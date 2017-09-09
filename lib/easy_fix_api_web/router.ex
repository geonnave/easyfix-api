defmodule EasyFixApiWeb.Router do
  use EasyFixApiWeb, :router

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

  scope "/", EasyFixApiWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/api", EasyFixApiWeb do
    pipe_through :api

    post "/sessions", SessionController, :create
    delete "/sessions", SessionController, :delete

    resources "/garages", GarageController, except: [:new, :edit] do
      resources "/orders", GarageOrderController, only: [:index, :show], name: :order do
        resources "/budget", BudgetController, only: [:show, :create], name: :budget, singleton: true
      end
    end

    resources "/customers", CustomerController, except: [:new, :edit] do
      resources "/orders", CustomerOrderController, only: [:index, :show, :create], name: :order
    end

    resources "/addresses", AddressController, except: [:new, :edit]
    get "/cities", CityController, :index
    resources "/bank_accounts", BankAccountController, except: [:new, :edit]
    get "/banks", BankController, :index

    resources "/users", UserController, only: [:index, :create, :show]
    resources "/diagnosis", DiagnosisController, except: [:new, :edit]
    resources "/budgets", BudgetController, except: [:new, :edit]
    resources "/orders", OrderController, except: [:new, :edit]

    resources "/vehicles", VehicleController, except: [:new, :edit]
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
