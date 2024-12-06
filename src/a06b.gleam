import a06.{type Map, Map, load, walk}
import gleam/int
import gleam/io
import gleam/list
import gleam/result.{try}
import gleam/set

pub fn each_pos(map: Map) {
  let #(h, w) = map.size
  list.range(0, h - 1)
  |> list.flat_map(fn(x) { list.range(0, w - 1) |> list.map(fn(y) { #(y, x) }) })
}

pub fn main() {
  use #(map, guard) <- try(load())
  let x =
    each_pos(map)
    |> list.map(fn(x) {
      let map = Map(set.insert(map.obstacles, x), map.size)
      case set.new() |> walk(map, guard) {
        a06.Cycle(_) -> 1
        a06.Out(_) -> 0
      }
    })
    |> int.sum
  x |> int.to_string |> io.println
  Ok(Nil)
}
