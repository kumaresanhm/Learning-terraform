resource "aws_security_group" "rds-sg" {
  name = "rds-sg"
  vpc_id = "${aws_vpc.my-vpc.id}"

  tags {
    Name = "rds-sg"
  }

 ingress {
   from_port = 3306
   protocol = "tcp"
   to_port = 3306
   cidr_blocks = ["${var.rds_cidr}"]
 }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["${var.rds_cidr}"]
  }


}
