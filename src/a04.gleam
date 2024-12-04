import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/result.{try}
import gleam/string
import gleam/yielder
import glearray
import simplifile

pub fn load() {
  use text <- try(simplifile.read("inputs/04"))
  let lines =
    string.split(text, "\n")
    |> list.map(string.to_graphemes)
    |> list.filter(fn(l) { !list.is_empty(l) })
    |> list.map(glearray.from_list)
    |> glearray.from_list
  Ok(lines)
}

pub fn product(a, b) {
  case a {
    [x, ..xs] -> list.map(b, fn(y) { #(x, y) }) |> list.append(product(xs, b))
    [] -> []
  }
}

pub fn explode(grid) {
  let xs =
    yielder.range(from: 0, to: glearray.length(grid) - 1) |> yielder.to_list
  use row <- try(glearray.get(grid, 0))
  let ys =
    yielder.range(from: 0, to: glearray.length(row) - 1) |> yielder.to_list
  product(xs, ys)
  |> list.map(fn(z) {
    list.flat_map(product([-1, 0, 1], [-1, 0, 1]), fn(d) {
      let #(dx, dy) = d
      let #(x, y) = z
      use <- bool.guard(dx == 0 && dy == 0, [])
      case
        yielder.try_fold(yielder.range(0, 3), [], fn(a, c) {
          use row <- try(glearray.get(grid, x + dx * c))
          use v <- try(glearray.get(row, y + dy * c))
          Ok(list.prepend(a, v))
        })
      {
        Error(_) -> []
        Ok(x) -> [x]
      }
    })
  })
  |> list.flatten
  |> list.map(string.concat)
  |> Ok
}

pub fn main() {
  use grid <- try(load() |> result.map_error(string.inspect))
  use all <- try(explode(grid) |> result.replace_error("can't explode"))
  let c = list.count(all, fn(s) { s == "XMAS" })
  io.println(int.to_string(c))
  Ok(Nil)
}
