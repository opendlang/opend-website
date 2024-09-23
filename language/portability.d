// just docs: Portability
/++





        It's good software engineering practice to minimize gratuitous
        portability problems in the code.
        Techniques to minimize potential portability problems are:
        

        $(LIST

        * The integral and floating type sizes should be considered as
        minimums.
        Algorithms should be designed to continue to work properly if the
        type size increases.

        * Floating point computations can be carried out at a higher
        precision than the size of the floating point variable can hold.
        Floating point algorithms should continue to work properly if
        precision is arbitrarily increased.

        * Avoid depending on the order of side effects in a computation
        that may get reordered by the compiler. For example:

---
a + b + c

---

        can be evaluated as (a + b) + c, a + (b + c), (a + c) + b, (c + b) + a,
        etc. Parentheses control operator precedence, parentheses do not
        control order of evaluation.
        

        If the operands of an associative operator + or * are floating
        point values, the expression is not reordered.
        
        

        * Avoid dependence on byte order; i.e. whether the CPU
        is big-endian or little-endian.

        * Avoid dependence on the size of a pointer or reference being
        the same size as a particular integral type.

        * If size dependencies are inevitable, put a `static assert` in
        the code to verify it:

---
static assert(int.sizeof == (int*).sizeof);

---
        
        
)

$(H2 $(ID 32_to_64bit) 32 to 64 Bit Portability)

        32 bit processors and operating systems are still out there.
        With that in mind:
        

        $(LIST

        * Integral types will remain the same sizes between
        32 and 64 bit code.

        * Pointers and object references will increase in size
        from 4 bytes to 8 bytes going from 32 to 64 bit code.

        * Use `size_t` as an alias for an unsigned integral
        type that can span the address space.
        Array indices should be of type `size_t`.

        * Use `ptrdiff_t` as an alias for a signed integral
        type that can span the address space.
        A type representing the difference between two pointers
        should be of type `ptrdiff_t`.

        * The `.length`, `.size`, `.sizeof`, `.offsetof`
        and `.alignof`
        properties will be of type `size_t`.

        
)

$(H2 $(ID endianness) Endianness)

        Endianness refers to the order in which multibyte types
        are stored. The two main orders are $(I big endian) and
        $(I little endian).
        The compiler predefines the version identifier
        `BigEndian` or `LittleEndian` depending on the order
        of the target system.
        The x86 systems are all little endian.
        

        The times when endianness matters are:

        $(LIST
        * When reading data from an external source (like a file)
        written in a different
        endian format.
        * When reading or writing individual bytes of a multibyte
        type like `long`s or `double`s.
        
)

$(H2 $(ID os_specific_code) OS Specific Code)

        System specific code is handled by isolating the differences into
        separate modules. At compile time, the correct system specific
        module is imported.
        

        Minor differences can be handled by constant defined in a system
        specific import, and then using that constant in an
        $(I IfStatement) or $(I StaticIfStatement).
        
objc_interface, Interfacing to Objective-C, entity, Named Character Entities




Link_References:
	ACC = Associated C Compiler
+/
module portability.dd;