/**
  apply an optional function to an optional value

  - If either the value or the function are `.none`, the function will not be
    evaluated and this will return `.none`
  - If both the value and the function are `.some`, the function will be
    applied to the unwrapped value

  - parameter f: An optional transformation function from type `T` to type `U`
  - parameter a: A value of type `Optional<T>`

  - returns: A value of type `Optional<U>`
*/
public func <*> <T, U>(f: ((T) -> U)?, a: T?) -> U? {
  return a.apply(f)
}

/**
  Sequence two values, discarding the right hand value

  - If the right hand value is `.none`, this will return `.none`
  - If the right hand value is `.some`, this will return the left hand value

  - parameter lhs: A value of type `Optional<T>`
  - parameter rhs: A value of type `Optional<U>`

  - returns: a value of type `Optional<T>`
*/
public func <* <T, U>(lhs: T?, rhs: U?) -> T? {
  switch rhs {
  case .none: return .none
  case .some: return lhs
  }
}

/**
  Sequence two values, discarding the left hand value

  - If the left hand value is `.none`, this will return `.none`
  - If the left hand value is `.some`, this will return the right hand value

  - parameter lhs: A value of type `Optional<T>`
  - parameter rhs: A value of type `Optional<U>`

  - returns: a value of type `Optional<U>`
*/
public func *> <T, U>(lhs: T?, rhs: U?) -> U? {
  switch lhs {
  case .none: return .none
  case .some: return rhs
  }
}

/**
  Wrap a value in a minimal context of `.some`

  - parameter a: A value of type `T`

  - returns: The provided value wrapped in `.some`
*/
public func pure<T>(_ a: T) -> T? {
  return .some(a)
}

public extension Optional {
  /**
    apply an optional function to `self`

    - If either self or the function are `.none`, the function will not be
      evaluated and this will return `.none`
    - If both self and the function are `.some`, the function will be applied
      to the unwrapped value

    - parameter f: An optional transformation function from type `Wrapped` to type `T`

    - returns: A value of type `Optional<T>`
  */
  func apply<T>(_ f: ((Wrapped) -> T)?) -> T? {
    return f.flatMap { self.map($0) }
  }
}
