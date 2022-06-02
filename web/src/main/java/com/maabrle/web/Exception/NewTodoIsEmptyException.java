package com.maabrle.web.Exception;

public class NewTodoIsEmptyException extends RuntimeException {

    public NewTodoIsEmptyException() {
        super(String.format("Todo cannot be empty."));
    }
}