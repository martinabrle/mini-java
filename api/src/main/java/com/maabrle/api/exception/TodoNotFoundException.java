package com.maabrle.api.exception;

import java.util.UUID;

public class TodoNotFoundException extends RuntimeException {

    public TodoNotFoundException(UUID id) {
      super(String.format("Could not find Todo '%s'", id.toString()));
    }
}