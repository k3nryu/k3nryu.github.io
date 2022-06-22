#!/bin/bash

<<comment
json转化为md
1. 删除开头。
2. 删除结尾。
3. 把\n定义为换行。
comment

sed -e 's/{"body":"//g' -e 's/","type_":.*//g' -e 's/\\n/\n/g' Goted_Note_body_tmp.json > Converted_Note_body_tmp.md
