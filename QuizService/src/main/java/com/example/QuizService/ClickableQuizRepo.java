package com.example.QuizService;

import org.springframework.data.mongodb.repository.MongoRepository;
import java.util.UUID;

public interface ClickableQuizRepo extends MongoRepository<ClickableQuiz, UUID> { }