///|
pub type Identifier = StringView

///|
pub(all) enum Mod {
  Module(body~ : Array[Stmt], type_ignores~ : Array[TypeIgnore])
  Interactive(body~ : Array[Stmt])
  Expression(body~ : Expr)
  FunctionType(argtypes~ : Array[Expr], returns~ : Expr)
} derive(Debug)

///|
pub extend Mod with Debug::{ to_repr }

///|
pub(all) enum StmtKind {
  FunctionDef(
    name~ : Identifier,
    args~ : Arguments,
    body~ : Array[Stmt],
    decorator_list~ : Array[Expr],
    returns~ : Expr?,
    type_comment~ : String?,
    type_params~ : Array[TypeParam],
  )
  AsyncFunctionDef(
    name~ : Identifier,
    args~ : Arguments,
    body~ : Array[Stmt],
    decorator_list~ : Array[Expr],
    returns~ : Expr?,
    type_comment~ : String?,
    type_params~ : Array[TypeParam],
  )
  ClassDef(
    name~ : Identifier,
    bases~ : Array[Expr],
    keywords~ : Array[Keyword],
    body~ : Array[Stmt],
    decorator_list~ : Array[Expr],
    type_params~ : Array[TypeParam],
  )
  Return(value~ : Expr?)
  Delete(targets~ : Array[Expr])
  Assign(targets~ : Array[Expr], value~ : Expr, type_comment~ : String?)
  TypeAlias(name~ : Expr, type_params~ : Array[TypeParam], value~ : Expr)
  AugAssign(target~ : Expr, op~ : Operator, value~ : Expr)
  AnnAssign(target~ : Expr, annotation~ : Expr, value~ : Expr?, simple~ : Int)
  For(
    target~ : Expr,
    iter~ : Expr,
    body~ : Array[Stmt],
    orelse_~ : Array[Stmt],
    type_comment~ : String?,
  )
  AsyncFor(
    target~ : Expr,
    iter~ : Expr,
    body~ : Array[Stmt],
    orelse_~ : Array[Stmt],
    type_comment~ : String?,
  )
  While(test_~ : Expr, body~ : Array[Stmt], orelse_~ : Array[Stmt])
  If(test_~ : Expr, body~ : Array[Stmt], orelse_~ : Array[Stmt])
  With(items~ : Array[Withitem], body~ : Array[Stmt], type_comment~ : String?)
  AsyncWith(
    items~ : Array[Withitem],
    body~ : Array[Stmt],
    type_comment~ : String?,
  )
  Match(subject~ : Expr, cases~ : Array[MatchCase])
  Raise(exc~ : Expr?, cause~ : Expr?)
  Try(
    body~ : Array[Stmt],
    handlers~ : Array[Excepthandler],
    orelse_~ : Array[Stmt],
    finalbody~ : Array[Stmt],
  )
  TryStar(
    body~ : Array[Stmt],
    handlers~ : Array[Excepthandler],
    orelse_~ : Array[Stmt],
    finalbody~ : Array[Stmt],
  )
  Assert(test_~ : Expr, msg~ : Expr?)
  Import(names~ : Array[Alias], is_lazy~ : Int?)
  ImportFrom(
    module_~ : Identifier?,
    names~ : Array[Alias],
    level~ : Int?,
    is_lazy~ : Int?,
  )
  Global(names~ : Array[Identifier])
  Nonlocal(names~ : Array[Identifier])
  Expr(value~ : Expr)
  Pass
  Break
  Continue
} derive(Debug)

///|
pub extend StmtKind with Debug::{ to_repr }

///|
pub(all) struct Stmt {
  kind : StmtKind
  lineno : Int
  col_offset : Int
  end_lineno : Int?
  end_col_offset : Int?
} derive(Debug)

///|
pub extend Stmt with Debug::{ to_repr }

///|
pub(all) enum ExprKind {
  BoolOp(op~ : Boolop, values~ : Array[Expr])
  NamedExpr(target~ : Expr, value~ : Expr)
  BinOp(left~ : Expr, op~ : Operator, right~ : Expr)
  UnaryOp(op~ : Unaryop, operand~ : Expr)
  Lambda(args~ : Arguments, body~ : Expr)
  IfExp(test_~ : Expr, body~ : Expr, orelse_~ : Expr)
  Dict(keys~ : Array[Expr], values~ : Array[Expr])
  Set(elts~ : Array[Expr])
  ListComp(elt~ : Expr, generators~ : Array[Comprehension])
  SetComp(elt~ : Expr, generators~ : Array[Comprehension])
  DictComp(key~ : Expr, value~ : Expr?, generators~ : Array[Comprehension])
  GeneratorExp(elt~ : Expr, generators~ : Array[Comprehension])
  Await(value~ : Expr)
  Yield(value~ : Expr?)
  YieldFrom(value~ : Expr)
  Compare(left~ : Expr, ops~ : Array[Cmpop], comparators~ : Array[Expr])
  Call(func~ : Expr, args~ : Array[Expr], keywords~ : Array[Keyword])
  FormattedValue(value~ : Expr, conversion~ : Int, format_spec~ : Expr?)
  Interpolation(
    value~ : Expr,
    str~ : String,
    conversion~ : Int,
    format_spec~ : Expr?,
  )
  JoinedStr(values~ : Array[Expr])
  TemplateStr(values~ : Array[Expr])
  Constant(value~ : String, kind~ : String?)
  Attribute(value~ : Expr, attr~ : Identifier, ctx~ : ExprContext)
  Subscript(value~ : Expr, slice~ : Expr, ctx~ : ExprContext)
  Starred(value~ : Expr, ctx~ : ExprContext)
  Name(id~ : Identifier, ctx~ : ExprContext)
  List(elts~ : Array[Expr], ctx~ : ExprContext)
  Tuple(elts~ : Array[Expr], ctx~ : ExprContext)
  Slice(lower~ : Expr?, upper~ : Expr?, step~ : Expr?)
} derive(Debug)

