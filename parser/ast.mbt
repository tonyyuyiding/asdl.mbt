///|
pub type Identifier = StringView // asdl built-in type

///|
pub struct Module {
  name : Identifier
  definitions : Array[Definition]
} derive(Debug)

///|
pub enum Definition {
  Product(name~ : Typeid, fields~ : Array[Field])
  Sum(
    name~ : Typeid,
    constructors~ : Array[Constructor],
    attributes~ : Array[Field]
  )
} derive(Debug)

///|
pub struct Constructor {
  name : Constructorid
  fields : Array[Field]
} derive(Debug)

///|
pub struct Field {
  type_ : Typeid
  quant : Quantifier?
  name : Identifier?
} derive(Debug)

///|
pub enum Quantifier {
  Optional
  Sequence
} derive(Debug)

///|
pub type Typeid = Identifier

///|
pub type Constructorid = Identifier
