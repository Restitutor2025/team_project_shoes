from fastapi import APIRouter
from fastapi import FastAPI, Form
from pydantic import BaseModel
from datetime import datetime
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
@router.get("/selectcart")
async def get_shopping():
    conn = connect()
    try:
        curs = conn.cursor()

        sql = """
            SELECT  quantity, price, date, ename
            FROM product
           
        """
        curs.execute(sql,)
        rows = curs.fetchall()

        return {"results": rows}

    except Exception as e:
        print(" selectcart error:", e)
        return {"error": str(e)}

    finally:
        conn.close()



@router.post("/select")
async def get_products():
    conn = connect()
    curs = conn.cursor() # 팀원 스타일: 커서 직접 생성

    try:
        # SQL 실행
        sql = "SELECT id, quantity, price, date, ename FROM product"
        curs.execute(sql)
        results = curs.fetchall()

        # 데이터 가공 (날짜 형변환)
        for row in results:
            if row['date']:
                row['date'] = str(row['date'])
        return results

    except Exception as e:
        print(f"Error: {e}")
        return {'results': 'Error'} 
        
    finally:
        conn.close()

@router.get("/selectdetail")
async def select(pid: int):
    conn = connect()
    try:
        curs = conn.cursor() 
        sql = """
            SELECT 
                p.id,
                p.ename,
                p.price,
                p.quantity,
                p.date,
                pn.name,
                m.name,
                ps.size,
                pc.color
            FROM product p
            LEFT JOIN productname pn ON p.id = pn.pid
            LEFT JOIN manufacturername m ON p.mid = m.pid
            LEFT JOIN productsize ps ON p.id = ps.pid
            LEFT JOIN productcolor pc ON p.id = pc.pid
            WHERE p.id = %s
        """
        curs.execute(sql, (pid,))
        rows = curs.fetchall()
        return {"results": rows}
    except Exception as e:
        print("selectdetail error:", e)
        return {"error": str(e)}
    finally:
        conn.close()



@router.post("/insert")
async def insert(
    quantity: str = Form(...), 
    price: str = Form(...), 
    ename: str = Form(...)
):
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()
        
        sql = "INSERT INTO product(quantity, price, date, ename) VALUES (%s, %s, NOW(), %s)"
        
        curs.execute(sql, (
            quantity,
            price,
            ename
        ))
        
        conn.commit()
        return {'results': 'OK'}
        
    except Exception as e:
        print(f"Error: {e}") 
        return {'results': 'Error'}
        
    finally:
        if conn:
            conn.close()