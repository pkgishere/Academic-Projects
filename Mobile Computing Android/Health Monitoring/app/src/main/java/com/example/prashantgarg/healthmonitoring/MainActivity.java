package com.example.prashantgarg.healthmonitoring;


import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.database.sqlite.SQLiteDatabase;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.os.Message;
import android.os.PowerManager;
import android.support.v7.app.AppCompatActivity;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.RadioButton;
import android.widget.RelativeLayout;
import android.widget.Toast;
import java.io.DataOutputStream;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URL;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;

import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;


import static java.lang.Math.abs;


/**
 * Created by Prashant garg on 01-03-2017.
 */

public class MainActivity extends AppCompatActivity {
    GraphView graphView;
    Handler threadHandle = new Handler();
    boolean buttonAlreadyClicked = false;
    boolean uploadButtonPress = false;
    boolean downloadButtonPress = false;
    float[] values = new float[50];
    SQLiteDatabase sqdb;
    private final String DataBase_File = "Group2.db";
    private final String DataBASE = "/data/data/com.example.prashantgarg.healthmonitoring/databases/"+DataBase_File;

    EditText id,name,age;
    RadioButton rb_Male,rb_Female;
    DataBase handler;
    Boolean serviceBound = false;
    AccelerometerService accelerometerService;
    Intent serviceIntent;
    ServiceConnection serve;
    Context ctx=this;
    Button runButton,stopButton,uploadButton,downloadButton;
    String String_name,String_age,String_id,String_sex,tablename;
    int flag_run=0;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        String[] ver = {"60","50","40","30","20","10"};
        String[] hor=  {"1","2","3","4","5","6","7","8","9","10"};
        String Head = "Health Monitoring";

        float[] values = new float[10];
        runButton = (Button) findViewById(R.id.run);
        stopButton = (Button) findViewById(R.id.stop);
        uploadButton = (Button) findViewById(R.id.upload);
        downloadButton = (Button) findViewById(R.id.download);
        id = (EditText) findViewById(R.id.IDBox);
        age = (EditText) findViewById(R.id.AgeBox);
        name = (EditText) findViewById(R.id.nameBox);
        rb_Male = (RadioButton) findViewById(R.id.Male);
        rb_Female = (RadioButton) findViewById(R.id.female);

