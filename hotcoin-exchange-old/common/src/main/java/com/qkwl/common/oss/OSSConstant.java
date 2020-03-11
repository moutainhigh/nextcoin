package com.qkwl.common.oss;

public class OSSConstant {

    /**
     * OSS基础配置
     */
    public static final String ACCESS_ID = "";
    public static final String ACCESS_KEY = "";
    public static final String OSS_ENDPOINT ="";

    /**
     * BUCKET配置
     */
    public static final String BUCKET_BASE = "";

    /**
     * 平台配置
     */
    public static final String PLATFORM_HK = "";//OSS 文件夹 例如: huobi/

    /**
     * 上传路径
     */
    public static final String UPLOAD_BASE = PLATFORM_HK + "upload/";

    /**
     * 新闻
     */
    public static final String ARTICLE = UPLOAD_BASE + "article/";

    /**
     * 关于我们
     */
    public static final String ABOUT = UPLOAD_BASE + "about/";

    /**
     * 虚拟币
     */
    public static final String COIN = UPLOAD_BASE + "coin/";

    /**
     * 参数
     */
    public static final String ARGS = UPLOAD_BASE + "args/";

    /**
     * ICO
     */
    public static final String ICO = UPLOAD_BASE + "ico/";

    /**
     * 资产
     */
    public static final String ASSETS = UPLOAD_BASE + "assets/";

    /**
     * 平衡报表
     */
    public static final String BALANCE = UPLOAD_BASE + "balance/";

}
