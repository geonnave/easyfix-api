# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     EasyFixApi.Repo.insert!(%EasyFixApi.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias EasyFixApi.Addresses

{:ok, _sampa_state = %{id: sampa_id}} = Addresses.create_state(%{name: "São Paulo"})
{:ok, _sampa_city} = Addresses.create_city(%{name: "São Paulo", state_id: sampa_id})
