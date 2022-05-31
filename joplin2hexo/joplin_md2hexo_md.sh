#! /usr/bin/bash

# 可以提取Joplin-Desktop中的附加文件（例如*.png|*.txt|*pdf...etc）放在hexo/source/resources/里面。
# 自动把Markdown文件中的[fileName.ext](:/guid)转换为为[fileName.ext](/resources/guid.ext)
# 如果跟我一样Hexo在别的机器上的话，需要跟我一样开启sshd，并设置好authorized_keys无密码使用scp


# Get hexo server directory.
hexo_dir=`pwd`
mkdir -p $hexo_dir/tmp $hexo_dir/source/resources

# hexo post resources directory.
local_rsc_dir=$hexo_dir/source/resources/

if [[ -e "$hexo_dir/joplin_user_profile.sh" ]];then
        source $hexo_dir/joplin_user_profile.sh
        echo -e "User profile successfully obtained!"
else
        echo -e "User profile[./.user_profile.sh] not found,\nPlease enter your Joplin server user name:"
	read joplin_srv_user
        echo -e "Please enter your Joplin server IP:"
	read joplin_srv_ip
        echo -e "Please enter your Joplin server token:"
	read joplin_srv_token
        echo -e "Please enter your Joplin server OS(mac or win):"
	read joplin_os
	if [[ $joplin_os == win ]];then
                joplin_rsc_dir=$joplin_srv_user@$joplin_srv_ip:/C:/Users/$joplin_srv_user/.config/joplin-desktop/resources/
	elif [[ $joplin_os == mac ]];then	
		joplin_rsc_dir=$joplin_srv_user@$joplin_srv_ip:/Users/$joplin_srv_user/.config/joplin-desktop/resources/
	else
		echo - "Input error!"
	fi

fi

echo -e 'The following parameters were read:\n'
echo '<<<EOF'
echo hexo_dir=`pwd`
echo joplin_srv_user=$joplin_srv_user
echo joplin_srv_ip=$joplin_srv_ip
echo joplin_srv_token=$joplin_srv_token
echo joplin_rsc_dir=$joplin_rsc_dir
echo -e 'EOF\n'


# Get posts markdown file by Joplin-API
## Connetc 
#joplin_srv_port=41184
#ssh -fCNL $joplin_srv_port:localhost:$joplin_srv_port $joplin_srv_user@$joplin_srv_ip

# Get the post's attached file from joplin server and modify markdown text to apply attached file.
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

# 匹配md文件里的添加文件部分
#egrep -o '\!?\[.*\.\w*\]\(:\/.*\)' test.md
# 匹配md文件里的添加文件部分                把':'改为'/resources'
#egrep -o '\!?\[.*\.\w*\]\(:\/.*\)' test.md | sed -e 's/\:/\/resources/'
# 匹配md文件里的添加文件部分                把':'改为'/resources' 把最后面的)删除了
#egrep -o '\!?\[.*\.\w*\]\(:\/.*\)' test.md | sed -e 's/\:/\/resources/;s/)$//'
# 匹配md文件里的添加文件部分                把':'改为'/resources'     提取.txt]文件后缀    删除文件后缀]
#egrep -o '\!?\[.*\.\w*\]\(:\/.*\)' test.md | sed -e 's/\:/\/resources/' | egrep -o '\.\w*\]' | sed -e 's/\]//g'
