#!/usr/bin/python2.7
#
# Assignment3 Interface
#

import psycopg2
import os
import sys
import threading

##################### This needs to changed based on what kind of table we want to sort. ##################
##################### To know how to change this, see Assignment 3 Instructions carefully #################
FIRST_TABLE_NAME = 'table1'
SECOND_TABLE_NAME = 'table2'
SORT_COLUMN_NAME_FIRST_TABLE = 'column1'
SORT_COLUMN_NAME_SECOND_TABLE = 'column2'
JOIN_COLUMN_NAME_FIRST_TABLE = 'column1'
JOIN_COLUMN_NAME_SECOND_TABLE = 'column2'


##########################################################################################################


# Donot close the connection inside this file i.e. do not perform openconnection.close()
def ParallelSort(InputTable, SortingColumnName, OutputTable, openconnection):
    # Implement ParallelSort Here.
    conn = openconnection.cursor()
    conn.execute('SELECT max(' + str(SortingColumnName) + ") FROM  " + str(InputTable))
    value_max = conn.fetchone()[0]
    #print value_max
    conn.execute('SELECT min(' + str(SortingColumnName) + ") FROM  " + str(InputTable))
    value_min = conn.fetchone()[0]
    #print value_min
    diff = value_max - value_min
    diff = diff / 5.0
    list1 = []
    Validate(openconnection)
    for i in range(5):
        list1.append(threading.Thread(target=Sorting, args=(
        InputTable, value_min, value_min + diff, "tb" + str(i), SortingColumnName, openconnection, value_max)))
        list1[i].start()
        value_min = value_min + diff
    #print "Here"
    for t in list1:
        t.join()
    #print "M"
    conn.execute(
        "CREATE TABLE " + OutputTable + " AS (SELECT * FROM tb0  union all  SELECT * FROM tb1 union all SELECT * FROM tb2 union all SELECT * FROM tb3 union all SELECT * FROM tb4)")
    openconnection.commit()
    final(openconnection)

def final(open):
    conn=open.cursor()
    for i in range(5):
        conn.execute("Drop table if exists tb"+str(i))
    open.commit()



def Validate(openconnection):
    conn = openconnection.cursor()
    for i in range(5):
        conn.execute("Drop table if exists tb" + str(i))
    openconnection.commit()



def Sorting(inputTable, lower, upper, tb, column, openconnection, value_max):
    conn = openconnection.cursor()
    #print "upper : " + str(upper) + " max: " + str(value_max)
    if (upper == value_max):
        #print "--------------------------------------------->"
        conn.execute("CREATE TABLE " + str(tb) + " AS SELECT * FROM  " + str(inputTable) + " WHERE " + str(column) + " >= " +  str(
            lower)+ " AND " + str(column) + " <= " + str(upper) + " ORDER BY " + str(column))
        #print("CREATE TABLE " + str(tb) + " AS SELECT * FROM  " + str(inputTable) + " WHERE " + str(column) + " >= " +  str(
            #lower)+ " AND " + str(column) + " < " + str(upper) + " ORDER BY " + str(column))

    else:
        conn.execute("CREATE TABLE " + str(tb) + " AS SELECT * FROM  " + str(inputTable) + " WHERE " + str(column) + " >= " +  str(
            lower)+ " AND " + str(column) + " < " + str(upper) + " ORDER BY " + str(column))
        #print("CREATE TABLE " + str(tb) + " AS SELECT * FROM  " + str(inputTable) + " WHERE " + str(column) + " >= " +  str(
#            lower)+ " AND " + str(column) + " < " + str(upper) + " ORDER BY " + str(column))
        conn.execute("Select * from " + str(tb))
        #print(conn.fetchall()[0])
        openconnection.commit()



