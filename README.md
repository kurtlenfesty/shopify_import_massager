# ShopifyImportMassager

The script takes Shopify CSV exports and converts the order name in the csv to
the _real_ underlying order number. This makes it easy to import the shopify
data even if the customer is using multiple different order prefixes and
suffixes and having third-party mechanisms injecting orders as well.

## Warning on what happens to the data
**Warning**
Because the order names are being changed, it may mean that finding a specific
_historical_ order number might not work as planned.

For example, an order might have an order name of `E-75123-1` that comes from
an external (non-shopify-store source), which gets converted to an order number
of `#78775` because of the underlying shopify order numbering.

This order name gets converted in all the associated files (orders, transactions
and returns). So the order naming is _consistent_ across the files when the
shopify imports happen, so there's no issue with data getting properly linked.
However, it does mean that the original order name of `E-75123-1` does not exist
in the Solve data store. Generally this isn't so much an issue because we import
historical data to get our summary data, not to look at individual orders.

## Structure the conversion

### Input and output
This program expects:
- All the input files are in one folder
- All the output files get stored in a _different_ folder

### Processing mechanism
1. A mapping gets generated using all the order files from the input folder.
  - The mapping is between the original order names and the mapped order name.
2. The mapping is then used to substitute the original order name with the 
   mapped name across all the input files.
3. The subsituted files get written to the output folder

### Example of ordering changes (the mechanism)
For example, if we had a sequence of orders such as:
```csv
#100123,customer-Dee@example.com,,..
#100122,customer-Cee@example.com,,..
BIZARRO-123-ORDER-NUMBER,customer-Bee@example.com,,..
#100120,customer-Ayyy@example.com,,..
#100119,customer-Heyyy@example.com,,..
```
We can imply that the `BIZARRO-123-ORDER-NUMBER` should actually be
`#100121` and make that substitution across all the files where
`BIZARRO-123-ORDER-NUMBER` appears as an order number.

### IMPORTANT NOTES
**This process only works if we have the first file, with the first orders,
  as some customers will start getting creative with their order numbers soon
  after starting their store.**

**In order for substitutions to work, _ALL_ the files must be present: orders,
  returns and transactions.**

## Running the massager

```shell
mix deps.get

# Start the IEX shell, where you will set the parameters and run the massager.
iex -S mix

# Note if you make coding changes, you will need to reload the code.
# You can reload the code by `^C` out of the iex shell and re-do `iex -S mix`
# or from the iex shell:
recompile

```

_From the IEX shell `iex(1)> `, etc._ 

### Set the variables for the run
**TODO This is still a bit complicated, could probably deduce the starting/ending indexes...**

Setup the variables that you'll use for the run. For example:
```shell
parameters = %{
  input_folder: "/path/to/source_files",
  output_folder: "/path/to/output_files",
  orders_files_filename_parameters: %{
    filename_prefix: "orders_export_",
    filename_suffix: ".csv",
    starting_index: 1,
    ending_index: 25,
    number_padding_characters: 2
  },
  returns_files_filename_parameters: %{
    filename_prefix: "returns_export_",
    filename_suffix: ".csv",
    starting_index: 1,
    ending_index: 4,
    number_padding_characters: 1
  },
  transactions_files_filename_parameters: %{
    filename_prefix: "transactions_export_",
    filename_suffix: ".csv",
    starting_index: 1,
    ending_index: 12,
    number_padding_characters: 2
  }
}

# Use `[show_substitutions: false]` if you don't want to see what the
# substitutions were.
options = [show_substitutions: true]
```

Note that the parameters can cover a range of situations, from a single file
conversion to many files converted.

### Convert the files:
```shell
ShopifyImportMassager.convert_files(parameters, options)

```

### Skipping returns or transactions files
You'll always need at least 1 orders file so that the substitutions get
extracted, but if you have no returns or transactions files to process, simply
use an empty map for those parameters, as in:
```shell
parameters = %{
  input_folder: "/path/to/source_files",
  output_folder: "/path/to/output_files",
  orders_files_filename_parameters: %{
    filename_prefix: "orders_export_",
    filename_suffix: ".csv",
    starting_index: 1,
    ending_index: 25,
    number_padding_characters: 2
  },
  returns_files_filename_parameters: %{},
  transactions_files_filename_parameters: %{}
}
```

## Testing
Running the unit tests is simple:
```shell
mix test
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `shopify_import_massager` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:shopify_import_massager, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/shopify_import_massager](https://hexdocs.pm/shopify_import_massager).
