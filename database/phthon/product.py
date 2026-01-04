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
    curs = conn.cursor()
    try:
        # id, mid, price, ename을 모두 가져와야 Flutter 모델이 깨지지 않습니다.
        sql = """
            SELECT id, mid, ename, price, quantity, date 
            FROM product 
            ORDER BY id DESC
        """
        curs.execute(sql)
        results = curs.fetchall()

        for row in results:
            if row['date']:
                row['date'] = str(row['date'])
        
        return results  # 리스트 형태로 반환

    except Exception as e:
        print(f"Error: {e}")
        return [] # 에러 시 빈 리스트 반환하여 로딩 종료 유도
    finally:
        conn.close()

@router.get("/selectdetail")
async def selectdetail(pid: int):
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

# [추가] 영문명(ename)으로 기존에 등록된 mid가 있는지 조회하는 API
@router.get("/get_mid")
async def get_mid(ename: str):
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()
        
        # 해당 영문명을 가진 상품 중 mid가 0이 아니거나 본인 id와 같은 대표 mid를 조회
        sql = "SELECT mid FROM product WHERE ename = %s AND mid != '0' LIMIT 1"
        curs.execute(sql, (ename,))
        result = curs.fetchone()
        
        if result:
            return {"mid": result['mid']}
        else:
            return {"mid": None}
            
    except Exception as e:
        print(f"get_mid Error: {e}")
        return {"mid": None}
    finally:
        if conn:
            conn.close()



##################################### 우선 구현용
@router.get("/selectdetail2")
async def select_detail2(pid: int):
    conn = connect()
    try:
        curs = conn.cursor()
        # 1. 먼저 해당 상품의 mid를 확인합니다.
        sql_mid = "SELECT mid FROM product WHERE id = %s"
        curs.execute(sql_mid, (pid,))
        res = curs.fetchone()
        
        # mid가 0이거나 없으면 본인 ID를 그룹 ID로 사용합니다.
        group_id = res['mid'] if res and res['mid'] != 0 else pid

        # 2. 같은 mid를 가진 모든 상품의 모든 옵션(사이즈, 컬러)을 중복 없이 가져옵니다.
        sql = """
            SELECT 
                p.id, p.ename, p.price, p.mid,
                pn.name as product_name,
                m.name as manufacturer_name,
                ps.size,
                pc.color
            FROM product p
            LEFT JOIN productname pn ON p.id = pn.pid
            LEFT JOIN manufacturername m ON p.mid = m.pid
            LEFT JOIN productsize ps ON p.id = ps.pid
            LEFT JOIN productcolor pc ON p.id = pc.pid
            WHERE p.mid = %s OR p.id = %s
        """
        curs.execute(sql, (group_id, group_id))
        rows = curs.fetchall()
        
        return {"results": rows, "group_id": group_id}
    except Exception as e:
        print(f"Error in selectdetail2: {e}")
        return {"error": str(e)}
    finally:
        conn.close()