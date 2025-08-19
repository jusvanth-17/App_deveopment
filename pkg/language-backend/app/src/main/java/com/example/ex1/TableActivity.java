package com.example.ex1;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

public class TableActivity extends AppCompatActivity {

    private Button btn4;
    private Intent intent4;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_table);

        btn4 = (Button) findViewById(R.id.btnidly);
        btn4.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                intent4 = new Intent(getApplicationContext(),ConstraintActivity.class);
                startActivity(intent4);
                finish();


                Toast.makeText(TableActivity.this, "Ordered Successful", Toast.LENGTH_SHORT).show();
            }
        });

    }
}