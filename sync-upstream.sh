#!/usr/bin/env bash
#
# 一键同步官网(deepseek-ai/deepseek-harness)最新代码到自己的 fork (origin)
# 用法: ./sync-upstream.sh [分支名]   默认分支 master
#
set -euo pipefail

# ===== 可配置项(可用环境变量覆盖) =====
UPSTREAM_REMOTE="${UPSTREAM_REMOTE:-upstream}"
UPSTREAM_BRANCH="${UPSTREAM_BRANCH:-master}"
ORIGIN_REMOTE="${ORIGIN_REMOTE:-origin}"
# =====================================

BRANCH="${1:-$UPSTREAM_BRANCH}"

echo "==> [1/4] 校验 remotes ..."
if ! git remote get-url "$UPSTREAM_REMOTE" >/dev/null 2>&1; then
    echo "错误: 未找到 remote '$UPSTREAM_REMOTE'，请先执行:"
    echo "  git remote add upstream git@github.com:deepseek-ai/deepseek-harness.git"
    exit 1
fi

echo "==> [2/4] 拉取官方最新代码 (fetch $UPSTREAM_REMOTE) ..."
git fetch "$UPSTREAM_REMOTE" --prune

echo "==> [3/4] 切换到分支 $BRANCH 并合并 $UPSTREAM_REMOTE/$UPSTREAM_BRANCH ..."
CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
if [ "$CURRENT_BRANCH" != "$BRANCH" ]; then
    git stash --include-untracked -q || true
    git checkout "$BRANCH"
fi
if ! git merge --ff-only "$UPSTREAM_REMOTE/$UPSTREAM_BRANCH"; then
    git merge "$UPSTREAM_REMOTE/$UPSTREAM_BRANCH" -m "Merge upstream $UPSTREAM_BRANCH into $BRANCH"
fi

echo "==> [4/4] 推送到你的 fork ($ORIGIN_REMOTE/$BRANCH) ..."
git push "$ORIGIN_REMOTE" "$BRANCH"

echo "✅ 同步完成: $UPSTREAM_REMOTE/$UPSTREAM_BRANCH -> $BRANCH -> $ORIGIN_REMOTE/$BRANCH"
