# ========================================
# SeerX 项目别名
# ========================================

# Git 工作流助手别名
alias seerx-git='cd /Users/xiaomingshi/Desktop/flutter_projects/my_prediction_app && ./scripts/git-workflow.sh'

# 快速进入项目目录
alias seerx='cd /Users/xiaomingshi/Desktop/flutter_projects/my_prediction_app'

# 运行 SeerX 应用
alias seerx-run='cd /Users/xiaomingshi/Desktop/flutter_projects/my_prediction_app && flutter run -d chrome --web-port 8080'


# ============ 代理相关配置 ============

# 开启终端代理（SOCKS5）
alias proxy='export all_proxy=socks5://127.0.0.1:10808'
# 关闭终端代理
alias unproxy='unset all_proxy'
# 查看当前代理状态
alias proxy-status='echo "当前代理: $all_proxy"'

# Git 代理开关
alias gitproxy='git config --global http.https://github.com.proxy socks5://127.0.0.1:10808 && echo "✅ Git代理已开启（仅GitHub）"'
alias gitnoproxy='git config --global --unset http.https://github.com.proxy && git config --global --unset https.https://github.com.proxy && echo "✅ Git代理已关闭"'
alias gitproxy-status='git config --global http.https://github.com.proxy && echo "🔵 Git代理已设置" || echo "⚪ Git代理未设置"'

# 测试网络连接
alias myip='curl ipinfo.io'


