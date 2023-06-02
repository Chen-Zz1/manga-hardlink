#!/bin/bash

# 检查参数个数
if [ $# -ne 1 ]; then
  echo "Usage: $0 [-h | --help | pattern]"
  exit 1
fi

# 检查是否请求帮助
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  echo "Usage: $0 pattern"
  echo "Search the current directory for files or directories matching the pattern."
  echo "Then choose a file or directory and link it to a selected destination."
  echo "The destination is selected by choosing a comic origin (jcomics, cncomics, kcomics)"
  echo "and a comic format (普通单页, 条漫, 本子)."
  exit 0
fi

# 获取搜索字符
pattern="$1"

# 搜索当前目录下所有文件夹，找到文件名或文件夹名中包含给定字符的文件或目录
results=()
while IFS= read -r line; do
  results+=("$line")
done < <(find . -name "*$pattern*")

# 检查是否找到了匹配的文件或目录
if [ ${#results[@]} -eq 0 ]; then
  echo "No file or directory found matching the pattern: $pattern"
  exit 1
fi

# 输出所有匹配项并让用户选择一个
echo "Select a file or directory:"
select src_path in "${results[@]}"; do
  if [[ -n $src_path ]]; then
    echo "You selected: $src_path"
    break
  else
    echo "Invalid selection. Try again."
  fi
done

# 第一次选择：漫画产地类型
echo "Choose comic origin:"
echo "1. jcomics"
echo "2. cncomics"
echo "3. kcomics"
read -p "Enter choice (1, 2, or 3): " choice_origin

# 第二次选择：漫画格式类型
echo "Choose comic format:"
echo "1. 普通单页"
echo "2. 条漫"
echo "3. 本子"
read -p "Enter choice (1, 2, or 3): " choice_format

# 确定目标路径
case "$choice_origin" in
  1) dest_base_origin="jcomics" ;;
  2) dest_base_origin="cncomics" ;;
  3) dest_base_origin="kcomics" ;;
  *) echo "Invalid choice for origin. Must be 1, 2, or 3."; exit 1 ;;
esac

case "$choice_format" in
  1) dest_base_format="普通单页" ;;
  2) dest_base_format="条漫" ;;
  3) dest_base_format="本子" ;;
  *) echo "Invalid choice for format. Must be 1, 2, or 3."; exit 1 ;;
esac
# /path/to/manga 应为你选取的存放漫画硬链接的位置
dest_base="/path/to/manga/$dest_base_origin/$dest_base_format"

# 获取源路径的最后一部分，并构建目标路径
src_basename=$(basename "$src_path")
dest_path="$dest_base/$src_basename"

# 判断硬链接是否已经存在
if [ -e "$dest_path" ]; then
  echo "Hard link already exists: $dest_path"
  exit 1
fi

# 判断是文件还是目录
if [ -f "$src_path" ]; then
  # 创建文件的硬链接
  ln "$src_path" "$dest_path"
elif [ -d "$src_path" ]; then
  # 创建目标目录
  mkdir -p "$dest_path"
  # 为目录中的每个文件创建硬链接
  for file in "$src_path"/*; do
    ln "$file" "$dest_path"/
  done
else
  echo "Source path is neither a file nor a directory: $src_path"
  exit 1
fi

