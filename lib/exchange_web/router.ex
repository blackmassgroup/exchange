defmodule ExchangeWeb.Router do
  use ExchangeWeb, :router
  use ErrorTracker.Web, :router

  import ExchangeWeb.UserAuth
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug ExchangeWeb.Plugs.MaintenanceMode

    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {ExchangeWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :fetch_current_user

    plug :put_secure_browser_headers, %{
      "content-security-policy" =>
        "default-src 'self'; connect-src 'self' https://s3.us-east-1.wasabisys.com;"
    }
  end

  pipeline :browser_insecure do
    plug ExchangeWeb.Plugs.MaintenanceMode

    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {ExchangeWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :fetch_current_user

    plug :put_secure_browser_headers, %{
      "content-security-policy" =>
        "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; connect-src 'self' https://s3.amazonaws.com;"
    }
  end

  pipeline :api do
    plug ExchangeWeb.Plugs.MaintenanceMode

    plug :accepts, ["json", "multipart"]
  end

  scope "/", ExchangeWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", ExchangeWeb do
  #   pipe_through :api
  # end
  #

  # Uncomment to use Oban Dashboard
  #
  # import Oban.Web.Router

  # scope "/dev" do
  #   pipe_through :browser_insecure
  #   oban_dashboard("/oban")
  # end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:exchange, :dev_routes) do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  scope "/", ExchangeWeb do
    pipe_through [:api]

    post "/api/login", UserApiSessionController, :create
  end

  scope "/", ExchangeWeb do
    pipe_through [:api]

    post "/api/upload", SampleController, :create
    post "/api/samples/new", SampleController, :create

    get "/api/samples/:sha256", SampleController, :show
  end

  ## Authentication routes

  scope "/", ExchangeWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{ExchangeWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", ExchangeWeb do
    pipe_through [:browser, :require_authenticated_user, :require_admin_or_uploader]

    live_session :require_admin_or_uploader,
      on_mount: [{ExchangeWeb.UserAuth, :ensure_authenticated}] do
      live "/tags/new", TagLive.Index, :new
      live "/samples/new", SampleLive.Index, :new
    end
  end

  scope "/", ExchangeWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{ExchangeWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email

      live "/tags", TagLive.Index, :index
      live "/tags/:id", TagLive.Show, :show

      live "/samples", SampleLive.Index, :index
      live "/samples/:id", SampleLive.Show, :show
    end
  end

  scope "/" do
    pipe_through [:browser_insecure, :require_authenticated_user, :require_admin]

    live_dashboard "/dashboard",
      metrics: ExchangeWeb.Telemetry,
      additional_pages: [
        route_name: Phx2Ban.LiveDashboardPlugin
      ]

    error_tracker_dashboard("/errors", on_mount: [{ExchangeWeb.UserAuth, :ensure_admin}])
  end

  scope "/", ExchangeWeb do
    pipe_through [:browser, :require_authenticated_user, :require_admin]

    live_session :require_admin_user,
      on_mount: [{ExchangeWeb.UserAuth, :ensure_authenticated}] do
      live "/tags/:id/edit", TagLive.Index, :edit
      live "/tags/:id/show/edit", TagLive.Show, :edit

      # live "/samples/:id/edit", SampleLive.Index, :edit
      # live "/samples/:id/show/edit", SampleLive.Show, :edit

      live "/roles", RoleLive.Index, :index
      live "/roles/new", RoleLive.Index, :new
      live "/roles/:id/edit", RoleLive.Index, :edit

      live "/roles/:id", RoleLive.Show, :show
      live "/roles/:id/show/edit", RoleLive.Show, :edit

      live "/manage/users", AccountLive.User.Index, :index
      live "/manage/users/new", AccountLive.User.Index, :new
      live "/manage/users/:id/edit", AccountLive.User.Index, :edit

      live "/manage/users/:id", AccountLive.User.Show, :show
      live "/manage/users/:id/show/edit", AccountLive.User.Show, :edit
    end
  end

  scope "/", ExchangeWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    get "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{ExchangeWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
