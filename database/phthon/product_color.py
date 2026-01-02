from fastapi import APIRouter, Form
from pydantic import BaseModel
import config
import pymysql

router = APIRouter()

def connect():
    conn = pymysql.connect(
        host=config.hostip,
        user=config.hostuser,
        password=config.hostpassword,
        database=config.hostdatabase,
        charset='utf8',
        cursorclass=pymysql.cursors.DictCursor
    )
    return conn

@router.get("/select")
async def select():
    conn=connect()
    curs=conn.cursor()
    curs.execute("select productcolor from color order by pid ")
    rows =curs.fetchall()
    conn.close()
    result=[{'color':row[0]for row in rows}]
    return{'results':result}

router.post("/uproad")
async def upload(color:str=Form(...)):
    try:
        conn=connect()
        curs=conn.cursor()
        sql="insert into productcolor(color,) values(%s,)"
        curs.execute(sql,(color))
        conn.commit()
        conn.close()
        return{'result':'OK'}
    except Exception as e:
        print("Error",e)
        return{'result':"Error"}