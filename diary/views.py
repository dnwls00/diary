from rest_framework import viewsets, status
from rest_framework.permissions import AllowAny,IsAuthenticated
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.authtoken.models import Token
from django.contrib.auth import authenticate
from django.contrib.auth.models import User
from .models import Diary
from .serializers import DiarySerializer

@api_view(['POST'])
@permission_classes([AllowAny])
def register_view(request):
    username = request.data.get('username')
    password = request.data.get('password')

    if User.objects.filter(username=username).exists():
        return Response(
            {'error': 'user_exists', 'message': '이미 사용 중인 아이디입니다'},
            status=status.HTTP_400_BAD_REQUEST
        )

    try:
        user = User.objects.create_user(username=username, password=password)
        return Response(
            {'message': '회원가입이 완료되었습니다'},
            status=status.HTTP_201_CREATED
        )
    except Exception as e:
        return Response(
            {'error': 'server_error', 'message': '서버 오류가 발생했습니다'},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
@api_view(['POST'])
@permission_classes([AllowAny])
def login_view(request):
    username = request.data.get('username')
    password = request.data.get('password')

    # 사용자 존재 여부 먼저 확인
    try:
        user = User.objects.get(username=username)
        # 비밀번호 검증
        if not user.check_password(password):
            return Response(
                {'error': 'wrong_password', 'message': '비밀번호가 올바르지 않습니다'},
                status=status.HTTP_400_BAD_REQUEST
            )
    except User.DoesNotExist:
        return Response(
            {'error': 'user_not_found', 'message': '존재하지 않는 아이디입니다'},
            status=status.HTTP_404_NOT_FOUND
        )

    # 인증 성공
    token, _ = Token.objects.get_or_create(user=user)
    return Response({'token': token.key})
class DiaryViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticated]
    serializer_class = DiarySerializer
    lookup_field = 'date'
    
    def get_queryset(self):
        return Diary.objects.filter(user=self.request.user)
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    def get_object(self):
        date = self.kwargs['date']
        return Diary.objects.get(user=self.request.user, date=date)