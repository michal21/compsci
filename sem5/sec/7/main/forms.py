from django import forms
from django.core.exceptions import ValidationError
from django.contrib.auth.models import User

from .models import *

class RegistrationForm(forms.Form):
    username = forms.CharField(label='Login', min_length=4, max_length=150)
    email = forms.EmailField(label='E-mail address')
    password = forms.CharField(label='Password', min_length=8, widget=forms.PasswordInput)
    vpassword = forms.CharField(label='Repeat password', min_length=8, widget=forms.PasswordInput)
    
    def clean_username(self):
        username = self.cleaned_data['username'] #.lower()
        r = User.objects.filter(username=username)
        if r.count() > 0:
            raise ValidationError("Username taken")
        return username
    
    def clean_email(self):
        email = self.cleaned_data['email'].lower()
        r = User.objects.filter(email=email)
        if r.count() > 0:
            raise ValidationError("Email already used")
        return email

    def clean_vpassword(self):
        password = self.cleaned_data.get('password')
        vpassword = self.cleaned_data.get('vpassword')
 
        if password and vpassword and password != vpassword:
            raise ValidationError("Password mismatch")
 
        return password
 
    def save(self, commit=True):
        user = User.objects.create_user(
            self.cleaned_data['username'],
            self.cleaned_data['email'],
            self.cleaned_data['password']
        )
        return user


class TransferForm(forms.ModelForm):
    class Meta:
        model = Transfer
        fields = ['to', 'title', 'amnt']

    def save(self, user, date, commit=True):
        inst = super(TransferForm, self).save(commit=False)
        inst.user = user
        inst.date = date

        if commit:
            inst.save()
            self.save_m2m()

        return inst
