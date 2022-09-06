defmodule SubstitutionMapExtractor do
  # Massages a single file
  def extract_substitution_map(file_path) do
    file_path
    |> Path.expand()
    |> Path.absname()
    |> IO.inspect(label: "Extracting substitution map from:")
    |> File.stream!()
    |> CSV.decode!()
    |> convert()
  end

  def convert(decoded_csv) do
    decoded_csv
    # Remove the first line, it's just headers
    |> Enum.drop(1)
    |> convert_to_order_number_name_map()
    |> convert_mapped()
    |> Enum.filter(fn %{is_valid: is_valid} = _row_map -> not is_valid end)
    |> Enum.map(fn %{order_number: order_number} = conversion_map ->
      conversion_map |> Map.put(:replace_order_number, "##{order_number}")
    end)
  end

  def display_results(converted_and_filtered) do
    converted_and_filtered
    |> Enum.map(fn single_row ->
      # Just want to look at the input here
      IO.puts("#{inspect(single_row)}")
      single_row
    end)
    |> Enum.map(fn %{order_name: order_name, order_number: order_number} = _row_map ->
      IO.puts("#{order_name}, ##{order_number}")
      "#{order_name}, ##{order_number}"
    end)
  end

  # For easier testing
  def convert_to_order_number_name_map(row_list) do
    row_list
    |> Enum.map(&to_order_number_name_map/1)
  end

  def convert_mapped(order_number_name_map) do
    order_number_name_map
    |> Enum.reduce([], &populate_missing_order_numbers/2)
    # Reverse our list so it's newest to oldest
    |> Enum.reverse()

    # Filter out is_valid == true
    # Produce a CSV file of order_number, order_name?
    # which can be used to substitute across all input files?
  end

  def to_order_number_name_map(row_list) do
    [order_name | _remainder_of_row] = row_list
    # %{order_name: order_name, row_list: row_list} |> IO.inspect(label: "\n\nDEBUG")
    order_number = extract_order_number(order_name)

    %{
      order_name: order_name,
      order_number: order_number,
      is_valid: order_number != nil
    }
  end

  def extract_order_number(order_name) do
    case String.match?(order_name, @order_number_regex) do
      true ->
        [_original, extracted_order_number] = Regex.run(@order_number_regex, order_name)
        {converted_number, _ignored_remainder} = extracted_order_number |> Integer.parse()
        converted_number

      false ->
        nil
    end
  end

  def populate_missing_order_numbers(
        current_row = %{order_name: order_name, order_number: order_number},
        previous_rows
      ) do
    %{order_number: previous_order_number, order_name: previous_order_name} =
      extract_previous_row(previous_rows)

    real_order_number =
      case previous_order_name == order_name do
        true ->
          # Just use the previous_order_number
          # (the order number on the previous row, it doesn't change)
          previous_order_number

        false ->
          case order_number do
            nil ->
              # Only extract the previous order number if we don't already have one
              #              extracted = extract_previous_row_order_number(previous_rows)
              #              %{previous_rows: previous_rows, extracted: extracted}
              #              |> IO.inspect(label: "\n\nDEBUG 104")
              extract_previous_row_order_number(previous_rows) - 1

            _ ->
              order_number
          end
      end

    updated_current_row =
      current_row
      |> Map.put(:order_number, real_order_number)
      |> Map.put(:previous_order_name, previous_order_name)
      |> Map.put(:previous_order_number, previous_order_number)

    [updated_current_row | previous_rows]
  end

  def extract_previous_row_order_number(previous_rows) do
    %{order_number: previous_order_number} = extract_previous_row(previous_rows)

    if previous_order_number == nil && previous_rows != [] do
      # This is the first row so order_number must _NOT_ be nil
      IO.puts("Unexpected previous rows without an order number: #{inspect(previous_rows)}")
    end

    previous_order_number
  end

  def extract_previous_row(previous_rows) do
    case previous_rows do
      [previous_row | _] ->
        previous_row

      [] ->
        %{
          order_name: nil,
          order_number: nil,
          is_valid: false
        }
    end
  end

  def show_substitutions(substitution_map, options) do
    show_substitutions = Keyword.get(options, :show_substitutions, false)

    if show_substitutions do
      substitution_map
      |> Enum.each(fn %{
                        order_name: order_name,
                        previous_order_name: previous_order_name,
                        replace_order_number: replace_order_number
                      } = substitution_entry ->
        output = %{
          order_name: order_name,
          previous_order_name: previous_order_name,
          replace_order_number: replace_order_number
        }

        IO.puts("#{inspect(output)}")
      end)
    end
  end
end
