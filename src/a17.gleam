import gleam/bool
import gleam/float
import gleam/int
import gleam/io
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import gleam/yielder.{Done}
import glearray

pub type Reg {
  Reg(a: Int, b: Int, c: Int)
}

fn combo(o, reg: Reg) {
  case o {
    _ if o < 4 -> o
    4 -> reg.a
    5 -> reg.b
    6 -> reg.c
    _ -> panic
  }
}

fn dvpow(r: Reg, o) {
  r.a
  / {
    int.power(2, combo(o, r) |> int.to_float)
    |> result.lazy_unwrap(fn() { panic })
    |> float.truncate
  }
}

pub fn step(state) {
  case state {
    #(r, ip, p) -> {
      use <- bool.guard(ip == glearray.length(p), Done)
      let assert Ok(i) = glearray.get(p, ip)
      let assert Ok(o) = glearray.get(p, ip + 1)
      case i {
        0 -> yielder.Next(None, #(Reg(dvpow(r, o), r.b, r.c), ip + 2, p))
        1 ->
          yielder.Next(None, #(
            Reg(r.a, int.bitwise_exclusive_or(r.b, o), r.c),
            ip + 2,
            p,
          ))
        2 -> yielder.Next(None, #(Reg(r.a, combo(o, r) % 8, r.c), ip + 2, p))
        3 ->
          case r.a {
            0 -> yielder.Next(None, #(r, ip + 2, p))
            _ -> yielder.Next(None, #(r, o, p))
          }
        4 ->
          yielder.Next(None, #(
            Reg(r.a, int.bitwise_exclusive_or(r.b, r.c), r.c),
            ip + 2,
            p,
          ))
        5 -> yielder.Next(Some(combo(o, r) % 8), #(r, ip + 2, p))
        6 -> yielder.Next(None, #(Reg(r.a, dvpow(r, o), r.c), ip + 2, p))
        7 -> yielder.Next(None, #(Reg(r.a, r.b, dvpow(r, o)), ip + 2, p))
        _ -> panic
      }
    }
  }
}

pub fn main() {
  let a = 28_066_687
  let b = 0
  let c = 0
  let program = [2, 4, 1, 1, 7, 5, 4, 6, 0, 3, 1, 4, 5, 5, 3, 0]
  let state = #(Reg(a, b, c), 0, program |> glearray.from_list)
  yielder.unfold(state, step)
  |> yielder.filter_map(fn(o) { option.to_result(o, Nil) })
  |> yielder.map(int.to_string)
  |> yielder.to_list
  |> string.join(",")
  |> io.println
}
