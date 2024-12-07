import a07.{Concat, Plus, Times, load, solve}
import gleam/int
import gleam/io
import gleam/list
import gleam/result.{try}

pub fn main() {
  use cases <- try(load())
  cases
  |> list.map(fn(c) { solve(c, [Plus, Times, Concat]) })
  |> int.sum
  |> int.to_string
  |> io.println
  Ok(Nil)
}
