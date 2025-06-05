package com.example.QuizService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("")
public class QuizRestController {
    private final ClassicQuizRepo classicQuizRepo;
    private final ClickableQuizRepo clickableQuizRepo;
    private final MultipleChoiceQuizRepo multipleChoiceQuizRepo; 
    private final OrderUpQuizRepo orderUpQuizRepo;

    @Autowired
    public QuizRestController(
            ClassicQuizRepo classicQuizRepo,
            ClickableQuizRepo clickableQuizRepo,
            MultipleChoiceQuizRepo multipleChoiceQuizRepo, 
            OrderUpQuizRepo orderUpQuizRepo) {
        this.classicQuizRepo = classicQuizRepo;
        this.clickableQuizRepo = clickableQuizRepo;
        this.multipleChoiceQuizRepo = multipleChoiceQuizRepo; 
        this.orderUpQuizRepo = orderUpQuizRepo;
    }

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


    @GetMapping(path = "/clickableQuiz")
    @ResponseStatus(code = HttpStatus.OK)
    public List<ClickableQuiz> findAllClickableQuiz() {
        return clickableQuizRepo.findAll();
    }

    @PostMapping(path = "/clickableQuiz")
    @ResponseStatus(code = HttpStatus.CREATED)
    public void createClickableQuiz(@RequestBody ClickableQuiz clickableQuiz) {
        clickableQuiz.setQuizGuid(UUID.randomUUID());
        clickableQuizRepo.save(clickableQuiz);
    }

    @PutMapping("/clickableQuiz/{quizGuid}")
    @ResponseStatus(HttpStatus.OK)
    public void updateClickableQuiz(
            @PathVariable(required = true) UUID quizGuid,
            @RequestBody ClickableQuiz clickableQuiz) {

        ClickableQuiz existingQuiz = clickableQuizRepo.findById(quizGuid).orElse(null);

        if (existingQuiz == null) {
            throw new RuntimeException("Quiz not found with ID: " + quizGuid);
        }

        existingQuiz.setQuizName(clickableQuiz.getQuizName());
        existingQuiz.setCategory(clickableQuiz.getCategory());
        existingQuiz.setQuizDescription(clickableQuiz.getQuizDescription());
        existingQuiz.setTimer(clickableQuiz.getTimer());
        existingQuiz.setHints(clickableQuiz.getHints());
        existingQuiz.setAnswers(clickableQuiz.getAnswers());

        clickableQuizRepo.save(existingQuiz);
    }

    @DeleteMapping(path = "/clickableQuiz/{quizGuid}")
    @ResponseStatus(HttpStatus.OK)
    public void deleteClickableQuiz(@PathVariable(required = true) UUID quizGuid) {
        clickableQuizRepo.deleteById(quizGuid);
    }

    @GetMapping(path = "/multipleChoiceQuiz")
    @ResponseStatus(code = HttpStatus.OK)
    public List<MultipleChoiceQuiz> findAllMultipleChoiceQuiz() {
        return multipleChoiceQuizRepo.findAll();
    }

    @PostMapping(path = "/multipleChoiceQuiz")
    @ResponseStatus(code = HttpStatus.CREATED)
    public void createMultipleChoiceQuiz(@RequestBody MultipleChoiceQuiz multipleChoiceQuiz) {
        multipleChoiceQuiz.setQuizGuid(UUID.randomUUID());
        multipleChoiceQuizRepo.save(multipleChoiceQuiz);
    }

    @PutMapping("/multipleChoiceQuiz/{quizGuid}")
    @ResponseStatus(HttpStatus.OK)
    public void updateMultipleChoiceQuiz(
            @PathVariable(required = true) UUID quizGuid,
            @RequestBody MultipleChoiceQuiz multipleChoiceQuiz) {

        MultipleChoiceQuiz existingQuiz = multipleChoiceQuizRepo.findById(quizGuid).orElse(null);

        if (existingQuiz == null) {
            throw new RuntimeException("Quiz not found with ID: " + quizGuid);
        }

        existingQuiz.setQuizName(multipleChoiceQuiz.getQuizName());
        existingQuiz.setCategory(multipleChoiceQuiz.getCategory());
        existingQuiz.setQuizDescription(multipleChoiceQuiz.getQuizDescription());
        existingQuiz.setTimer(multipleChoiceQuiz.getTimer());
        existingQuiz.setHints(multipleChoiceQuiz.getHints());
        existingQuiz.setAnswers(multipleChoiceQuiz.getAnswers());

        multipleChoiceQuizRepo.save(existingQuiz);
    }

    @DeleteMapping(path = "/multipleChoiceQuiz/{quizGuid}")
    @ResponseStatus(HttpStatus.OK)
    public void deleteMultipleChoiceQuiz(@PathVariable(required = true) UUID quizGuid) {
        multipleChoiceQuizRepo.deleteById(quizGuid);
    }

    @GetMapping(path = "/orderUpQuiz")
    @ResponseStatus(code = HttpStatus.OK)
    public List<OrderUpQuiz> findAllOrderUpQuiz() {
        return orderUpQuizRepo.findAll();
    }

    @PostMapping(path = "/orderUpQuiz")
    @ResponseStatus(code = HttpStatus.CREATED)
    public void createOrderUpQuiz(@RequestBody OrderUpQuiz orderUpQuiz) {
        orderUpQuiz.setQuizGuid(UUID.randomUUID());
        orderUpQuizRepo.save(orderUpQuiz);
    }

    @PutMapping("/orderUpQuiz/{quizGuid}")
    @ResponseStatus(HttpStatus.OK)
    public void updateOrderUpQuiz(
            @PathVariable(required = true) UUID quizGuid,
            @RequestBody OrderUpQuiz orderUpQuiz) {

        OrderUpQuiz existingQuiz = orderUpQuizRepo.findById(quizGuid).orElse(null);
        if (existingQuiz == null) {
            throw new RuntimeException("Quiz not found with ID: " + quizGuid);
        }

        existingQuiz.setQuizName(orderUpQuiz.getQuizName());
        existingQuiz.setCategory(orderUpQuiz.getCategory());
        existingQuiz.setQuizDescription(orderUpQuiz.getQuizDescription());
        existingQuiz.setTimer(orderUpQuiz.getTimer());
        existingQuiz.setHintHeading(orderUpQuiz.getHintHeading());
        existingQuiz.setAnswerHeading(orderUpQuiz.getAnswerHeading());
        existingQuiz.setHints(orderUpQuiz.getHints());
        existingQuiz.setAnswers(orderUpQuiz.getAnswers());

        orderUpQuizRepo.save(existingQuiz);
    }

    @DeleteMapping(path = "/orderUpQuiz/{quizGuid}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteOrderUpQuiz(@PathVariable(required = true) UUID quizGuid) {
        orderUpQuizRepo.deleteById(quizGuid);
    }
}
