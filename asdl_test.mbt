///|
test "tokenize basics" {
  let code = "foo Bar = , ? | ( ) * { }"
  let tokens = @asdl.tokenize(code)
  debug_inspect(
    tokens,
    content=(
      #|[
      #|  TypeId(<StringView: "foo">),
      #|  ConstructorId(<StringView: "Bar">),
      #|  Equals,
      #|  Comma,
      #|  Question,
      #|  Pipe,
      #|  LParen,
      #|  RParen,
      #|  Asterisk,
      #|  LBrace,
      #|  RBrace,
      #|]
    ),
  )
}

///|
test "tokenize with comments" {
  let code =
    #|foo -- this is a comment
    #|-- this is another comment
    #|Bar
  let tokens = @asdl.tokenize(code)
  debug_inspect(
    tokens,
    content=(
      #|[TypeId(<StringView: "foo">), ConstructorId(<StringView: "Bar">)]
    ),
  )
}
