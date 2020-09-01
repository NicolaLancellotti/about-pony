use "debug"

// Capability Constraints
// [Name: Constraint ReferenceCapability]
class GenericClass1[A: Any val]

/*
Classes of capabilities

Anything you can read from
#read  - ref, val, box	    
  
Anything you can send to an actor
#send	 - iso, val, tag	    
  
Anything you can send to more than one actor
#share -  val, tag	          
  
Set of capabilities that alias as themselves
#alias	- ref, val, box, tag	
  
Default of a constraint
#any	  - iso, trn, ref, val, box, tag	    
*/
class GenericClass2[A: Any #read]

// If the capability is left out of the type parameter then the 
// generic class or function can accept any reference capability  

class GenericClass[A]
  var _c: A

  new create(c: A) =>
    let alias: A! = c
    _c = consume c

  fun get(): this->A => _c

  fun ref set(c: A) => _c = consume c

  // box->A - a type parameter `A` as it is seen by some unknown type
  // as long as that type can read the type parameter `A`
  fun box_as_viewpoint(that: box->A) => 
    if that is _c then
      None
    end
    
// ____________________________________________________________________________

primitive GenericMethods
  fun bar_val[A: Stringable val](a: A): String =>
    a.string()

// ____________________________________________________________________________

trait GenericTrait[A]
  fun fooA(): A

class ClassWithGenericTrait is GenericTrait[String val]
  fun fooA(): String val => "ClassWithGenericTrait"

// ____________________________________________________________________________

primitive PonyGenerics  

  fun run(env: Env) => None
    let iso_value = recover iso "World".clone() end
    let iso_tag: String iso! = iso_value
    let a: GenericClass[String iso] ref = GenericClass[String iso](consume iso_value)
    let a_value1: String iso! = a.get()
    let a_value2: String tag = a.get()
    // a.get() is a iso -> automatic receiver recovery
    a.get().string()
    a.box_as_viewpoint(iso_tag)
    
    let ref_value = recover ref "Hello".clone() end
    let b = GenericClass[String ref](ref_value)
    let b_value: String ref = b.get()
    b.box_as_viewpoint(ref_value)

    let c = GenericClass[U8](42)
    let c_value: U8 val = c.get()
    c.box_as_viewpoint(42)

    // _______________________________

    let x = GenericMethods.bar_val[U32](10)
    Debug.out(x.string())

    // _______________________________
    // Type Aliases
    // type SetIs[A] is HashSet[A, HashIs[A!]]
    // type Map[K: (Hashable box & Comparable[K] box), V] is HashMap[K, V, HashEq[K]]

    // _____________________________
    // Type parameter as a viewpoint
    // class ListValues[A, N: ListNode[A] box] is Iterator[N->A]
    // The iterator returns objects of the type A
    // The reference capability will be the same as an object of type N 
    // would see an object of type A