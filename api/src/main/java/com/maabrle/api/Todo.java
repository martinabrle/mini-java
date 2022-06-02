package com.maabrle.api;

import java.util.Date;
import java.util.Objects;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;

@Entity
public class Todo {

	private @Id @GeneratedValue(strategy = GenerationType.IDENTITY) Long id;
    private Date createdDateTime;
	private String todoText;
	private Date completedDateTime;
	private String trackingId;

	private Todo() {}

	public Todo(Date createdDateTime, String todoText, Date completedDateTime) {
		this.createdDateTime = createdDateTime;
		this.todoText = todoText;
		this.completedDateTime = completedDateTime;
	}

	@Override
	public boolean equals(Object o) {
		if (this == o) return true;
		if (o == null || getClass() != o.getClass()) return false;
		Todo todo = (Todo) o;
		return Objects.equals(id, todo.id) &&
            ((createdDateTime == null && todo.createdDateTime == null) || (createdDateTime != null && createdDateTime.compareTo(todo.createdDateTime) == 0)) &&
			Objects.equals(todoText, todo.todoText) &&
			Objects.equals(trackingId, todo.trackingId) &&
            ((completedDateTime == null && todo.completedDateTime == null) || (completedDateTime != null && completedDateTime.compareTo(todo.completedDateTime) == 0));
	}

	@Override
	public int hashCode() {

		return Objects.hash(id, createdDateTime, todoText, completedDateTime);
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getTrackingId() {
		return trackingId;
	}

	public void setTrackingId(String trackingId) {
		this.trackingId = trackingId;
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
		return "Todo{" +
			"id=" + id +
			", todoText='" + todoText + '\'' +
			", created='" + createdDateTime + '\'' +
			", trackingId='" + trackingId + '\'' +
			", completed='" + completedDateTime + '\'' +
			'}';
	}
}