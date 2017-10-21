#!/bin/bash

[ "$1" == "down" ] && docker-compose down && exit 0

docker-compose build web_dev

docker-compose run web_dev mix do deps.get, compile
docker-compose run web_dev mix ecto.reset
docker-compose run web_dev mix run priv/repo/prod_seeds.exs

docker-compose up -d web_dev
