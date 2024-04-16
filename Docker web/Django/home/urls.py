from django.urls import path

from home.views import home_display

app_name = "home"

urlpatterns = [
    path('home/', home_display, name="home")
]