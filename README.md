# VxUnderground

### Built With 🛠

- **Postgres** - 14.6.0
- **erlang** - 25.2
- [**Elixir**](https://hexdocs.pm/elixir/Kernel.html) - 1.14.3-otp-25
- [**Phoenix**](https://hexdocs.pm/phoenix/Phoenix.html) - 1.7.0-rc.2
- [**Phoenix LiveView**](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html) - 0.18.13
- **NodeJS** - 19.3.0
- [**TailwindCSS**](https://tailwindcss.com/docs/installation) - 3.0.23

## Getting Started 🏃

To get a local copy up and running follow these simple steps.

### Prerequisites 🔌

1. Install `erlang`, `Elixir`, `NodeJS`, `Postgres` and `stripe/stripe-cli/stripe`.

   1. With homebrew the commands are:

   ```zsh
    brew update
    brew install erlang elixir nodejs postgres
   ```

   2. Or if you prefer `asdf`

   ```zsh
    brew update
    brew install asdf

    asdf plugin-add erlang
    asdf plugin-add elixir
    asdf plugin-add nodejs

    asdf install erlang latest
    asdf install elixir latest
    asdf install nodejs latest

    asdf global erlang latest
    asdf global elixir latest
    asdf global nodejs latest
   ```
### Installation ⌨


1.  Clone this Repo and enter the directory.
2.  Install dependencies with `mix deps.get`.
3.  Install npm assets.
    1. `cd assets && npm ci && cd ../`
4.  Create and migrate your database with `mix ecto.setup`
5.  Add the following env variables in order to get Wasabi/S3 to work.
    1. `AWS_ACCESS_KEY_ID` 
    2. `AWS_SECRET_ACCESS_KEY`
6.  Start Phoenix server with `iex -S mix phx.server`
    1. Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
7.  Now you can visit `http://localhost:4000` in your browser and you will see the app running.

> You can run unit tests with the command `mix test`

## Database architecture 🗂
#TODO

## License 🔒

Distributed under the MIT License. See `LICENSE.txt` for more information.


## Contact 📩

John Herbener - [herbener.net](https://herbener.net) - john@herbener.cloud 
