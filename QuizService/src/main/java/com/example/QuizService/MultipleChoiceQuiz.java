package com.example.QuizService;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import java.util.ArrayList;
import java.util.UUID;

@Document(collection = "multipleChoiceQuiz")
public class MultipleChoiceQuiz {
    @Id
    private UUID quizGuid;
    private String quizName;
    private Category category;
    private String quizDescription;
    private String timer;
    private ArrayList<String> hints;
    private ArrayList<ArrayList<String>> answers;

    public MultipleChoiceQuiz() {}

    public UUID getQuizGuid() {
        return quizGuid;
    }

    public void setQuizGuid(UUID quizGuid) {
        this.quizGuid = quizGuid;
    }

    public String getQuizName() {
        return quizName;
    }

    public void setQuizName(String quizName) {
        this.quizName = quizName;
    }

    public Category getCategory() {
        return category;
    }

    public void setCategory(Category category) {
        this.category = category;
    }

    public String getQuizDescription() {
        return quizDescription;
    }

    public void setQuizDescription(String quizDescription) {
        this.quizDescription = quizDescription;
    }

    public String getTimer() {
        return timer;
    }

    public void setTimer(String timer) {
        this.timer = timer;
    }

    public ArrayList<String> getHints() {
        return hints;
    }

    public void setHints(ArrayList<String> hints) {
        this.hints = hints;
    }

    public ArrayList<ArrayList<String>> getAnswers() {
        return answers;
    }

    public void setAnswers(ArrayList<ArrayList<String>> answers) {
        this.answers = answers;
    }
}
