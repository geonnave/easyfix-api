defmodule EasyFixApi.Emails.Internal do
  import Bamboo.Email, except: [new_email: 0]

  def new_email do
    Bamboo.Email.new_email()
    |> from("EasyFix <contato@easyfix.net.br>")
    |> to("EasyFix <contato@easyfix.net.br>")
  end

  def new_order_call_direct(order = %{customer: customer}) do
    new_email()
    |> subject("Novo Pedido Call Direct EasyFix!")
    |> html_body("""
O cliente #{customer.name} acaba de fazer o pedido \##{order.id}! Aqui estão seus dados:<br>
<br>
Cliente ID: #{customer.id}<br>
Nome: #{customer.name}<br>
Telefone: #{customer.phone}<br>
Email: #{customer.user.email}<br><br>
<br>
    """)
  end

  def new_order_call_fixer(order = %{customer: customer}) do
    new_email()
    |> subject("Novo Pedido Outros EasyFix!")
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
    |> subject("Novo Cliente EasyFix!")
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

  def customer_rating(order = %{customer: customer}) do
    new_email()
    |> subject("Avaliação Cliente EasyFix!")
    |> html_body("""
O cliente #{customer.name} (\##{customer.id}) acaba de avaliar o pedido \##{order.id}!
 Ele deu nota #{order.rating}, e comentou:<br>
<br>
#{order.rating_comment || "(comentário vazio)"}
    """)
  end

  def customer_message(customer, message) do
    new_email()
    |> from("#{customer.name} <#{customer.user.email}>")
    |> subject("Mensagem Cliente EasyFix")
    |> text_body(message)
  end
end
