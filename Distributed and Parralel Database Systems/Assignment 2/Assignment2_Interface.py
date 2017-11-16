#!/usr/bin/python2.7
#
# Assignment2 Interface
#

import psycopg2
import os
import sys

# Donot close the connection inside this file i.e. do not perform openconnection.close()
def RangeQuery(ratingsTableName, Min, Max, openconnection):
    #Implement RangeQuery Here.
    con = openconnection;
    cur = con.cursor()

    cur.execute(
        "select count(*) from (SELECT * FROM information_schema.tables WHERE table_schema = 'public') as temp where table_name like 'rangeratingspart%'")
    partition = cur.fetchone()[0]
    file1= open("RangeQueryOut.txt","w");
    for i in range(partition):
        cur.execute("Select * from public.rangeratingspart"+str(i)+" where rating >= "+ str(Min) +" and rating <= " +str(Max))
        rows = cur.fetchall()
        for row in rows:
            print("rangeratingspart"+str(i)+","+str(row[0])+","+str(row[1])+","+str(row[2]))
            file1.write("rangeratingspart"+str(i)+","+str(row[0])+","+str(row[1])+","+str(row[2]))
            file1.write("\n")

    cur.execute(
        "select count(*) from (SELECT * FROM information_schema.tables WHERE table_schema = 'public') as temp where table_name like 'roundrobinratingspart%'")
    partition = cur.fetchone()[0]
    #file1 = open("RangeQueryOut.txt", "w");
    for i in range(partition):
        cur.execute(
            "Select * from public.roundrobinratingspart" + str(i) + " where rating >= " + str(Min) + " and rating <= " + str(
                Max))
        rows = cur.fetchall()
        for row in rows:
            print("roundrobinratingspart" + str(i) + "," + str(row[0]) + "," + str(row[1]) + "," + str(row[2]))
            file1.write("roundrobinratingspart" + str(i) + "," + str(row[0]) + "," + str(row[1]) + "," + str(row[2]))
            file1.write("\n")

def PointQuery(ratingsTableName, Val, openconnection):
    con = openconnection;
    cur = con.cursor()
    cur.execute(
        "select count(*) from (SELECT * FROM information_schema.tables WHERE table_schema = 'public') as temp where table_name like 'rangeratingspart%'")
    partition = cur.fetchone()[0]
    print partition
    file1 = open("PointQueryOut.txt", "w");
    for i in range(partition):
        cur.execute(
            "Select * from public.rangeratingspart" + str(i) + " where rating = " + str(Val))
        rows = cur.fetchall()
        for row in rows:
            print("rangeratingspart" + str(i) + "," + str(row[0]) + "," + str(row[1]) + "," + str(row[2]))
            file1.write("rangeratingspart" + str(i) + "," + str(row[0]) + "," + str(row[1]) + "," + str(row[2]))
            file1.write("\n")

    cur.execute(
        "select count(*) from (SELECT * FROM information_schema.tables WHERE table_schema = 'public') as temp where table_name like 'roundrobinratingspart%'")
    partition = cur.fetchone()[0]
    print partition
    # file1 = open("RangeQueryOut.txt", "w");
    for i in range(partition):
        cur.execute(
            "Select * from public.roundrobinratingspart" + str(i) + " where rating = " + str(Val))
        rows = cur.fetchall()
        for row in rows:
            print("roundrobinratingspart" + str(i) + "," + str(row[0]) + "," + str(row[1]) + "," + str(row[2]))
            file1.write("roundrobinratingspart" + str(i) + "," + str(row[0]) + "," + str(row[1]) + "," + str(row[2]))
            file1.write("\n")
