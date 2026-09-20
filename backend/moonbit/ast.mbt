///|
priv struct AST {
  definitions : Array[Definition]
}

///|
priv enum Definition {
  Struct(name~ : StringView, fields~ : Array[StructField])
  Enum(name~ : StringView, cases~ : Array[EnumCase])
  TupleStruct(name~ : StringView, fields~ : Array[TupleStructField])
  TypeAlias(alias_~ : StringView, type_~ : StringView)
}

///|
priv struct StructField {
  name : StringView
  type_ : StringView
}

///|
priv struct EnumCase {
  name : StringView
  payload : Array[EnumCaseField]
}

///|
priv struct EnumCaseField {
  name : StringView?
  type_ : StringView
}

///|
type TupleStructField = StringView
