from fastapi import APIRouter
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

class ProductSize(BaseModel):
    pid: int
    size: int

class ProductSizeOnly(BaseModel):
    size: int

@router.get("/select", response_model=list[ProductSizeOnly])
async def select(pid: int):
    conn = connect()
    curs = conn.cursor()

    sql = """
            SELECT size FROM ProductSize WHERE pid = %s 
        """
    curs.execute(sql, (pid,))
    rows = curs.fetchall()
    conn.close()
    print(rows)
    return {'results':rows}

@router.post("/insert")
async def insert(pid: int, inputsize: list[int]):
    conn = connect()
    curs = conn.cursor()

    try:
        sql = """
            INSERT INTO ProductSize (pid, size)
            VALUES (%s, %s)
        """

        data = [(pid, size) for size in inputsize]
        curs.executemany(sql, data)

        conn.commit()
        return {"results": "OK"}

    except Exception as e:
        conn.rollback()
        return {"results": "Error", "detail": str(e)}

    finally:
        conn.close()
        
# @router.post("/update")
# async def update(pid: int, inputsize: list[int]):
#     conn = connect()
#     curs = conn.cursor()

#     try:
#         sql1 = """
#             DELETE FROM ProductSize WHERE pid = %s
            
#             INSERT INTO ProductSize (pid, size)
#             VALUES (%s, %s)
#         """

#         data = [(pid, pid, size) for size in inputsize]
#         curs.executemany(sql, data)

#         conn.commit()
#         return {"results": "OK"}

#     except Exception as e:
#         conn.rollback()
#         return {"results": "Error", "detail": str(e)}

#     finally:
#         conn.close()