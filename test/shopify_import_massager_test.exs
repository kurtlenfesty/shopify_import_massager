defmodule ShopifyImportMassagerTest do
  use ExUnit.Case

  # From the command line at project root, you know, `mix test`

  describe "extract_order_number/1" do
    test "extracts order number when it exists" do
      assert ShopifyImportMassager.extract_order_number("#12345") == 12345
      assert ShopifyImportMassager.extract_order_number("#99123") == 99123
      assert ShopifyImportMassager.extract_order_number("#1") == 1
    end

    test "extracts nil when order number doesn't match" do
      assert ShopifyImportMassager.extract_order_number("#191192_TOGETHER") == nil
      assert ShopifyImportMassager.extract_order_number("#191_MULT-LINE-ONE_189") == nil
      assert ShopifyImportMassager.extract_order_number("THREE#191203") == nil
      assert ShopifyImportMassager.extract_order_number("just a string") == nil
      assert ShopifyImportMassager.extract_order_number("1234") == nil
    end
  end

  describe "convert_to_order_number_name_map/1" do
    test "converts properly to number-name map" do
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

      assert ShopifyImportMassager.convert_to_order_number_name_map(source) == [
               %{is_valid: true, order_name: "#191207", order_number: 191_207},
               %{
                 is_valid: false,
                 order_name: "#191_SHOULD_WORK_206",
                 order_number: nil
               },
               %{is_valid: true, order_name: "#191205", order_number: 191_205},
               %{is_valid: true, order_name: "#191205", order_number: 191_205},
               %{is_valid: false, order_name: "#191_FOUR_204", order_number: nil},
               %{is_valid: false, order_name: "THREE#191203", order_number: nil},
               %{is_valid: false, order_name: "#191202TWO", order_number: nil},
               %{is_valid: true, order_name: "#191201", order_number: 191_201},
               %{is_valid: true, order_name: "#191201", order_number: 191_201},
               %{is_valid: true, order_name: "#191201", order_number: 191_201},
               %{is_valid: true, order_name: "#191200", order_number: 191_200},
               %{is_valid: true, order_name: "#191200", order_number: 191_200},
               %{
                 is_valid: false,
                 order_name: "#191_PUT-TOGETHER_199",
                 order_number: nil
               },
               %{
                 is_valid: false,
                 order_name: "#191_PUT-TOGETHER_199",
                 order_number: nil
               },
               %{
                 is_valid: false,
                 order_name: "#191_PUT-TOGETHER_199",
                 order_number: nil
               },
               %{is_valid: true, order_name: "#191198", order_number: 191_198},
               %{is_valid: true, order_name: "#191198", order_number: 191_198},
               %{is_valid: true, order_name: "#191197", order_number: 191_197},
               %{is_valid: true, order_name: "#191196", order_number: 191_196},
               %{is_valid: true, order_name: "#191196", order_number: 191_196},
               %{is_valid: true, order_name: "#191195", order_number: 191_195},
               %{is_valid: true, order_name: "#191194", order_number: 191_194},
               %{is_valid: true, order_name: "#191194", order_number: 191_194},
               %{is_valid: true, order_name: "#191193", order_number: 191_193},
               %{
                 is_valid: false,
                 order_name: "#191192_TOGETHER",
                 order_number: nil
               },
               %{
                 is_valid: false,
                 order_name: "#191192_TOGETHER",
                 order_number: nil
               },
               %{is_valid: false, order_name: "BUDDY_#191191", order_number: nil},
               %{is_valid: false, order_name: "BUDDY_#191191", order_number: nil},
               %{is_valid: true, order_name: "#191190", order_number: 191_190},
               %{is_valid: true, order_name: "#191190", order_number: 191_190},
               %{
                 is_valid: false,
                 order_name: "#191_MULT-LINE-ONE_189",
                 order_number: nil
               },
               %{is_valid: true, order_name: "#191188", order_number: 191_188},
               %{is_valid: true, order_name: "#191188", order_number: 191_188},
               %{is_valid: true, order_name: "#191187", order_number: 191_187}
             ]
    end
  end

  describe "convert_mapped/1" do
    test "extracts a sequence correctly" do
      source = [
        %{is_valid: true, order_name: "#191207", order_number: 191_207},
        %{
          is_valid: false,
          order_name: "#191_SHOULD_WORK_206",
          order_number: nil
        },
        %{is_valid: true, order_name: "#191205", order_number: 191_205},
        %{is_valid: true, order_name: "#191205", order_number: 191_205},
        %{is_valid: false, order_name: "#191_FOUR_204", order_number: nil},
        %{is_valid: false, order_name: "THREE#191203", order_number: nil},
        %{is_valid: false, order_name: "#191202TWO", order_number: nil},
        %{is_valid: true, order_name: "#191201", order_number: 191_201},
        %{is_valid: true, order_name: "#191201", order_number: 191_201},
        %{is_valid: true, order_name: "#191201", order_number: 191_201},
        %{is_valid: true, order_name: "#191200", order_number: 191_200},
        %{is_valid: true, order_name: "#191200", order_number: 191_200},
        %{
          is_valid: false,
          order_name: "#191_PUT-TOGETHER_199",
          order_number: nil
        },
        %{
          is_valid: false,
          order_name: "#191_PUT-TOGETHER_199",
          order_number: nil
        },
        %{
          is_valid: false,
          order_name: "#191_PUT-TOGETHER_199",
          order_number: nil
        },
        %{is_valid: true, order_name: "#191198", order_number: 191_198},
        %{is_valid: true, order_name: "#191198", order_number: 191_198},
        %{is_valid: true, order_name: "#191197", order_number: 191_197},
        %{is_valid: true, order_name: "#191196", order_number: 191_196},
        %{is_valid: true, order_name: "#191196", order_number: 191_196},
        %{is_valid: true, order_name: "#191195", order_number: 191_195},
        %{is_valid: true, order_name: "#191194", order_number: 191_194},
        %{is_valid: true, order_name: "#191194", order_number: 191_194},
        %{is_valid: true, order_name: "#191193", order_number: 191_193},
        %{is_valid: false, order_name: "#191192_TOGETHER", order_number: nil},
        %{is_valid: false, order_name: "#191192_TOGETHER", order_number: nil},
        %{is_valid: false, order_name: "BUDDY_#191191", order_number: nil},
        %{is_valid: false, order_name: "BUDDY_#191191", order_number: nil},
        %{is_valid: true, order_name: "#191190", order_number: 191_190},
        %{is_valid: true, order_name: "#191190", order_number: 191_190},
        %{
          is_valid: false,
          order_name: "#191_MULT-LINE-ONE_189",
          order_number: nil
        },
        %{is_valid: true, order_name: "#191188", order_number: 191_188},
        %{is_valid: true, order_name: "#191188", order_number: 191_188},
        %{is_valid: true, order_name: "#191187", order_number: 191_187}
      ]

      assert ShopifyImportMassager.convert_mapped(source) == [
               %{
                 is_valid: true,
                 order_name: "#191207",
                 order_number: 191_207,
                 previous_order_name: nil,
                 previous_order_number: nil
               },
               %{
                 is_valid: false,
                 order_name: "#191_SHOULD_WORK_206",
                 order_number: 191_206,
                 previous_order_name: "#191207",
                 previous_order_number: 191_207
               },
               %{
                 is_valid: true,
                 order_name: "#191205",
                 order_number: 191_205,
                 previous_order_name: "#191_SHOULD_WORK_206",
                 previous_order_number: 191_206
               },
               %{
                 is_valid: true,
                 order_name: "#191205",
                 order_number: 191_205,
                 previous_order_name: "#191205",
                 previous_order_number: 191_205
               },
               %{
                 is_valid: false,
                 order_name: "#191_FOUR_204",
                 order_number: 191_204,
                 previous_order_name: "#191205",
                 previous_order_number: 191_205
               },
               %{
                 is_valid: false,
                 order_name: "THREE#191203",
                 order_number: 191_203,
                 previous_order_name: "#191_FOUR_204",
                 previous_order_number: 191_204
               },
               %{
                 is_valid: false,
                 order_name: "#191202TWO",
                 order_number: 191_202,
                 previous_order_name: "THREE#191203",
                 previous_order_number: 191_203
               },
               %{
                 is_valid: true,
                 order_name: "#191201",
                 order_number: 191_201,
                 previous_order_name: "#191202TWO",
                 previous_order_number: 191_202
               },
               %{
                 is_valid: true,
                 order_name: "#191201",
                 order_number: 191_201,
                 previous_order_name: "#191201",
                 previous_order_number: 191_201
               },
               %{
                 is_valid: true,
                 order_name: "#191201",
                 order_number: 191_201,
                 previous_order_name: "#191201",
                 previous_order_number: 191_201
               },
               %{
                 is_valid: true,
                 order_name: "#191200",
                 order_number: 191_200,
                 previous_order_name: "#191201",
                 previous_order_number: 191_201
               },
               %{
                 is_valid: true,
                 order_name: "#191200",
                 order_number: 191_200,
                 previous_order_name: "#191200",
                 previous_order_number: 191_200
               },
               %{
                 is_valid: false,
                 order_name: "#191_PUT-TOGETHER_199",
                 order_number: 191_199,
                 previous_order_name: "#191200",
                 previous_order_number: 191_200
               },
               %{
                 is_valid: false,
                 order_name: "#191_PUT-TOGETHER_199",
                 order_number: 191_199,
                 previous_order_name: "#191_PUT-TOGETHER_199",
                 previous_order_number: 191_199
               },
               %{
                 is_valid: false,
                 order_name: "#191_PUT-TOGETHER_199",
                 order_number: 191_199,
                 previous_order_name: "#191_PUT-TOGETHER_199",
                 previous_order_number: 191_199
               },
               %{
                 is_valid: true,
                 order_name: "#191198",
                 order_number: 191_198,
                 previous_order_name: "#191_PUT-TOGETHER_199",
                 previous_order_number: 191_199
               },
               %{
                 is_valid: true,
                 order_name: "#191198",
                 order_number: 191_198,
                 previous_order_name: "#191198",
                 previous_order_number: 191_198
               },
               %{
                 is_valid: true,
                 order_name: "#191197",
                 order_number: 191_197,
                 previous_order_name: "#191198",
                 previous_order_number: 191_198
               },
               %{
                 is_valid: true,
                 order_name: "#191196",
                 order_number: 191_196,
                 previous_order_name: "#191197",
                 previous_order_number: 191_197
               },
               %{
                 is_valid: true,
                 order_name: "#191196",
                 order_number: 191_196,
                 previous_order_name: "#191196",
                 previous_order_number: 191_196
               },
               %{
                 is_valid: true,
                 order_name: "#191195",
                 order_number: 191_195,
                 previous_order_name: "#191196",
                 previous_order_number: 191_196
               },
               %{
                 is_valid: true,
                 order_name: "#191194",
                 order_number: 191_194,
                 previous_order_name: "#191195",
                 previous_order_number: 191_195
               },
               %{
                 is_valid: true,
                 order_name: "#191194",
                 order_number: 191_194,
                 previous_order_name: "#191194",
                 previous_order_number: 191_194
               },
               %{
                 is_valid: true,
                 order_name: "#191193",
                 order_number: 191_193,
                 previous_order_name: "#191194",
                 previous_order_number: 191_194
               },
               %{
                 is_valid: false,
                 order_name: "#191192_TOGETHER",
                 order_number: 191_192,
                 previous_order_name: "#191193",
                 previous_order_number: 191_193
               },
               %{
                 is_valid: false,
                 order_name: "#191192_TOGETHER",
                 order_number: 191_192,
                 previous_order_name: "#191192_TOGETHER",
                 previous_order_number: 191_192
               },
               %{
                 is_valid: false,
                 order_name: "BUDDY_#191191",
                 order_number: 191_191,
                 previous_order_name: "#191192_TOGETHER",
                 previous_order_number: 191_192
               },
               %{
                 is_valid: false,
                 order_name: "BUDDY_#191191",
                 order_number: 191_191,
                 previous_order_name: "BUDDY_#191191",
                 previous_order_number: 191_191
               },
               %{
                 is_valid: true,
                 order_name: "#191190",
                 order_number: 191_190,
                 previous_order_name: "BUDDY_#191191",
                 previous_order_number: 191_191
               },
               %{
                 is_valid: true,
                 order_name: "#191190",
                 order_number: 191_190,
                 previous_order_name: "#191190",
                 previous_order_number: 191_190
               },
               %{
                 is_valid: false,
                 order_name: "#191_MULT-LINE-ONE_189",
                 order_number: 191_189,
                 previous_order_name: "#191190",
                 previous_order_number: 191_190
               },
               %{
                 is_valid: true,
                 order_name: "#191188",
                 order_number: 191_188,
                 previous_order_name: "#191_MULT-LINE-ONE_189",
                 previous_order_number: 191_189
               },
               %{
                 is_valid: true,
                 order_name: "#191188",
                 order_number: 191_188,
                 previous_order_name: "#191188",
                 previous_order_number: 191_188
               },
               %{
                 is_valid: true,
                 order_name: "#191187",
                 order_number: 191_187,
                 previous_order_name: "#191188",
                 previous_order_number: 191_188
               }
             ]
    end
  end

  describe "gets substitutions and converts files" do
    test "converts test_orders_1|2|3" do
      input_folder = "test/source_files"
      output_folder = "test/output_files"

      test_file_1 = "test_orders_1.csv"
      test_file_2 = "test_orders_2.csv"
      test_file_3 = "test_orders_3.csv"

      file_names = [test_file_1, test_file_2, test_file_3]

      ShopifyImportMassager.convert_files(input_folder, output_folder, file_names, file_names,
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
