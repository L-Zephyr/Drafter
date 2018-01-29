/**
  Return the result of concatenating two arrays

  - parameter lhs: A value of type `[T]`
  - parameter rhs: A value of type `[T]`

  - returns: The result of concatenating `lhs` and `rhs`
*/
public func <|> <T>(lhs: [T], rhs: @autoclosure () -> [T]) -> [T] {
  return lhs + rhs()
}

/**
  Return an empty context of `[]`

  This is the dual of `pure`.

  - returns: An instance of `[]` of the type `[T]`
*/
public func empty<T>() -> [T] {
  return []
}
