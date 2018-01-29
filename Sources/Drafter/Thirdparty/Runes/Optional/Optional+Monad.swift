/**
  flatMap a function over an optional value (left associative)

  - If the value is `.none`, the function will not be evaluated and this will
    return `.none`
  - If the value is `.some`, the function will be applied to the unwrapped
    value

  - parameter f: A transformation function from type `T` to type `Optional<U>`
  - parameter a: A value of type `Optional<T>`

  - returns: A value of type `Optional<U>`
*/
public func >>- <T, U>(a: T?, f: (T) -> U?) -> U? {
  return a.flatMap(f)
}

/**
  flatMap a function over an optional value (right associative)

  - If the value is `.none`, the function will not be evaluated and this will
    return `.none`
  - If the value is `.some`, the function will be applied to the unwrapped
    value

  - parameter a: A value of type `Optional<T>`
  - parameter f: A transformation function from type `T` to type `Optional<U>`

  - returns: A value of type `Optional<U>`
*/
public func -<< <T, U>(f: (T) -> U?, a: T?) -> U? {
  return a.flatMap(f)
}

/**
  compose two functions that produce optional values, from left to right

  - If the result of the first function is `.none`, the second function will
    not be inoked and this will return `.none`
  - If the result of the first function is `.some`, the value is unwrapped and
    passed to the second function which may return `.none`

  - parameter f: A transformation function from type `T` to type `Optional<U>`
  - parameter g: A transformation function from type `U` to type `Optional<V>`

  - returns: A function from type `T` to type `Optional<V>`
*/
public func >-> <T, U, V>(f: @escaping (T) -> U?, g: @escaping (U) -> V?) -> (T) -> V? {
  return { x in f(x) >>- g }
}

/**
  compose two functions that produce optional values, from right to left

  - If the result of the first function is `.none`, the second function will
    not be inoked and this will return `.none`
  - If the result of the first function is `.some`, the value is unwrapped and
    passed to the second function which may return `.none`

  - parameter f: A transformation function from type `U` to type `Optional<V>`
  - parameter g: A transformation function from type `T` to type `Optional<U>`

  - returns: A function from type `T` to type `Optional<V>`
*/
public func <-< <T, U, V>(f: @escaping (U) -> V?, g: @escaping (T) -> U?) -> (T) -> V? {
  return { x in g(x) >>- f }
}
