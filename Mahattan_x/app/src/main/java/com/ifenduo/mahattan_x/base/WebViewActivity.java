package com.ifenduo.mahattan_x.base;

import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import com.ifenduo.mahattan_x.R;

import butterknife.BindView;

/**
 * Created by Administrator on 2017/2/13.
 */

public class WebViewActivity extends BaseActivity {

    @BindView(R.id.web_view)
    WebView webView;
    private String url;
    private String mTitle;

    @Override
    protected boolean isShouldCreateStatusBar() {
        return true;
    }

    @Override
    protected boolean isSetStatusBarLightMode() {
        return true;
    }

    @Override
    protected int getToolbarColor() {
        return getResources().getColor(R.color.colorPrimary);
    }

    public static void openWebView(Context context, String title, String url) {
        Intent intent = new Intent(context, WebViewActivity.class);
        Bundle bundle = new Bundle();
        bundle.putString("url", url);
        bundle.putString("title", title);
        intent.putExtras(bundle);
        context.startActivity(intent);
    }

    @Override
    protected int getContentViewLayoutId() {
        return R.layout.activity_web_view;
    }

    @Override
    protected void onCreateViewAfter(Bundle savedInstanceState) {
        super.onCreateViewAfter(savedInstanceState);
        setNavigationCenter(mTitle, Color.WHITE);
        init();
    }


    @Override
    protected void onReceiveRequestIntent(Intent intent) {
        super.onReceiveRequestIntent(intent);
        Bundle bundle=intent.getExtras();
        if(bundle!=null){
            url=bundle.getString("url","");
            mTitle=bundle.getString("title","");
        }
    }

    private void init() {
        if (TextUtils.isEmpty(url))
            return;
        //启用支持javascript
        WebSettings settings = webView.getSettings();
        settings.setJavaScriptEnabled(true);
//        settings.setSupportZoom(true);
        //优先使用缓存
//        webView.getSettings().setCacheMode(WebSettings.LOAD_CACHE_ELSE_NETWORK);
        //不使用缓存
        webView.getSettings().setCacheMode(WebSettings.LOAD_NO_CACHE);
        showProgress(null);
        settings.setUseWideViewPort(true);//设置此属性，可任意比例缩放
        settings.setLoadWithOverviewMode(true);
        webView.loadUrl(url);
        //覆盖WebView默认使用第三方或系统默认浏览器打开网页的行为，使网页用WebView打开
        webView.setWebViewClient(new WebViewClient() {
            @Override
            public boolean shouldOverrideUrlLoading(WebView view, String url) {
                // TODO Auto-generated method stub
                //返回值是true的时候控制去WebView打开，为false调用系统浏览器或第三方浏览器
//                view.loadUrl(url);
                if (url.startsWith("scheme:") || url.startsWith("scheme:")) {
                    Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
                    startActivity(intent);
                }
                return false;
            }

        });
        webView.setWebChromeClient(new WebChromeClient() {
            @Override
            public void onProgressChanged(WebView view, int newProgress) {
                // TODO Auto-generated method stub
                if (newProgress == 100) {
                    // 网页加载完成
                    dismissProgress();
                } else {
                    showProgress();
                }
            }

            @Override
            public void onReceivedTitle(WebView view, String title) {
                super.onReceivedTitle(view, title);
            }
        });
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        // TODO Auto-generated method stub
        if (keyCode == KeyEvent.KEYCODE_BACK) {
            if (webView.canGoBack()) {
                webView.goBack();//返回上一页面
                return true;
            } else {
                finish();
            }
        }
        return super.onKeyDown(keyCode, event);
    }


}
