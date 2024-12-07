import common
import gleam/int
import gleam/io
import gleam/list
import gleam/result.{try}
import gleam/string

pub fn load() {
  use lines <- try(common.loadlines("inputs/07"))
  lines
  |> list.try_map(fn(line) {
    use #(left, right) <- try(string.split_once(line, ": "))
    use sum <- try(int.parse(left))
    use xs <- try(right |> string.split(" ") |> list.try_map(int.parse))
    #(sum, xs) |> Ok
  })
}

pub type Op {
  Plus
  Times
  Concat
}

fn ops(n, opts) {
  case n {
    0 -> [[]]
    n -> {
      let next = ops(n - 1, opts)
      list.flatten(
        opts
        |> list.map(fn(o) {
          [list.map(next, fn(next) { list.prepend(next, o) })]
        })
        |> list.flatten,
      )
    }
  }
}

fn eval(xs, ops) {
  case xs, ops {
    [a, b, ..xs], [op, ..ops] -> {
      case op {
        Plus -> eval([a + b, ..xs], ops)
        Times -> eval([a * b, ..xs], ops)
        Concat ->
          eval(
            [
              int.parse(int.to_string(a) <> int.to_string(b))
                |> result.lazy_unwrap(fn() { panic }),
              ..xs
            ],
            ops,
          )
      }
    }
    [x], [] -> x
    _, _ -> panic
  }
}

pub fn solve(cas, opts) {
  let #(sum, xs) = cas
  let ok =
    ops(list.length(xs) - 1, opts)
    |> list.map(fn(ops) { eval(xs, ops) })
    |> list.any(fn(s) { s == sum })
  case ok {
    True -> sum
    False -> 0
  }
}

pub fn main() {
  use cases <- try(load())
  cases
  |> list.map(fn(c) { solve(c, [Plus, Times]) })
  |> int.sum
  |> int.to_string
  |> io.println
  Ok(Nil)
}
