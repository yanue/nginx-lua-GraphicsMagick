# nginx-lua-GraphicsMagick
Nginx+Lua+GraphicsMagick，实现自定义图片尺寸功能，支持FastDFS文件存储

## 说明
类似淘宝图片，实现自定义图片尺寸功能，可根据图片加后缀_100x100.jpg形式实现自定义输出图片大小。
主要将自定义尺寸的图片放在完全独立的thumb目录（自定义目录）,并保持原有的图片目录结构。

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
            |-- 001_100x100.jpg
            |-- 001_200x160.jpg
```
其中img.xxx.com为图片站点根目录，img1,img2...目录是原图目录，可根据目录设置不同的缩略图尺寸，thumb文件夹用来存放缩略图，可定时清理。

#### 链接地址对应关系
* 原图访问地址：```http://img.xxx.com/xx/001/001.jpg```
* 缩略图访问地址：```http://img.xxx.com/xx/001/001.jpg_100x100.jpg```

#### 访问流程
* 首先判断缩略图是否存在，如存在则直接显示缩略图；
* 缩略图不存在,则判断原图是否存在，如原图存在则拼接graphicsmagick命令,生成并显示缩略图,否则返回404

## 配置


## 依赖
* Nginx
```bash
./configure --prefix=/usr/local/nginx --user=www --group=www --pid-path=/opt/logs/nginx/nginx.pid --lock-path=/opt/logs/nginx/nginx.lock --error-log-path=/opt/logs/nginx/error.log --http-log-path=/opt/logs/nginx/access.log --with-http_ssl_module --with-http_realip_module --with-http_sub_module --with-http_flv_module --with-http_dav_module --with-http_gzip_static_module --with-http_stub_status_module --with-http_addition_module --with-zlib=../zlib-1.2.8 --with-pcre=../pcre-8.36 --add-module=../nginx-http-concat --add-module=../lua-nginx-module/ --add-module=../echo-nginx-module/ --add-module=../ngx_devel_kit/
```
* GraphicsMagick(1.3.18)
  * libjpeg
  * libpng
* inotify(可选)

## 安装

#### nginx vhost default配置
```bash
server {
    listen   80;
    index index.php index.html index.htm;

    set $root_path '/var/www';
    root $root_path;


    location / {
        index  index.html index.htm;
    }

	location /lua {
		default_type 'text/plain';
        content_by_lua 'ngx.say("hello, ttlsa lua")';
    }

    location ~* ^(.+\.(jpg|jpeg|gif|png))_(\d+)+x(\d+)+\.(jpg|jpeg|gif|png)$ {
        root /tmp/thumb;    # 这里必须设置，否则根目录，即 $document_root 会是 Nginx 默认的 Nginx Root/html，在 Lua 中会得不到期望的值
        set $thumbnail_root /tmp/thumb;
        set $img_original_root $root_path;
        set $file $thumbnail_root$uri;             #如果缩略图文件存在，直接返回

        if (!-f $file) {    # 如果文件不存在时才需要裁剪
            set $request_filepath $img_original_root$1;    # 设置原始图片路径，如：/document_root/1.gif
            set $img_width $3;    # 设置裁剪/缩放的宽度
            set $img_height $4;    # 设置裁剪/缩放的高度
            set $img_ext $2;    # 图片文件格式后缀
            content_by_lua_file /etc/nginx/lua/img.lua;    # 加载外部 Lua 文件
        }
    }

    location ~ /\.ht {
        deny all;
    }
}
```

#### nginx fastdfs配置
```bash
server{
    listen      80;
    server_name static.saleasy.net static.isaleasy.com static.estt.com.cn;

    # 缩放图片链接
    location ~* ^(\/pic\/M00(.+\.(jpg|jpeg|gif|png))_(\d+)+x(\d+)+\.(jpg|jpeg|gif|png))$ {
            root /opt/fastdfs/thumb;    # 这里必须设置，否则根目录，即 $document_root 会是 Nginx 默认的 Nginx Root/html，在 Lua 中会得不到期望的值
            set $thumbnail_root /opt/fastdfs/thumb;
            set $fdfs_group_root /opt/fastdfs/pic/store0/data;
            set $file $thumbnail_root$uri;

            if (!-f $file) {    # 如果文件不存在时才需要裁剪
                    set $request_filepath $fdfs_group_root$2;    # 设置原始图片路径，如：/document_root/1.gif
                    set $img_width $4;    # 设置裁剪/缩放的宽度
                    set $img_height $5;    # 设置裁剪/缩放的高度
                    set $img_ext $3;    # 图片文件格式后缀
                    content_by_lua_file /etc/nginx/lua/img.lua;    # 加载外部 Lua 文件
            }
    }

    # 默认图片
    location /pic/M00 {
            alias /opt/fastdfs/pic/store0/data;
            ngx_fastdfs_module;
    }

    location = /favicon.ico {
            log_not_found off;
            access_log off;
    }
}
```

#### img.lua文件
```bash
-- nginx lua thumbnail module
-- created by yanue
-- last update : 2014/11/3
-- version     : 0.5.1

-- 检测路径是否目录
local function is_dir(sPath)
    if type(sPath) ~= "string" then return false end

    local response = os.execute("cd " .. sPath)
    if response == 0 then
        return true
    end
    return false
end

-- 文件是否存在
function file_exists(name)
    local f = io.open(name, "r")
    if f ~= nil then io.close(f) return true else return false end
end

-- 获取文件路径
function getFileDir(filename)
    return string.match(filename, "(.+)/[^/]*%.%w+$") --*nix system
end

-- 获取文件名
function strippath(filename)
    return string.match(filename, ".+/([^/]*%.%w+)$") -- *nix system
end

--去除扩展名
function stripextension(filename)
    local idx = filename:match(".+()%.%w+$")
    if (idx) then
        return filename:sub(1, idx - 1)
    else
        return filename
    end
end

--获取扩展名
function getExtension(filename)
    return filename:match(".+%.(%w+)$")
end

-- 开始执行
-- ngx.log(ngx.ERR, getFileDir(ngx.var.file));
-- ngx.log(ngx.ERR,ngx.var.file);
-- ngx.log(ngx.ERR,ngx.var.request_filepath);

local gm_path = 'gm'

-- check image dir
if not is_dir(getFileDir(ngx.var.file)) then
    os.execute("mkdir -p " .. getFileDir(ngx.var.file))
end

-- 裁剪后保证等比缩图 （缺点：裁剪了图片的一部分）
-- 命令：gm convert input.jpg -thumbnail "100x100^" -gravity center -extent 100x100 output_3.jpg
if (file_exists(ngx.var.request_filepath)) then
    local cmd = gm_path .. ' convert ' .. ngx.var.request_filepath
    cmd = cmd .. " -thumbnail " .. ngx.var.img_width .. "x" .. ngx.var.img_height .. "^"
    cmd = cmd .. " -gravity center -extent " .. ngx.var.img_width .. "x" .. ngx.var.img_height
    cmd = cmd .. " +profile \"*\" " .. ngx.var.file;
    ngx.log(ngx.ERR, cmd);
    os.execute(cmd);
    ngx.exec(ngx.var.uri);
else
    ngx.exit(ngx.HTTP_NOT_FOUND);
end
```

参考:https://github.com/hopesoft/nginx-lua-image-module