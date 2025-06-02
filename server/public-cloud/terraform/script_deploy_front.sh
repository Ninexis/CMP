#!/bin/bash

echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDCWtHidKn+GLcE/Q4fHQyonV0CKfQ2CK1clmdZ0QREJdrFt8HPn9NMS0FyDp/p+2fFGyJbu13iXhM3sxCpdje+QIrb648EblkupQui4V+n+OnpC6nvF6hAtk09zW1peFHxhCyBL8atkOvwzOCsqbBneh2ObW9IXtUSRE4iInDHKSWOR3bJqN5QYZzHvvJYMUYPazUd43DwUzAQ+j3txNALSKTB/+I6G8UnThRXPs+ElnVgJ7/svRANwNnbQ34CCqAM+85xUQ7ZBUl3Gn50k2cBi+QERzSsqnyB+mhq9vdQm82isal8AI7+KYbibVBUyA3FPyKIGc9L0XAXpNcaQFOymmZ8HAoOWRFPYQZjMli2vXqpY+ioewxYpaVI32+qezZ/L+G3kH4TQdIZr0Q8V2Fvj7P18S5WIGPoAFCi0UGpfgX8Nj9QluKWzYCb59mV+Cd9xN5qzyCqT8WHh0P0eA1oct2hjhPaHEalG99cRLkDjNhLSK9ONqpmQbCAhyTHzM0= mathieuneumar@Host-003.lan" >> /home/ubuntu/.ssh/authorized_keys

cd /home/ubuntu

curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install nodejs

sudo -u ubuntu git clone https://github.com/Ninexis/app-arcl-front.git
cd app-arcl-front
sudo -u ubuntu npm install

CONFIG_FILE = /home/ubuntu/app-arcl-front/.env.production

cat > "$CONFIG_FILE" <<EOF
VITE_ADDR_MASTER="35.207.86.150:808${asg_number}"
VITE_ADDR_SLAVE="35.217.57.158:808${asg_number}"
EOF

npm install -g serve
npm run build
serve -s dist -l 80 &
