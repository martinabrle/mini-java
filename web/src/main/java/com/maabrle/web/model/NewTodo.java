package com.maabrle.web.model;

public class NewTodo {

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
}