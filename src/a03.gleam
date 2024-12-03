import gleam/bool
import gleam/int
import gleam/io
import gleam/result.{try}
import gleam/string
import simplifile

pub fn load() {
  use text <- try(simplifile.read("inputs/03"))
  Ok(text)
}

fn parse_str(rest, str) {
  case string.starts_with(rest, str) {
    True -> Ok(string.drop_start(rest, string.length(str)))
    False -> Error(Nil)
  }
}

fn parse_num(rest, max_digits) {
  use <- bool.guard(max_digits == 0, Error(Nil))
  use #(digit, rest) <- try(string.pop_grapheme(rest))
  use digit <- try(int.parse(digit))
  case parse_num(rest, max_digits - 1) {
    Ok(#(n, o, rest)) -> Ok(#(digit * 10 * o + n, o * 10, rest))
    Error(_) -> Ok(#(digit, 1, rest))
  }
}

fn parse_mul(rest) {
  use rest <- try(parse_str(rest, "mul("))
  use #(a, _, rest) <- try(parse_num(rest, 3))
  use rest <- try(parse_str(rest, ","))
  use #(b, _, rest) <- try(parse_num(rest, 3))
  use rest <- try(parse_str(rest, ")"))
  Ok(#(a * b, rest))
}

fn skip_one(rest) {
  use <- bool.guard(string.is_empty(rest), Error(Nil))
  Ok(string.drop_start(rest, 1))
}

fn parse_cond(rest) {
  result.or(
    parse_str(rest, "don't()") |> result.map(fn(rest) { #(False, rest) }),
    parse_str(rest, "do()") |> result.map(fn(rest) { #(True, rest) }),
  )
}

fn alt(parse, if_ok, alt) {
  case parse {
    Ok(ok) -> if_ok(ok)
    Error(_) -> alt()
  }
}

pub fn find_muls(rest, enabled, conds) {
  use <- alt(parse_mul(rest), fn(z) {
    let #(mul, rest) = z
    find_muls(rest, enabled, conds)
    + case enabled || !conds {
      True -> mul
      False -> 0
    }
  })
  use <- alt(parse_cond(rest), fn(z) {
    let #(enabled, rest) = z
    find_muls(rest, enabled, conds)
  })
  use <- alt(skip_one(rest), fn(rest) { find_muls(rest, enabled, conds) })
  0
}

pub fn main() {
  use text <- try(load() |> result.map_error(string.inspect))
  let s = find_muls(text, True, False)
  io.println(int.to_string(s))
  Ok(Nil)
}
