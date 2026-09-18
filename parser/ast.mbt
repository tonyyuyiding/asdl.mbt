///|
/// Built-in types
pub type Identifier = String

///|
pub struct Module {
  name : Identifier
  definitions : Array[Definition]
}

///|
pub enum Definition {
  Product(Product)
  Sum(Sum)
}

///|
pub struct Product {
  name : Typeid
  fields : Array[Field]
}

///|
pub struct Sum {
  name : Typeid
  constructors : Array[Constructor]
  attributes : Array[Field]
}

///|
pub struct Constructor {
  name : Constructorid
  fields : Array[Field]
}

///|
pub struct Field {
  type_ : Typeid
  quant : Quantifier?
  name : Identifier?
}

///|
pub enum Quantifier {
  Optional
  Sequence
}

///|
pub type Typeid = Identifier

///|
pub type Constructorid = Identifier
