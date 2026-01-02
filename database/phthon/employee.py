from fastapi import APIRouter, Form
from pydantic import BaseModel
import config
import pymysql

router = APIRouter()
class LoginRequest(BaseModel):
    email: str
    password: str

class Employee(BaseModel):
    role: str
    name: str
    email: str
    password: str
    storenumber: str
    phone:str
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
@router.post("/login")
async def login(request: LoginRequest):
    conn = connect()
    curs = conn.cursor()
    
    try:
        sql = "SELECT id, role, name, email, password, storenumber, phone FROM employee WHERE email = %s AND password = %s"
        curs.execute(sql, (request.email, request.password))
        employee = curs.fetchone() 

        if employee:
            # 보안상 비밀번호는 내려주지 않는 걸 추천
            employee.pop("password", None)

            return {
                "results": "OK",
                "employee_data": employee
            }
        else:
            return {'results': 'Fail'}
            
    except Exception as e:
        print(f"로그인 처리 중 에러 발생: {e}")
        return {'results': 'Error'}
    finally:
        conn.close()

@router.post("/insert")
async def idInsert(employee: Employee):
    conn=connect()
    curs=conn.cursor()

    try:
        sql = "INSERT INTO employee(role, name, email, password, storenumber, phone) VALUES (%s, %s, %s, %s, %s, %s)"
        curs.execute(sql, (employee.role,employee.name,employee.email,employee.password,employee.storenumber,employee.phone))
        conn.commit()
        return{'results':'OK'}
    except Exception as e:
        return{'results':'Error'}
    finally:
        conn.close()

