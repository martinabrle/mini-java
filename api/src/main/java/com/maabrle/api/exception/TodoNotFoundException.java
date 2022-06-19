package com.maabrle.api.exception;

public class TodoNotFoundException extends RuntimeException {

    public TodoNotFoundException(Long id) {
      super(String.format("Could not find Todo %x", id));
    }
}