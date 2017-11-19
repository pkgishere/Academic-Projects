package com.example.alanr.assignment3;


import android.content.ContentValues;
import java.sql.Timestamp;
import java.util.ArrayList;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.os.Environment;
import android.content.Context;
import android.database.Cursor;

/**
 * Created by Prashant garg on 01-03-2017.
 */

public class DataBase extends SQLiteOpenHelper
{

        SQLiteDatabase sqdb;
        private Context context;
        private static volatile DataBase flag;



        private static final String DataBase_Name = "Group2.db";
        private static final int DATABASE_VERSION = 1;
        private static final String DATABASE_PATH = Environment.getExternalStorageDirectory().getPath() + "/";


        private static final String X_Value = "X_Value";
        private static final String Y_Value = "Y_Value";
        private static final String Z_Value = "Z_Value";




        @Override
        public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion)
        {
            sqdb = getWritableDatabase();
        }

        public static DataBase getInstance(Context context)
        {
            if(flag == null)
            {
                flag = new DataBase(context);
            }
            return flag;
        }

        public DataBase(Context context)
        {

            super(context, DATABASE_PATH+DataBase_Name, null, DATABASE_VERSION);
            this.context = context;
        }


        @Override
        public void onCreate(SQLiteDatabase sqdb){}

        public void createDatabase()
        {
            String database = DATABASE_PATH + DataBase_Name;
            try
            {
                sqdb = SQLiteDatabase.openOrCreateDatabase(database, null);
            }
            catch (Exception e) {}
        }

        public void createTable(String name)
        {
            sqdb = getWritableDatabase();
            try
            {
                sqdb.execSQL("drop table if exists ["+name+"]");
                sqdb.execSQL("create table if not exists ["+name+"] ("
                        + "AccelX0 float, "
                        +"AccelY0 float, "
                        +"AccelZ0 float);" );
                for (int i=1;i<50;i++){
                    sqdb.execSQL("ALTER TABLE ["+name+"] ADD AccelX"+i+" float;");
                    sqdb.execSQL("ALTER TABLE ["+name+"] ADD AccelY"+i+" float;");
                    sqdb.execSQL("ALTER TABLE ["+name+"] ADD AccelZ"+i+" float;");
                }
                sqdb.execSQL("ALTER TABLE ["+name+"] ADD ActivityLabel int;");
            }catch (Exception e){
            }
        }

    public void setDataBase(String name, float x, float y, float z, int label, int temp, boolean firstime, int row) {
        sqdb = getWritableDatabase();
        try
        {
            if (firstime)
            {
                sqdb.execSQL("insert into [" + name + "] (AccelX" + temp + ", AccelY" + temp + ", AccelZ" + temp + ", ActivityLabel) values ('" + x + "', '" + y + "', '" + z + "', '" + label + "' );");
            }
            else
            {
                sqdb.execSQL("update [" + name + "] SET AccelX" + temp + "=" + x + " ,AccelY" + temp + "=" + y + " ,AccelZ" + temp + "=" + z + " where rowid=" + row + ";");
            }

        } catch (Exception e) {}
    }

    public ArrayList<float[]> getDatabase(String name) {
        try
        {
            Cursor cursor =  sqdb.rawQuery("SELECT * FROM " + name , null);
            float[] X_Value = new float[10];
            float[] Y_Value = new float[10];
            float[] Z_Value = new float[10];
            ArrayList<float[]> list= new ArrayList<float[]>();

            cursor.moveToFirst();
            for(int i=1;i>=10;i--) {
                if(!cursor.isAfterLast()){
                    int j=0;
                    while(true)
                    {


                        float xvalue = cursor.getFloat(cursor.getColumnIndex("xvalue"));
                        X_Value[j] = (float) xvalue;

                        float yvalue = cursor.getFloat(cursor.getColumnIndex("yvalue"));
                        Y_Value[j] = (float) yvalue;

                        float zvalue = cursor.getFloat(cursor.getColumnIndex("zvalue"));
                        Z_Value[j] = (float) zvalue;
                        if(xvalue== 0 || yvalue==0 || zvalue==0 || X_Value[j]==0  || Y_Value[j]==0 || Z_Value[j]==0)
                        {
                            break;
                        }
                        j++;
                        list.add(X_Value);
                        list.add(Y_Value);
                        list.add(Z_Value);


                    }




                    cursor.moveToNext();

                }





            }

            return list;
        }
        catch (Exception e) {
            return null;
        }

    }



        public ArrayList<float[]> getinput(String name){
            try{
                sqdb = getWritableDatabase();
                Cursor cursor =  sqdb.rawQuery("SELECT xvalue, yvalue , zvalue FROM " + name + " ORDER BY TIMESTAMP DESC LIMIT 10;", null);
                float[] X_Value = new float[10];
                float[] Y_Value = new float[10];
                float[] Z_Value = new float[10];

                cursor.moveToFirst();
                for(int i=9;i>=0;i--) {
                    if(!cursor.isAfterLast()){
                        float xvalue = cursor.getFloat(cursor.getColumnIndex("xvalue"));
                        X_Value[i] = (float) xvalue;

                        float yvalue = cursor.getFloat(cursor.getColumnIndex("yvalue"));
                        Y_Value[i] = (float) yvalue;

                        float zvalue = cursor.getFloat(cursor.getColumnIndex("zvalue"));
                        Z_Value[i] = (float) zvalue;
                        cursor.moveToNext();

                    } else {
                        X_Value[i] = 0;
                        Y_Value[i]=0;
                        Z_Value[i]=0;
                    }
                }


                ArrayList<float[]> list= new ArrayList<float[]>();
                list.add(X_Value);
                list.add(Y_Value);
                list.add(Z_Value);
                return list;
            }
            catch(Exception e){
            }
            return null;
        }

        public void insertion(String name, Timestamp timestamp, float x, float y, float z){
            try{
                sqdb = getWritableDatabase();
                try{
                    ContentValues values = new ContentValues();
                    values.put("timestamp", System.currentTimeMillis());
                    values.put("xvalue", x);
                    values.put("yvalue", y);
                    values.put("zvalue", z);
                    sqdb.insertOrThrow(name, null, values);
                    Cursor cursor = sqdb.rawQuery("SELECT * FROM " + name, null);
                }
                catch (Exception e){

                }
                finally {
                    sqdb.close();
                }
            }
            catch (Exception e){
            }
        }
}

