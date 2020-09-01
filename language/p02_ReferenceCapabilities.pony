/*
Reference capabilities (a form of type qualifier):
- Mutable reference capabilities
  - Isolated  T iso   (to pass a mutable object between actors)
    - variables in    the same actor cannot     read or write
    - variables in    other actors cannot       read or write
  - Transition T trn  (it can’t be sent to other actors)
    - variables in    the same actor cannot     write
    - variables in    other actors cannot       read or write
  - Reference  T ref  (it can’t be sent to other actors)
    - variables in    other actors cannot       read or write
- Immutable reference capabilities               
  - Value      T val  (to share an immutable object amongst actors)   
    - variables in    the same actor cannot     write
    - variables in    other actors cannot       write
  - Box        T box  (it can’t be sent to other actors)   
    - variables in    other actors cannot       write 
- Opaque reference capabilities (can’t be used to either read or write)
  - Tag        T tag  (to share the identity of a mutable object amongst actors)
    - makes no guarantees about other variables at all
    
    - you can do identity comparison 
    - you can call behaviours on it
    - you can call functions on it that only need a tag receiver

Default Reference capability:
- primitives -  val
- classes - ref
- tag - actor    

Simple substitution
iso <: trn
trn <: ref
trn <: val
ref <: box
val <: box
box <: tag

Ephemeral substitution
iso^ <: iso
trn^ <: trn
ref^ <: ref and ref <: ref^
val^ <: val and val <: val^
box^ <: box and box <: box^
tag^ <: tag and tag <: tag^     

Aliased substitution
iso! <: tag
trn! <: box
ref! <: ref
val! <: val
box! <: box
tag! <: tag  

Viewpoint adaptation (combining origin and field capabilities)
The origin has a viewpoint, and its fields can be “seen” only from that viewpoint
  
Reading  to the field of an object
        field    iso	trn		ref		val		box		tag
_________________________________________________
origin  iso   | iso		tag		tag		val		tag		tag
        trn   | iso		box 	box		val		box		tag
        ref   | iso		trn		ref		val		box		tag
        val   | val		val		val		val		val		tag
        box   | tag		box		box		val		box		tag
        tag   | n/a		n/a		n/a		n/a		n/a		n/a 

Writing to the field of an object
        field    iso	trn		ref		val		box		tag
_________________________________________________
origin  iso   | YES               YES         YES
        trn   | YES   YES         YES         YES
        ref   | YES   YES   YES   YES   YES   YES
        val   | 
        box   | 
        tag   | 
*/

class Bar
  fun iso fun_iso() => None

class val /* Default reference capability for Baz is val: `Baz` means `Baz val` */ Baz
  var field_iso: Array[String] iso = []
  var field_trn: Array[String] trn = []
  var field_ref: Array[String] ref = []
  var field_val: Array[String] val = []
  var field_box: Array[String] box = []
  var field_tag: Array[String] tag = []

  var field_iso2: Bar iso = Bar

  new /* default reference capability for classes is ref*/ create() => None

  // Create objects with different capabilities
  new iso create_iso() => None
  new trn create_trn() => None
  new ref create_ref() => None
  new val create_val() => None
  new box create_box() => None
  new tag create_tag() => None
  

  // Box is the default receiver
  fun get_box(): Array[String] box => field_ref     // Reading to the field of an object
  fun ref get_ref(): Array[String] ref => field_ref // Reading to the field of an object

  // Viewpoint adapted type (Arrow Types)
  // An arrow type with “this->” states to use the capability of the actual receiver 
  // not the capability of the method 
  fun get(): this->Array[String] ref => field_ref   // Reading to the field of an object    

