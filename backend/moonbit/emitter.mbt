///|
pub fn emit_moonbit(module_ : @asdl.Module) -> String {
  let ast = transform_module(module_)
  let builder = StringBuilder()
  ast.write(builder)
  @fmt.format(builder.to_string())
}

///|
fn AST::write(self : Self, builder : StringBuilder) -> Unit {
  for definition in self.definitions {
    definition.write(builder)
  }
}

///|
fn Definition::write(self : Self, builder : StringBuilder) -> Unit {
  match self {
    Struct(name~, fields~) => {
      builder.write_string("pub(all) struct \{name} {\n")
      for field in fields {
        field.write(builder)
      }
      builder.write_string("} derive(Debug)\n")
    }
    Enum(name~, cases~) => {
      builder.write_string("pub(all) enum \{name} {\n")
      for case in cases {
        case.write(builder)
      }
      builder.write_string("} derive(Debug)\n")
    }
    TupleStruct(name~, fields~) => {
      builder.write_string("pub(all) struct \{name} (")
      for field in fields {
        builder.write_string("\{field},")
      }
      builder.write_string(") derive(Debug)\n")
    }
    TypeAlias(alias_~, type_~) =>
      builder.write_string("pub type \{alias_} = \{type_}\n")
  }
}

///|
fn StructField::write(self : Self, builder : StringBuilder) -> Unit {
  builder.write_string("\{self.name} : \{self.type_}\n")
}

///|
fn EnumCase::write(self : Self, builder : StringBuilder) -> Unit {
  builder.write_string("\{self.name}")
  if self.payload.length() > 0 {
    builder.write_char('(')
    for field in self.payload {
      field.write(builder)
    }
    builder.write_char(')')
  }
  builder.write_char('\n')
}

///|
fn EnumCaseField::write(self : Self, builder : StringBuilder) -> Unit {
  if self.name is Some(name) {
    builder.write_string("\{name}~ : ")
  }
  builder.write_string("\{self.type_},")
}
