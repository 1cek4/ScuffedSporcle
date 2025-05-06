package com.example.QuizService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("")
public class QuizRestController {

    @Autowired
    private ClassicQuizRepo classicQuizRepo;

    @GetMapping(path = "/classicQuiz")
    @ResponseStatus(code = HttpStatus.OK)
    public List<ClassicQuiz> findAllSpaceships() {
        return classicQuizRepo.findAll();
    }
    @PostMapping(path = "")
    @ResponseStatus(code = HttpStatus.CREATED)
    public void createSpaceship(@RequestBody ClassicQuiz spaceship) {
        spaceship.setQuizGuid(UUID.randomUUID());
        classicQuizRepo.save(spaceship);
    }




}
