defmodule EasyFixApi.Helpers do
  def apply_changes_ensure_atom_keys(changeset) do
    changeset
    |> Ecto.Changeset.apply_changes()
    |> Enum.filter(fn {k, _v} -> is_atom(k) end)
    |> Enum.into(%{})
  end
end