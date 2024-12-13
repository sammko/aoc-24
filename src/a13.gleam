import common
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/regexp
import gleam/result.{try}

pub fn load() {
  use lines <- try(common.loadlines("inputs/13"))

  let assert Ok(re) = regexp.from_string("X[+=](\\d+), Y[+=](\\d+)")
  let parse_xy = fn(l) {
    case regexp.scan(re, l) {
      [] -> Error(Nil)
      [regexp.Match(_, [Some(xs), Some(ys)])] -> {
        use x <- try(int.parse(xs))
        use y <- try(int.parse(ys))
        Ok(#(x, y))
      }
      _ -> Error(Nil)
    }
  }

  lines
  |> list.sized_chunk(3)
  |> list.try_map(fn(chunk) {
    case chunk {
      [button_a, button_b, prize] -> {
        use button_a <- try(parse_xy(button_a))
        use button_b <- try(parse_xy(button_b))
        use prize <- try(parse_xy(prize))
        #(button_a, button_b, prize) |> Ok
      }
      _ -> Error(Nil)
    }
  })
}

pub fn solve(machine) {
  let #(#(ax, ay), #(bx, by), #(px, py)) = machine
  let range = list.range(0, 100)
  let wins =
    common.product(range, range)
    |> list.filter_map(fn(ab) {
      let #(a, b) = ab
      let x = ax * a + bx * b
      let y = ay * a + by * b
      case x == px && y == py {
        False -> Error(Nil)
        True -> Ok(3 * a + b)
      }
    })
  case wins {
    [] -> Error(Nil)
    [x, ..xs] -> list.fold(xs, x, int.min) |> Ok
  }
}

pub fn main() {
  use machines <- try(load())
  machines
  |> list.filter_map(solve)
  |> int.sum
  |> io.debug
  Ok(Nil)
}
