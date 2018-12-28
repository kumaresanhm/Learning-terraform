provider "aws" {
  region = "${var.region}"
}

resource "aws_vpc" "my-vpc" {
  cidr_block = "${var.vpc-cidr}"
  instance_tenancy = "default"
  enable_dns_support = "true"
  tags {
    Name= "Cloudelligent-VPC"
    Location= "Viginia"
  }
}

#CREATING A INTERNET GATEWAY

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.my-vpc.id}"

  tags {
    Name= "Cloudelligent-Internet-Gate-Way"

  }
}

#PUBLIC SUBNET FROM A LIST
resource "aws_subnet" "public-subnets" {
  availability_zone = "${element(var.azs,count.index)}"

  count = "${length(var.azs)}"
  cidr_block = "${element(var.vpc-public-subnet-cidr,count.index)}"
  vpc_id = "${aws_vpc.my-vpc.id}"
  map_public_ip_on_launch = "true"

  tags {
    Name = "Public-Subnet-${count.index+1}"
    Location = "Viginia"
  }
}

#CREATING A PUBLIC ROUTES
resource "aws_route_table" "public-routes" {
  vpc_id = "${aws_vpc.my-vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }
  tags {
    Name = "Public-Subnets-Routes"
  }
}

#ASSOCIATE/LINK PUBLIC-ROUTE WITH PUBLIC-SUBNETS LIST
# https://github.com/hashicorp/terraform/issues/14880
resource "aws_route_table_association" "public-association" {
  count = "${length(var.azs)}"
  route_table_id = "${aws_route_table.public-routes.id}"
  subnet_id = "${element(aws_subnet.public-subnets.*.id, count.index)}"
}


#In Case of fetching all AZ from a Region.
##############################################################
#resource "aws_subnet" "public-subnet" {
#  availability_zone = "${element(data.aws_availability_zones.azs.names,count.index)}"
#  count = "${length(data.aws_availability_zones.azs.names)}"
#  cidr_block = "${element(var.public_subnets,count.index)}"
#  vpc_id = "${aws_vpc.my-vpc.id}"
#  map_public_ip_on_launch = "true"
#  tags {
#    Name= "Public-subnet-${count.index+1}" #for dynamic names eg. Public-subnet-1
#  }

#CREATING PUBLIC SUBNET 1
#resource "aws_subnet" "public-subnet-1" {
#  availability_zone = "${var.vpc-public-subnet-1-az}"
#  cidr_block = "${var.vpc-public-subnet-1}"
#  vpc_id = "${aws_vpc.my-vpc.id}"
#  map_public_ip_on_launch = "true"
#  tags {
#    Name = "Public-Subnet-1"
#  }
#}

#CREATING PUBLIC SUBNET 2
#resource "aws_subnet" "public-subnet-2" {
#  availability_zone = "${var.vpc-public-subnet-2-az}"
#  cidr_block = "${var.vpc-public-subnet-2}"
#  vpc_id = "${aws_vpc.my-vpc.id}"
#  map_public_ip_on_launch = "true"
#  tags {
#    Name = "Public-Subnet-2"
#  }
#}

#CREATING PUBLIC SUBNET 3
#resource "aws_subnet" "public-subnet-3" {
#  availability_zone = "${var.vpc-public-subnet-3-az}"
#  vpc_id = "${aws_vpc.my-vpc.id}"
#  cidr_block = "${var.vpc-public-subnet-3}"
#  map_public_ip_on_launch = "true"
#  tags {
#    Name = "Public-Subnet-3"
#  }
#}

#CREATING PRIVATE SUBNET-1
#resource "aws_subnet" "private-subnet-1" {
#  availability_zone = "${var.vpc-priavte-subnet-1-az}"
#  cidr_block = "${var.vpc-private-subnet-1}"
#  vpc_id = "${aws_vpc.my-vpc.id}"

#  tags {
#    Name = "Private-Subnet-1"
#  }
#}

#CREATING PRIVATE SUBNET-2
#resource "aws_subnet" "private-subnet-2" {
#  availability_zone = "${var.vpc-priavte-subnet-2-az}"
#  cidr_block = "${var.vpc-private-subnet-2}"
#  vpc_id = "${aws_vpc.my-vpc.id}"

#  tags {
#    Name = "Private-Subnet-2"
#  }
#}


#CREATING PRIVATE SUBNET-3
#resource "aws_subnet" "private-subnet-3" {
#  availability_zone = "${var.vpc-priavte-subnet-3-az}"
#  cidr_block = "${var.vpc-private-subnet-3}"
#  vpc_id = "${aws_vpc.my-vpc.id}"

 # tags {
 #   Name = "Private-Subnet-3"
 # }
#}

#CREATING PRIVATE SUBNETS FROM A LIST
resource "aws_subnet" "private-subnets" {
  availability_zone = "${element(var.azs,count.index)}"

  count = "${length(var.azs)}"
  cidr_block = "${element(var.vpc-private-subnet-cidr,count.index)}"
  vpc_id = "${aws_vpc.my-vpc.id}"


  tags {
    Name = "Private-Subnet-${count.index+1}"
    Location = "Viginia"
  }
}

