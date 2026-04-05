#!/bin/bash
# ============================================
# SeerX Git 工作流助手
# 版本: 2.0
# 创建: 2026-03-29
# 最后更新: 2026-03-29
# 功能: 完整的 SeerX 项目 Git 工作流程自动化
# ============================================

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # 恢复默认颜色

# 显示带颜色的消息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

print_divider() {
    echo "========================================="
}

# 检查当前目录是否为 Git 仓库
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "当前目录不是 Git 仓库。"
        exit 1
    fi
}

# 显示当前分支信息
show_branch_info() {
    current_branch=$(git branch --show-current 2>/dev/null)
    if [ -n "$current_branch" ]; then
        print_divider
        print_info "当前分支: $current_branch"
        print_divider
    fi
}

# 检查是否在项目目录中
check_project_dir() {
    if [ ! -f "pubspec.yaml" ]; then
        print_warning "未检测到 Flutter 项目 (pubspec.yaml)。"
        read -p "是否继续？(y/n): " confirm
        if [[ $confirm != "y" && $confirm != "Y" ]]; then
            exit 1
        fi
    fi
}

# 检查是否有未提交的更改
check_uncommitted_changes() {
    if ! git diff-index --quiet HEAD --; then
        print_warning "检测到未提交的更改。"
        git status --short
        return 1
    fi
    return 0
}

# 主菜单
main_menu() {
    clear
    print_divider
    echo "          🔧 SeerX Git 工作流助手 v2.0         "
    print_divider
    echo ""
    
    # 显示项目信息
    if [ -f "pubspec.yaml" ]; then
        project_name=$(grep "name:" pubspec.yaml | head -1 | cut -d ':' -f2 | xargs)
        print_info "项目: $project_name"
    fi
    
    show_branch_info
    echo ""
    echo "请选择操作："
    echo "1. 🚀 开始新功能开发 (V0.x)"
    echo "2. 📝 提交更改"
    echo "3. 📤 推送到远程仓库"
    echo "4. 🔄 同步主分支"
    echo "5. 📊 查看当前状态"
    echo "6. 📖 更新项目文档 (README)"
    echo "7. 🏷️  创建版本标签"
    echo "8. 🧹 清理本地分支"
    echo "9. 🧪 运行应用验证"
    echo "0. ❌ 退出"
    echo ""
    print_divider
}

# 功能 1: 开始新功能开发
start_new_feature() {
    print_step "🚀 开始新功能开发流程"
    
    # 1. 检查是否有未提交的更改
    if ! check_uncommitted_changes; then
        echo ""
        read -p "有未提交的更改，是否先提交？(y/n): " commit_now
        if [[ $commit_now == "y" || $commit_now == "Y" ]]; then
            commit_changes
        else
            print_warning "未提交的更改可能会在切换分支时丢失。"
            read -p "是否继续？(y/n): " continue_anyway
            if [[ $continue_anyway != "y" && $continue_anyway != "Y" ]]; then
                return
            fi
        fi
    fi
    
    # 2. 切换到主分支
    print_info "切换到主分支..."
    git checkout main
    
    # 3. 拉取最新代码
    print_info "拉取主分支最新代码..."
    if ! git pull origin main; then
        print_error "拉取代码失败，请检查网络连接或权限。"
        return
    fi
    
    # 4. 创建新功能分支
    echo ""
    print_info "请输入功能分支名称，格式建议：v0.x-功能描述"
    print_info "例如: v0.5-tag-system, v0.6-user-profile"
    echo ""
    read -p "请输入功能分支名称: " feature_name
    
    if [ -z "$feature_name" ]; then
        print_error "分支名称不能为空。"
        return
    fi
    
    # 规范化分支名
    feature_name=$(echo "$feature_name" | tr ' ' '-' | tr -cd '[:alnum:]-')
    
    branch_name="feature/$feature_name"
    print_info "创建并切换到分支: $branch_name"
    
    if git checkout -b "$branch_name"; then
        print_success "✅ 已成功创建并切换到分支: $branch_name"
        echo ""
        print_info "您现在可以开始开发新功能了！"
        echo ""
        print_info "开发完成后，请按顺序执行："
        print_info "1. 使用选项 2 提交更改"
        print_info "2. 使用选项 3 推送到远程仓库"
        print_info "3. 在 GitHub 上创建 Pull Request 并合并"
        print_info "4. 使用选项 4 同步主分支"
        print_info "5. 使用选项 6 更新项目文档"
    else
        print_error "❌ 创建分支失败，可能已存在同名分支。"
    fi
}

