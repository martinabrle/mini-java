package com.maabrle.consumerkafka.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.maabrle.consumerkafka.model.Todo;

public interface TodoRepository extends JpaRepository<Todo, Long> {

}