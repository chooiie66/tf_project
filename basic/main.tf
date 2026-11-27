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
    filter{
        name = "vpc-id"
        # n 개의 서브넷 정보가 조회되어서 [ ] 에 담긴다. 서브넷을 보유한 vpc의 id로 조회.
        values = [data.aws_vpc.default.id]
    }
}
 

# 3. 보안 그룹

# 4. ec2 생성을 위한 이미지(OS 구동) 정보 조회

# 5. EC2 생성 선언

# 6. 탄력적 IP 적용 (1차 버전에서는  제외)