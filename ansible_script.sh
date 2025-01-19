
#Run the playbook
ansible-playbook -v rabbitmq_play.yml 

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

ansible rabbit3 -a "
  sudo docker exec -it rabbitmq bash -c '
    rabbitmqctl stop_app &&
    rabbitmqctl reset &&
    rabbitmqctl join_cluster rabbit@rabbit1 &&
    rabbitmqctl start_app'
" --become
