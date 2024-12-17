import gleam/int
import gleam/io
import gleam/list
import gleam/result.{try}

fn poww(b) {
  case b {
    0 -> 1
    b -> 2 * poww(b - 1)
  }
}

fn xor(a, b) {
  int.bitwise_exclusive_or(a, b)
}

fn find(have, need) {
  case need {
    [] -> Ok(have)
    [dgt, ..need] ->
      list.range(0, 7)
      |> list.find_map(fn(n3d) {
        let offset = xor(n3d, 1)
        let big = have * 8 + n3d
        let taken = { big / poww(offset) } % 8
        case offset |> xor(taken) |> xor(4) == dgt {
          True -> find(big, need)
          False -> Error(Nil)
        }
      })
  }
}

pub fn main() {
  let r = list.reverse([2, 4, 1, 1, 7, 5, 4, 6, 0, 3, 1, 4, 5, 5, 3, 0])
  use x <- try(find(0, r))
  io.debug(x)
  Ok(Nil)
}
