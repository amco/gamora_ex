defmodule Gamora.Adapters.Request do
  defdelegate post, to: HTTPoison
end
