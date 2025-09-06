# Kilo Code와 Kimi-K2 통합 가이드

Kilo Code VS Code 확장과 Kimi-K2 Docker 서버를 연동하여 사용하는 방법입니다.

## 1. Kimi-K2 서버 실행

먼저 Kimi-K2 Docker 서버를 시작합니다:

```bash
# Docker 서비스 시작
docker-compose up -d

# 서버 상태 확인
curl http://localhost:8000/health
```

## 2. Kilo Code 설정

### VS Code에서 Kilo Code 설치

1. VS Code Extensions에서 "Kilo Code" 검색
2. Install 클릭하여 설치

### Kilo Code에 Kimi-K2 연결

VS Code settings.json에 다음 설정 추가:

```json
{
  "kilocode.customModels": [
    {
      "id": "kimi-k2-local",
      "name": "Kimi-K2 (Local)",
      "provider": "openai",
      "baseUrl": "http://localhost:8000/v1",
      "apiKey": "your-api-key",
      "model": "kimi-k2",
      "maxTokens": 32768,
      "temperature": 0.7,
      "contextLength": 128000
    }
  ],
  "kilocode.defaultModel": "kimi-k2-local",
  "kilocode.enableAutocomplete": true,
  "kilocode.autocompleteModel": "kimi-k2-local"
}
```

## 3. 사용 방법

### 기본 사용

1. **코드 생성**: 
   - Ctrl+Shift+P → "Kilo Code: Generate Code"
   - 자연어로 요청 입력
   - Kimi-K2가 코드 생성

2. **코드 리팩토링**:
   - 코드 선택 → 우클릭 → "Kilo Code: Refactor"
   - 리팩토링 요구사항 입력

3. **디버깅 도움**:
   - 에러 메시지 선택 → "Kilo Code: Debug"
   - Kimi-K2가 해결책 제시

### 고급 기능

#### 아키텍처 모드
```json
{
  "kilocode.architectMode": {
    "enabled": true,
    "model": "kimi-k2-local",
    "systemPrompt": "당신은 시스템 아키텍트입니다. 확장 가능하고 유지보수가 쉬운 설계를 제안해주세요."
  }
}
```

#### 자동 완성
```json
{
  "kilocode.autocomplete": {
    "enabled": true,
    "model": "kimi-k2-local",
    "debounceDelay": 500,
    "maxSuggestions": 3,
    "contextLines": 50
  }
}
```

#### 커밋 메시지 자동 생성
```json
{
  "kilocode.assistedCommits": {
    "enabled": true,
    "model": "kimi-k2-local",
    "language": "korean",
    "conventionalCommits": true
  }
}
```

## 4. 성능 최적화

### Kimi-K2 서버 최적화

docker-compose.yml 수정:

```yaml
services:
  kimi-k2:
    environment:
      - MAX_MODEL_LEN=8192  # 빠른 응답을 위해 컨텍스트 축소
      - GPU_MEMORY_UTILIZATION=0.9
      - MAX_NUM_SEQS=10  # 동시 요청 수 조정
```

### Kilo Code 최적화

```json
{
  "kilocode.performance": {
    "cacheResponses": true,
    "cacheDuration": 3600,
    "streamResponses": true,
    "timeout": 30000
  }
}
```

## 5. 문제 해결

### 연결 오류

```bash
# Docker 로그 확인
docker-compose logs kimi-k2

# 포트 확인
netstat -an | grep 8000
```

### 느린 응답

- MAX_MODEL_LEN 값 감소
- GPU_MEMORY_UTILIZATION 조정
- 동시 요청 수 제한

### API 키 문제

.env 파일에서 API_KEY 설정:
```
API_KEY=your-secure-api-key
```

VS Code settings.json에 동일한 키 사용:
```json
"apiKey": "your-secure-api-key"
```

## 6. 활용 예시

### 한국어 코드 설명
```javascript
// Kilo Code에 요청: "이 함수를 한국어로 설명해주세요"
function complexAlgorithm(data) {
  // Kimi-K2가 한국어로 상세 설명 제공
}
```

### 테스트 코드 생성
```javascript
// Kilo Code에 요청: "이 함수의 Jest 테스트 코드를 작성해주세요"
function calculateTotal(items) {
  // Kimi-K2가 완전한 테스트 스위트 생성
}
```

### 보안 검토
```python
# Kilo Code에 요청: "이 코드의 보안 취약점을 찾아주세요"
def handle_user_input(data):
    # Kimi-K2가 보안 이슈 분석 및 개선안 제시
    pass
```

## 7. 추가 리소스

- [Kilo Code 공식 문서](https://github.com/Kilo-Org/kilocode)
- [Kimi-K2 Docker 설정](https://github.com/choyunsung/kimi2-docker)
- [vLLM 성능 튜닝 가이드](https://docs.vllm.ai/)