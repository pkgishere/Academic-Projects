package com.example.prashantgarg.healthmonitoring;


import java.sql.Timestamp;
import java.util.ArrayList;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;


/**
 * Created by Prashant garg on 01-03-2017.
 */

public class DataBase extends SQLiteOpenHelper
{

        private static final String DataBase_Name = "Group2.db";
        private static final int DATABASE_VERSION = 1;
        private final String DataBase_Path;
        private Context context;

        @Override
        public void onUpgrade(SQLiteDatabase sqdb, int oldVersion, int newVersion) {

        }

        public DataBase(Context context)
        {
            super(context, DataBase_Name, null, DATABASE_VERSION);
            DataBase_Path = context.getFilesDir().getPath()+"/";
            this.context = context;
        }

        @Override
        public void onCreate(SQLiteDatabase sqdb) {
        }

        public void createDatabase() {
            SQLiteDatabase sqdb = null;
            String database = DataBase_Path + DataBase_Name;
            try {
                sqdb = SQLiteDatabase.openOrCreateDatabase(database, null);
            } catch (Exception e) {
            }
        }

        public void createTable(String name) {
            SQLiteDatabase sqdb = getWritableDatabase();
            sqdb.execSQL("CREATE TABLE IF NOT EXISTS " + name + "(timestamp datetime, xvalue real, yvalue real, zvalue real);");
            sqdb.close();
        }



        public ArrayList<float[]> getinput(String name){
            try{
                SQLiteDatabase sqdb = getWritableDatabase();
                Cursor cursor =  sqdb.rawQuery("SELECT xvalue, yvalue , zvalue FROM " + name + " ORDER BY TIMESTAMP DESC LIMIT 10;", null);
                float[] xvalues = new float[10];
                float[] yvalues = new float[10];
                float[] zvalues = new float[10];

                cursor.moveToFirst();
                for(int i=9;i>=0;i--) {
                    if(!cursor.isAfterLast()){
                        float xvalue = cursor.getFloat(cursor.getColumnIndex("xvalue"));
                        xvalues[i] = (float) xvalue;

                        float yvalue = cursor.getFloat(cursor.getColumnIndex("yvalue"));
                        yvalues[i] = (float) yvalue;

                        float zvalue = cursor.getFloat(cursor.getColumnIndex("zvalue"));
                        zvalues[i] = (float) zvalue;
                        cursor.moveToNext();

                    } else {
                        xvalues[i] = 0;
                        yvalues[i]=0;
                        zvalues[i]=0;
                    }
                }


                ArrayList<float[]> list= new ArrayList<float[]>();
                list.add(xvalues);
                list.add(yvalues);
                list.add(zvalues);
                return list;
            }
            catch(Exception e){
            }
            return null;
        }

        public void insertion(String name, Timestamp timestamp, float x, float y, float z){
            try{
                SQLiteDatabase sqdb = getWritableDatabase();
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

