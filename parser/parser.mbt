///|
using @tokenizer {type Token}

///|
pub fn parse_tokens(tokens : Array[Token]) -> Module raise ParseError {
  let scanner = Scanner::new(tokens)
  parse_module(scanner)
}

///|
pub suberror ParseError {
  UnexpectedToken(Token)
  UnexpectedEof
}

///|
priv struct Scanner {
  tokens : Array[Token]
  mut cursor : Int
}

///|
fn Scanner::new(tokens : Array[Token]) -> Scanner {
  Scanner::{ tokens, cursor: 0, }
}

///|
fn Scanner::empty(self : Self) -> Bool {
  self.cursor >= self.tokens.length()
}

///|
fn Scanner::front(self : Self) -> Token raise ParseError {
  guard !self.empty() else { raise ParseError::UnexpectedEof }
  self.tokens[self.cursor]
}

///|
fn Scanner::advance(self : Self) -> Unit raise ParseError {
  guard !self.empty() else { raise ParseError::UnexpectedEof }
  self.cursor += 1
}

///|
fn Scanner::consume(self : Self, expected : Token) -> Unit raise ParseError {
  if self.front() == expected {
    self.advance()
  } else {
    raise ParseError::UnexpectedToken(self.front())
  }
}

///|
fn parse_module(scanner : Scanner) -> Module raise ParseError {
  scanner.consume(TypeId("module"))
  let name = match scanner.front() {
    TypeId(id) | ConstructorId(id) => id
    _ => raise ParseError::UnexpectedToken(scanner.front())
  }
  scanner.advance()
  scanner.consume(LBrace)
  let definitions : Array[Definition] = []
  while scanner.front() != RBrace {
    let definition = parse_definition(scanner)
    definitions.push(definition)
  }
  scanner.consume(RBrace)
  guard scanner.empty() else {
    raise ParseError::UnexpectedToken(scanner.front())
  }
  Module::{ name, definitions, }
}

///|
fn parse_definition(scanner : Scanner) -> Definition raise ParseError {
  guard scanner.front() is TypeId(name) else {
    raise ParseError::UnexpectedToken(scanner.front())
  }
  scanner.advance()
  scanner.consume(Equals)
  match scanner.front() {
    LParen => {
      let fields = parse_fields(scanner)
      Product(name~, fields~)
    }
    ConstructorId(_) => {
      let constructors : Array[Constructor] = []
      while true {
        let constructor_ = parse_constructor(scanner)
        constructors.push(constructor_)
        if scanner.front() == Pipe {
          scanner.consume(Pipe)
        } else {
          break
        }
      }
      let attributes = match scanner.front() {
        TypeId("attributes") => {
          scanner.advance()
          parse_fields(scanner)
        }
        _ => []
      }
      Sum(name~, constructors~, attributes~)
    }
    _ => raise ParseError::UnexpectedToken(scanner.front())
  }
}

///|
fn parse_constructor(scanner : Scanner) -> Constructor raise ParseError {
  guard scanner.front() is ConstructorId(name) else {
    raise ParseError::UnexpectedToken(scanner.front())
  }
  scanner.advance()
  let fields = match scanner.front() {
    LParen => parse_fields(scanner)
    _ => []
  }
  Constructor::{ name, fields, }
}

///|
fn parse_fields(scanner : Scanner) -> Array[Field] raise ParseError {
  scanner.consume(LParen)
  let fields : Array[Field] = []
  while scanner.front() != RParen {
    let field = parse_field(scanner)
    fields.push(field)
    if scanner.front() == Comma {
      scanner.consume(Comma)
    } else {
      break
    }
  }
  scanner.consume(RParen)
  fields
}

///|
fn parse_field(scanner : Scanner) -> Field raise ParseError {
  guard scanner.front() is TypeId(type_) else {
    raise ParseError::UnexpectedToken(scanner.front())
  }
  scanner.advance()
  let quant = match scanner.front() {
    Question => {
      scanner.advance()
      Some(Optional)
    }
    Asterisk => {
      scanner.advance()
      Some(Sequence)
    }
    _ => None
  }
  let name = match scanner.front() {
    TypeId(name) | ConstructorId(name) => {
      scanner.advance()
      Some(name)
    }
    _ => None
  }
  Field::{ type_, quant, name, }
}
