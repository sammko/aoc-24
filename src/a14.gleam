import common
import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/regexp
import gleam/result.{try}

pub const w = 101

pub const h = 103

pub fn load() {
  use lines <- try(common.loadlines("inputs/14"))
  let assert Ok(re) = regexp.from_string("p=(\\d+),(\\d+) v=(-?\\d+),(-?\\d+)")

  lines
  |> list.try_map(fn(line) {
    case regexp.scan(re, line) {
      [regexp.Match(_, matches)] -> {
        use matches <- try(
          matches |> list.try_map(fn(o) { option.to_result(o, Nil) }),
        )
        use matches <- try(matches |> list.try_map(int.parse))
        case matches {
          [px, py, vx, vy] -> Ok(#(px, py, vx, vy))
          _ -> Error(Nil)
        }
      }
      _ -> Error(Nil)
    }
  })
}

pub fn final_pos(robot, steps) {
  let #(px, py, vx, vy) = robot
  #({ px + { vx * steps } % w + w } % w, { py + { vy * steps } % h + h } % h)
}

pub fn qadd(t1, t2) {
  let #(a1, b1, c1, d1) = t1
  let #(a2, b2, c2, d2) = t2
  #(a1 + a2, b1 + b2, c1 + c2, d1 + d2)
}

pub fn quadrant(pos) {
  let #(x, y) = pos
  use <- bool.guard(x == w / 2 || y == h / 2, #(0, 0, 0, 0))
  case x < w / 2, y < h / 2 {
    True, True -> #(1, 0, 0, 0)
    True, False -> #(0, 1, 0, 0)
    False, True -> #(0, 0, 1, 0)
    False, False -> #(0, 0, 0, 1)
  }
}

pub fn main() {
  use robots <- try(load())
  let #(a, b, c, d) =
    robots
    |> list.map(fn(r) { final_pos(r, 100) })
    |> list.map(quadrant)
    |> list.fold(#(0, 0, 0, 0), qadd)
  io.debug(a * b * c * d)
  Ok(Nil)
}
