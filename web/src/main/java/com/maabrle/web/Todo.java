package com.maabrle.web;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.UUID;

public class Todo {

    private long id;

    private Date createdDateTime;

    private String todoText;

    private Date completedDateTime;

    private String trackingId;

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
}