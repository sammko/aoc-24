import common
import gleam/dict
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result.{try}
import gleam/set
import gleam/string

pub fn load() {
  use lines <- try(common.loadlines("inputs/08"))
  let height = list.length(lines)
  use width <- try({
    use firstline <- try(list.first(lines) |> result.replace_error(Nil))
    Ok(string.length(firstline))
  })
  let anteny =
    lines
    |> common.enumerate
    |> list.flat_map(fn(yl) {
      let #(y, l) = yl
      l
      |> string.to_graphemes
      |> common.enumerate
      |> list.filter_map(fn(xl) {
        let #(x, l) = xl
        case l {
          "." -> Error(Nil)
          _ -> Ok(#(#(y, x), l))
        }
      })
    })
  let g =
    anteny
    |> list.fold(dict.new(), fn(d, n) {
      let #(pos, freq) = n
      dict.upsert(d, freq, fn(l) {
        case l {
          None -> [pos]
          Some(xs) -> [pos, ..xs]
        }
      })
    })

  Ok(#(g, #(height, width)))
}

pub fn solve(gen) {
  use #(g, #(height, width)) <- try(load())
  dict.values(g)
  |> list.flat_map(fn(towers) {
    common.product(towers, towers)
    |> list.filter(fn(c) {
      let #(a, b) = c
      a != b
    })
    |> list.flat_map(fn(c) {
      let #(#(y1, x1), #(y2, x2)) = c
      let dx = x2 - x1
      let dy = y2 - y1
      gen
      |> list.map(fn(o) { #(y1 + o * dy, x1 + o * dx) })
    })
  })
  |> list.filter(fn(p) {
    let #(y, x) = p
    y >= 0 && y < height && x >= 0 && x < width
  })
  |> set.from_list
  |> set.size
  |> io.debug
  Ok(Nil)
}

pub fn main() {
  solve([-1, 2])
}
