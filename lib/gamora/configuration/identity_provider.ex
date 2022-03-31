defmodule Gamora.Configuration.IdentityProvider do
  alias Gamora.Configuration

  @default_token_path "/oauth/token"
  @default_introspect_path "/oauth/introspect"

  def host do
    config() |> Keyword.fetch!(:host)
  end

  def token_url do
    host() <> token_path()
  end

  def token_path do
    config()
    |> Keyword.get(:token_path, @default_token_path)
  end

  def introspect_url do
    host() <> introspect_path()
  end

  def introspect_path do
    config()
    |> Keyword.get(:introspect_path, @default_introspect_path)
  end

  def client_id do
    config() |> Keyword.fetch!(:client_id)
  end

  def client_secret do
    config() |> Keyword.fetch!(:client_secret)
  end

  defp config do
    Configuration.identity_provider()
  end
end
