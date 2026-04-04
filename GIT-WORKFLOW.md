📚 SeerX 项目 GitHub 代码库更新完整指南

一、📋 准备工作（首次设置）

1.1 安装与配置 Git

# 检查 Git 是否已安装
git --version

# 如果未安装，根据系统安装：
# macOS: brew install git
# Ubuntu/Debian: sudo apt-get install git
# Windows: 下载 Git for Windows

# 配置用户信息（全局设置，只需一次）
git config --global user.name "你的GitHub用户名"
git config --global user.email "你的GitHub邮箱"


1.2 克隆项目到本地（首次）

# 进入你的工作目录
cd ~/Documents/Projects

# 克隆项目
git clone https://github.com/你的用户名/seerx.git
cd seerx


二、🔄 日常开发工作流

2.1 开始新功能开发

# 1. 确保在主分支并获取最新代码
git checkout main
git pull origin main

# 2. 创建新功能分支（命名规范：feature/功能名-版本）
git checkout -b feature/personal-center-v0.3

# 3. 开始开发...
# 在 lib/pages/profile_page.dart 等文件中进行修改


2.2 提交更改

# 1. 查看更改状态
git status

# 2. 查看具体更改内容
git diff

# 3. 添加更改到暂存区
# 添加所有更改
git add .

# 或添加特定文件
git add lib/pages/profile_page.dart
git add lib/services/prediction_service.dart

# 4. 提交更改（使用规范的提交信息）
git commit -m "feat: 实现V0.3个人中心页面

- 创建个人中心静态UI框架
- 添加预言数据统计功能
- 实现动态数据加载与刷新
- 优化用户界面交互体验

Closes #3"  # 如果有相关Issue号

# 提交信息格式建议：
# feat: 新功能
# fix: 修复bug
# docs: 文档更新
# style: 代码格式调整
# refactor: 代码重构
# test: 测试相关
# chore: 构建过程或辅助工具变动


2.3 推送分支到远程

# 1. 推送本地分支到远程仓库
git push origin feature/personal-center-v0.3

# 2. 如果远程不存在该分支，使用：
git push --set-upstream origin feature/personal-center-v0.3


三、🎯 版本发布流程

3.1 创建 Pull Request（GitHub网页操作）

1. 访问你的GitHub仓库：https://github.com/你的用户名/seerx
2. 点击 "Pull requests" → "New pull request"
3. 选择：
   • base: main (目标分支)

   • compare: feature/personal-center-v0.3 (源分支)

4. 填写PR标题和描述：
   • 标题格式：[V0.3] 个人中心与数据洞察

   • 描述内容：详细说明本次更新的功能、修改的文件、测试结果

5. 点击 "Create pull request"

3.2 代码审查与合并

# 1. 在本地确保代码是最新的
git checkout feature/personal-center-v0.3
git pull origin main  # 合并主分支最新代码

# 2. 解决可能的冲突
# 如果有冲突，编辑冲突文件，然后：
git add .
git commit -m "merge: 合并main分支最新代码"

# 3. 再次推送到远程
git push origin feature/personal-center-v0.3

# 4. 在GitHub上点击 "Merge pull request"
# 5. 删除已合并的功能分支（可选）
git branch -d feature/personal-center-v0.3
git push origin --delete feature/personal-center-v0.3


3.3 打版本标签（重要版本发布）

# 1. 切换到主分支并拉取最新代码
git checkout main
git pull origin main

# 2. 创建版本标签
git tag -a v0.3.0 -m "SeerX V0.3: 个人中心与数据洞察"

# 3. 推送标签到远程
git push origin v0.3.0

# 4. 查看所有标签
git tag -l


四、📁 项目结构维护

4.1 更新项目文档

# 1. 更新 README.md（记录版本更新）
# 在 README.md 中添加：
# ## V0.3 (2026-04-04)
# - ✅ 实现个人中心页面
# - ✅ 添加预言数据统计功能
# - ✅ 支持动态数据加载与刷新

# 2. 更新 CHANGELOG.md（如果有）
# 3. 提交文档更新
git add README.md CHANGELOG.md
git commit -m "docs: 更新V0.3版本文档"
git push origin main


