provider "vsphere" {
  user              = var.vsphere_user
  password          = var.vsphere_password
  vsphere_server    = var.vsphere_server

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

#Adressing the hosts in the cluster SWHAN001
variable "SWHANOO1_hosts" {
  default = [
    "nb999vmw013.gad.teliasonera.net",
    "nb999vmw014.gad.teliasonera.net",
    "nb999vmw015.gad.teliasonera.net"
  ]
}

#Reading the Dataccenter Sweden
data "vsphere_datacenter" "dc" {
  name = "Sweden"
}

#Reading the host, kind of foreach of the host array
data "vsphere_host" "esxi_hosts" {
  count         = "${length(var.SWHANOO1_hosts)}"
  name          = "${var.SWHANOO1_hosts[count.index]}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}


#Creating the datastore clusters
resource "vsphere_datastore_cluster" "datastore_cluster" {
  name          = "terraform-datastore-cluster"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
  sdrs_enabled  = true
  sdrs_automation_level= "automated"
  sdrs_free_space_threshold="80"
  sdrs_io_latency_threshold="15"  
  sdrs_default_intra_vm_affinity =true
  sdrs_load_balance_interval= "480"   
  sdrs_free_space_utilization_difference= "5"   
  sdrs_io_load_imbalance_threshold= "5"  
}


# Creating the datastores

resource "vsphere_nas_datastore" "datastore1" {
  name                  = "Terraform-test-ds1"
  host_system_ids       = "${data.vsphere_host.esxi_hosts.*.id}"
  datastore_cluster_id  ="${vsphere_datastore_cluster.datastore_cluster.id}" 
  type                  = "NFS"
  remote_hosts          = ["10.88.64.137"]
  remote_path           = "/SWHAN001_NFS_SAS_CVLT"
}

resource "vsphere_nas_datastore" "datastore2" {
  name            = "Terraform-test-ds2"
  host_system_ids = "${data.vsphere_host.esxi_hosts.*.id}"
  datastore_cluster_id  ="${vsphere_datastore_cluster.datastore_cluster.id}" 
  type         = "NFS"
  remote_hosts = ["10.88.64.138"]
  remote_path  = "/SWHAN001_NFS_SAS_CVLT002"
}