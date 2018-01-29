/**
  Return a successful value or the provided default

  - If the left hand value is `.some`, this will return the left hand value
  - If the left hand value is `.none`, this will return the default on the
    right hand side

  - parameter lhs: A value of type `Optional<T>`
  - parameter rhs: A value of type `Optional<T>`

  - returns: a value of type `Optional<T>`
*/
public func <|> <T>(lhs: T?, rhs: @autoclosure () -> T?) -> T? {
  return lhs.or(rhs)
}

/**
  Return an empty context of `.none`

  This is the dual of `pure`.

  - returns: An instance of `.none` of the type `T?`
*/
public func empty<T>() -> T? {
  return .none
}

public extension Optional {
  /**
    Return a successful value or the provided default

    - If `self` is `.some`, this will return `self`
    - If `self` is `.none`, this will return the provided default

    - parameter other: A value of type `Optional<T>`

    - returns: a value of type `Optional<T>`
  */
  func or(_ other: @autoclosure () -> Wrapped?) -> Wrapped? {
    switch self {
      case .some: return self
      case .none: return other()
    }
  }
}
