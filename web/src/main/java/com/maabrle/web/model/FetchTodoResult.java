package com.maabrle.web.model;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

public class FetchTodoResult {

    public static final Logger LOGGER = LoggerFactory.getLogger(FetchTodoResult.class);

    private boolean error;
    private String message;
    private Todo todo;

    public FetchTodoResult() {
    }

    public boolean getError() {
        return error;
    }

    public String getMessage() {
        return message;
    }

    public Todo getTodo() {
        return todo;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public void setError(boolean error) {
        this.error = error;
    }

    public void setTodo(Todo todo) {
        this.todo = todo;
    }

    @Override
    public String toString() {
        try {
            return new ObjectMapper().writeValueAsString(this);
        } catch (JsonProcessingException ex) {
            LOGGER.error("Failed to convert FetchTodoResult into a string: {}\n{}", ex.getMessage(), ex);
        }
        // This is just for the impossible case where the ObjectMapper throws an
        // exception
        return "{" +
                " error: '" + error + '\'' +
                ", message: '" + (message != null ? message : "").replace("\'", "\\'") + '\'' +
                ", todo:" + (todo != null ? todo.toString() : "nil") +
                '}';
    }
}