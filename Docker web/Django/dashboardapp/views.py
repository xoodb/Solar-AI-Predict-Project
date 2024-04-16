from django.contrib.auth.decorators import login_required
from django.core.paginator import Paginator, PageNotAnInteger
from django.http import HttpResponse
from django.shortcuts import render, redirect, get_object_or_404

from dashboardapp.form import BoardWriteForm, DeviceUpdateForm, DeviceCreateForm
from database.models import Device, Measurement, Board, UserData, Xytable, WeatherStorageDay
from .tasks import DeviceDataUpdate

# Create your views here.

# 장치 정보 받아오기
def GetData(user_id):
    devices = Device.objects.filter(
        id = user_id
    );
    return devices;

# 지역 정보 받아오기
def GetLoaction(location_code):
    location = Xytable.objects.filter(
        location_code = location_code
    );
    return location


# 현제 이용자가 작성자가 맞는가?
def is_writer(user_id, board_writer):
    return True if user_id == str(board_writer) else False

# (임시)
def Dashboard_display(request):
    return render(request, "main.html", {'device':GetData(request.user.id)});

def Device_display(request):
    return render(request, "device/device.html", {'device':GetData(request.user.id)});

# 게시판
def NoticeList(request):
    boards, paginator = BoardList('notice', request.GET.get('page'))
    return render(request, "board/board_list.html", {'boards': boards, 'paginator': paginator, 'board_type': 'notice', 'device': GetData(request.user.id)});

def PostList(request):
    boards, paginator = BoardList('post', request.GET.get('page'))
    return render(request, "board/board_list.html", {'boards': boards, 'paginator': paginator, 'board_type': 'post', 'device': GetData(request.user.id)});

def BoardList(board_type, page):
    boards = Board.objects.filter(
        board_type = board_type
    ).order_by('-board_id');
    paginator = Paginator(boards, 4)

    try:
        page_board = paginator.page(page)
    except PageNotAnInteger:
        page_board = paginator.page(1)
    return page_board, paginator

def BoardWrite(request, board_type):
    print(board_type)
    context = {}
    if request.user.id:
        if request.method == 'GET':
            return render(request, 'board/board_write.html', {'forms': BoardWriteForm(), 'device':GetData(request.user.id)})

        elif request.method == 'POST':
            write_form = BoardWriteForm(request.POST)
            if write_form.is_valid():
                from datetime import datetime
                board = Board(
                    title = write_form.title,
                    content = write_form.content,
                    writer = UserData.objects.get(id=request.user.id),
                    write_date = datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
                    board_type = board_type,
                )
                board.save()
                return redirect('/dashboard/' + board_type)
        else:
            return HttpResponse('Invalid Request')
    return HttpResponse('Invalid Request')

def BoardContent(request, board_type, board_id):
    previous_url = request.META.get('HTTP_REFERER', '/')  # 이전 목록으로
    board = Board.objects.get(
        board_id = board_id
    )
    return render(request, 'board/board_content.html',{'board':board, 'device': GetData(request.user.id),
                                                       'previous_url': previous_url, 'is_writer' : is_writer(request.user.id, board.writer)})


def BoardDelete(request, board_type, board_id):
    # 게시글 객체 가져오기
    board = get_object_or_404(Board, board_type=board_type, board_id=board_id)
    # 삭제
    board.delete()
    if board_type == 'notice':
        return redirect('dashboardapp:notice')
    elif board_type == 'post':
        return redirect('dashboardapp:post')
    else:
        return HttpResponse('Invalid Request')

def BoardEdit(request, board_id):
    board = get_object_or_404(Board, board_id=board_id)
    if request.method == 'POST':
        form = BoardWriteForm(request.POST, instance=board)
        if form.is_valid():
            form.save()
            return redirect('dashboardapp:content', board_id=board_id, board_type=board.board_type)
    else:
        form = BoardWriteForm(instance=board)
    return render(request, 'board/board_edit.html', {'form': form, 'board_id': board_id, 'writer': board.writer,
                                                     'is_writer': is_writer(request.user.id, board.writer)})

# 차트 밑 표 구성을 위한 데이터 전송
def DisplayData(request, device_id):
    queryset = {}
    device = Device.objects.get(id=request.user.id, device_id=device_id)
    # db에는 현재 날짜 기준으로 2일치가 추가 저장되기 때문에 역순으로 3개만 가져와 준다.
    weather = WeatherStorageDay.objects.filter(location_code=device.location_code).order_by('-date')[:3];
    if device:
        queryset = Measurement.objects.filter(
            device_id = device_id
        ).order_by('-measure_date')[:30].values("measure_date", "measure", "predictive_measure", "measurement_accuracy")
        return render(request, 'chart.html', {'queryset': list(queryset)[::-1], 'device_id': device_id, 'device': GetData(request.user.id), 'my_device': device, 'weather': reversed(weather)})
    else:
        return HttpResponse('Invalid Request')
    
def NewDeviceDataUpdate(device_name, location_code):
    DeviceDataUpdate.delay(str(device_name), str(location_code))
    return

# 기기 등록
@login_required
def DeviceCreate(request):
    if request.method == 'POST':
        form = DeviceCreateForm(request.POST)
        if form.is_valid():
            device = form.save(commit=False)
            city = request.POST.get('city')
            district = request.POST.get('district')
            area = request.POST.get('dong')
            device_name = device
            device.id = UserData.objects.get(id=request.user.id)

            print(city, district, area)

            try:
                location_code = Xytable.objects.get(city=city, district=district, area=area)
                device.location_code = location_code
                device.save()
            except Xytable.DoesNotExist:
                print("error")
                pass
            NewDeviceDataUpdate(device_name, location_code)
            return redirect('dashboardapp:device')
    else:
        form = DeviceCreateForm()
    return render(request, 'device/device_create.html', {'form': form, 'device':GetData(request.user.id)})

@login_required
def get_districts(request):
    city = request.GET.get('city', None)
    districts = Xytable.objects.filter(city=city).values_list('district', flat=True).distinct()

    # HTML 옵션 태그로 반환
    options = ''.join(['<option value="{0}">{0}</option>'.format(d) for d in districts])
    return HttpResponse(options)

@login_required
def get_dong(request):
    city = request.GET.get('city', None)
    district = request.GET.get('district', None)
    districts = Xytable.objects.filter(city=city, district=district).values_list('area', flat=True).distinct()

    # HTML 옵션 태그로 반환
    options = ''.join(['<option value="{0}">{0}</option>'.format(d) for d in districts])
    return HttpResponse(options)

@login_required
# 기기 수정
def DeviceUpdate(request, device_id):
    devices = get_object_or_404(Device, device_id=device_id)
    if request.method == 'POST':
        form = DeviceUpdateForm(request.POST, instance=devices)
        if form.is_valid():
            form.save()
            return redirect('dashboardapp:device')
    else:
        form = DeviceUpdateForm(instance=devices)
    return render(request, 'device/device_update.html', {'form': form, 'device_id': device_id, 'device':GetData(request.user.id)})
