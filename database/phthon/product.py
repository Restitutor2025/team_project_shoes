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

@router.get("/selectInventory")
async def select(pid: int):
    conn = connect()
    try:
        curs = conn.cursor() 
        sql = """
            SELECT 
                p.id,
                p.ename,
                p.quantity,
                p.date,
                pn.name,
                m.name,
                pc.color
            FROM product p
            LEFT JOIN productname pn ON p.id = pn.pid
            LEFT JOIN manufacturername m ON p.mid = m.pid
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


# [수정] insert 함수: mid를 Form(None)으로 변경하여 필수 입력을 해제합니다.
@router.post("/insert")
async def insert(
    quantity: str = Form(...), 
    price: str = Form(...), 
    ename: str = Form(...),
    mid: str = Form(None)  # 🔥 필수값에서 선택값으로 변경
):
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()
        
        # mid가 없으면 일단 '0'으로 저장 (첫 번째 상품인 경우)
        safe_mid = mid if mid else "0"
        
        sql = "INSERT INTO product(mid, quantity, price, date, ename) VALUES (%s, %s, %s, NOW(), %s)"
        curs.execute(sql, (safe_mid, quantity, price, ename))
        conn.commit()
        new_pid = curs.lastrowid 
        return {'result': 'OK', 'pid': new_pid}
    except Exception as e:
        print(f"Error: {e}") 
        return {'result': 'Error', 'message': str(e)}
    finally:
        if conn: conn.close()

# [추가] Flutter에서 보낸 mid 값을 업데이트하는 API
@router.post("/updateMid")
async def update_mid(
    pid: str = Form(...),
    mid: str = Form(...)
):
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()
        sql = "UPDATE product SET mid = %s WHERE id = %s"
        curs.execute(sql, (mid, pid))
        conn.commit()
        return {'result': 'OK'}
    except Exception as e:
        print(f"Update Error: {e}")
        return {'result': 'Error', 'message': str(e)}
    finally:
        if conn: conn.close()