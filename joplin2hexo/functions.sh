#!/bin/bash

function ReadConfig {
<<ReadConfig
ReadConfig
	if [[ -e "$1" ]];then
	        source $1
		echo -e 'The following parameters were successfully obtained:'
		echo hexo_dir=$hexo_dir
		echo joplin_srv_user=$joplin_srv_user
		echo joplin_srv_ip=$joplin_srv_ip
		echo joplin_srv_port=$joplin_srv_port
		echo joplin_srv_token=$joplin_srv_token
		echo joplin_rsc_dir=$joplin_rsc_dir
		echo ---
	else
	        echo -e "User profile[$1] not found,\nPlease enter your Joplin server user name:"
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
		echo '#!bin/bash' >> $1
		echo hexo_dir=$hexo_dir >> $1
		echo joplin_srv_user=$joplin_srv_user >> $1
		echo joplin_srv_ip=$joplin_srv_ip >> $1
		echo joplin_srv_port=$joplin_srv_port >> $1
		echo joplin_srv_token=$joplin_srv_token >> $1
		echo joplin_rsc_dir=$joplin_rsc_dir >> $1
	fi
}

function GetNoteBody {
<<GetNoteBody
Get note body(json format) by note id.
GetNoteBody
	curl -so $1 -X GET http://localhost:$joplin_srv_port/notes/$2?token=$joplin_srv_token\&fields=body
}

function GetNoteTitle {
<<GetNoteTitle
Get note title(json format) by note id.
GetNoteTitle
	curl -so $1 -X GET http://localhost:$joplin_srv_port/notes/$2?token=$joplin_srv_token\&fields=title
}

function GetNoteDate {
<<GetNoteDate
Get note created date(json format) by note id.
GetNoteDate
	curl -so $1 -X GET http://localhost:$joplin_srv_port/notes/$2?token=$joplin_srv_token\&fields=created_time
}

function GetNoteTag {
<<GetNoteTag
Get note tags(json format) by note id.
GetNoteTag
#curl -so $1 -X GET http://localhost:$joplin_srv_port/notes/$2?token=$joplin_srv_token\&fields=tag
	curl -so $1 -X GET http://localhost:$joplin_srv_port/notes/$2/tags/\?token\=$joplin_srv_token
}

function GetNoteCat {
<<GetNoteCat
Get note categories(json format) by note id.
GetNoteCat
	# get category id by note id
	echo 'get category id by note id by API:' > $1
	curl -s -X GET http://localhost:$joplin_srv_port/notes/$2?token=$joplin_srv_token\&fields=parent_id >> $1
	# edit json file
	echo >> $1
	echo >> $1
	echo "i.e." >> $1
	folder_id=`egrep "\{\"parent_id\"\:\""  $1 | sed -e 's/{"parent_id":"//g' -e 's/","type_":1}//g'` 
	echo $folder_id >> $1
	echo >> $1
	# get category information by category id
	echo 'get category information by category id by API:' >> $1
	curl -s -X GET http://localhost:$joplin_srv_port/folders/$folder_id?token=$joplin_srv_token >> $1
	echo >> $1
	# edit json file
	# get parent category id
	# edit json file

}

function Json2MD {
<<Json2MD
json转化为md
1. 删除开头。
2. 删除结尾。
3. 把\n定义为换行。
Json2MD

	sed -e 's/{"body":"//g' -e 's/","type_":.*//g' -e 's/\\n/\n/g' $1 > $2
}
function JoplinMD2HexoMD {
<<JoplinMD2HexoMD
joplin的原始md文件中附加文件资源部分修改为真实文件名
（例如: [fileName.ext](:/guid) -->[fileName.ext](/resources/guid.ext)
JoplinMD2HexoMD

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
}

<<AddFrontMatterByNoteID
AddFrontMatterByNoteID

function GetRscForHexoMDBySCP {
<<GetRscForHexoMDBySCP
通过SCP提取Joplin-Desktop中的附加文件（例如*.png|*.txt|*pdf...etc）放在hexo/source/resources/里面。
*需要开启sshd，并设置好authorized_keys无密码使用scp
GetRscForHexoMDBySCP

}

function GetRscForHexoMDByAPI {
<<GetRscForHexoMDByAPI
通过API提取Joplin-Desktop中的附加文件（例如*.png|*.txt|*pdf...etc）放在hexo/source/resources/里面。
GetRscForHexoMDByAPI

}


# --- Useful ---
#cat $hexo_dir/tmp/Goted_Note_body_tmp.json
# Get note attached resources id;title;
#curl -so $hexo_dir/tmp/Goted_Note_resources_tmp.json -X GET http://localhost:$joplin_srv_port/notes/$note_id/resources/?token=$joplin_srv_token

#cat $hexo_dir/tmp/Goted_Note_resources_tmp.json

#curl -so $hexo_dir/tmp/192.168.64.130.png -X GET http://localhost:$joplin_srv_port/resources/18eeac093c384a13b0d3b849e41a6292/file?token=$joplin_srv_token
# --- tested  ---
# Testing if the service is available
#curl http://$joplin_srv_ip:$joplin_srv_port/ping

# Testing the token whether avalible
#curl http://$joplin_srv_ip:$joplin_srv_port/auth/check/\?token\=$joplin_srv_token

# Gets all notes
#curl http://$joplin_srv_ip:$joplin_srv_port/notes/\?token\=$joplin_srv_token

# Gets note with ID :id
#curl http://$joplin_srv_ip:$joplin_srv_port/notes/$note_id/\?token\=$joplin_srv_token

# Gets all the tags attached to this note.
#curl http://$joplin_srv_ip:$joplin_srv_port/notes/$note_id/tags/\?token\=$joplin_srv_token


# Gets the IDs only of all the tags:
#curl http://$joplin_srv_ip:$joplin_srv_port/tags/?fields=id\&token=$joplin_srv_token

# Get token 
#curl -XPOST http://$joplin_srv_ip:$joplin_srv_port/auth
#curl  http://$joplin_srv_ip:$joplin_srv_port/auth/check?auth_token=AUTH_TOKEN

# Get the note's location by note id
#curl http://$joplin_srv_ip:$joplin_srv_port/notes/$note_id?fields=longitude,latitude\&token=$joplin_srv_token

#echo http://$joplin_srv_ip:$joplin_srv_port/tags?token=$joplin_srv_token

#curl http://$joplin_srv_ip:$joplin_srv_port/notes/"$note_id?fields"=longitude,latitude?"token"=$joplin_srv_token
#curl http://$joplin_srv_ip:$joplin_srv_port/tags?fields=id&token=$joplin_srv_token
#curl http://$joplin_srv_ip:$joplin_srv_port/notes/$note_id?"token"=$joplin_srv_token

# Unix Time to local time
#date +'%Y/%m/%d %H:%M:%S' -d "@1653542376"
