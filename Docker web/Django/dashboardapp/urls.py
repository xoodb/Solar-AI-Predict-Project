from django.urls import path, include
from dashboardapp import views

app_name = "dashboardapp"

urlpatterns = [
    # path('list/', views.ShowData, name='list'),
    path('main/', views.Dashboard_display, name='main'),
    path('chart/<str:device_id>', views.DisplayData, name='chart'),

    # 게시판
    path('notice', views.NoticeList, name='notice'),
    path('post', views.PostList, name='post'),
    path('write/<str:board_type>/', views.BoardWrite, name='write'),
    path('content/<str:board_type>/<int:board_id>/', views.BoardContent, name='content'),
    path('edit/<int:board_id>/', views.BoardEdit, name='edit'),
    path('delete/<str:board_type>/<int:board_id>/', views.BoardDelete, name='delete'),

    path('device/', views.Device_display, name='device'),
    path('device/update/<str:device_id>/', views.DeviceUpdate, name='device_update'),
    path('device/create/', views.DeviceCreate, name='device_create'),

    path('device/get_districts/', views.get_districts, name="get_district"),
    path('device/get_dong/', views.get_dong, name="get_dong"),
]