///|
pub type Identifier = StringView

///|
pub(all) struct Module {
  name : Identifier
  definitions : Array[Definition]
} derive(Debug)

///|
pub extend Module with Debug::{to_repr}

///|
pub(all) enum Definition {
  Product(name~ : Identifier, fields~ : Array[Field])
  Sum(
    name~ : Identifier,
    constructors~ : Array[Constructor],
    attributes~ : Array[Field]
  )
} derive(Debug)

///|
pub extend Definition with Debug::{to_repr}

///|
pub(all) struct Constructor {
  name : Identifier
  fields : Array[Field]
} derive(Debug)

///|
pub extend Constructor with Debug::{to_repr}

///|
pub(all) struct Field {
  type_ : Identifier
  quant : Quantifier?
  name : Identifier?
} derive(Debug)

///|
pub extend Field with Debug::{to_repr}

///|
pub(all) enum Quantifier {
  Optional
  Sequence
} derive(Debug)

///|
pub extend Quantifier with Debug::{to_repr}
