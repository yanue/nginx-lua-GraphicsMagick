-- 根据输入长和宽的尺寸裁切图片
-- User: yanue
-- Date: 04/10/2016
-- Time: 14:42

-- 基础方法
local base = require("base")

-- 配置信息
local cfg = require("config")

-- check image dir
if not base.is_dir(base.get_file_dir(ngx.var.img_file)) then
    os.execute("mkdir -p " .. base.get_file_dir(ngx.var.img_file))
end

function get_img_width_height()
    -- 获取高宽 img_size 如: 100-或-100模式
    local width = ngx.var.img_width
    local height = ngx.var.img_height
    local has_found = 0
    local prev_size = cfg.allow_max_width
    local list = cfg.all_crop_area_sizes
    -- 倒序排序
    table.sort(list, function(a, b) return a[1] > b[1] end);
    -- 查找匹配规格列表
    -- todo
    for _, value in pairs(all_list) do
        if ((height <= value and height > prev_size) or (width <= value and width > prev_size)) then
            height = value
            has_found = 1
            break
        end
        prev_size = value
    end

    if (has_found == 0) then

    end

    return {
        width:width,
        height:width,
    }
end

-- ngx.log(ngx.ERR,uri)
-- ngx.log(ngx.ERR,width)
-- ngx.log(ngx.ERR,height)
-- ngx.log(ngx.ERR,ngx.var.img_file);
-- ngx.log(ngx.ERR,ngx.var.request_filepath);

--[[
    裁剪后保证等比缩图 （缺点：裁剪了图片的一部分）
    转换图片命令如: gm convert cropSize.jpg -thumbnail 300x300^ -gravity center -extent 300x300 -quality 100 +profile "*" cropSize.jpg_300x300.jpg
]]
if (base.file_exists(ngx.var.request_filepath)) then
    -- 拼接 gm 命令
    local cmd = cfg.gm_path .. ' convert ' .. ngx.var.request_filepath
    cmd = cmd .. " -thumbnail " .. ngx.var.img_width .. "x" .. ngx.var.img_height .. "^"
    cmd = cmd .. " -gravity center -extent " .. ngx.var.img_width .. "x" .. ngx.var.img_height

    -- 由于压缩后比较模糊,默认图片质量为100,请根据自己情况修改quality
    cmd = cmd .. " -quality 100"

    -- 不存储exif信息，以减小图片体积
    cmd = cmd .. " +profile \"*\" " .. ngx.var.img_file;

    -- 打印gm转换命令
    base.lua_log(cmd, ngx.ERR);

    -- 执行转换
    os.execute(cmd);

    -- 重新渲染 nginx 地址
    ngx.exec(ngx.var.uri);
else
    -- 404
    ngx.exit(ngx.HTTP_NOT_FOUND);
end
