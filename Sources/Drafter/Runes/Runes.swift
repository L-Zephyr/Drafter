precedencegroup RunesMonadicPrecedenceRight {
  associativity: right
  lowerThan: LogicalDisjunctionPrecedence
  higherThan: AssignmentPrecedence
}

precedencegroup RunesMonadicPrecedenceLeft {
  associativity: left
  lowerThan: LogicalDisjunctionPrecedence
  higherThan: AssignmentPrecedence
}

precedencegroup RunesAlternativePrecedence {
  associativity: left
  higherThan: LogicalConjunctionPrecedence
  lowerThan: ComparisonPrecedence
}

precedencegroup RunesApplicativePrecedence {
  associativity: left
  higherThan: RunesAlternativePrecedence
  lowerThan: NilCoalescingPrecedence
}

precedencegroup RunesApplicativeSequencePrecedence {
  associativity: left
  higherThan: RunesApplicativePrecedence
  lowerThan: NilCoalescingPrecedence
}

/**
  map a function over a value with context

  Expected function type: `(a -> b) -> f a -> f b`
  Haskell `infixl 4`
*/
infix operator <^> : RunesApplicativePrecedence

/**
  apply a function with context to a value with context

  Expected function type: `f (a -> b) -> f a -> f b`
  Haskell `infixl 4`
*/
infix operator <*> : RunesApplicativePrecedence

/**
  sequence actions, discarding right (value of the second argument)

  Expected function type: `f a -> f b -> f a`
  Haskell `infixl 4`
*/
infix operator <* : RunesApplicativeSequencePrecedence

/**
  sequence actions, discarding left (value of the first argument)

  Expected function type: `f a -> f b -> f b`
  Haskell `infixl 4`
*/
infix operator *> : RunesApplicativeSequencePrecedence

/**
  an associative binary operation

  Expected function type: `f a -> f a -> f a`
  Haskell `infixl 3`
*/
infix operator <|> : RunesAlternativePrecedence

/**
  map a function over a value with context and flatten the result

  Expected function type: `m a -> (a -> m b) -> m b`
  Haskell `infixl 1`
*/
infix operator >>- : RunesMonadicPrecedenceLeft

/**
  map a function over a value with context and flatten the result

  Expected function type: `(a -> m b) -> m a -> m b`
  Haskell `infixr 1`
*/
infix operator -<< : RunesMonadicPrecedenceRight

/**
  compose two functions that produce results in a context,
  from left to right, returning a result in that context

  Expected function type: `(a -> m b) -> (b -> m c) -> a -> m c`
  Haskell `infixr 1`
*/
infix operator >-> : RunesMonadicPrecedenceRight

/**
  compose two functions that produce results in a context,
  from right to left, returning a result in that context

  like `>->`, but with the arguments flipped

  Expected function type: `(b -> m c) -> (a -> m b) -> a -> m c`
  Haskell `infixr 1`
*/
infix operator <-< : RunesMonadicPrecedenceRight
