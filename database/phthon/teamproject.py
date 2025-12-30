# ip Address : 172.16.250.193

from fastapi import FastAPI
import pymysql

app = FastAPI()
ipAddress = '172.16.250.193'

def connect():
    conn = pymysql.connect(
        host=ipAddress,
        user='root',
        password='qwer1234',
        database='teamproject',
        charset='utf8'
    )
    return conn


if __name__ == '__main__':
    import uvicorn
    uvicorn.run(app, host=ipAddress, port=8008)