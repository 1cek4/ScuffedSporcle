package com.example.QuizService;


import java.util.List;
import java.util.UUID;

import org.springframework.data.mongodb.repository.MongoRepository;

public interface ClassicQuizRepo extends MongoRepository<ClassicQuiz,UUID>{
    public List<ClassicQuiz> findByQuizNameContainingOrCategoryContaining(String txt, String txt2);

    List<ClassicQuiz> findByQuizNameContainingIgnoreCase(String title);

    // Custom query to find books by author
    List<ClassicQuiz> findByCategoryContainingIgnoreCase(String author);


}
