defmodule EasyFixApi.Emails.Internal do
  import Bamboo.Email, except: [new_email: 0]

  def new_email do
    Bamboo.Email.new_email()
    |> from("EasyFix <contato@easyfix.net.br>")
    |> to("EasyFix <contato@easyfix.net.br>")
  end

  def new_order_call_direct(order = %{customer: customer}) do
    new_email()
    |> subject("[Pedido ##{order.id}] Novo Call Direct!")
    |> html_body("""
O cliente ##{customer.id} acaba de fazer o pedido \##{order.id}! Aqui estão seus dados:<br>
<br>
Nome: #{customer.name}<br>
Telefone: #{customer.phone}<br>
Email: #{customer.user.email}<br><br>
<br>
    """)
  end

  def new_order_call_fixer(order = %{customer: customer}) do
    new_email()
    |> subject("[Pedido ##{order.id}] Novo Outros Reparos!")
    |> html_body("""
O cliente #{customer.name} acaba de fazer o pedido \##{order.id}! É um pedido do tipo "outros". Aqui estão seus dados:<br>
<br>
Cliente ID: #{customer.id}<br>
Nome: #{customer.name}<br>
Telefone: #{customer.phone}<br>
Email: #{customer.user.email}<br><br>
<br>
Veja o que ele escreveu sobre o reparo necessário:<br>
#{order.diagnosis.comment}
    """)
  end

  def new_customer(customer) do
    [vehicle] = customer.vehicles

    new_email()
    |> subject("Novo Cliente!")
    |> html_body("""
Um novo cliente acaba de se cadastrar! Aqui estão seus dados:<br>
<br>
ID: #{customer.id}<br>
Nome: #{customer.name}<br>
Telefone: #{customer.phone}<br>
Email: #{customer.user.email}<br><br>
<br>
Veículo: #{vehicle.model.name}<br>
Ano: #{vehicle.model_year}<br>
    """)
  end

  def notify_customer_purchase(order = %{customer: customer, accepted_quote: accepted_quote}) do
    new_email()
    |> subject("[Pedido ##{order.id}] Cliente ##{customer.id} comprou")
    |> html_body("""
O cliente #{customer.name} comprou um orçamento:
<br>
<strong>Oficina</strong>: ##{accepted_quote.issuer.garage.id} #{accepted_quote.issuer.garage.name}<br>
#{accepted_quote.issuer.email} | #{accepted_quote.issuer.garage.phone}<br><br>
<br>
<strong>Cliente</strong>: ##{customer.id} #{customer.name}<br>
#{customer.user.email} | #{customer.phone}<br>
<br>
    """)
  end

  def customer_rating(order = %{customer: customer}) do
    new_email()
    |> subject("[Pedido ##{order.id}] Cliente ##{customer.id} avaliou")
    |> html_body("""
O cliente #{customer.name} deu nota #{order.rating}, e comentou:<br>
<br>
#{order.rating_comment || "(comentário vazio)"}
    """)
  end

  def customer_message(order = %{customer: customer}, message) do
    new_email()
    |> from("#{customer.name} <#{customer.user.email}>")
    |> subject("[Pedido ##{order.id}] Cliente ##{customer.id} enviou mensagem")
    |> text_body("Veja o que o #{customer.name} escreveu: \n\n" <> message)
  end
end
