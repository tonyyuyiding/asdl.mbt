///|
fn main raise {
  let cmd = @argparse.Command(
    "asdl-gen",
    positionals=[
      @argparse.PositionArg("filename", num_args=@argparse.ValueRange::single()),
    ],
    options=[
      @argparse.OptionArg("output", short='o', long="output"),
      @argparse.OptionArg("target", long="target", default_values=["moonbit"]),
    ],
  )
  let args = cmd.parse().values
  let filename = args["filename"][0]
  let target = args["target"][0]
  let source = @fs.read_file_to_string(filename)
  let result = match target {
    "moonbit" => @lib.asdl_to_moonbit(source)
    _ => abort("Unsupported target: \{target}")
  }
  match args.get("output") {
    Some([output]) => @fs.write_string_to_file(output, result)
    _ => println(result)
  }
}
