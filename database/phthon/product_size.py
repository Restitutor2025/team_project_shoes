from fastapi import APIRouter
from pydantic import BaseModel
from typing import Optional
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

class SizeList(BaseModel):
    inputsize: list[int] # [230,235,240] range(230, 275+1, 5)

@router.get("/select")
async def select(pid: int):
    conn = connect()
    curs = conn.cursor()

    sql = """
            SELECT size FROM ProductSize WHERE pid = %s 
        """
    curs.execute(sql, (pid,))
    rows = curs.fetchall()
    conn.close()
    print(rows)
    return {'results':rows}

@router.post("/insert")
async def insert(pid: int, body: Optional[SizeList] = None):
    conn = connect()
    curs = conn.cursor()
    if body is None:
        sizes = list(range(230, 276, 5))  # 230 ~ 275
    else:
        sizes = body.inputsize

    try:
        sql = """
            INSERT INTO ProductSize (pid, size)
            VALUES (%s, %s)
        """

        data = [(pid, size) for size in sizes]
        curs.executemany(sql, data)

        conn.commit()
        return {"results": "OK"}

    except Exception as e:
        conn.rollback()
        return {"results": "Error", "detail": str(e)}

    finally:
        conn.close()
        
@router.post("/update")
async def update(pid: int, body: SizeList):
    conn = connect()
    curs = conn.cursor()

    try:
        sql1 = """
            DELETE FROM ProductSize WHERE pid = %s
        """
        sql2 = """
            INSERT INTO ProductSize (pid, size)
            VALUES (%s, %s)
        """

        data = [(pid, size) for size in body.inputsize]
        curs.execute(sql1, (pid,))
        curs.executemany(sql2, data)

        conn.commit()
        return {"results": "OK"}

    except Exception as e:
        conn.rollback()
        return {"results": "Error", "detail": str(e)}

    finally:
        conn.close()