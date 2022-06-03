package com.maabrle.web;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.UUID;

import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.web.reactive.function.client.WebClient;

import com.maabrle.web.Exception.TodoCreationFailedException;
import com.maabrle.web.Exception.TodosRetrievalFailedException;
import com.maabrle.web.model.NewTodo;

import reactor.core.publisher.Mono;

public class TodoService {
    public static List<com.maabrle.web.Todo> GetTodos() throws TodosRetrievalFailedException {

        ArrayList<Todo> retVaList = new ArrayList<>();

        try {
            String uri = TodoApiConfiguration.getTodoApiURI();

            HttpClient client = HttpClient.newHttpClient();

            HttpRequest request = HttpRequest.newBuilder(URI.create(uri)).header("Content-Type", "application/json")
                    .GET()
                    .build();

            HttpResponse<String> response = client.send(request,
                    HttpResponse.BodyHandlers.ofString());

            JSONObject responseJSON = new JSONObject(response.body());
            System.out.println("=========");
            System.out.println("Response:");
            System.out.println("=========");
            System.out.println(response.body());

            JSONObject embededJSON = responseJSON.getJSONObject("_embedded");

            JSONArray todosJSON = embededJSON.getJSONArray("todos");

            for (int i = 0; i < todosJSON.length(); i++) {
                JSONObject todoJSON = todosJSON.getJSONObject(i);
                Date createdDateTime;

                try {
                    String createdDateTimeString = todoJSON.getString("createdDateTime");
                    if (createdDateTimeString.length() > 23)
                        createdDateTimeString = createdDateTimeString.substring(0, 22) + "Z";
                    
                    createdDateTime = Date.from(Instant.parse(createdDateTimeString));
                } catch (Exception exception) {
                    createdDateTime = null;
                }

                retVaList.add(new Todo(todoJSON.getLong("id"), createdDateTime, todoJSON.getString("todoText")));
            }

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
