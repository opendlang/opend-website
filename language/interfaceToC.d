// just docs: Interfacing to C
/++





        D is designed to fit comfortably with a C compiler for the target
        system. D makes up for not having its own VM by relying on the
        target environment's C runtime library. It would be senseless to
        attempt to port to D or write D wrappers for the vast array of C APIs
        available. How much easier it is to just call them directly.
        

        This is done by matching the C compiler's data types, layouts,
        and function call/return sequences.
        

$(H2 $(ID calling_c_functions) Calling C Functions)

        C functions can be called directly from D. There is no need for
        wrapper functions, argument swizzling, and the C functions do not
        need to be put into a separate DLL.
        

        The C function must be declared and given a calling convention,
        most likely the "C" calling convention, for example:
        

---
extern (C) int strcmp(const char* string1, const char* string2);

---

        and then it can be called within D code in the obvious way:

---
import std.string;
int myDfunction(char[] s)
{
    return strcmp(std.string.toStringz(s), "foo");
}

---

        There are several things going on here:

        $(LIST
        * D understands how C function names are "mangled" and the
        correct C function call/return sequence.

        * C functions cannot be overloaded with another C function
        with the same name.

        * There are no `__cdecl`, `__far`, `__stdcall`,
        $(LINK2         http://www.digitalmars.com/ctg/ctgLanguageImplementation.html#declspec,
        `__declspec`),
        or other such C
        $(LINK2 http://www.digitalmars.com/ctg/ctgLanguageImplementation.html#extended, extended type modifiers)
        in D. These are handled by
        $(LINK2 attribute.html#linkage, linkage attributes),
        such as `extern (C)`.

        * There is no volatile type modifier in D. To declare a C function that uses
        volatile, just drop the keyword from the declaration.

        * Strings are not 0 terminated in D. See "Data Type Compatibility"
        for more information about this. However, string literals in D are
        0 terminated.

        
)

        C code can correspondingly call D functions, if the D functions
        use an attribute that is compatible with the C compiler, most likely
        the extern (C):

---
// myfunc() can be called from any C function
extern (C)
{
    void myfunc(int a, int b)
    {
        ...
    }
}

---

$(H2 $(ID storage_allocation) Storage Allocation)

        C code explicitly manages memory with calls to
        $(LINK2 http://www.digitalmars.com/rtl/stdlib.html#malloc, malloc()) and
        $(LINK2 http://www.digitalmars.com/rtl/stdlib.html#free, free()).
        D allocates memory using the D garbage collector,
        so no explicit frees are necessary.
        

        D can still explicitly allocate memory using core.stdc.stdlib.malloc()
        and core.stdc.stdlib.free(), these are useful for connecting to C
        functions that expect malloc'd buffers, etc.
        

        If pointers to D garbage collector allocated memory are passed to
        C functions, it's critical to ensure that the memory will not be
        collected by the garbage collector before the C function is done with
        it. This is accomplished by:
        

        $(LIST

        * Making a copy of the data using core.stdc.stdlib.malloc() and passing
        the copy instead.

        * Leaving a pointer to it on the stack (as a parameter or
        automatic variable), as the garbage collector will scan the stack.

        * Leaving a pointer to it in the static data segment, as the
        garbage collector will scan the static data segment.

        * Registering the pointer with the garbage collector with the

        [phobos/core_memory.html#addRoot, std.gc.addRoot()]
        or

        [phobos/core_memory.html#addRange, std.gc.addRange()]
        calls.

        
)

        An interior pointer to the allocated memory block is sufficient
        to let the GC
        know the object is in use; i.e. it is not necessary to maintain
        a pointer to the beginning of the allocated memory.
        

        The garbage collector does not scan the stacks of threads not
        created by the D Thread interface. Nor does it scan the data
        segments of other DLLs, etc.
        

$(H2 $(ID data_type_compat) Data Type Compatibility)

        $(TABLE_ROWS
D And C Type Equivalence
    $(ELABORATE_HEADER )
        + -<td>`void`</td>
-$(RAW_HTML <td colspan="2">`void` </td>)
        + -<td>`byte`</td>
-$(RAW_HTML <td colspan="2">`signed char` </td>)
        + -<td>`ubyte`</td>
-$(RAW_HTML <td colspan="2">`unsigned char` </td>)
        + -<td>`char`</td>
-$(RAW_HTML <td colspan="2">`char` (chars are unsigned in D)</td>)
        + -<td>`wchar`</td>
-$(RAW_HTML <td colspan="2">`wchar_t` (when `sizeof(wchar_t)` is 2)</td>)
        + -<td>`dchar`</td>
-$(RAW_HTML <td colspan="2">`wchar_t` (when `sizeof(wchar_t)` is 4)</td>)
        + -<td>`short`</td>
-$(RAW_HTML <td colspan="2">`short` </td>)
        + -<td>`ushort`</td>
-$(RAW_HTML <td colspan="2">`unsigned short` </td>)
        + -<td>`int`</td>
-$(RAW_HTML <td colspan="2">`int` </td>)
        + -<td>`uint`</td>
-$(RAW_HTML <td colspan="2">`unsigned` </td>)

        + -<td>`core.stdc.config.c_long`</td>
-<td>`long`</td>
-<td>`long`</td>
        + -<td>`core.stdc.config.c_ulong`</td>
-<td>`unsigned long`</td>
-<td>`unsigned long`</td>
        + -<td>`core.stdc.stdint.intptr_t`</td>
-<td>`intptr_t`</td>
-<td>`intptr_t`</td>
        + -<td>`core.stdc.stdint.uintptr_t`</td>
-<td>`uintptr_t`</td>
-<td>`uintptr_t`</td>

        + -<td>`long`</td>
-<td>`long long`</td>
-<td>`long` (or `long long`)</td>
        + -<td>`ulong`</td>
-<td>`unsigned long long`</td>
-<td>`unsigned long` (or `unsigned long long`)</td>

        + -<td>`float`</td>
-$(RAW_HTML <td colspan="2">`float` </td>)
        + -<td>`double`</td>
-$(RAW_HTML <td colspan="2">`double` </td>)
        + -<td>`real`</td>
-$(RAW_HTML <td colspan="2">`long double` </td>)

        + -<td>`cdouble`</td>
-$(RAW_HTML <td colspan="2">`double _Complex` </td>)
        + -<td>`creal`</td>
-$(RAW_HTML <td colspan="2">`long double _Complex` </td>)
        + -<td>`struct`</td>
-$(RAW_HTML <td colspan="2">`struct` </td>)
        + -<td>`union`</td>
-$(RAW_HTML <td colspan="2">`union` </td>)
        + -<td>`enum`</td>
-$(RAW_HTML <td colspan="2">`enum` </td>)
        + -<td>`class`</td>
-$(RAW_HTML <td colspan="2">`` no equivalent</td>)
        + -<td>`type *`</td>
-$(RAW_HTML <td colspan="2">`type *` </td>)
        + -<td>`type[dim]`</td>
-$(RAW_HTML <td colspan="2">`type[dim]` </td>)
        + -<td>`type[dim]<em>, type()</em>[dim]`</td>
-$(RAW_HTML <td colspan="2">`type[dim]<em>, type()</em>[dim]` </td>)
        + -<td>`type[]`</td>
-$(RAW_HTML <td colspan="2">`` no equivalent</td>)
        + -<td>`type1[type2]`</td>
-$(RAW_HTML <td colspan="2">`` no equivalent</td>)
        + -<td>`type function(params)`</td>
-$(RAW_HTML <td colspan="2">`type(*)(params)` </td>)
        + -<td>`type delegate(params)`</td>
-$(RAW_HTML <td colspan="2">`` no equivalent</td>)
        + -<td>`size_t`</td>
-$(RAW_HTML <td colspan="2">`size_t` </td>)
        + -<td>`ptrdiff_t`</td>
-$(RAW_HTML <td colspan="2">`ptrdiff_t` </td>)
        
)

        These equivalents hold for most C compilers. The C standard
        does not pin down the sizes of the types, so some care is needed.
        

$(H2 $(ID passing_d_array) Passing D Array Arguments to C Functions)

        In C, arrays are passed to functions as pointers even if the function
        prototype says its an array. In D, static arrays are passed by value,
        not by reference. Thus, the function prototype must be adjusted to match
        what C expects.

        $(TABLE_ROWS
D And C Function Prototype Equivalence
        * + D type
+ C type

        * - $(I T)$(B *) 
- $(I T)$(B [])

        * - $(B ref) $(I T)$(B [)$(I dim)$(B ]) 
- $(I T)$(B [)$(I dim)$(B ])

)

        For example:

```c
void foo(int a[3]) { ... } // C code
```
---
extern (C)
{
    void foo(ref int[3] a); // D prototype
}

---


$(H2 $(ID calling_printf) Calling `printf()`)

        `printf` can be directly called from D code:
---
import core.stdc.stdio;

int main()
{
    printf("hello world\n");
    return 0;
}

---

        Printing values works as it does in C:
---
int apples;
printf("there are %d apples\n", apples);

---
        Correctly matching the format specifier to the D type is necessary.
        The D compiler recognizes the printf formats and diagnoses mismatches
        with the supplied arguments. The specification for the formats
        used by D is the C99 specification 7.19.6.1.
        

        A generous interpretation of what is a match between the argument
        and format specifier is taken, for example, an unsigned type can
        be printed with a signed format specifier. Diagnosed incompatibilites
        are:
        

        $(LIST
        * incompatible sizes which may cause argument misalignment
        * dereferencing arguments that are not pointers
        * insufficient number of arguments
        * struct, array and slice arguments are not allowed
        * non-pointer arguments to `s` specifier
        * non-Standard formats
        * undefined behavior per C99
        
)

$(H3 Strings)

        A string cannot be printed directly. But `%.*s` can be used:
        
---
string s = "betty";
printf("hello %.*s\n", cast(int) s.length, s.ptr);

---
        The cast to `int` is required.
        

$(H3 `size_t` and `ptrdiff_t`)

        These use the `zu` and `td` format specifiers respectively:
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
import core.stdc.stdio : printf;
int* p = new int, q = new int;
printf("size of an int is %zu, pointer difference is %td\n", int.sizeof, p - q);

---

)

$(H3 Non-Standard Format Specifiers)

        Non-Standard format specifiers will be rejected by the compiler.
        Since the checking is only done for formats as string literals,
        non-Standard ones can be used:
        
---
const char* format = "value: %K\n";
printf(format, value);

---

$(H3 Modern Formatted Writing)

        An improved D function for formatted output is
        `std.stdio.writef()`.
        

$(H2 $(ID structs_and_unions) Structs and Unions)

        D structs and unions are analogous to C's.
        

        C code often adjusts the alignment and packing of struct members
        with a command line switch or with various implementation specific
        #pragmas. D supports explicit alignment attributes that correspond
        to the C compiler's rules. Check what alignment the C code is using,
        and explicitly set it for the D struct declaration.
        

        D does not support bit fields. If needed, they can be emulated
        with shift and mask operations,
        or use the $(LINK2 phobos/std_bitmanip.html#bitfields, std.bitmanip.bitfields)
        library type.
        [htod.html, htod] will convert bit fields to inline
        functions that
        do the right shift and masks.
        

    D does not support declaring variables of anonymous struct types. In such a case, define a named struct in D and make it private:

```c
union Info  // C code
{
    struct
    {
        char *name;
    } file;
};

```
---
union Info  // D code
{
    private struct File
    {
        char* name;
    }
    File file;
}

---

$(H2 $(ID callbacks) Callbacks)

    D can easily call C callbacks (function pointers), and C can call
    callbacks provided by D code if the callback is an `extern(C)` function,
    or some other linkage that both sides have agreed to (e.g. `extern(Windows)`).

    Here's an example of C code providing a callback to D code:

```c
void someFunc(void *arg) { printf("Called someFunc!\n"); }  // C code
typedef void (*Callback)(void *);
extern "C" Callback getCallback(void)
{
    return someFunc;
}

```

---
extern(C) alias Callback = int function(int, int);  // D code
extern(C) Callback getCallback();
void main()
{
    Callback cb = getCallback();
    cb();  // invokes the callback
}

---

    And an example of D code providing a callback to C code:

```c
extern "C" void printer(int (*callback)(int, int))  // C code
{
    printf("calling callback with 2 and 4 returns: %d\n", callback(2, 4));
}

```

---
extern(C) alias Callback = int function(int, int);  // D code
extern(C) void printer(Callback callback);
extern(C) int sum(int x, int y) { return x + y; }
void main()
{
    printer(&amp;sum);
}

---

    For more info about callbacks read the $(LINK2 function.html#closures, closures) section.

$(H2 $(ID using-c-libraries)Using Existing C Libraries)

        Since D can call C code directly, it can also call any C library
        functions, giving D access to the smorgasbord of existing C libraries.
        To do so, however, one needs to write a D interface (.di) file, which
        is a translation of the C .h header file for the C library into D.
        

        For popular C libraries, the first place to look for the corresponding
        D interface file is the $(LINK2 https://github.com/D-Programming-Deimos/, Deimos Project).
        If it isn't there already, please write and contribute one
        to the Deimos Project.
        

$(H2 $(ID c-globals)Accessing C Globals)

        C globals can be accessed directly from D. C globals have the C naming
        convention, and so must be in an `extern (C)` block.
        Use the `extern` storage class to indicate that the global is allocated
        in the C code, not the D code.
        C globals default to being in global, not thread local, storage.
        To reference global storage
        from D, use the `__gshared` storage class.
        

---
extern (C) extern __gshared int x;

---

ddoc, Embedded Documentation, cpp_interface, Interfacing to C++




Link_References:
	ACC = Associated C Compiler
+/
module interfaceToC.dd;