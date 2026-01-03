from fastapi import APIRouter
from pydantic import BaseModel
from typing import Optional
import config
import pymysql

#  refund CRUD
    #Create: 03/01/2026 14:04, Creator: Chansol, Park
    #Update log: 
    #  DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
    #Version: 1.0
    #Dependency: 
    #Desc: refund CRUD

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
async def select_refund(cid: int, pcid: Optional[int] = None):
    conn = connect()
    curs = conn.cursor()

    if pcid is None:
        sql = """
            SELECT *
            FROM refund
            WHERE cid = %s
        """
        curs.execute(sql, (cid,))
    else:
        sql = """
            SELECT *
            FROM refund
            WHERE cid = %s AND pcid = %s
        """
        curs.execute(sql, (cid, pcid))

    rows = curs.fetchall()
    conn.close()
    print(rows)
    return {'results':rows}

@router.post("/insert")
async def insert_refund(eid: int, pcid: int, cid: int, refunddate: int, quantity: int):
    conn = connect()
    curs = conn.cursor()

    try:
        sql = """
            INSERT INTO refund (eid, pcid, cid, refunddate, quantity)
            VALUES (%s, %s, %s, %s, %s)
        """
        curs.executemany(sql, (eid, pcid, cid, refunddate, quantity))

        conn.commit()
        return {"results": "OK"}

    except Exception as e:
        conn.rollback()
        return {"results": "Error", "detail": str(e)}

    finally:
        conn.close()