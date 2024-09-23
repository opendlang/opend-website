// just docs: Memory-Safe-D-Spec
/++





    $(HTMLTAG3 img, src="images/dman-rain.jpg" align="right" alt="D-Man in rain" height="200")

        $(I Memory Safety) for a program is defined as it being
        impossible for the program to corrupt memory.
        Therefore, the safe subset of D consists only of programming
        language features that are guaranteed to never result in memory
        corruption. See $(LINK2 safed.html, this article) for a
        rationale.
        

        Memory-safe code $(LINK2 spec/function#function-safety,cannot
        use certain language features), such as:
                $(LIST
                        * Casts that break the type system.
                        * Modification of pointer values.
                        * Taking the address of a local variable or function parameter.
                
)

$(H2 $(ID usage) Usage)

        There are three categories of functions from the perspective of memory safety:
        $(LIST
                * $(LINK2 spec/function#safe-functions,`@safe`) functions
                * $(LINK2 spec/function#trusted-functions,`@trusted`) functions
                * $(LINK2 spec/function#system-functions,`@system`) functions
        
)

        `@system` functions may perform any operation legal from the perspective of the language,
        including inherently memory unsafe operations such as pointer casts or pointer arithmetic.
        However, compile-time known memory corrupting operations, such as indexing a static array
        out of bounds or returning a pointer to an expired stack frame, can still raise an error.
        `@system` functions may not be called directly from `@safe` functions.

        `@trusted` functions have all the capabilities of `@system` functions but may be called from
        `@safe` functions. For this reason they should be very limited in the scope of their use. Typical uses of
        `@trusted` functions include wrapping system calls that take buffer pointer and length arguments separately so that
        `@safe` functions may call them with arrays. `@trusted` functions must have a $(LINK2 spec/function#safe-interfaces,safe interface).

        `@safe` functions have a number of restrictions on what they may do and are intended to disallow operations that
        may cause memory corruption. See $(LINK2 spec/function#safe-functions,`@safe` functions).

        These attributes may be inferred when the compiler has the function body available, such as with templates.

        Array bounds checks are necessary to enforce memory safety, so
        these are enabled (by default) for `@safe` code even in $(B -release) mode.
        

    $(H3 $(ID scope-return-params) Scope and Return Parameters)

         The function parameter attributes `return` and `scope` are used to track what happens to low-level pointers
         passed to functions. Such pointers include: raw pointers, arrays, `this`, classes, `ref` parameters, delegate/lazy parameters,
         and aggregates containing a pointer.

         `scope` ensures that no references to the pointed-to object are retained, in global variables or pointers passed to the
         function (and recursively to other functions called in the function), as a result of calling the function.
         Variables in the function body and parameter list that are `scope` may have their allocations elided as a result.

         `return` indicates that either the return value of the function or the first parameter is a pointer derived from the
         `return` parameter or any other parameters also marked `return`.
         For constructors, `return` applies to the (implicitly returned) `this` reference.
         For void functions, `return` applies to the first parameter $(I iff) it is `ref`; this is to support UFCS,
         property setters and non-member functions (e.g. `put` used like `put(dest, source)`).

         These attributes may appear after the formal parameter list, in which case they apply either to a method's `this` parameter, or to
         a free function's first parameter $(I iff) it is `ref`.
         `return` or `scope` is ignored when applied to a type that is not a low-level pointer.

         $(B Note:) Checks for `scope` parameters are currently enabled
         only for `@safe` code compiled with the `-dip1000` command-line flag.


$(H2 $(ID limitations) Limitations)

        Memory safety does not imply that code is portable, uses only
        sound programming practices, is free of byte order dependencies,
        or other bugs. It is focussed only on eliminating memory corruption
        possibilities.
        

entity, Named Character Entities, abi, Application Binary Interface




Link_References:
	ACC = Associated C Compiler
+/
module memory-safe-d.dd;