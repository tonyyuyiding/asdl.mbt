///|
fn get_lines(code : StringView) -> Array[StringView] {
  code.split("\n").collect()
}

///|
struct CodePos {
  line_no : Int
  col_offset : Int
}

///|
fn get_code_pos(lines : Array[StringView], offset : @lib.Offset) -> CodePos {
  let mut line_no = 0
  let mut col_offset = offset
  for line in lines {
    line_no += 1
    if col_offset < line.length() + 1 {
      break CodePos::{ line_no, col_offset, }
    }
    col_offset -= line.length() + 1
  } nobreak {
    CodePos::{ line_no, col_offset: lines[line_no - 1].length(), }
  }
}

///|
fn main raise {
  let cmd = @argparse.Command(
    "asdl-gen",
    positionals=[
      @argparse.PositionArg("filename", num_args=@argparse.ValueRange::single()),
    ],
    options=[
      @argparse.OptionArg("output", short='o', long="output"),
      @argparse.OptionArg("target", long="target", default_values=["moonbit"]),
    ],
  )
  let args = cmd.parse().values
  let filename = args["filename"][0]
  let target = args["target"][0]
  let source = @fs.read_file_to_string(filename) catch {
    IOError(message) => abort("Failed to read \{filename}: \{message}")
  }
  let result = try {
    match target {
      "moonbit" => @lib.asdl_to_moonbit(source)
      _ => abort("Unsupported target: \{target}")
    }
  } catch {
    @lib.TokenizeError::UnknownSymbol(symbol) =>
      abort("Unknown symbol '\{symbol}'")
    @lib.ParseError::UnexpectedToken(token) => {
      let lines = get_lines(source)
      let { line_no, col_offset, } = get_code_pos(lines, token.pos)
      let line = lines[line_no - 1]
      println(
        "\{filename}:\{line_no}:\{col_offset}: Unexpected token '\{Repr(token.body)}'",
      )
      println(line)
      let token_length = match token.body {
        @lib.TokenBody::TypeId(id) => id.length()
        @lib.TokenBody::ConstructorId(id) => id.length()
        _ => 1
      }
      let pointer_line = " ".repeat(col_offset) + "^".repeat(token_length)
      println(pointer_line)
      abort("Parse error at \{filename}:\{line_no}:\{col_offset}")
    }
    @lib.ParseError::UnexpectedEof =>
      abort("Unexpected end of file while parsing \{filename}")
    @lib.CheckError::TypeNotFound(type_id) =>
      abort("Type '\{type_id}' not found in \{filename}")
    @lib.CheckError::TypeRedefinition(type_id) =>
      abort("Type '\{type_id}' redefined in \{filename}")
    _ => abort("An unknown error occurred while processing \{filename}")
  }
  match args.get("output") {
    Some([output]) => @fs.write_string_to_file(output, result)
    _ => println(result)
  }
}
