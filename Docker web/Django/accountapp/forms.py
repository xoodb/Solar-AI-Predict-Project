from django import forms

from database.CustomUser import User


class UserForm(forms.ModelForm):
    class Meta:
        model = User
        widgets = {
            'password': forms.PasswordInput(),
        }