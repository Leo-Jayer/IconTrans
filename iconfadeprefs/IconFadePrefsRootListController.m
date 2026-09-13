#import "IconFadePrefsRootListController.h"
#import <Preferences/PSSpecifier.h>

@implementation IconFadePrefsRootListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }
    return _specifiers;
}

- (id)readPreferenceValue:(PSSpecifier *)specifier {
    NSString *path = @"/var/mobile/Library/Preferences/com.yourcompany.iconfade.plist";
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:path];
    if (!settings[specifier.properties[@"key"]]) {
        return specifier.properties[@"default"];
    }
    return settings[specifier.properties[@"key"]];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    NSString *path = @"/var/mobile/Library/Preferences/com.yourcompany.iconfade.plist";
    NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    if (!settings) {
        settings = [NSMutableDictionary dictionary];
    }
    settings[specifier.properties[@"key"]] = value;
    [settings writeToFile:path atomically:YES];

    // 发送通知让 Tweak 重新加载设置
    CFStringRef notificationName = CFSTR("com.yourcompany.iconfade/prefsChanged");
    CFNotificationCenterPostNotification(
        CFNotificationCenterGetDarwinNotifyCenter(),
        notificationName,
        NULL,
        NULL,
        YES
    );
}

@end
