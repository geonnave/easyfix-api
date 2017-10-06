defmodule EasyFixApiWeb.SessionView do
  use EasyFixApiWeb, :view
  alias EasyFixApi.Accounts.{Garage, Customer}
  alias EasyFixApiWeb.{GarageView, CustomerView}

  def render("show.json", %{account: garage = %Garage{}, jwt: jwt}) do
    %{data: render_one(garage, GarageView, "garage.json"), jwt: jwt}
  end
  def render("show.json", %{account: customer = %Customer{}, jwt: jwt}) do
    %{data: render_one(customer, CustomerView, "customer.json"), jwt: jwt}
  end
end
