primitive PonyExpressions
  
  // _______________________________
  
  fun run(env: Env) =>
    literals()
    control_structures()

  // _______________________________

  fun literals() =>
    // Numbers
    let unsigned1: I32 = 42_000
    let unsigned2 = I32(42_000)
    let my_hexadecimal_int: I32 = 0x400
    let my_binary_int: I32 = 0b10000000000
    let my_scientific_float: F32 = 42.12e-4
    let big_a: U8 = 'A'                 // 65
    let hex_escaped_big_a: U8 = '\x41'  // 65
    let newline: U32 = '\n'             // 10

    // The resulting integer value is constructed byte 
    // by byte with each character representing a single 
    // byte in the resulting integer, the last character 
    // being the least significant byte
    let multiByte: U64 = 'ABCD' // 0x41424344

    // Strings
    let pony = "🐎"
    let pony_hex_escaped = "p\xF6n\xFF"
    let pony_unicode_escape = "\U01F40E"

    // multiline strings
    let stacked_ponies = 
"🐎
🐎
🐎"
    let triple_quoted_string_docs =
  """
  🐎
  🐎
  🐎
  """

    // Array
    // Constructing an array with a literal creates new references to its elements. 
    // Thus, to be 100% technically correct, array literal elements are inferred to 
    // be the alias of the actual element type. If all elements are of type T the 
    // array literal will be inferred as Array[T!] ref that is as an array of aliases 
    // of the type T.
    // It is thus necessary to use elements that can have more than one reference of 
    // the same type (e.g. types with val or ref capability) or use ephemeral types 
    // for other capabilities (as returned from constructors or the consume expression)

    let literal_array1 =
    [
      "first"; "second"
      "third"
    ]

    let literal_array2: Array[(U64|String)] =  [U64(42); "42"; U64.min_value()]
    let literal_array3: Array[Stringable] ref = [U64(0xA); "0xA"]
    let literal_array4: Array[Stringable] val = [U64(0xA); "0xA"]

    // As Expression
    // This array literal is coerced to be an Array[Stringable] ref 
    let literal_array5 = [as Stringable: U64(0xFFEF); "0xFFEF"; U64(1 + 1)]
    
    take_array([as U32: 1; 2; 3])
    //take_array([1; 2; 3]) // Error

  fun take_array(xs: (Array[U32] ref | Array[U64] ref)) => None
    
  // _______________________________

  fun control_structures() =>
    // Any else branch that doesn’t exist gives an implicit None

    let a: U32 = 0
    let b: U32 = 0
    let enum: (U32 | None) = 1

    // _______________________________
    // Match

    let match_result1: String = match enum
      | 1 => "one" // value matching
      | let u: U32 if u < 10 => "little int" // capture
      | let u: U32 => "int" // capture
      | None => "none"
    end

    let match_result2: String = match enum
      | 1 => "one" // value matching
      | let u: U32 if u < 10 => "little int" // capture
      | let u: U32 => "int" // capture
    else
      "none"
    end

    let match_result3: (String | None) = match enum
      | 1 => "one" // value matching
      | let u: U32 if u < 10 => "little int" // capture
      | let u: U32 => "int" // capture
    end

    // Implicit matching on capabilities in the context of union types
    // Using a match expression to differentiate solely based on capabilities 
    // at runtime is not possible
    var value: (Array[String val] iso | String box | None) = recover box "Hello" end
    match (value = None) // type of this expression: (Array[String val] iso^ | String box | None)
    | let string_box: String box =>  None
    | let array_iso: Array[String val] iso => consume array_iso
    end
    
    match (a, b)
      | (let s: U32, 1) => s + 1
      | (let s: U32, _) => s
    end

    // _______________________________
    // If
    
    var if_result1: (String | Bool) = if a == b then
      "="
    elseif a > b then
      true
    else
      false
    end

    var if_result2: (Bool | None) = if a == b then true end
    
    // _______________________________
    // While  
   
    var count: U32 = 1

    let while_result = while count <= 10 do
      count = count + 1
      
      // `break` immediately exits from the innermost loop it’s in. 
      // Since the loop has to return a value break can take an expression
      // if it’s left out, the value from the else block is returned
    
      // If `continue` is executed during the last iteration of the loop 
      //  we use the loop’s else expression to get a value
    else 
      true
    end

    // _______________________________
    // Repeat  

    count = 1
    repeat
      count = count + 1
    until count > 10 end // The termination condition is reversed

    // _______________________________
    // For
    // An iterator needs to provide the following methods:
    // fun has_next(): Bool
    // fun next(): T?  
    
    var for_result: (Bool | None) = 
      for flag in [true; false].values() do
        flag
      end

  // _______________________________
  
  fun destructive_read() => 
    var a: U64 = 10
    var b: U64 = 11
  
    var temp = a
    a = b
    b = temp
    
    // is the same of
    a = b = a