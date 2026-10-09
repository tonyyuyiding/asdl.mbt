///|
pub using @lexer {
  tokenize,
  type Token,
  type TokenBody,
  type TokenizeError,
  type Position,
}

///|
pub using @parser {parse_tokens, type ParseError}

///|
pub using @backend {emit_moonbit}

///|
pub fn asdl_to_moonbit(code : StringView) -> String raise {
  let tokens = tokenize(code)
  let module_ = parse_tokens(tokens)
  @checker.check_types(module_)
  emit_moonbit(module_)
}
