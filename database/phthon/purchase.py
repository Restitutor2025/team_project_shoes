from fastapi import APIRouter, Form
from pydantic import BaseModel
from typing import Optional
import config
import pymysql

router = APIRouter()

# 
# Description : 상품 구매 테이블
#   - select, insert, insertPickupDate 생성
#       - insertPickupDate 은 결제 완료 이후 , 
#         실제 픽업 날짜로 이후 생성 되어 추가 될 예정으로 PickupDate만 들어가게 구성
# Date : 2025-01-02
# Author : 지현
#

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

from datetime import datetime, date
from decimal import Decimal

def serialize_rows(rows):
    for row in rows:
        for k, v in row.items():
            if isinstance(v, (datetime, date)):
                row[k] = v.isoformat(sep=" ") if isinstance(v, datetime) else v.isoformat()
            elif isinstance(v, Decimal):
                row[k] = float(v)  # 돈 오차 싫으면 str(v)
    return rows

@router.get("/select")
async def select():
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()

        # ✅ 컬럼명 통일(스네이크 케이스)
        sql = """
            SELECT id, pid, cid, eid, quantity, finalprice, pickupdate, purchasedate, code
            FROM purchase
            ORDER BY purchasedate DESC
        """
        curs.execute(sql)
        rows = curs.fetchall()

        rows = serialize_rows(rows)
        return {"results": rows}

    except Exception as e:
        print("purchase/select error:", e)
        return {"error": str(e), "results": []}

    finally:
        if conn:
            conn.close()
            
@router.get("/selectcustomer")
async def selectcustomer(cid: int):
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()

        sql = """
            SELECT id, pid, cid, eid, quantity, finalprice, pickupdate, purchasedate, code
            FROM purchase
            WHERE cid = %s
            ORDER BY purchasedate DESC
        """
        curs.execute(sql, (cid,))
        rows = curs.fetchall()

        rows = serialize_rows(rows)
        return {"results": rows}

    except Exception as e:
        print("purchase/selectcustomer error:", e)
        return {"error": str(e), "results": []}

    finally:
        if conn:
            conn.close()

@router.post("/insert")
async def insert(
    quantity: int = Form(...), 
    finalprice: int = Form(...), 
    code: str = Form(...),
    pid: int = Form(...),   # 추가
    cid: int = Form(...),   # 추가
    eid: int = Form(...)    # 추가
):
    try:
        conn = connect() 
        curs = conn.cursor()
        # SQL 문에 pid, cid, eid 컬럼과 %s를 추가합니다.
        sql = """
            INSERT INTO purchase (quantity, finalprice, purchasedate, code, pid, cid, eid) 
            VALUES (%s, %s, CURDATE(), %s, %s, %s, %s)
        """
        curs.execute(sql, (quantity, finalprice, code, pid, cid, eid))
        conn.commit()
        conn.close()
        return {"result": "OK"}
    except Exception as e:
        print("Error details:", e)
        return {'result': "Error"}


@router.post("/insertPickupDate")
async def insertPickupDate():
    try:
        conn = connect() 
        curs = conn.cursor()
        sql = "INSERT INTO purchase (pickupDate) VALUES (CURDATE())"
        curs.execute(sql, ())
        conn.commit()
        conn.close()
        return{"result": "OK"}
    except Exception as e:
        print("Error:", e)
        return {'result': "Error"}

@router.get("/selectSummary")
async def select_summary():
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()

        sql = """
            SELECT
                p.id            AS pcid,
                pr.id           AS pid,
                p.cid           AS cid,
                c.email         AS cemail,
                c.name          AS cname,
                pn.name         AS pname,
                p.finalprice    AS finalprice,
                ps.size         AS size,
                pc.color        AS color,
                p.quantity      AS quantity,
                s.name          AS sname,
                r.id            AS rid,
                p.purchasedate  AS purchasedate,
                p.pickupdate    AS pickupdate,
                r.refunddate    AS refunddate
            FROM purchase p
            JOIN customer c            ON p.cid = c.id
            JOIN employee e            ON p.eid = e.id
            JOIN store s               ON e.sid = s.id
            JOIN product pr            ON p.pid = pr.id
            LEFT JOIN productname pn   ON pn.pid = pr.id
            LEFT JOIN productsize ps   ON ps.pid = pr.id
            LEFT JOIN productcolor pc  ON pc.pid = pr.id
            LEFT JOIN refund r         ON r.pcid = p.id
            ORDER BY p.purchasedate DESC
        """
        curs.execute(sql)
        rows = curs.fetchall()

        rows = serialize_rows(rows)
        return {"results": rows}

    except Exception as e:
        print("purchase/selectSummary error:", e)
        return {"error": str(e), "results": []}

    finally:
        if conn:
            conn.close()