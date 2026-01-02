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
async def select(pid:int):
    conn=connect()
    curs=conn.cursor()
    sql = """
    SELECT name FROM manufacturername WHERE pid = %s
    """
    curs.execute(sql,(pid,))
    rows =curs.fetchall()
    conn.close()
    result=[rows]
    return{'results':result}

@router.post("/upload")
async def upload(pid:int=Form(...),name:str=Form(...)):
    try:
        conn=connect()
        curs=conn.cursor()
        sql="insert into manufacturername(pid,name) values(%s,%s)"
        curs.execute(sql,(pid,name))
        conn.commit()
        conn.close()
        return{'result':'OK'}
    except Exception as e:
        print("Error",e)
        return{'result':"Error"}