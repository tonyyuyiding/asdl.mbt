///|
pub enum Token {
  TypeId(StringView)
  ConstructorId(StringView)
  Equals
  Comma
  Question
  Pipe
  LParen
  RParen
  Asterisk
  LBrace
  RBrace
  Eof
} derive(Debug)

///|
let operator_table : Map[Char, Token] = {
  '=': Equals,
  ',': Comma,
  '?': Question,
  '|': Pipe,
  '(': LParen,
  ')': RParen,
  '*': Asterisk,
  '{': LBrace,
  '}': RBrace,
}

///|
fn next_token(code : @lexbuf.StringScanner) -> Token {
  lexscan code {
    re"^[a-z][a-zA-Z0-9_]*" as id => TypeId(id)
    re"^[A-Z][a-zA-Z0-9_]*" as id => ConstructorId(id)
    re"^[=,?|()*{}]" as operator => operator_table[operator]
    re"^[[:space:]]+" => next_token(code)
    re"^--[^\n]*\n?" => next_token(code)
    _ => Eof
  }
}

///|
pub fn tokenize(code : StringView) -> Array[Token] {
  let scanner = @lexbuf.StringScanner::{ data: code, cursor: 0, }
  let tokens : Array[Token] = []
  while true {
    match next_token(scanner) {
      Eof => break
      token => tokens.push(token)
    }
  }
  tokens
}
