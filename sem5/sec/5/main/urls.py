from django.urls import path

from .views import *

urlpatterns = [
    path('', index, name='index'),
    path('register', register, name='register'),
    path('registered', registered, name='registered'),
    path('profile', profile, name='profile'),
    path('new_transfer', new_transfer, name='new_transfer'),
    path('confirm_transfer', confirm_transfer, name='confirm_transfer'),
    path('history', history, name='history'),
]