primitive PonyReferenceCapabilities
  
  // _______________________________

  fun run(env: Env) => None
  
  // _______________________________

  fun create_values() => 
    let x1: Baz /*Default reference capability for Baz is val */ =  Baz.create_val()
    let x2: Baz ref =  Baz.create()
    let x3: Baz ref =  Baz.create_ref()
    let x4: Baz val =  Baz.create_val()

    // Consuming a variable
    // Move an object from one variable to another
    // Fields cannot be consumed -> use destructive read
    let y1: Baz val = consume x1
    // let y2 = x1 // Error
    
  // _______________________________
  // Ephemeral type
  // It is a type for a value that currently has no name
  
  fun ephemeral_type_consume(x: Baz iso): Baz iso^ =>  
    consume x

  fun ephemeral_types_destructive_read(x': Baz iso): Baz iso^ =>  
    var x: Baz iso =  Baz.create_iso()
    x = consume x'

  // _______________________________
  //   Capability Subtyping
  // - a <: b means “a is a subtype of b” “a can be substituted for b”
  // - Subtyping is transitive

  fun aliased_substitution() =>
    let x_iso: Baz iso = Baz.create_iso()
    let x_trn: Baz trn = Baz.create_trn()
    let x_ref: Baz ref = Baz.create_ref()
    let x_val: Baz val = Baz.create_val()
    let x_box: Baz box = Baz.create_box()
    let x_tag: Baz tag = Baz.create_tag()

    // There are three things that count as making an alias:
    // - When you assign a value to a variable or a field
    // - When you pass a value as an argument to a method
    // - When you call a method, an alias of the receiver of the call is 
    //   created. It is accessible as this within the method body
    // The alias type of `Baz iso` is `Baz iso!`
    
    let x_iso_alias1: Baz iso! = x_iso
    let x_iso_alias2: Baz tag = x_iso_alias1  // iso! <: tag

    let x_trn_alias1: Baz trn! = x_trn
    let x_trn_alias2: Baz box = x_trn_alias1  // trn! <: box

    let x_ref_alias1: Baz ref! = x_ref
    let x_ref_alias2: Baz ref = x_ref_alias1  // ref! <: ref

    let x_val_alias1: Baz val! = x_val
    let x_val_alias2: Baz val = x_val_alias1  // val! <: val

    let x_box_alias1: Baz box! = x_box
    let x_box_alias2: Baz box = x_box_alias1  // box! <: box

    let x_tag_alias1: Baz tag! = x_tag
    let x_tag_alias2: Baz tag = x_tag_alias1  // tag! <: tag

  fun simple_and_ephemeral_substitution() =>
    //            <: ref 
    // iso <: trn        <: box <: tag   
    //            <: val
    
    let x_trn: Baz trn = Baz.create_iso()  // iso^ <: iso <: trn
    let x_ref1: Baz ref = Baz.create_trn() // trn^ <: trn <: ref
    let x_val: Baz val = Baz.create_trn()  // trn^ <: trn <: val
    let x_box1: Baz box = Baz.create_ref() // ref^ <: ref <: box
    let x_box2: Baz box = Baz.create_val() // val^ <: val <: box
    let x_tag1: Baz tag = Baz.create_box() // box^ <: box <: tag
    let x_tag2: Baz tag = Baz.create_tag() // tag^ <: tag

    let x_ref_e: Baz ref^ = Baz.create_ref() // ref^ <: ref <: ref^
    let x_val_e: Baz val^ = Baz.create_val() // val^ <: val <: val^
    let x_box_e: Baz box^ = Baz.create_box() // box^ <: box <: box^
    let x_tag_e: Baz tag^ = Baz.create_tag() // tag^ <: tag <: tag^ 

  // _______________________________  
     
  fun viewpoint_adaptation_iso() =>
    var x: Baz iso =  Baz.create_iso()
    x.field_iso // Array[String] iso
    let field_trn: Array[String] tag = x.field_trn
    let field_ref: Array[String] tag = x.field_ref
    let field_val: Array[String] val = x.field_val
    let field_box: Array[String] tag = x.field_box
    let field_tag: Array[String] tag = x.field_tag

  fun viewpoint_adaptation_trn() =>
    var x: Baz trn = Baz.create_iso()
    x.field_iso // Array[String] iso
    let field_trn: Array[String] box = x.field_trn
    let field_ref: Array[String] box = x.field_ref
    let field_val: Array[String] val = x.field_val
    let field_box: Array[String] box = x.field_box
    let field_tag: Array[String] tag = x.field_tag
  
  fun viewpoint_adaptation_ref() =>
    var x: Baz ref = Baz.create_ref()
    x.field_iso // Array[String] iso
    x.field_trn // Array[String] trn
    let field_ref: Array[String] ref = x.field_ref
    let field_val: Array[String] val = x.field_val
    let field_box: Array[String] box = x.field_box
    let field_tag: Array[String] tag = x.field_tag

  fun viewpoint_adaptation_val() =>
    var x: Baz val = Baz.create_val()
    let field_iso: Array[String] val = x.field_iso
    let field_trn: Array[String] val = x.field_trn
    let field_ref: Array[String] val = x.field_ref
    let field_val: Array[String] val = x.field_val
    let field_box: Array[String] val = x.field_box
    let field_tag: Array[String] tag = x.field_tag

  fun viewpoint_adaptation_box() =>
    var x: Baz box = Baz.create_box()
    let field_iso: Array[String] tag = x.field_iso
    let field_trn: Array[String] box = x.field_trn
    let field_ref: Array[String] box = x.field_ref
    let field_val: Array[String] val = x.field_val
    let field_box: Array[String] box = x.field_box
    let field_tag: Array[String] tag = x.field_tag

  fun viewpoint_adaptation_tag() =>
    var x: Baz tag = Baz.create_tag()
    // x.field_iso // Error
    // x.field_trn // Error
    // x.field_ref // Error
    // x.field_val // Error
    // x.field_box // Error
    // x.field_tag // Error

  // _______________________________ 

  fun arrow_types() =>
    var x_ref: Baz ref = Baz
    let y1: Array[String] box = x_ref.get_box()
    let y2: Array[String] ref = x_ref.get_ref()
    
    let y3: Array[String] ref = x_ref.get()

// _______________________________

 fun recovering_capabilities() =>
    // A recover expression lets you “lift” the reference capability of the result
    // - A mutable reference capability (iso, trn, or ref) 
    //   can become any reference capability 
    // - An immutable reference capability (val or box) 
    //   can become any immutable or opaque reference capability.
    // You can only use iso, val and tag things from outside the recover expression
    // When the recover expression finishes, any aliases to the result of the expression 
    // other than iso, val and tag ones won’t exist anymore
    // It safe to “lift” the reference capability of the result of the expression

    // iso is the default reference capability 
    let x_iso: Baz iso = recover Baz.create_ref() end

    let x_val: Baz val = recover val Baz.create_ref() end

    let x_box: Baz box = recover box x_val end
    let x_val2: Baz val = recover val consume x_iso end

    // Automatic receiver recovery
    // When you have an iso or trn receiver, you normally can’t call ref methods on it
    // That’s because the receiver is also an argument to a method, which means both the 
    // method body and the caller have access to the receiver at the same time
    // 
    // If all the arguments to the method (other than the receiver) at the call-site are sendable, 
    // and the return type of the method is either sendable or isn’t used at the call-site, 
    // then we can “automatically recover” the receiver
    var s: String iso = recover iso String end
    s.append("hello")

    let hello: String val = "hello" 
    s = recover 
      let s_ref: String ref = recover ref consume s end
      s_ref.append(hello)
      s_ref
    end