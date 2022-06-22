#!/bin/bash
<<Json2MD
json转化为md
1. 删除开头。
2. 删除结尾。
3. 把\n定义为换行。
Json2MD
function Json2MD {
	sed -e 's/{"body":"//g' -e 's/","type_":.*//g' -e 's/\\n/\n/g' $1 > $2
}

<<JoplinMD2HexoMD
joplin的原始md文件中附加文件资源部分修改为真实文件名
（例如: [fileName.ext](:/guid) -->[fileName.ext](/resources/guid.ext)
JoplinMD2HexoMD
function JoplinMD2HexoMD {

}

<<AddFrontMatterByNoteID
AddFrontMatterByNoteID

<<GetRscForHexoMDBySCP
通过SCP提取Joplin-Desktop中的附加文件（例如*.png|*.txt|*pdf...etc）放在hexo/source/resources/里面。
*需要开启sshd，并设置好authorized_keys无密码使用scp
GetRscForHexoMDBySCP
function GetRscForHexoMDBySCP {

}

<<GetRscForHexoMDByAPI
通过API提取Joplin-Desktop中的附加文件（例如*.png|*.txt|*pdf...etc）放在hexo/source/resources/里面。
GetRscForHexoMDByAPI
function GetRscForHexoMDByAPI {

}

<<comment
如果跟我一样Hexo在别的机器上的话，需要跟我一样开启sshd，并设置好authorized_keys无密码使用scp
comment

# hexo post resources directory.
local_rsc_dir=$hexo_dir/source/resources/

echo "What is the new post file path?"
read post_path

while read LINE
do
    if [[ $LINE =~ \!?\[.*\.[0-9a-zA-Z]*\]\(:\/.*\) ]];
    then
        post_rsc_name=`echo $LINE | egrep -o ':/\w*' | cut -c3-`
        ext=`echo $LINE | egrep  -o '\.\w*\]' | sed -e 's/.$//'`
        echo $LINE | sed -e 's/](:/](\/resources/g' -e 's/\s*$//' -e "s/)$/$ext)/g"
        scp $joplin_rsc_dir$post_rsc_name$ext $local_rsc_dir > /dev/null
    else
        echo $LINE
    fi
done < ${post_path} > $hexo_dir/tmp/tmp.md
\cp -f $hexo_dir/tmp/tmp.md $post_path
