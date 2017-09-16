#!/bin/bash

docker-compose build web_dev
docker-compose up -d web_dev
docker-compose run web_dev mix do deps.get, compile
docker-compose run web_dev mix ecto.reseed
docker-compose run web_dev mix run priv/repo/static_data_seeds.exs
docker-compose restart web_dev
docker-compose run web_dev

# docker-compose stop web_dev && docker-compose build web_dev && docker-compose run web_dev mix ecto.reseed