#https://github.com/terraform-community-modules/tf_aws_vpc/issues/42
#CREATING 3 EIP FOR NAT-GATEWAY
resource "aws_eip" "eip-ngw" {
  count = "3"
  tags {
    Name = "EIP-nat-gatway-${count.index+1}"
  }
}
#CREATING 3 NAT GATEWAYS
resource "aws_nat_gateway" "ngw" {
  count = "${length(var.azs)}"
  allocation_id = "${element(aws_eip.eip-ngw.*.id,count.index)}"
  subnet_id = "${element(aws_subnet.public-subnets.*.id, count.index)}"
  tags {
    Name = "Cloudelligent-Nat-Gateway-${count.index+1}"
  }
}

#CREATING A PRIAVTE ROUTE-TABLE FOR PRIVATE-SUBNETS
resource "aws_route_table" "private-routes" {
  count = "${length(var.azs)}"
  vpc_id = "${aws_vpc.my-vpc.id}"
  route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = "${element(aws_nat_gateway.ngw.*.id,count.index)}"
      }
      tags {
        Name = "Priave-Subnet-Route-${count.index+1}"
      }

  }

#ASSOCIATE/LINK PRIVATE-ROUTES WITH PRIVATE-SUBNETS
resource "aws_route_table_association" "private-routes-linking" {
  count = "${length(var.azs)}"
  route_table_id = "${element(aws_route_table.private-routes.*.id,count.index)}"
  subnet_id = "${element(aws_subnet.private-subnets.*.id,count.index)}"
}


#CREATING A PUBLIC ROUTE-TABLE FOR PUBLIC-SUBNET-1
#    resource "aws_route_table" "public-route-1" {
#      vpc_id = "${aws_vpc.my-vpc.id}"
#      route {
#        cidr_block = "0.0.0.0/0"
#        gateway_id = "${aws_internet_gateway.igw.id}"
#      }
#      tags {
#        Name = "Public-Subnet-Route-1"
#      }
#    }

#CREATING A PUBLIC ROUTE-TABLE FOR PUBLIC-SUBNET-2
#resource "aws_route_table" "public-route-2" {
#  vpc_id = "${aws_vpc.my-vpc.id}"
#  route {
#    cidr_block = "0.0.0.0/0"
#    gateway_id = "${aws_internet_gateway.igw.id}"
#  }
#  tags {
#    Name = "Public-Subnet-Route-2"
#  }
#}

#CREATING A PUBLIC ROUTE-TABLE FOR PUBLIC-SUBNET-3
#resource "aws_route_table" "public-route-3" {
#  vpc_id = "${aws_vpc.my-vpc.id}"
#  route {
#    cidr_block = "0.0.0.0/0"
#    gateway_id = "${aws_internet_gateway.igw.id}"
#  }
#  tags {
#    Name = "Public-Subnet-Route-3"
#  }
#}

#ASSOCIATE/LINK PUBLIC-ROUTE WITH PUBLIC-SUBNET-1
#resource "aws_route_table_association" "public-route-1" {
#  route_table_id = "${aws_route_table.public-route-1.id}"
#  subnet_id = "${aws_subnet.public-subnet-1.id}"
#}

#ASSOCIATE/LINK PUBLIC-ROUTE WITH PUBLIC-SUBNET-2
#resource "aws_route_table_association" "public-route-2" {
#  route_table_id = "${aws_route_table.public-route-2.id}"
#  subnet_id = "${aws_subnet.public-subnet-2.id}"
#}

#ASSOCIATE/LINK PUBLIC-ROUTE WITH PUBLIC-SUBNET-3
#resource "aws_route_table_association" "public-route-3" {
#  route_table_id = "${aws_route_table.public-route-3.id}"
#  subnet_id = "${aws_subnet.public-subnet-3.id}"
#}






#ElASTIC IP FOR NAT GATWAY-1
#resource "aws_eip" "nat-eip-1" {
#  vpc = "true"
#  depends_on = ["aws_internet_gateway.igw"]
#  tags {
#    Name = "NAT-Elastic-IP-1"
#  }
#}

#NAT-GATEWAY-1 FOR PRIVATE IP ADDRESSES
#resource "aws_nat_gateway" "ngw-1" {
#  allocation_id = "${aws_eip.nat-eip-1.id}"
#  subnet_id = "${aws_subnet.public-subnet-1.id}"
#  depends_on = ["aws_internet_gateway.igw"]

 # tags {
#    Name = "Cloudelligent-NAT-Gateway-1"
#  }
#}

#CREATING A PRIAVTE ROUTE-TABLE FOR PRIVATE-SUBNET-1
#resource "aws_route_table" "private-route-1" {
#  vpc_id = "${aws_vpc.my-vpc.id}"
#  route {
#    cidr_block = "0.0.0.0/0"
#    nat_gateway_id = "${aws_nat_gateway.ngw-1.id}"
#  }
#  tags {
#    Name = "Priave-Subnet-Route-1"
#  }
#}
#ASSOCIATE/LINK PRIVATE-ROUTE WITH PRIVATE-SUBNET-1
#resource "aws_route_table_association" "private-route-1" {
#  route_table_id = "${aws_route_table.private-route-1.id}"
#  subnet_id = "${aws_subnet.private-subnet-1.id}"
#}

