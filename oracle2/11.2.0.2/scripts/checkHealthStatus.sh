
echo "Waiting for 'healthy' status"
res=&(docker inspect -f {{.State.Health.Status}} oracle-jan-2)

until [ "$res" == "healthy" ]; do
    sleep 0.1;
    res=$(docker inspect -f {{.State.Health.Status}} oracle-jan-2)
done;
sleep 15;
