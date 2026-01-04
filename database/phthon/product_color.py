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
    SELECT color FROM PRODUCTCOLOR WHERE pid = %s
    """
    curs.execute(sql,(pid,))
    rows =curs.fetchall()
    conn.close()
    return{'results':rows}

@router.post("/uproad")
async def upload(pid:int=Form(...),color:str=Form(...)):
    try:
        conn=connect()
        curs=conn.cursor()
        sql="insert into productcolor(pid,color) values(%s,%s)"
        curs.execute(sql,(pid,color))
        conn.commit()
        conn.close()
        return{'result':'OK'}
    except Exception as e:
        print("Error",e)
        return{'result':"Error"}
    

@router.delete("/delete") # 또는 @router.post("/delete")
async def delete_productcolor(pid: int, color: str):
    conn = connect()
    curs = conn.cursor()
    try:
        sql = "DELETE FROM productcolor WHERE pid = %s AND color = %s"
        curs.execute(sql, (pid, color))
        conn.commit()
        if curs.rowcount > 0:
            return {'result': 'OK', 'message': f'Deleted {color} for product {pid}'}
        else:
            return {'result': 'NoData', 'message': '일치하는 데이터가 없습니다.'}
    except Exception as e:
        print("Error during delete:", e)
        return {'result': 'Error'}
    finally:
        conn.close()

@router.get("/all")
async def get_all_colors():
    conn = connect()
    curs = conn.cursor()
    # 등록된 모든 색상을 중복 없이 가져옴
    curs.execute("SELECT DISTINCT color FROM productcolor")
    rows = curs.fetchall()
    conn.close()
    return {"results": [row['color'] for row in rows]}