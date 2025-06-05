package com.example.QuizService;

import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
public class MultipleChoiceQuizService {
    private final MultipleChoiceQuizRepo multipleChoiceQuizRepo;

    public MultipleChoiceQuizService(MultipleChoiceQuizRepo multipleChoiceQuizRepo) {
        this.multipleChoiceQuizRepo = multipleChoiceQuizRepo;
    }

    public MultipleChoiceQuiz createMultipleChoiceQuiz(MultipleChoiceQuiz multipleChoiceQuiz) {
        return multipleChoiceQuizRepo.save(multipleChoiceQuiz);
    }

    public List<MultipleChoiceQuiz> getAllMultipleChoiceQuizzes() {
        return multipleChoiceQuizRepo.findAll();
    }

    public Optional<MultipleChoiceQuiz> getMultipleChoiceQuizById(UUID quizGuid) {
        return multipleChoiceQuizRepo.findById(quizGuid);
    }

    public Optional<MultipleChoiceQuiz> updateMultipleChoiceQuiz(UUID quizGuid, MultipleChoiceQuiz updatedQuiz) {
        return multipleChoiceQuizRepo.findById(quizGuid).map(existingQuiz -> {
            existingQuiz.setQuizName(updatedQuiz.getQuizName());
            existingQuiz.setCategory(updatedQuiz.getCategory());
            existingQuiz.setQuizDescription(updatedQuiz.getQuizDescription());
            existingQuiz.setTimer(updatedQuiz.getTimer());
            existingQuiz.setHints(updatedQuiz.getHints());
            existingQuiz.setAnswers(updatedQuiz.getAnswers());
            return multipleChoiceQuizRepo.save(existingQuiz);
        });
    }

    public boolean deleteMultipleChoiceQuiz(UUID quizGuid) {
        if (multipleChoiceQuizRepo.existsById(quizGuid)) {
            multipleChoiceQuizRepo.deleteById(quizGuid);
            return true;
        }
        return false;
    }
}