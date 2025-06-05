package com.example.QuizService;

import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
public class OrderUpQuizService {
    private final OrderUpQuizRepo orderUpQuizRepo;

    public OrderUpQuizService(OrderUpQuizRepo orderUpQuizRepo) {
        this.orderUpQuizRepo = orderUpQuizRepo;
    }

    public OrderUpQuiz createOrderUpQuiz(OrderUpQuiz orderUpQuiz) {
        return orderUpQuizRepo.save(orderUpQuiz);
    }

    public List<OrderUpQuiz> getAllOrderUpQuizzes() {
        return orderUpQuizRepo.findAll();
    }

    public Optional<OrderUpQuiz> getOrderUpQuizById(UUID quizGuid) {
        return orderUpQuizRepo.findById(quizGuid);
    }

    public Optional<OrderUpQuiz> updateOrderUpQuiz(UUID quizGuid, OrderUpQuiz updatedQuiz) {
        return orderUpQuizRepo.findById(quizGuid).map(existingQuiz -> {
            existingQuiz.setQuizName(updatedQuiz.getQuizName());
            existingQuiz.setCategory(updatedQuiz.getCategory());
            existingQuiz.setQuizDescription(updatedQuiz.getQuizDescription());
            existingQuiz.setTimer(updatedQuiz.getTimer());
            existingQuiz.setHintHeading(updatedQuiz.getHintHeading());
            existingQuiz.setAnswerHeading(updatedQuiz.getAnswerHeading());
            existingQuiz.setHints(updatedQuiz.getHints());
            existingQuiz.setAnswers(updatedQuiz.getAnswers());
            existingQuiz.setNumberOfGuesses(updatedQuiz.getNumberOfGuesses()); 
            return orderUpQuizRepo.save(existingQuiz);
        });
    }

    public boolean deleteOrderUpQuiz(UUID quizGuid) {
        if (orderUpQuizRepo.existsById(quizGuid)) {
            orderUpQuizRepo.deleteById(quizGuid);
            return true;
        }
        return false;
    }
}