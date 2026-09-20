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
  let emit = match target {
    "moonbit" => @backend.emit_moonbit
    _ => abort("Unsupported target: \{target}")
  }
  let raw = @fs.read_file_to_string(filename)
  let tokens = @lexer.tokenize(raw)
  let module_ = @parser.parse_tokens(tokens)
  let code = emit(module_)
  match args.get("output") {
    Some([output]) => @fs.write_string_to_file(output, code)
    _ => println(code)
  }
}
