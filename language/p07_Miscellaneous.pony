primitive PonyMiscellaneous  

  fun run(env: Env) => 
    // _______________________________
    """
    This is a docstrings documentation
    """  

    // _______________________________
    let flag: Bool = true

    // Environment
    // env.out.print("Hello, world! " + flag.string())

    // _______________________________
    // Program Annotations
    // Gives optimisation hints to the compiler on the 
    // likelihood of a given conditional expression
    if \likely\ flag then
      None
    end

    // _______________________________
    // Create a USize value that summarizes the Pony object
    let d: USize = digestof flag

    // _______________________________
    // Flag at compile time: ponyc –D “foo”
    ifdef "foo" then  
      compile_error "foo must not be defined"
    end