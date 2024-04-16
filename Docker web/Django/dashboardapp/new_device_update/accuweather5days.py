import requests
import json
from . import apidb # db에 연결 및 구문 실행
from . import get_time
from . import accuweathergetcity # api에서 사용할 위치 코드를 가져온다
from .info import secret_info


'''
AccuWeather API를 사용해서 예측 데이터를 받아오는 코드
'''

# AccuWeather API 키
api_key = secret_info.AccuWeather_API
#등록된 기기의 위치 정보를 가져온다
table = "solar_api_5day" #DB 테이블명

# api 세부 요청
lang = 'ko-kr'
details = 'true'
metric = 'true'

# 파싱된 데이터 출력

def new_insert(Location_code, area):
    ins = 0
    upd = 0
    try:
        location = accuweathergetcity.get_areacode(area) # api로 위치 코드를 받아와서 저장
    except:
        print(area, 'location url코드 오류')
        return -1

    # API 엔드포인트 URL
    url = f'https://dataservice.accuweather.com/forecasts/v1/daily/5day/{location}?apikey={api_key}&language={lang}&details={details}&metric={metric}'
    # API 요청 보내기
    try:
        response = requests.get(url)
    except:
        print(area, "API 요청 오류")
        return -1

    # JSON 데이터 파싱
    data = json.loads(response.content.decode('utf-8'))
    head = data["Headline"] # 응답 헤더정보
    dailyforecast = data["DailyForecasts"] # 응답 바디 정보

    counts = 0
    for i in dailyforecast:
        date = str(dailyforecast[counts]['Date'])
        date = date[:10]
        solar = dailyforecast[counts]['Day']['SolarIrradiance']['Value'] # 일조량 값 ( W/m^2 )
        hours = dailyforecast[counts]['HoursOfSun'] # 일조시간
        cloud = dailyforecast[counts]['Day']['CloudCover'] # 구름양 ( % )
        rain = dailyforecast[counts]['Day']['HoursOfRain'] # 비내린 시간
        snow = dailyforecast[counts]['Day']['HoursOfSnow'] # 눈내린 시간
        Min_temp = dailyforecast[counts]['Temperature']['Minimum']['Value'] # 최소 온도
        Max_temp = dailyforecast[counts]['Temperature']['Maximum']['Value'] # 최대 온도

        #DB에 UPDATE할건지 INSERT할건지
        ret = apidb.dbconselect_Location(table, date, Location_code)
        if len(ret) == 1: # 만약 값이 있다면 UPDATE로 값 갱신
            values = f'cloud = {cloud}, solar = {solar}, solar_time = {hours}, rainy = {rain}, snow = {snow}, MIN_temp = {Min_temp}, MAX_temp = {Max_temp}'
            apidb.dbconupdate_Location(table, values, date, Location_code)
            upd += 1

        else: # 만약 값이 없는 새로운 정보라면 INSERT로 값 등록
            values = f'0, "{date}", {cloud}, {solar}, {hours}, {rain}, {snow}, {Min_temp}, {Max_temp}, {Location_code}'
            apidb.dbconinsert(table, values)
            ins += 1
        counts += 1
    #print문들은 실행시 로그에 남기기위해 사용
    #print("ACCUWEATHER 5DAY FORCAST | ",get_time.get_today("-"), get_time.get_now_time(), "INSERT RATE :", ins, "UPDATE RATE :", upd) #log 확인용
    return