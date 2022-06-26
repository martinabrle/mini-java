package com.maabrle.consumerkafka;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.messaging.Message;

import java.util.Date;
import java.util.function.Consumer;

import com.maabrle.consumerkafka.model.Todo;
import com.maabrle.consumerkafka.repository.TodoRepository;

@SpringBootApplication
public class ConsumerKafkaApplication {
	/************************************************************************************
	 * private final TodoRepository repository;
	 *
	 * ConsumerKafkaApplication(TodoRepository repository) {
	 * this.repository = repository;
	 * //this only works when not using Kafka; when used in conjunction with Kafka,
	 * // it breaks consume() - consume() will not be called
	 * }
	 ***********************************************************************************/
	@Autowired
	private TodoRepository repository;

	private static final Logger LOGGER = LoggerFactory.getLogger(ConsumerKafkaApplication.class);

	public static void main(String[] args) {
		SpringApplication.run(ConsumerKafkaApplication.class, args);
	}

	@Bean
	public Consumer<Message<Todo>> consume() {
		// return message -> System.out.printf(String.format("New message received:
		// '%s'", message.getPayload()));
		return message -> {
			Todo newTodo = message.getPayload();
			LOGGER.debug("New message received: '{}'", newTodo);
			if (repository == null)
				LOGGER.error("weird");
			LOGGER.debug("New message saved into the repository");
			try {
				if (newTodo.getCreatedDateTime() == null) {
					newTodo.setCreatedDateTime(new Date());
				}
				repository.save(newTodo);
			} catch (Exception ex) {
				LOGGER.error("Failed to save '{}': {}\n{}", newTodo, ex.getMessage(), ex);
				throw ex;
			}
		};
	}
}
