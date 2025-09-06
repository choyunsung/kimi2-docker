.PHONY: help build up down logs shell clean test

help:
	@echo "Kimi-K2 Docker Management Commands"
	@echo ""
	@echo "Usage:"
	@echo "  make build    - Docker 이미지 빌드"
	@echo "  make up       - 서비스 시작"
	@echo "  make down     - 서비스 중지"
	@echo "  make logs     - 로그 확인"
	@echo "  make shell    - 컨테이너 쉘 접속"
	@echo "  make clean    - 컨테이너와 볼륨 정리"
	@echo "  make test     - API 테스트"

build:
	docker-compose build

up:
	docker-compose up -d

down:
	docker-compose down

logs:
	docker-compose logs -f kimi-k2

shell:
	docker exec -it kimi-k2-server /bin/bash

clean:
	docker-compose down -v
	rm -rf models/ data/

test:
	@echo "Testing Kimi-K2 API..."
	@curl -s http://localhost:8000/health | jq . || echo "Health check failed"
	@echo ""
	@echo "Testing chat completion..."
	@curl -s http://localhost:8000/v1/chat/completions \
		-H "Content-Type: application/json" \
		-d '{"model": "kimi-k2", "messages": [{"role": "user", "content": "Hello!"}]}' | jq .