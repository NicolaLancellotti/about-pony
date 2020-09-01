// cd About-Pony
// ponyc

// Standard Library: https://stdlib.ponylang.io

use "language"
use alias = "language"
// use "package" if (windows and debug)

actor Main

  new create(env: Env) =>
    PonyTypes.run(env)
    PonyReferenceCapabilities.run(env)
    PonyExpressions.run(env)
    PonyOperators.run(env)
    PonyAnonymousTypes.run(env)
    PonyErrors.run(env)
    PonyGenerics.run(env)
    alias.PonyMiscellaneous.run(env)