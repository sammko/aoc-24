import common
import gleam/bool
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
  use lines <- result.try(common.loadlines("inputs/10"))
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
        use i <- try(int.parse(c))
        Ok(#(#(y, x), i))
      })
    })
    |> yielder.to_list
    |> list.try_map(function.identity),
  )
  dict.from_list(g) |> Ok
}

pub fn neighbors(pos) {
  let #(y, x) = pos
  [#(y + 1, x), #(y - 1, x), #(y, x - 1), #(y, x + 1)]
}

pub fn traverse(g, from start) {
  use i <- try(dict.get(g, start))
  neighbors(start)
  |> list.map(fn(n) {
    use j <- try(dict.get(g, n))
    use <- bool.guard(i + 1 != j, Error(Nil))
    use <- bool.guard(j == 9, Ok(set.new() |> set.insert(n)))
    traverse(g, n)
  })
  |> list.map(fn(r) { result.unwrap(r, set.new()) })
  |> list.fold(set.new(), set.union)
  |> Ok
}

pub fn main() {
  use g <- try(load())
  // g |> io.debug
  g
  |> dict.map_values(fn(pos, i) {
    use <- bool.guard(i != 0, 0)
    traverse(g, pos) |> result.unwrap(set.new()) |> set.size
  })
  |> dict.values
  |> int.sum
  |> io.debug
  Ok(Nil)
}
