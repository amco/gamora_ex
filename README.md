# Gamora

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `gamora` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:gamora, "~> 0.1.0"}
  ]
end
```

## Configuration

Add the following to `config/config.exs`:

```elixir
  config :my_app, :gamora,
    authorization_server: [
      host: "https://authserver.com",
      client_id: "MY_APP_CLIENT_ID",
      client_secret: "MY_APP_CLIENT_SECRET"
  ]
```

## Usage

### Protected Routes

Use the plug `Gamora.Plugs.AuthenticatedUser` in your protected routes.
This will try to get the access token from cookies and validate it against
the authorization server.

```elixir
defmodule MyAppWeb.Router do
  use MyAppWeb, :router

  # ... pipelines

  pipeline :protected do
    plug Gamora.Plugs.AuthenticatedUser
  end

  scope "/", MyAppWeb do
    pipe_through [:browser, :protected]

    # Add your protected routes here
  end

  # ... routes
end
```

If your app is an API you'll need to add `format: :json` to the plug
options. It will try to find the access token in the request header
`Authorization: Bearer <access_token>`.

```elixir
defmodule MyAppWeb.Router do
  use MyAppWeb, :router

  # ... pipelines

  pipeline :protected do
    plug Gamora.Plugs.AuthenticatedUser, format: :json
  end

  # ... routes
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/gamora>.

