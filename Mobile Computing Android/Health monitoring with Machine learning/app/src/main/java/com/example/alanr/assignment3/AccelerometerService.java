package com.example.alanr.assignment3;


import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.Binder;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.os.Message;

/**
 * Created by Prashant garg on 01-03-2017.
 */

public class AccelerometerService extends Service implements SensorEventListener {


        public final IBinder localBinder = new LocalBinder();
        public Handler handler;
        private Sensor sensor;
        private SensorManager sensorManager;
        long prevtime;
        private long sensorTime;
        static int TIME = 600;

        public AccelerometerService(){

        }

        @Override
        public void onSensorChanged(SensorEvent event) {

            if ((System.currentTimeMillis() - prevtime) > TIME && handler !=null ) {
                prevtime = System.currentTimeMillis();
                float x = event.values[0];
                float y = event.values[1];
                float z = event.values[2];

                Message msg = handler.obtainMessage();
                Bundle b = new Bundle();

                b.putString("timestamp", String.valueOf(prevtime));
                b.putFloat("xvalue", x);
                b.putFloat("yvalue", y);
                b.putFloat("zvalue",z);
                msg.setData(b);
                handler.sendMessage(msg);
            }
        }

        @Override
        public IBinder onBind(Intent intent) {
            return localBinder;
        }

        @Override
        public void onAccuracyChanged(Sensor sensor, int accuracy) {

        }

        public class LocalBinder extends Binder
        {
            public AccelerometerService getInstance(){return AccelerometerService.this;}
        }

        public void onCreate() {
            prevtime = System.currentTimeMillis();
            sensorManager = (SensorManager)  getSystemService(Context.SENSOR_SERVICE);
            sensor  = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
            sensorManager.registerListener((SensorEventListener) this, sensor, 1000000);
            sensorTime = System.currentTimeMillis();
        }

        public void setHandler(Handler handler){this.handler = handler;}
}

