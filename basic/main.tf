#################################
# ec2 구성에 대한 모든 설정 선언
# data ~ : 조회
# resource ~ : 리소스 생성.
#################################

# 1.VPC 구성 (새로 생성 or [v]기존 사용)
# vpc 이름과 상관없는 vpc 생성 시 지정된 default-vpc에 영향을 받을 것임.
data "aws_vpc" "default" {
  # 현재 존재하는 VPC 목록 중에 default vpc 정보를 조회하라.
  default = true
}
# 2. subnet 설정 or 구성 후 설정
# 현재 default vpc는 4개의 서브넷을 가지고있음. -> 멀티 az 지원 고난점에서 4가지 사용할 수 있음
#  멀티 AZ를 사용한다는 것은 같은 서비스를 A,B 동일하게 구성해 a등 장애나면 B에서 진행
data "aws_subnets" "default" {
  filter {
    name = "vpc-id"
    # n 개의 서브넷 정보가 조회되어서 [ ] 에 담긴다. 서브넷을 보유한 vpc의 id로 조회.
    values = [data.aws_vpc.default.id]
  }
}
# 3. 보안 그룹 생성 선언        선언 = resource
resource "aws_security_group" "ai-cp2-07-sg" {
  # 기본 세부 정보 #############
  # 이름 
  name = "ai-cp2-07-sg"
  # 설명-ASCII만 지원. 한글 X
  description = "ai-cp2-07 security_group"
  # 보안그룹이 속한 vpc 지정
  vpc_id = data.aws_vpc.default.id

  # 인바운드 규칙 ###########
  # 외부 트래픽 내부로 진입됨 -> 통과한 포트만 등록 -> 존재하는 만큼 추가함(규칙 추가)
  #22,80
  ingress {
    # 프로토콜
    protocol = "tcp"
    # 포트
    from_port = 22 # 허용할 포트 범위의 시작 번호
    to_port   = 22 # 허용할 포트 범위의 끝 번호
    # 22만 허용한단 소리. 

    # CIDR 블록
    # classless inter-domain `routing` : IP 주소, 네트워크 범위를 표현
    # IP 주소의 범위(네트워크 대역) 정의 
    # IPv4 기준으로 0~255.0~255.0~255.0~255 => 각 자리수별로 256개 설정 => 전체 32bit
    # 모든 IP의 가짓수는 256 * 256 * 256 * 256개 가 가능함. 
    # ().().().()/<앞에서부터 고정되는 bit 수>
    # 10.0.0.0/8 => 앞에서부터 8 비트는 고정 => 10.(0~255).(0~255).(0~255)
    # 0.0.0.0/0 : 모든 대역폭 => 전세계 어디서든.
    # 222.111.55.44/32 -> 오직 1개의 IP만 가능, 내 IP 
    cidr_blocks = ["222.108.125.33/32"]
    # 설명 : 강의장에서만 접속 가능.
    description = "SSH"
  }
  ingress {
    protocol  = "tcp"
    from_port = 80 # 허용할 포트 범위의 시작 번호
    to_port   = 80 # 허용할 포트 범위의 끝 번호
    # 80만 허용한단 소리
    cidr_blocks = ["0.0.0.0/0"] #전세계로 개방
    # 전세계에서 웹으로 접속 가능.
    description = "HTTP"
  }

  # 아웃바운드 규칙 ###############
  #내부 트래픽이 외부로 나가는 규칙
  egress {
    # 모든 프로토콜 개방
    protocol = "-1"
    # 모든 포트 개방
    from_port = 0
    to_port   = 0
    # IP 전세계로 개방
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# 4. ec2 생성을 위한 이미지(ami: Amazon machine image) (OS 구동환경) 정보 조회 조회 = data
data "aws_ami" "amazon_linux" {
  # 최신 설정
  most_recent = true
  # 소유자 지정
  owners = ["amazon"]
  # 필터링
  filter {
    name   = "name"
    values = ["al2023-ami-*"]

  }
  # 필터추가
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  # 필터를 추가할수록 원하는 것을 뽑을 수 있을 가능성이 높아진다.
}
# 5. EC2 생성 선언
resource "aws_instance" "ai-cp2-07-ec2" {
  # 태그
  tags = {
    Name = "ai-cp2-07-ec2"
  }
  # AMI 
  ami = data.aws_ami.amazon_linux.id
  # 인스턴스 유형
  instance_type = var.instance_type
  # 키페어
  key_name = var.key_name
  # 서브넷
  subnet_id = data.aws_subnets.default.ids[0] #a동,b동,c동,d동 중 a동 선택.
  # 보안그룹
  vpc_security_group_ids = [aws_security_group.ai-cp2-07-sg.id]
  # 스토리지 생략
  # 고급설정 생략
  # IP는 임시적으로 동적 할당
}


# 6. 탄력적 IP 적용 (1차 버전에서는  제외)
resource "aws_eip" "ai-cp2-07-eip" {
  # 연결할 ec2 인스턴스 id 지정
  instance = aws_instance.ai-cp2-07-ec2.id
  # 네트워크
  domain = "vpc"
}