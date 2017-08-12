defmodule EasyFixApiWeb.SessionView do
  use EasyFixApiWeb, :view
  alias EasyFixApi.Accounts.{Garage}
  alias EasyFixApiWeb.{GarageView}

  def render("show.json", %{account: garage = %Garage{}, jwt: jwt}) do
    %{data: render_one(garage, GarageView, "garage.json"), jwt: jwt}
  end
end
