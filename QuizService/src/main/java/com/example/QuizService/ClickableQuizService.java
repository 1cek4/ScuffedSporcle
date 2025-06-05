package com.example.QuizService;

import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
public class ClickableQuizService {
    private final ClickableQuizRepo clickableQuizRepo;

    public ClickableQuizService(ClickableQuizRepo clickableQuizRepo) {
        this.clickableQuizRepo = clickableQuizRepo;
    }

    public ClickableQuiz createClickableQuiz(ClickableQuiz clickableQuiz) {
        return clickableQuizRepo.save(clickableQuiz);
    }

    public List<ClickableQuiz> getAllClickableQuizzes() {
        return clickableQuizRepo.findAll();
    }

    public Optional<ClickableQuiz> getClickableQuizById(UUID quizGuid) {
        return clickableQuizRepo.findById(quizGuid);
    }

    public Optional<ClickableQuiz> updateClickableQuiz(UUID quizGuid, ClickableQuiz updatedClickableQuiz) {
        return clickableQuizRepo.findById(quizGuid).map(existingQuiz -> {
            existingQuiz.setQuizName(updatedClickableQuiz.getQuizName());
            existingQuiz.setCategory(updatedClickableQuiz.getCategory());
            existingQuiz.setQuizDescription(updatedClickableQuiz.getQuizDescription());
            existingQuiz.setTimer(updatedClickableQuiz.getTimer());
            existingQuiz.setHints(updatedClickableQuiz.getHints());
            existingQuiz.setAnswers(updatedClickableQuiz.getAnswers());
            return clickableQuizRepo.save(existingQuiz);
        });
    }

    public boolean deleteClickableQuiz(UUID quizGuid) {
        if (clickableQuizRepo.existsById(quizGuid)) {
            clickableQuizRepo.deleteById(quizGuid);
            return true;
        }
        return false;
    }
}