# 功能 2: 提交更改
commit_changes() {
    print_step "📝 提交更改流程"
    
    # 显示当前状态
    print_info "当前更改状态："
    git status --short
    
    echo ""
    echo "请选择提交方式："
    echo "1. 提交所有更改"
    echo "2. 选择特定文件提交"
    echo "3. 查看更改详情"
    echo "4. 返回主菜单"
    
    read -p "请输入选项 (1-4): " commit_option
    
    case $commit_option in
        1)
            print_info "添加所有更改到暂存区..."
            if ! git add .; then
                print_error "添加文件失败。"
                return
            fi
            ;;
        2)
            print_info "当前更改的文件："
            git status --porcelain | grep -v "^??"
            echo ""
            read -p "请输入要提交的文件（多个文件用空格分隔）: " files_to_add
            if [ -n "$files_to_add" ]; then
                if ! git add $files_to_add; then
                    print_error "添加文件失败。"
                    return
                fi
            else
                print_error "没有选择文件。"
                return
            fi
            ;;
        3)
            print_info "更改详情："
            git diff
            echo ""
            read -p "按 Enter 键继续..." dummy
            commit_changes
            return
            ;;
        4)
            return
            ;;
        *)
            print_error "无效选项。"
            return
            ;;
    esac
    
    # 输入提交信息
    echo ""
    print_info "提交信息格式建议："
    print_info "  feat: 添加新功能"
    print_info "  fix: 修复bug"
    print_info "  docs: 更新文档"
    print_info "  style: 代码格式调整"
    print_info "  refactor: 代码重构"
    echo ""
    read -p "请输入提交信息: " commit_message
    if [ -z "$commit_message" ]; then
        print_error "提交信息不能为空。"
        return
    fi
    
    # 执行提交
    print_info "正在提交更改..."
    if git commit -m "$commit_message"; then
        print_success "✅ 更改已成功提交！"
        
        # 显示提交信息
        print_info "提交信息: $commit_message"
        print_info "提交哈希: $(git rev-parse --short HEAD)"
    else
        print_error "❌ 提交失败。"
    fi
}

# 功能 3: 推送到远程仓库
push_to_remote() {
    print_step "📤 推送到远程仓库"
    
    current_branch=$(git branch --show-current)
    if [ -z "$current_branch" ]; then
        print_error "无法获取当前分支信息。"
        return
    fi
    
    print_info "当前分支: $current_branch"
    
    # 检查是否需要设置上游分支
    upstream_info=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
    
    if [ -z "$upstream_info" ]; then
        print_warning "当前分支没有设置上游分支。"
        read -p "是否设置上游分支并推送？(y/n): " confirm
        if [[ $confirm == "y" || $confirm == "Y" ]]; then
            print_info "正在推送到远程仓库并设置上游分支..."
            if git push --set-upstream origin "$current_branch"; then
                print_success "✅ 成功推送到远程仓库！"
            else
                print_error "❌ 推送失败。"
                return
            fi
        else
            print_info "操作已取消。"
            return
        fi
    else
        print_info "将推送到远程仓库: $upstream_info"
        echo ""
        read -p "是否继续？(y/n): " confirm
        if [[ $confirm != "y" && $confirm != "Y" ]]; then
            print_info "操作已取消。"
            return
        fi
        
        # 推送到远程
        print_info "正在推送到远程仓库..."
        if git push origin "$current_branch"; then
            print_success "✅ 成功推送到远程仓库！"
        else
            print_error "❌ 推送失败。"
            return
        fi
    fi
    
    echo ""
    print_info "下一步：请在 GitHub 上创建 Pull Request"
    print_info "访问: https://github.com/sytq2000/seerx/compare/main...$current_branch"
    echo ""
    print_info "创建PR后，请执行以下操作："
    print_info "1. 在GitHub上审查代码变更"
    print_info "2. 点击 'Merge pull request' 合并到 main 分支"
    print_info "3. 回到本工具，使用选项 4 同步主分支"
}

