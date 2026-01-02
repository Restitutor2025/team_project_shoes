from fastapi import APIRouter
from fastapi import UploadFile, File, Form
from fastapi.responses import Response
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

@router.get("/view")
async def view(pid: int, position: str):
    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute(
            """
                SELECT path FROM ProductImage
                WHERE pid = %s AND position = %s
            """, (pid, position)
        )
        row = curs.fetchone()
        conn.close()
        if row and row["path"]:
            return Response(
                content = row["path"],
                media_type = "path/jpeg",
                headers = {"Cache-Control":"no-cache, no-store, must-revalidate"}
            )
        else:
            return{"result":"No path found"}
    except Exception as e:
        print("Error: ", e)
        return {"result": "Error"}
        
@router.post("/upload")
async def upload(
    pid: int = Form(...), position: str = Form(...), file: UploadFile = File(...)):
    try:
        image_data = await file.read()
        conn = connect()
        curs = conn.cursor()
        sql = "INSERT INTO ProductImage (pid, position, path) VALUES (%s, %s, %s)"
        curs.execute(sql, (pid, position, image_data))
        conn.commit()
        conn.close()
        return {"result":"OK"}
    except Exception as e:
        print("Error: ", e)
        return {"result": "Error"}
    
@router.delete("/delete")
async def delete(pid: int, position: str):
    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute(
            """
            DELETE FROM ProductImage WHERE pid = %s AND position = %s
            """, (pid, position)
        )
        conn.commit()
        conn.close()
        return {"result":"OK"}
    except Exception as e:
        print("Error: ", e)
        return {"result": "Error"}
    
@router.post("/update_image")
async def updatewithimage(
    pid: int = Form(...), position: str = Form(...), file: UploadFile = File(...)):
    try:
        image_data = await file.read()
        conn = connect()
        curs = conn.cursor()
        sql = "UPDATE ProductImage SET path = %s WHERE pid = %s AND position = %s"
        curs.execute(sql, (position, image_data, pid))
        conn.commit()
        conn.close()
        return {"result":"OK"}
    except Exception as e:
        print("Error: ", e)
        return {"result": "Error"}