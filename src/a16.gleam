import common
import gleam/bool
import gleam/dict
import gleam/function
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/result.{try}
import gleam/set
import gleam/string
import gleam/yielder
import gleamy/priority_queue

pub type SE {
  No
  Start
  End
}

pub fn load() {
  use map <- try(common.loadlines("inputs/16"))
  use map <- try(
    map
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
        use tile <- try(case c {
          "." -> Ok(#(No, option.None))
          "#" -> Ok(#(No, option.Some(Nil)))
          "E" -> Ok(#(End, option.None))
          "S" -> Ok(#(Start, option.None))
          _ -> Error(Nil)
        })
        Ok(#(#(y, x), tile))
      })
    })
    |> yielder.to_list
    |> list.try_map(function.identity),
  )
  let map2 =
    list.fold(map, set.new(), fn(d, l) {
      let #(pos, t) = l
      case t {
        #(_, option.None) -> d
        #(_, option.Some(_)) -> d |> set.insert(pos)
      }
    })
  use start <- try(
    list.find_map(map, fn(s) {
      case s {
        #(pos, #(Start, _)) -> Ok(pos)
        _ -> Error(Nil)
      }
    }),
  )
  use end <- try(
    list.find_map(map, fn(s) {
      case s {
        #(pos, #(End, _)) -> Ok(pos)
        _ -> Error(Nil)
      }
    }),
  )
  #(map2, start, end) |> Ok
}

pub type Vertex {
  Vertex(pos: #(Int, Int), ort: #(Int, Int))
}

pub type Edge {
  Edge(to: Vertex, cost: Int)
}

pub fn build_graph(map, visited, v) {
  let edges =
    common.neighbors(#(0, 0))
    |> list.map(fn(ort) {
      let #(dy, dx) = ort
      let n = {
        let #(y, x) = v
        #(y + dy, x + dx)
      }
      #(Vertex(v, ort), [
        Edge(Vertex(v, #(-dx, dy)), 1000),
        Edge(Vertex(v, #(dx, -dy)), 1000),
        ..case set.contains(map, n) {
          False -> [Edge(Vertex(n, ort), 1)]
          True -> []
        }
      ])
    })
    |> dict.from_list
  let #(visited, g) =
    common.neighbors(v)
    |> list.filter(fn(n) { !set.contains(map, n) })
    |> list.map_fold(visited, fn(visited, n) {
      case set.contains(visited, n) {
        True -> #(visited, dict.new())
        False -> {
          let visited = set.insert(visited, n)
          let #(visited, g) = build_graph(map, visited, n)
          #(visited, g)
        }
      }
    })
  #(visited, list.fold(g, edges, dict.merge))
}

pub fn vcomp(v1, v2) {
  let #(_, d1) = v1
  let #(_, d2) = v2
  int.compare(d1, d2)
}

fn dijkstra_inner(g, q, dist, v, pp) {
  let assert Ok(dv) = dict.get(dist, v)
  let #(q, dist, pp) = {
    dict.get(g, v)
    |> result.unwrap([])
    |> list.fold(#(q, dist, pp), fn(qdp, edge) {
      let #(q, dist, pp) = qdp
      let Edge(to, cost) = edge
      let #(leq, newd) = case dict.get(dist, to) {
        Ok(d) ->
          case dv + cost <= d {
            True -> #(True, dv + cost)
            False -> #(False, d)
          }
        Error(_) -> #(True, dv + cost)
      }
      case leq {
        False -> #(q, dist, pp)
        True -> #(
          priority_queue.push(q, #(to, newd)),
          dict.insert(dist, to, newd),
          dict.upsert(pp, to, fn(s) {
            s
            |> option.lazy_unwrap(fn() { set.new() })
            |> set.insert(#(v, newd))
          }),
        )
      }
    })
  }
  case priority_queue.pop(q) {
    Error(Nil) -> #(q, dist, pp)
    Ok(#(#(v2, _), q)) -> dijkstra_inner(g, q, dist, v2, pp)
  }
}

pub fn dfs(pp, vs, v, dst) {
  let vs = vs |> set.insert(v)
  use <- bool.guard(v == dst, vs)
  let vs =
    pp
    |> dict.get(v)
    |> result.unwrap(set.new())
    |> set.to_list
    |> list.fold(vs, fn(vs, nd) {
      let #(n, _) = nd
      case set.contains(vs, n) {
        True -> vs
        False -> dfs(pp, vs, n, dst)
      }
    })
  vs
}

pub fn dijkstra(g, start) {
  let q = priority_queue.new(vcomp)
  let dist = dict.new() |> dict.insert(start, 0)
  let #(_, dist, pp) = dijkstra_inner(g, q, dist, start, dict.new())
  #(dist, pp)
}

pub fn main() {
  use #(map, start, end) <- try(load())
  let #(_, g) = build_graph(map, set.new() |> set.insert(start), start)
  let sv = Vertex(start, #(0, 1))
  let #(dist, pp) = dijkstra(g, sv)
  use d <- try(
    common.neighbors(#(0, 0))
    |> list.map(fn(ort) { Vertex(end, ort) })
    |> list.filter_map(fn(v) { dict.get(dist, v) })
    |> list.reduce(int.min),
  )

  let pvs =
    common.neighbors(#(0, 0))
    |> list.map(fn(ort) { Vertex(end, ort) })
    |> list.map(fn(ev) {
      let pp =
        pp
        |> dict.upsert(ev, fn(s) {
          case s {
            option.None -> set.new()
            option.Some(s) ->
              set.filter(s, fn(vd) {
                let #(_, md) = vd
                d == md
              })
          }
        })
      dfs(pp, set.new(), ev, sv)
    })
    |> list.fold(set.new(), set.union)
    |> set.map(fn(v) {
      let Vertex(pos, _) = v
      pos
    })
  io.debug(d)
  io.debug(set.size(pvs))
  Ok(Nil)
}
