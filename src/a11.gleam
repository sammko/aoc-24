import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/result.{try}
import gleam/string
import simplifile

pub fn load() {
  use line <- try(simplifile.read("inputs/11") |> result.replace_error(Nil))
  line
  |> string.trim
  |> string.split(" ")
  |> list.try_map(int.parse)
}

pub fn evolve(state) {
  list.flat_map(state, fn(s) {
    use <- bool.guard(s == 0, [1])
    let ss = s |> int.to_string
    case s |> int.to_string |> string.length |> int.is_even {
      False -> [s * 2024]
      True -> [
        ss
          |> string.slice(0, string.length(ss) / 2)
          |> int.parse
          |> result.lazy_unwrap(fn() { panic }),
        ss
          |> string.slice(string.length(ss) / 2, string.length(ss) / 2)
          |> int.parse
          |> result.lazy_unwrap(fn() { panic }),
      ]
    }
  })
}

pub fn main() {
  use stones <- try(load())
  list.range(1, 25)
  |> list.fold(stones, fn(s, _) { evolve(s) })
  |> list.length
  |> io.debug
  Ok(Nil)
}