###################################################################

#ElASTIC IP FOR NAT GATWAY-2
#resource "aws_eip" "nat-eip-2" {
#  vpc = "true"
#  depends_on = ["aws_internet_gateway.igw"]
#  tags {
#    Name = "NAT-Elastic-IP-2"
#  }
#}



#NAT-GATEWAY-2 FOR PRIVATE IP ADDRESSES
#resource "aws_nat_gateway" "ngw-2" {
#  allocation_id = "${aws_eip.nat-eip-2.id}"
#  subnet_id = "${aws_subnet.public-subnet-2.id}"
#  depends_on = ["aws_internet_gateway.igw"]

#  tags {
#    Name = "Cloudelligent-NAT-Gateway-2"
#  }
#}

#CREATING A PRIAVTE ROUTE-TABLE FOR PRIVATE-SUBNET-2
#resource "aws_route_table" "private-route-2" {
#  vpc_id = "${aws_vpc.my-vpc.id}"
#  route {
#    cidr_block = "0.0.0.0/0"
#    nat_gateway_id = "${aws_nat_gateway.ngw-2.id}"
#  }
#  tags {
#    Name = "Priave-Subnet-Route-2"
#  }
#}
#ASSOCIATE/LINK PRIVATE-ROUTE WITH PRIVATE-SUBNET-2
#resource "aws_route_table_association" "private-route-2" {
#  route_table_id = "${aws_route_table.private-route-2.id}"
#  subnet_id = "${aws_subnet.private-subnet-2.id}"
#}

################################################################
#ElASTIC IP FOR NAT GATWAY-3
#resource "aws_eip" "nat-eip-3" {
#  vpc = "true"
#  depends_on = ["aws_internet_gateway.igw"]
#  tags {
#    Name = "NAT-Elastic-IP-3"
#  }
#}



#NAT-GATEWAY-3 FOR PRIVATE IP ADDRESSES
#resource "aws_nat_gateway" "ngw-3" {
#  allocation_id = "${aws_eip.nat-eip-3.id}"
#  subnet_id = "${aws_subnet.public-subnet-3.id}"
#  depends_on = ["aws_internet_gateway.igw"]

#  tags {
#    Name = "Cloudelligent-NAT-Gateway-3"
#  }
#}

#CREATING A PRIAVTE ROUTE-TABLE FOR PRIVATE-SUBNET-2
#resource "aws_route_table" "private-route-3" {
#  vpc_id = "${aws_vpc.my-vpc.id}"
#  route {
#    cidr_block = "0.0.0.0/0"
#    nat_gateway_id = "${aws_nat_gateway.ngw-3.id}"
#  }
#  tags {
#    Name = "Priave-Subnet-Route-3"
#  }
#}
#ASSOCIATE/LINK PRIVATE-ROUTE WITH PRIVATE-SUBNET-3
#resource "aws_route_table_association" "private-route-3" {
#  route_table_id = "${aws_route_table.private-route-3.id}"
#  subnet_id = "${aws_subnet.private-subnet-3.id}"
#}

###################################################################
#https://github.com/terraform-aws-modules/terraform-aws-vpc/blob/master/outputs.tf
#OUTPUT OF PUBLIC SUBNET IDS
output "public-subnet-ids" {
  value = ["${aws_subnet.public-subnets.*.id}"]
}

#OUTPUT OF PRIVATE SUBNET IDS
output "private-subnet-ids" {
value = ["${aws_subnet.private-subnets.*.id}"]
}

#OUTPUT OF PUBLIC ROUTE TABLE IDS
#output "public_route_table_ids" {
#  description = "List of IDs of public route tables"
#  value       = ["${aws_route_table.public-routes.*.id}"]
#}

#OUTPUT OF PRIVATE ROUTE TABLE IDS
#output "private_route_table_ids" {
#  description = "List of IDs of private route tables"
#  value       = ["${aws_route_table.private-routes.*.id}"]
#}

##########################################################################################
#OUTPUT OF PUBLIC-SUBNETS-IDS

#output "public-subnet-1-id" {
#  value = "${aws_subnet.public-subnet-1.id}"
#}

#output "public-subnet-2-id" {
#  value = "${aws_subnet.public-subnet-2.id}"
#}

#output "public-subnet-3-id" {
#  value = "${aws_subnet.public-subnet-3.id}"
#}

#OUTPUT OF PRIVATE-SUBNETS-IDS

#output "priavte-subnet-1-id" {
#  value = "${aws_subnet.private-subnet-1.id}"
#}

#output "priavte-subnet-2-id" {
#  value = "${aws_subnet.private-subnet-2.id}"
#}

#output "priavte-subnet-3-id" {
#  value = "${aws_subnet.private-subnet-3.id}"
#}