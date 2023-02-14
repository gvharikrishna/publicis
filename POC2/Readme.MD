#**Purpose of this document is to understand the details of the Resources are created in the project**

##Resource Group
##VNET -> Subnet, Network Security Group allowed ports 80 and 3389
##Storage Account -> Created blob for Boot Diagnostics
##Windows Web Server  -> Created under the Loadbalancer, Able to connect RDP and access the Website through LB.  No scalling group enabled.  http://40.88.140.217
##Linux Web server -> Created under the VMSS, Bootstrapped with extension for Apache2,  Enabled Auto Scalling groups, http://52.136.113.137
##Attached bootstrap scripts for both IIS and Apache

###Note: Pending fixes are install webserver on Scaleset machines (Bootstrap with Ansible)