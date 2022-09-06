defmodule ShopifyImportMassager do
  @moduledoc """
  Massages csv import files, specifically for a shopify customer.
  """

  @order_number_regex ~r|^#(\d+)$|

  @doc """
    This is our main function call that does all the work.
  """
  def convert_files(
        input_folder,
        output_folder,
        orders_files_filename_parameters = %{},
        returns_files_filename_parameters = %{},
        transactions_files_parameters = %{},
        options \\ []
      ) do
    IO.puts("Processing START")

    # We want the unchanged list of files so we can extract our substitutions
    orders_input_files =
      orders_files_filename_parameters
      |> Map.merge(%{
        input_path_prefix: input_folder,
        output_path_prefix: "IGNORED",
        number_padding_characters: 0
      })
      |> MassagerFilenameGenerator.generate_filename_pairs()
      |> Enum.map(fn {input_filename, _output_filename} -> input_filename end)

    substitution_map =
      orders_input_files
      |> Enum.map(fn file_name ->
        SubstitutionMapExtractor.extract_substitution_map(file_name)
      end)
      |> List.flatten()

    IO.puts("Order name substitutions extracted")

    SubstitutionMapExtractor.show_substitutions(substitution_map, options)

    IO.puts("Processing order files with parameters #{inspect(orders_files_filename_parameters)}")

    %{
      substitution_map: substitution_map,
      input_folder: input_folder,
      output_folder: output_folder,
      filename_parameters: orders_files_filename_parameters
    }
    |> substitute()

    IO.puts(
      "Processing returns files with parameters #{inspect(returns_files_filename_parameters)}"
    )

    %{
      substitution_map: substitution_map,
      input_folder: input_folder,
      output_folder: output_folder,
      filename_parameters: returns_files_filename_parameters
    }
    |> substitute()

    IO.puts(
      "Processing transactions files with parameters #{inspect(transactions_files_filename_parameters)}"
    )

    %{
      substitution_map: substitution_map,
      input_folder: input_folder,
      output_folder: output_folder,
      filename_parameters: transactions_files_filename_parameters
    }
    |> substitute()

    IO.puts("Processing COMPLETE")
  end

  def substitute(%{
        substitution_map: substitution_map,
        input_folder: input_folder,
        output_folder: output_folder,
        filename_parameters: filename_parameters
      }) do
    Map.merge(filename_parameters, %{
      input_path_prefix: input_folder,
      output_path_prefix: output_folder
    })
    |> generate_filenames()
    |> Enum.each(fn {input_file, output_file} ->
      substitute(%{
        substitution_map: substitution_map,
        input_file: input_file,
        output_file: output_file
      })
    end)
  end

  def substitute(%{
        substitution_map: substitution_map,
        input_file: input_file_name,
        output_file: output_file_name
      }) do
    IO.puts("Processing input: #{input_file_name}\n --> output: #{output_file_name}")

    input_file = File.open!(input_file_name, [:read, :utf8])
    output_file = File.open!(output_file_name, [:write, :utf8])

    input_file
    |> IO.stream(:line)
    |> Enum.map(fn input_line ->
      substitute_input_line(input_line, substitution_map)
    end)
    |> Enum.each(fn output_line ->
      IO.write(output_file, output_line)
    end)

    File.close(input_file)
    File.close(output_file)
  end

  def substitute_input_line(input_line, substitution_map) do
    substitution_map
    |> Enum.reduce(
      input_line,
      fn %{order_name: order_name, replace_order_number: replace_order_number}, adjusted_line ->
        String.replace(adjusted_line, order_name, replace_order_number, global: true)
      end
    )
  end
end
