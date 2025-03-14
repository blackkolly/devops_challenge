Challenge 1: Create a custom bridge network and connect two containers (alpine and nginx).
1.	Create a custom bridge network:
bash
Copy
docker network create my_bridge_network
2.	Run the alpine and nginx containers and connect them to the network:
bash
Copy
docker run -d --name alpine_container --network my_bridge_network alpine sleep 3600
docker run -d --name nginx_container --network my_bridge_network nginx
3.	Verify the containers are connected:
bash
Copy
docker network inspect my_bridge_network

Challenge 2: Run a MySQL container with a named volume (mysql_data) and confirm data persistence after container restart.

1.	Run the MySQL container with a named volume:
bash
Copy
docker run -d --name mysql_container -e MYSQL_ROOT_PASSWORD=mysecretpassword -v mysql_data:/var/lib/mysql mysql
2.	Restart the container and verify data persistence:
bash
Copy
docker restart mysql_container
docker exec -it mysql_container mysql -uroot -pmysecretpassword -e "SHOW DATABASES;"

