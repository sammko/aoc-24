import a01.{load}
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result.{try}

pub fn main() {
  use #(ls, rs) <- try(load())
  let counts =
    list.fold(rs, dict.new(), fn(a, x) {
      use c <- dict.upsert(a, x)
      case c {
        None -> 1
        Some(c) -> c + 1
      }
    })
  list.map(ls, fn(x) {
    dict.get(counts, x) |> result.unwrap(0) |> int.multiply(x)
  })
  |> int.sum
  |> io.debug
  |> Ok()
}
