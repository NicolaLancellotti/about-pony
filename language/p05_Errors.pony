primitive PonyErrors

  // _______________________________

  fun run(env: Env) => 
    let int: (I32 | None) = try
      throw(true)?
    end

    try
      throw(true)?
      return
    else
      "an error was throw"
    then
      "always executed - even if there is a return inside the try"
    end

    // obj.dispose() will be called whether the code inside 
    // the with block completes successfully or raises an error
    with obj = SomeObjectThatNeedsDisposing, other = SomeObjectThatNeedsDisposing do
      throw(true)?
    else 
      "only run if an error has occurred"
    end

  // _______________________________
  // Partial function
  // Constructors and behaviours for actors may not be partial
  // Errors do not have type
  
  fun throw(flag: Bool): I32 ? =>
    if flag then error else 10 end

// ____________________________________________________________________________

class SomeObjectThatNeedsDisposing
  new create() => None
  fun dispose() => None    