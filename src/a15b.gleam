import a15.{gps, load, simulate}
import gleam/dict
import gleam/io
import gleam/result.{try}

fn embiggen(map) {
  map
  |> dict.fold(dict.new(), fn(big, pos, t) {
    let #(y, x) = pos
    let pos1 = #(y, x * 2)
    let pos2 = #(y, x * 2 + 1)
    case t {
      a15.Box ->
        big
        |> dict.insert(pos1, a15.BigBox(a15.L))
        |> dict.insert(pos2, a15.BigBox(a15.R))
      a15.Wall ->
        big
        |> dict.insert(pos1, a15.Wall)
        |> dict.insert(pos2, a15.Wall)
      a15.BigBox(_) -> panic
    }
  })
}

pub fn main() {
  use #(map, instructions, #(y, x)) <- try(load())
  let map = embiggen(map)
  let map = simulate(map, instructions, #(y, x * 2))
  gps(map) |> io.debug
  Ok(Nil)
}
