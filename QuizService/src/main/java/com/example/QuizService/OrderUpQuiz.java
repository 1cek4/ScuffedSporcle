package com.example.QuizService;
import java.util.ArrayList;
import java.util.UUID;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
@Document(collection = "orderUpQuiz")
public class OrderUpQuiz {
    @Id
    private UUID quizGuid;
    private String quizName;
    private Category category;
    private String quizDescription;
    private String timer;
    private String hintHeading;
    private String answerHeading;
    private ArrayList<String> hints;
    private ArrayList<String> answers;
    private int numberOfGuesses; 

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

    public String getHintHeading() {
        return hintHeading;
    }

    public void setHintHeading(String hintHeading) {
        this.hintHeading = hintHeading;
    }

    public String getAnswerHeading() {
        return answerHeading;
    }

    public void setAnswerHeading(String answerHeading) {
        this.answerHeading = answerHeading;
    }

    public ArrayList<String> getHints() {
        return hints;
    }

    public void setHints(ArrayList<String> hints) {
        this.hints = hints;
    }

    public ArrayList<String> getAnswers() {
        return answers;
    }

    public void setAnswers(ArrayList<String> answers) {
        this.answers = answers;
    }


    public int getNumberOfGuesses() {
        return numberOfGuesses;
    }

    public void setNumberOfGuesses(int numberOfGuesses) {
        this.numberOfGuesses = numberOfGuesses;
    }
}
