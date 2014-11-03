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
