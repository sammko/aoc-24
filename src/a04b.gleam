import a04.{load, product}
import gleam/bool
import gleam/io
import gleam/list
import gleam/result.{try}
import gleam/string
import gleam/yielder
import glearray

pub fn explode(grid) {
  let xs =
    yielder.range(from: 0, to: glearray.length(grid) - 1) |> yielder.to_list
  use row <- try(glearray.get(grid, 0))
  let ys =
    yielder.range(from: 0, to: glearray.length(row) - 1) |> yielder.to_list
  product(xs, ys)
  |> list.map(fn(z) {
    list.flat_map(product([-1, 1], [-1, 1]), fn(d) {
      let #(dx, dy) = d
      let #(x, y) = z
      use <- bool.guard(dx == 0 && dy == 0, [])
      case
        yielder.try_fold(yielder.range(-1, 1), [], fn(a, c) {
          use row <- try(glearray.get(grid, x + dx * c))
          use v <- try(glearray.get(row, y + dy * c))
          Ok(list.prepend(a, v))
        })
      {
        Error(_) -> []
        Ok(x) -> [x]
      }
    })
    |> list.map(string.concat)
    |> list.count(fn(s) { s == "MAS" })
  })
  |> list.count(fn(x) { x == 2 })
  |> Ok
}

pub fn main() {
  use grid <- try(load() |> result.map_error(string.inspect))
  use all <- try(explode(grid) |> result.replace_error("can't explode"))
  io.debug(all)
  Ok(Nil)
}
