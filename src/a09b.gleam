import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result.{try}
import gleam/string
import gleam/yielder
import simplifile

pub type Seg {
  Empty(length: Int)
  Data(length: Int, id: Int)
}

pub fn load() {
  use line <- try(simplifile.read("inputs/09s") |> result.replace_error(Nil))
  use digits <- try(
    line
    |> string.to_graphemes
    |> list.try_map(fn(d) { int.parse(d) }),
  )

  digits
  |> yielder.from_list
  |> yielder.zip(
    yielder.iterate(0, fn(x) { x + 1 })
    |> yielder.flat_map(fn(x) { yielder.from_list([x, x]) }),
  )
  |> yielder.map2(
    [False, True] |> yielder.from_list |> yielder.cycle,
    fn(x, is_empty) {
      let #(len, id) = x
      case is_empty {
        False -> Data(len, id)
        True -> Empty(len)
      }
    },
  )
  |> yielder.to_list
  |> Ok
}

fn napchaj(m: List(Seg), f: Seg) {
  let assert Data(len, id) = f
  case m {
    [Empty(n), ..m] if n >= len -> {
      let m =
        m
        |> list.map(fn(v) {
          case v {
            Data(l, id2) if id2 == id -> Empty(l)
            x -> x
          }
        })
      case n - len {
        0 -> [Data(len, id), ..m]
        l -> [Data(len, id), Empty(l), ..m]
      }
    }
    [Data(_, id2), ..] as m if id2 == id -> m
    [v, ..m] -> [v, ..napchaj(m, f)]
    [] -> panic
  }
}

pub fn main() {
  use m <- try(load())
  let files_rev =
    m
    |> list.filter(fn(d) {
      case d {
        Data(_, _) -> True
        Empty(_) -> False
      }
    })
    |> list.reverse

  files_rev
  |> list.fold(m, fn(m, f) { napchaj(m, f) })
  |> yielder.from_list
  |> yielder.flat_map(fn(s) {
    case s {
      Data(l, id) -> list.repeat(Some(id), l)
      Empty(l) -> list.repeat(None, l)
    }
    |> yielder.from_list
  })
  |> fn(p) {
    let l = yielder.to_list(p)

    l
    |> list.drop(32_500)
    |> list.take(1000)
    |> list.map(fn(o) { option.lazy_unwrap(o, fn() { panic }) })
    |> list.map(int.to_string)
    |> string.join(", ")
    |> io.println

    yielder.from_list(l)
  }
  |> yielder.map2(yielder.iterate(0, fn(x) { x + 1 }), fn(x, i) {
    case x {
      None -> 0
      Some(x) -> x * i
    }
  })
  |> yielder.fold(0, int.add)
  |> io.debug
  Ok(Nil)
}
