///|
fn transform_module(module_ : @asdl.Module) -> AST {
  let definitions = [
    TypeAlias(alias_="Identifier", type_="StringView"),
    ..module_.definitions.map(transform_definition).flatten(),
  ]
  AST::{ definitions, }
}

///|
fn transform_definition(definition : @asdl.Definition) -> Array[Definition] {
  match definition {
    Product(name~, fields~) => transform_product(name, fields)
    Sum(name~, constructors~, attributes~) =>
      transform_sum(name, constructors, attributes)
  }
}

///|
fn transform_product(
  name : @asdl.Identifier,
  fields : Array[@asdl.Field],
) -> Array[Definition] {
  let name = transform_type_name(name, None)
  if fields.all(field => field.name is None) {
    let fields = fields.map(field => {
      transform_type_name(field.type_, field.quant)
    })
    [TupleStruct(name~, fields~)]
  } else {
    let fields = fields.mapi((i, field) => StructField::{
      name: field.name.unwrap_or("_\{i}") |> transform_field_name,
      type_: transform_type_name(field.type_, field.quant),
    })
    [Struct(name~, fields~)]
  }
}

///|
fn transform_sum(
  name : @asdl.Identifier,
  constructors : Array[@asdl.Constructor],
  attributes : Array[@asdl.Field],
) -> Array[Definition] {
  let name = transform_type_name(name, None)
  let cases = constructors.map(transform_constructor)
  if attributes.is_empty() {
    [Enum(name~, cases~)]
  } else {
    let enum_name = "\{name}Kind"
    let fields = [
      StructField::{ name: "kind", type_: enum_name, },
      ..attributes.mapi((i, field) => StructField::{
        name: field.name.unwrap_or("_\{i}") |> transform_field_name,
        type_: transform_type_name(field.type_, field.quant),
      }),
    ]
    [Enum(name=enum_name, cases~), Struct(name~, fields~)]
  }
}

///|
fn transform_constructor(constructor_ : @asdl.Constructor) -> EnumCase {
  let payload = constructor_.fields.map(field => EnumCaseField::{
    name: field.name.map(transform_field_name),
    type_: transform_type_name(field.type_, field.quant),
  })
  EnumCase::{ name: constructor_.name, payload, }
}

///|
fn transform_type_name(
  name : @asdl.Identifier,
  quant : @asdl.Quantifier?,
) -> StringView {
  let name = name
    .split("_")
    .map(part => part[0:1].to_upper() + part[1:])
    .collect()
    .join("")
  match quant {
    None => name
    Some(Optional) => "\{name}?"
    Some(Sequence) => "Array[\{name}]"
  }
}

///|
fn transform_field_name(name : StringView) -> StringView {
  if keywords.contains(name) || reserved_keywords.contains(name) {
    "\{name}_"
  } else {
    name
  }
}

///|
let keywords : ReadOnlyArray[StringView] = [
  "as", "else", "extern", "fn", "if", "let", "const", "match", "using", "mut", "type",
  "struct", "enum", "extenum", "trait", "derive", "while", "break", "continue", "import",
  "return", "throw", "raise", "try", "catch", "pub", "priv", "proof_assert", "proof_let",
  "readonly", "true", "false", "_", "test", "loop", "for", "in", "impl", "with",
  "guard", "async", "is", "suberror", "and", "letrec", "enumview", "noraise", "nocancel",
  "defer", "lexmatch", "lexscan", "where", "declare", "nobreak",
]

///|
let reserved_keywords : ReadOnlyArray[StringView] = [
  "module", "move", "ref", "static", "super", "unsafe", "use", "await", "dyn", "abstract",
  "do", "final", "macro", "override", "typeof", "virtual", "yield", "local", "method",
  "alias", "assert", "package", "recur", "using", "enumview", "isnot", "define",
  "downcast", "inherit", "member", "namespace", "static", "upcast", "use", "void",
  "lazy", "include", "mixin", "protected", "sealed", "constructor", "atomic", "volatile",
  "anyframe", "anytype", "asm", "await", "comptime", "errdefer", "export", "opaque",
  "orelse", "resume", "threadlocal", "unreachable", "dynclass", "dynobj", "dynrec",
  "var", "finally", "noasync", "assume", "extend",
]
