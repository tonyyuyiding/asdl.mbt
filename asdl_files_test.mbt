///|
test "bootstrapping" {
  let generated = @fs.read_file_to_string("parser/asdl.asdl")
    |> @lexer.tokenize
    |> @parser.parse_tokens
    |> @backend.emit_moonbit
  let expected = @fs.read_file_to_string("parser/ast.mbt") |> @fmt.format
  assert_eq(generated, expected)
}
