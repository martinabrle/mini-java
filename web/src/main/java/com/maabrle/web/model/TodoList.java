package com.maabrle.web.model;

import java.util.ArrayList;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

public class TodoList extends ArrayList<Todo> {

    public static final Logger LOGGER = LoggerFactory.getLogger(Todo.class);

    @Override
    public String toString() {
        try {
            return new ObjectMapper().writeValueAsString(this);
        } catch (JsonProcessingException ex) {
            LOGGER.error("Failed to convert TodoList into a string: {}\n{}", ex.getMessage(), ex);
        }
        // This is just for the impossible case where the ObjectMapper throws an
        // exception
        String retVal = "{ ";
        for (int i = 0; i < this.size(); i++) {
            if (i > 0)
                retVal += ",";
            retVal += this.get(i).toString();
        }
        retVal += " }";
        return retVal;
    }
}
