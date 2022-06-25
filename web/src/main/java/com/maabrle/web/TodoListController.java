package com.maabrle.web;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

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
import com.maabrle.web.model.TodoList;

@Controller
public class TodoListController {

	public static final Logger LOGGER = LoggerFactory.getLogger(Todo.class);

	@GetMapping("/")
	public String getTodos(@RequestParam(name = "name", required = false, defaultValue = "World") String name,
			Model model) {

		LOGGER.debug("TODOs retrieval called");

		model.addAttribute("newTodo", new NewTodo());
		model.addAttribute("status", "");
		model.addAttribute("todos", new TodoList());

		try {
			model.addAttribute("todos", TodoService.GetTodos());
		} catch (Exception ex) {
			LOGGER.error("Failed to retrieve the list of TODOs: {}\n{}", ex.getMessage(), ex);
			model.addAttribute("status", "error");
			model.addAttribute("message", "Failed to fetch Todos. Please try again later.");
		}
		return "todo";
	}

	@PostMapping("/create")
	public String todoSubmit(@ModelAttribute NewTodo newTodo, Model model) {

		LOGGER.debug("TODO creation called", newTodo);

		model.addAttribute("newTodo", newTodo);
		model.addAttribute("status", "");
		model.addAttribute("todos", new TodoList());
		model.addAttribute("message", "");
		boolean isError = false;
		try {
			if (newTodo == null) {
				throw new NewTodoIsEmptyException();
			}

			if (newTodo.getProcessingType().equals("SYNC")) {
				Todo todo = TodoService.CreateTodoSync(newTodo);
				model.addAttribute("status", "saved");
				model.addAttribute("message", String.format("Task %o has been saved.", todo.getId()));
			} else {
				String trackingId = TodoService.CreateTodoAsyncEventHub(newTodo).getTrackingId();
				model.addAttribute("status", "saving");
				model.addAttribute("trackingId", trackingId);
				model.addAttribute("message", String.format("Task is being saved. If not autopatically redirected, please refresh the browser"));
			}
		} catch (NewTodoIsEmptyException ex) {
			isError = true;
			LOGGER.error("Failed to save a new TODO: {}\n{}", ex.getMessage(), ex);
			model.addAttribute("status", "error");
			model.addAttribute("message", "New Todo cannot be empty. Please fill in the text.");
		} catch (Exception ex) {
			isError = true;
			LOGGER.error("Failed to save a new TODO: {}\n{}", ex.getMessage(), ex);
			model.addAttribute("status", "error");
			model.addAttribute("message", "Error while saving the new task. Please try again later.");
		}

		try {
			model.addAttribute("todos", TodoService.GetTodos());
		} catch (TodosRetrievalFailedException e) {
			if (!isError) {
				if (newTodo.getProcessingType().equals("SYNC")) {
					// it's more important to display that "waiting for task saved" message, than
					// "error while retrieving existing tasks" message
					model.addAttribute("status", "error");
					model.addAttribute("message",
							"New Todo has been saved, but we failed to fetch the list of all Todos. Please try again later.");
				}
				isError = true;
			}
		}
		return "todo";
	}
}