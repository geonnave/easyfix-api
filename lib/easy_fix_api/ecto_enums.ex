import EctoEnum

defenum(EasyFixApi.Accounts.UserTypeEnum, :user_type, [:garage, :customer, :fixer, :admin])

defenum(EasyFixApi.Orders.StateEnum, :order_state,
  [:started,
   :created_with_diagnosis,
   :not_quoted_by_garages,
   :quoted_by_garages,
   :quote_not_accepted_by_customer,
   :quote_accepted_by_customer,
   :finished_by_garage,
   :timeout])
