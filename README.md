# Gamora - OIDC Relying Party

Gamora aims to provide most of the functionality that is commonly
required in an OpenID Connect Relying Party. An OIDC Relying Party is
an OAuth 2.0 Client application that requires user authentication and
claims from an OpenID Connect Provider (IdP). More information about
[OpenID Connect](https://openid.net/connect/).

## Installation

To use `Gamora` add the dependency to your deps in `mix.exs`:

```elixir
def deps do
  [
    {:gamora, "~> 0.1.0"}
  ]
end
```

## Configuration

To configure the library use the `config/config.exs` to define `host`,
`client_id` and `client_secret`. It will end up looking something like:

```elixir
  config :my_app, :gamora,
    identity_provider: [
      host: "https://oidc.com",
      client_id: "MY_APP_CLIENT_ID",
      client_secret: "MY_APP_CLIENT_SECRET",
      token_path: "/oauth/token", # This is the default
      introspect_path: "/oauth/introspect" # This is the default
    ]
```

## Usage

### Protected Routes

Use the plug `Gamora.Plugs.AuthenticatedUser` in your protected routes.
This will get the access token from cookies and validate it against
the IDP (OIDC Identity Provider).

```elixir
defmodule MyAppWeb.Router do
  use MyAppWeb, :router

  # ... pipelines

  pipeline :protected do
    plug Gamora.Plugs.AuthenticatedUser,
      callbacks: MyAppWeb.GamoraCallbacks
  end

  scope "/", MyAppWeb do
    pipe_through [:browser, :protected]

    # Add your protected routes here
  end

  # ... routes
end
```

And define your callbacks module in your application. It may look
something like the following in a phoenix application:

```elixir
defmodule MyAppWeb.GamoraCallbacks do
  @behaviour Gamora.Callbacks

  import Plug.Conn
  import Phoenix.Controller

  @impl Gamora.Callbacks
  def access_token_error(conn, response) do
    conn
    |> put_view(ErrorView)
    |> put_status(:unauthorized)
    |> render("401.html")
    |> halt()
  end
end
```

If your app requires json response you'll need to add `format: :json`
to the plug options. It will get the access token from the request
header `Authorization: Bearer <access_token>`.

```elixir
defmodule MyAppWeb.Router do
  use MyAppWeb, :router

  # ... pipelines

  pipeline :protected do
    plug Gamora.Plugs.AuthenticatedUser,
      callbacks: MyAppWeb.GamoraCallbacks,
      format: :json
  end

  # ... routes
end
```

## Testing

To avoid hitting the OpenID Provider while tests are running, you
can use the `Gamora.Adapters.Mock` adapter in your `config/test.exs`:

```elixir
  config :my_app, :gamora, adapter: Gamora.Adapters.Mock
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/gamora>.

