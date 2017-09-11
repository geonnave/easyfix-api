import EctoEnum

defenum(EasyFixApi.Accounts.UserTypeEnum, :user_type, [:garage, :customer, :fixer, :admin])

defenum(EasyFixApi.Orders.StateEnum, :order_state,
  [:started,
   :created_with_diagnosis,
   :not_budgeted_by_garages,
   :budgeted_by_garages,
   :budget_not_accepted_by_customer,
   :budget_accepted_by_customer,
   :finished_by_garage,
   :timeout])
