/**
  map a function over an optional value

  - If the value is `.none`, the function will not be evaluated and this will
    return `.none`
  - If the value is `.some`, the function will be applied to the unwrapped
    value

  - parameter f: A transformation function from type `T` to type `U`
  - parameter a: A value of type `Optional<T>`

  - returns: A value of type `Optional<U>`
*/
public func <^> <T, U>(f: (T) -> U, a: T?) -> U? {
  return a.map(f)
}
