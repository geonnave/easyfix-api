defmodule EasyFixApi.Vouchers do
  @moduledoc """
  The Vouchers context.
  """

  import Ecto.Query, warn: false
  alias EasyFixApi.Repo

  alias EasyFixApi.Vouchers.IndicationCode

  @coder Hashids.new(
    salt: "easyfix rules!",
    alphabet: "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
  )

  def coder, do: @coder

  def generate_indication_code(customer) do
    first_name =
      customer.name
      |> String.split(" ")
      |> List.first
      |> String.normalize(:nfd)
      |> String.replace(~r/\W/u, "")
      |> String.upcase

    first_name <> Hashids.encode(@coder, customer.id)
  end

  def list_indication_codes do
    Repo.all(IndicationCode)
  end

  def get_indication_code!(id), do: Repo.get!(IndicationCode, id)

  def create_indication_code(attrs \\ %{}) do
    %IndicationCode{}
    |> IndicationCode.changeset(attrs)
    |> Repo.insert()
  end

  def update_indication_code(%IndicationCode{} = indication_code, attrs) do
    indication_code
    |> IndicationCode.changeset(attrs)
    |> Repo.update()
  end

  def delete_indication_code(%IndicationCode{} = indication_code) do
    Repo.delete(indication_code)
  end

  def change_indication_code(%IndicationCode{} = indication_code) do
    IndicationCode.changeset(indication_code, %{})
  end
end
