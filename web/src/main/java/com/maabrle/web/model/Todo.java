package com.maabrle.web.model;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.UUID;

public class Todo {
    public static final Logger LOGGER = LoggerFactory.getLogger(Todo.class);

    private long id;

    private Date createdDateTime;

    private String todoText;

    private Date completedDateTime;

    private String trackingId;

    public Todo() {
    }

    public Todo(long id, Date createdDateTime, String todoText) {
        this.id = id;
        this.createdDateTime = createdDateTime;
        this.todoText = todoText;
        this.completedDateTime = null;
        this.trackingId = null;
    }

    public Todo(String todoText, UUID trackingId) {
        this.id = 0;
        this.createdDateTime = null;
        this.todoText = todoText;
        this.completedDateTime = null;
        this.trackingId = trackingId.toString();
    }

    public long getId() {
        return id;
    }

    public String getTodoText() {
        return todoText;
    }

    public void setTodoText(String todoText) {
        this.todoText = todoText;
    }

    public String getTrackingId() {
        return trackingId;
    }

    public void setTrackingId(String trackingId) {
        this.trackingId = trackingId;
    }

    public String getCompleted() {
        return "Status: " + (completedDateTime != null ? "Completed" : "Pending");
    }

    public String getCreatedDateTimeShortString() {
        if (createdDateTime == null)
            return "";
        SimpleDateFormat sdf = new SimpleDateFormat("EEE MMM dd HH:mm:ss ");
        return "Created: " + sdf.format(createdDateTime);
    }

    @Override
    public String toString() {
        try {
            return new ObjectMapper().writeValueAsString(this);
        } catch (JsonProcessingException ex) {
            LOGGER.error("Failed to convert Todo into a string: {}\n{}", ex.getMessage(), ex);
        }
        // This is just for the impossible case where the ObjectMapper throws an
        // exception
        return "{" +
                "id=" + id +
                ", todoText='" + (todoText != null ? todoText : "").replace("\'", "\\'") + '\'' +
                ", created='" + createdDateTime + '\'' +
                ", trackingId='" + trackingId + '\'' +
                ", completed='" + completedDateTime + '\'' +
                '}';
    }
}