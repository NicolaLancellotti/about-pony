use "debug"

primitive PonyOperators
  
  // _______________________________
  
  fun run(env: Env) =>
    operators()
    arithmetic_op()
    convert()
    as_op()
    equality_op(env)

  // _______________________________

  fun operators() =>
    // Precedence
    // - Method calls and field accesses have higher precedence than any operators
    // - Unary operator have higher precedence than infix operators
    // - When mixing infix operators in complex expressions, 
    //    we must use parentheses to specify precedences explicitly
    let x: I32 = 1 + (2 * -3)  // -5

    I32(1) + I32(2)
    Pair(1, 2) + Pair(3, 4)   
    // Most infix operators in Pony are actually aliases for function
    Pair(1, 2).add(Pair(3, 4))

    // Boolean operators
    (false and (not true)) or false
  
   // _______________________________  

   fun arithmetic_op() =>
    let a: I32 = 1
    let b: I32 = 1
    
    // Default arithmetic
    // Overflow/underflow are handled with proper wrap around semantics
    // The normal division is defined to be 0 when the divisor is 0
    (U32.max_value() + 1) == 0
    (I32.min_value() - 1) == I32.max_value()
  
    // Unsafe Arithmetic
    // Like in C, overflow, underflow and division by zero scenarios are undefined
    a +~ b // add unsafe

    // Partial arithmetic
    // Partial arithmetic operators error on overflow/underflow and division by zero
    try
      USize.max_value() +? 123
    else
      "overflow detected"
    end

    // Checked Arithmetic
    // Checked arithmetic methods return a tuple of the result of the operation and 
    // a Boolean indicating overflow or other exceptional behaviour
    
    match USize.max_value().addc(1)
      | (let result: USize, false) => None
      | (_, true) => "overflow detected"        
    end 
  
  // _______________________________  

  fun convert() =>
    I64(12).f32() // Converting an I32 to a 32 bit floating point
    I64.max_value().f32_unsafe() // Undefined
    I64(1).u8_unsafe()  // Undefined (actually safe)

  // _______________________________  

  fun as_op() =>
    // Runtime casting
    let x:(U32 | String) = 1
    try
      let t = x as U32
    end

  // _______________________________  

   fun equality_op(env: Env) =>
    let a = Pair(3, 4)
    let a2 = a
    let b = Pair(3, 4)
    let c = Pair(4, 3)
  
    // Identity equality
    let r1 = None is None // True: There is only 1 None so the identity is the same
    let r2 = "🐎" is "🐎" // True
    let r3 = a is a  // True
    let r4 = a is a2 // True
    let r5 = a is b  // False
    let r6 = a is c  // False
    None isnt None /// False
    
    // Structural_equality
    let r7 = a == a2 // True
    let r8 = a == b  // True
    let r9 = a == c  // False

    // The compiler calls the eq() function on the operand
    // passing the pattern as the argument.
    let r10 = match a
    | Pair(3, 4) => true
    | Pair(4, 3) => false
    end
    
    // Debug.out("r1: " + r1.string())
    // Debug.out("r2: " + r2.string())
    // Debug.out("r3: " + r3.string())
    // Debug.out("r4: " + r4.string())
    // Debug.out("r5: " + r5.string())
    // Debug.out("r6: " + r6.string())
    // Debug.out("r7: " + r7.string())
    // Debug.out("r8: " + r8.string())
    // Debug.out("r9: " + r9.string()) 
    // Debug.out("r10: " + r10.string()) 

// ____________________________________________________________________________
// Custom Operators 

class Pair
  var _x: U32 = 0
  var _y: U32 = 0

  new create(x: U32, y: U32) =>
    _x = x
    _y = y

  // The right side of the + will have to match the parameter type
  // The whole + expression will have the type that add returns
  fun add(other: Pair): Pair =>
    Pair(_x + other._x, _y + other._y)  

  fun eq(that: box->Pair): Bool =>
    (this._x == that._x) and (this._y == that._y)   