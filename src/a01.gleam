import gleam/int
import gleam/io
import gleam/list
import gleam/result.{try}
import gleam/string
import simplifile

pub fn load() {
  use text <- try(
    simplifile.read(from: "inputs/01") |> result.map_error(string.inspect),
  )
  let lines =
    string.split(text, on: "\n") |> list.filter(fn(s) { !string.is_empty(s) })
  use pairs <- try({
    use line <- list.try_map(lines)
    let vs = string.split(line, "   ")
    use lr <- try({
      use v <- list.try_map(vs)
      string.trim(v)
      |> int.parse
      |> result.replace_error("Cannot parse")
    })
    case lr {
      [l, r] -> Ok(#(l, r))
      _ -> Error("Each line must contain 2 numbers")
    }
  })
  Ok(list.unzip(pairs))
}

pub fn main() {
  use #(ls, rs) <- try(load())
  let ls = list.sort(ls, by: int.compare)
  let rs = list.sort(rs, by: int.compare)
  list.map2(ls, rs, int.subtract)
  |> list.map(int.absolute_value)
  |> int.sum
  |> io.debug
  |> Ok
}
