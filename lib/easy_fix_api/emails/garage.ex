defmodule EasyFixApi.Emails.Garage do
  import Bamboo.Email, except: [new_email: 1]

  alias EasyFixApi.Mailer
  alias EasyFixApi.Orders.Matcher
  alias EasyFixApiWeb.EmailGarageView

  def new_email(garage) do
    Bamboo.Email.new_email()
    |> from("EasyFix <contato@easyfix.net.br>")
    |> to("#{garage.name} <#{garage.user.email}>")
  end

  def send_email_to_matching_garages(new_order) do
    new_order
    |> Matcher.list_garages_matching_order
    |> Enum.map(&new_order_call_direct(&1, new_order))
    |> Enum.each(&Mailer.deliver_later/1)
  end

  def new_order_call_direct(garage, order) do
    assigns = %{garage: garage, order: order}
    content = Phoenix.View.render_to_string(EmailGarageView, "new_order_call_direct.html", assigns)

    garage
    |> new_email()
    |> subject("Novo Pedido EasyFix!")
    |> html_body(content)
  end
end
