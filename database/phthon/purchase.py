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
    conn = connect()
    curs = conn.cursor()
    curs.execute("SELECT seq, pid, cid, eid, quantity, finalPrice, pickupDate, purchaseDate, code FROM purchase ORDER BY purchaseDate")
    rows = curs.fetchall()
    conn.close()
    result = [{'seq':row[0], 'pid':row[1],'cid':row[2],'eid':row[3],'quantity':row[4],'finalPrice':row[5],'pickupDate':row[6],'purchaseDate':row[7],'code':row[8],} for row in rows]
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