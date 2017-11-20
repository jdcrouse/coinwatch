defmodule CoinwatchWeb.Router do
  use CoinwatchWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    # look for a token in the header and validate it
    #plug CORSPlug, [origin: "http://localhost:3000"] #TODO this isnt working (see options routes)
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
  end

  #TODO eventually remove browser access altogether?
  #TODO also remove all non-json views + associated tests
  scope "/", CoinwatchWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
   scope "/api/0", CoinwatchWeb do
     pipe_through :api

     options "/session", SessionController, :cors
     post "/session", SessionController, :create # login
     delete "/session", SessionController, :delete #logout
     post "/session/refresh", SessionController, :refresh

     options "/markets", SessionController, :cors
     resources "/markets", MarketController, except: [:new, :edit]

     options "/users", SessionController, :cors
     resources "/users", UserController, except: [:new, :edit]
     resources "/notifications", NotificationController, except: [:new, :edit]

     options "/market_user", SessionController, :cors
     post "/market_user", MarketUserController, :create
     delete "/market_user", MarketUserController, :delete
   end
end
