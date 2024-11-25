from django.urls import path
from .views import DiaryViewSet

urlpatterns = [
    path('diaries/', DiaryViewSet.as_view({
        'get': 'list',
        'post': 'create'
    })),
    path('diaries/<str:date>/', DiaryViewSet.as_view({
        'get': 'retrieve',
        'put': 'update',
        'delete': 'destroy'
    })),
]