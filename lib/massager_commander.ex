defmodule MassagerCommander do
  @file_path_root "/aa-work/2022-09-05_SOME-CUSTOMER_shopify-historical-import"
  @single_orders_file "/aa-work/2022-09-05_SOME-CUSTOMER_shopify-historical-import/import_massaging/orders_export_06.csv"
  @all_orders_files [
    "orders_export_01.csv",
    "orders_export_02.csv",
    "orders_export_03.csv",
    "orders_export_04.csv",
    "orders_export_05.csv",
    "orders_export_06.csv",
    "orders_export_07.csv",
    "orders_export_08.csv",
    "orders_export_09.csv",
    "orders_export_10.csv",
    "orders_export_11.csv",
    "orders_export_12.csv"
  ]

  # ["returns_export_1.csv"]
  @all_returns_files []

  # ["transactions_export_1.csv"]
  @all_transactions_files []

  # MassagerCommander.massage_single()
  def massage_single() do
    ShopifyImportMassager.extract_substitution_map(@single_orders_file)
  end

  # MassagerCommander.massage_single_and_display()
  def massage_single_and_display() do
    ShopifyImportMassager.extract_substitution_map(@single_orders_file)
    |> ShopifyImportMassager.display_results()
  end

  # MassagerCommander.massage_all()
  def massage_all() do
    input_folder = @file_path_root <> "/import_massaging_ORIGINAL"
    output_folder = @file_path_root <> "/import_massaging_OUTPUT"

    input_files = @all_orders_files
    output_files = @all_orders_files ++ @all_returns_files ++ @all_transactions_files

    ShopifyImportMassager.convert_files(input_folder, output_folder, input_files, output_files,
      show_substitutions: true
    )
  end

  def massage_all(
        output_folder,
        orders_files_filename_parameters = %{},
        returns_files_filename_parameters = %{},
        transactions_files_parameters = %{}
      ) do
  end
end
