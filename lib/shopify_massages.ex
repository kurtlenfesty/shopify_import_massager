defmodule MaudeMassages do
  @single_orders_file "/qgo/aaa-solve-work/shopify-imports/dsanddurga/test_subs_1_input/orders_export_6.csv"
  @all_orders_files [
    "orders_export_1.csv",
    "orders_export_2.csv",
    "orders_export_3.csv",
    "orders_export_4.csv",
    "orders_export_5.csv",
    "orders_export_6.csv"
  ]

  @all_returns_files ["returns_export_1.csv"]

  @all_transactions_files ["transactions_export_1.csv"]

  # MaudeMassages.massage_single()
  def massage_single() do
    ShopifyImportMassager.extract_substitution_map(@single_orders_file)
  end

  # MaudeMassages.massage_single_and_display()
  def massage_single_and_display() do
    ShopifyImportMassager.extract_substitution_map(@single_orders_file)
    |> ShopifyImportMassager.display_results()
  end

  # MaudeMassages.massage_all()
  def massage_all() do
    input_folder = "/qgo/aaa-solve-work/shopify-imports/dsanddurga/test_subs_1_input"
    output_folder = "/qgo/aaa-solve-work/shopify-imports/dsanddurga/test_subs_1_output"

    input_files = @all_orders_files
    output_files = @all_orders_files ++ @all_returns_files ++ @all_transactions_files

    ShopifyImportMassager.convert_files(input_folder, output_folder, input_files, output_files,
      show_substitutions: true
    )
  end
end