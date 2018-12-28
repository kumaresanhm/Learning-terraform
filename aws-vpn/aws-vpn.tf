resource "aws_customer_gateway" "customer_gateway" {
  bgp_asn    = 65000
  ip_address = "3.121.242.236"
  type       = "ipsec.1"
  tags {
    Name = "Data-Center-Frankfurt"
  }
}

resource "aws_vpn_gateway" "vpn_gateway" {
  vpc_id = "${aws_vpc.my-vpc.id}"
  tags {
    Name = "AWS-VGW-London"
  }
}

resource "aws_vpn_connection" "main" {
  vpn_gateway_id      = "${aws_vpn_gateway.vpn_gateway.id}"
  customer_gateway_id = "${aws_customer_gateway.customer_gateway.id}"
  type                = "ipsec.1"
  static_routes_only  = true
  tags {
    Name = "AWS-VGW-London-vpn-link-DATA-Center-Frankfurt"
  }
}

resource "aws_vpn_connection_route" "office" {
  destination_cidr_block = "10.11.0.0/16"
  vpn_connection_id      = "${aws_vpn_connection.main.id}"

}

############Route Propagations for Public Subnets###########
resource "aws_vpn_gateway_route_propagation" "vpn-public-subnets" {

  vpn_gateway_id = "${aws_vpn_gateway.vpn_gateway.id}"
  route_table_id = "${aws_route_table.public-routes.id}"

}

#######Route Propagations for Private Subnets############
resource "aws_vpn_gateway_route_propagation" "vpn-private-subnets" {
  count = "${length(var.azs)}"
  vpn_gateway_id = "${aws_vpn_gateway.vpn_gateway.id}"
  route_table_id = "${element(aws_route_table.private-routes.*.id,count.index)}"

}




