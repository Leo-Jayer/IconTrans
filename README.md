# IconFade - iOS 桌面图标渐变透明插件

## 功能
- 桌面图标静止指定时间后**渐变透明**
- 触摸图标时**立即恢复可见**
- 支持自定义延迟时间和透明度
- 适配 iOS 15-16, Dopamine rootless 越狱

## 环境要求

### 必须
- **macOS** (Intel/M1/M2/M3 均可)
- **Xcode** (从 App Store 或开发者网站安装)
- **Theos** (越狱插件开发工具链)
- **Homebrew** (用于安装依赖)

### 安装 Theos (首次只需执行一次)

```bash
# 1. 安装 Homebrew (如未安装)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. 安装依赖
brew install dpkg ldid

# 3. 克隆 Theos
export THEOS=~/theos
git clone --recursive https://github.com/theos/theos.git $THEOS

# 4. 添加到环境变量 (添加到 ~/.zshrc 或 ~/.bash_profile)
echo 'export THEOS=~/theos' >> ~/.zshrc
echo 'export PATH=$THEOS/bin:$PATH' >> ~/.zshrc
source ~/.zshrc
```

## 编译步骤

### 方法一：一键编译 (推荐)

```bash
cd IconFade
chmod +x build.sh
./build.sh
```

### 方法二：手动编译

```bash
cd IconFade

# 清理
make clean

# 编译
make

# 打包成 deb
make package

# 自动安装到设备 (需在同一 WiFi 下)
make install THEOS_DEVICE_IP=192.168.x.x
```

编译成功后，`.deb` 文件会在 `packages/` 目录下。

## 安装到设备

### 方式一：自动安装 (需要 SSH)
```bash
make install THEOS_DEVICE_IP=你的设备IP
```

### 方式二：手动安装
1. 用 `scp` 或 AirDrop 把 `.deb` 传到 iPhone
2. 用 **Filza** 打开 `.deb` 文件 → 点击安装
3. 或在终端执行：`dpkg -i /path/to/IconFade.deb`
4. 安装后 SpringBoard 会自动重启

## 使用

1. 打开 **设置 → IconFade**
2. 调整参数：
   - **启用插件**：总开关
   - **延迟时间**：图标静止后多久开始透明 (0.5~60秒)
   - **目标透明度**：最终透明度 (0=完全透明, 1=不透明)
3. 返回桌面即可看到效果

## 项目文件说明

| 文件 | 说明 |
|------|------|
| `Tweak.xm` | 核心 Hook 代码 |
| `Makefile` | 编译配置 (已配置 rootless) |
| `control` | 包信息 |
| `IconFade.plist` | 注入目标声明 |
| `iconfadeprefs/` | 设置面板源码 |
| `build.sh` | 一键编译脚本 |

## 常见问题

**Q: 编译报错 "theos not found"?**
A: 确保 `THEOS` 环境变量已设置，且 `$THEOS/bin` 在 PATH 中。

**Q: 安装后没有效果?**
A: 检查设置中是否启用了插件，或尝试注销 SpringBoard。

**Q: 图标透明后找不到了?**
A: 触摸屏幕任意位置图标就会恢复可见。建议透明度不要低于 0.1。

**Q: 可以修改 Bundle ID 吗?**
A: 可以。全局替换 `com.yourcompany.iconfade` 为你自己的 ID 即可。

## 技术细节

- Hook 了 `SBIconView` 的 `didMoveToWindow` 来启动定时器
- 使用 `touchesBegan/Ended/Cancelled` 检测触摸事件
- 通过 `CFNotificationCenter` 实现设置实时更新 (无需注销)
- 使用 `UIView animateWithDuration` 实现平滑渐变动画

## License

MIT
