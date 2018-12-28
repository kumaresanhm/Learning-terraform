#CREATING A NEW KEY PAIR AND EXPORTING OUR PUBLIC-KEY
resource "aws_key_pair" "power" {
  key_name = "power"
  public_key = "${file("power.pub")}"
}



#Creating an EC2 instance in Public Subnet must mention the "Subnet ID"#
resource "aws_instance" "cloudelligent-ec2" {

#   ami = "${var.ami-id}"
  ami = "ami-6ac2d40e"
  instance_type = "t2.micro"

#  Single Subnet
#  subnet_id = "subnet-0b03fbea26eafeb61"
#  subnet_id = "${var.ec2-subnet}"

# Number of EC2-instances required.
  count = "3"

  #EXISTING KEY PAIR OR CREATE ssh-keygen -f demo #it will give private & public keys, import public in aws
  #key_name = "power"

# EXPORTED PUBLIC-KEY
  key_name = "${aws_key_pair.power.key_name}"

# BASH SCRIPT
  user_data = "${file("httpd.sh")}"

# MULTIPLE SUBNETS IDS
  subnet_id = "${element(var.ec2-subnets-id,count.index)}"
  vpc_security_group_ids = ["${aws_security_group.ec2-sg.id}"]
  tags {
    Name= "Centos-6-${count.index+1}"
  }
}


#######################################################################
#EC2 VARIABLES
#EC2 Subnet ID's for Subnets
variable "ec2-subnets-id" {
  type = "list"
  default = ["subnet-0e451eb94102f3adb","subnet-0e9beadcf79744246","subnet-092c5d7d16b52031a"]
}

##Note: EC2 instance take only subnet_id as compare to RDS it takes subnet_ids##
##############################################################


#ELASTIC IP FOR EC2-Instance ASSOCIATION
#resource "aws_eip" "ec2-eip-1" {
#  vpc = "true"
#  depends_on = ["aws_internet_gateway.igw"]
#  network_interface = "${var.ec2-nic-1-id}"
#  instance = "i-04df1b7567f69fa92"
#  tags {
#    Name = "EC2-Elastic-IP-1-Gateway-1"
#  }
#}

#EC2 NIC-1 ID eth0
#variable "ec2-nic-1-id" {
#  default = "eni-06ff4d580aed824d6"
#}



#ELASTIC IP NO.2 FOR EC2-INSTANCE ASSOCIATION
#resource "aws_eip" "ec2-eip-2" {
#  vpc = "true"
#  depends_on = ["aws_internet_gateway.igw"]
#  network_interface = "${var.ec2-nic-2-id}"
#  instance = "i-01fa85ed8ef0ce793"
#  tags {
#    Name = "EC2-Elastic-IP-2-Gateway-2"
#  }

#}

#EC2 NIC-2 ID eth0
#variable "ec2-nic-2-id" {
#  default = "eni-0b4652913cc0c26e4"
#}