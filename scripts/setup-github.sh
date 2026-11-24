#!/usr/bin/env bash
# AutoDevFlow GitHub 초기 설정: 라벨, Milestone 10개, 01~02 초기 이슈
# 사용법: 저장소를 push한 뒤 저장소 폴더에서 실행
#   gh auth login   (처음 한 번)
#   bash scripts/setup-github.sh
set -euo pipefail

REPO="$(gh repo view --json nameWithOwner -q .nameWithOwner)"
echo "대상 저장소: $REPO"

# ---------- 라벨 ----------
label() { gh label create "$1" --color "$2" --description "$3" --force >/dev/null; echo "  label: $1"; }
echo "[1/3] 라벨 생성"
label "type:task"       "1D76DB" "계획된 작업"
label "type:docs"       "0E8A16" "산출물 문서"
label "type:defect"     "D73A4A" "코드, 데이터, 문서의 오류"
label "type:decision"   "5319E7" "방향 결정이 필요한 논의 (ADR)"
label "type:experiment" "FBCA04" "실험 설계와 실행"
label "area:analysis"   "C5DEF5" "업무 분석, 선행 연구"
label "area:spec"       "C5DEF5" "요구사항 명세"
label "area:dataset"    "C5DEF5" "기준 데이터셋, Gold Dataset"
label "area:core"       "C5DEF5" "Artifact Registry, Trace Graph, Version, Evidence"
label "area:change"     "C5DEF5" "변경 영향도 분석"
label "area:verify"     "C5DEF5" "변경 후 검증, 시험 연동"
label "area:eval"       "C5DEF5" "평가 스크립트와 결과"
label "area:repo"       "C5DEF5" "저장소 운영, CI"
label "status:blocked"  "B60205" "외부 요인으로 진행 불가"

# ---------- Milestone ----------
echo "[2/3] Milestone 생성"
milestone() {
  local title="$1" desc="$2"
  if gh api "repos/$REPO/milestones?state=all&per_page=100" -q '.[].title' | grep -Fxq "$title"; then
    echo "  (있음) $title"
  else
    gh api "repos/$REPO/milestones" -f title="$title" -f description="$desc" >/dev/null
    echo "  milestone: $title"
  fi
}
milestone "01 업무 분석서"                     "자동화 대상 업무 선정 (v0.1.0)"
milestone "02 기존 솔루션 및 선행 연구 분석서" "프로젝트 차별화 근거 확보 (v0.2.0)"
milestone "03 자동 전조등 요구사항 명세서"     "실험 대상 정의 (v0.3.0)"
milestone "04 설계·코드·시험 기준 데이터셋"   "검증 환경 구축 (v0.4.0)"
milestone "05 플랫폼 요구사항 명세서"          "개발 범위 확정 (v0.5.0)"
milestone "06 데이터 모델 및 시스템 아키텍처"  "공통 엔지니어링 기반 설계 (v0.6.0)"
milestone "07 변경 시나리오 및 Gold Dataset"   "평가 환경 구축 (v0.7.0)"
milestone "08 MVP 구현"                        "첫 번째 핵심 기능 개발 (v0.8.0)"
milestone "09 AI 적용 효과 검증 보고서"        "정량적 성과 측정 (v0.9.0)"
milestone "10 통합 및 확장 계획서"             "후속 미니 프로젝트 연결 (v1.0.0)"

# ---------- 초기 이슈 ----------
echo "[3/3] 초기 이슈 생성"
issue() {
  local title="$1" ms="$2" labels="$3" body="$4"
  if gh issue list --state all --search "in:title \"$title\"" --json title -q '.[].title' | grep -Fxq "$title"; then
    echo "  (있음) $title"; return
  fi
  gh issue create --title "$title" --milestone "$ms" --label "$labels" --body "$body" >/dev/null
  echo "  issue: $title"
}

M1="01 업무 분석서"
issue "[작업] 업무 분석서 v1.0 작성" "$M1" "type:docs,area:analysis" \
"## 목표
ASPICE 4.0 SYS/SWE/SUP 기준 세부 업무를 분석해 MVP 범위를 정한다.

## 할 일
- [x] 13개 장 초안 작성
- [x] ASPICE PAM v4.0 원문으로 BP 제목 확인
- [x] docs/01-work-analysis.md 커밋

## 완료 기준
문서가 main에 머지되어 있다."

issue "[작업] 현업 인터뷰 Q1~Q12 진행" "$M1" "type:task,area:analysis" \
"## 목표
업무 분석서 11장의 질문으로 가설 상태인 Pain Point와 빈도·소요 시간을 확인한다.

## 할 일
- [ ] 인터뷰 대상 1~2명 섭외
- [ ] Q8~Q11(MVP 관련) 우선 질문
- [ ] 답변자 동의 범위 확인 후 결과 기록 (회사명, 개인 정보 제외)

## 완료 기준
11장 확인 결과 열이 채워져 있다."

issue "[작업] 인터뷰 결과를 반영해 근거 수준과 우선순위 갱신" "$M1" "type:docs,area:analysis" \
"## 목표
확인된 항목의 근거 수준을 가설에서 현업으로 바꾸고, 10장 평가가 달라지면 우선순위를 다시 계산한다.

## 완료 기준
문서 버전 v1.1 머지, 필요 시 ADR-0003 갱신."

issue "[작업] 01 회고 작성과 v0.1.0 릴리스" "$M1" "type:docs,area:repo" \
"## 할 일
- [ ] retrospectives/01-work-analysis.md 작성
- [ ] v0.1.0 태그와 Release 노트 작성 (회고 링크)
- [ ] Milestone 01 닫기"

M2="02 기존 솔루션 및 선행 연구 분석서"
issue "[작업] 상용 ALM의 AI 기능 비교" "$M2" "type:task,area:analysis" \
"## 목표
Polarion, Codebeamer AI, Jama Connect 등의 AI 기능을 공식 문서 기준으로 비교한다.

## 할 일
- [ ] 비교 축 정의 (요구사항 품질, TC 생성, 링크 제안, 영향도, 버전·실행 근거 결합)
- [ ] 제품별 공식 문서 확인과 출처 기록

## 완료 기준
비교표와 출처 목록이 문서에 있다."

issue "[작업] 추적성·변경 영향도 선행 연구 정리" "$M2" "type:task,area:analysis" \
"## 할 일
- [ ] 요구사항-코드 추적 링크 복원 연구
- [ ] IR + LLM 추적성 분석 연구
- [ ] 의미 기반·그래프 기반 변경 영향도 분석 (arXiv:2606.18855 포함)
- [ ] 비교군 B0~B4 설계에 쓸 근거 정리"

issue "[작업] Automotive SPICE PAM 4.1 변경 사항 확인" "$M2" "type:task,area:analysis" \
"## 목표
VDA QMC가 2026-04 게시한 PAM 4.1 프리뷰를 확인하고 업무 분석서에 영향이 있는지 판단한다."

issue "[결정] 차별화 후보 3개 검증" "$M2" "type:decision,area:analysis" \
"## 배경
업무 분석서 9장의 차별화 후보가 기존 도구·연구에 이미 있는지 확인이 필요하다.

## 선택지
1. 버전이 일치하는 실행 근거를 결합한 변경 후 충족도 검증
2. 도구별 버전 체계를 하나의 베이스라인으로 묶는 형상 일관성 검사
3. 관계 추출 + 규칙 엔진 기반 의미적 모순 검사

## 결론 (결정 후 작성)
"

echo "완료. Projects 보드는 GitHub 웹에서 만들고 위 이슈들을 추가하세요."
