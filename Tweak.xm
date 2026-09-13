#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

// 偏好设置路径 (rootless)
#define PREFS_PATH @"/var/mobile/Library/Preferences/com.yourcompany.iconfade.plist"

// 默认配置
static CGFloat kDefaultDelay = 3.0;      // 默认延迟3秒
static CGFloat kDefaultAlpha = 0.2;      // 默认透明度20%
static BOOL kDefaultEnabled = YES;       // 默认启用

// 当前配置
static CGFloat gDelaySeconds = 3.0;
static CGFloat gTargetAlpha = 0.2;
static BOOL gEnabled = YES;

// 读取偏好设置
static void loadPreferences() {
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:PREFS_PATH];
    if (prefs) {
        gEnabled = [prefs objectForKey:@"enabled"] ? [[prefs objectForKey:@"enabled"] boolValue] : YES;
        gDelaySeconds = [prefs objectForKey:@"delay"] ? [[prefs objectForKey:@"delay"] floatValue] : 3.0;
        gTargetAlpha = [prefs objectForKey:@"alpha"] ? [[prefs objectForKey:@"alpha"] floatValue] : 0.2;

        // 限制范围
        if (gDelaySeconds < 0.5) gDelaySeconds = 0.5;
        if (gDelaySeconds > 60) gDelaySeconds = 60;
        if (gTargetAlpha < 0.0) gTargetAlpha = 0.0;
        if (gTargetAlpha > 1.0) gTargetAlpha = 1.0;
    }
}

// 监听设置变化
static void prefsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    loadPreferences();
}

// SBIconView 接口声明
@interface SBIconView : UIView
@property (nonatomic, retain) NSTimer *fadeTimer;
- (void)startFadeTimer;
- (void)fadeOut;
- (void)fadeIn;
@end

%hook SBIconView

%property (nonatomic, retain) NSTimer *fadeTimer;

// 当图标被添加到窗口时启动定时器
- (void)didMoveToWindow {
    %orig;

    if (!gEnabled) return;

    // 取消之前的定时器
    if (self.fadeTimer) {
        [self.fadeTimer invalidate];
        self.fadeTimer = nil;
    }

    // 先恢复完全不透明
    self.alpha = 1.0;

    // 启动新的定时器
    [self startFadeTimer];
}

// 启动渐变定时器
%new
- (void)startFadeTimer {
    if (!gEnabled) return;

    // 使用弱引用避免循环引用
    __weak SBIconView *weakSelf = self;
    self.fadeTimer = [NSTimer scheduledTimerWithTimeInterval:gDelaySeconds
                                                      repeats:NO
                                                        block:^(NSTimer *timer) {
        [weakSelf fadeOut];
    }];
}

// 渐变透明
%new
- (void)fadeOut {
    if (!gEnabled) return;

    [UIView animateWithDuration:0.8
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
        self.alpha = gTargetAlpha;
    } completion:nil];
}

// 恢复不透明
%new
- (void)fadeIn {
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
        self.alpha = 1.0;
    } completion:nil];
}

// 触摸开始时恢复可见
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    %orig;

    if (!gEnabled) return;

    // 取消定时器
    if (self.fadeTimer) {
        [self.fadeTimer invalidate];
        self.fadeTimer = nil;
    }

    // 恢复可见
    [self fadeIn];
}

// 触摸结束时重新启动定时器
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    %orig;

    if (!gEnabled) return;

    // 延迟后重新启动淡出
    [self startFadeTimer];
}

// 触摸取消时重新启动定时器
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    %orig;

    if (!gEnabled) return;

    [self startFadeTimer];
}

// 从窗口移除时清理定时器
- (void)willMoveToWindow:(UIWindow *)newWindow {
    %orig;

    if (!newWindow) {
        if (self.fadeTimer) {
            [self.fadeTimer invalidate];
            self.fadeTimer = nil;
        }
    }
}

%end

// 构造函数 - 插件加载时执行
%ctor {
    // 加载偏好设置
    loadPreferences();

    // 注册设置变化监听
    CFNotificationCenterAddObserver(
        CFNotificationCenterGetDarwinNotifyCenter(),
        NULL,
        prefsChanged,
        CFSTR("com.yourcompany.iconfade/prefsChanged"),
        NULL,
        CFNotificationSuspensionBehaviorDeliverImmediately
    );
}
