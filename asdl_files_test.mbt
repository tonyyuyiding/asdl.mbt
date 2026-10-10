///|
fn assert_generated_eq(asdl_file : String, mbt_file : String) -> Unit raise {
  let generated = @fs.read_file_to_string(asdl_file)
    |> @lexer.tokenize
    |> @parser.parse_tokens
    |> @backend.emit_moonbit
  let expected = @fs.read_file_to_string(mbt_file) |> @fmt.format
  assert_eq(generated, expected)
}

///|
test "bootstrapping" {
  assert_generated_eq("parser/asdl.asdl", "parser/ast.mbt")
}

///|
test "example Python.asdl" {
  assert_generated_eq("examples/Python.asdl", "examples/Python.mbt")
}
