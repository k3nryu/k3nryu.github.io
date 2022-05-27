#! /usr/bin/bash

# Get hexo server directory.
hexo_dir=`pwd`

# hexo post resources directory.
local_rsc_dir=$hexo_dir/source/resources/

# Get Joplin-Desktop resources directory.
echo "Where is your Joplin-Desktop resources directory? (mac or win)"
read client
case $client in
        mac)
                remote_rsc_dir=cjl@172.16.1.18:/Users/cjl/.config/joplin-desktop/resources/
                ;;
        win)
                remote_rsc_dir=cmsuser@192.168.65.191:/C:/Users/cmsuser/.config/joplin-desktop/resources/
                ;;
        *)
                echo "error"
                ;;
esac

echo "What is the new post file path?"
read post_path

while read LINE
do
    if [[ $LINE =~ \!?\[.*\.[0-9a-zA-Z]*\]\(:\/.*\) ]];
    then
        post_rsc_name=`echo $LINE | egrep -o ':/\w*' | cut -c3-`
        ext=`echo $LINE | egrep  -o '\.\w*\]' | sed -e 's/.$//'`
        echo $LINE | sed -e 's/](:/](\/resources/g' -e 's/\s*$//' -e "s/)$/$ext)/g"
        scp $remote_rsc_dir$post_rsc_name$ext $local_rsc_dir > /dev/null
    else
        echo $LINE
    fi
done < ${post_path} > /tmp/tmp.md
\cp -f /tmp/tmp.md $post_path

# 匹配md文件里的添加文件部分
#egrep -o '\!?\[.*\.\w*\]\(:\/.*\)' test.md
# 匹配md文件里的添加文件部分                把':'改为'/resources'
#egrep -o '\!?\[.*\.\w*\]\(:\/.*\)' test.md | sed -e 's/\:/\/resources/'
# 匹配md文件里的添加文件部分                把':'改为'/resources' 把最后面的)删除了
#egrep -o '\!?\[.*\.\w*\]\(:\/.*\)' test.md | sed -e 's/\:/\/resources/;s/)$//'
# 匹配md文件里的添加文件部分                把':'改为'/resources'     提取.txt]文件后缀    删除文件后缀]
#egrep -o '\!?\[.*\.\w*\]\(:\/.*\)' test.md | sed -e 's/\:/\/resources/' | egrep -o '\.\w*\]' | sed -e 's/\]//g'
