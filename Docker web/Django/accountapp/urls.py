from django.urls import path
from accountapp.views import AccountCreateView, AccountDeleteView, AccountDetailView, AccountUpdateView

from django.contrib.auth.views import LoginView, LogoutView

from . import views

app_name = "accountapp"

urlpatterns = [
    # 함수형 : 함수_이름
    # 클래스형 : 클래스_이름.as_view()
    path('create/', AccountCreateView.as_view(), name='create'),

    path('login/', LoginView.as_view(template_name='login.html'), name='login'),
    path('logout/', LogoutView.as_view(), name='logout'),
    path('delete/<str:pk>', AccountDeleteView.as_view(), name='delete'),
    path('detail/<str:pk>', AccountDetailView.as_view(), name='detail'),
    path('update/<str:pk>', AccountUpdateView.as_view(), name='update'),
]

