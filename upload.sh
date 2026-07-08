#!/bin/bash
# 批量上传图片到图床 (GitHub + jsDelivr CDN)
# 用法: ./upload.sh image1.png image2.jpg "path/to/*.png"
# 返回 CDN 链接列表

CDN_BASE="https://cdn.jsdelivr.net/gh/yinchuxiong/cx-images@master"
REPO_DIR="$HOME/anzhiyu-images"
YEAR=$(date +%Y)

# 确保在仓库目录
cd "$REPO_DIR" || exit 1

# 创建年份目录
mkdir -p "$YEAR"

UPLOADED=()

for file in "$@"; do
    # 支持通配符展开
    if [ ! -f "$file" ]; then
        echo "[SKIP] 文件不存在: $file"
        continue
    fi

    filename=$(basename "$file")
    dest="$YEAR/$filename"

    # 时间戳去重: 同名文件加后缀
    if [ -f "$dest" ]; then
        base="${filename%.*}"
        ext="${filename##*.}"
        timestamp=$(date +%H%M%S)
        filename="${base}_${timestamp}.${ext}"
        dest="$YEAR/$filename"
    fi

    cp "$file" "$dest"
    echo "[OK] $file → $dest"
    UPLOADED+=("$dest")
done

if [ ${#UPLOADED[@]} -eq 0 ]; then
    echo "没有新文件需要上传"
    exit 0
fi

# 提交并推送
git add "${UPLOADED[@]}"
git commit -m "Upload ${#UPLOADED[@]} image(s): $(date '+%Y-%m-%d %H:%M:%S')"
git push

echo ""
echo "===== CDN 链接 (共 ${#UPLOADED[@]} 张) ====="
for img in "${UPLOADED[@]}"; do
    echo "$CDN_BASE/$img"
done
