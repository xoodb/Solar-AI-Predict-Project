import get_time

print(f'\n--------START : {get_time.get_today("-")} {get_time.get_now_time()}--------')
print('ACCUWEATHER 5DAY FORCAST | ', end='')
import accuweather5days
print('24H FORCAST | ', end='')
import afterdata_24h
print('SORT FORCAST DATA | ', end='')
import afterdata_Day
print('PREDICT MODUL | ', end='')
import use_LSTM_modul
print('CALCULATION MODUL GENERATE | ', end='')
import predict_device
print(f'--------END : {get_time.get_today("-")} {get_time.get_now_time()}--------\n')
