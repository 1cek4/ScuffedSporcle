package com.example.QuizService;
import org.springframework.data.annotation.Id;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
public class ClassicQuizService {
    private final ClassicQuizRepo classicQuizRepo;

    public ClassicQuizService( ClassicQuizRepo classicQuizRepo) {
        this.classicQuizRepo = classicQuizRepo;
    }

    public ClassicQuiz createClassicQuiz(ClassicQuiz classicQuiz) {
        return classicQuizRepo.save(classicQuiz);
    }

    public List<ClassicQuiz> getAllClassicQuizs() {
        return classicQuizRepo.findAll();
    }

    public Optional<ClassicQuiz> getClassicQuizById(UUID classicQuizGuid) {
        return classicQuizRepo.findById(classicQuizGuid);
    }

    public Optional<ClassicQuiz> updateClassicQuiz(UUID classicQuizGuid, ClassicQuiz updatedClassicQuiz) {
        return classicQuizRepo.findById(classicQuizGuid).map(existingClassicQuiz -> {
            existingClassicQuiz.setQuizName(updatedClassicQuiz.getQuizName());
            existingClassicQuiz.setCategory(updatedClassicQuiz.getCategory());
            existingClassicQuiz.setQuizDescription(updatedClassicQuiz.getQuizDescription());
            existingClassicQuiz.setTimer(updatedClassicQuiz.getTimer());
            existingClassicQuiz.setAnswerLabel(updatedClassicQuiz.getAnswerLabel());
            existingClassicQuiz.setHintHeading(updatedClassicQuiz.getHintHeading());
            existingClassicQuiz.setAnswerHeading(updatedClassicQuiz.getAnswerHeading());
            existingClassicQuiz.setExtraHeading(updatedClassicQuiz.getExtraHeading());
            existingClassicQuiz.setHints(updatedClassicQuiz.getHints());
            existingClassicQuiz.setAnswers(updatedClassicQuiz.getAnswers());
            existingClassicQuiz.setExtras(updatedClassicQuiz.getExtras());
            return classicQuizRepo.save(existingClassicQuiz);
        });
    }

    public boolean deleteClassicQuiz(UUID id) {
        if (classicQuizRepo.existsById(id)) {
            classicQuizRepo.deleteById(id);
            return true;
        }
        return false;
    }
}
