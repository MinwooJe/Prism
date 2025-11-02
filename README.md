# Prism

**Prism**은 SwiftUI의 `AsyncImage`를 개선한 경량 이미지 로딩 라이브러리입니다.  
메모리 캐싱과 AsyncStream 기반 상태 관리를 통해 효율적인 이미지 로딩 경험을 제공합니다.

## ✨ 주요 기능

### 🚀 AsyncStream 기반 비동기 이미지 로딩
- Swift Concurrency의 AsyncStream을 활용한 실시간 로딩 상태 전달
- `.empty` → `.loading` → `.loaded` / `.failed` 상태 흐름
- SwiftUI의 선언적 패러다임과 자연스러운 통합

### 💾 메모리 캐싱
- **NSCache 기반** 자동 메모리 관리
- 동일 이미지 재요청 시 네트워크 호출 없이 즉시 반환

---

## 📦 요구사항

- **iOS 15.0+**
- **Swift 5.9+**
- **Xcode 15.0+**

## 🏗️ 아키텍처
<img width="5149" height="2745" alt="image" src="https://github.com/user-attachments/assets/babe473e-a6f1-4d0a-a20d-d86a3c47e379" />


## 🔮 개발 예정 기능

### 디스크 캐싱
- [ ] FileManager 기반 영구 저장
- [ ] URL을 SHA256 해시로 변환하여 안전한 파일명 생성
- [ ] `.cachesDirectory` 활용한 자동 용량 관리

### 다운샘플링
- [ ] ImageIO 프레임워크를 활용한 메모리 효율적 이미지 리사이징
- [ ] 큰 이미지를 작은 크기로 표시할 때 메모리 사용량 최소화

### 메모리 경고 대응
- [ ] `NotificationCenter`로 메모리 경고 감지
- [ ] 자동으로 메모리 캐시 일부 해제

### UIKit 지원
- [ ] UIImageView extension 제공
- [ ] `imageView.prism.setImage(with:)` 스타일 API

# 고민한 지점
### (1) 이미지 캐싱 시 데이터 타입: UIImage vs NSData
- NSData
    - 장점: UIImage와 비교해 캐싱 시 메모리 사용 부담이 적음.
    - 단점: 캐싱 후 렌더링을 위해 디코딩, 작업이 필요.
        - JPEG/PNG 이미지의 경우 압축 해제 및 디코딩이 필요함.
        - 디코딩은 CPU Intensive 작업이므로 Hang 발생 우려.
- UIImage
    - 장점: 디코딩 된 이미지를 바로 저장하므로 성능 최적화 가능.
    - 단점: NSData와 비교해 캐싱 시 메모리 사용량 증가.

### (3) 결론
캐싱의 주요 목적은 성능 향상과 사용자 경험 개선입니다. 메모리 캐시의 경우 스크롤 시 빠른 이미지 로딩이 사용자 경험에 직접적인 영향을 미치므로 반응성 확보가 우선이라고 판단했습니다.   
따라서 메모리 캐싱 시에는 디코딩이 완료된 UIImage를 저장하도록 구현했습니다.

