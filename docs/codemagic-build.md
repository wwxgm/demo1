# Codemagic 构建说明

本项目已添加 `codemagic.yaml`，用于 Codemagic 云端构建：

- `ios-unsigned-workflow`：macOS 云端构建 unsigned `.ipa`
- `android-apk-workflow`：Linux 云端构建 Android `.apk`

## 操作步骤

1. 打开 https://codemagic.io/start/
2. 使用 GitHub 登录 Codemagic。
3. Add application，选择仓库 `wwxgm/demo1`。
4. 让 Codemagic 扫描根目录的 `codemagic.yaml`。
5. 手动运行 `iOS unsigned Flutter build`。
6. 构建完成后，在 Artifacts 下载 `unsigned-autovi.ipa`。

## 安装到 iPhone

下载 `unsigned-autovi.ipa` 后，在 Windows 上使用 Sideloadly + Apple ID 重新签名安装。

免费 Apple ID 通常 7 天后需要重新签名安装。

## 注意

Codemagic 若提示无法生成可安装 IPA，需要改为 Apple 证书签名构建。免费 Apple ID 通常不能直接在 Codemagic 上完成签名，需要本地 Sideloadly 或付费 Apple Developer 证书。
