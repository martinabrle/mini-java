package com.maabrle.api;

import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.maabrle.api.model.Todo;

interface TodoRepository extends JpaRepository<Todo, UUID> {

}