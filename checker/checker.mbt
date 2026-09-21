///|
pub suberror CheckError {
  TypeRedefinition(StringView)
  TypeNotFound(StringView)
}

///|
pub fn check_types(module_ : @asdl.Module) -> Unit raise CheckError {
  let known_types : @hashset.HashSet[StringView] = HashSet([
    "identifier", "int", "string",
  ])
  for definition in module_.definitions {
    let type_name = match definition {
      Product(name~, ..) | Sum(name~, ..) => name
    }
    if known_types.contains(type_name) {
      raise CheckError::TypeRedefinition(type_name)
    }
    known_types.add(type_name)
  }
  let check_fields = (fields : Array[@asdl.Field]) => {
    for field in fields {
      if !known_types.contains(field.type_) {
        raise CheckError::TypeNotFound(field.type_)
      }
    }
  }
  for definition in module_.definitions {
    match definition {
      Product(fields~, ..) => check_fields(fields)
      Sum(constructors~, attributes~, ..) => {
        for constructor_ in constructors {
          check_fields(constructor_.fields)
        }
        check_fields(attributes)
      }
    }
  }
}
