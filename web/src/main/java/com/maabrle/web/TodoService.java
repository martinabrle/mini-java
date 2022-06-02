package com.maabrle.web;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONObject;

public class TodoService {
    public static List<com.maabrle.web.Todo> GetTodos() {

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

        } catch (Exception exception) {
            System.err.println(exception.getMessage());
        }

        return retVaList;
    }
}
