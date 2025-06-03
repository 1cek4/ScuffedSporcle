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
    public List<ClassicQuiz> findAllClassicQuiz() {
        return classicQuizRepo.findAll();
    }
    @PostMapping(path = "/classicQuiz")
    @ResponseStatus(code = HttpStatus.CREATED)
    public void createClassicQuiz(@RequestBody ClassicQuiz classicQuiz) {
        classicQuiz.setQuizGuid(UUID.randomUUID());
        classicQuizRepo.save(classicQuiz);
    }

    @PutMapping("/classicQuiz/{quizGuid}")
    @ResponseStatus(HttpStatus.OK)
    public void updateClassicQuiz(
            @PathVariable(required = true) UUID quizGuid,
            @RequestBody ClassicQuiz classicQuiz) {

        ClassicQuiz existingQuiz = classicQuizRepo.findById(quizGuid).orElse(null);

        if (existingQuiz == null) {
            throw new RuntimeException("Quiz not found with ID: " + quizGuid);
        }

        existingQuiz.setQuizName(classicQuiz.getQuizName());
        existingQuiz.setCategory(classicQuiz.getCategory());
        existingQuiz.setQuizDescription(classicQuiz.getQuizDescription());
        existingQuiz.setTimer(classicQuiz.getTimer());
        existingQuiz.setAnswerLabel(classicQuiz.getAnswerLabel());
        existingQuiz.setHintHeading(classicQuiz.getHintHeading());
        existingQuiz.setAnswerHeading(classicQuiz.getAnswerHeading());
        existingQuiz.setExtraHeading(classicQuiz.getExtraHeading());
        existingQuiz.setHints(classicQuiz.getHints());
        existingQuiz.setAnswers(classicQuiz.getAnswers());
        existingQuiz.setExtras(classicQuiz.getExtras());
        existingQuiz.setUserGuid(classicQuiz.getUserGuid());

        classicQuizRepo.save(existingQuiz);
    }

    @DeleteMapping(path = "/classicQuiz/{quizGuid}")
    @ResponseStatus(HttpStatus.OK)
    public void DeleteItem(@PathVariable(required = true) UUID quizGuid) {
        classicQuizRepo.deleteById(quizGuid);
    }






}
