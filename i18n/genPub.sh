#! /bin/bash

# Get hexo server directory.
hexo_dir=`realpath $(dirname $0) | sed -e 's/\/[0-9a-zA-Z]*$//'`

cd $hexo_dir/

# Clean 'public' folder
hexo clean 

# Generate i18n 'public' folder
for lang in en zh ja
do
	ln -sf i18n/hexo_config_$lang.yml _config.yml
	ln -sf ../../i18n/pure_config_$lang.yml themes/pure/_config.yml
	ln -sf ../../i18n/about_$lang.md source/about/index.md
	hexo g 
	if [ $lang == en ];
	then
		mv $hexo_dir/public $hexo_dir/public_en
	else
		mv $hexo_dir/public $hexo_dir/public_en/$lang
	fi
done
mv public_en public

# Reset config file for 'hexo s'
ln -sf i18n/hexo_config_en.yml _config.yml
ln -sf ../../i18n/pure_config_en.yml themes/pure/_config.yml
ln -sf ../../i18n/about_en.md source/about/index.md
