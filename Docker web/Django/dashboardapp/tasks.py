from celery import Celery
from .new_device_update import new_device
import os

REDIS_HOST = os.environ.get('REDIS_HOST', 'redis_server')
REDIS_PORT = os.environ.get('REDIS_PORT', '6379')

app = Celery('config',config='redis://', broker=f'redis://{REDIS_HOST}:{REDIS_PORT}/')

@app.task
def DeviceDataUpdate(device_name, location_code):
    new_device.insert_new_data(device_name, location_code)
    return 