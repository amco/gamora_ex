defmodule Gamora.Configuration do
  @default_adapter Gamora.Adapters.Request

  def adapter do
    config()
    |> Keyword.get(:adapter, @default_adapter)
  end

  def identity_provider do
    config()
    |> Keyword.fetch!(:identity_provider)
  end

  defp config do
    Mix.Project.get!().project()[:app]
    |> Application.fetch_env!(:gamora)
  end
end
