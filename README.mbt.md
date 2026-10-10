# tonyyuyiding/asdl

Generate AST types from ASDL (Abstract Syntax Description Language) descriptions.

This project is under development. We will try to keep the API stable, but breaking changes might still occur in some cases.

## Usage

### CLI

```bash
moon run cmd/asdl-gen path/to/schema.asdl --target moonbit -o schema.mbt
```

Omit `-o` to print to stdout. Use `--target` to specify target language (default: `moonbit`).

Only the MoonBit backend is available currently. Additional language emitters have been planned.

### Library

```mbt check
///|
test "asdl_to_moonbit" {
  let asdl =
    #|module Expr {
    #|    expr = Num(int n) | Add(expr left, expr right)
    #|}
  let code = @asdl.asdl_to_moonbit(asdl)
  let expected =
    #|///|
    #|pub type Identifier = StringView
    #|
    #|///|
    #|pub(all) enum Expr {
    #|  Num(n~ : Int)
    #|  Add(left~ : Expr, right~ : Expr)
    #|} derive(Debug)
    #|
    #|///|
    #|pub extend Expr with Debug::{ to_repr }
    #|
  assert_eq(code, expected)
}
```

## Pipeline

| Stage | Package | Role |
| --- | --- | --- |
| Lexer | `lexer/` | Tokenize ASDL source |
| Parser | `parser/` | Build an ASDL module AST |
| Checker | `checker/` | Validate type names and definitions |
| Backend | `backend/` | Emit target-language source (MoonBit today) |

The root package re-exports these stages and provides `asdl_to_moonbit` as a single entry point: tokenize → parse → check → emit.

## Bootstrapping

ASDL can describe itself. `parser/asdl.asdl` is a meta-schema for ASDL modules, definitions, constructors, and fields:

```asdl
module ASDL {
    module = (identifier name, definition* definitions)

    definition = Product(identifier name, field* fields)
               | Sum(identifier name, constructor* constructors, field* attributes)

    constructor = (identifier name, field* fields)

    field = (identifier type, quantifier? quant, identifier? name)

    quantifier = Optional | Sequence
}
```

Feeding this file through the generator produces `parser/ast.mbt` — the MoonBit types being used by the parser :D
