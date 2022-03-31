defmodule Gamora.Authorization.AccessToken do
  alias HTTPoison.Response

  def authorize(token) do
    authorization_request(token)
    |> process_response()
  end

  defp authorization_request(token) do
    adapter().post(url(), data(token), [
      {"Content-Type", "application/json"}
    ])
  end

  defp adapter do
    identity_provider(:adapter)
  end

  defp url do
    identity_provider(:host)
    |> Kernel.<>("/oauth/introspect")
  end

  defp identity_provider(config) do
    Mix.Project.get!().project()[:app]
    |> Application.fetch_env!(:gamora)
    |> Keyword.fetch!(:identity_provider)
    |> Keyword.fetch!(config)
  end

  defp data(token) do
    %{
      token: token,
      client_id: identity_provider(:client_id),
      client_secret: identity_provider(:client_secret)
    }
    |> Jason.encode!()
  end

  defp process_response({:ok, %Response{status_code: 200, body: body}}) do
    process_response(Jason.decode(body))
  end

  defp process_response({:ok, %{"active" => true} = data}), do: {:ok, data}
  defp process_response(_), do: {:error, :access_token_invalid}
end
