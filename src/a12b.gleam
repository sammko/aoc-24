import a12.{compute, load}
import common
import gleam/dict
import gleam/io
import gleam/list
import gleam/result.{try}
import gleam/set

fn edge(p, n) {
  let #(yp, xp) = p
  let #(yn, xn) = n
  #(p, #(yp - yn, xp - xn))
}

fn edge_adjacent(e) {
  let #(#(y, x), #(dy, dx) as o) = e
  [#(#(y - dx, x + dy), o), #(#(y + dx, x - dy), o)]
}

pub fn sides(region) {
  let edges =
    set.to_list(region)
    |> list.fold([], fn(edges, pos) {
      common.neighbors(pos)
      |> list.filter(fn(n) { !set.contains(region, n) })
      |> list.map(fn(n) { edge(pos, n) })
      |> list.append(edges)
    })
  let se = edges |> list.fold(dict.new(), fn(d, e) { dict.insert(d, e, 0) })
  let #(_, r) =
    edges
    |> list.fold(#(se, []), fn(state, e) {
      let #(unvisited, regions) = state
      let #(unvisited, region) = a12.dfs(edge_adjacent, unvisited, e)
      case set.is_empty(region) {
        False -> #(unvisited, [region, ..regions])
        True -> #(unvisited, regions)
      }
    })
  r |> list.length
}

pub fn main() {
  use map <- try(load())
  compute(map, fn(r) { set.size(r) * sides(r) })
  |> io.debug
  Ok(Nil)
}
