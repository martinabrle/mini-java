package com.maabrle.web;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.maabrle.web.model.NewTodo;

@Controller
public class TodoListController {

	@GetMapping("/")
	public String greeting(@RequestParam(name = "name", required = false, defaultValue = "World") String name,
			Model model) {
		model.addAttribute("newTodo", new NewTodo());
		model.addAttribute("todos", TodoService.GetTodos());
		return "todo";
	}
    
	//@PostMapping("/greeting")
	@PostMapping("/")
	public String greetingSubmit(@ModelAttribute NewTodo newTodo, Model model) {
		model.addAttribute("newTodo", newTodo);
		if (newTodo != null) {
			System.out.println(String.format("New task: $s", newTodo.getTodoText()));
			TodoService.CreateTodo(newTodo);
		} else {
			System.err.println("Received an ampty request");
		}
		model.addAttribute("todos", TodoService.GetTodos());
		return "todo";
	}

}