from django.shortcuts import render
from django.contrib.auth.decorators import login_required

# Create your views here.
from django.http import HttpResponse, HttpResponseRedirect
from django.utils import timezone

from .forms import *;
from .models import *;

def index(request):
    return HttpResponseRedirect('/login')
    return HttpResponse('Hello, World!')

def register(request):
    if request.method != 'POST':
        return render(request, 'register.html', {'form': RegistrationForm()})

    f = RegistrationForm(request.POST)
    if f.is_valid():
        f.save()
        return HttpResponseRedirect('/registered')
    else:
        return render(request, 'register.html', {'form': f})

def registered(request):
    return render(request, 'registered.html')

@login_required
def profile(request):
    return render(request, 'profile.html')

@login_required
def new_transfer(request):
    if request.method != 'POST':
        return render(request, 'new_transfer.html', {'form': TransferForm()})

    f = TransferForm(request.POST)
    if f.is_valid():
        f.save(user=request.user, date=timezone.now())
        return HttpResponseRedirect('/confirm_transfer')
    else:
        return render(request, 'new_transfer.html', {'form': f})

@login_required
def confirm_transfer(request):
    utrfs = [_ for _ in Transfer.objects.all() if _.user_id == request.user.id and _.accpt == False]
    if request.method == 'POST':
        for t in utrfs:
            t.accpt = True
            t.save()
        return HttpResponseRedirect('/profile')
    else:
        return render(request, 'confirm_transfer.html', {'transfers': utrfs})

@login_required
def history(request):
    utrfs = [_ for _ in Transfer.objects.all() if _.user_id == request.user.id]
    return render(request, 'history.html', {'transfers': utrfs})

