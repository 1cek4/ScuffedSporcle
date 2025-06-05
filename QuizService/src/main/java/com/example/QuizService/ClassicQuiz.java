package com.example.QuizService;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import java.util.ArrayList;
import java.util.UUID;

@Document(collection = "classicQuiz")
public class ClassicQuiz {

    @Id
    private UUID quizGuid;
    private UUID userGuid;
    private String quizName;
    private Category category;
    private String quizDescription;
    private String timer;
    private String answerLabel;
    private String hintHeading;
    private String answerHeading;
    private String extraHeading;
    private ArrayList<String> hints;
    private ArrayList<String> answers;
    private ArrayList<String> extras;

    public ClassicQuiz() {}

    public ClassicQuiz(
        UUID quizGuid,
        UUID userGuid,
        String quizName,
        Category category,
        String quizDescription,
        String timer,
        String answerLabel,
        String hintHeading,
        String answerHeading,
        String extraHeading,
        ArrayList<String> hints,
        ArrayList<String> answers,
        ArrayList<String> extras
    ) {
        this.quizGuid = quizGuid;
        this.userGuid = userGuid;
        this.quizName = quizName;
        this.category = category;
        this.quizDescription = quizDescription;
        this.timer = timer;
        this.answerLabel = answerLabel;
        this.hintHeading = hintHeading;
        this.answerHeading = answerHeading;
        this.extraHeading = extraHeading;
        this.hints = hints;
        this.answers = answers;
        this.extras = extras;
    }

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

    public String getAnswerLabel() {
        return answerLabel;
    }

    public void setAnswerLabel(String answerLabel) {
        this.answerLabel = answerLabel;
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

    public String getExtraHeading() {
        return extraHeading;
    }

    public void setExtraHeading(String extraHeading) {
        this.extraHeading = extraHeading;
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

    public ArrayList<String> getExtras() {
        return extras;
    }

    public void setExtras(ArrayList<String> extras) {
        this.extras = extras;
    }

    public UUID getUserGuid() {
        return userGuid;
    }

    public void setUserGuid(UUID userGuid) {
        this.userGuid = userGuid;
    }
}
