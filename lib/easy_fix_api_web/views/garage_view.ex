defmodule EasyFixApiWeb.GarageView do
  use EasyFixApiWeb, :view
  alias EasyFixApiWeb.GarageView

  def render("index.json", %{garages: garages}) do
    %{data: render_many(garages, GarageView, "garage_summary.json")}
  end

  def render("show.json", %{garage: garage}) do
    %{data: render_one(garage, GarageView, "garage.json")}
  end

  def render("show_registration.json", %{garage: garage, jwt: jwt}) do
    %{data: render_one(garage, GarageView, "garage.json"), jwt: jwt}
  end

  def render("garage_summary.json", %{garage: garage}) do
    %{id: garage.id,
      name: garage.name,
      owner_name: garage.owner_name,
      email: garage.user.email,
      phone: garage.phone,
      garage_categories: render_many(garage.garage_categories, EasyFixApiWeb.GarageCategoryView, "garage_category.json"),
      cnpj: garage.cnpj}
  end

  def render("garage.json", %{garage: garage}) do
    %{id: garage.id,
      name: garage.name,
      owner_name: garage.owner_name,
      email: garage.user.email,
      phone: garage.phone,
      garage_categories: render_many(garage.garage_categories, EasyFixApiWeb.GarageCategoryView, "garage_category.json"),
      address: render_one(garage.address, EasyFixApiWeb.AddressView, "address.json"),
      bank_account: render_one(garage.bank_account, EasyFixApiWeb.BankAccountView, "bank_account.json"),
      cnpj: garage.cnpj}
  end
end
