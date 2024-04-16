# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey has `on_delete` set to the desired behavior.
#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.
from django.contrib.auth.base_user import BaseUserManager
from django.contrib.auth.models import UserManager, AbstractUser, PermissionsMixin
from django.db import models

class UserManager(BaseUserManager):
    def create_user(self, id, password=None, **extra_fields):
        """
        Creates and saves a User with the given id and password.
        """
        if not id:
            raise ValueError('The ID must be set')

        user = self.model(id=id, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, id, password=None, **extra_fields):
        """
        Creates and saves a superuser with the given id and password.
        """
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)

        if extra_fields.get('is_staff') is not True:
            raise ValueError('Superuser must have is_staff=True.')
        if extra_fields.get('is_superuser') is not True:
            raise ValueError('Superuser must have is_superuser=True.')

        return self.create_user(id, password, **extra_fields)

class Device(models.Model):
    id = models.ForeignKey('UserData', models.DO_NOTHING, db_column='ID')  # Field name made lowercase.
    device_id = models.CharField(db_column='device_ID', primary_key=True, max_length=20)  # Field name made lowercase.
    location_code = models.ForeignKey('Xytable', models.DO_NOTHING, db_column='Location_code')  # Field name made lowercase.
    area = models.CharField(max_length=20)
    power_generation_capacity = models.CharField(db_column='power generation capacity', max_length=20)  # Field renamed to remove unsuitable characters.
    efficiency = models.FloatField()

    class Meta:
        managed = False
        db_table = 'device'


class DjangoContentType(models.Model):
    name = models.CharField(max_length=100)
    app_label = models.CharField(max_length=100)
    model = models.CharField(max_length=100)

    class Meta:
        managed = False
        db_table = 'django_content_type'


class DjangoMigrations(models.Model):
    app = models.CharField(max_length=255)
    name = models.CharField(max_length=255)
    applied = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'django_migrations'


class Measurement(models.Model):
    device = models.ForeignKey(Device, models.DO_NOTHING, db_column='device_ID')  # Field name made lowercase.
    measure_date = models.DateField()
    measure = models.CharField(max_length=100)
    predictive_measure = models.CharField(max_length=100)
    measurement_accuracy = models.FloatField()
    measure_number = models.AutoField(primary_key=True)

    class Meta:
        managed = False
        db_table = 'measurement'

class UserData(AbstractUser, PermissionsMixin):
    id = models.CharField(db_column='ID', primary_key=True, max_length=20)
    password = models.CharField(max_length=100)
    name = models.CharField(max_length=20)
    phone_number = models.CharField(db_column='phone number', max_length=13)
    is_active = models.IntegerField()
    is_superuser = models.IntegerField()
    email = models.CharField(db_column='email', max_length=254)

    USERNAME_FIELD = 'id'
    REQUIRED_FIELDS = ['password', 'name', 'phone_number', 'email']

    first_name = None
    last_name = None
    is_staff = None
    last_login = None
    date_joined = None
    username = None

    objects = UserManager()

    class Meta:
        managed = False
        db_table = 'user_data'

    def __str__(self):
        return str(self.id)



class WeatherStorageDay(models.Model):
    date = models.CharField(db_column='Date', primary_key=True, max_length=10)  # Field name made lowercase.
    location_code = models.ForeignKey('Xytable', models.DO_NOTHING, db_column='Location_code')  # Field name made lowercase.
    sunrise = models.FloatField(db_column='Sunrise')  # Field name made lowercase.
    sunset = models.FloatField(db_column='Sunset')  # Field name made lowercase.
    min_temp = models.FloatField(db_column='Min_Temp')  # Field name made lowercase.
    max_temp = models.FloatField(db_column='Max_Temp')  # Field name made lowercase.
    rainfall = models.FloatField(db_column='Rainfall')  # Field name made lowercase.
    wind_speed = models.FloatField(db_column='Wind_speed')  # Field name made lowercase.
    humidity = models.FloatField(db_column='Humidity')  # Field name made lowercase.
    cloud = models.FloatField(db_column='Cloud')  # Field name made lowercase.
    predict_solar_power = models.FloatField()

    class Meta:
        managed = False
        db_table = 'weather_storage_Day'

class Xytable(models.Model):
    location_code = models.BigIntegerField(db_column='Location_code', primary_key=True)  # Field name made lowercase.
    city = models.CharField(max_length=40)
    district = models.CharField(max_length=40)
    area = models.CharField(max_length=40)
    x = models.IntegerField()
    y = models.IntegerField()
    longitude_hour = models.IntegerField()
    longitude_min = models.IntegerField()
    longitude_sec = models.FloatField()
    latitude_hour = models.IntegerField(db_column='Latitude_hour')  # Field name made lowercase.
    latitude_min = models.IntegerField(db_column='Latitude_min')  # Field name made lowercase.
    latitude_sec = models.FloatField(db_column='Latitude_sec')  # Field name made lowercase.
    longitude_sec_100 = models.FloatField(db_column='longitude_sec/100')  # Field renamed to remove unsuitable characters.
    latitude_sec_100 = models.FloatField(db_column='Latitude_sec/100')  # Field name made lowercase. Field renamed to remove unsuitable characters.

    class Meta:
        managed = False
        db_table = 'xytable'

# DB 1차 테이블 추가(수정)

class SolarApi(models.Model):
    date = models.DateField()
    cloud = models.FloatField(blank=True, null=True)
    solar = models.FloatField(blank=True, null=True)
    num_count = models.AutoField(primary_key=True)

    class Meta:
        managed = False
        db_table = 'solar_api'


class SolarApi5Day(models.Model):
    num_count = models.AutoField(primary_key=True)
    date = models.DateField()
    cloud = models.FloatField()
    solar = models.FloatField()
    solar_time = models.FloatField()

    class Meta:
        managed = False
        db_table = 'solar_api_5day'

# 게시판 작업

class Board(models.Model):
    board_id = models.AutoField(primary_key=True)
    title = models.CharField(max_length=64)
    writer = models.ForeignKey('UserData', models.DO_NOTHING, db_column='writer')
    write_date = models.DateTimeField()
    content = models.TextField()
    board_type = models.CharField(max_length=30)

    class Meta:
        managed = False
        db_table = 'board'