import a11.{load}
import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/result.{try}
import gleam/string
import rememo/memo

fn c(x, n, memo) {
  use <- memo.memoize(memo, #(x, n))
  let c = fn(x, n) { c(x, n, memo) }
  // io.debug(#(x, n))
  use <- bool.guard(n == 0, 1)
  use <- bool.lazy_guard(x == 0, fn() { c(1, n - 1) })
  let str = x |> int.to_string
  case str |> string.length |> int.is_even {
    True ->
      c(
        str
          |> string.slice(0, string.length(str) / 2)
          |> int.parse
          |> result.lazy_unwrap(fn() { panic }),
        n - 1,
      )
      + c(
        str
          |> string.slice(string.length(str) / 2, string.length(str) / 2)
          |> int.parse
          |> result.lazy_unwrap(fn() { panic }),
        n - 1,
      )
    False -> c(x * 2024, n - 1)
  }
}

pub fn main() {
  use stones <- try(load())
  use memo <- memo.create()
  stones |> list.map(fn(s) { c(s, 75, memo) }) |> int.sum |> io.debug
  Ok(Nil)
}
