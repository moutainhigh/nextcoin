package com.ifenduo.lib_okhttp.builder;

import android.text.TextUtils;
import android.util.Log;

import com.ifenduo.lib_okhttp.OkHttpProxy;
import com.ifenduo.lib_okhttp.callback.OkCallback;

import java.io.IOException;
import java.util.IdentityHashMap;
import java.util.Map;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.FormBody;
import okhttp3.Request;
import okhttp3.Response;

/**
 */
public class PostRequestBuilder<T> extends RequestBuilder<T> {

    private Map<String, String> headers;

    public PostRequestBuilder url(String url) {
        this.url = url;
        return this;
    }

    public PostRequestBuilder setParams(Map<String, String> params) {
        this.params = params;
        return this;
    }

    public PostRequestBuilder addParams(String key, String value) {
        if (params == null) {
            params = new IdentityHashMap<>();
        }
        params.put(key, value);
        return this;
    }

    public PostRequestBuilder headers(Map<String, String> headers) {
        this.headers = headers;
        return this;
    }

    public PostRequestBuilder addHeader(String key, String values) {
        if (headers == null) {
            headers = new IdentityHashMap<>();
        }
        headers.put(key, values);
        return this;
    }

    public PostRequestBuilder tag(Object tag) {
        this.tag = tag;
        return this;
    }

    @Override
    public Call enqueue(Callback callback) {

        if (TextUtils.isEmpty(url)) {
            throw new IllegalArgumentException("url can not be null !");
        }
        Log.d("TAG","url="+url);
        Request.Builder builder = new Request.Builder().url(url);
        if (tag != null) {
            builder.tag(tag);
        }
        if (params!=null) {
            Log.i("TAG","params="+params.toString());
        }
        FormBody.Builder encodingBuilder = new FormBody.Builder();
        appendParams(encodingBuilder, params);
        appendHeaders(builder, headers);
        builder.post(encodingBuilder.build());
        Request request = builder.build();

        if (callback instanceof OkCallback) {
            ((OkCallback) callback).onStart();
        }
        Call call = OkHttpProxy.getInstance().newCall(request);
        call.enqueue(callback);
        return call;
    }

    @Override
    public Response execute() throws IOException {
        if (TextUtils.isEmpty(url)) {
            throw new IllegalArgumentException("url can not be null !");
        }

        Request.Builder builder = new Request.Builder().url(url);
        if (tag != null) {
            builder.tag(tag);
        }
        FormBody.Builder encodingBuilder = new FormBody.Builder();
        appendParams(encodingBuilder, params);
        appendHeaders(builder, headers);
        builder.post(encodingBuilder.build());
        Request request = builder.build();

        Call call = OkHttpProxy.getInstance().newCall(request);
        return call.execute();
    }
}
