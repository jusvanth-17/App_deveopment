package com.example.ex1;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import androidx.appcompat.app.AppCompatActivity; // Import AppCompatActivity

public class Idly extends AppCompatActivity { // Extend AppCompatActivity
   Button btn1;
    @SuppressLint("WrongViewCast")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_idly);

        btn1 = (Button) findViewById(R.id.btnidly);
        btn1.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(getApplicationContext(), TableActivity.class);
                startActivity(intent);
                finish();
            }
        });
    }
}
