#! /bin/bash

nvm install 16
npm install -g hexo-cli
npm install -g npm-check npm-upgrade
npm install hexo-deployer-git --save
npm install hexo-wordcount --save
npm install hexo-generator-json-content --save
npm install hexo-generator-feed --save
npm install hexo-generator-sitemap --save
#npm install hexo-generator-baidu-sitemap --save

rm -rf node_modules && npm install --force
npm audit fix
