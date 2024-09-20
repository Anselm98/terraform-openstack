#Define provider
terraform {
    required_providers {
        openstack = {
            source  = "terraform-provider-openstack/openstack"
            version = ">= 1.0.0"
        }
    }
}

provider "openstack" {
}

#Link SSH key
resource "openstack_compute_keypair_v2" "my_key" {
    name       = "my_key"
    public_key = file("~/.ssh/id_ed25519.pub")
}

#Create security group
resource "openstack_networking_secgroup_v2" "web_server" {
    name        = "web_server"
    description = "Security group for web servers"
}

#Define rules for the  security group
resource "openstack_networking_secgroup_rule_v2" "allow_ssh" {
    direction         = "ingress"
    ethertype         = "IPv4"
    protocol          = "tcp"
    port_range_min    = 22
    port_range_max    = 22
    remote_ip_prefix  = "0.0.0.0/0"
    security_group_id = openstack_networking_secgroup_v2.web_server.id
}

resource "openstack_networking_secgroup_rule_v2" "allow_http" {
    direction         = "ingress"
    ethertype         = "IPv4"
    protocol          = "tcp"
    port_range_min    = 80
    port_range_max    = 80
    remote_ip_prefix  = "0.0.0.0/0"
    security_group_id = openstack_networking_secgroup_v2.web_server.id
}

resource "openstack_networking_secgroup_rule_v2" "allow_https" {
    direction         = "ingress"
    ethertype         = "IPv4"
    protocol          = "tcp"
    port_range_min    = 443
    port_range_max    = 443
    remote_ip_prefix  = "0.0.0.0/0"
    security_group_id = openstack_networking_secgroup_v2.web_server.id
}

#Create instance and apply the security group
resource "openstack_compute_instance_v2" "web-server" {
    name            = "web-server"
    image_id        = "4aab6e87-1d04-4351-855d-dafe8765c93d"
    flavor_name     = "a1-ram2-disk20-perf1"
    key_pair        = "my_key"
    security_groups = ["web_server"]

    metadata = {
        application = "web-app"
    }

    network {
        name = "ext-net1"
    }
}

#Output IPV4
output "web-server_ip" {
    value = openstack_compute_instance_v2.web-server.access_ip_v4
}