package com.maabrle.web.model;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

public class NewTodo {

    public static final Logger LOGGER = LoggerFactory.getLogger(NewTodo.class);

    private String processingType;
    private String todoText;

    public NewTodo(String todoText, String processingType) {
        this.todoText = todoText;
        this.processingType = processingType;
    }

    public NewTodo() {
    }

    public String getProcessingType() {
        return processingType;
    }

    public String getTodoText() {
        return todoText;
    }

    public void setProcessingType(String type) {
        processingType = type;
    }

    public void setTodoText(String text) {
        todoText = text;
    }

    @Override
    public String toString() {
        try {
            return new ObjectMapper().writeValueAsString(this);
        } catch (JsonProcessingException ex) {
            LOGGER.error("Failed to convert NewTodo into a string: {}\n{}", ex.getMessage(), ex);
        }
        // This is just for the impossible case where the ObjectMapper throws an
        // exception
        return "{" +
                " todoText='" + (todoText != null ? todoText : "").replace("\'", "\\'") + '\'' +
                ", processingType='" + processingType + '\'' +
                '}';
    }
}