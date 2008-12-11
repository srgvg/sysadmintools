#!/bin/sh

src_host="hades2"
src_dir="/mnt/disk2/ScratchDTP/jpg/"
dst_dir="/mnt/rootusa/Resources/Departments/Shared Files/Pictures/Products/"
prod_list="vi_data.txt"

rm "$dst_dir/$prod_list"
rsync "$src_host:$src_dir/$prod_list" "$dst_dir" || (echo error retrieving product list; exit)

sed -i s@^@"+ "@ "$dst_dir/$prod_list"
echo "+ */" >> "$dst_dir/$prod_list"
echo "- *" >> "$dst_dir/$prod_list"

rsync -az --delete --delete-excluded --exclude-from="$dst_dir/$prod_list" "$src_host:$src_dir/" "$dst_dir" 

