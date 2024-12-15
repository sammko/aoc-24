import gleam/dict
import gleam/function
import gleam/io
import gleam/list
import gleam/option
import gleam/result.{try}
import gleam/string
import gleam/yielder
import simplifile

pub type LR {
  L
  R
}

pub type Tile {
  Wall
  Box
  BigBox(LR)
}

pub fn load() {
  use text <- try(simplifile.read("inputs/15") |> result.replace_error(Nil))
  let #(map, instructions) =
    string.split(text, "\n") |> list.split_while(fn(l) { !string.is_empty(l) })
  use instructions <- try(case instructions {
    [_, ..instructions] -> string.join(instructions, "") |> Ok
    _ -> Error(Nil)
  })
  use instructions <- try(
    instructions
    |> string.to_graphemes
    |> list.try_map(fn(c) {
      case c {
        "<" -> Ok(#(0, -1))
        ">" -> Ok(#(0, 1))
        "^" -> Ok(#(-1, 0))
        "v" -> Ok(#(1, 0))
        _ -> Error(Nil)
      }
    }),
  )
  use map <- try(
    map
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
        use tile <- try(case c {
          "." -> Ok(#(False, option.None))
          "#" -> Ok(#(False, option.Some(Wall)))
          "O" -> Ok(#(False, option.Some(Box)))
          "@" -> Ok(#(True, option.None))
          _ -> Error(Nil)
        })
        Ok(#(#(y, x), tile))
      })
    })
    |> yielder.to_list
    |> list.try_map(function.identity),
  )
  let map2 =
    list.fold(map, dict.new(), fn(d, l) {
      let #(pos, t) = l
      case t {
        #(_, option.None) -> d
        #(_, option.Some(t)) -> d |> dict.insert(pos, t)
      }
    })
  use pos <- try(
    list.find_map(map, fn(s) {
      case s {
        #(pos, #(True, _)) -> Ok(pos)
        _ -> Error(Nil)
      }
    }),
  )

  #(map2, instructions, pos) |> Ok
}

pub fn step(map, pos, i) {
  let #(y, x) = pos
  let #(dy, dx) = i
  let newpos = #(y + dy, x + dx)
  let move_lr = case i {
    #(0, _) -> True
    _ -> False
  }
  case dict.get(map, newpos) {
    Error(_) -> #(map, newpos)
    Ok(Wall) -> #(map, pos)
    Ok(Box) -> {
      let map = dict.delete(map, newpos)
      let #(map, #(y, x)) = step(map, newpos, i)
      let map = map |> dict.insert(#(y, x), Box)
      #(map, #(y - dy, x - dx))
    }
    Ok(BigBox(_) as bb) if move_lr -> {
      let map = dict.delete(map, newpos)
      let #(map, #(y, x)) = step(map, newpos, i)
      let map = map |> dict.insert(#(y, x), bb)
      #(map, #(y - dy, x - dx))
    }
    // eww
    Ok(BigBox(lr)) -> {
      let #(newy, newx) = newpos
      let newpos2 = #(newy, case lr {
        L -> newx + 1
        R -> newx - 1
      })
      let old1 = dict.get(map, newpos)
      let old2 = dict.get(map, newpos2)
      let map0 = map |> dict.delete(newpos) |> dict.delete(newpos2)
      let #(map1, #(y, x) as moved1) = step(map0, newpos, i)
      let #(map2, moved2) = step(map1, newpos2, i)
      let map3 = case old1 {
        Error(_) -> map2
        Ok(o) -> dict.insert(map2, moved1, o)
      }
      let map3 = case old2 {
        Error(_) -> map3
        Ok(o) -> dict.insert(map3, moved2, o)
      }
      case moved1 != newpos && moved2 != newpos2 {
        False -> #(map, pos)
        True -> #(map3, #(y - dy, x - dx))
      }
    }
  }
}

pub fn simulate(map, instructions, pos) {
  case instructions {
    [] -> map
    [i, ..is] -> {
      let #(map, pos) = step(map, pos, i)
      simulate(map, is, pos)
    }
  }
}

pub fn gps(map) {
  dict.fold(map, 0, fn(a, pos, tile) {
    let #(y, x) = pos
    case tile {
      Box | BigBox(L) -> a + 100 * y + x
      _ -> a
    }
  })
}

pub fn print(map, pos, h, w) {
  list.range(0, h - 1)
  |> list.map(fn(y) {
    list.range(0, w - 1)
    |> list.map(fn(x) {
      case #(y, x) == pos, dict.get(map, #(y, x)) {
        True, _ -> "@"
        False, Ok(Box) -> "O"
        False, Ok(BigBox(L)) -> "["
        False, Ok(BigBox(R)) -> "]"
        False, Ok(Wall) -> "#"
        False, Error(_) -> "."
      }
    })
    |> string.join("")
  })
  |> string.join("\n")
  |> io.println
}

pub fn main() {
  use #(map, instructions, pos) <- try(load())
  let map = simulate(map, instructions, pos)
  gps(map) |> io.debug
  Ok(Nil)
}
