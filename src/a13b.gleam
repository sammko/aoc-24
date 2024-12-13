import a13
import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/result.{try}

pub fn solve(machine) {
  let #(#(ax, ay), #(bx, by), #(px, py)) = machine
  let px = px + 10_000_000_000_000
  let py = py + 10_000_000_000_000
  // ax bx
  // ay by
  let d = ax * by - bx * ay
  use <- bool.guard(d == 0, Error(Nil))
  // 1/d [by -bx] [px]
  //     [-ay ax] [py]
  let a = { px * by - py * bx } / d
  let b = { py * ax - px * ay } / d
  use <- bool.guard(
    !{ a * ax + b * bx == px && b * by + a * ay == py },
    Error(Nil),
  )
  use <- bool.guard(a < 0 || b < 0, Error(Nil))
  Ok(3 * a + b)
}

pub fn main() {
  use machines <- try(a13.load())
  machines
  |> list.filter_map(solve)
  |> int.sum
  |> io.debug
  Ok(Nil)
}
