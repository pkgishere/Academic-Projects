package com.example.alanr.assignment3;

import android.content.res.AssetManager;
import android.hardware.SensorEventListener;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.content.Context;
import android.hardware.SensorManager;
import android.os.Environment;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.List;

public class MainActivity extends AppCompatActivity implements SensorEventListener{

    final String databaseName="Group2.db";

    String tableName;
    private SensorManager sensorMgr;
    private Sensor sensorAccelerometer;
    DataBase dbClass;
    Long Time_ms;
    Long Last_Time;
    int i=0,count=2,row=0;
    boolean firstTime=true;
    Button MLalgo, reset, DataBasegen, graph;
    TextView Status;
    float acc;
    ImageView img;

    String appFolderPath=Environment.getExternalStorageDirectory().getPath()+"/";

    static
    {
        System.loadLibrary("jnilibsvm");
    }

    @SuppressWarnings("JniMissingFunction")
    private native float jniSvmTrain(String cmd);
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        MLalgo = (Button) findViewById(R.id.MLalgo);
        Status = (TextView) findViewById(R.id.Status);
        reset = (Button) findViewById(R.id.reset);
        DataBasegen = (Button) findViewById(R.id.DataBasegen);
        graph = (Button) findViewById(R.id.Image);
        img = (ImageView) findViewById(R.id.image);



        sensorMgr = (SensorManager) getSystemService(Context.SENSOR_SERVICE);
        sensorAccelerometer = sensorMgr.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);

        tableName = "accelerometerValues";
        dbClass= DataBase.getInstance(MainActivity.this);
        dbClass.createDatabase();
        dbClass.createTable(tableName);




        DataBasegen.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Time_ms = System.currentTimeMillis();
                Last_Time = System.currentTimeMillis();
                sensorMgr.registerListener(MainActivity.this, sensorAccelerometer, 100);
                Toast.makeText(MainActivity.this, "Started Record of Eating",Toast.LENGTH_LONG).show();
                Status.setText("Start Eating");

            }
        });

        MLalgo.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String k="4";
                String svmTrainOptions = "-v "+ k+" ";
                List<String> outputList = new ArrayList<String>();
                outputList=copyAssetsDataIfNeed();
                String modelPath = Environment.getExternalStorageDirectory().getPath() + "/Model2.txt";
                String dataTrainPath = Environment.getExternalStorageDirectory().getPath() + "/Group2.txt";
                acc = jniSvmTrain(svmTrainOptions + dataTrainPath + " " + modelPath);
                Status.setText("K-fold cross-validation with K = " + k + " is used. The Accuracy is " + Float.toString(acc));


            }
        });

        graph.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                img.setVisibility(View.VISIBLE);
                img.setImageResource(R.drawable.capture);

            }
        });

        reset.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Status.setText("");
                img.setVisibility(View.INVISIBLE);
            }
        });

    }
    @Override
    public void onSensorChanged(SensorEvent sensorEvent) {
        Sensor mySensor = sensorEvent.sensor;
        if (mySensor.getType() == Sensor.TYPE_ACCELEROMETER) {

            Time_ms = System.currentTimeMillis();
            if(Time_ms - Last_Time < 100) {return;}
            Last_Time = Time_ms;
            if (i%50==0){
                row++;
                firstTime=true;
            }
            if (i==1000){
                Toast.makeText(this, "Stop Eating and start walking.",Toast.LENGTH_LONG).show();
                Status.setText("Stop Eating and start walking.");
                count=3;
            }
            else
            {
                if (i==1200){
                    Toast.makeText(this, "Record Walking.",Toast.LENGTH_LONG).show();
                    Status.setText("Record Walking.");
                }


                if(i==2000)
                {
                    Toast.makeText(this, "You can stop walking and start running", Toast.LENGTH_LONG).show();
                    Status.setText("You can stop walking and start running");
                    count = 1;
                }
                if(i==2200)
                {
                    Toast.makeText(this, "Record Runing", Toast.LENGTH_LONG).show();
                    Status.setText("Record Runing");
                    count = 1;
                }
            }
            float x = sensorEvent.values[0];
            float y = sensorEvent.values[1];
            float z = sensorEvent.values[2];

            int temp=i%50;
            setData(tableName, x, y, z, count, temp, firstTime,row);
            firstTime=false;
            i++;

            if (i==3000){
                Toast.makeText(this, "DB Gen Completed",Toast.LENGTH_LONG).show();
                Status.setText("DB Gen Completed");
                sensorMgr.unregisterListener(this);
            }

        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        sensorMgr.unregisterListener(this);
    }

    @Override
    protected void onResume() {
        super.onResume();


    }

    @Override
    public void onAccuracyChanged(Sensor sensor, int accuracy) {

    }
    public void setData(String tableName, float xvalue, float yvalue, float zvalue, int label, int temp, boolean firstime, int row) {
        dbClass.setDataBase(tableName, xvalue, yvalue, zvalue, label, temp, firstime, row);
    }

    public List<String> copyAssetsDataIfNeed(){
        String assetsToCopy[] = {"Group2.txt"};
        List<String> arrayList = new ArrayList<String>();
        for(int i=0; i<assetsToCopy.length; i++){
            String from = assetsToCopy[i];
            String to = appFolderPath+from;
            File file = new File(to);
            if(file.exists()){}
            else
            {
                boolean copyResult = copyAsset(getAssets(), from, to);
                arrayList.add(to);
            }
        }
        return arrayList;
    }

    private boolean copyAsset(AssetManager assetManager, String fromAssetPath, String toPath) {
        InputStream in = null;
        OutputStream out = null;
        try
        {
            in = assetManager.open(fromAssetPath);
            new File(toPath).createNewFile();
            out = new FileOutputStream(toPath);
            copyFile(in, out);
            in.close();
            out.flush();
            out.close();

            return true;
        }
        catch(Exception e)
        {
            return false;
        }
    }

    private void copyFile(InputStream in, OutputStream out) throws IOException {
        byte[] buffer = new byte[1024];
        int read;
        while((read = in.read(buffer)) != -1){
            out.write(buffer, 0, read);
        }
    }
}