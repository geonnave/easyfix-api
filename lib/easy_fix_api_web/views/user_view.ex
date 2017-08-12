defmodule EasyFixApiWeb.UserView do
  use EasyFixApiWeb, :view
  alias EasyFixApiWeb.UserView

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("show_registration.json", %{user: user, jwt: jwt}) do
    %{data: render_one(user, UserView, "user.json"), jwt: jwt}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      email: user.email}
  end
end
