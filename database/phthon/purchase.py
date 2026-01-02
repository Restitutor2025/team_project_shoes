from fastapi import APIRouter, Form
from pydantic import BaseModel
from typing import Optional
import config
import pymysql

router = APIRouter()

    #  purchase CRUD
    #Create: 02/01/2026 17:46, Creator: Chansol, Park
    #Update log: 
    #  DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
    #Version: 1.0
    #Dependency: 
    #Desc: purchase CRUD

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
async def select(cid:int, id:Optional[int] = None):
    conn=connect()
    curs=conn.cursor()
    if id is None:
        sql = "SELECT * FROM Purchase WHERE cid = %s"
        curs.execute(sql, (cid,))
    else:
        sql = "SELECT * FROM Purchase WHERE cid = %s AND id = %s"
        curs.execute(sql, (cid, id))
        
    rows =curs.fetchall()
    conn.close()
    return{'results':rows}

@router.post("/insert")
async def insert_purchase(pid:int=Form(...), cid:int=Form(...), eid:int=Form(...),quantity:int=Form(...), finalprice:int=Form(...), pickupdate:str=Form(...), purchasedate:str=Form(...)):
    try:
        conn=connect()
        curs=conn.cursor()
        sql="INSERT INTO Purchase(pid, cid, eid, quantity, finalprice, pickupdate, purchasedate) values(%s,%s,%s,%s,%s,%s,%s)"
        curs.execute(sql,(pid, cid, eid, quantity, finalprice, pickupdate, purchasedate))
        conn.commit()
        conn.close()
        return{'result':'OK'}
    except Exception as e:
        print("Error",e)
        return{'result':"Error"}
    
@router.delete("/delete") # 또는 @router.post("/delete")
async def delete_purchase(id: int, cid: int):
    conn = connect()
    curs = conn.cursor()
    try:
        sql = "DELETE FROM Purchase WHERE id = %s AND cid = %s"
        curs.execute(sql, (id, cid))
        conn.commit()
        if curs.rowcount > 0:
            return {'result': 'OK'}
        else:
            return {'result': 'NoData', 'message': '일치하는 데이터가 없습니다.'}
    except Exception as e:
        print("Error during delete:", e)
        return {'result': 'Error'}
    finally:
        conn.close()