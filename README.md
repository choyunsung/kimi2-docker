# Kimi-K2 Docker Self-Host Setup

Kimi-K2 모델을 Docker로 셀프 호스팅하기 위한 설정입니다.

## 요구사항

- Docker & Docker Compose
- NVIDIA GPU (최소 VRAM 32GB 권장)
- NVIDIA Container Toolkit
- 충분한 저장 공간 (모델 다운로드를 위해 ~100GB)

## 빠른 시작

### 1. NVIDIA Container Toolkit 설치

```bash
# Ubuntu/Debian
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker
```

### 2. 환경 설정

```bash
# .env 파일 생성
cp .env.example .env

# 필요에 따라 .env 파일 수정
nano .env
```

### 3. Docker 이미지 빌드 및 실행

```bash
# 이미지 빌드
docker-compose build

# 서비스 시작
docker-compose up -d

# 로그 확인
docker-compose logs -f kimi-k2
```

## 사용 방법

### OpenAI 호환 API 사용

서버가 실행되면 OpenAI API와 호환되는 엔드포인트를 사용할 수 있습니다:

```python
from openai import OpenAI

client = OpenAI(
    base_url="http://localhost:8000/v1",
    api_key="your-api-key"  # .env 파일에 설정한 키
)

response = client.chat.completions.create(
    model="kimi-k2",
    messages=[
        {"role": "user", "content": "안녕하세요! 자기소개를 해주세요."}
    ],
    temperature=0.7,
    max_tokens=1000
)

print(response.choices[0].message.content)
```

### cURL 예제

```bash
curl http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your-api-key" \
  -d '{
    "model": "kimi-k2",
    "messages": [
      {"role": "user", "content": "Hello!"}
    ]
  }'
```

## 구성 옵션

### 환경 변수 (.env)

- `MODEL_NAME`: 사용할 모델 (기본값: moonshot-ai/kimi-k2-instruct)
- `MAX_MODEL_LEN`: 최대 컨텍스트 길이 (기본값: 32768)
- `TENSOR_PARALLEL_SIZE`: GPU 병렬 처리 수 (기본값: 1)
- `GPU_MEMORY_UTILIZATION`: GPU 메모리 사용률 (기본값: 0.95)
- `API_KEY`: API 인증 키

### 메모리 요구사항

- **Kimi-K2 Base**: ~64GB VRAM (2x A100 40GB 권장)
- **Kimi-K2 Instruct**: ~64GB VRAM
- **양자화 버전 (INT4)**: ~16-24GB VRAM

### 다중 GPU 설정

여러 GPU를 사용하려면:

```bash
# .env 파일에서 설정
TENSOR_PARALLEL_SIZE=2  # GPU 2개 사용
CUDA_VISIBLE_DEVICES=0,1  # GPU 0번과 1번 사용
```

## 프로덕션 배포

### SSL 설정

1. SSL 인증서를 `./ssl` 디렉토리에 배치
2. `nginx.conf`의 SSL 섹션 주석 해제
3. 도메인 이름 수정

### 성능 최적화

```bash
# 더 작은 컨텍스트 길이로 메모리 절약
MAX_MODEL_LEN=8192

# GPU 메모리 사용률 조정
GPU_MEMORY_UTILIZATION=0.9
```

## 문제 해결

### GPU를 인식하지 못하는 경우

```bash
# NVIDIA 드라이버 확인
nvidia-smi

# Docker가 GPU를 인식하는지 확인
docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi
```

### 메모리 부족 오류

- `MAX_MODEL_LEN` 값 감소
- `GPU_MEMORY_UTILIZATION` 값 감소
- 양자화된 모델 사용 고려

### 모델 다운로드 문제

```bash
# Hugging Face 토큰 설정 (프라이빗 모델의 경우)
export HF_TOKEN=your-huggingface-token
```

## 모니터링

### 헬스 체크

```bash
curl http://localhost:8000/health
```

### 메트릭 확인

```bash
curl http://localhost:8000/metrics
```

## 중지 및 정리

```bash
# 서비스 중지
docker-compose down

# 볼륨 포함 완전 정리
docker-compose down -v

# 이미지 삭제
docker rmi kimi2-docker_kimi-k2
```

## 라이선스

이 프로젝트는 Kimi-K2 모델의 라이선스 조건을 따릅니다. 상업적 사용 시 원본 라이선스를 확인하세요.

## 참고 자료

- [Kimi-K2 GitHub](https://github.com/choyunsung/Kimi-K2)
- [vLLM Documentation](https://docs.vllm.ai/)
- [OpenAI API Reference](https://platform.openai.com/docs/api-reference)