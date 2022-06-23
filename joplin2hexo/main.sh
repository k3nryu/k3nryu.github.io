#! /bin/bash

<<flowchat
读取用户配置
连接API服务器
询问Note ID
Joplin API
	获取Note Body (JSON file)
	获取Note Title (JSON file)
	获取Note Create Data (JSON file)
	获取Note Note Book (JSON file)
	获取Note Tag (JSON file)
转换Note Body (JSON file) --> Note Body (MarkDown File)
修正Note Body (MarkDown File) --> Hexo Note Body (Markdown File)
添加Front Matter
	读取Note Title (JSON file) >> Note Body (MarkDown File Front Matter YAML)
	读取Note Create Data (JSON file) >> Note Body (MarkDown File Front Matter YAML)
	读取Note Note Book (JSON file) >> Note Body (MarkDown File Front Matter YAML)
	读取Note Tag (JSON file) >> Note Body (MarkDown File Front Matter YAML)
	读取Note Create Data (JSON file) >> Note Body (MarkDown File)
获取Note Attachment 储存到 /hexo/source/resources/
展示
flowchat

# Get hexo server directory.
hexo_dir=~/k3nryu.github.io
hexo_post_dir=$hexo_dir/source/_posts
hexo_rsc_dir=$hexo_dir/source/resources
note_body_json=$hexo_dir/tmp/Goted_Note_body_tmp.json
note_title_json=$hexo_dir/tmp/Goted_Note_title_tmp.json
note_date_json=$hexo_dir/tmp/Goted_Note_date_tmp.json
note_tag_json=$hexo_dir/tmp/Goted_Note_tag_tmp.json
note_cat_json=$hexo_dir/tmp/Goted_Note_cat_tmp.json
note_body_md=$hexo_dir/tmp/Goted_Note_body_tmp.md
joplin_user_profile=$hexo_dir/joplin2hexo/joplin_user_profile.sh
# hexo post resources directory.
local_rsc_dir=$hexo_dir/source/resources/

# Import functions
source $hexo_dir/joplin2hexo/functions.sh

# Make directories
mkdir -p $hexo_dir/tmp $hexo_dir/source/resources


# Read user profile for connect JoplinClipperServer 
ReadConfig $joplin_user_profile

# JoplinClipperServer Connection
ssh -fNL $joplin_srv_port:127.0.0.1:$joplin_srv_port $joplin_srv_user@$joplin_srv_ip

# JoplinClipperServer Connection Check
echo JoplinClipperServer Connection Check:
curl -so $hexo_dir/tmp/ping.json http://localhost:$joplin_srv_port/ping > $hexo_dir/tmp/ping.json
if [ `cat $hexo_dir/tmp/ping.json` == 'JoplinClipperServer' ];then
	echo Connected successfully!
	echo 
else
	echo Connection failed!
	echo 
	exit
fi

# JoplinClipperServer Authorisation Check
echo JoplinClipperServer Authorisation Check:
curl -so $hexo_dir/tmp/auth.json http://localhost:$joplin_srv_port/auth/check/\?token\=$joplin_srv_token
if [ `cat $hexo_dir/tmp/auth.json` == '{"valid":true}' ];then
	echo Token is valid!
	echo 
else
	echo Token is invalid!
	echo 
	exit
fi

echo -e "Please enter note ID:"
read note_id
#note_id=b76691e5a8f14c919360b5ed69b1c0c1
echo note_id=$note_id

# Get note body(json format) by note id.
GetNoteBody $note_body_json $note_id
GetNoteTitle $note_title_json $note_id
GetNoteDate $note_date_json $note_id
GetNoteTag $note_tag_json $note_id
GetNoteCat $note_cat_json $note_id

Json2MD $note_body_json $note_body_md

