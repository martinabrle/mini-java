package com.maabrle.api;

import java.util.Date;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import com.maabrle.api.model.Todo;

@RestController
class TodoController {

  private final TodoRepository repository;

  TodoController(TodoRepository repository) {
    this.repository = repository;
  }

  // Aggregate root
  // tag::get-aggregate-root[]
  @GetMapping("/todos")
  List<Todo> all() {
    return repository.findAll();
  }
  // end::get-aggregate-root[]

  @PostMapping("/todos")
  Todo newTodo(@RequestBody Todo newTodo) {
    if (newTodo.getCreatedDateTime() == null) {
      newTodo.setCreatedDateTime(new Date());
    }
    return repository.save(newTodo);
  }

  // Single item
  @GetMapping("/todos/{id}")
  ResponseEntity<Todo> one(@PathVariable UUID id) {

    Optional<Todo> retVal = repository.findById(id);
    
    //return ResponseEntity.of(retVal);
    if (retVal.isEmpty()) {
      return new ResponseEntity<Todo>(HttpStatus.NOT_FOUND);
    }
    
    return new ResponseEntity<Todo>(retVal.get(), HttpStatus.OK);
  }

  @PutMapping("/todos/{id}")
  ResponseEntity<Todo> replaceTodo(@RequestBody Todo newTodo, @PathVariable UUID id) {

    Optional<Todo> retVal = repository.findById(id);

    if (retVal.isEmpty()) {
      return new ResponseEntity<Todo>(HttpStatus.NOT_FOUND);
    }
    Todo todo = retVal.get();

    todo.setTodoText(newTodo.getTodoText());
    todo.setCreatedDateTime(newTodo.getCreatedDateTime());
    todo.setCompletedDateTime(newTodo.getCompletedDateTime());
    if (newTodo.getCreatedDateTime() == null) {
      newTodo.setCreatedDateTime(new Date());
    }

    todo = repository.save(todo);

    return new ResponseEntity<Todo>(retVal.get(), HttpStatus.OK);
  }

  @DeleteMapping("/todos/{id}")
  void deleteTodo(@PathVariable UUID id) {
    repository.deleteById(id);
  }
}