defmodule MassagerFilenameGenerator do
  # For example, this will turn: "input_path/order_1.csv" into {"input_path/order_1.csv", "input_path/order_01.csv"}
  def generate_filename_pairs(%{
        input_path_prefix: input_path_prefix,
        output_path_prefix: output_path_prefix,
        prefix: prefix,
        suffix: suffix,
        starting_number: starting_index,
        ending_index: ending_index,
        number_padding_characters: number_padding_characters
      }) do
    starting_index..ending_index
    |> Enum.map(fn index -> {Integer.toString(index), pad(index, number_padding_characters)} end)
    |> Enum.map(fn {original_index, padded_index} ->
      {prefix <> original_index <> suffix, prefix <> padded_index <> suffix}
    end)
    |> Enum.map(fn {original_filename, adjusted_filename} ->
      {Path.join(input_path_prefix, original_filename),
       Path.join(output_path_prefix, adjusted_filename)}
    end)
  end

  def generate_filenames(_) do
    raise "Expecting a map with " <>
            "[:path_prefix, :prefix, :suffix, :starting_index, :ending_index, :number_padding_characters}"
  end

  def pad(index, number_padding_characters) do
    index
    |> Integer.toString()
    |> String.pad_leading(number_padding_characters, "0")
  end
end
