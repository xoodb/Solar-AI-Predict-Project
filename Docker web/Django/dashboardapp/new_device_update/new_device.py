from . import apidb
import re
from . import accuweather5days
from . import afterdata_24h
from . import afterdata_Day
from . import use_LSTM_modul
from . import predict_device


def find_data(data):
    match = re.search(r'\((.*?)\)', data)
    return match.group(1)

def insert_new_data(device_id, location_code):
    print(f"디바이스 이름 : {device_id}, 코드 : {location_code}")
    Device_name = find_data(device_id)
    if location_code != 0:
        Device_location_code = find_data(location_code)
    else:
        Device_location_code = apidb.dbconfreeselect('select Location_code from device where device_id ="{device_id}";')[0][0]
    #print(f"디바이스 이름 : {Device_name}, 코드 : {Device_location_code}")
    Device_area = apidb.dbconfreeselect(f'SELECT area FROM xytable WHERE Location_code = {Device_location_code};')[0][0]
    Device_Coordinates = apidb.dbconfreeselect(f"SELECT `Latitude_sec/100`, `longitude_sec/100` FROM xytable WHERE Location_code = {Device_location_code};")
    accuweather5days.new_insert(Device_location_code, Device_area)
    afterdata_24h.new_24_insert(Device_location_code, Device_area)
    afterdata_Day.new_Day_insert(Device_location_code, Device_area)
    use_LSTM_modul.new_model_insert(Device_location_code, Device_area, Device_Coordinates)
    predict_device.new_perdict_insert(Device_name) 
    print(f'추가 완료')