        graphView = new GraphView(MainActivity.this,values,values,values,Head,hor,ver,true);
        RelativeLayout relativeLayout = (RelativeLayout) findViewById(R.id.graphLayout);
        RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.WRAP_CONTENT, RelativeLayout.LayoutParams.MATCH_PARENT);
        layoutParams.addRule(relativeLayout.BELOW, R.id.activity_main);
        relativeLayout.addView(graphView, layoutParams);


        final Handler handler2;

        handler2 = new Handler() {
            @Override
            public void handleMessage(Message msg) {
                //msg.arg1
                float xvalue = msg.getData().getFloat("xvalue");
                float yvalue = msg.getData().getFloat("yvalue");
                float zvalue = msg.getData().getFloat("zvalue");
                Date date = new java.util.Date();
                if(serviceBound){
                    handler.insertion(tablename, new Timestamp(date.getTime()), abs(xvalue),abs(yvalue), abs(zvalue));
                }
            }
        };
        stopButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                clearGraph();
                if(serviceBound) {
                    unbindService(serve);
                    serviceBound = false;
                }
                if(flag_run==1){
                    Toast.makeText(MainActivity.this, "Service Stop Request Executed", Toast.LENGTH_SHORT).show();
                    flag_run=0;
                }
            }
        });

        uploadButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                stopButton.callOnClick();
                Uploadtask();
            }
        });

        downloadButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                stopButton.callOnClick();
                Downloadtask();
            }
        });

        runButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(id.getText().toString().isEmpty() || name.getText().toString().isEmpty()
                        || age.getText().toString().isEmpty()) {

                    Toast.makeText(MainActivity.this, "Empty Fields", Toast.LENGTH_SHORT).show();
                }
                else {
                    if (buttonAlreadyClicked == false) {
                        buttonAlreadyClicked = true;
                        serviceBound = true;
                        handler = new DataBase(MainActivity.this);
                        handler.createDatabase();
                        if (rb_Male.isChecked()) {
                            String_sex = "MALE";
                        } else {
                            String_sex = "FEMALE";
                        }
                        String_name = name.getText().toString().toUpperCase().replace(' ', '_');
                        String_id = id.getText().toString().toUpperCase();
                        String_age = age.getText().toString().toUpperCase();
                        tablename = String_name + "_" + String_id + "_"  + String_age + "_" + String_sex;
                        handler.createTable(tablename);


                        serviceIntent = new Intent(MainActivity.this.getBaseContext(),AccelerometerService.class);
                        startService(serviceIntent);
                        serve = new ServiceConnection() {
                            @Override
                            public void onServiceConnected(ComponentName name, IBinder service) {
                                accelerometerService =((AccelerometerService.LocalBinder)service).getInstance();
                                accelerometerService.setHandler(handler2);
                            }

                            @Override
                            public void onServiceDisconnected(ComponentName name) {

                            }
                        };
                        bindService(serviceIntent, serve, Context.BIND_AUTO_CREATE);
                        flag_run=1;
                        Graph();
                    }
                }
            }});


    }

    public void Graph() {
        final Thread graphPlotterThread = new Thread(new Runnable() {
            @Override
            public void run() {
                while (buttonAlreadyClicked == true) {
                    ArrayList<float[]>values=handler.getinput(tablename);
                    float[] X = values.get(0);
                    float[] Y = values.get(1);
                    float[] Z = values.get(2);
                    graphView.setValues(X, Y, Z);
                    try {
                        Thread.sleep(1000);
                    } catch (Exception e) {
                    }
                    threadHandle.post(new Runnable() {
                        @Override
                        public void run() {
                            graphView.invalidate();
                        }
                    });

                }
            }
        });
        graphPlotterThread.start();
    }

    public void clearGraph() {
        if (buttonAlreadyClicked == true) {
            buttonAlreadyClicked = false;
            float[] xArray = new float[10];
            Arrays.fill(xArray, 0);
            float[] yArray = new float[10];
            Arrays.fill(yArray, 0);
            float[] zArray = new float[10];
            Arrays.fill(zArray, 0);
            graphView.setValues(xArray, yArray, zArray);
            graphView.invalidate();
            EditText et = (EditText) findViewById(R.id.IDBox);
            EditText et1 = (EditText)findViewById(R.id.AgeBox);
            EditText et2 = (EditText) findViewById(R.id.nameBox);
        }
    }

    private void Uploadtask(){

        final MainActivity.UploadTask uploadTask = new MainActivity.UploadTask(MainActivity.this);
        uploadTask.execute("https://impact.asu.edu/CSE535Spring17Folder/UploadToServer.php");
        uploadButtonPress = true;

    }

    private void Downloadtask() {
        final MainActivity.DownloadTask DownloadTask = new MainActivity.DownloadTask(MainActivity.this);
        DownloadTask.execute("https://impact.asu.edu/CSE535Spring17Folder/" + DataBase_File);
        downloadButtonPress = true;
    }




    private class DownloadTask extends AsyncTask<String, Integer, String> {

        private Context context;
        private PowerManager.WakeLock mWakeLock;

        public DownloadTask(Context context) {
            this.context = context;
        }

        @Override
        protected String doInBackground(String... sUrl) {
            String responseString = null;

            InputStream input = null;
            OutputStream output = null;
            HttpsURLConnection connection = null;

            TrustManager[] trustAllCerts = new TrustManager[] { new X509TrustManager() {
                public X509Certificate[] getAcceptedIssuers() {
                    return null;
                }

                @Override
                public void checkClientTrusted(X509Certificate[] arg0, String arg1) throws CertificateException {
                }

                @Override
                public void checkServerTrusted(X509Certificate[] arg0, String arg1) throws CertificateException {

                }
            } };

            try {
                SSLContext sc = SSLContext.getInstance("TLS");

                sc.init(null, trustAllCerts, new java.security.SecureRandom());

                HttpsURLConnection.setDefaultSSLSocketFactory(sc.getSocketFactory());
            } catch (Exception e) {

            }

            try {
                URL url = new URL(sUrl[0]);
                connection = (HttpsURLConnection) url.openConnection();
                connection.connect();
                if (connection.getResponseCode() != HttpsURLConnection.HTTP_OK) {
                    return "Server returned HTTP " + connection.getResponseCode()
                            + " " + connection.getResponseMessage();
                }
                int fileLength = connection.getContentLength();
                input = connection.getInputStream();
                output = new FileOutputStream(DataBASE);

                byte data[] = new byte[4096];
                long total = 0;
                int count;
                while ((count = input.read(data)) != -1) {
                    if (isCancelled()) {
                        input.close();
                        return null;
                    }
                    total += count;

                    if (fileLength > 0)
                        publishProgress((int) (total * 100 / fileLength));
                    output.write(data, 0, count);
                }
            } catch (Exception e) {
            } finally {
                try {
                    if (output != null)
                        output.close();
                    if (input != null)
                        input.close();
                } catch (Exception e) {
                }

                if (connection != null)
                    connection.disconnect();
            }
            return responseString;
        }

        @Override
        protected void onPreExecute() {
            super.onPreExecute();
            PowerManager pm = (PowerManager) context.getSystemService(Context.POWER_SERVICE);
            mWakeLock = pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK,
                    getClass().getName());
            mWakeLock.acquire();
        }

        @Override
        protected void onProgressUpdate(Integer... progress) {
            super.onProgressUpdate(progress);
        }

        @Override
        protected void onPostExecute(String result) {
            mWakeLock.release();
            if (result != null) {
                Toast.makeText(context, "Download error: " + result, Toast.LENGTH_LONG).show();


            } else {
                Toast.makeText(context, "Downloaded", Toast.LENGTH_SHORT).show();

                if (downloadButtonPress) {
                    downloadButtonPress = false;
                }
            }

            Graph();
        }

        private void Graph() {
            graphStaticPlotterThread.start();
        }

        final Thread graphStaticPlotterThread = new Thread(new Runnable() {
            @Override
            public void run() {
                ArrayList<float[]>storedVals=handler.getinput(tablename);
                float[] X = storedVals.get(0);
                float[] Y = storedVals.get(1);
                float[] Z = storedVals.get(2);
                graphView.setValues(X, Y, Z);
                threadHandle.post(new Runnable() {
                    @Override
                    public void run() {
                        graphView.invalidate();
                    }
                });
            }
        });
    }


    // Upload

    private class UploadTask extends AsyncTask<String, Integer, String> {

        private Context context;
        private PowerManager.WakeLock mWakeLock;

        public UploadTask(Context context) {
            this.context = context;
        }

        @Override
        protected String doInBackground(String... sUrl) {
            FileInputStream input = null;
            DataOutputStream output = null;
            HttpsURLConnection connection = null;
            String responseString = null;

            String URLBoundary = "***";

            TrustManager[] trustAllCerts = new TrustManager[] { new X509TrustManager() {
                public X509Certificate[] getAcceptedIssuers() {
                    return null;
                }

                @Override
                public void checkClientTrusted(X509Certificate[] arg0, String arg1) throws CertificateException {
                }

                @Override
                public void checkServerTrusted(X509Certificate[] arg0, String arg1) throws CertificateException {
                }
            } };

            try {
                SSLContext sc = SSLContext.getInstance("TLS");
                sc.init(null, trustAllCerts, new java.security.SecureRandom());
                HttpsURLConnection.setDefaultSSLSocketFactory(sc.getSocketFactory());
            }
            catch (Exception e) { }

            try {
                URL url = new URL(sUrl[0]);
                connection = (HttpsURLConnection) url.openConnection();
                connection.setDoInput(true);
                connection.setDoOutput(true);
                connection.setUseCaches(false);
                connection.setRequestMethod("POST");
                connection.setRequestProperty("Connection", "Keep-Alive");
                connection.setRequestProperty("ENCTYPE", "multipart/form-data");
                connection.setRequestProperty("Content-Type", "multipart/form-data;boundary=" + URLBoundary);
                connection.setRequestProperty("uploaded_file", DataBase_File);

                input = new FileInputStream(DataBASE);
                output = new DataOutputStream(connection.getOutputStream());

                output.writeBytes("--" + "***" + "\r\n");
                output.writeBytes("Content-Disposition: form-data; name=\"uploaded_file\";filename=\""
                        + DataBase_File + "\"" + "\r\n");
                output.writeBytes("\r\n");


                byte data[] = new byte[4096];


                while (0 < input.read(data, 0, 4096)) {

                    if (isCancelled()) {
                        input.close();
                        return null;
                    }
                    output.write(data, 0, 4096);
                }

                output.writeBytes("\r\n");
                output.writeBytes("--" + "***" + "--" + "\r\n");

                int responseCode = connection.getResponseCode();
                String responseMessage = connection.getResponseMessage();


                if(200 != responseCode) {
                    responseString =  responseMessage;
                }

            } catch (Exception e) { }
            finally {
                try {
                    if (output != null)
                        output.close();
                    if (input != null)
                        input.close();
                } catch (Exception e) {
                }

            }
            return responseString;
        }

        @Override
        protected void onPreExecute() {
            super.onPreExecute();
            PowerManager pm = (PowerManager) context.getSystemService(Context.POWER_SERVICE);
            mWakeLock = pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK,
                    getClass().getName());
            mWakeLock.acquire();
        }

        @Override
        protected void onProgressUpdate(Integer... progress) {
            super.onProgressUpdate(progress);
        }

        @Override
        protected void onPostExecute(String result) {
            mWakeLock.release();
            if (result != null){
                Toast.makeText(context,"Upload error: "+result, Toast.LENGTH_LONG).show();


            }else{
                Toast.makeText(context,"Uploaded", Toast.LENGTH_SHORT).show();

                if(uploadButtonPress){
                    uploadButtonPress = false;
                }
            }
        }
    }
}

