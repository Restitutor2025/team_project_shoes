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

@router.get("/select")
async def select():
    conn = connect()
    curs = conn.cursor()
    curs.execute("SELECT id, lat, `long`, name, address, phone FROM store ORDER BY name")
    rows = curs.fetchall()
    conn.close()

    result = [{'id': row['id'],'lat': row['lat'],'long': row['long'],'name': row['name'],'address': row['address'],'phone': row['phone']}for row in rows]
    return {'results': result}

storeData = [
    {
        'id': 1,
        'name': '강남점',
        'lat': 37.4979,
        'long': 127.0276,
        'address': '서울특별시 강남구 테헤란로 425',
        'phone': '02-1000-0001'
    },
    {
        'id': 2,
        'name': '강동점',
        'lat': 37.5302,
        'long': 127.1238,
        'address': '서울특별시 강동구 올림픽로 660',
        'phone': '02-1000-0002'
    },
    {
        'id': 3,
        'name': '강북점',
        'lat': 37.6396,
        'long': 127.0257,
        'address': '서울특별시 강북구 도봉로 365',
        'phone': '02-1000-0003'
    },
    {
        'id': 4,
        'name': '강서점',
        'lat': 37.5509,
        'long': 126.8495,
        'address': '서울특별시 강서구 공항대로 561',
        'phone': '02-1000-0004'
    },
    {
        'id': 5,
        'name': '관악점',
        'lat': 37.4784,
        'long': 126.9516,
        'address': '서울특별시 관악구 관악로 145',
        'phone': '02-1000-0005'
    },
    {
        'id': 6,
        'name': '광진점',
        'lat': 37.5386,
        'long': 127.0822,
        'address': '서울특별시 광진구 능동로 120',
        'phone': '02-1000-0006'
    },
    {
        'id': 7,
        'name': '구로점',
        'lat': 37.4955,
        'long': 126.8876,
        'address': '서울특별시 구로구 구로중앙로 152',
        'phone': '02-1000-0007'
    },
    {
        'id': 8,
        'name': '금천점',
        'lat': 37.4568,
        'long': 126.8956,
        'address': '서울특별시 금천구 시흥대로 250',
        'phone': '02-1000-0008'
    },
    {
        'id': 9,
        'name': '노원점',
        'lat': 37.6543,
        'long': 127.0565,
        'address': '서울특별시 노원구 동일로 1414',
        'phone': '02-1000-0009'
    },
    {
        'id': 10,
        'name': '도봉점',
        'lat': 37.6688,
        'long': 127.0471,
        'address': '서울특별시 도봉구 도봉로 552',
        'phone': '02-1000-0010'
    },
    {
        'id': 11,
        'name': '동대문점',
        'lat': 37.5740,
        'long': 127.0396,
        'address': '서울특별시 동대문구 천호대로 133',
        'phone': '02-1000-0011'
    },
    {
        'id': 12,
        'name': '동작점',
        'lat': 37.5124,
        'long': 126.9393,
        'address': '서울특별시 동작구 노량진로 200',
        'phone': '02-1000-0012'
    },
    {
        'id': 13,
        'name': '마포점',
        'lat': 37.5603,
        'long': 126.9084,
        'address': '서울특별시 마포구 월드컵북로 400',
        'phone': '02-1000-0013'
    },
    {
        'id': 14,
        'name': '서대문점',
        'lat': 37.5792,
        'long': 126.9368,
        'address': '서울특별시 서대문구 통일로 87',
        'phone': '02-1000-0014'
    },
    {
        'id': 15,
        'name': '서초점',
        'lat': 37.4837,
        'long': 127.0324,
        'address': '서울특별시 서초구 서초대로 411',
        'phone': '02-1000-0015'
    },
    {
        'id': 16,
        'name': '성동점',
        'lat': 37.5635,
        'long': 127.0364,
        'address': '서울특별시 성동구 왕십리로 241',
        'phone': '02-1000-0016'
    },
    {
        'id': 17,
        'name': '성북점',
        'lat': 37.5894,
        'long': 127.0167,
        'address': '서울특별시 성북구 종암로 35',
        'phone': '02-1000-0017'
    },
    {
        'id': 18,
        'name': '송파점',
        'lat': 37.5146,
        'long': 127.1058,
        'address': '서울특별시 송파구 송파대로 345',
        'phone': '02-1000-0018'
    },
    {
        'id': 19,
        'name': '양천점',
        'lat': 37.5169,
        'long': 126.8665,
        'address': '서울특별시 양천구 목동동로 130',
        'phone': '02-1000-0019'
    },
    {
        'id': 20,
        'name': '영등포점',
        'lat': 37.5260,
        'long': 126.8963,
        'address': '서울특별시 영등포구 국제금융로 10',
        'phone': '02-1000-0020'
    },
    {
        'id': 21,
        'name': '용산점',
        'lat': 37.5311,
        'long': 126.9794,
        'address': '서울특별시 용산구 한강대로 95',
        'phone': '02-1000-0021'
    },
    {
        'id': 22,
        'name': '은평점',
        'lat': 37.6027,
        'long': 126.9291,
        'address': '서울특별시 은평구 연서로 200',
        'phone': '02-1000-0022'
    },
    {
        'id': 23,
        'name': '종로점',
        'lat': 37.5720,
        'long': 126.9794,
        'address': '서울특별시 종로구 종로 33',
        'phone': '02-1000-0023'
    },
    {
        'id': 24,
        'name': '중구점',
        'lat': 37.5636,
        'long': 126.9976,
        'address': '서울특별시 중구 세종대로 110',
        'phone': '02-1000-0024'
    },
    {
        'id': 25,
        'name': '중랑점',
        'lat': 37.6065,
        'long': 127.0927,
        'address': '서울특별시 중랑구 망우로 300',
        'phone': '02-1000-0025'
    },
]

@router.post("/insert")
async def insert():
    try:
        conn = connect()
        curs = conn.cursor()

        curs.execute("SELECT COUNT(*) AS cnt FROM store")
        count = curs.fetchone()['cnt']
        if count > 0:
            conn.close()
            return {"message": "이미 데이터가 있음", "count": count}

        sql = "INSERT INTO store (id, name, lat, `long`, address, phone) VALUES (%s, %s, %s, %s, %s, %s)"

        for store in storeData:
            curs.execute(sql,(store['id'],store['name'],store['lat'],store['long'],store['address'],store['phone']))
        conn.commit()
        conn.close()
        return {"message": f"store 데이터 {len(storeData)}개 삽입 완료"}
    except Exception as e:
        print("Error:",e)
        return {'result':'Error'}