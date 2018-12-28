resource "aws_db_instance" "db-prod" {
  identifier = "cloudeligent-db"
 # final_snapshot_identifier = "cloudeligent-db-final-snap-shot-1"
  allocated_storage = "${var.rds_allocated_storage}"
  storage_type = "${var.storage_type}"
  engine = "${var.rds_engine}"
  engine_version = "${var.engine_version}"
  instance_class = "${var.db_instance_class}"
  backup_retention_period = "${var.backup_retension_period}"
  backup_window = "${var.backup_window}"
  publicly_accessible = "${var.publicly_accessible}"
  username = "${var.rds_username}"
  password = "${var.rds_password}"
  vpc_security_group_ids = ["${aws_security_group.rds-sg.id}"]
  db_subnet_group_name = "${aws_db_subnet_group.rds-instance-subnets.name}"
  multi_az = "true"

}

#NOTE: PLEASE ONLY PUT THE PRIVATE-SUBNET IDS
resource "aws_db_subnet_group" "rds-instance-subnets" {
  name = "cloudeligent-rds-private-subnets-groups"
  description = "Allowed Only Private Subnets for Cloudeligent-RDS-MYSQL"
  subnet_ids = ["subnet-0f82144ac988d09f0","subnet-0110e2f5660653648","subnet-09e16122a2066bbff"]
  tags {
    Name = "cloudeligent-rds-subnets-groups"
  }
}

#OUTPUT RDS INSTANCE END POINT

output "rds-end-point" {
  value = "${aws_db_instance.db-prod.endpoint}"
}

#RDS VARIABLES
variable "rds_cidr" {
  default = "192.168.0.0/16"
}
variable "db_instance_class" {
  default = "db.t2.micro"
}
variable "rds_engine" {
  default = "mysql"
}
variable "engine_version" {
  default = "5.7.17"
}
#These are automated backups
variable "backup_retension_period" {
  default = "0"
}
variable "backup_window" {
  default = "04:00-6:00"
}
variable "publicly_accessible" {
  default = "false"
}
variable "rds_username" {
  default = "sage"
}
variable "rds_password" {
  default = "cbaLpjjsihaha12"
}
variable "rds_allocated_storage" {
  default = "5"
}
variable "storage_type" {
  default = "gp2"
}
