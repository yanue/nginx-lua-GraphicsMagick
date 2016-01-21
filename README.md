# nginx-lua-GraphicsMagick
Nginx+Lua+GraphicsMagick，实现自定义图片尺寸功能，支持两种模式[固定高宽模式,定高或定宽模式]，支持FastDFS文件存储

  github地址:[https://github.com/yanue/nginx-lua-GraphicsMagick](https://github.com/yanue/nginx-lua-GraphicsMagick)

## 说明
- 类似淘宝图片，实现自定义图片尺寸功能，可根据图片加后缀_100x100.jpg(固定高宽),_-100.jpg(定高),_100-.jpg(定宽)形式实现自定义输出图片大小。
- 主要将自定义尺寸的图片放在完全独立的thumb目录（自定义目录）,并保持原有的图片目录结构。

## 2016-01-14更新说明
- 新增定高或定宽裁切模式
  左右结构,用"-"号区分未知高或未知宽("-"号不会被浏览器url转义),如
  如: xx.jpg_100-.jpg 宽100,高自动
  如: xx.jpg_-100.jpg 高100,宽自动
- 新增 php 动态获取图片尺寸的类文件

#### 文件夹规划
```bash
img.xxx.com(如/var/www/img)
|-- img1
|   `-- 001
|       `-- 001.jpg
|-- img2
|   `-- notfound.jpg
|-- img3
|   `-- 001
|       `-- 001.jpg
```
#### 自定义尺寸后的路径
```bash
thumb（如/tmp/thumb,可在conf文件里面更改）
    `-- img1
        `-- 001
            |-- 001_200x160.jpg 固定高和宽
            |-- 001_-100.jpg 定高
            |-- 001_200-.jpg 定宽
```
- 其中img.xxx.com为图片站点根目录，img1,img2...目录是原图目录
- 缩略图目录根据保持原有结构，并单独设置目录，可定时清理。

#### 链接地址对应关系
* 原图访问地址：```http://img.xxx.com/xx/001/001.jpg```
* 缩略图访问地址：```http://img.xxx.com/xx/001/001.jpg_100x100.jpg``` 即为宽100,高100
* 自动宽地址: ```http://img.xxx.com/xx/001/001.jpg_-100.jpg``` 用"-"表示自动,即为高100,宽自动
* 自动高地址: ```http://img.xxx.com/xx/001/001.jpg_100-.jpg``` 用"-"表示自动,即为宽100,高自动

#### 访问流程
* 首先判断缩略图是否存在，如存在则直接显示缩略图；
* 缩略图不存在,则判断原图是否存在，如原图存在则拼接graphicsmagick(gm)命令,生成并显示缩略图,否则返回404

## 安装
CentOS6 安装过程见 [nginx+lua+GraphicsMagick安装](nginx-install.md)

## 配置

### 依赖
* Nginx
```bash
./configure --prefix=/usr/local/nginx \
--user=www \
--group=www \
--sbin-path=/usr/sbin/nginx \
--conf-path=/etc/nginx/nginx.conf \
--pid-path=/var/run/nginx.pid  \
--lock-path=/var/run/nginx.lock \
--error-log-path=/opt/logs/nginx/error.log \
--http-log-path=/opt/logs/nginx/access.log \
--with-http_ssl_module \
--with-http_realip_module \
--with-http_sub_module \
--with-http_flv_module \
--with-http_dav_module \
--with-http_gzip_static_module \
--with-http_stub_status_module \
--with-http_addition_module \
--with-http_spdy_module \
--with-pcre \
--with-zlib=../zlib-1.2.8 \
--add-module=../nginx-http-concat \
--add-module=../lua-nginx-module \
--add-module=../ngx_devel_kit \
```
* GraphicsMagick(1.3.18)
  * libjpeg
  * libpng
  * inotify(可选)

### 配置文件说明
##### nginx 配置文件 /etc/nginx
##### vhost 为站点配置
-  [demo.conf](vhost/demo.conf) 为 普通站点 配置文件,包含固定高宽和定高,定宽两种模式配置
-  [fdfs.conf](vhost/fdfs.conf) 为 fastdfs 配置文件,包含固定高宽和定高,定宽两种模式配置
##### lua 为裁切图片处理目录
-  [autoSize.lua](lua/autoSize.lua) 定高或定宽模式裁切图片处理lua脚本
-  [cropSize.lua](lua/cropSize.lua) 固定高宽模式裁切图片处理lua脚本
  
#### nginx vhost demo配置
```bash
server{
    listen  80
    
    # set var for thumb pic
    set $upload_path /opt/uploads;
    set $img_original_root  $upload_path;# original root;
    set $img_thumbnail_root $upload_path/cache/thumb;
    set $img_file $img_thumbnail_root$uri;

    # like：/xx/xx/xx.jpg_100-.jpg or /xx/xx/xx.jpg_-100.jpg
    location ~* ^(.+\.(jpg|jpeg|gif|png))_((\d+\-)|(\-\d+))\.(jpg|jpeg|gif|png)$ {
            root $img_thumbnail_root;    # root path for croped img
            set $img_size $3;

            if (!-f $img_file) {    # if file not exists
                    add_header X-Powered-By 'Nginx+Lua+GraphicsMagick By Yanue';  #  header for test
                    add_header file-path $request_filename;    #  header for test
                    set $request_filepath $img_original_root$1;    # origin_img full path：/document_root/1.gif
                    set $img_size $3;    # img width or height size depends on uri
                    set $img_ext $2;    # file ext
                    content_by_lua_file /etc/nginx/lua/autoSize.lua;    # load lua
            }
    }

    # like: /xx/xx/xx.jpg_100x100.jpg
    location ~* ^(.+\.(jpg|jpeg|gif|png))_(\d+)+x(\d+)+\.(jpg|jpeg|gif|png)$ {
            root $img_thumbnail_root;    # root path for croped img

            if (!-f $img_file) {    # if file not exists
                    add_header X-Powered-By 'Nginx+Lua+GraphicsMagick By Yanue';  #  header for test
                    add_header file-path $request_filename;    #  header for test
                    set $request_filepath $img_original_root$1;    # origin_img file path
                    set $img_width $3;    # img width
                    set $img_height $4;    # height
                    set $img_ext $5;    # file ext
                    content_by_lua_file /etc/nginx/lua/cropSize.lua;    # load lua
            }
    }
    
    location = /favicon.ico {
                log_not_found off;
                access_log off;
    }
}
```

#### nginx fastdfs配置
```bash
server{
    listen      80;
    server_name xxx.com;
    
    set $img_thumbnail_root /opt/fastdfs/thumb; #set thumb path
    set $img_file $img_thumbnail_root$uri;   #thumb file

    # like：/pic/M00/xx/xx/xx.jpg_100-.jpg or /pic/M00/xx/xx/xx.jpg_-100.jpg
    location ~* ^(\/(\w+)(\/M00)(.+\.(jpg|jpeg|gif|png)))_((\d+\-)|(\-\d+))\.(jpg|jpeg|gif|png)$ {
            root $img_thumbnail_root;    # root path for croped img
            set $fdfs_group_root /opt/fastdfs/$2/store0/data; #set fastdfs group path $2

            if (!-f $img_file) {    # if thumb file not exists
                    add_header X-Powered-By 'Nginx+Lua+GraphicsMagick By Yanue';  #  header for test
                    add_header file-path $request_filename;    #  header for test
                    set $request_filepath $fdfs_group_root$4;    # origin_img full path：/document_root/1.gif
                    set $img_size $6;    # img width or height size depends on uri : img size like "-100" or "100-", "-" means auto size
                    set $img_ext $5;    # file ext
                    content_by_lua_file /etc/nginx/lua/autoSize.lua;    # load auto width or height crop Lua file
            }
    }

    # like：/pic/M00/xx/xx/xx.jpg_200x100.jpg
    location ~* ^(\/(\w+)(\/M00)(.+\.(jpg|jpeg|gif|png))_(\d+)+x(\d+)+\.(jpg|jpeg|gif|png))$ {
            root $img_thumbnail_root;    # root path for croped img
            set $fdfs_group_root /opt/fastdfs/$2/store0/data; #set fastdfs group path $2

            if (!-f $img_file) {   # if thumb file not exists
                    add_header X-Powered-By 'Nginx+Lua+GraphicsMagick By Yanue';  #  header for test
                    add_header file-path $request_filename;    #  header for test
                    set $request_filepath $fdfs_group_root$4;    # real file path
                    set $img_width $6;    #  img width
                    set $img_height $7;    #  img height
                    set $img_ext $5;     # file ext
                    content_by_lua_file /etc/nginx/lua/cropSize.lua;    # load crop Lua file
            }
    }

    location /pic/M00 {
            alias /opt/fastdfs/pic/store0/data;
            ngx_fastdfs_module;
    }

    location /chat/M00 {
            alias /opt/fastdfs/chat/store0/data;
            ngx_fastdfs_module;
    }

    location = /favicon.ico {
            log_not_found off;
            access_log off;
    }
}
```
### 最后说明
- lua 脚本处理并未做任何图片尺寸限制,这样很容易被恶意改变宽和高参数而随意生成大量文件,浪费资源和空间,请根据直接情况自行处理

参考:https://github.com/hopesoft/nginx-lua-image-module
