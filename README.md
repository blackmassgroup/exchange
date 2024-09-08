# Exchange

## Features

- [LiveView Authentication](https://fly.io/phoenix-files/phx-gen-auth/)
- User Role and Permission system
- [Direct to S3/Wasabi upload with LiveView](https://hexdocs.pm/phoenix_live_view/uploads-external.html#direct-to-s3-compatible)
- Presigned urls for secure download
- Calculates file hashes with [`:crypto.hash/2`](https://www.erlang.org/doc/man/crypto.html#hash-2)
- Uses [`libcluster`](https://fly.io/docs/elixir/the-basics/clustering/#adding-libcluster) and [`fly_postgres`](https://hexdocs.pm/fly_postgres/readme.html) for scalability
- [CI/CD](https://fly.io/docs/elixir/advanced-guides/github-actions-elixir-ci-cd/) setup and is deployed on Fly.io.
- Upload, login and get sample API routes
- ~~Custom Discord Logger backend~~
- Applicaiton Error tracking
- Uses Oban for retryable jobs.

### Built With

- **Postgres**
- **erlang**
- [**Elixir**](https://hexdocs.pm/elixir/Kernel.html)
- [**Phoenix**](https://hexdocs.pm/phoenix/Phoenix.html)
- [**Phoenix LiveView**](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html)
- [**TailwindCSS**](https://tailwindcss.com/docs/installation)

## Getting Started

### Prerequisites

1. Install `erlang`, `Elixir`, `NodeJS`, `Postgres`

   1. With homebrew the commands are:

   ```zsh
    brew update
    brew install erlang elixir nodejs postgres
   ```

### Installation

1.  Clone this Repo and enter the directory.
2.  Set up the project with the command `mix setup`
3.  Start Phoenix server with `iex -S mix phx.server`
    1. Now you can visit [`localhost:4000`](http://localhost:4000) or [`localhost:4001`](https://localhost:4001) from your browser.
4.  Once you register a user, you make it admin by running this in the same window you ran `iex -S mix phx.server` in (yes we run commands in a running server)
    1.  `VExchange.Accounts.get_user!(1) |> VExchange.Accounts.add_role_to_user("Admin")`

> You can run unit tests with the command `mix test`

### API Routes

### Bruno Collection

Bruno is a Postman,Insomnia/Insomnia alternative.

Setup

1. Install, on mac `brew install bruno`; others see their [website](https://www.usebruno.com/)
2. Import the collection from `/bruno`
3. Set ENV vars
4. Enjoy.

> I also provide a Postman friendly import file as well

Documentation can be found at [here](https://docs.virus.exchange) and requires an API key that can be found under user settings in the exchange app.
