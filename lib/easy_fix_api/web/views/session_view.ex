defmodule EasyFixApi.Web.SessionView do
  use EasyFixApi.Web, :view
  alias EasyFixApi.Accounts.{Garage}
  alias EasyFixApi.Web.{GarageView}

  def render("show.json", %{account: garage = %Garage{}, jwt: jwt}) do
    %{data: render_one(garage, GarageView, "garage.json"), jwt: jwt}
  end
end
