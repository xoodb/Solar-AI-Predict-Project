from django import forms
from django_summernote.fields import SummernoteTextField
from django_summernote.widgets import SummernoteWidget

from database.models import Board, Device, Xytable


class BoardWriteForm(forms.ModelForm):

    title = forms.CharField(
        label = "제목",
        widget = forms.TextInput(
            attrs = {
                'placeholder' : '게시글 제목',
                'class' : 'form-control mb-2'
            }
        ), required=True,
    )

    content = SummernoteTextField()

    field_order = [
        'title',
        'content',
    ]

    class Meta:
        model = Board
        fields = [
            'title',
            'content',
        ]
        widgets = {
            'content' :  SummernoteWidget()
        }

    def clean(self):
        cleaned_data = super().clean()

        title = cleaned_data.get('title', '')
        content = cleaned_data.get('content', '')

        if title == '':
            self.add_error('title', '제목을 입력하세요')
        elif content == '':
            self.add_error('content', '글 내용을 입력하세요')
        else:
            self.title = title
            self.content = content

class DeviceUpdateForm(forms.ModelForm):
    class Meta:
        model = Device
        fields = ['area', 'power_generation_capacity', 'efficiency']

    # 필드명 바꿔주기
    area = forms.CharField(label="총 면적")
    power_generation_capacity = forms.CharField(label="총 발전량")
    efficiency = forms.CharField(label="효율")

class DeviceCreateForm(forms.ModelForm):
    class Meta:
        model = Device
        fields = ['device_id', 'area', 'power_generation_capacity', 'efficiency']

    # 필드명 바꿔주기
    device_id = forms.CharField(label="장치명")
    area = forms.CharField(label="총 면적")
    power_generation_capacity = forms.CharField(label="총 발전량")
    efficiency = forms.CharField(label="효율")

