# ip Address : 172.16.250.193

from fastapi import FastAPI
from productcolor import router as color_router
from commission import router as commission_router
from customer import router as customer_router
from employee import router as employee_router
from image import router as image_router
from manufacturer import router as manufacturer_router
from manufacturername import router as manufacturername_router
from productname import router as name_router
from product import router as product_router
from purchase import router as purchase_router
from receive import router as receive_router
from refund import router as refund_router
from request import router as request_router
from productsize import router as size_router
from store import router as store_router
from pydantic import BaseModel
import config
import pymysql



app = FastAPI()
app.include_router(color_router,prefix='/color', tags=['color'])
app.include_router(commission_router,prefix='/commission', tags=['commission'])
app.include_router(customer_router,prefix='/customer', tags=['customer'])
app.include_router(employee_router,prefix='/employee', tags=['employee'])
app.include_router(image_router,prefix='/image', tags=['image'])
app.include_router(manufacturer_router,prefix='/manufacturer', tags=['manufacturer'])
app.include_router(manufacturername_router,prefix='/manufacturername', tags=['manufacturername'])
app.include_router(name_router,prefix='/name', tags=['name'])
app.include_router(product_router,prefix='/product', tags=['product'])
app.include_router(purchase_router,prefix='/purchase', tags=['purchase'])
app.include_router(receive_router,prefix='/receive', tags=['receive'])
app.include_router(refund_router,prefix='/refund', tags=['refund'])
app.include_router(request_router,prefix='/request', tags=['request'])
app.include_router(size_router,prefix='/size', tags=['size'])
app.include_router(store_router,prefix='/store', tags=['store'])

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




if __name__ == '__main__':
    import uvicorn
    uvicorn.run(app, host=config.userAddress, port=8008)