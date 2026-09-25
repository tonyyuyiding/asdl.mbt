///|
pub(all) enum Token {
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
} derive(Debug, Eq)

///|
pub extend Token with Debug::{to_repr}

///|
pub extend Token with Eq::{not_equal, equal}

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
/// Get the next token, or `None` if the input is exhausted.
fn next_token(scanner : @lexbuf.StringScanner) -> Token? raise TokenizeError {
  lexscan scanner {
    re"^[a-z][a-zA-Z0-9_]*" as id => Some(TypeId(id))
    re"^[A-Z][a-zA-Z0-9_]*" as id => Some(ConstructorId(id))
    re"^[[:space:]]+" => next_token(scanner)
    re"^--[^\n]*\n?" => next_token(scanner)
    re"^." as symbol =>
      match operator_table.get(symbol) {
        Some(operator) => Some(operator)
        None => raise TokenizeError::UnknownSymbol(symbol)
      }
    re"^$" => None
  }
}

///|
pub fn tokenize(code : StringView) -> Array[Token] raise TokenizeError {
  let scanner = @lexbuf.StringScanner::{ data: code, cursor: 0, }
  let tokens : Array[Token] = []
  while true {
    match next_token(scanner) {
      Some(token) => tokens.push(token)
      None => break
    }
  }
  tokens
}
