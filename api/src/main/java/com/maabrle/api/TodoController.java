package com.maabrle.api;

import java.util.List;

import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import com.maabrle.api.exception.TodoNotFoundException;
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
    return repository.save(newTodo);
  }

  // Single item
  @GetMapping("/todos/{id}")
  Todo one(@PathVariable Long id) {
    
    return repository.findById(id)
      .orElseThrow(() -> new TodoNotFoundException(id));
  }

  @PutMapping("/todos/{id}")
  Todo replaceTodo(@RequestBody Todo newTodo, @PathVariable Long id) {
    
    return repository.findById(id)
      .map(todo -> {
        todo.setTodoText(newTodo.getTodoText());
        return repository.save(todo);
      })
      .orElseGet(() -> {
        newTodo.setId(id);
        return repository.save(newTodo);
      });
  }

  @DeleteMapping("/todos/{id}")
  void deleteTodo(@PathVariable Long id) {
    repository.deleteById(id);
  }
}