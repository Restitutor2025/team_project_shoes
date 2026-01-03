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

@router.get("/select")
async def select():
    conn = connect()
    curs = conn.cursor()
    curs.execute("SELECT id, pid, cid, eid, quantity, finalPrice, pickupDate, purchaseDate, code FROM purchase ORDER BY purchaseDate")
    rows = curs.fetchall()
    conn.close()
    result = [{'id':row[0], 'pid':row[1],'cid':row[2],'eid':row[3],'quantity':row[4],'finalPrice':row[5],'pickupDate':row[6],'purchaseDate':row[7],'code':row[8],} for row in rows]
    return{'results':result}

@router.post("/insert")
async def insert(quantity: int = Form(...), finalprice: int = Form(...), code: str = Form(...)):
    try:
        conn = connect() 
        curs = conn.cursor()
        sql = "INSERT INTO purchase (quantity,finalprice,purchasedate,code) VALUES (%s,%s,CURDATE(),%s)"
        curs.execute(sql, (quantity,finalprice,code,))
        conn.commit()
        conn.close()
        return{"result": "OK"}
    except Exception as e:
        print("Error:", e)
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
        return {"results": rows}
    except Exception as e:
        print("Error:", e)
        return {"Error": "Error"}
    finally:
        conn.close()