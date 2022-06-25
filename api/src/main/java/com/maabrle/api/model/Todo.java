package com.maabrle.api.model;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.util.Date;
import java.util.Objects;
import java.util.UUID;

import javax.persistence.Entity;
import javax.persistence.Id;

@Entity
public class Todo {
	public static final Logger LOGGER = LoggerFactory.getLogger(Todo.class);

	private @Id UUID id;
	private Date createdDateTime;
	private String todoText;
	private Date completedDateTime;

	@SuppressWarnings("unused")
	private Todo() {
	}

	public Todo(Date createdDateTime, String todoText, Date completedDateTime) {
		this.createdDateTime = createdDateTime;
		this.todoText = todoText;
		this.completedDateTime = completedDateTime;
	}

	@Override
	public boolean equals(Object o) {
		if (this == o)
			return true;
		if (o == null || getClass() != o.getClass())
			return false;
		Todo todo = (Todo) o;
		return Objects.equals(id, todo.id) &&
				((createdDateTime == null && todo.createdDateTime == null)
						|| (createdDateTime != null && createdDateTime.compareTo(todo.createdDateTime) == 0))
				&&
				Objects.equals(todoText, todo.todoText) &&
				((completedDateTime == null && todo.completedDateTime == null)
						|| (completedDateTime != null && completedDateTime.compareTo(todo.completedDateTime) == 0));
	}

	@Override
	public int hashCode() {

		return Objects.hash(id, createdDateTime, todoText, completedDateTime);
	}

	public UUID getId() {
		return id;
	}

	public void setId(UUID id) {
		this.id = id;
	}

	public String getTodoText() {
		return todoText;
	}

	public void setTodoText(String todoText) {
		this.todoText = todoText;
	}

	public Date getCreatedDateTime() {
		return createdDateTime;
	}

	public void setCreatedDateTime(Date createdDateTime) {
		this.createdDateTime = createdDateTime;
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
				", completed='" + completedDateTime + '\'' +
				'}';
	}
}