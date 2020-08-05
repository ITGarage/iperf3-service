#!/bin/env bash
# check the bash shell script is being run by root
if [ "$EUID" -ne 0 ]
  then echo 'this script must be run with sudo'
  exit
fi

echo 'updating'
apt --yes --quiet --quiet update
echo 'installing iperf3'
apt --yes --quiet --quiet install iperf3

cat << EOF > /etc/systemd/system/iperfd.service
# content of /etc/systemd/system/iperfd.service
[Unit]
Description=iperf service
After=network.target
[Service]
Type=simple
PIDFile=/var/run/iperf3.pid
ExecStart=/usr/bin/iperf3 --server --daemon --stdin /var/run/iperf3.pid
ExecReload=/usr/bin/kill-HUP $MAINPID
Restart=always
[Install]
WantedBy=multi-user.target
EOF

ufw allow from any to any port 5201 proto tcp comment "iperf from anywhere"

systemctl enable iperfd.service
systemctl start  iperfd.service
