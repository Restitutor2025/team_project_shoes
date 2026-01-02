from fastapi import APIRouter
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
        sql = "SELECT id, mid, quantity, price, date, ename FROM product ORDER BY date"
        curs.execute(sql)
        results = curs.fetchall()

        # 데이터 가공 (날짜 형변환)
        for row in results:
            if row['date']:
                row['date'] = str(row['date'])
        return results

    except Exception as e:
        print(f"Error: {e}")
        return {'results': 'Error'} # 팀원 스타일: 에러 발생 시 반환값Z
        
    finally:
        conn.close()


@router.post("/insert")
async def insert():
    conn = connect()
    curs = conn.cursor()
    try:
        for product in productname:
            sql = "insert into product(id, mid, quantity, price, date, ename) values (%s,%s,%s,%s,%s,%s)"
            curs.execute(sql, (
                product['id'],
                product['mid'],
                product['quantity'],
                product['price'],
                product['date'],
                product['ename'],
            ))
        
        conn.commit()
        return {'results': 'OK'}

    except Exception as e:
        print(f"Error: {e}")
        return {'results': 'Error'}
        
    finally:
        conn.close()

# 현재 시간을 문자열로 변환
current_date = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

productname = [
    {
        "id": 1,
        "mid": 1, # 나이키 ID (가정)
        "quantity": 100,
        "price": 200000,
        "date": current_date,
        "ename": "나이키 레드 스니커즈"
    },
    {
        "id": 2,
        "mid": 2, # 퓨마 ID
        "quantity": 50,
        "price": 220000,
        "date": current_date,
        "ename": "퓨마 블랙 스니커즈"
    },
    {
        "id": 3,
        "mid": 3, # 아디다스 ID
        "quantity": 80,
        "price": 190000,
        "date": current_date,
        "ename": "아디다스 화이트 스니커즈"
    },
    {
        "id": 4,
        "mid": 4, # 기타 브랜드 ID
        "quantity": 120,
        "price": 100000,
        "date": current_date,
        "ename": "스니커즈 브라운"
    }
]
