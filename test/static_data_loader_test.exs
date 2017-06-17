defmodule EasyFixApi.StaticDataLoaderTest do
  use ExUnit.Case, async: true

  import EasyFixApi.StaticDataLoader

  test "read and prepare csv" do
    raw_csv = """
    h1,h2,h3
    a,b,c
    x,y,z
    """
    assert [["a", "b", "c"], ["x", "y", "z"]] == prepare_csv(raw_csv)
  end

  test "Load Vehicle data" do
    raw_csv = """
    Montadoras,Modelos 
    Acura,Integra GS 1.8
    ,Legend 3.2/3.5
    ,NSX 3.0
    AM Gen,Hummer Hard-Top 6.5 4x4 Diesel TB
    ,Hummer Open-Top 6.5 4x4 Diesel TB
    ,Hummer Wagon 6.5 4x4 Diesel TB
    """

    brands_to_models = %{"Acura" => acura_models, "AM Gen" => am_gen_models} = transform_vehicles_models(raw_csv)
    assert 3 == length(acura_models)
    assert 3 == length(am_gen_models)
  end

  test "Load Parts data" do
    raw_csv = """
Subgrupo 1 ,Subgrupo 2,Componentes a trocar,especialidade sugerida,check search google/ML,Repair by FIXER,Repair by GARAGE,,
ELEMENTOS DE FIXAÇÃO,,PARAFUSO,TODAS,x,,x,,
,,PORCA,TODAS,x,,x,,
,,CLIP,TODAS,x,,x,,
TRANSMISSÕES,ACIONAMENTO CAIXA DE CAMBIO MANUAL,SEMI EIXO COMPLETO TRANSMISSÃO ESQUERDA CAMBIO MANUAL,MECANICA,x,,x,,
,,SEMI EIXO COMPLETO TRANSMISSÃO DIREITA CAMBIO MANUAL,MECANICA,x,,x,,
,,PARAFUSO CABEÇA EXCÊNTRICA,MECANICA,x,,x,,
,ACIONAMENTO CAIXA DE CAMBIO AUTOMÁTICA,SEMI EIXO ESQUERDA CAMBIO AUTOMATICO,MECANICA,x,,x,,
,,SEMI EIXO DIREITO CAMBIO AUTOMATICO,MECANICA,x,,x,,
,,JUNTA TOROIDAL ESQUERDA,MECANICA,x,,x,,
,,JUNTA TOROIDAL DIREITA,MECANICA,x,,x,,
RODAS,,CONTRAPESO PARA BALANCEAMENTO, PNEUS E RODAS,x,,x,,
,,RODA DE LIGA LEVE  ORIGINAL, PNEUS E RODAS,x,x,x,,
    """
    parts_csv = [
      %{group: "ELEMENTOS DE FIXAÇÃO", sub_group: "", name: "PARAFUSO", garage_type: "TODAS", repair_by_fixer: ""},
      %{group: "ELEMENTOS DE FIXAÇÃO", sub_group: "", name: "PORCA", garage_type: "TODAS", repair_by_fixer: ""},
      %{group: "ELEMENTOS DE FIXAÇÃO", sub_group: "", name: "CLIP", garage_type: "TODAS", repair_by_fixer: ""},
      %{group: "TRANSMISSÕES", sub_group: "ACIONAMENTO CAIXA DE CAMBIO MANUAL", name: "SEMI EIXO COMPLETO TRANSMISSÃO ESQUERDA CAMBIO MANUAL", garage_type: "MECANICA", repair_by_fixer: ""},
      %{group: "TRANSMISSÕES", sub_group: "ACIONAMENTO CAIXA DE CAMBIO MANUAL", name: "SEMI EIXO COMPLETO TRANSMISSÃO DIREITA CAMBIO MANUAL", garage_type: "MECANICA", repair_by_fixer: ""},
      %{group: "TRANSMISSÕES", sub_group: "ACIONAMENTO CAIXA DE CAMBIO MANUAL", name: "PARAFUSO CABEÇA EXCÊNTRICA", garage_type: "MECANICA", repair_by_fixer: ""},
      %{group: "TRANSMISSÕES", sub_group: "ACIONAMENTO CAIXA DE CAMBIO AUTOMÁTICA", name: "SEMI EIXO ESQUERDA CAMBIO AUTOMATICO", garage_type: "MECANICA", repair_by_fixer: ""},
      %{group: "TRANSMISSÕES", sub_group: "ACIONAMENTO CAIXA DE CAMBIO AUTOMÁTICA", name: "SEMI EIXO DIREITO CAMBIO AUTOMATICO", garage_type: "MECANICA", repair_by_fixer: ""},
      %{group: "TRANSMISSÕES", sub_group: "ACIONAMENTO CAIXA DE CAMBIO AUTOMÁTICA", name: "JUNTA TOROIDAL ESQUERDA", garage_type: "MECANICA", repair_by_fixer: ""},
      %{group: "TRANSMISSÕES", sub_group: "ACIONAMENTO CAIXA DE CAMBIO AUTOMÁTICA", name: "JUNTA TOROIDAL DIREITA", garage_type: "MECANICA", repair_by_fixer: ""},
      %{group: "RODAS", sub_group: "", name: "CONTRAPESO PARA BALANCEAMENTO", garage_type: " PNEUS E RODAS", repair_by_fixer: ""},
      %{group: "RODAS", sub_group: "", name: "RODA DE LIGA LEVE  ORIGINAL", garage_type: " PNEUS E RODAS", repair_by_fixer: "x"},
    ]

    parsed_parts = transform_parts(raw_csv)
    for parsed_item <- parts_csv do
      name = parsed_item[:name]
      part_item = Enum.find(parsed_parts, & &1[:name] == name)
      refute is_nil(part_item)
      assert parsed_item == part_item
    end
  end
end
