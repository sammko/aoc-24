import gleam/function
import gleam/int
import gleam/io
import gleam/list
import gleam/result.{try}
import gleam/string
import simplifile

pub fn load() {
  use text <- try(
    simplifile.read(from: "inputs/02") |> result.map_error(string.inspect),
  )
  let lines =
    string.split(text, on: "\n") |> list.filter(fn(s) { !string.is_empty(s) })
  use line <- list.try_map(lines)
  string.split(line, on: " ")
  |> list.try_map(fn(x) { int.parse(x) |> result.replace_error("Cannot parse") })
}

fn diff2(l: List(Int)) {
  case l {
    [] -> panic
    [_] -> []
    [_, ..xs] -> list.map2(l, xs, fn(a, b) { a - b })
  }
}

pub fn is_report_safe(report: List(Int)) {
  let diffs = diff2(report)
  let f = fn(x) { x >= 1 && x <= 3 }
  list.all(diffs, f) || { list.map(diffs, int.negate) |> list.all(f) }
}

pub fn main() {
  use reports <- try(load())
  list.map(reports, is_report_safe)
  |> list.count(function.identity)
  |> int.to_string
  |> io.println
  Ok(Nil)
}
