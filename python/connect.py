import os
import cx_Oracle

username = os.getenv('ORACLE_USER')
password = os.getenv('ORACLE_PASSWORD')
dsn_tns = cx_Oracle.makedsn('213.184.8.44', '1521', service_name='orcl')
connection = cx_Oracle.connect(user=username, password=password, dsn=dsn_tns)
cur = connection.cursor()

