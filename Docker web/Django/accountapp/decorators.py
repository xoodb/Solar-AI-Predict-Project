from django.contrib.auth.models import User
from django.http import HttpResponseForbidden

from database.models import UserData


def account_ownership_required(func):
    def decorated(request, *args, **kwargs):
        user = UserData.objects.get(pk=kwargs['pk'])
        if not user == request.user:
            return HttpResponseForbidden()
        return func(request, *args, **kwargs)
    return decorated