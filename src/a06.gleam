import common
import gleam/int
import gleam/io
import gleam/list
import gleam/result.{try}
import gleam/set
import gleam/string
import simplifile

pub type Guard {
  Guard(y: Int, x: Int, dy: Int, dx: Int)
}

pub type Map {
  Map(obstacles: set.Set(#(Int, Int)), size: #(Int, Int))
}

pub fn load() {
  use text <- try(
    simplifile.read("inputs/06") |> result.map_error(string.inspect),
  )
  let lines =
    string.split(text, "\n") |> list.filter(fn(l) { !string.is_empty(l) })
  let height = list.length(lines)
  use width <- try({
    use firstline <- try(
      list.first(lines) |> result.replace_error("no first line"),
    )
    Ok(string.length(firstline))
  })
  let cgrid =
    common.enumerate(lines)
    |> list.flat_map(fn(in) {
      let #(y, line) = in
      line
      |> string.to_graphemes
      |> common.enumerate
      |> list.map(fn(in) {
        let #(x, c) = in
        #(y, x, c)
      })
    })
  let obstacles =
    cgrid
    |> list.fold(set.new(), fn(grid, yxc) {
      let #(y, x, c) = yxc
      case c {
        "#" -> grid |> set.insert(#(y, x))
        _ -> grid
      }
    })
  use guard <- try(
    list.find_map(cgrid, fn(yxc) {
      case yxc {
        #(y, x, "^") -> Ok(Guard(y, x, -1, 0))
        #(y, x, "v") -> Ok(Guard(y, x, 1, 0))
        #(y, x, "<") -> Ok(Guard(y, x, 0, -1))
        #(y, x, ">") -> Ok(Guard(y, x, 0, 1))
        #(_, _, _) -> Error(Nil)
      }
    })
    |> result.replace_error("can't find guard"),
  )

  Ok(#(Map(obstacles, #(height, width)), guard))
}

pub fn is_outside(guard, map) {
  let Guard(x, y, _, _) = guard
  let Map(_, size) = map
  let #(height, width) = size
  x < 0 || y < 0 || x >= width || y >= height
}

pub fn move(guard: Guard, map: Map) {
  let Guard(y, x, dy, dx) = guard
  let new = Guard(y + dy, x + dx, dy, dx)
  case set.contains(map.obstacles, #(new.y, new.x)) {
    False -> new
    True -> Guard(y, x, dx, -dy)
  }
}

pub type Walk {
  Out(set.Set(Guard))
  Cycle(set.Set(Guard))
}

pub fn anywalk(w: Walk) {
  case w {
    Cycle(v) -> v
    Out(v) -> v
  }
}

pub fn walk(visited, map: Map, guard: Guard) {
  case is_outside(guard, map) {
    False ->
      case set.contains(visited, guard) {
        False -> {
          let visited = set.insert(visited, guard)
          walk(visited, map, move(guard, map))
        }
        True -> Cycle(visited)
      }
    True -> Out(visited)
  }
}

pub fn main() {
  use #(map, guard) <- try(load())
  let visited =
    set.new() |> walk(map, guard) |> anywalk |> set.map(fn(g) { #(g.x, g.y) })
  set.size(visited) |> int.to_string |> io.println
  Ok(Nil)
}
