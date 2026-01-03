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

@router.delete("/delete") # 또는 @router.post("/delete")
async def delete_manufacturename(pid: int, name: str):
    conn = connect()
    curs = conn.cursor()
    try:
        sql = "DELETE FROM manufacturername WHERE pid = %s AND name = %s"
        curs.execute(sql, (pid, name))
        conn.commit()
        if curs.rowcount > 0:
            return {'result': 'OK', 'message': f'Deleted {name} for product {pid}'}
        else:
            return {'result': 'NoData', 'message': '일치하는 데이터가 없습니다.'}
    except Exception as e:
        print("Error during delete:", e)
        return {'result': 'Error'}
    finally:
        conn.close()


@router.post("/insert")
async def insert_product(
    ename: str = Form(...),
    price: int = Form(...),
    manufacturer: str = Form(...)
):
    conn = connect()
    try:
        curs = conn.cursor()
        sql = "INSERT INTO Product (ename, price, manufacturer) VALUES (%s, %s, %s)"
        curs.execute(sql, (ename, price, manufacturer))
        conn.commit()
        
        new_pid = curs.lastrowid 
        
        return {"result": "OK", "pid": new_pid}
    finally:
        conn.close()

@router.get("/all")
async def get_all_manufacturers():
    conn = connect()
    curs = conn.cursor()
    # 등록된 모든 제조사 이름을 중복 없이 가져옴
    curs.execute("SELECT DISTINCT name FROM manufacturername")
    rows = curs.fetchall()
    conn.close()
    return {"results": [row['name'] for row in rows]}