defmodule Gamora.Plugs.AuthenticatedUser do
  import Plug.Conn

  alias Plug.Conn
  alias Gamora.Authorization

  @moduledoc """
  This plug is in charge to verify and validate the access token
  provided in the request against the OpenID Connect Provider.
  It will try to get the access token from headers for json requests,
  otherwise from cookies.

  If the access token is valid, the current user will be assigned to the
  connection and the request will continue as normal. In the other hand,
  it will halt the request with an unauthorized code for json requests,
  otherwise it will render the 401.html error view.
  """

  def init(opts), do: opts

  def call(%Conn{} = conn, opts) do
    format = Keyword.get(opts, :format, :html)
    callbacks = Keyword.get(opts, :callbacks)

    with {:ok, access_token} <- get_access_token(conn, format),
         {:ok, response} <- validate_access_token(access_token) do
      callbacks.access_token_success(conn, response)
      conn
    else
      {:error, error} ->
        response = %{error: error, format: format}
        callbacks.access_token_error(conn, response)
    end
  end

  defp get_access_token(%Conn{} = conn, :json) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> access_token] -> {:ok, access_token}
      _ -> {:error, :access_token_required}
    end
  end

  defp get_access_token(%Conn{} = conn, :html) do
    case get_access_token_from_cookies(conn) do
      nil -> {:error, :access_token_required}
      access_token -> {:ok, access_token}
    end
  end

  defp get_access_token_from_cookies(%Conn{} = conn) do
    cookie_name = get_cookie_name_for_access_token()
    conn = fetch_cookies(conn, signed: [cookie_name])
    conn.cookies[cookie_name]
  end

  defp validate_access_token(access_token) do
    case Authorization.authorize_access_token(access_token) do
      {:ok, response} -> {:ok, response}
      {:error, error} -> {:error, error}
    end
  end

  defp get_cookie_name_for_access_token do
    app = Mix.Project.get!().project()[:app]
    "_#{app}_web_access_token"
  end
end
