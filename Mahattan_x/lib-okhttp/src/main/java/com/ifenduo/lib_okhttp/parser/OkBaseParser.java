package com.ifenduo.lib_okhttp.parser;

import java.io.IOException;

import okhttp3.Response;

/**
 */
public abstract class OkBaseParser<T> {

    protected int code;

    protected abstract T parse(Response response) throws IOException;

    public T parseResponse(Response response) throws IOException {
        code = response.code();
        return parse(response);
    }

    public int getCode() {
        return code;
    }

}
