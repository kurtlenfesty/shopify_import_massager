# ShopifyImportMassager

The script takes Shopify CSV exports and converts the order name in the csv to
the _real_ underlying order number. This makes it easy to import the shopify
data even if the customer is using multiple different order prefixes and suffixes
and having third-party mechanisms injecting orders as well.

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

### Preparing to run the massager
1. Make a copy of the `massager_parameters_example.ex` file and rename it to: `massager_parameters.ex`
2. Rename the module name in `massager_parameters.ex` to `MassagerParameters`
3. Change the parameters to reflect the files you are trying to modify

Note that the copied `massager_parameters.ex` won't be added to git.

**Note that the program won't run until a `MassagerParameters` module exists.**

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
iex -S mix

# Note if you make coding changes, you will need to reload the code.
# You can reload the code by `^C` out of the iex shell and re-do `iex -S mix`
# or from the iex shell:
recompile

```

From the IEX shell `iex(1)> `, etc. 

**NOTE** You will need to edit `shopify_import_massager.ex` so the correct paths and files are laid out.

### Massaging a single file (for testing)
```shell
MassagerCommander.massage_single()
```

### Massage a single file and display the mapping results
```shell
MassagerCommander.massage_single_and_display()
```

### Massage all the files:
```shell
MassagerCommander.massage_all()

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

