from django.db import models

class User(models.Model):
    name = models.CharField(max_length=100)
    password = models.CharField(max_length=100)
    password1 = models.CharField(max_length=100)
    phone = models.CharField(max_length=100)

    first_name = None
    last_name = None
    is_superuser = None
    is_staff = None
    last_login = None
    date_joined = None

    def __str__(self):
        return self.name
