/**
  apply an array of functions to an array of values

  This will return a new array resulting from the matrix of each function being
  applied to each value in the array

  - parameter fs: An array of transformation functions from type `T` to type `U`
  - parameter a: A value of type `[T]`

  - returns: A value of type `[U]`
*/
public func <*> <T, U>(fs: [(T) -> U], a: [T]) -> [U] {
  return a.apply(fs)
}

/**
  Sequence two values, discarding the right hand value

  This will return a new array resulting from repeating each element in `lhs`
  for each element in `rhs`.

  For example:

  ```
  let xs = [1, 2, 3]
  let ys = [4, 5, 6]
  let zs = xs <* ys // [1, 1, 1, 2, 2, 2, 3, 3, 3]
  ```

  - parameter lhs: A value of type `[T]`
  - parameter rhs: A value of type `[U]`

  - returns: a value of type `[T]`
*/
public func <* <T, U>(lhs: [T], rhs: [U]) -> [T] {
  return lhs.reduce([]) { accum, elem in
    accum + rhs.map { _ in elem }
  }
}

/**
  Sequence two values, discarding the left hand value

  This will return a new array resulting from iterating over `lhs` and
  appending the elements in `rhs` each time.

  For example:

  ```
  let xs = [1, 2, 3]
  let ys = [4, 5, 6]
  let zs = xs *> ys // [4, 5, 6, 4, 5, 6, 4, 5, 6]
  ```

  - parameter lhs: A value of type `[T]`
  - parameter rhs: A value of type `[U]`

  - returns: a value of type `[U]`
*/
public func *> <T, U>(lhs: [T], rhs: [U]) -> [U] {
  return lhs.reduce([]) { accum, _ in
    accum + rhs
  }
}

/**
  Wrap a value in a minimal context of `[]`

  - parameter a: A value of type `T`

  - returns: The provided value wrapped in an array
*/
public func pure<T>(_ a: T) -> [T] {
  return [a]
}

public extension Array {
  /**
    apply an array of functions to `self`

    This will return a new array resulting from the matrix of each function
    being applied to each value inside `self`

    - parameter fs: An array of transformation functions from type `Element` to
                    type `T`

    - returns: A value of type `[T]`
  */
  func apply<T>(_ fs: [(Element) -> T]) -> [T] {
    return fs.flatMap { self.map($0) }
  }
}
