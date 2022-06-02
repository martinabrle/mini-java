package com.maabrle.api;

class TodoNotFoundException extends RuntimeException {

    TodoNotFoundException(Long id) {
    super(String.format("Could not find Todo %x", id));
  }
}