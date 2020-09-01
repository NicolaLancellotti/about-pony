// Expressions for arguments in function calls are evaluated 
// before the expression for the function receiver

primitive PonyTypes
  
  // _______________________________
  
  fun run(env: Env) =>
    variables()
    primitives()
    enumerations()
    classes()
    actors()

  // _______________________________

  fun variables() =>
    var x: String = "Hello"
    var x' = "Hello"
    var x''': String
    x''' = "Hello"

    // A variable having been declared with let only restricts reassignment
    // and does not influence the mutability of the object it references
    let y: U32 = 3
    // let y': U32 // Error
    // y' = 4

  // _______________________________
  
  fun primitives() => 
    // Built-in primitive types
    let x1: Bool = false
    let x2: I8 = 1
    let x3: ISize = 1
    let x4: U8 = 1
    let x5: USize = 1
    let x6: F32 = 1

    let sum = SomePrimitive.add(2,3)

  // _______________________________  
  
  fun enumerations() => 
    let color: Colour = Red
    let is_red: Bool = match color
      | Red => true 
      | Green => false
      | Blue => false
    end

    for colour in ColourList().values() do 
      None
    end  

  // _______________________________

  fun tuples() => 
    var x: (String, U64)
    x = ("hi", 3)
    x = ("bye", 7)

    (var y1, var z1) = x

    var y2 = x._1
    var z2 = x._2  

  // _______________________________
 
  fun classes() => 
    // Constructors
    let x1 = SomeClass // zero-argument constructor `create`
    let x2 = SomeClass.make("Hello")
    let x3 = x1.make("Hello") // Constructors can also be called on an expression

    // Functions
    let value = x1.get_value()
    x1.set_value(1)
    x2.set_value()

  // _______________________________
  
  fun actors() => 
    let x = SomeActor
    x.increment(1)

  // _______________________________

  fun sugar() => None
    // Create
    //  var foo = Foo
    //  var baz = Foo(z)
    // becomes
    //  var foo = Foo.create()
    //  var baz = Foo.create(z)
    
    // Apply
    //  foo()
    // becomes
    //  foo.apply()

    // Combined create-apply
    // If there are default arguments then this sugar cannot be used.
    //  var foo = Foo()
    // becomes
    //  var foo = Foo.create().apply()

    // Chaining
    //  out.>print(s1).>print(s2)
    // becomes
    //  out.print(s1)
    //  out.print(s2)
    //  out

    // Where
    // fun f(a: U32 = 1, b: U32 = 2, c: U32 = 3, d: U32 = 4, e: U32 = 5) => None
    // 
    // f(6, 7 where d = 8)
    // becomes
    // f(6, 7, 3, 8, 5)

    // Update
    //  foo(z) = x
    // becomes
    //  foo.update(z where value = x) 

// ____________________________________________________________________________
// Primitives
// - A primitive has no fields (never mutable)
// - There is only one instance of a user-defined primitive

primitive SomePrimitive
  // _______________________________
  // Primitive initialisation and finalisation
  // The _init and _final functions for different primitives always run sequentially
  
  // It is called before any actor starts
  fun _init() => None
  
  // It is called after all actors have terminated
  fun _final() => None

  // _______________________________
  // Functions

  fun add(x: U64, y: U64): U64 => x + y

// ____________________________________________________________________________
// Enumerations

primitive Red    fun apply(): U32 => 0xFF0000FF
primitive Green  fun apply(): U32 => 0x00FF00FF
primitive Blue   fun apply(): U32 => 0x0000FFFF
type Colour is (Red | Blue | Green)

primitive ColourList fun apply(): Array[Colour] => [Red; Green; Blue]

// ____________________________________________________________________________
// Classes

class SomeClass
  let field: String
  var _private_field: U64

  // _______________________________
  // Constructors
 
  new create() =>
    field = ""
    _private_field = 1

  new make(field': String) =>
    field = field'
    _private_field = 0

  // _______________________________
  // Finalisers
  // - The receiver has to be a `box` type (see Reference capabilities)
  // - Functions may still be called on an object after its finalisation, 
  //   but only from within another finaliser 
  // - Messages cannot be sent from within a finaliser
 
  fun _final() =>
    @puts[I32]("_final".cstring()) // FFI

  // _______________________________
  // Functions
  
  // The default receiver reference capability is box (readonly)
  fun get_value(): U64 => _private_field    
  
  fun ref set_value(to: U64 = 0): None => _private_field = to

// ____________________________________________________________________________
// Actors
// - An actor can have behaviours (asynchronous functions)
// - Each actor will only execute one behaviour at a time
// - An actor will not receive any further message after its finaliser is called
// - Garbage collection is never attempted on any actor while it is executing a behavior
//   or a constructor
// - If you have a variable referring to an actor then you can send messages to that 
//   actor regardless of what reference capability that variable has

actor SomeActor
  var _value: U64 = 0
  
  be increment(amount: U64) =>
    _value = _value + amount
  
// ____________________________________________________________________________
// Structs

struct Inner
  var x: I32 = 0

  // Constructor
  new create(x': I32) =>
    x = x'

struct Outer
  // Fields 

  //  var/let field is a pointer to an object allocated separately
  var inner_var: Inner = Inner(1)

  // - The memory for the embedded class is laid out directly within the outer class
  // - Embedded fields must be initialised from a constructor expression
  // - Exterior references to the field forbids garbage collection of the parent
  //   which can result in higher memory usage if a field outlives its parent.
  embed inner_embed: Inner = Inner(1)

  // Only classes or structs can be embedded
  // embed x: U32 = 1 // Error
  
  // Function
  fun foo() => None

// Removes padding
struct \packed\ MyPackedStruct
  var x: U8 = 0
  var y: U32 = 0  

// ____________________________________________________________________________
// Traits: Nominal subtyping  

trait TraitA
  fun fooA(): Bool => false
  
trait TraitAB is TraitA
  fun fooB(): Bool => false

trait TraitC
  fun fooC(): Bool

// Interfaces: Structural subtyping  
interface InterfaceA
  fun barA(): Bool

interface InterfaceB
  fun barB(): Bool
 
// Example
class Bob is (TraitAB & TraitC & InterfaceA)
  fun fooC(): Bool => false
  fun barA(): Bool => false
  fun barB(): Bool => false