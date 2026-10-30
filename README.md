# PixelSift

面向剪辑素材整理的 macOS 视频下载工具。基于 [VidTuck](https://github.com/xiangye-zephyr/VidTuck) 开发，增加下载前的格式与清晰度确认、批量偏好和逐条调整。

**Apple Silicon · macOS 15+ · 中文界面 · 预览版**

[下载 Mac 版](https://github.com/wujimu4-jpg/PixelSift/releases/tag/v0.3.0-preview.1) · [全部发行版本](https://github.com/wujimu4-jpg/PixelSift/releases)

## 安装

1. 在 Releases 下载 `PixelSift-0.3.0-preview.1-macOS-arm64.zip`，不要选择 Source code。
2. 对照 `SHA256SUMS.txt` 校验下载包，解压后将 `PixelSift.app` 放进「应用程序」。
3. 当前为临时签名，未进行苹果 Developer ID 签名及公证。首次打开若被阻止，请参照[苹果官方说明](https://support.apple.com/zh-cn/102445)，在「系统设置 → 隐私与安全」使用「仍要打开」；无需关闭系统安全保护。

已内置 yt-dlp、Deno 和 FFmpeg，无需安装开发环境。暂不支持 Intel Mac 或 Windows。

## 下载素材

- 粘贴或拖入视频链接，支持一批最多 50 条。
- 工具先解析视频源，再显示每条实际可用的格式与清晰度。
- 顶部设置统一偏好，点击「应用到待添加视频」后生效；每条也可以单独调整。
- MP4 选项要求源中存在 H.264 视频与 AAC 音频，便于常见剪辑软件处理。MKV 保留源编码，可能进行无损重封装。
- 支持 4K、1080p、720p，按视频短边判断，兼容竖屏素材。源未提供的组合置灰，不自动降级、放大或重新编码。
- 点击「添加 N 条可下载任务」，已匹配条目进入队列，其他条目留待处理。全部添加后弹窗关闭。

例如，某条视频的 4K 只有 VP9／AV1，而 1080p 提供 H.264：MP4 的 4K 不可选；可以选择 MP4 1080p，或切换 MKV 4K。

## 支持与限制

沿用 VidTuck 对 YouTube、B站、抖音和小红书的解析能力。YouTube 需要可访问的网络；部分内容需要本人登录。遇到验证时，使用「网页辅助」打开目标视频、完成登录并播放，再点击「读取此页」。

网站接口、账号权限、网络与链接有效期都会影响结果。直接媒体缺少编码信息时，会核验最多 12 个候选；无法确认的组合保持不可选。当前三档之外的清晰度不在新选择界面中开放。多语言音轨尚无独立选择器。

这是首个预览版本。已验证批量选择逻辑、真实 MP4/MKV 下载与重封装、直接媒体编码探测、原有核心行为回归，以及实际 YouTube 1080p H.264＋AAC 下载和完整解码。尚未覆盖所有平台的视频类型，亦未完成剪映实际导入验收。

## 本机数据与隐私

不需要 PixelSift 账号；无遥测、无云端上传服务。下载和解析在本机进行，访问目标网站、媒体服务器及官方更新服务。

为保持本地预览版兼容，内部 bundle ID 暂沿用 `local.streamnest.preview`，数据目录为 `~/Library/Application Support/VidTuck-Preview/`。默认下载目录为 `~/Downloads/VidTuck/`，可在设置中修改。原 VidTuck 数据目录独立，发行版不会主动导入其登录信息或下载记录。

应用包不包含账号、Cookie、下载任务或个人视频。请勿把应用数据目录上传或附在反馈中；错误报告请移除凭据和带签名参数的链接。

## 从源码构建

需要 Apple Silicon Mac、macOS 15+、Xcode Command Line Tools；依赖准备要求参见 `scripts/prepare-tools.sh`。

```sh
git clone https://github.com/wujimu4-jpg/PixelSift.git
cd PixelSift
zsh scripts/prepare-tools.sh
zsh scripts/build.sh
```

也可使用已准备好的工具目录：

```sh
zsh scripts/build.sh /absolute/path/to/tools /absolute/path/to/PixelSift.app
```

Swift 核心测试位于 `scripts/FormatSelectionTests.swift` 与 `scripts/CoreTests.swift`，使用隔离目录和仅本机 HTTP 测试媒体。UI 测试 `scripts/BatchUITests.cjs` 需要 Playwright 和本机 Chrome，仅用于开发，不属于应用运行依赖。

## 来源与许可

PixelSift 基于 xiangye-zephyr 的 [VidTuck 0.2.6](https://github.com/xiangye-zephyr/VidTuck)；保留原始 MIT 许可和署名。本仓库新增格式选择、批量确认和品牌调整。PixelSift 与上游项目为独立发布。

源码许可见 [LICENSE](LICENSE)。第三方工具保留各自许可，来源、版本、FFmpeg 对应源码及许可证见 [ThirdParty](ThirdParty/NOTICE.md)。请仅下载你有权下载和使用的内容。
