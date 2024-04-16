from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth import get_user_model

class CustomUserCreationForm(UserCreationForm):
    # UserCreationForm을 상속받아 CustomUserCreationForm을 만든다.

    class Meta:
        model = get_user_model() # 이 폼이 적용될 모델을 지정한다.
        fields = ['id', 'name', 'phone_number', 'email']
        # 이 폼에서 입력 받을 필드명을 지정한다.
