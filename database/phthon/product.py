from fastapi import APIRouter, Form
from datetime import datetime, date
from decimal import Decimal
import config
import pymysql

router = APIRouter()
#asdasdasd

def connect():
    return pymysql.connect(
        host=config.hostip,
        user=config.hostuser,
        password=config.hostpassword,
        database=config.hostdatabase,
        charset="utf8",
        cursorclass=pymysql.cursors.DictCursor
    )

def serialize_rows(rows):
    """
    FastAPI JSON 직렬화 문제 해결용:
    - datetime/date -> isoformat 문자열
    - Decimal -> float (또는 str로 바꾸고 싶으면 str(v)로)
    """
    for row in rows:
        for k, v in row.items():
            if isinstance(v, (datetime, date)):
                row[k] = v.isoformat(sep=" ") if isinstance(v, datetime) else v.isoformat()
            elif isinstance(v, Decimal):
                row[k] = float(v)   # 돈 정확도 유지 원하면 str(v)
    return rows


@router.get("/selectcart")
async def get_shopping():
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()

        sql = """
            SELECT quantity, price, date, ename
            FROM product
        """
        curs.execute(sql)
        rows = curs.fetchall()

        rows = serialize_rows(rows)
        return {"results": rows}

    except Exception as e:
        print("selectcart error:", e)
        return {"error": str(e), "results": []}

    finally:
        if conn:
            conn.close()


@router.post("/select")
async def get_products():
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()

        sql = """
            SELECT id, mid, ename, price, quantity, date
            FROM product
            ORDER BY id DESC
        """
        curs.execute(sql)
        rows = curs.fetchall()

        rows = serialize_rows(rows)
        return {"results": rows}

    except Exception as e:
        print("select error:", e)
        return {"error": str(e), "results": []}

    finally:
        if conn:
            conn.close()


@router.get("/selectdetail")
async def selectdetail(pid: int):
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()

        sql = """
            SELECT
                p.id,
                p.ename,
                p.price,
                p.quantity,
                p.date,
                pn.name AS product_name,
                m.name  AS manufacturer_name,
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

        rows = serialize_rows(rows)
        return {"results": rows}

    except Exception as e:
        print("selectdetail error:", e)
        return {"error": str(e), "results": []}

    finally:
        if conn:
            conn.close()


@router.get("/selectInventory")
async def select_inventory(pid: int):
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()

        sql = """
            SELECT
                p.id,
                p.ename,
                p.quantity,
                p.date,
                pn.name AS product_name,
                m.name  AS manufacturer_name,
                pc.color
            FROM product p
            LEFT JOIN productname pn ON p.id = pn.pid
            LEFT JOIN manufacturername m ON p.mid = m.pid
            LEFT JOIN productcolor pc ON p.id = pc.pid
            WHERE p.id = %s
        """
        curs.execute(sql, (pid,))
        rows = curs.fetchall()

        rows = serialize_rows(rows)
        return {"results": rows}

    except Exception as e:
        print("selectInventory error:", e)
        return {"error": str(e), "results": []}

    finally:
        if conn:
            conn.close()


@router.post("/insert")
async def insert(
    quantity: str = Form(...),
    price: str = Form(...),
    ename: str = Form(...),
    mid: str = Form(None)   # 선택값
):
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()

        safe_mid = mid if mid else "0"
        sql = """
            INSERT INTO product(mid, quantity, price, date, ename)
            VALUES (%s, %s, %s, NOW(), %s)
        """
        curs.execute(sql, (safe_mid, quantity, price, ename))
        conn.commit()

        new_pid = curs.lastrowid
        return {"result": "OK", "pid": new_pid}

    except Exception as e:
        print("insert error:", e)
        return {"result": "Error", "message": str(e)}

    finally:
        if conn:
            conn.close()


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

        return {"result": "OK"}

    except Exception as e:
        print("updateMid error:", e)
        return {"result": "Error", "message": str(e)}

    finally:
        if conn:
            conn.close()


@router.get("/get_mid")
async def get_mid(ename: str):
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()

        # mid가 문자열로 저장돼있을 수도 있어서 '0' 비교 유지
        sql = "SELECT mid FROM product WHERE ename = %s AND mid != '0' LIMIT 1"
        curs.execute(sql, (ename,))
        result = curs.fetchone()

        return {"mid": result["mid"] if result else None}

    except Exception as e:
        print("get_mid error:", e)
        return {"mid": None, "error": str(e)}

    finally:
        if conn:
            conn.close()


@router.get("/selectdetail2")
async def select_detail2(pid: int):
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()

        # 1) 해당 상품 mid 조회
        sql_mid = "SELECT mid FROM product WHERE id = %s"
        curs.execute(sql_mid, (pid,))
        res = curs.fetchone()

        # 2) mid 타입이 str/int 섞여도 안전하게 처리
        mid_val = res["mid"] if res and "mid" in res else None
        try:
            mid_int = int(mid_val) if mid_val is not None else 0
        except (ValueError, TypeError):
            mid_int = 0

        group_id = mid_int if mid_int != 0 else pid

        # 3) 그룹 옵션 전체 조회
        sql = """
            SELECT
                p.id, p.ename, p.price, p.mid,
                pn.name AS product_name,
                m.name  AS manufacturer_name,
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

        rows = serialize_rows(rows)
        return {"results": rows, "group_id": group_id}

    except Exception as e:
        print("selectdetail2 error:", e)
        return {"error": str(e), "results": []}

    finally:
        if conn:
            conn.close()
