#개요
- 기본 구성
- EC2 구성
- 문법

# 구조
### 기본 구성
- *.tf : terraform 파일
- * : 이름의 제한 X => service 혹은 기능 혹은 커스텀 의미 부여 가능
- *.tfvars : terraform의 환경변수 -> 외부에서 세팅하는 기본 값.
```
/basic
L provider.tf            : 버전, 공급자정보 기술.
L terraform.tfvars
L variables.tf          : 테라폼 변수
L main.tf
L outputs.tf
L .gitignore

작성 순서대로 구조를 작성하는 것이 좋다.
```

## 인프라 구성 핵심 절차
- 인프라 코드가 있는 위치로 이동 (단 옵션부여로 경로지정 가능)
```
cd basic
```
- step1 : 테라폼 초기화
```
terraform init
```
결과물 체크
- .terraform/~ : 공급자 플러그인, 바이너리, 모듈, 정보 등 생성.
- .terraform.lock.hcl : 프로바이더 모듈의 지정한 버전, 해시값 잠금 관리 -> 안정적 관리, 자동생성 시 체킹 용도 활용.

- step2 : 문법 검사(체킹)
```
terraform validate          # 문법에 대한 유효성 검사를 하기위해 종종 쓸 수 있다.
```
- step3 : 실행 계획 확인 (플래닝, 시뮬레이션)
```
terraform plan
---
# 실제 구성할 인프라에 대한 시뮬레이션 => +,-,+/- 기호주목
data.aws_vpc.default: Reading...
data.aws_vpc.default: Read complete after 1s [id=vpc-0eebee125226fd6c5]
data.aws_subnets.default: Reading...
data.aws_subnets.default: Read complete after 0s [id=ap-northeast-2]

Changes to Outputs:
  + default_susbnets_ids = [
      + "subnet-049c8f72bb109a11e",
      + "subnet-0cc79271aae2ac523",
      + "subnet-0928223142a64ef05",
      + "subnet-011432f9b62dee9b6",
    ]
  + default_vpc_ids      = "vpc-0eebee125226fd6c5"

You can apply this plan to save these new output values to the Terraform state, without changing any real
infrastructure.

─────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these
actions if you run "terraform apply" now.
```
- step4 : 테라폼 적용 (실제 생성)
```
terraform apply
```
- step5 : 테라폼 삭제
```
terraform destroy
```


# 목표 인프라 시스템
```
Internet
    |
Elastic IP         <- 탄력적 IP. 리소스할당 생성.
    |
EC2 AmazonLinux2   <- AmazonLinux 사용/ ec2-user
    |
security Group     <- 보안그룹, 인바운드(ssh-22), 아웃바운드(전체 개방)
    |
VPC(Default)       <- 클라우드 내에 사설 클라우드(네트워크), 기본(default)를 사용,신규생성X
```
