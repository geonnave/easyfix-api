defmodule EasyFixApi.Web.Router do
  use EasyFixApi.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
  end

  scope "/", EasyFixApi.Web do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/api", EasyFixApi.Web do
    pipe_through :api

    post "/sessions", SessionController, :create
    delete "/sessions", SessionController, :delete

    resources "/garages", GarageController, except: [:new, :edit]
    resources "/users", UserController, except: [:new, :edit]

    resources "/addresses", AddressController, except: [:new, :edit]
    get "/cities", AddressController, :cities

    get "/banks", BankController, :index

    resources "/models", ModelController, except: [:new, :edit]
    resources "/brands", BrandController, except: [:new, :edit]

    resources "/parts", PartController, except: [:new, :edit]
    resources "/garage_categories", GarageCategoryController, except: [:new, :edit]
    resources "/part_systems", PartSystemController, except: [:new, :edit]
    resources "/part_groups", PartGroupController, except: [:new, :edit]
    resources "/part_sub_groups", PartSubGroupController, except: [:new, :edit]

    resources "/repair_by_fixer_parts", RepairByFixerPartController, except: [:new, :edit]
  end
end
