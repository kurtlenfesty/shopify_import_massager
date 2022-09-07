defmodule ShopifyImportMassager do
  @moduledoc """
  Massages csv import files, specifically for a shopify customer.
  """

  alias Massager.FilenameGenerator

  @doc """
    This is our main function call that does all the work.
  """
  # TODO
  # - Handle invalid ranges
  def convert_files(
        %{
          input_folder: input_folder,
          output_folder: output_folder,
          orders_files_filename_parameters: orders_files_filename_parameters = %{},
          returns_files_filename_parameters: returns_files_filename_parameters = %{},
          transactions_files_filename_parameters: transactions_files_filename_parameters = %{}
        },
        options \\ []
      ) do
    # TODO This function could be a bit more streamlined so it's easier to follow.

    IO.puts("Processing START")

    substitution_map =
      extract_substitution_map(
        %{
          orders_files_filename_parameters: orders_files_filename_parameters,
          input_folder: input_folder
        },
        options
      )

    IO.puts("Processing order files with parameters #{inspect(orders_files_filename_parameters)}")

    %{
      substitution_map: substitution_map,
      input_folder: input_folder,
      output_folder: output_folder,
      filename_parameters: orders_files_filename_parameters,
      file_type: :orders
    }
    |> substitute()

    IO.puts(
      "Processing returns files with parameters #{inspect(returns_files_filename_parameters)}"
    )

    %{
      substitution_map: substitution_map,
      input_folder: input_folder,
      output_folder: output_folder,
      filename_parameters: returns_files_filename_parameters,
      file_type: :returns
    }
    |> substitute()

    IO.puts(
      "Processing transactions files with parameters #{inspect(transactions_files_filename_parameters)}"
    )

    %{
      substitution_map: substitution_map,
      input_folder: input_folder,
      output_folder: output_folder,
      filename_parameters: transactions_files_filename_parameters,
      file_type: :transactions
    }
    |> substitute()

    IO.puts("Processing COMPLETE")
  end

  def extract_substitution_map(
        %{
          orders_files_filename_parameters: orders_files_filename_parameters,
          input_folder: input_folder
        },
        options
      ) do
    # We want the unchanged list of files so we can extract our substitutions
    orders_input_files =
      orders_files_filename_parameters
      |> Map.merge(%{
        input_path_prefix: input_folder,
        output_path_prefix: "IGNORED",
        number_padding_characters: 0
      })
      |> FilenameGenerator.generate_filename_pairs()
      |> Enum.map(fn %{input_file: input_file} -> input_file end)
      # We reverse the file list because we want to start with the oldest file
      # and work forwards in time.
      |> Enum.reverse()

    # Kind of tricky here, but we needed to incorporate information from the
    # previous file to capture the last number for the case when the new file
    # starts with a non-extractable number.
    # TODO This really needs a unit test
    substitution_map =
      orders_input_files
      |> Enum.reduce([%{conversions: [], file_last_order_number: 0}], fn file_name,
                                                                         previous_conversions = [
                                                                           %{
                                                                             conversions: _,
                                                                             file_last_order_number:
                                                                               file_last_order_number
                                                                           }
                                                                           | _
                                                                         ] ->
        [
          SubstitutionMapExtractor.extract_substitution_map(%{
            file_name: file_name,
            previous_file_last_order_number: file_last_order_number
          })
          | previous_conversions
        ]
      end)
      |> Enum.map(fn %{conversions: conversions, file_last_order_number: _file_last_order_number} ->
        conversions
      end)
      # Let's have the order be the same as the file order
      |> Enum.reverse()
      |> List.flatten()

    IO.puts("Order name substitutions extracted")

    SubstitutionMapExtractor.show_substitutions(substitution_map, options)

    substitution_map |> convert_substitution_map()
  end

  # Convert the substitution_map to a lookup table for faster conversions.
  def convert_substitution_map(substitution_map) do
    substitution_map
    |> Enum.reduce(
      %{},
      fn map_entry = %{
           order_name: order_name,
           previous_order_name: _,
           replace_order_number: replace_order_number
         },
         order_name_map ->
        case Map.get(order_name_map, order_name, nil) do
          nil ->
            Map.put(order_name_map, order_name, replace_order_number)

          ^replace_order_number ->
            # It's already there (sometimes the order is spread across multiple lines)
            order_name_map

          a_different_order_number ->
            IO.puts(
              "WARNING: KEEPING EXISING ENTRY: We have 2 orders with the same entry: " <>
                "existing_entry: #{inspect(a_different_order_number)}, new_entry: #{inspect(replace_order_number)} " <>
                "map_entry: #{inspect(map_entry)}"
            )

            order_name_map
        end
      end
    )
  end

  def substitute(%{
        substitution_map: substitution_map,
        input_folder: input_folder,
        output_folder: output_folder,
        filename_parameters: filename_parameters = %{filename_prefix: _},
        file_type: file_type
      }) do
    Map.merge(filename_parameters, %{
      input_path_prefix: input_folder,
      output_path_prefix: output_folder
    })
    |> FilenameGenerator.generate_filename_pairs()
    |> Enum.each(fn %{input_file: input_file, output_file: output_file} ->
      substitute(%{
        substitution_map: substitution_map,
        input_file: input_file,
        output_file: output_file,
        column_index: file_type |> get_column_index()
      })
    end)
  end

  def substitute(%{
        substitution_map: _substitution_map,
        input_folder: _input_folder,
        output_folder: _output_folder,
        filename_parameters: _filename_parameters,
        file_type: _file_type
      }) do
    # This handles the case where we don't want to run a certain set of files.
    :no_op
  end

  def substitute(%{
        substitution_map: substitution_map,
        input_file: input_file_name,
        output_file: output_file_name,
        column_index: column_index
      }) do
    IO.puts(
      "Processing input: #{input_file_name}\n --> output: #{output_file_name}, " <>
        "column_index: #{inspect(column_index)}"
    )

    input_file = File.open!(input_file_name, [:read, :utf8])
    output_file = File.open!(output_file_name, [:write, :utf8])

    input_file
    |> IO.stream(:line)
    |> Enum.map(fn input_line ->
      substitute_input_line(%{
        input_line: input_line,
        substitution_map: substitution_map,
        column_index: column_index
      })
    end)
    |> Enum.each(fn output_line ->
      IO.write(output_file, output_line)
    end)

    File.close(input_file)
    File.close(output_file)
  end

  def get_column_index(file_type) do
    # If it's an orders file, then only substitute on the first column.
    # If it's a transaction, then only substitute on the second column.
    # If it's a return, then only substitute on the first column.
    # Remember: 0-based indexing
    case file_type do
      :orders -> 0
      :transactions -> 1
      :returns -> 0
    end
  end

  # TODO It is slow and inefficient to do a line-by-line substitution for each
  # input-output string, but sometimes orders names are referenced in a
  # comment field. This is probably not an issue because we're trying to
  # extract financial information such as sales values from the orders,
  # not act as a source of truth.
  #
  # One approach is to do global substitutions across the whole file. That may
  # or may not be faster.
  #
  # Substitutions are done only matched on the given column, but done across
  # the whole line. This may or may not be wise.
  def substitute_input_line(%{
        input_line: input_line,
        substitution_map: substitution_map,
        column_index: column_index
      }) do
    match_column_value = input_line |> String.split(",") |> Enum.fetch!(column_index)
    # IO.puts("match_column_value: #{inspect(match_column_value)}")

    case Map.get(substitution_map, match_column_value, nil) do
      nil ->
        input_line

      replace_order_number ->
        # TODO Do we really want to globally replace on order_name on the whole line?
        # IO.puts("Replacing #{match_column_value} with #{replace_order_number} in #{input_line}")
        String.replace(input_line, match_column_value, replace_order_number, global: true)
        # |> IO.inspect(label: "replacement line")
    end
  end
end
