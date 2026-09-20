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
  name : @asdl.Typeid,
  fields : Array[@asdl.Field],
) -> Array[Definition] {
  if fields.all(field => field.name is None) {
    let fields = fields.map(field => field.type_)
    [TupleStruct(name~, fields~)]
  } else {
    let fields = fields.mapi((i, field) => StructField::{
      name: field.name.unwrap_or("_\{i}"),
      type_: field.type_,
    })
    [Struct(name~, fields~)]
  }
}

///|
fn transform_sum(
  name : @asdl.Typeid,
  constructors : Array[@asdl.Constructor],
  attributes : Array[@asdl.Field],
) -> Array[Definition] {
  let cases = constructors.map(transform_constructor)
  if attributes.is_empty() {
    [Enum(name~, cases~)]
  } else {
    let enum_name = "_\{name}"
    let fields = [
      StructField::{ name: "kind", type_: enum_name, },
      ..attributes.mapi((i, field) => StructField::{
        name: field.name.unwrap_or("_\{i}"),
        type_: field.type_,
      }),
    ]
    [Enum(name=enum_name, cases~), Struct(name~, fields~)]
  }
}

///|
fn transform_constructor(constructor_ : @asdl.Constructor) -> EnumCase {
  let payload = constructor_.fields.map(field => EnumCaseField::{
    name: field.name,
    type_: translate_type(field.type_, field.quant),
  })
  EnumCase::{ name: constructor_.name, payload, }
}

///|
fn translate_type(
  type_ : @asdl.Typeid,
  quant : @asdl.Quantifier?,
) -> StringView {
  match quant {
    None => type_
    Some(Optional) => "\{type_}?"
    Some(Sequence) => "Array[\{type_}]"
  }
}
