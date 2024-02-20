package com.example.ex1;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;

import androidx.appcompat.app.AppCompatActivity;

public class Dosa extends AppCompatActivity {
    private Button btn2;
    private Intent intent2;

    @SuppressLint("MissingInflatedId")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_dosa);

        btn2 = (Button) findViewById(R.id.btndosa);
        btn2.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                intent2 = new Intent(getApplicationContext(),TableActivity.class);
                startActivity(intent2);
                finish();
            }
        });
    }
}