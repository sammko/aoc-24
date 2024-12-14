import a14.{final_pos, h, load, w}
import gleam/int
import gleam/io
import gleam/list
import gleam/result.{try}
import gleam/set
import gleam/string

pub fn print(final) {
  list.range(0, h - 1)
  |> list.map(fn(y) {
    list.range(0, w - 1)
    |> list.map(fn(x) {
      case set.contains(final, #(x, y)) {
        False -> " "
        True -> "#"
      }
    })
    |> string.join("")
  })
  |> string.join("\n")
  |> io.println
}

pub fn main() {
  use robots <- try(load())
  list.range(1, 1000)
  |> list.each(fn(i) {
    let final =
      robots
      |> list.map(fn(r) { final_pos(r, 27 + { 4559 - 4456 } * i) })
      |> set.from_list
    io.println(int.to_string(i))
    print(final)
  })

  Ok(Nil)
}
