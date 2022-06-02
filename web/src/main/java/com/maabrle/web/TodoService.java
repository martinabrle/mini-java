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
import org.springframework.http.ResponseEntity;
import org.springframework.web.client.RestTemplate;

import com.maabrle.web.Exception.TodosRetrievalFailedException;
import com.maabrle.web.model.NewTodo;

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

    public static Todo CreateTodoSync(NewTodo newTodo) {
        try
        {
            //https://howtodoinjava.com/spring-boot2/resttemplate/resttemplate-post-json-example/
            String baseUrl = TodoApiConfiguration.getTodoApiURI();
            
            RestTemplate restTemplate = new RestTemplate();
     
            URI uri = new URI(baseUrl);

            HttpClient client = HttpClient.newHttpClient();

            Todo todo = new Todo(newTodo.getTodoText(), UUID.randomUUID());
 
            ResponseEntity<Todo> result = restTemplate.postForEntity(uri, todo, String.class);

            
        }
        catch (Exception exception) {

        }
    }

    public static String CreateTodoAsync(NewTodo newTodo) {
        return null;
    }
}
