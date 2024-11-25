from django.contrib import admin
from django.urls import path, include
from diary.views import register_view, login_view

urlpatterns = [
    path('admin/', admin.site.urls),  # 관리자 페이지 URL 추가
    path('api/', include('diary.urls')),  # diary 앱의 URLs
    path('api/register/', register_view, name='register'),
    path('api/login/', login_view, name='login'),
]