defmodule EasyFixApi.Vouchers.IndicationCode do
  use Ecto.Schema
  import Ecto.Changeset
  alias EasyFixApi.Vouchers.IndicationCode

  schema "indication_codes" do
    field :code, :string
    field :date_used, :utc_datetime
    field :type, :string # indication | indication_reward
    belongs_to :customer, EasyFixApi.Accounts.Customer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%IndicationCode{} = indication_code, attrs) do
    indication_code
    |> cast(attrs, [:code, :type, :date_used])
    |> validate_required([:code, :type, :date_used])
  end

  @doc false
  def create_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:code, :type, :customer_id])
    |> validate_required([:code, :type])
  end

  def all_nested_assocs do
    [customer: []]
  end
end
