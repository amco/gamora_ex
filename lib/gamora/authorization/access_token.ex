defmodule Gamora.Authorization.AccessToken do
  alias HTTPoison.Response
  alias Gamora.Configuration

  defdelegate adapter, to: Configuration
  defdelegate client_id, to: Configuration.IdentityProvider
  defdelegate client_secret, to: Configuration.IdentityProvider
  defdelegate introspect_url, to: Configuration.IdentityProvider

  def authorize(token) do
    authorization_request(token)
    |> process_response()
  end

  defp authorization_request(token) do
    adapter().post(introspect_url(), data(token), [
      {"Content-Type", "application/json"}
    ])
  end

  defp data(token) do
    Jason.encode!(%{
      token: token,
      client_id: client_id(),
      client_secret: client_secret()
    })
  end

  defp process_response({:ok, %Response{status_code: 200, body: body}}) do
    process_response(Jason.decode(body))
  end

  defp process_response({:ok, %{"active" => true} = data}), do: {:ok, data}
  defp process_response({:ok, %{"active" => false}}), do: {:error, :expired}
  defp process_response(_), do: {:error, :invalid}
end