# 功能 4: 同步主分支
sync_main_branch() {
    print_step "🔄 同步主分支"
    
    # 保存当前分支
    current_branch=$(git branch --show-current)
    
    # 切换到主分支
    print_info "切换到主分支..."
    if ! git checkout main; then
        print_error "切换分支失败。"
        return
    fi
    
    # 拉取最新代码
    print_info "拉取主分支最新代码..."
    if git pull origin main; then
        print_success "✅ 主分支已同步到最新状态！"
        
        # 检查是否有未合并的更改
        if [ "$current_branch" != "main" ] && [ -n "$current_branch" ]; then
            echo ""
            read -p "是否切换回原来的分支 '$current_branch'？(y/n): " switch_back
            if [[ $switch_back == "y" || $switch_back == "Y" ]]; then
                git checkout "$current_branch"
            fi
        fi
    else
        print_error "❌ 同步失败，可能存在冲突。"
    fi
}

# 功能 5: 查看当前状态
show_status() {
    print_step "📊 查看当前状态"
    
    print_info "Git 仓库状态："
    print_divider
    
    # 显示分支信息
    print_info "分支信息："
    git branch -v
    
    print_divider
    print_info "状态信息："
    git status
    
    print_divider
    print_info "最近提交记录："
    git log --oneline -5
    
    print_divider
    print_info "远程仓库信息："
    git remote -v
    
    print_divider
    # 显示未推送的提交
    print_info "未推送的提交："
    git log --oneline origin/main..HEAD 2>/dev/null || print_info "没有未推送的提交。"
}

# 功能 6: 更新项目文档
update_documentation() {
    print_step "📖 更新项目文档流程"
    
    # 确保当前在 main 分支
    current_branch=$(git branch --show-current)
    if [ "$current_branch" != "main" ]; then
        print_warning "当前不在 main 分支，建议在 main 分支上更新文档。"
        read -p "是否切换到 main 分支？(y/n): " switch_to_main
        if [[ $switch_to_main == "y" || $switch_to_main == "Y" ]]; then
            git checkout main
            if [ $? -ne 0 ]; then
                print_error "切换分支失败，请手动处理。"
                return
            fi
        else
            print_info "您选择在当前分支（$current_branch）上更新文档，请注意这可能不是标准流程。"
        fi
    fi
    
    # 拉取最新代码，避免冲突
    print_info "拉取最新主分支代码..."
    git pull origin main
    
    # 打开 README.md 文件
    readme_file="README.md"
    if [ ! -f "$readme_file" ]; then
        print_error "找不到 $readme_file 文件。"
        return
    fi
    
    print_info "正在打开 $readme_file 文件..."
    
    # 尝试用 VS Code 打开，如果失败则用默认编辑器
    if command -v code >/dev/null 2>&1; then
        code "$readme_file"
    else
        print_warning "未找到 'code' 命令，尝试使用系统默认编辑器打开。"
        if [[ "$OSTYPE" == "darwin"* ]]; then
            open "$readme_file"
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            xdg-open "$readme_file"
        else
            print_error "无法自动打开文件，请手动编辑 $readme_file。"
            return
        fi
    fi
    
    # 等待用户编辑完成
    echo ""
    read -p "请编辑 README.md 文件，保存并关闭编辑器后按 Enter 键继续..."
    
    # 检查文件是否有更改
    if git diff --quiet "$readme_file"; then
        print_info "README.md 文件未更改。"
        return
    fi
    
    # 显示更改
    print_info "README.md 的更改："
    git diff "$readme_file"
    
    echo ""
    read -p "是否提交并推送这些更改？(y/n): " confirm_push
    if [[ $confirm_push == "y" || $confirm_push == "Y" ]]; then
        # 提交更改
        print_info "提交更改..."
        git add "$readme_file"
        git commit -m "docs: 更新 README.md 文档"
        
        # 推送到远程
        print_info "推送到远程仓库..."
        git push origin main
        
        if [ $? -eq 0 ]; then
            print_success "✅ 文档更新已提交并推送！"
        else
            print_error "❌ 推送失败，请检查错误信息。"
        fi
    else
        print_info "更改未提交。您可以选择稍后手动提交。"
    fi
}

