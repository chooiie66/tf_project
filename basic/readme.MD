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
L provider.tf
L main.tf
L variables.tf
L outputs.tf
L terraform.tfvars
L .gitignore
```