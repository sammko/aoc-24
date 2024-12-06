import gleam/list

pub fn enumerate(list) {
  let #(_, l) = list.map_fold(list, 0, fn(i, x) { #(i + 1, #(i, x)) })
  l
}
