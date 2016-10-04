--
-- 根据输入长或宽的尺寸自动裁切图片大小
-- User: yanue
-- Date: 04/10/2016
-- Time: 14:42
--

-- 基础方法
local base = require("base")

-- 配置信息
local cfg = require("config")

-- 检查缩略图目录是否存在
if not base.is_dir(base.get_file_dir(ngx.var.img_file)) then
    os.execute("mkdir -p " .. base.get_file_dir(ngx.var.img_file))
end


function get_img_width_height()
    -- 获取高宽 img_size 如: 100-或-100模式
    local uri = ngx.var.img_size
    local width = string.sub(uri, 1, 1)
    local height = 0

    -- 宽为"-"时,高固定,取高的值
    if width == "-" then
        local prev_height = 0;
        local has_found = 0
        width = 0
        -- 截取高,如: -100
        height = string.sub(uri, 2, string.len(uri))

        -- 正序排序
        table.sort(cfg.allow_auto_height_sizes);

        -- 查找匹配规格列表
        for _, value in pairs(all_list) do
            if (height <= value and height > prev_height) then
                height = value
                has_found = 1
                break
            end
            prev_height = value
        end

        -- 如果不在列表
        if (has_found == 0) then
            height = cfg.allow_max_height
        end
    else
        -- 高为"-"时,宽固定,取宽的值
        local prev_width = 0;

        -- 截取宽,如: 100-
        width = string.sub(uri, 1, string.len(uri) - 1)
        height = 0

        -- 正序排序
        table.sort(cfg.allow_auto_width_sizes);

        -- 查找匹配规格列表
        for _, value in pairs(cfg.allow_auto_width_sizes) do
            if (width <= value and width > prev_width) then
                width = value
                break
            end
            prev_width = value
        end

        -- 如果不在列表
        if (has_found == 0) then
            width = cfg.allow_max_width
        end
    end

    return {
        width:width,
        height:width,
    }
end

local width = 0
local height = 0

-- ngx.log(ngx.ERR,uri)
-- ngx.log(ngx.ERR,img_size)
-- ngx.log(ngx.ERR,ngx.var.img_file);
-- ngx.log(ngx.ERR,ngx.var.request_filepath);

--[[
    裁剪后保证等比缩图
    转换图片命令如: gm convert autoSize.jpg -resize x200 -quality 100 +profile "*" autoSize.jpg_-200.jpg
]]
if (base.file_exists(ngx.var.request_filepath)) then
    -- 拼接 gm 命令
    local cmd = cfg.gm_path .. ' convert ' .. ngx.var.request_filepath
    if height == 0 then
        cmd = cmd .. " -resize " .. width .. "x" .. ""
    else
        cmd = cmd .. " -resize " .. "x" .. height .. ""
    end

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
    ngx.exit(ngx.HTTP_NOT_FOUND);
end

