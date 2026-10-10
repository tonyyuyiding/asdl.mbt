///|
pub(all) struct Token {
  body : TokenBody
  pos : Offset
} derive(Debug)

///|
pub extend Token with Debug::{to_repr}

///|
pub(all) enum TokenBody {
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
pub extend TokenBody with Debug::{to_repr}

///|
pub extend TokenBody with Eq::{equal, not_equal}

///|
let operator_table : Map[Char, TokenBody] = {
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
pub type Offset = Int

///|
pub suberror TokenizeError {
  UnknownSymbol(Char)
}

///|
/// Get the next token, or `None` if the input is exhausted.
fn next_token(scanner : @lexbuf.StringScanner) -> Token? raise TokenizeError {
  let pos = scanner.cursor
  lexscan scanner {
    re"^[a-z][a-zA-Z0-9_]*" as id => Some(Token::{ body: TypeId(id), pos, })
    re"^[A-Z][a-zA-Z0-9_]*" as id =>
      Some(Token::{ body: ConstructorId(id), pos, })
    re"^[[:space:]]+" => next_token(scanner)
    re"^--[^\n]*\n?" => next_token(scanner)
    re"^." as symbol =>
      match operator_table.get(symbol) {
        Some(body) => Some(Token::{ body, pos, })
        None => raise TokenizeError::UnknownSymbol(symbol)
      }
    re"^$" => None
  }
}

///|
pub fn tokenize(code : StringView) -> Array[Token] raise TokenizeError {
  let scanner = @lexbuf.StringScanner::{ data: code, cursor: 0, }
  let tokens : Array[Token] = []
  for ;; {
    match next_token(scanner) {
      Some(token) => tokens.push(token)
      None => return tokens
    }
  }
}
