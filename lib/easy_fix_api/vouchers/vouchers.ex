defmodule EasyFixApi.Vouchers do
  @moduledoc """
  The Vouchers context.
  """

  import Ecto.{Query, Changeset}, warn: false
  alias EasyFixApi.Repo
  alias EasyFixApi.Vouchers.IndicationCode
  alias EasyFixApi.Accounts
  alias EasyFixApi.Accounts.{Customer}


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

  def create_indication(friends_code) do
    %{
      code: friends_code,
      type: "indication"
    }
    |> IndicationCode.create_changeset()
    |> case do
      %{valid?: true} = changeset ->
        changeset |> Repo.insert()
      changeset ->
        {:error, changeset}
    end
  end

  def create_reward(from_code, customer_id) do
    %{
      code: from_code,
      customer_id: customer_id,
      type: "reward"
    }
    |> IndicationCode.create_changeset()
    |> case do
      %{valid?: true} = changeset ->
        changeset |> Repo.insert()
      changeset ->
        {:error, changeset}
    end
  end

  def use_voucher(voucher_id) do
    voucher_id
    |> get_indication_code!()
    |> update_indication_code(%{date_used: DateTime.utc_now})
  end

  def reward_voucher(voucher_code) do
    customer = Accounts.get_customer_by(indication_code: voucher_code)
    create_reward(voucher_code, customer.id)
  end

  def list_indication_codes do
    Repo.all(IndicationCode)
    |> Repo.preload(IndicationCode.all_nested_assocs)
  end
  def list_indication_codes(customer_id) do
    from(ic in IndicationCode,
      join: c in Customer, on: c.id == ic.customer_id,
      where: c.id == ^customer_id,
      order_by: ic.inserted_at
    )
    |> Repo.all()
  end

  def list_available_indication_codes do
    from(ic in IndicationCode,
      where: is_nil(ic.date_used),
      preload: ^IndicationCode.all_nested_assocs
    )
    |> Repo.all()
  end
  def list_available_indication_codes(customer_id) do
    from(ic in IndicationCode,
      join: c in Customer, on: c.id == ic.customer_id,
      where: c.id == ^customer_id and is_nil(ic.date_used),
      order_by: ic.inserted_at
    )
    |> Repo.all()
  end

  def get_indication_code!(id) do
    Repo.get!(IndicationCode, id)
    |> Repo.preload(IndicationCode.all_nested_assocs)
  end

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
