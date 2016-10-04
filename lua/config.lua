-- 基础配置
-- User: yanue
-- Date: 04/10/2016
-- Time: 14:42

module(..., package.seeall)

--[[
	enabled_log：			是否打开日志
	lua_log_level：			日志记录级别
	gm_path：				graphicsmagick安装目录
	img_background_color：	填充背景色
	enabled_default_img：	是否显示默认图片
	default_img_uri：		默认图片链接
	default_uri_reg：		缩略图正则匹配模式，可自定义
		_[0-9]+x[0-9]						对应：001_100x100.jpg
		_[0-9]+x[0-9]+[.jpg|.png|.gif]+ 	对应：001.jpg_100x100.jpg
]]

enabled_log = true
lua_log_level = ngx.NOTICE

-- gm命令路径
gm_path = 'gm'
crop_mode = ''

allow_max_width = 1980
allow_max_height = 1980

--[[
    固定宽高模式[如: /xx/xx/xx.jpg_100x100.jpg]
    允许的宽度列表,请根据自己情况修改(填写数字)
]]
all_crop_area_sizes = {
    30,
    50,
    80,
    100,
    120,
    160,
    200,
    240,
    300,
    360,
    400,
    500,
    600,
    640,
    800,
    800,
    900,
    1000,
    1200
}

--[[
    宽固定模式[如: /xx/xx/xx.jpg_100-.jpg]
    允许的宽度列表,请根据自己情况修改(填写数字)
]]
allow_auto_height_sizes = {
    30,
    50,
    80,
    100,
    120,
    160,
    200,
    240,
    300,
    360,
    400,
    500,
    600,
    640,
    800,
    800,
    900,
    1000,
    1200
}

--[[
    高固定模式[如: /xx/xx/xx.jpg_-100.jpg]
    允许的宽度列表,请根据自己情况修改(填写数字)
]]
allow_auto_width_sizes = {
    30,
    50,
    80,
    100,
    120,
    160,
    200,
    240,
    300,
    360,
    400,
    500,
    600,
    640,
    800,
    800,
    900,
    1000
}

