import a05.{check_swap, get_middle, is_valid, load}
import gleam/int
import gleam/io
import gleam/list
import gleam/result.{try}

fn fixup(update, rules) -> List(Int) {
  case check_swap(rules, update) {
    Ok(Nil) -> update
    Error(#(l, r)) -> {
      list.map(update, fn(x) {
        case x == l, x == r {
          False, False -> x
          True, False -> r
          False, True -> l
          _, _ -> panic
        }
      })
      |> io.debug
      |> fixup(rules)
    }
  }
}

pub fn main() {
  use #(rules, updates) <- try(load())
  use v <- try(
    updates
    |> list.filter(fn(u) { !is_valid(rules, u) })
    |> list.try_map(fn(u) {
      u
      |> io.debug
      |> fixup(rules)
      |> get_middle()
      |> result.replace_error("Can't get middle")
    }),
  )
  int.sum(v)
  |> io.debug
  Ok(Nil)
}
