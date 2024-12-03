import a03.{find_muls, load}
import gleam/int
import gleam/io
import gleam/result.{try}
import gleam/string

pub fn main() {
  use text <- try(load() |> result.map_error(string.inspect))
  let s = find_muls(text, True, True)
  io.println(int.to_string(s))
  Ok(Nil)
}
