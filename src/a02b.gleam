import a02.{is_report_safe, load}
import gleam/function
import gleam/int
import gleam/io
import gleam/list
import gleam/result.{try}

pub fn dampened(report) {
  case report {
    [] -> []
    [_] -> [[]]
    [x, ..xs] -> list.map(dampened(xs), fn(l) { [x, ..l] }) |> list.prepend(xs)
  }
}

fn safe_with_dampener(report) {
  list.any(dampened(report), is_report_safe) || is_report_safe(report)
}

pub fn main() {
  use reports <- try(load())
  list.map(reports, safe_with_dampener)
  |> list.count(function.identity)
  |> int.to_string
  |> io.println
  Ok(Nil)
}
