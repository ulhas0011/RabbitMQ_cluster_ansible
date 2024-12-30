#Add IPs of servers to /etc/hosts
ansible servers -m shell -a "echo '172.31.6.173 rabbit1' >> /etc/hosts && echo '172.31.14.94 rabbit2' >> /etc/hosts" --become

#creating erlang cookie and copying it to managed nodes
cookie_value=$(openssl rand -base64 20)
ansible servers -m shell -a "touch /home/ubuntu/erlang.cookie"
ansible servers -m shell -a "echo $cookie_value > /home/ubuntu/erlang.cookie" --become
ansible servers -m shell -a "sudo chmod 400 erlang.cookie"
ansible-playbook rabbitmq_playbook.yml

# rabbit1 will be the master here
ansible rabbit1 -a "
  sudo docker exec -it rabbitmq bash -c '
    rabbitmqctl stop_app &&
    rabbitmqctl reset &&
    rabbitmqctl start_app'
" --become

#rabbit2 will be used to connect to rabbit1 to formm a cluster
ansible rabbit2 -a "
  sudo docker exec -it rabbitmq bash -c '
    rabbitmqctl stop_app &&
    rabbitmqctl reset &&
    rabbitmqctl join_cluster rabbit@rabbit1 &&
    rabbitmqctl start_app'
" --become
