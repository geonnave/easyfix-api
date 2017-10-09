defmodule EasyFixApi.Emails do
  import Bamboo.Email

  def test_email do
    new_email(
      # TODO: verify domain at Mailgun
      to: "Oficina XYZ <geonnave@gmail.com>",
      # to: "Contato Easyfix <contato@easyfix.net.br>",

      # TODO: verify domain at Mailgun
      # from: "Algum Cliente <cliente_easyfix@gmail.com>",
      from: "Cliente Easyfix <contato@easyfx.net.br>",

      subject: "Testing mail from EasyFixApi",
      text_body: "#{inspect(Timex.now)} The test works!"
    )
  end
end