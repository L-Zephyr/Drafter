/**
  map a function over an array of values

  This will return a new array resulting from the transformation function being
  applied to each value in the array

  - parameter f: A transformation function from type `T` to type `U`
  - parameter a: A value of type `[T]`

  - returns: A value of type `[U]`
*/
public func <^> <T, U>(f: (T) -> U, a: [T]) -> [U] {
  return a.map(f)
}
