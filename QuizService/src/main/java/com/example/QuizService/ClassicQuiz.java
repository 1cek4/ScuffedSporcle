package com.example.QuizService;
import com.sun.jdi.event.StepEvent;

import java.util.ArrayList;
import java.util.UUID;



public class ClassicQuiz {


    private UUID quizGuid;
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

    public ClassicQuiz(UUID quizGuid, String quizName, Category category, String quizDescription, String timer, String answerLabel, String hintHeading, String answerHeading, String extraHeading, ArrayList<String> hints, ArrayList<String> answers, ArrayList<String> extras) {
        this.quizGuid = quizGuid;
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
}
