package com.example.ex1;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;

import androidx.appcompat.app.AppCompatActivity;


    public class vada extends AppCompatActivity {

        private Button btn5;
        private Intent intent5;

        @Override
        protected void onCreate(Bundle savedInstanceState) {
            super.onCreate(savedInstanceState);
            setContentView(R.layout.activity_pongal);

            btn5= findViewById(R.id.btnPongal);
            btn5.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    intent5= new Intent(getApplicationContext(), TableActivity.class);
                    startActivity(intent5);
                    finish();
                }
            });
    }

    }

