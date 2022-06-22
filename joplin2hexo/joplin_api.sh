#! /bin/bash

# Get hexo server directory.
hexo_dir=..
mkdir -p $hexo_dir/tmp $hexo_dir/source/resources

# hexo post resources directory.
local_rsc_dir=$hexo_dir/source/resources/

if [[ -e "./joplin_user_profile.sh" ]];then
        source ./joplin_user_profile.sh
        echo -e "User profile successfully obtained!"
else
        echo -e "User profile[./joplin_user_profile.sh] not found,\nPlease enter your Joplin server user name:"
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
echo joplin_srv_port=$joplin_srv_port
echo joplin_srv_token=$joplin_srv_token
echo joplin_rsc_dir=$joplin_rsc_dir
echo -e 'EOF\n'

# JoplinClipperServer Connection
ssh -fNL $joplin_srv_port:127.0.0.1:$joplin_srv_port $joplin_srv_user@$joplin_srv_ip


# JoplinClipperServer Connection Check
#curl -o $hexo_dir/tmp/ping.json http://$joplin_srv_ip:$joplin_srv_port/auth/check/\?token\=$joplin_srv_token
curl -o $hexo_dir/tmp/ping.json http://localhost:$joplin_srv_port/ping > $hexo_dir/tmp/ping.json

if [ `cat $hexo_dir/tmp/ping.json` == "JoplinClipperServer" ];then
	echo Connected to the JoplinClipperServer successfully!
	echo 
else
	echo Connection to the JoplinClipperServer failed!
	echo 
	exit
fi

echo -e "Please enter note ID:"
#read note_id
note_id=b76691e5a8f14c919360b5ed69b1c0c1
echo $note_id

# --- Useful ---
# Get note body(json format) by note id.
curl -o $hexo_dir/tmp/Goted_Note_body_tmp.json -X GET http://localhost:$joplin_srv_port/notes/$note_id?token=$joplin_srv_token\&fields=body

echo cat $hexo_dir/tmp/Goted_Note_body_tmp.json
cat $hexo_dir/tmp/Goted_Note_body_tmp.json
echo

# Get note attached resources id;title;
curl -o $hexo_dir/tmp/Goted_Note_resources_tmp.json -X GET http://localhost:$joplin_srv_port/notes/$note_id/resources/?token=$joplin_srv_token

echo cat $hexo_dir/tmp/Goted_Note_resources_tmp.json
cat $hexo_dir/tmp/Goted_Note_resources_tmp.json
echo

curl -o $hexo_dir/tmp/192.168.64.130.png -X GET http://localhost:$joplin_srv_port/resources/18eeac093c384a13b0d3b849e41a6292/file?token=$joplin_srv_token

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

