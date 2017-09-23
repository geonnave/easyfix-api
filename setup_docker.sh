#!/bin/bash

docker-compose build web_dev

docker-compose run web_dev mix do deps.get, compile
docker-compose run web_dev mix ecto.reset
docker-compose run web_dev mix run priv/repo/static_data_seeds.exs

docker-compose up -d web_dev



# command to pre-populate the database 
# mix ecto.reset && docker-compose run web_dev mix run priv/repo/static_data_seeds.exs

# command to DROP db and recreate all
# docker-compose down
# ./setup_docker.sh
