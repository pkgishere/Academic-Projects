#!/usr/bin/python2.7
#
# Interface for the assignement
#

import psycopg2

DATABASE_NAME = 'dds_assgn1'


def getopenconnection(user='postgres', password='Linux', dbname='dds_assgn1'):
    return psycopg2.connect("dbname='" + dbname + "' user='" + user + "' host='localhost' password='" + password + "'")


def loadratings(ratingstablename, ratingsfilepath, openconnection):
    conn=openconnection.cursor()
    conn.execute("Drop table if exists "+ratingstablename)
    conn.execute("Create Table if not exists "+ratingstablename+" (UserID int, temp1 varchar,MovieID int,temp2 varchar, Rating real, temp3 varchar,temp varchar)")
    file = open(ratingsfilepath,'r')
    if False:
        for line in file:
            data=line.split("::")
            requireddata=data[0:-1]
            requireddata=",".join(requireddata)
            conn.execute("Insert into "+ratingstablename+"(userid,movieid,rating) values("+requireddata+")")
    # with open('Stud.txt', 'r') as f:
    #     newlines = []
    #     for line in f.readlines():
    #         newlines.append(line.replace('A', 'Orange'))
    # file.replace("::",":")

    #
    # return;
    conn.copy_from(file,ratingstablename,sep=":",columns=('UserID', 'temp1','MovieID','temp2', 'Rating', 'temp3','temp'))
    conn.execute('ALTER TABLE '+ratingstablename+' DROP temp2,DROP temp3,DROP temp,DROP temp1')
    conn.close
    #pass


def rangepartition(ratingstablename, numberofpartitions, openconnection):
    conn=openconnection.cursor()
    if numberofpartitions<=1:
        return
    start = 0.0
    diff = 5.0/numberofpartitions
    conn.execute('CREATE TABLE range_part0 (UserID int, MovieID int, Rating real)')
    conn.execute('INSERT INTO range_part0 SELECT * from ' + ratingstablename + ' WHERE Rating >= ' + str(start) + ' AND Rating <= ' + str(start + diff))
    start=start+diff
    for counter in range(1, numberofpartitions):
        conn.execute('CREATE TABLE range_part'+str(counter)+'(UserID int, MovieID int, Rating real)')
        conn.execute('INSERT INTO range_part'+str(counter)+' SELECT * from '+ratingstablename+' WHERE Rating > '+str(start)+' AND Rating <= '+str(start+diff))
        start=start+diff
    conn.close


def roundrobinpartition(ratingstablename, numberofpartitions, openconnection):
    conn = openconnection.cursor()
    for counter in range(0, numberofpartitions):
        conn.execute('CREATE TABLE if not exists rrobin_part' + str(counter) + '(UserID int, MovieID int, Rating real)')
    for counter in range(0, numberofpartitions):
        conn.execute(
        'INSERT INTO rrobin_part'+str(counter)+
            ' SELECT UserID, MovieID, Rating ' +
                'FROM (SELECT *, ROW_NUMBER() OVER (ORDER BY UserID) AS id' +
        ' FROM '+ ratingstablename+
        ') AS tempTable WHERE id % '+str(numberofpartitions)+' = '+str(counter))
    conn.close





def roundrobininsert(ratingstablename, userid, itemid, rating, openconnection):
    conn = openconnection.cursor()
    conn.execute("select count(*) from (SELECT * FROM information_schema.tables WHERE table_schema = 'public') as temp where table_name like 'rrobin_part%'")
    partition = conn.fetchone()[0]
    #print partition
    conn.execute("select count(*) from "+ratingstablename)
    rowcount = conn.fetchone()[0]
    #print rowcount
    value=rowcount%partition
    print value
    conn.execute('INSERT INTO '+ratingstablename+ ' VALUES (' + str(userid) + ' , ' + str(itemid) + ' , ' + str(rating) + ')' )
    conn.execute('INSERT INTO rrobin_part'+ str(value)  + ' VALUES (' + str(userid) + ' , ' + str(itemid) + ' , ' + str(rating) + ')')
    conn.close
    #pass


def rangeinsert(ratingstablename, userid, itemid, rating, openconnection):
    conn = openconnection.cursor()
    conn.execute(
        "select count(*) from (SELECT * FROM information_schema.tables WHERE table_schema = 'public') as temp where table_name like 'range_part%'")
    partition = conn.fetchone()[0]
    # print partition
    # print rowcount
    value = 5.0/partition
    print value
    start=0.0
    conn.execute('INSERT INTO ' + ratingstablename + ' VALUES (' + str(userid) + ' , ' + str(itemid) + ' , ' + str(rating) + ')')
    for i in range(partition):
        if (rating==0.0):
            conn.execute('INSERT INTO range_part0 VALUES (' + str(userid) + ' , ' + str(itemid) + ' , ' + str(rating) + ')')
        if(rating > start and rating <= start+value):
            conn.execute('INSERT INTO range_part' + str(i) + ' VALUES (' + str(userid) + ' , ' + str(itemid) + ' , ' + str(rating) + ')')
        start=start+value
    conn.close
    #pass

def deletepartition(ratingstablename,openconnection):
    conn = openconnection.cursor()
    conn.execute("select count(*) from (SELECT * FROM information_schema.tables WHERE table_schema = 'public') as temp where table_name like 'range_part%'")
    partition1 = conn.fetchone()[0]
    conn.execute("select count(*) from (SELECT * FROM information_schema.tables WHERE table_schema = 'public') as temp where table_name like 'rrobin_part%'")
    partition2 = conn.fetchone()[0]
    for i in range(0,partition2):
        conn.execute('DROP TABLE if exists rrobin_part'+str(i))
    for i in range(0, partition1):
        conn.execute('DROP TABLE if exists range_part'+str(i))
    conn.execute('DROP TABLE if exists '+ratingstablename)
    conn.close
def create_db(dbname):
    """
    We create a DB by connecting to the default user and database of Postgres
    The function first checks if an existing database exists for a given name, else creates it.
    :return:None
    """
    # Connect to the default database
    con = getopenconnection(dbname='postgres')
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
    con.close()


# Middleware
def before_db_creation_middleware():
    # Use it if you want to
    pass


def after_db_creation_middleware(databasename):
    # Use it if you want to
    pass


def before_test_script_starts_middleware(openconnection, databasename):
    # Use it if you want to
    pass


def after_test_script_ends_middleware(openconnection, databasename):
    # Use it if you want to
    pass


if __name__ == '__main__':
    try:

        # Use this function to do any set up before creating the DB, if any
        before_db_creation_middleware()

        create_db(DATABASE_NAME)

        # Use this function to do any set up after creating the DB, if any
        after_db_creation_middleware(DATABASE_NAME)

        with getopenconnection() as con:
            # Use this function to do any set up before I starting calling your functions to test, if you want to
            before_test_script_starts_middleware(con, DATABASE_NAME)

            # Here is where I will start calling your functions to test them. For example,
            deletepartition('ratings', con);
            loadratings('ratings','ratings.dat', con)
            roundrobinpartition('ratings',5,con)
            #(ratingstablename, userid, itemid, rating, openconnection):
            # ###################################################################################
            # Anything in this area will not be executed as I will call your functions directly
            # so please add whatever code you want to add in main, in the middleware functions provided "only"
            # ###################################################################################

            # Use this function to do any set up after I finish testing, if you want to
            after_test_script_ends_middleware(con, DATABASE_NAME)

    except Exception as detail:
        print "OOPS! This is the error ==> ", detail
