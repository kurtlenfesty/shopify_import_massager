defmodule ShopifyImportMassagerTest do
  use ExUnit.Case

  # From the command line at project root, you know, `mix test`

  describe "gets substitutions and converts files" do
    test "converts test_orders_1|2|3" do
      parameters = %{
        input_folder: "test/source_files",
        output_folder: "test/output_files",
        orders_files_filename_parameters: %{
          filename_prefix: "test_orders_",
          filename_suffix: ".csv",
          starting_index: 1,
          ending_index: 3,
          number_padding_characters: 3
        },
        returns_files_filename_parameters: %{
          filename_prefix: "test_returns_",
          filename_suffix: ".csv",
          starting_index: 1,
          ending_index: 1,
          number_padding_characters: 2
        },
        transactions_files_filename_parameters: %{
          filename_prefix: "test_transactions_",
          filename_suffix: ".csv",
          starting_index: 1,
          ending_index: 1,
          number_padding_characters: 1
        }
      }

      ShopifyImportMassager.convert_files(parameters,
        show_substitutions: true
      )
    end
  end

  describe "create test output file" do
    @tag :skip
    test "creates output file 1" do
      source = [
        ["#191207", "#191207@dummy_email", "paid", "2021-11-30 15:52:53 -0500", "unfulfilled"],
        [
          "#191_SHOULD_WORK_206",
          "#191_SHOULD_WORK_206@dummy_email",
          "paid",
          "2021-11-30 15:44:36 -0500",
          "unfulfilled"
        ],
        ["#191205", "#191205@dummy_email", "paid", "2021-11-30 15:36:41 -0500", "unfulfilled"],
        ["#191205", "#191205@dummy_email", "", "", ""],
        [
          "#191_FOUR_204",
          "#191_FOUR_204@dummy_email",
          "paid",
          "2021-11-30 15:31:36 -0500",
          "unfulfilled"
        ],
        [
          "THREE#191203",
          "THREE#191203@dummy_email",
          "paid",
          "2021-11-30 15:29:27 -0500",
          "unfulfilled"
        ],
        [
          "#191202TWO",
          "#191202TWO@dummy_email",
          "paid",
          "2021-11-30 15:28:00 -0500",
          "unfulfilled"
        ],
        ["#191201", "#191201@dummy_email", "paid", "2021-11-30 15:21:53 -0500", "unfulfilled"],
        ["#191201", "#191201@dummy_email", "", "", ""],
        ["#191201", "#191201@dummy_email", "", "", ""],
        ["#191200", "#191200@dummy_email", "paid", "", "unfulfilled"],
        ["#191200", "#191200@dummy_email", "", "", ""],
        [
          "#191_PUT-TOGETHER_199",
          "#191_PUT-TOGETHER_199@dummy_email",
          "paid",
          "2021-11-30 15:11:58 -0500",
          "unfulfilled"
        ],
        ["#191_PUT-TOGETHER_199", "#191_PUT-TOGETHER_199@dummy_email", "", "", ""],
        ["#191_PUT-TOGETHER_199", "#191_PUT-TOGETHER_199@dummy_email", "", "", ""],
        ["#191198", "#191198@dummy_email", "paid", "2021-11-30 15:08:09 -0500", "unfulfilled"],
        ["#191198", "#191198@dummy_email", "", "", ""],
        ["#191197", "#191197@dummy_email", "paid", "2021-11-30 15:07:59 -0500", "unfulfilled"],
        ["#191196", "#191196@dummy_email", "paid", "2021-11-30 15:05:34 -0500", "unfulfilled"],
        ["#191196", "#191196@dummy_email", "", "", ""],
        ["#191195", "#191195@dummy_email", "paid", "2021-11-30 14:50:13 -0500", "unfulfilled"],
        ["#191194", "#191194@dummy_email", "paid", "2021-11-30 14:38:25 -0500", "unfulfilled"],
        ["#191194", "#191194@dummy_email", "", "", ""],
        ["#191193", "#191193@dummy_email", "paid", "2021-11-30 14:37:43 -0500", "unfulfilled"],
        [
          "#191192_TOGETHER",
          "#191192_TOGETHER@dummy_email",
          "paid",
          "2021-11-30 14:34:49 -0500",
          "unfulfilled"
        ],
        ["#191192_TOGETHER", "#191192_TOGETHER@dummy_email", "", "", ""],
        [
          "BUDDY_#191191",
          "BUDDY_#191191@dummy_email",
          "paid",
          "2021-11-30 14:34:14 -0500",
          "unfulfilled"
        ],
        ["BUDDY_#191191", "BUDDY_#191191@dummy_email", "", "", ""],
        ["#191190", "#191190@dummy_email", "paid", "2021-11-30 14:29:12 -0500", "unfulfilled"],
        ["#191190", "#191190@dummy_email", "", "", ""],
        [
          "#191_MULT-LINE-ONE_189",
          "#191_MULT-LINE-ONE_189@dummy_email",
          "paid",
          "2021-11-30 14:26:39 -0500",
          "unfulfilled"
        ],
        ["#191188", "#191188@dummy_email", "paid", "2021-11-30 14:22:06 -0500", "unfulfilled"],
        ["#191188", "#191188@dummy_email", "", "", ""],
        ["#191187", "#191187@dummy_email", "partially_refunded", "", "unfulfilled"]
      ]

      output_file_name =
        "/aa-work/shopify-imports/SOME_CUSTOMER/test-subs/CREATED_OUTPUT_FILE_1.csv"

      output_file = File.open!(output_file_name, [:write, :utf8])

      source
      |> CSV.encode()
      |> Enum.each(&IO.write(output_file, &1))

      File.close(output_file)
    end
  end
end
