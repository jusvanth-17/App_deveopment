package com.example.ex1;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import androidx.appcompat.app.AppCompatActivity;

public class Pongal extends AppCompatActivity {

    private Button btn3;
    private Intent intent3;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_pongal);

        btn3 = findViewById(R.id.btnPongal);
        btn3.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                intent3 = new Intent(getApplicationContext(), TableActivity.class);
                startActivity(intent3);
                finish();
            }
        });
    }
}
