#! /bin/bash

joplin_srv_ip=localhost
joplin_srv_port=41184
note_id=fa648cf2a039497da5eee0b61d454892
joplin_token=b03f620aac099e9c9ca929eccc95f361ea6de8db4275ddde31214dfef346d8adefc95ff25bccec8633d291fd558c4fade067ee6b807eb389f38d284ed06dc9e5

# --- Useful ---
# Get note body(json format) by note id.
curl http://$joplin_srv_ip:$joplin_srv_port/notes/$note_id?token=$joplin_token\&fields=body


# --- tested  ---
# Testing if the service is available
#curl http://$joplin_srv_ip:$joplin_srv_port/ping

# Testing the token whether avalible
#curl http://$joplin_srv_ip:$joplin_srv_port/auth/check/\?token\=$joplin_token

# Gets all notes
#curl http://$joplin_srv_ip:$joplin_srv_port/notes/\?token\=$joplin_token

# Gets note with ID :id
#curl http://$joplin_srv_ip:$joplin_srv_port/notes/$note_id/\?token\=$joplin_token

# Gets all the tags attached to this note.
#curl http://$joplin_srv_ip:$joplin_srv_port/notes/$note_id/tags/\?token\=$joplin_token

# Gets all the resources attached to this note.
#curl http://$joplin_srv_ip:$joplin_srv_port/notes/$note_id/resources/\?token\=$joplin_token

# Gets the IDs only of all the tags:
#curl http://$joplin_srv_ip:$joplin_srv_port/tags/?fields=id\&token=$joplin_token

# Get token 
#curl -XPOST http://$joplin_srv_ip:$joplin_srv_port/auth
#curl  http://$joplin_srv_ip:$joplin_srv_port/auth/check?auth_token=AUTH_TOKEN

# Get the note's location by note id
#curl http://$joplin_srv_ip:$joplin_srv_port/notes/$note_id?fields=longitude,latitude\&token=$joplin_token

#echo http://$joplin_srv_ip:$joplin_srv_port/tags?token=$joplin_token

#curl http://$joplin_srv_ip:$joplin_srv_port/notes/"$note_id?fields"=longitude,latitude?"token"=$joplin_token
#curl http://$joplin_srv_ip:$joplin_srv_port/tags?fields=id&token=$joplin_token
#curl http://$joplin_srv_ip:$joplin_srv_port/notes/$note_id?"token"=$joplin_token

