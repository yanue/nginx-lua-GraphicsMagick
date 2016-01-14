nginx install
============
0. before ready
---------------
groupadd www
useradd -g www www -s /bin/false

yum install -y gcc gcc-c++ zlib zlib-devel openssl openssl-devel pcre pcre-devel
yum install -y libpng libjpeg libpng-devel libjpeg-devel ghostscript libtiff libtiff-devel freetype freetype-devel

1. download software
--------------------
/usr/local/src
### base download
wget http://nginx.org/download/nginx-1.8.0.tar.gz
wget http://luajit.org/download/LuaJIT-2.0.4.tar.gz ### LuaJIT
wget ftp://ftp.graphicsmagick.org/pub/GraphicsMagick/1.3/GraphicsMagick-1.3.21.tar.gz ### GraphicsMagick
wget http://zlib.net/zlib-1.2.8.tar.gz

### nginx module 
git clone https://github.com/alibaba/nginx-http-concat.git
git clone https://github.com/simpl/ngx_devel_kit.git
git clone https://github.com/openresty/echo-nginx-module.git
git clone https://github.com/openresty/lua-nginx-module.git
git clone https://github.com/happyfish100/fastdfs-nginx-module.git

2. unzip and install depends
------------------------------

#### 2.0 unzip 
tar -zxf nginx-1.8.0.tar.gz
tar -zxf LuaJIT-2.0.4.tar.gz
tar -zxf GraphicsMagick-1.3.21.tar.gz
tar -zxf zlib-1.2.8.tar.gz

#### 2.1 install LuaJIT
cd LuaJIT-2.0.4
./configure --with-ld-opt="-Wl,-rpath,$LUAJIT_LIB"
make -j8
make install 
export LUAJIT_LIB=/usr/local/lib
export LUAJIT_INC=/usr/local/include/luajit-2.0
ln -s /usr/local/lib/libluajit-5.1.so.2 /lib64/libluajit-5.1.so.2
cd ..

#### 2.2 install GraphicsMagick
cd GraphicsMagick-1.3.21
./configure --enable-shared --with-jpeg=yes  --with-png=yes
make -j8
make install
cd ..

#### 2.3 install nginx
cd nginx-1.8.0
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

如果安装了 fastdfs
--add-module=../fastdfs-nginx-module/src

make -j8
make install



