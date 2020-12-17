#!/bin/bash
cd /home/eduardoefb/scripts/ansible/lab
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts 00_test.yml 

# https://docs.openstack.org/tripleo-docs/latest/install/
# 
# https://docs.openstack.org/project-deploy-guide/tripleo-docs/latest/



# Using kickstart: 
# https://docs.openstack.org/tripleo-quickstart/latest/basic-usage.html

#echo "stack ALL=(ALL) NOPASSWD:ALL" | tee -a /etc/sudoers.d/stack

yum install python3 python3-pip -y
curl -O https://raw.githubusercontent.com/openstack/tripleo-quickstart/master/quickstart.sh
ssh-keygen -f /root/.ssh/id_rsa -t rsa -q -N ""
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
export LIBGUESTFS_BACKEND_SETTINGS=network_bridge=virbr0

bash quickstart.sh 127.0.0.2

# After installation, from undercloud machine
ssh -F ~/.quickstart/ssh.config.ansible undercloud





# To clear:
ANSIBLE_HOST_KEY_CHECKING=False  ansible-playbook  -i hosts clear.yml




# https://docs.openstack.org/project-deploy-guide/tripleo-docs/latest/deployment/install_undercloud.html
useradd stack
passwd stack  # specify a password

echo "stack ALL=(root) NOPASSWD:ALL" | tee -a /etc/sudoers.d/stack
chmod 0440 /etc/sudoers.d/stack

su - stack

# Enable the appropriate repos for the desired release, as indicated below. Do not enable any other repos not explicitly marked for that release.
sudo yum install -y https://trunk.rdoproject.org/centos7/current/python2-tripleo-repos-0.0.1-0.20200409224957.8bac392.el7.noarch.rpm

# As stack
rel="queens"
bash << EOF
sudo -E tripleo-repos -b ${rel} current
sudo -E tripleo-repos -b ${rel} current ceph
sudo -E tripleo-repos current-tripleo-dev ceph
EOF

# Install the TripleO CLI, which will pull in all other necessary packages as dependencies:
bash << EOF
sudo yum install -y python-tripleoclient
sudo yum install -y ceph-ansible
EOF
# TLS
# If you intend to deploy TLS-everywhere in the overcloud and are deploying Train with python3 or Ussuri+, install the following packages:
# sudo yum install -y python3-ipalib python3-ipaclient krb5-devel

# if you intend to use Novajoin to implement TLS-everywhere install the following package:
# sudo yum install -y python-novajoin

# Prepare the configuration file:
cp /usr/share/python-tripleoclient/undercloud.conf.sample ~/undercloud.conf

cat << EOF > undercloud.conf
[DEFAULT]
local_ip = 10.5.1.5/24
undercloud_public_vip = 10.5.1.150
undercloud_admin_vip = 10.5.1.151
local_interface = eth1
#masquerade_network = 10.5.1.0/24
dhcp_start = 10.5.1.200
dhcp_end = 10.5.1.230
network_cidr = 10.5.1.0/24
network_gateway = 10.5.1.1
inspection_iprange = 10.5.1.235,10.5.1.245
EOF

openstack undercloud install


# Undercloud:
https://www.youtube.com/watch?v=ulpxlNFfbF8

# Overcloud:
https://www.youtube.com/watch?v=FF8Ks1aJ_6c


# Outro doc:
https://images.rdoproject.org/docs/baremetal/introduction.html
