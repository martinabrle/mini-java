package com.maabrle.web.exception;

public class TodoNotFoundException extends RuntimeException {

    public TodoNotFoundException() {
        super(String.format("Todo was not found."));
    }
}