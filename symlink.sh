#! /bin/bash

#ln -s ../ja/public public/ja
#ln -s ../zh/public public/zh

hexo clean 

ln -sf i18n/hexo_config_en.yml _config.yml
ln -sf ../../i18n/pure_config_en.yml themes/pure/_config.yml
hexo g 
mv public public_en

ln -sf i18n/hexo_config_zh.yml _config.yml
ln -sf ../../i18n/pure_config_zh.yml themes/pure/_config.yml
hexo g
mv public public_en/zh

ln -sf i18n/hexo_config_ja.yml _config.yml
ln -sf ../../i18n/pure_config_ja.yml themes/pure/_config.yml
hexo g
mv public public_en/ja

mv public_en public

ln -sf i18n/hexo_config_en.yml _config.yml
ln -sf ../../i18n/pure_config_en.yml themes/pure/_config.yml
