defmodule EasyFixApi.TotalVoice do
  use Tesla

  plug Tesla.Middleware.Logger
  plug Tesla.Middleware.BaseUrl, "https://api.totalvoice.com.br"
  plug Tesla.Middleware.Headers, %{"Access-Token" => "c2e96c65d7f591e3628ad2602e17fb7c"}
  plug Tesla.Middleware.JSON

  def send_sms(text, _number) do
    post("/sms", %{"numero_destino" => "11970338405", "mensagem" => text})
  end

end

defmodule EasyFixApi.MockVoice do
  require Logger

  def send_sms(text, number) do
    Logger.debug "Pretending to send SMS: #{inspect %{"numero_destino" => number, "mensagem" => text}}"
  end
end
