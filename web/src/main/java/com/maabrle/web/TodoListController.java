package com.maabrle.web;

import java.util.ArrayList;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.maabrle.web.exception.NewTodoIsEmptyException;
import com.maabrle.web.exception.TodosRetrievalFailedException;
import com.maabrle.web.model.NewTodo;
import com.maabrle.web.model.Todo;

@Controller
public class TodoListController {

	@GetMapping("/")
	public String greeting(@RequestParam(name = "name", required = false, defaultValue = "World") String name,
			Model model) {
		model.addAttribute("newTodo", new NewTodo());
		model.addAttribute("status", "");
		model.addAttribute("todos", new ArrayList<Todo>());
		
		try
		{
			model.addAttribute("todos", TodoService.GetTodos());
		}
		catch (Exception e) {
			model.addAttribute("status", "error");
			model.addAttribute("message", "Failed to fetch Todos. Please try again later.");
		}
		return "todo";
	}
    
	//@PostMapping("/greeting")
	@PostMapping("/")
	public String greetingSubmit(@ModelAttribute NewTodo newTodo, Model model) {
		model.addAttribute("newTodo", newTodo);
		model.addAttribute("status", "");
		model.addAttribute("todos", new ArrayList<Todo>());
		
		try
		{
			if (newTodo == null) {
				throw new NewTodoIsEmptyException();
			}

			if (newTodo.getProcessingType().equals("SYNC")) {
				Todo todo = TodoService.CreateTodoSync(newTodo);
				model.addAttribute("status", "saved");
				model.addAttribute("message", String.format("Task %o has been saved.",todo.getId()));
			} else {
				String trackingId = TodoService.CreateTodoAsync(newTodo);
				model.addAttribute("status", "saving");
				model.addAttribute("trackingId", trackingId);
			}
		}
		catch (NewTodoIsEmptyException e) {
			model.addAttribute("status", "error");
			model.addAttribute("message", "New Todo cannot be empty. Please fill in the text.");
		}
		catch (Exception e) {
			model.addAttribute("status", "error");
			model.addAttribute("message", "Error while saving the new task. Please try again later.");
		}

		try
		{
			//Review: shall we ammed the message from the previous step (?)
			model.addAttribute("todos", TodoService.GetTodos());
		}
		catch (TodosRetrievalFailedException e) {
			model.addAttribute("status", "error");
			model.addAttribute("message", "Failed to fetch Todos. Please try again later.");
		}
		return "todo";
	}
}