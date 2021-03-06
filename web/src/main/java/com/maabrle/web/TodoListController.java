package com.maabrle.web;

import java.util.UUID;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.maabrle.web.exception.NewTodoIsEmptyException;
import com.maabrle.web.exception.TodoNotFoundException;
import com.maabrle.web.exception.TodosRetrievalFailedException;
import com.maabrle.web.model.NewTodo;
import com.maabrle.web.model.Todo;
import com.maabrle.web.model.TodoList;

//TODO: review and refactor - Thymeleaf the first time
@Controller
public class TodoListController {

	public static final Logger LOGGER = LoggerFactory.getLogger(Todo.class);

	@GetMapping("/")
	public String getTodos(@RequestParam(name = "name", required = false, defaultValue = "World") String name,
			Model model) {

		LOGGER.debug("TODOs retrieval called");

		model.addAttribute("status", "");
		model.addAttribute("checkStatusAsync", false);
		model.addAttribute("message", "");
		model.addAttribute("newTodo", new NewTodo());
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
		model.addAttribute("todos", new TodoList());
		model.addAttribute("status", "");
		model.addAttribute("createdTodoId", UUID.fromString("0-0-0-0-0"));
		model.addAttribute("checkStatusAsync", false);
		model.addAttribute("message", "");
		boolean isError = false;
		try {
			if (newTodo == null) {
				throw new NewTodoIsEmptyException();
			}
			if (newTodo.getProcessingType().equals("SYNC")) {
				Todo todo = TodoService.CreateTodoSync(newTodo);
				model.addAttribute("status", "saved");
				model.addAttribute("createdTodoId", todo.getId());
				String taskStrParm = todo.getTodoText();
				if (taskStrParm != null && taskStrParm.length() > 5)
					taskStrParm = taskStrParm.substring(0, 4) + "...";
				model.addAttribute("message", String.format("Task '%s' has been saved.", taskStrParm));
				NewTodo newTodoEmpty = new NewTodo();
				newTodoEmpty.setProcessingType(newTodo.getProcessingType());
				model.addAttribute("newTodo", newTodoEmpty);
			} else {
				UUID id = TodoService.CreateTodoAsyncEventHub(newTodo).getId();
				model.addAttribute("status", "saving");
				model.addAttribute("trackingId", id);
				model.addAttribute("checkStatusAsync", true);
				model.addAttribute("message", String
						.format("Task is being saved. If not automatically redirected, please refresh the browser"));
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

	@RequestMapping(value = "/todos/{id}", method = RequestMethod.GET, produces = "application/json")
	@ResponseBody
	public ResponseEntity<Todo> fetchTodo(@PathVariable(name = "id", required = true) String id) {
		Todo retVal = null;
		try {
			retVal = TodoService.GetTodo(UUID.fromString(id));
		} catch (TodoNotFoundException ex) {
			return new ResponseEntity<Todo>(HttpStatus.NOT_FOUND);
		} catch (TodosRetrievalFailedException ex) {
			return new ResponseEntity<Todo>(HttpStatus.BAD_REQUEST);
		} catch (Exception ex) {
			return new ResponseEntity<Todo>(HttpStatus.INTERNAL_SERVER_ERROR);
		}
		return new ResponseEntity<Todo>(retVal, HttpStatus.OK);
	}
}