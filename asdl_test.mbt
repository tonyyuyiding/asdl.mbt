///|
test "tokenize basics" {
  let code = "foo Bar = , ? | ( ) * { }"
  let tokens = @asdl.tokenize(code)
  debug_inspect(
    tokens,
    content=(
      #|[
      #|  { body: TypeId(<StringView: "foo">), pos: 0 },
      #|  { body: ConstructorId(<StringView: "Bar">), pos: 4 },
      #|  { body: Equals, pos: 8 },
      #|  { body: Comma, pos: 10 },
      #|  { body: Question, pos: 12 },
      #|  { body: Pipe, pos: 14 },
      #|  { body: LParen, pos: 16 },
      #|  { body: RParen, pos: 18 },
      #|  { body: Asterisk, pos: 20 },
      #|  { body: LBrace, pos: 22 },
      #|  { body: RBrace, pos: 24 },
      #|]
    ),
  )
}

///|
test "tokenize with underscore" {
  let code = "foo_bar Baz_123"
  let tokens = @asdl.tokenize(code)
  debug_inspect(
    tokens,
    content=(
      #|[
      #|  { body: TypeId(<StringView: "foo_bar">), pos: 0 },
      #|  { body: ConstructorId(<StringView: "Baz_123">), pos: 8 },
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
      #|[
      #|  { body: TypeId(<StringView: "foo">), pos: 0 },
      #|  { body: ConstructorId(<StringView: "Bar">), pos: 52 },
      #|]
    ),
  )
}

///|
test "panic tokenize unknown symbol" {
  let code = "foo @"
  let _ = @asdl.tokenize(code)
}
