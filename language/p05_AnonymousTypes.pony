use "collections"

// When an anonymous type has no fields and no behaviours
// (for example, an object literal declared as a lambda literal)
// the compiler generates it as an anonymous primitive
// unless a non-val reference capability is explicitly given
// This means no memory allocation is needed to generate an instance of that type
// (A primitive literal is always returned as a val)

primitive PonyAnonymousTypes
  
  // _______________________________
  
  fun run(env: Env) => 
    object_literals()
    lambdas(env)

  // _______________________________
  
  fun object_literals() =>
    let str = "Hello, world!"

    // Free variables: Values that aren’t 
    // - local variables
    // - fields
    // - parameters
    
    // An object literal with fields is returned as a ref by default 
    let object_literal1: Hashable ref = object is Hashable
      let s: String = str // Free variable (Capturing from the lexical scope)
      fun apply(): String => s
      fun hash(): USize => s.hash()
    end

    // Explicit reference capability
    let object_literal2: Hashable iso = object iso is Hashable
      fun apply(): String => str 
      fun hash(): USize => str.hash()
    end  

    // An actor literal is always returned as a tag
    let actor_literal = object
      be foo() => None
    end  

  // _______________________________
  
  fun lambdas(env: Env) => 
    let lambda1 = {(s: String): String => "lambda: " + s }
    
    // Desugar
    // A lambda desugars to an object literal with an apply method
    let object_literal1 = object
      fun apply(s: String): String => "lambda: " + s
    end

    // The reference capability for the object 
    // - val - if the lambda does not have any captured references
    // - ref - if the lambda does have captured references
    
    // Declare the reference capability for the object
    let lambda_iso = {(s: String): String => "lambda: " + s } iso

    let odd_object_literal_iso = object iso
      fun apply(s: String): String => "lambda: " + s
    end

    // The reference capability for the object 
    // - box - default
    // If the lambda does have captured references this needs to be ref 

    // Declare the reference capability for the apply method & Capture from the lexical scope 
    var star_value: U32 = 1
    let increment = {ref(i:U32): U32 => star_value = star_value + i; star_value } 
    let increment2 = {ref(i:U32)(s = star_value): U32 => s = s + i; s }
    increment(10) // 11
    increment(5) // 16
    star_value == 1 // Reassigning a reference,  x = true, inside a lambda or object literal
                    // can never cause a reassignment in the outer scope

    // Pass to a function
    take_a_lambda(lambda1)

  fun take_a_lambda(f: {(String): String} val): String => f("Hello World")

   // _______________________________

  fun partial_application() => None
    let foo  = PonyAnonymousTypes
    let f0 = foo~add()
    f0(3, 4)

    var f1 = foo~add(3)
    f1(4)

    let f2 = foo~add(3, 4)
    f2()

    let f3 = foo~add(where y = 4)
    f3(3)
    
    // Partial application results in an anonymous class and returns a ref
    // It captures aliases of some of the lexical scope as fields and has an apply 
    // function that takes some, possibly reduced, number of arguments
    // If you need another reference capability, you can wrap partial application 
    // in a recover expression 
    // It also means that we can’t consume unique fields for a lambda, as the apply 
    // method might be called many times

    // Partially applying a partial application
    let f4 = foo~add()
    let f5 = f4~apply(where x = 4)
    f5(3)

  fun add(x: F64, y: F64): F64 => x + y