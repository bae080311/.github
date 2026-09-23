# 보안

## 취약점 신고

공개 이슈로 올리지 말고 [GitHub Security Advisory](https://github.com/bae080311)
비공개 신고 기능을 쓰거나, 해당 레포의 Security 탭에서 "Report a vulnerability" 를 연다.

공개 배포물(`@jump-section/*` npm 패키지)의 취약점은 우선 처리한다.

## 이 레포들의 원칙

- **토큰은 항상 fine-grained + 최소 권한.** Administration, Workflows(write), Organization
  권한은 어떤 자동화 주체에게도 주지 않는다
- **시크릿을 커밋하지 않는다.** `.env` 는 항상 gitignore
- **보안 가드는 부분문자열 비교로 판정하지 않는다.** 구조를 파싱해 앵커 비교하고, 가드를 고치면
  회귀 테스트를 같은 변경에 추가한다
- **자동화는 실패가 관측 가능해야 한다.** 조용히 실패하는 자동화는 없는 것보다 나쁘다 —
  있다고 착각하게 만든다
