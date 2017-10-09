defmodule EasyFixApi.Emails do
  import Bamboo.Email

  alias EasyFixApi.Orders.Matcher
  alias EasyFixApi.Mailer

  def send_email_to_matching_garages(new_order) do
    new_order
    |> Matcher.list_garages_matching_order
    |> Enum.map(&new_order_email(&1, new_order))
    |> Enum.each(&Mailer.deliver_now/1)
  end

  def new_order_email(garage, order) do
    ec2_budget_url = "http://ec2-18-221-115-152.us-east-2.compute.amazonaws.com:8080/#/orders/#{order.id}"

    new_email()
    |> to("#{garage.name} <#{garage.user.email}>")
    |> from("Easyfix <contato@easyfix.net.br>")
    |> subject("Novo Pedido Easyfix!")
    |> html_body("""
Olá #{garage.name}!
<br><br>
Um cliente acaba de nos enviar um pedido. Ele certamente está ansioso para receber o seu orçamento.
<br><br>
E aí, vamos orçar? <a href="#{ec2_budget_url}">Clique aqui</a> para abrir o painel de orçamento Easyfix.
    """)
  end
end