# 功能 7: 创建版本标签
create_version_tag() {
    print_step "🏷️  创建版本标签"
    
    # 检查是否在 main 分支
    current_branch=$(git branch --show-current)
    if [ "$current_branch" != "main" ]; then
        print_warning "建议在 main 分支上创建版本标签。"
        read -p "是否切换到 main 分支？(y/n): " switch_to_main
        if [[ $switch_to_main == "y" || $switch_to_main == "Y" ]]; then
            git checkout main
        fi
    fi
    
    # 拉取最新代码
    print_info "拉取最新代码..."
    git pull origin main
    
    # 显示最近的标签
    print_info "最近的版本标签："
    git tag -l | tail -5
    
    echo ""
    print_info "版本号格式建议：v0.1.0, v1.0.0, v2.3.1"
    read -p "请输入新版本标签: " version_tag
    
    if [ -z "$version_tag" ]; then
        print_error "版本标签不能为空。"
        return
    fi
    
    # 检查标签是否已存在
    if git tag -l | grep -q "^$version_tag$"; then
        print_error "版本标签 $version_tag 已存在。"
        return
    fi
    
    read -p "请输入版本描述（可选）: " version_description
    if [ -z "$version_description" ]; then
        version_description="SeerX $version_tag"
    fi
    
    # 创建标签
    print_info "创建版本标签: $version_tag"
    if git tag -a "$version_tag" -m "$version_description"; then
        print_success "✅ 本地标签创建成功！"
        
        # 推送到远程
        read -p "是否推送到远程仓库？(y/n): " push_tag
        if [[ $push_tag == "y" || $push_tag == "Y" ]]; then
            print_info "推送标签到远程仓库..."
            if git push origin "$version_tag"; then
                print_success "✅ 版本标签已推送到远程仓库！"
            else
                print_error "❌ 标签推送失败。"
            fi
        fi
    else
        print_error "❌ 标签创建失败。"
    fi
}

# 功能 8: 清理本地分支
cleanup_branches() {
    print_step "🧹 清理本地分支"
    
    # 显示当前分支
    current_branch=$(git branch --show-current)
    print_info "当前分支: $current_branch"
    
    # 获取已合并到 main 的分支
    print_info "已合并到 main 的分支："
    git branch --merged main | grep -v "main"
    
    echo ""
    read -p "是否删除所有已合并到 main 的分支？(y/n): " delete_merged
    if [[ $delete_merged == "y" || $delete_merged == "Y" ]]; then
        print_info "正在删除已合并的分支..."
        git branch --merged main | grep -v "main" | xargs -n 1 git branch -d
        print_success "✅ 已合并分支清理完成。"
    fi
    
    # 显示未合并的分支
    echo ""
    print_info "未合并到 main 的分支："
    git branch --no-merged main | grep -v "main"
    
    echo ""
    read -p "是否查看远程分支？(y/n): " show_remote
    if [[ $show_remote == "y" || $show_remote == "Y" ]]; then
        print_info "远程分支："
        git branch -r
    fi
}

# 功能 9: 运行应用验证
run_app_validation() {
    print_step "🧪 运行应用验证"
    
    # 检查是否为 Flutter 项目
    if [ ! -f "pubspec.yaml" ]; then
        print_error "未检测到 Flutter 项目，无法运行验证。"
        return
    fi
    
    # 检查 Flutter 是否可用
    if ! command -v flutter >/dev/null 2>&1; then
        print_error "未找到 Flutter 命令。"
        return
    fi
    
    echo ""
    print_info "请选择验证方式："
    echo "1. 在 Chrome 中运行应用"
    echo "2. 分析代码"
    echo "3. 运行测试"
    echo "4. 检查依赖"
    echo "5. 返回主菜单"
    
    read -p "请输入选项 (1-5): " validation_option
    
    case $validation_option in
        1)
            print_info "在 Chrome 中运行应用..."
            flutter run -d chrome --web-port 8080
            ;;
        2)
            print_info "分析代码..."
            flutter analyze
            ;;
        3)
            print_info "运行测试..."
            flutter test
            ;;
        4)
            print_info "检查依赖..."
            flutter pub get
            flutter pub outdated
            ;;
        5)
            return
            ;;
        *)
            print_error "无效选项。"
            ;;
    esac
}

# 主程序
main() {
    # 检查是否为 Git 仓库
    check_git_repo
    
    # 检查项目目录
    check_project_dir
    
    while true; do
        main_menu
        
        read -p "请输入选项 (0-9): " choice
        
        case $choice in
            1)
                start_new_feature
                ;;
            2)
                commit_changes
                ;;
            3)
                push_to_remote
                ;;
            4)
                sync_main_branch
                ;;
            5)
                show_status
                ;;
            6)
                update_documentation
                ;;
            7)
                create_version_tag
                ;;
            8)
                cleanup_branches
                ;;
            9)
                run_app_validation
                ;;
            0)
                print_info "感谢使用 SeerX Git 工作流助手，再见！👋"
                exit 0
                ;;
            *)
                print_error "无效选项，请重新输入。"
                ;;
        esac
        
        echo ""
        read -p "按 Enter 键继续..." dummy
    done
}

# 运行主程序
main