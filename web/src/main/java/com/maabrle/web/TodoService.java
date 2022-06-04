package com.maabrle.web;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.web.reactive.function.client.WebClient;

import com.maabrle.web.exception.TodoCreationFailedException;
import com.maabrle.web.exception.TodosRetrievalFailedException;
import com.maabrle.web.model.NewTodo;
import com.maabrle.web.model.Todo;
import com.maabrle.web.model.TodoApiConfiguration;
import com.maabrle.web.model.TodoList;

import reactor.core.publisher.Mono;

public class TodoService {
 
    public static List<Todo> GetTodos() throws TodosRetrievalFailedException {

        ArrayList<Todo> retVaList = new ArrayList<>();

        try {
            //https://reflectoring.io/spring-webclient/

            String apiUri = TodoApiConfiguration.getTodoApiURI();
            WebClient webClient = WebClient.create(apiUri);
            
            retVaList = webClient.get()
              .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
              .retrieve()
              .bodyToMono(TodoList.class)
              .block();

        } catch (Exception e) {
            System.err.println(e.getMessage());
            throw new TodosRetrievalFailedException(e.getMessage());
        }

        return retVaList;
    }

    public static Todo CreateTodoSync(NewTodo newTodo) throws TodoCreationFailedException {
        Todo createdTodo = null;
        try
        {
            //https://howtodoinjava.com/spring-webflux/webclient-get-post-example/
            String apiUri = TodoApiConfiguration.getTodoApiURI();
            WebClient webClient = WebClient.create(apiUri);
            
            var todo = new Todo(newTodo.getTodoText(), UUID.randomUUID());

            //Review: no idea what this Mono is and why do I need to convert the response first to Mono
            //        and later to the desired type
            createdTodo = webClient.post()
              .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
              .body(Mono.just(todo), Todo.class)
              .retrieve()
              .bodyToMono(Todo.class)
              .block();
        }
        catch (Exception e) {
            throw new TodoCreationFailedException(e.getMessage());
        }
        return createdTodo;
    }

    public static String CreateTodoAsync(NewTodo newTodo) {
        return null;
    }
}
