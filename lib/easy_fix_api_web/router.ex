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

    resources "/customers", CustomerController, except: [:new, :edit]
    resources "/garages", GarageController, except: [:new, :edit]
    resources "/users", UserController, except: [:new, :edit]

    resources "/addresses", AddressController, except: [:new, :edit]
    get "/cities", AddressController, :cities

    resources "/bank_accounts", BankAccountController, except: [:new, :edit]
    get "/banks", BankController, :index

    get "/garages/:garage_id/orders", GarageOrderController, :list_orders
    get "/garages/:garage_id/orders/:order_id", GarageOrderController, :list_orders
    post "/garages/:garage_id/orders/:order_id/budgets", GarageOrderController, :create_budget

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
