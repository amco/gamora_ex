defmodule Gamora.Authorization.AccessToken do
  alias HTTPoison.Response

  def authorize(token) do
    authorization_request(token)
    |> process_response()
  end

  defp app_name(), do: Mix.Project.get!().project()[:app]

  defp authorization_request(token) do
    adapter().post(url(), data(token), [
      {"Content-Type", "application/json"}
    ])
  end

  defp adapter do
    authorization_server_config(:adapter)
  end

  defp url do
    authorization_server_config(:host)
    |> Kernel.<>("/oauth/introspect")
  end

  defp authorization_server_config(config) do
    app_name()
    |> Application.fetch_env!(:gamora)
    |> Keyword.fetch!(:authorization_server)
    |> Keyword.fetch!(config)
  end

  defp data(token) do
    %{
      token: token,
      client_id: authorization_server_config(:client_id),
      client_secret: authorization_server_config(:client_secret)
    }
    |> Jason.encode!()
  end

  defp process_response({:ok, %Response{status_code: 200, body: body}}) do
    process_response(Jason.decode(body))
  end

  defp process_response({:ok, %{"active" => true} = data}), do: {:ok, data}
  defp process_response(_), do: {:error, :access_token_invalid}
end