def ParallelJoin(InputTable1, InputTable2, Table1JoinColumn, Table2JoinColumn, OutputTable, openconnection):
    conn = openconnection.cursor()
    conn.execute('SELECT max(' + str(Table1JoinColumn) + ") FROM  " + str(InputTable1))
    value_max = conn.fetchone()[0]
    conn.execute('SELECT max(' + str(Table2JoinColumn) + ") FROM  " + str(InputTable2))
    value_max = max(value_max,conn.fetchone()[0])

    conn.execute('SELECT min(' + str(Table1JoinColumn) + ") FROM  " + str(InputTable1))
    value_min = conn.fetchone()[0]
    conn.execute('SELECT min(' + str(Table2JoinColumn) + ") FROM  " + str(InputTable2))
    value_min = min(value_min, conn.fetchone()[0])


    diff = value_max - value_min
    diff = diff / 5.0
    list1 = []
    Validate(openconnection)
    for i in range(5):
        print (value_min,value_min+diff)
        list1.append(threading.Thread(target=Join, args=(
            InputTable1,InputTable2, value_min, value_min + diff, "tb" + str(i), Table1JoinColumn, Table2JoinColumn, openconnection, value_max)))
        list1[i].start()
        value_min = value_min + diff
    for t in list1:
        t.join()
    conn.execute(
        "CREATE TABLE " + OutputTable + " AS (SELECT * FROM tb0  union all  SELECT * FROM tb1 union all SELECT * FROM tb2 union all SELECT * FROM tb3 union all SELECT * FROM tb4)")
    openconnection.commit()
    final(openconnection)

def Join(InputTable1,InputTable2, lower, upper, tb, Table1JoinColumn, Table2JoinColumn, openconnection, value_max):
    conn = openconnection.cursor()
    conn.execute("Drop table if exists temp1"+str(tb))
    conn.execute("Drop table if exists temp2"+str(tb))
    openconnection.commit();
    #print "upper : " + str(upper) + " max: " + str(value_max)
    if (upper == value_max):
        conn = openconnection.cursor()
        conn.execute("Drop table if exists temp1"+str(tb))
        conn.execute("CREATE TABLE temp1"+str(tb)+" AS SELECT * FROM  " + str(InputTable1) + " WHERE " +
            str(Table1JoinColumn) + " >= " + str(lower) +
            " AND " + str(Table1JoinColumn) + " <= " + str(upper))
        openconnection.commit()
        conn = openconnection.cursor()
        conn.execute("Drop table if exists temp2"+str(tb))
        conn.execute("CREATE TABLE temp2"+str(tb)+" AS SELECT * FROM  " + str(InputTable2) + " WHERE " +
                     str(Table2JoinColumn) + " >= " + str(lower) +
                     " AND " + str(Table2JoinColumn) + " <= " + str(upper))
        openconnection.commit()
        conn = openconnection.cursor()
        conn.execute("Create table " + str(tb) +
                     " AS Select * from  temp1"+str(tb)+" t inner join temp2"+tb+" r on t."+
                     str(Table1JoinColumn) + "= r."+str(Table2JoinColumn))


    else:
        conn = openconnection.cursor()
        conn.execute("Drop table if exists temp1"+str(tb))
        conn.execute("CREATE TABLE temp1"+tb+" AS SELECT * FROM  " + str(InputTable1) + " WHERE " +
                     str(Table1JoinColumn) + " >= " + str(lower) +
                     " AND " + str(Table1JoinColumn) + " < " + str(upper))

        openconnection.commit()
        conn = openconnection.cursor()
        conn.execute("Drop table if exists temp2"+tb)
        conn.execute("CREATE TABLE temp2"+tb+" AS SELECT * FROM  " + str(InputTable2) + " WHERE " +
                     str(Table2JoinColumn) + " >= " + str(lower) +
                     " AND " + str(Table2JoinColumn) + " < " + str(upper))
        openconnection.commit()
        conn = openconnection.cursor()
        conn.execute("Create table " + str(tb) +
                     " AS Select * from  temp1"+tb+" t inner join temp2"+tb+" r on t." +
                     str(Table1JoinColumn) + "= r." + str(Table2JoinColumn))
        openconnection.commit()
    conn = openconnection.cursor()
    conn.execute("Drop table if exists temp1"+tb)
    conn.execute("Drop table if exists temp2"+tb)
    openconnection.commit()


