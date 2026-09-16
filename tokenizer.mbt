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
pub suberror TokenizeError {
  UnknownSymbol(Char)
}

///|
fn next_token(scanner : @lexbuf.StringScanner) -> Token raise TokenizeError {
  lexscan scanner {
    re"^[a-z][a-zA-Z0-9_]*" as id => TypeId(id)
    re"^[A-Z][a-zA-Z0-9_]*" as id => ConstructorId(id)
    re"^[=,?|()*{}]" as operator => operator_table[operator]
    re"^[[:space:]]+" => next_token(scanner)
    re"^--[^\n]*\n?" => next_token(scanner)
    re"^$" => Eof
    re"^." as symbol => raise UnknownSymbol(symbol)
  }
}

///|
pub fn tokenize(code : StringView) -> Array[Token] raise TokenizeError {
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
