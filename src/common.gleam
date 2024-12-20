import gleam/list
import gleam/result.{try}
import gleam/string
import simplifile

pub fn enumerate(list) {
  let #(_, l) = list.map_fold(list, 0, fn(i, x) { #(i + 1, #(i, x)) })
  l
}

pub fn loadlines(fname) {
  use text <- try(simplifile.read(fname) |> result.replace_error(Nil))
  string.split(text, "\n") |> list.filter(fn(l) { !string.is_empty(l) }) |> Ok
}

pub fn product(a, b) {
  case a {
    [x, ..xs] -> list.map(b, fn(y) { #(x, y) }) |> list.append(product(xs, b))
    [] -> []
  }
}

pub fn neighbors(pos) {
  let #(y, x) = pos
  [#(y + 1, x), #(y - 1, x), #(y, x - 1), #(y, x + 1)]
}
