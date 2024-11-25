from django.contrib import admin
from .models import Diary

@admin.register(Diary)
class DiaryAdmin(admin.ModelAdmin):
    list_display = ('user', 'date', 'content')
    list_filter = ('user', 'date')
    search_fields = ('content',)