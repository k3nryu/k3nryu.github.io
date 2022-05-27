#! /bin/bash

# Clean 'public' folder
hexo clean 

# Generate i18n 'public' folder
for lang in en zh ja
do
	ln -sf i18n/hexo_config_$lang.yml _config.yml
	ln -sf ../../i18n/pure_config_$lang.yml themes/pure/_config.yml
	hexo g 
	if [ $lang == en ]
	then
		mv public public_en
	else
		mv public public_en/$lang
	fi
done
mv public_en public

# Reset config file for 'hexo s'
ln -sf i18n/hexo_config_en.yml _config.yml
ln -sf ../../i18n/pure_config_en.yml themes/pure/_config.yml
