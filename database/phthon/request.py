from fastapi import APIRouter , Form
from pydantic import BaseModel
import config
import pymysql

router = APIRouter()
class RequestData(BaseModel):
    eid: int
    date: int
    okdate: int
    contents: str

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

@router.post("/insert")
async def RequestInsert(data: RequestData):
    conn = connect()
    curs = conn.cursor()

    try:
        sql = "INSERT INTO request(eid, date, okdate, contents) VALUES (%s, NOW(), NOW(), %s)"
        
        curs.execute(sql, (data.eid, data.contents))
        
        conn.commit()
        return {'results': 'OK'}
    except Exception as e:
        print(f"DB Error: {e}") 
        return {'results': 'Error'}
    finally:
        conn.close()