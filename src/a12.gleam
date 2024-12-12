import common
import gleam/dict
import gleam/function
import gleam/int
import gleam/io
import gleam/list
import gleam/result.{try}
import gleam/set
import gleam/string
import gleam/yielder

pub fn load() {
  use lines <- result.try(common.loadlines("inputs/12"))
  use g <- try(
    lines
    |> yielder.from_list
    |> yielder.index
    |> yielder.flat_map(fn(a) {
      let #(line, y) = a
      line
      |> string.to_graphemes
      |> yielder.from_list
      |> yielder.index
      |> yielder.map(fn(a) {
        let #(c, x) = a
        Ok(#(#(y, x), c))
      })
    })
    |> yielder.to_list
    |> list.try_map(function.identity),
  )
  dict.from_list(g) |> Ok
}

pub fn dfs(nfunc, unvisited, starting_plot) {
  {
    use t <- try(dict.get(unvisited, starting_plot))
    let unvisited = dict.delete(unvisited, starting_plot)
    use #(unvisited, reg) <- try(
      starting_plot
      |> nfunc
      |> list.filter_map(fn(pos) {
        unvisited |> dict.get(pos) |> result.map(fn(t) { #(pos, t) })
      })
      |> list.filter(fn(n) {
        let #(_, nt) = n
        nt == t
      })
      |> list.try_fold(#(unvisited, set.new()), fn(state, n) {
        let #(npos, _) = n
        let #(unv, reg) = state
        let #(unv, reg2) = dfs(nfunc, unv, npos)
        #(unv, set.union(reg, reg2)) |> Ok
      }),
    )
    #(unvisited, reg |> set.insert(starting_plot)) |> Ok
  }
  |> result.unwrap(#(unvisited, set.new()))
}

pub fn perimeter(region) {
  region
  |> set.to_list
  |> list.map(fn(p) {
    common.neighbors(p)
    |> list.count(fn(n) { !set.contains(region, n) })
  })
  |> int.sum
}

pub fn compute(map, cost) {
  let #(_, regions) =
    map
    |> dict.keys()
    |> list.fold(#(map, []), fn(state, starting_plot) {
      let #(unvisited, regions) = state
      let #(unvisited, region) = dfs(common.neighbors, unvisited, starting_plot)
      case set.is_empty(region) {
        False -> #(unvisited, [region, ..regions])
        True -> #(unvisited, regions)
      }
    })

  regions
  |> list.map(cost)
  |> int.sum
}

pub fn main() {
  use map <- try(load())
  compute(map, fn(r) { set.size(r) * perimeter(r) })
  |> io.debug
  Ok(Nil)
}
