defmodule EasyFixApi.Repo.Migrations.FixDigitisTypo do
  use Ecto.Migration

  def change do
    rename table(:payments), :card_last_digitis, to: :card_last_digits
  end
end
