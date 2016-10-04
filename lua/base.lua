-- 基础方法模块
-- User: yanue
-- Date: 04/10/2016
-- Time: 14:42
--

-- 引用配置
local c  = require 'config'

-- 定义 base 模块
base = {}

-- 检测路径是否目录
function base.is_dir(sPath)
    if type(sPath) ~= "string" then return false end

    local response = os.execute("cd " .. sPath)
    if response == 0 then
        return true
    end
    return false
end

-- 文件是否存在
function base.file_exists(name)
    local f = io.open(name, "r")
    if f ~= nil then io.close(f) return true else return false end
end

-- 获取文件路径
function base.get_file_dir(filename)
    return string.match(filename, "(.+)/[^/]*%.%w+$") --*nix system
end

-- 获取文件名
function base.strip_path(filename)
    return string.match(filename, ".+/([^/]*%.%w+)$") -- *nix system
end

-- 去除扩展名
function base.strip_extension(filename)
    local idx = filename:match(".+()%.%w+$")
    if (idx) then
        return filename:sub(1, idx - 1)
    else
        return filename
    end
end

-- 获取扩展名
function base.get_extension(filename)
    return filename:match(".+%.(%w+)$")
end

-- 获取图片尺寸
function base.get_img_size(img)
end

--[[
	打印 nginx 日志
	log_level: 默认为ngx.NOTICE
	取值范围：ngx.STDERR , ngx.EMERG , ngx.ALERT , ngx.CRIT , ngx.ERR , ngx.WARN , ngx.NOTICE , ngx.INFO , ngx.DEBUG
	请配合nginx.conf中error_log的日志级别使用
]]
function lua_log(msg, log_level)
    log_level = log_level or c.lua_log_level
    if (c.enabled_log) then
        ngx.log(log_level, msg)
    end
end

return base