// just docs: Better C
/++





$(H2 $(ID linking) Linking)

    It is straightforward to link C functions and libraries into D programs.
    But linking D functions and libraries into C programs is not straightforward.
    

    D programs generally require:

    $(NUMBERED_LIST
    * The D runtime library to be linked in, because many features of
    the core language require runtime library support.
    * The `main()` function to be written in D, to ensure that the required
    runtime library support is properly initialized.
    
)

    To link D functions and libraries into C programs, it's necessary to only
    require the C runtime library to be linked in. This is accomplished by defining
    a subset of D that fits this requirement, called $(B BetterC).
    

$(H2 $(ID better-c) Better C)

    $(WARNING $(B BetterC) is typically enabled by setting the $(TT -betterC)
    command line flag for the implementation.
    )

    When $(B BetterC) is enabled, the predefined
    $(LINK2 spec/version, Conditional Compilation) `D_BetterC`
    can be used for conditional compilation.
    


    An entire program can be written in $(B BetterC) by supplying a C `main()` function:

---
extern(C) void main()
{
    import core.stdc.stdio : printf;
    printf("Hello betterC\n");
}

---

$(CONSOLE > dmd -betterC hello.d &amp;&amp; ./hello
Hello betterC
)

    Limiting a program to this subset of runtime features is useful
    when targeting constrained environments where the use of such features
    is not practical or possible.
    

    $(B BetterC) makes embedding D libraries in existing larger projects easier by:
    

    $(NUMBERED_LIST
    * Simplifying the process of integration at the build-system level
    * Removing the need to ensure that Druntime is properly initialized on
    calls to the library, for situations when an initialization step is not
    performed or would be difficult to insert before the library is used.
    * Mixing memory management strategies (GC + manual memory management) can
    be tricky, hence removing D's GC from the equation may be worthwhile sometimes.
    
)

    Note: BetterC and $(LINK2 spec/importc, ImportC) are very different.
    ImportC is an actual C compiler. BetterC is a subset of D that relies only on the
    existence of the C Standard library.


$(H2 $(ID retained) Retained Features)

    Nearly the full language remains available. Highlights include:

    $(NUMBERED_LIST
    * Unrestricted use of compile-time features
    * Full metaprogramming facilities
    * Nested functions, nested structs, delegates and $(LINK2 spec/expression#function_literals,lambdas)
    * Member functions, constructors, destructors, operating overloading, etc.
    * The full module system
    * Array slicing, and array bounds checking
    * RAII (yes, it can work without exceptions)
    * `scope(exit)`
    * Memory safety protections
    * $(LINK2 spec/cpp_interface, Interfacing to C++)
    * COM classes and C++ classes
    * `assert` failures are directed to the C runtime library
    * `switch` with strings
    * `final switch`
    * `unittest`
    * $(LINK2 spec/interfaceToC#calling_printf,`printf` format validation)
    
)

$(H3 $(ID unittests) Running unittests in `-betterC`)

While testing can be done without the $(TT -betterC) flag, it is sometimes desirable to run the testsuite in `-betterC` too.
`unittest` blocks can be listed with the $(LINK2 spec/traits#getUnitTests,`getUnitTests`) trait:

---
unittest
{
   assert(0);
}

extern(C) void main()
{
    static foreach(u; __traits(getUnitTests, __traits(parent, main)))
        u();
}

---

$(CONSOLE > dmd -betterC -unittest -run test.d
dmd_runpezoXK: foo.d:3: Assertion `0' failed.
)

However, in `-betterC`, `assert` expressions don't use Druntime's assert and are directed to `assert` from the C runtime library instead.

$(H2 $(ID consequences) Unavailable Features)

    D features not available with $(B BetterC):

$(NUMBERED_LIST
    * Garbage Collection
    * TypeInfo and $(LINK2 spec/abi#ModuleInfo,$(TT ModuleInfo))
    * Classes
    * Built-in threading (e.g. [core.thread])
    * Dynamic arrays (though slices of static arrays and pointers work)
    * Associative arrays
    * Exceptions
    * `synchronized` and [core.sync]
    * Static module constructors or destructors

)


simd, Vector Extensions, importc, ImportC





Link_References:
	ACC = Associated C Compiler
+/
module betterc.dd;