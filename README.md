🔮 SeerX (大预言家)

记录你的每一个预言，验证你的直觉。 一个让你创建、追踪并验证个人预言的应用。

https://img.shields.io/badge/Flutter-3.19-blue](https://flutter.dev)

https://img.shields.io/badge/Dart-3.3-blue](https://dart.dev)

https://img.shields.io/badge/License-MIT-green.svg](LICENSE)

https://img.shields.io/badge/版本-V0.1_基础版-orange](https://github.com/sytq2000/SeerX)

✨ 特性

• 📝 创建预言：清晰描述你的预测，并设置验证到期时间。

• 📊 状态追踪：四种清晰的状态流转：待验证 → 待裁决 → 成功/失败。

• ✅ 一键裁决：到期后，在详情页轻松标记预言结果。

• 📱 多端就绪：基于 Flutter 构建，未来可轻松编译为 iOS、Android 及 Web 应用。

• 🎨 简洁现代：采用 Material Design 3 设计语言，界面直观友好。

🎯 当前版本 (V0.1) 已完成功能

• ✅ 模拟登录：输入任意用户名即可进入应用。

• ✅ 预言管理：

    ◦ 查看所有预言列表（含示例数据）。

    ◦ 创建新预言（内容、到期时间）。

    ◦ 查看预言详情。

• ✅ 裁决系统：

    ◦ 对到期预言进行裁决（成功/失败）。

    ◦ 实时更新预言状态与界面反馈。

• ✅ 状态可视化：通过彩色徽章清晰区分不同状态。

🚀 快速开始

运行项目

确保你的开发环境已安装 https://flutter.dev/docs/get-started/install (推荐 3.0 或更高版本)。
# 1. 克隆仓库
git clone https://github.com/sytq2000/SeerX.git
cd SeerX

# 2. 获取项目依赖
flutter pub get

# 3. 在 Chrome 浏览器中运行（网页版）
flutter run -d chrome

应用将在本地启动，默认地址为 http://localhost:xxxxx。

项目结构


lib/
├── main.dart                 # 应用入口
├── models/                   # 数据模型
│   └── prediction.dart       # 预言(Prediction)模型类
├── services/                 # 服务层（模拟数据）
│   ├── auth_service.dart     # 模拟认证服务
│   └── prediction_service.dart # 预言数据管理服务
├── pages/                    # 页面
│   ├── login_page.dart       # 登录页
│   ├── home_page.dart        # 主页（预言列表）
│   ├── create_page.dart      # 创建预言页
│   └── detail_page.dart      # 预言详情页
└── widgets/                  # 可复用组件
    ├── prediction_card.dart  # 预言卡片组件
    └── status_badge.dart     # 状态标签组件


📖 使用指南

1.  登录：启动应用，输入任意用户名，点击“开始预言”。
2.  浏览：主页展示所有预言，包括预设的示例预言。
3.  创建：点击右下角“+”按钮，填写预言内容和到期时间，发布你的第一个预言。
4.  验证：预言到期后，进入详情页，点击“预言成功”或“预言失败”进行裁决。

🗺️ 开发路线图

版本 目标 状态

V0.1 基础 MVP - 实现“记录-到期-验证”核心闭环 ✅ 已完成

V0.2 数据持久化 - 使用 shared_preferences 或 hive 保存数据，刷新页面不丢失 ✅ 已完成

V0.3 个人中心 - 添加用户数据统计（成功率、总数等） 📅 计划中

V0.4 增强功能 - 预言分类、搜索、分享、通知提醒等 📅 计划中

🛠 技术栈

• 框架：https://flutter.dev/ - Google 的跨平台 UI 工具包。

• 语言：https://dart.dev/ - 客户端优化的语言，用于多平台应用。

• 状态管理：目前使用 Flutter 内置的 setState 进行简单状态管理。

• 数据存储：V0.1 为内存存储，V0.2 计划引入本地持久化方案。

🤝 如何贡献

我们欢迎任何形式的贡献！如果你有任何想法、发现了 Bug，或者想改进代码：

1.  提交 Issue：报告 Bug 或提议新功能。
2.  发起 Pull Request：
    ◦ Fork 本仓库。

    ◦ 创建你的功能分支 (git checkout -b feature/AmazingFeature)。

    ◦ 提交你的更改 (git commit -m 'Add some AmazingFeature')。

    ◦ 推送到分支 (git push origin feature/AmazingFeature)。

    ◦ 在 GitHub 上开启一个 Pull Request。

📄 许可证

本项目基于 MIT 许可证开源。详情请见 LICENSE 文件。

🙋 常见问题

Q: 为什么关闭浏览器后，我创建的预言就没了？
A: 当前 V0.1 版本使用内存存储，用于快速原型验证。数据持久化功能已在 V0.2 计划中。

Q: 预言到期后，状态会自动变为“待裁决”吗？
A: 当前版本中，部分示例预言的状态是预设的。完整的时间自动判断逻辑将在后续版本中完善。

如果这个项目对你有帮助或启发，欢迎给个 ⭐ Star！你的支持是我们持续更新的最大动力。
