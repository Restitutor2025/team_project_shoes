from fastapi import APIRouter
from fastapi import UploadFile, File, Form
from fastapi.responses import Response
from pydantic import BaseModel
import config
import pymysql

    #  product_image CRUD
    #Create: 31/12/2025 15:06, Creator: Chansol, Park
    #Update log: 
    #  DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
    #Version: 1.0
    #Dependency: 
    #Desc: product_image CRUD
    
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
async def view(pid: int, position: int):
    conn = connect()
    try:
        curs = conn.cursor()
        curs.execute(
            "SELECT image FROM ProductImage WHERE pid=%s AND position=%s",
            (pid, position)
        )
        row = curs.fetchone()

        if row and row["image"]:
            return Response(
                content=row["image"],
                media_type="image/png",
                headers={"Cache-Control":"no-cache, no-store, must-revalidate"}
            )
        return {"result": "No image found"}
    finally:
        conn.close()
        
@router.post("/upload")
async def upload(
    pid: int = Form(...), position: str = Form(...), file: UploadFile = File(...)):
    try:
        image_data = await file.read()
        conn = connect()
        curs = conn.cursor()
        sql = "INSERT INTO ProductImage (pid, position, image) VALUES (%s, %s, %s) ON DUPLICATE KEY UPDATE image = VALUES(image)"
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
        sql = "UPDATE ProductImage SET image = %s WHERE pid = %s AND position = %s"
        curs.execute(sql, (image_data, pid, position))
        conn.commit()
        conn.close()
        return {"result":"OK"}
    except Exception as e:
        print("Error: ", e)
        return {"result": "Error"}