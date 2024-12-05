import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/result.{try}
import gleam/set
import gleam/string
import simplifile

pub fn load() {
  use text <- try(
    simplifile.read("inputs/05") |> result.map_error(string.inspect),
  )
  let lines = string.split(text, on: "\n")
  let assert #(rules, [_, ..lines]) =
    list.split_while(lines, fn(l) { !string.is_empty(l) })
  let lines = list.take_while(lines, fn(l) { !string.is_empty(l) })
  use rules <- try(
    list.try_map(rules, fn(rule) {
      use #(l, r) <- try(
        string.split_once(rule, "|") |> result.replace_error("Can't parse rule"),
      )
      use l <- try(int.parse(l) |> result.replace_error("Can't parse L"))
      use r <- try(int.parse(r) |> result.replace_error("Can't parse R"))
      Ok(#(l, r))
    }),
  )
  let rules =
    list.fold(rules, dict.new(), fn(m, lr) {
      let #(l, r) = lr
      dict.upsert(m, l, fn(opt) {
        case opt {
          option.None -> set.new() |> set.insert(r)
          option.Some(s) -> set.insert(s, r)
        }
      })
    })
  use updates <- try(
    list.try_map(lines, fn(line) {
      string.split(line, ",")
      |> list.try_map(int.parse)
    })
    |> result.replace_error("Can't parse update"),
  )
  Ok(#(rules, updates))
}

pub fn check_swap(rules, update) -> Result(Nil, #(Int, Int)) {
  let #(_, to_swap) =
    list.fold(update, #(set.new(), option.None), fn(a, x) {
      let #(seen, to_swap) = a
      let badset = dict.get(rules, x) |> result.unwrap(set.new())
      #(set.insert(seen, x), case to_swap {
        option.None ->
          case set.is_disjoint(seen, badset) {
            True -> option.None
            False -> {
              let y = case
                set.intersection(seen, badset)
                |> set.to_list()
                |> list.first()
              {
                Error(_) -> panic
                Ok(x) -> x
              }

              option.Some(#(x, y))
            }
          }
        option.Some(_) -> to_swap
      })
    })
  case to_swap {
    option.None -> Ok(Nil)
    option.Some(x) -> Error(x)
  }
}

pub fn is_valid(rules, update) {
  check_swap(rules, update) |> result.is_ok
}

pub fn get_middle(update) {
  let n = list.length(update) / 2
  list.drop(update, n) |> list.first
}

pub fn main() {
  use #(rules, updates) <- try(load())
  use v <- try(
    list.try_map(updates, fn(u) {
      case is_valid(rules, u) {
        False -> Ok(0)
        True -> get_middle(u) |> result.replace_error("Can't get middle")
      }
    }),
  )
  int.sum(v)
  |> io.debug
  Ok(Nil)
}
