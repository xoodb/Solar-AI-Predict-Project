from django.shortcuts import render, redirect


# Create your views here.


def home_display(request):
    return render(request, 'home.html')

def redirect_home(request):
    return redirect('/main/home')