4.2 清理无用分支

# 查看所有分支
git branch -a

# 删除本地已合并的分支
git branch --merged main | grep -v "main" | xargs git branch -d

# 删除远程已合并的分支
git remote prune origin


五、🚨 常见问题与解决方案

5.1 撤销更改

# 撤销未暂存的更改
git checkout -- 文件名

# 撤销已暂存但未提交的更改
git reset HEAD 文件名

# 撤销最近一次提交（保留更改）
git reset --soft HEAD~1

# 撤销最近一次提交（丢弃更改）
git reset --hard HEAD~1


5.2 解决合并冲突

# 1. 拉取最新代码时发现冲突
git pull origin main

# 2. 查看冲突文件
git status

# 3. 手动编辑冲突文件（搜索 <<<<<<< 标记）
# 4. 解决冲突后标记为已解决
git add 冲突文件

# 5. 完成合并
git commit -m "merge: 解决合并冲突"


5.3 恢复误删分支

# 查看最近的操作记录
git reflog

# 找到删除分支前的commit hash
git checkout -b 分支名 commit_hash


六、📊 最佳实践清单

✅ 每次开发前
git checkout main

git pull origin main

git checkout -b feature/描述性名称

✅ 每次提交前
git status 检查更改

git diff 查看具体修改

编写有意义的提交信息

确保代码能正常编译运行

✅ 每次推送前
运行 flutter analyze 检查代码质量

运行 flutter test 确保测试通过

更新相关文档（README、注释等）

✅ 版本发布时
更新版本号（pubspec.yaml）

更新CHANGELOG

创建版本标签

更新项目路线图

七、🔧 自动化脚本（可选）

创建 scripts/git-workflow.sh 简化流程：
#!/bin/bash
# 简化Git工作流脚本

echo "🚀 SeerX Git 工作流助手"

case $1 in
  "start")
    echo "开始新功能开发..."
    git checkout main
    git pull origin main
    read -p "请输入功能分支名: " branch_name
    git checkout -b "feature/$branch_name"
    ;;
  "commit")
    echo "提交更改..."
    git status
    read -p "提交信息: " commit_msg
    git add .
    git commit -m "$commit_msg"
    ;;
  "push")
    echo "推送到远程..."
    current_branch=$(git branch --show-current)
    git push origin "$current_branch"
    ;;
  "pr")
    echo "创建Pull Request..."
    current_branch=$(git branch --show-current)
    echo "请访问: https://github.com/你的用户名/seerx/compare/main...$current_branch"
    ;;
  *)
    echo "可用命令:"
    echo "  ./git-workflow.sh start  开始新功能"
    echo "  ./git-workflow.sh commit 提交更改"
    echo "  ./git-workflow.sh push   推送到远程"
    echo "  ./git-workflow.sh pr     创建PR"
    ;;
esac


八、📝 记录模板

8.1 提交信息模板


类型(范围): 简要描述

详细描述（可选）：
- 修改点1
- 修改点2
- 修复的问题

关联Issue: #编号


8.2 PR描述模板


## 变更概述
简要描述本次PR的主要变更

## 修改内容
- [ ] 文件1：修改说明
- [ ] 文件2：修改说明

## 测试验证
- [ ] 功能测试通过
- [ ] UI测试通过
- [ ] 性能测试通过

## 相关Issue
Closes #编号


💡 快速参考卡片

操作 命令 说明

开始开发 git checkout -b feature/名称 创建功能分支

查看状态 git status 查看更改状态

提交更改 git commit -m "描述" 提交到本地仓库

推送到远程 git push origin 分支名 上传到GitHub

拉取更新 git pull origin main 获取最新代码

查看历史 git log --oneline 简洁查看提交历史

创建标签 git tag -a v1.0.0 标记重要版本

建议：将此指南保存为 docs/GIT_WORKFLOW.md 文件，方便随时查阅。每次更新代码库时，按照这个流程操作，可以确保代码管理的规范性和一致性。

现在您可以按照这个指南来更新您的GitHub代码库了！如果有任何步骤不清楚或遇到问题，请随时问我。
