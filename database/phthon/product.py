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