################### DO NOT CHANGE ANYTHING BELOW THIS #############################


# Donot change this function
def getOpenConnection(user='postgres', password='1234', dbname='ddsassignment3'):
    return psycopg2.connect("dbname='" + dbname + "' user='" + user + "' host='localhost' password='" + password + "'")


# Donot change this function
def createDB(dbname='ddsassignment3'):
    """
    We create a DB by connecting to the default user and database of Postgres
    The function first checks if an existing database exists for a given name, else creates it.
    :return:None
    """
    # Connect to the default database
    con = getOpenConnection(dbname='postgres')
    con.set_isolation_level(psycopg2.extensions.ISOLATION_LEVEL_AUTOCOMMIT)
    cur = con.cursor()

    # Check if an existing database with the same name exists
    cur.execute('SELECT COUNT(*) FROM pg_catalog.pg_database WHERE datname=\'%s\'' % (dbname,))
    count = cur.fetchone()[0]
    if count == 0:
        cur.execute('CREATE DATABASE %s' % (dbname,))  # Create the database
    else:
        print 'A database named {0} already exists'.format(dbname)

    # Clean up
    cur.close()
    con.commit()
    con.close()


# Donot change this function
def deleteTables(ratingstablename, openconnection):
    try:
        cursor = openconnection.cursor()
        if ratingstablename.upper() == 'ALL':
            cursor.execute("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'")
            tables = cursor.fetchall()
            for table_name in tables:
                cursor.execute('DROP TABLE %s CASCADE' % (table_name[0]))
        else:
            cursor.execute('DROP TABLE %s CASCADE' % (ratingstablename))
        openconnection.commit()
    except psycopg2.DatabaseError, e:
        if openconnection:
            openconnection.rollback()
        print 'Error %s' % e
        sys.exit(1)
    except IOError, e:
        if openconnection:
            openconnection.rollback()
        print 'Error %s' % e
        sys.exit(1)
    finally:
        if cursor:
            cursor.close()


# Donot change this function
def saveTable(ratingstablename, fileName, openconnection):
    try:
        cursor = openconnection.cursor()
        cursor.execute("Select * from %s" % (ratingstablename))
        data = cursor.fetchall()
        openFile = open(fileName, "w")
        for row in data:
            for d in row:
                openFile.write(`d` + ",")
            openFile.write('\n')
        openFile.close()
    except psycopg2.DatabaseError, e:
        if openconnection:
            openconnection.rollback()
        print 'Error %s' % e
        sys.exit(1)
    except IOError, e:
        if openconnection:
            openconnection.rollback()
        print 'Error %s' % e
        sys.exit(1)
    finally:
        if cursor:
            cursor.close()


if __name__ == '__main__':
    try:
        # Creating Database ddsassignment3
        print "Creating Database named as ddsassignment3"
        createDB();

        # Getting connection to the database
        print "Getting connection from the ddsassignment3 database"
        con = getOpenConnection();

        # Calling ParallelSort
        print "Performing Parallel Sort"
        ParallelSort(FIRST_TABLE_NAME, SORT_COLUMN_NAME_FIRST_TABLE, 'parallelSortOutputTable', con);

        # Calling ParallelJoin
        print "Performing Parallel Join"
        ParallelJoin(FIRST_TABLE_NAME, SECOND_TABLE_NAME, JOIN_COLUMN_NAME_FIRST_TABLE, JOIN_COLUMN_NAME_SECOND_TABLE,
                     'parallelJoinOutputTable', con);

        # Saving parallelSortOutputTable and parallelJoinOutputTable on two files
        saveTable('parallelSortOutputTable', 'parallelSortOutputTable.txt', con);
        saveTable('parallelJoinOutputTable', 'parallelJoinOutputTable.txt', con);

        # Deleting parallelSortOutputTable and parallelJoinOutputTable
        deleteTables('parallelSortOutputTable', con);
        deleteTables('parallelJoinOutputTable', con);

        if con:
            con.close()

    except Exception as detail:
        print "Something bad has happened!!! This is the error ==> ", detail
