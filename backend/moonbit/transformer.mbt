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
  name : @asdl.Typeid,
  constructors : Array[@asdl.Constructor],
  attributes : Array[@asdl.Field],
) -> Array[Definition] {
  let name = transform_type_name(name, None)
  let cases = constructors.map(transform_constructor)
  if attributes.is_empty() {
    [Enum(name~, cases~)]
  } else {
    let enum_name = "_\{name}"
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
  name : @asdl.Typeid,
  quant : @asdl.Quantifier?,
) -> StringView {
  let name = name[0:1].to_upper() + name[1:]
  match quant {
    None => name
    Some(Optional) => "\{name}?"
    Some(Sequence) => "Array[\{name}]"
  }
}

///|
fn transform_field_name(name : StringView) -> StringView {
  match name {
    "type" => "type_"
    _ => name
  }
}
