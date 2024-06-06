defmodule AppWeb.Router do
  use AppWeb, :router

  import AppWeb.UserAuth, only: [redirect_if_user_is_authenticated: 2]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AppWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AppWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/sessions/:token", UserSessionController, :index
  end

  scope "/", AppWeb do
    pipe_through :browser

    # get "/", PageController, :home

    delete "/users/logout", UserSessionController, :logout

    live_session :ensure_authenticated,
      on_mount: [
        {AppWeb.UserAuth, :mount_current_user},
        {AppWeb.UserAuth, :ensure_authenticated}
      ] do
      live "/new", MyJobsLive, :new
      live "/edit/:id", MyJobsLive, :edit
      live "/my-jobs", MyJobsLive, :my_jobs
    end

    live_session :current_user,
      on_mount: [
        {AppWeb.UserAuth, :mount_current_user}
      ] do
      live "/", JobsLive, :index
      live "/:id", JobsLive, :show
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", AppWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:app, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AppWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
