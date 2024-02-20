package com.example.ex1;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;

import androidx.appcompat.app.AppCompatActivity;

public class RelativeActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_relative); // Replace with your XML layout file name

        Button btnDosa = findViewById(R.id.btnDosa);
        Button btnIdly = findViewById(R.id.btnIdly);
        Button btnVada = findViewById(R.id.btnVada);
        Button btnPongal = findViewById(R.id.btnPongal);

        btnDosa.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                // Perform action when Dosa button is clicked
                Intent intent = new Intent(RelativeActivity.this, Dosa.class);
                startActivity(intent);
            }
        });

        btnIdly.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                // Perform action when Idly button is clicked
                Intent intent = new Intent(RelativeActivity.this,Idly.class);
                startActivity(intent);
            }
        });

        btnVada.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                // Perform action when Vada button is clicked
                Intent intent = new Intent(RelativeActivity.this, vada.class);
                startActivity(intent);
            }
        });

        btnPongal.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                // Perform action when Pongal button is clicked
                Intent intent = new Intent(RelativeActivity.this, Pongal.class);
                startActivity(intent);
            }
        });
    }
}
