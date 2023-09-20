defmodule EasyFixApi.VouchersTest do
  use EasyFixApi.DataCase

  alias EasyFixApi.Vouchers

  describe "indication_codes" do
    alias EasyFixApi.Vouchers.IndicationCode

    test "generate_indication_code" do
      [
        {"John Silva", "JOHN"},
        {"João Silva", "JOAO"},
        {"Diego", "DIEGO"},
        {"Svetlana Fydryczewski", "SVETLANA"}
      ]
      |> Enum.each(fn {name, capitapized_first_name} ->
        customer = build(:customer) |> with_name(name) |> insert()
        expected_code = capitapized_first_name <> Hashids.encode(Vouchers.coder, customer.id)

        assert expected_code == Vouchers.generate_indication_code(customer)
      end)
    end
  end
end
