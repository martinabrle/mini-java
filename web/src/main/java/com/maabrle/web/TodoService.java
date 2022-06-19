package com.maabrle.web;

import java.util.List;
import java.util.UUID;

import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.web.reactive.function.client.WebClient;
import com.azure.messaging.eventhubs.*;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.maabrle.web.exception.TodoCreationFailedException;
import com.maabrle.web.exception.TodosRetrievalFailedException;
import com.maabrle.web.model.NewTodo;
import com.maabrle.web.model.Todo;
import com.maabrle.web.model.TodoApiConfiguration;
import com.maabrle.web.model.TodoList;

import reactor.core.publisher.Mono;

public class TodoService {

    public static final Logger LOGGER = LoggerFactory.getLogger(TodoService.class);

    public static List<Todo> GetTodos() throws TodosRetrievalFailedException {

        TodoList retValList = new TodoList();

        LOGGER.debug("Retrieving all TODOs synchronously using GetTodos()");

        try {
            // https://reflectoring.io/spring-webclient/

            String apiUri = TodoApiConfiguration.getTodoApiURI();
            WebClient webClient = WebClient.create(apiUri);

            retValList = webClient.get()
                    .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                    .retrieve()
                    .bodyToMono(TodoList.class)
                    .block();

            LOGGER.debug("Received back a list of TODOs as a response: {}", retValList);
        } catch (Exception ex) {
            LOGGER.error("Retrieving all TODOs failed: { }\n{ }", ex.getMessage(), ex);
            throw new TodosRetrievalFailedException(ex.getMessage());
        }

        return retValList;
    }

    public static Todo CreateTodoSync(NewTodo newTodo) throws TodoCreationFailedException {
        Todo createdTodo = null;
        try {
            LOGGER.debug("Create a new Todo synchronously using CreateTodoSync({})", newTodo);

            // https://howtodoinjava.com/spring-webflux/webclient-get-post-example/
            String apiUri = TodoApiConfiguration.getTodoApiURI();
            WebClient webClient = WebClient.create(apiUri);

            var todo = new Todo(newTodo.getTodoText(), UUID.randomUUID());

            LOGGER.debug("Sending a POST request with a new TODO {}", todo);

            createdTodo = webClient.post()
                    .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                    .body(Mono.just(todo), Todo.class)
                    .retrieve()
                    .bodyToMono(Todo.class)
                    .block();

            LOGGER.debug("Received back a new TODO as a response: {}", createdTodo);
        } catch (Exception ex) {
            LOGGER.error("Todo creation failed: { }\n{ }", ex.getMessage(), ex);
            throw new TodoCreationFailedException(ex.getMessage());
        }
        return createdTodo;
    }

    public static Todo CreateTodoAsyncEventHub(NewTodo newTodo) throws TodoCreationFailedException {

        LOGGER.debug("Create a new Todo asynchronously via EventHub using CreateTodoAsyncEventHub({})", newTodo);

        // create a producer using the namespace connection string and event hub name
        var todo = new Todo(newTodo.getTodoText(), UUID.randomUUID());

        try {
            LOGGER.debug("Initializing EventHubProducerClient");

            EventHubProducerClient producer = new EventHubClientBuilder()
                    .connectionString(TodoApiConfiguration.getEventHubNameSpaceConnectionString(),
                            TodoApiConfiguration.getEventHubName())
                    .buildProducerClient();

            LOGGER.debug("Creating a new EventDataBatch");
            // prepare a batch of events to send to the event hub
            EventDataBatch batch = producer.createBatch();

            LOGGER.debug("Adding a new Todo ({}) into EventDataBatch", todo);

            if (!batch.tryAdd(new EventData(todo.toString()))) {
                LOGGER.error("Unable to fit the Todo object '{}'' into an EventDataBatch!", todo);
                throw new TodoCreationFailedException("Unable to fit the Todo object into an EventDataBatch!");
            }

            // send the batch of events to the event hub
            LOGGER.warn("Sending EventDataBatch to EventHub");

            producer.send(batch);

            // close the producer
            producer.close();

            LOGGER.warn("Finished the async Todo submission via EventBub and closed the producer");
        } catch (Exception ex) {
            LOGGER.error("Todo creation failed: { }\n{ }", ex.getMessage(), ex);
            throw new TodoCreationFailedException(ex.getMessage());
        }
        return todo;
    }
}
