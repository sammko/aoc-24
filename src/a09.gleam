import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result.{try}
import gleam/string
import gleam/yielder
import simplifile

pub fn load() {
  use line <- try(simplifile.read("inputs/09") |> result.replace_error(Nil))
  use digits <- try(
    line
    |> string.to_graphemes
    |> list.try_map(fn(d) { int.parse(d) }),
  )

  digits
  |> yielder.from_list
  |> yielder.zip(
    yielder.iterate(0, fn(x) { x + 1 })
    |> yielder.flat_map(fn(x) { yielder.from_list([x, x]) }),
  )
  |> yielder.map2(
    [False, True] |> yielder.from_list |> yielder.cycle,
    fn(x, is_empty) {
      let #(len, id) = x
      case is_empty {
        False -> yielder.repeat(Some(id))
        True -> yielder.repeat(None)
      }
      |> yielder.take(len)
    },
  )
  |> yielder.flatten
  |> yielder.to_list
  |> Ok
}

pub fn main() {
  use m <- try(load())
  let count = list.count(m, option.is_some)
  let mrev = list.reverse(m)
  let #(_, ok) =
    m
    |> list.map_fold(mrev, fn(mrev, x) {
      case x {
        None -> {
          case mrev |> list.drop_while(option.is_none) {
            [] -> panic
            [None, ..] -> panic
            [Some(fst), ..mrev] -> #(mrev, fst)
          }
        }
        Some(x) -> #(mrev, x)
      }
    })
  ok
  |> yielder.from_list
  |> yielder.take(count)
  |> yielder.map2(yielder.iterate(0, fn(x) { x + 1 }), fn(x, i) { x * i })
  |> yielder.fold(0, int.add)
  |> io.debug
  Ok(Nil)
}
