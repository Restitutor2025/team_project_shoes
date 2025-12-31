from fastapi import APIRouter
from pydantic import BaseModel
import pymysql
import config

router = APIRouter()

# 회원가입용 클라스 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
class Customer(BaseModel):
    email: str
    password: str
    name: str
    phone: str
    address: str

# 로그인용 클라스 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
class LoginRequest(BaseModel):
    email: str
    password: str
    
# 이메일 중복 확인용 클래스
class EmailCheck(BaseModel):
    email: str

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
#회원 가입 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
@router.post("/idregist")
async def idInsert(customer: Customer):
    conn=connect()
    curs=conn.cursor()

    try:
        sql = "INSERT INTO customer(email, password, name, phone, date, address) VALUES (%s, %s, %s, %s, NOW(), %s)"
        curs.execute(sql, (customer.email,customer.password,customer.name,customer.phone,customer.address))
        conn.commit()
        return{'results':'OK'}
    except Exception as e:
        return{'results':'Error'}
    finally:
        conn.close()

#로그인 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
@router.post("/login")
async def login(request: LoginRequest):
    conn = connect()
    curs = conn.cursor()
    
    try:
        sql = "SELECT email, password FROM customer WHERE email = %s AND password = %s"
        curs.execute(sql, (request.email, request.password))
        user = curs.fetchone() 

        if user:
            return {
                'results': 'OK',
                'email': user['email'],
                'password': user['password']
            }
        else:
            # 일치하는 정보가 없다면 (이메일이 틀렸거나, 비번이 틀렸거나)
            return {'results': 'Fail'}
            
    except Exception as e:
        print(f"로그인 처리 중 에러 발생: {e}")
        return {'results': 'Error'}
    finally:
        conn.close()


#이메일 중복확인 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

@router.post("/check_email")
async def checkEmail(request: EmailCheck):
    conn = connect()
    curs = conn.cursor()
    try:
        sql = "SELECT email FROM customer WHERE email = %s"
        curs.execute(sql, (request.email,))
        user = curs.fetchone()
        if user:
            return {'results': 'Exists'} # 이미 존재함
        else:
            return {'results': 'OK'}     # 사용 가능
    except Exception as e:
        return {'results': 'Error'}
    finally:
        conn.close()