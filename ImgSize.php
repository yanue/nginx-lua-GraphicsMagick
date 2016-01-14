<?php
/**
 * Created by PhpStorm.
 * User: mi
 * Date: 2014/10/30
 * Time: 14:56
 */

namespace Plugin;

/**
 * 动态获取图片尺寸
 *
 * 原始图片: http://img.xx.com/chat/M00/00/51/cHxqplZWoMKANLnyAAC290JKUck397.jpg
 * 按固定宽和高: http://img.xx.com/chat/M00/00/51/cHxqplZWoMKANLnyAAC290JKUck397.jpg_100x200.jpg
 * 按固定宽: http://img.xx.com/chat/M00/00/51/cHxqplZWoMKANLnyAAC290JKUck397.jpg_200-.jpg
 * 按固定高: http://img.xx.com/chat/M00/00/51/cHxqplZWoMKANLnyAAC290JKUck397.jpg_-200.jpg
 *
 * Class ImgSize
 * @package Plugin
 */
class ImgSize
{
    private static $trust_hosts = array(
        null, // 保留null
        STATIC_DOMAIN,
        MAIN_DOMAIN,
        "fdfs.estt.com.cn"
    );


    /**
     * 获取原始图片
     *
     * @param $img_url
     * @return string
     */
    public static function getOriginal($img_url)
    {
        $img_ext = pathinfo($img_url, PATHINFO_EXTENSION);
        $img_path = self::getOriginalWithoutExt($img_url);
        if ($img_url) {
            return $img_path . '.' . $img_ext;
        }
        return $img_url;
    }

    /**
     * 替换内容图片为自动高
     *
     * @param $detail
     * @return mixed
     */
    public static function getWapDetailPicReplace($detail)
    {
        preg_match_all('/<[img|IMG].*?src=[\'|\"](.*?(?:))[\'|\"].*?[\/]?>/', $detail, $matches);
        if (isset($matches[1])) {
            $matches[1] = array_unique($matches[1]);
            foreach ($matches[1] as $item) {
                $detail = str_replace($item, self::getAutoHeight($item), $detail);
            }
        }
        return $detail;

    }

    /**
     * 获取自动高
     *
     * @param $img_url
     * @param int $width
     * @return string
     */
    public static function getAutoHeight($img_url, $width = 800)
    {
        $width = intval($width * 1.5);

        if ($img_url) {
            // 允许的域名
            $img_host = parse_url($img_url, PHP_URL_HOST);
            if (!($img_host && in_array($img_host, self::$trust_hosts))) {
                return $img_url;
            }

            // 获取原始图片未带后缀
            $originalImgPath = self::getOriginalWithoutExt($img_url);
            if (!$originalImgPath) {
                return $img_url;
            }
            $img_ext = pathinfo($img_url, PATHINFO_EXTENSION);

            if ($width) {
                return $originalImgPath . '.' . $img_ext . '_' . $width . '-.' . $img_ext;
            }
        }

        return $img_url;
    }

    /**
     * 获取自动宽
     *
     * @param $img_url
     * @param int $height
     * @return string
     */
    public static function getAutoWidth($img_url, $height = 200)
    {
        $height = intval($height * 1.5);

        if ($img_url) {

            // 允许的域名
            $img_host = parse_url($img_url, PHP_URL_HOST);
            if (!($img_host && in_array($img_host, self::$trust_hosts))) {
                return $img_url;
            }

            // 获取原始图片未带后缀
            $originalImgPath = self::getOriginalWithoutExt($img_url);
            if (!$originalImgPath) {
                return $img_url;
            }
            $img_ext = pathinfo($img_url, PATHINFO_EXTENSION);

            if ($height) {
                return $originalImgPath . '.' . $img_ext . '_' . '-' . $height . '.' . $img_ext;
            }
        }

        return $img_url;
    }

    /**
     * 按固定尺寸获取图片
     *
     * @param $img_url
     * @param int $w
     * @param null $h
     * @return string
     */
    public static function getSize($img_url, $w = 200, $h = null)
    {
        if ($w < 800) {
            $w = intval($w * 1.5);
            $h = intval($h * 1.5);
        }

        if ($img_url) {
            // 允许的域名

            $img_host = parse_url($img_url, PHP_URL_HOST);
            if (!(in_array($img_host, self::$trust_hosts))) {
                return $img_url;
            }
            // 获取原始图片未带后缀
            $originalImgPath = self::getOriginalWithoutExt($img_url);
            if (!$originalImgPath) {
                return $img_url;
            }
            $img_ext = pathinfo($img_url, PATHINFO_EXTENSION);
            // 长宽检测
            if ($w && $h) {
                return $originalImgPath . '.' . $img_ext . '_' . $w . 'x' . $h . '.' . $img_ext;
            }

            if ($w && !$h) {
                return $originalImgPath . '.' . $img_ext . '_' . $w . 'x' . $w . '.' . $img_ext;
            }

            if (!$w && $h) {
                return $originalImgPath . '.' . $img_ext . '_' . $h . 'x' . $h . '.' . $img_ext;
            }

            if (!$w && !$h) {
                return $originalImgPath . '.' . $img_ext;
            }
        }

        return $img_url;
    }

    /**
     * 获取原始图片未带后缀
     *
     * @param $img_url
     * @return string
     */
    private static function getOriginalWithoutExt($img_url)
    {
        if ($img_url) {
            $img_ext = pathinfo($img_url, PATHINFO_EXTENSION);
            // like /avatar/M00/00/01/wKgBqFJyG2iAfHD0AAAxCAGuAII166.jpg_430x430.jpg
            if (preg_match('/^(.*)\.' . $img_ext . '(_([0-9]+)x([0-9]+)\.' . $img_ext . ')?$/is', $img_url, $match)) {
                return $match[1];
            }
        }
        return "";
    }
}