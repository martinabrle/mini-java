package com.maabrle.web;

import java.text.SimpleDateFormat;
import java.util.Date;

public class Todo {

    private long id;

    private Date createdDateTime;

    private String text;

    private Date completedDateTime;

    public Todo(long id, Date createdDateTime, String text) {
        this.id = id;
        this.createdDateTime = createdDateTime;
        this.text = text;
        this.completedDateTime = null;
    }

    public long getId() {
        return id;
    }

    public String getText() {
        return text;
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