///|
pub extend ExprKind with Debug::{ to_repr }

///|
pub(all) struct Expr {
  kind : ExprKind
  lineno : Int
  col_offset : Int
  end_lineno : Int?
  end_col_offset : Int?
} derive(Debug)

///|
pub extend Expr with Debug::{ to_repr }

///|
pub(all) enum ExprContext {
  Load
  Store
  Del
} derive(Debug)

///|
pub extend ExprContext with Debug::{ to_repr }

///|
pub(all) enum Boolop {
  And
  Or
} derive(Debug)

///|
pub extend Boolop with Debug::{ to_repr }

///|
pub(all) enum Operator {
  Add
  Sub
  Mult
  MatMult
  Div
  Mod
  Pow
  LShift
  RShift
  BitOr
  BitXor
  BitAnd
  FloorDiv
} derive(Debug)

///|
pub extend Operator with Debug::{ to_repr }

///|
pub(all) enum Unaryop {
  Invert
  Not
  UAdd
  USub
} derive(Debug)

///|
pub extend Unaryop with Debug::{ to_repr }

///|
pub(all) enum Cmpop {
  Eq
  NotEq
  Lt
  LtE
  Gt
  GtE
  Is
  IsNot
  In
  NotIn
} derive(Debug)

///|
pub extend Cmpop with Debug::{ to_repr }

///|
pub(all) struct Comprehension {
  target : Expr
  iter : Expr
  ifs : Array[Expr]
  is_async : Int
} derive(Debug)

///|
pub extend Comprehension with Debug::{ to_repr }

///|
pub(all) enum ExcepthandlerKind {
  ExceptHandler(type_~ : Expr?, name~ : Identifier?, body~ : Array[Stmt])
} derive(Debug)

///|
pub extend ExcepthandlerKind with Debug::{ to_repr }

///|
pub(all) struct Excepthandler {
  kind : ExcepthandlerKind
  lineno : Int
  col_offset : Int
  end_lineno : Int?
  end_col_offset : Int?
} derive(Debug)

///|
pub extend Excepthandler with Debug::{ to_repr }

///|
pub(all) struct Arguments {
  posonlyargs : Array[Arg]
  args : Array[Arg]
  vararg : Arg?
  kwonlyargs : Array[Arg]
  kw_defaults : Array[Expr]
  kwarg : Arg?
  defaults : Array[Expr]
} derive(Debug)

///|
pub extend Arguments with Debug::{ to_repr }

///|
pub(all) struct Arg {
  arg : Identifier
  annotation : Expr?
  type_comment : String?
} derive(Debug)

///|
pub extend Arg with Debug::{ to_repr }

///|
pub(all) struct Keyword {
  arg : Identifier?
  value : Expr
} derive(Debug)

///|
pub extend Keyword with Debug::{ to_repr }

///|
pub(all) struct Alias {
  name : Identifier
  asname : Identifier?
} derive(Debug)

///|
pub extend Alias with Debug::{ to_repr }

///|
pub(all) struct Withitem {
  context_expr : Expr
  optional_vars : Expr?
} derive(Debug)

///|
pub extend Withitem with Debug::{ to_repr }

///|
pub(all) struct MatchCase {
  pattern : Pattern
  guard_ : Expr?
  body : Array[Stmt]
} derive(Debug)

///|
pub extend MatchCase with Debug::{ to_repr }

///|
pub(all) enum PatternKind {
  MatchValue(value~ : Expr)
  MatchSingleton(value~ : Expr)
  MatchSequence(patterns~ : Array[Pattern])
  MatchMapping(
    keys~ : Array[Expr],
    patterns~ : Array[Pattern],
    rest~ : Identifier?,
  )
  MatchClass(
    cls~ : Expr,
    patterns~ : Array[Pattern],
    kwd_attrs~ : Array[Identifier],
    kwd_patterns~ : Array[Pattern],
  )
  MatchStar(name~ : Identifier?)
  MatchAs(pattern~ : Pattern?, name~ : Identifier?)
  MatchOr(patterns~ : Array[Pattern])
} derive(Debug)

///|
pub extend PatternKind with Debug::{ to_repr }

///|
pub(all) struct Pattern {
  kind : PatternKind
  lineno : Int
  col_offset : Int
  end_lineno : Int
  end_col_offset : Int
} derive(Debug)

///|
pub extend Pattern with Debug::{ to_repr }

///|
pub(all) enum TypeIgnore {
  TypeIgnore(lineno~ : Int, tag~ : String)
} derive(Debug)

///|
pub extend TypeIgnore with Debug::{ to_repr }

///|
pub(all) enum TypeParamKind {
  TypeVar(name~ : Identifier, bound~ : Expr?, default_value~ : Expr?)
  ParamSpec(name~ : Identifier, default_value~ : Expr?)
  TypeVarTuple(name~ : Identifier, default_value~ : Expr?)
} derive(Debug)

///|
pub extend TypeParamKind with Debug::{ to_repr }

///|
pub(all) struct TypeParam {
  kind : TypeParamKind
  lineno : Int
  col_offset : Int
  end_lineno : Int
  end_col_offset : Int
} derive(Debug)

///|
pub extend TypeParam with Debug::{ to_repr }
