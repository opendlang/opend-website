// just docs: Interfacing to C++
/++





    This document specifies how to interface with C++ directly.

    It is also possible to indirectly interface with C++ code, either
    through a $(LINK2 spec/interfaceToC, Interfacing to C) or a
    COM interface.

$(H2 $(ID general_idea) The General Idea)

    Being 100% compatible with C++ means more or less adding
    a fully functional C++ compiler front end to D.
    Anecdotal evidence suggests that writing such is a minimum
    of a 10 man-year project, essentially making a D compiler
    with such capability unimplementable.
    Other languages looking to hook up to C++ face the same
    problem, and the solutions have been:
    

    $(NUMBERED_LIST
    * Support the COM interface (but that only works for Windows).
    * Laboriously construct a C wrapper around
    the C++ code.
    * Use an automated tool such as SWIG to construct a
    C wrapper.
    * Reimplement the C++ code in the other language.
    * Give up.
    
)

    D takes a pragmatic approach that assumes a couple
    modest accommodations can solve a significant chunk of
    the problem:
    

    $(LIST
    * matching C++ name mangling conventions
    * matching C++ function calling conventions
    * matching C++ virtual function table layout for single inheritance
    
)

$(H2 $(ID global-functions) Global Functions)

    C++ global functions, including those in namespaces, can be declared
    and called in D, or defined in D and called in C++.

$(H3 $(ID calling_cpp_global_from_d) Calling C++ Global Functions from D)

    Given a C++ function in a C++ source file:

```cpp
#include <iostream>

using namespace std;

int foo(int i, int j, int k)
{
    cout &lt;&lt; "i = " &lt;&lt; i &lt;&lt; endl;
    cout &lt;&lt; "j = " &lt;&lt; j &lt;&lt; endl;
    cout &lt;&lt; "k = " &lt;&lt; k &lt;&lt; endl;

    return 7;
}

```

    In the corresponding D code, `foo`
    is declared as having C++ linkage and function calling conventions:
    

---
extern (C++) int foo(int i, int j, int k);

---

    and then it can be called within the D code:

---
extern (C++) int foo(int i, int j, int k);

void main()
{
    foo(1, 2, 3);
}

---

    Compiling the two files, the first with a C++ compiler,
    the second with a D compiler, linking them together,
    and then running it yields:

$(CONSOLE > g++ -c foo.cpp
> dmd bar.d foo.o -L-lstdc++ &amp;&amp; ./bar
i = 1
j = 2
k = 3
)

    There are several things going on here:

    $(LIST
    * D understands how C++ function names are "mangled" and the
    correct C++ function call/return sequence.

    * Because modules are not part of C++, each function with C++ linkage
    in the global namespace must be globally unique within the program.

    * There are no `__cdecl`, `__far`, `__stdcall`, `__declspec`, or other
    such nonstandard C++ extensions in D.

    * There are no volatile type modifiers in D.

    * Strings are not 0 terminated in D. See "Data Type Compatibility"
    for more information about this. However, string literals in D are
    0 terminated.

    
)

$(H3 $(ID calling_global_d_functions_from_cpp) Calling Global D Functions From C++)

    To make a D function accessible from C++, give it
    C++ linkage:

---
import std.stdio;

extern (C++) int foo(int i, int j, int k)
{
    writefln("i = %s", i);
    writefln("j = %s", j);
    writefln("k = %s", k);
    return 1;
}

extern (C++) void bar();

void main()
{
    bar();
}

---

    The C++ end looks like:

```cpp
int foo(int i, int j, int k);

void bar()
{
    foo(6, 7, 8);
}

```

    Compiling, linking, and running produces the output:

$(CONSOLE > dmd -c foo.d
> g++ bar.cpp foo.o -lphobos2 -pthread -o bar &amp;&amp; ./bar
i = 6
j = 7
k = 8
)

$(H2 $(ID cpp-namespaces) C++ Namespaces)

        C++ symbols that reside in namespaces can be
        accessed from D. A $(LINK2 attribute.html#namespace, namespace)
        can be added to the `extern (C++)`
        $(LINK2 attribute.html#linkage, LinkageAttribute):
    
---
extern (C++, N) int foo(int i, int j, int k);

void main()
{
    N.foo(1, 2, 3);   // foo is in C++ namespace 'N'
}

---

    C++ can open the same namespace in the same file and multiple files.
      In D, this can be done as follows:

---
module ns;
extern (C++, `ns`)
{
    int foo() { return 1; }
}

---
    Any expression that resolves to either a tuple of strings or an empty tuple is accepted.
      When the expression resolves to an empty tuple, it is equivalent to `extern (C++)`
---
extern(C++, (expression))
{
    int bar() { return 2; }
}

---

or in multiple files, by organizing them in a package consisting of several modules:
---
ns/
|-- a.d
|-- b.d
|-- package.d

---

File `ns/a.d`:
---
module a; extern (C++, `ns`) { int foo() { return 1; } }

---

File `ns/b.d`:
---
module b; extern (C++, `ns`) { int bar() { return 2; } }

---

File `ns/package.d`:
---
module ns;
public import a, b;

---
Then import the package containing the extern C++ declarations as follows:

---
import ns;
static assert(foo() == 1 &amp;&amp; bar() == 2);

---

Note that the `extern (C++, `ns`)` linkage attribute affects only the ABI (name mangling and calling convention) of
  these declarations. Importing them follows the usual
  $(LINK2 spec/module, D module import semantics).

Alternatively, the non-string form can be used to introduce a scope. Note that the
    enclosing module already provides a scope for the symbols declared in the namespace.
    This form does not allow closing and reopening the same namespace with in the same module. That is:
---
module a; extern (C++, ns1) { int foo() { return 1; } }

---
---
module b; extern (C++, ns1) { int bar() { return 2; } }

---
---
import a, b;
static assert(foo() == 1 &amp;&amp; bar() == 2);

---
   works, but:
---
extern (C++, ns1) { int foo() { return 1; } }
extern (C++, ns1) { int bar() { return 2; } }

---
   does not. Additionally, aliases can be used to avoid collision of symbols:
---
module a; extern (C++, ns) { int foo() { return 1; } }

---
---
module b; extern (C++, ns) { int bar() { return 2; } }

---
---
module ns;
import a, b;
alias foo = a.ns.foo;
alias bar = b.ns.bar;

---
---
import ns;
static assert(foo() == 1 &amp;&amp; bar() == 2);

---

$(H2 $(ID classes) Classes)

    C++ classes can be declared in D by using the `extern (C++)`
    attribute on `class`, `struct` and `interface`
    declarations. `extern (C++)` interfaces have the same restrictions as
    D interfaces, which means that Multiple Inheritance is supported to the
    extent that only one base class can have member fields.

    `extern (C++)` structs do not support virtual functions but can
    be used to map C++ value types.

    Unlike classes and interfaces with D linkage, `extern (C++)`
    classes and interfaces are not rooted in `Object` and cannot be used
    with `typeid`.

    D structs and classes have different semantics whereas C++ structs and
    classes are basically the same. The use of a D struct or class depends on
    the C++ implementation and not on the used C++ keyword.
    When mapping a D `class` onto a C++ `struct`,
    use `extern(C++, struct)` to avoid linking problems with C++ compilers
    (notably MSVC) that distinguish between C++'s `class` and `struct`
    when mangling. Conversely, use `extern(C++, class)` to map a D
    `struct` onto a C++ `class`.

    `extern(C++, class)` and `extern(C++, struct)` can be combined
    with C++ namespaces:
---
extern (C++, struct) extern (C++, foo)
class Bar
{
}

---

$(H3 $(ID using_cpp_classes_from_d) Using C++ Classes From D)

    The following example shows binding of a pure virtual function, its
    implementation in a derived class, a non-virtual member function, and a
    member field:

```cpp
#include <iostream>

using namespace std;

class Base
{
    public:
        virtual void print3i(int a, int b, int c) = 0;
};

class Derived : public Base
{
    public:
        int field;
        Derived(int field) : field(field) {}

        void print3i(int a, int b, int c)
        {
            cout &lt;&lt; "a = " &lt;&lt; a &lt;&lt; endl;
            cout &lt;&lt; "b = " &lt;&lt; b &lt;&lt; endl;
            cout &lt;&lt; "c = " &lt;&lt; c &lt;&lt; endl;
        }

        int mul(int factor);
};

int Derived::mul(int factor)
{
    return field * factor;
}

Derived *createInstance(int i)
{
    return new Derived(i);
}

void deleteInstance(Derived *&d)
{
    delete d;
    d = 0;
}

```

    We can use it in D code like:

---
extern(C++)
{
    abstract class Base
    {
        void print3i(int a, int b, int c);
    }

    class Derived : Base
    {
        int field;
        @disable this();
        override void print3i(int a, int b, int c);
        final int mul(int factor);
    }

    Derived createInstance(int i);
    void deleteInstance(ref Derived d);
}

void main()
{
    import std.stdio;

    auto d1 = createInstance(5);
    writeln(d1.field);
    writeln(d1.mul(4));

    Base b1 = d1;
    b1.print3i(1, 2, 3);

    deleteInstance(d1);
    assert(d1 is null);

    auto d2 = createInstance(42);
    writeln(d2.field);

    deleteInstance(d2);
    assert(d2 is null);
}

---

Compiling, linking, and running produces the output:

$(CONSOLE > g++ base.cpp
> dmd main.d base.o -L-lstdc++ &amp;&amp; ./main
5
20
a = 1
b = 2
c = 3
42
)

Note how in the above example, the constructor is not bindable and is
instead disabled on the D side; an alternative would be to reimplement the
constructor in D. See the $(LINK2 spec/cpp_interface#lifetime-management,section below on lifetime management) for more information.

$(H3 $(ID using_d_classes_from_cpp) Using D Classes From C++)

    Given D code like:

---
extern (C++) int callE(E);

extern (C++) interface E
{
    int bar(int i, int j, int k);
}

class F : E
{
    extern (C++) int bar(int i, int j, int k)
    {
        import std.stdio : writefln;
        writefln("i = %s", i);
        writefln("j = %s", j);
        writefln("k = %s", k);
        return 8;
    }
}

void main()
{
    F f = new F();
    callE(f);
}

---

    The C++ code to access it looks like:

```cpp
class E
{
  public:
    virtual int bar(int i, int j, int k);
};


int callE(E *e)
{
    return e-&gt;bar(11, 12, 13);
}

```

$(CONSOLE > dmd -c base.d
> g++ klass.cpp base.o -lphobos2 -pthread -o klass &amp;&amp; ./klass
i = 11
j = 12
k = 13
)


$(H2 $(ID structs) Structs)

    C++ allows a struct to inherit from a base struct. This is done in D using
    `alias this`:

---
struct Base { ... members ... };

struct Derived
{
    Base base;       // make it the first field
    alias base this;

    ... members ...
}

---

    In both C++ and D, if a struct has zero fields, the struct still has a
    size of 1 byte. But, in C++ if the struct with zero fields is used as a base
    struct, its size is zero (called the
    $(LINK2 https://en.cppreference.com/w/cpp/language/ebo, Empty Base Optimization)).
    There are two methods for emulating this behavior in D.
    The first forwards references to a function returning a faked reference to the base:

---
struct Base { ... members ... };

struct DerivedStruct
{
    static if (Base.tupleof.length &gt; 0)
        Base base;
    else
        ref inout(Base) base() inout
        {
            return *cast(inout(Base)*)&amp;this;
        }
    alias base this;

    ... members ...
}

---

    The second makes use of template mixins:

---
mixin template BaseMembers()
{
    void memberFunction() { ... }
}

struct Base
{
    mixin BaseMembers!();
}

struct Derived
{
    mixin BaseMembers!();

    ... members ...
}

---

    Note that the template mixin is evaluated in the context of its
    instantiation, not declaration. If this is a problem, the template mixin
    can use local imports, or have the member functions forward to the
    actual functions.


$(H2 $(ID cpp-templates) C++ Templates)

    C++ function and type templates can be bound by using the
    `extern (C++)` attribute on a function or type template declaration.

    Note that all instantiations used in D code must be provided by linking
    to C++ object code or shared libraries containing the instantiations.

    For example:

```cpp
#include <iostream>

template<class T>
struct Foo
{
    private:
    T field;

    public:
    Foo(T t) : field(t) {}
    T get();
    void set(T t);
};

template<class T>
T Foo<T>::get()
{
    return field;
}

template<class T>
void Foo<T>::set(T t)
{
    field = t;
}

Foo<int> makeIntFoo(int i)
{
    return Foo<int>(i);
}

Foo<char> makeCharFoo(char c)
{
    return Foo<char>(c);
}

template<class T>
void increment(Foo<T> &foo)
{
    foo.set(foo.get() + 1);
}

template<class T>
void printThreeNext(Foo<T> foo)
{
    for(size_t i = 0; i < 3; ++i)
    {
        std::cout << foo.get() << std::endl;
        increment(foo);
    }
}

// The following two functions ensure that the required instantiations of
// printThreeNext are provided by this code module
void printThreeNexti(Foo<int> foo)
{
    printThreeNext(foo);
}

void printThreeNextc(Foo<char> foo)
{
    printThreeNext(foo);
}

```

---
extern(C++):
struct Foo(T)
{
    private:
    T field;

    public:
    @disable this();
    T get();
    void set(T t);
}

Foo!int makeIntFoo(int i);
Foo!char makeCharFoo(char c);
void increment(T)(ref Foo!T foo);
void printThreeNext(T)(Foo!T foo);

extern(D) void main()
{
    auto i = makeIntFoo(42);
    assert(i.get() == 42);
    i.set(1);
    increment(i);
    assert(i.get() == 2);

    auto c = makeCharFoo('a');
    increment(c);
    assert(c.get() == 'b');

    c.set('A');
    printThreeNext(c);
}

---

Compiling, linking, and running produces the output:

$(CONSOLE > g++ -c template.cpp
> dmd main.d template.o -L-lstdc++ &amp;&amp; ./main
A
B
C
)

$(H2 $(ID function-overloading) Function Overloading)

    C++ and D follow different rules for function overloading.
    D source code, even when calling `extern (C++)` functions,
    will still follow D overloading rules.
    

$(H2 $(ID memory-allocation) Memory Allocation)

    C++ code explicitly manages memory with calls to
    `::operator new()` and `::operator delete()`.
    D's `new` operator allocates memory using the D garbage collector,
    so no explicit delete is necessary. D's `new` operator is not
    compatible with C++'s `::operator new` and `::operator delete`.
    Attempting to allocate memory with D's `new` and deallocate with
    C++ `::operator delete` will result in miserable failure.
    

    D can explicitly manage memory using a variety of library tools, such as
    with [std.experimental]. Additionally,
    `core.stdc.stdlib.malloc` and `core.stdc.stdlib.free` can be
    used directly for connecting to C++ functions that expect `malloc`'d
    buffers.
    

    If pointers to memory allocated on the D garbage collector heap are
    passed to C++ functions, it's critical to ensure that the referenced memory
    will not be collected by the D garbage collector before the C++ function is
    done with it. This is accomplished by:
    

    $(LIST

    * Making a copy of the data using
    [std.experimental] or `core.stdc.stdlib.malloc`
    and passing the copy instead.

    * Leaving a pointer to it on the stack (as a parameter or
    automatic variable), as the garbage collector will scan the stack.

    * Leaving a pointer to it in the static data segment, as the
    garbage collector will scan the static data segment.

    * Registering the pointer with the garbage collector using the
    `core.memory.GC.addRoot` or `core.memory.GC.addRange`
    functions.

    
)

    An interior pointer to the allocated memory block is sufficient to let
    the GC know the object is in use; i.e. it is not necessary to maintain
    a pointer to the $(I beginning) of the allocated memory.
    

    The garbage collector does not scan the stacks of threads not
    registered with the D runtime, nor does it scan the data segments of
    shared libraries that aren't registered with the D runtime.
    

$(H2 $(ID data-type-compatibility) Data Type Compatibility)

    $(TABLE_ROWS
D And C++ Type Equivalence

    * + D type
+ C++ type


    * -     $(B void)
-     $(B void)
    


    * -     $(B byte)
-     $(B signed char)
    


    * -     $(B ubyte)
-     $(B unsigned char)
    


    * -     $(B char)
-     $(B char) (chars are unsigned in D)
    


    * -     `core.stdc.stddef.wchar_t`
-     `wchar_t`
    


    * -     $(B short)
-     $(B short)
    


    * -     $(B ushort)
-     $(B unsigned short)
    


    * -     $(B int)
-     $(B int)
    


    * -     $(B uint)
-     $(B unsigned)
    


    * -     $(B long)
-     $(B long) if it is 64 bits wide, otherwise $(B long long)
    


    * -     $(B ulong)
-     $(B unsigned long) if it is 64 bits wide, otherwise $(B unsigned long long)
    


    * -     `core.stdc.config.cpp_long`
-     $(B long)
    


    * -     `core.stdc.config.cpp_ulong`
-     $(B unsigned long)
    


    * -     $(B float)
-     $(B float)
    


    * -     $(B double)
-     $(B double)
    


    * -     $(B real)
-     $(B long double)
    


    * -     `extern (C++)` $(B struct)
-     $(B struct) or $(B class)
    


    * -     `extern (C++)` $(B class)
-     $(B struct) or $(B class)
    


    * -     `extern (C++)` $(B interface)
-     $(B struct) or $(B class) with no member fields
    


    * -     $(B union)
-     $(B union)
    


    * -     $(B enum)
-     $(B enum)
    


    * -     $(I type)$(B *)
-     $(I type) $(B *)
    


    * -     $(B ref) $(I type) (in parameter lists only)
-     $(I type) &
    


    * -     $(I type)$(B [)$(I dim)$(B ])
-     $(I type)$(B [)$(I dim)$(B ]) for a variable/field declaration,
    or $(LINK2 spec/interfaceToC#passing_d_array,use `ref` for function parameter)
    


    * -     $(I type)$(B [)$(I dim)$(B ]*)
-     $(I type)$(B (*)[)$(I dim)$(B ])
    


    * -     $(I type)$(B [])
-     no `extern (C++)` equivalent, [#dynamic-arrays|see below]
    


    * -     $(I type)$(B [)$(I type)$(B ])
-     no equivalent
    


    * -     $(I type) $(B function)$(B ()$(I parameters)$(B ))
-     $(I type)$(B (*))$(B ()$(I parameters)$(B ))
    


    * -     $(I type) $(B delegate)$(B ()$(I parameters)$(B ))
-     no equivalent
    

    
)

    These equivalents hold when the D and C++ compilers used are companions
    on the host platform.

$(H3 $(ID dynamic-arrays) Dynamic Arrays)

    These are not supported for `extern (C++)`. For `extern (C)`, they
    are equivalent to a struct template. For example:

---
extern (C) const(char)[] slice;

---

    `dmd -HC` generates the following C++ declaration:

---
extern "C" _d_dynamicArray&lt; const char &gt; slice;

---
    `_d_dynamicArray` is generated as follows:

---
/// Represents a D [] array
template&lt;typename T&gt;
struct _d_dynamicArray final
{
    size_t length;
    T *ptr;

    _d_dynamicArray() : length(0), ptr(NULL) { }

    _d_dynamicArray(size_t length_in, T *ptr_in)
        : length(length_in), ptr(ptr_in) { }

    T&amp; operator[](const size_t idx) {
        assert(idx &lt; length);
        return ptr[idx];
    }

    const T&amp; operator[](const size_t idx) const {
        assert(idx &lt; length);
        return ptr[idx];
    }
};

---


$(H2 $(ID packing-and-alignment) Packing and Alignment)

    D structs and unions are analogous to C's.
    

    C code often adjusts the alignment and packing of struct members
    with a command line switch or with various implementation specific
    #pragmas. D supports explicit alignment attributes that correspond
    to the C compiler's rules. Check what alignment the C code is using,
    and explicitly set it for the D struct declaration.
    

    D supports bitfields in the standard library: see
    $(REF bitfields, std, bitmanip).
    

$(H2 $(ID lifetime-management) Lifetime Management)

    C++ constructors, copy constructors, move constructors and destructors
    cannot be called directly in D code, and D constructors, postblit operators
    and destructors cannot be directly exported to C++ code. Interoperation of
    types with these special operators is possible by either 1)
    disabling the operator in the client language and only using it in the host
    language, or 2) faithfully reimplementing the operator in the
    client language. With the latter approach, care needs to be taken to ensure
    observable semantics remain the same with both implementations, which can be
    difficult, or in some edge cases impossible, due to differences in how the
    operators work in the two languages. For example, in D all objects are
    movable and there is no move constructor.

$(H2 $(ID special-member-functions) Special Member Functions)

    D cannot directly call C++ special member functions, and vice versa.
    These include constructors, destructors, conversion operators,
    operator overloading, and allocators.
    

$(H2 $(ID rtti) Runtime Type Identification)

    D runtime type identification
    uses completely different techniques than C++.
    The two are incompatible.

$(H2 $(ID exception-handling) Exception Handling)

    Exception interoperability is a work in progress.

    At present, C++ exceptions cannot be caught in or thrown from D, and D
    exceptions cannot be caught in or thrown from C++. Additionally, objects
    in C++ stack frames are not guaranteed to be destroyed when unwinding the
    stack due to a D exception, and vice versa.

    The plan is to support all of the above except throwing D exceptions
    directly in C++ code (but they will be throwable indirectly by calling into
    a D function with C++ linkage).

$(H3 $(ID comparing-d-immutable-and-const-with-cpp-const) Comparing D Immutable and Const with C++ Const)

$(TABLE_ROWS
Const, Immutable Comparison
   * + Feature
+ D
+ C++98

    * - `const` keyword
- Yes
- Yes

    * - `immutable` keyword
- Yes
- No

    * - const notation
- ---
// Functional:
//ptr to const ptr to const int
const(int*)* p;

---

- ```cpp
// Postfix:
//ptr to const ptr to const int
const int *const *p;

```
    


    * - transitive const
- ---
// Yes:
//const ptr to const ptr to const int
const int** p;
**p = 3; // error

---

- ```cpp
// No:
// const ptr to ptr to int
int** const p;
**p = 3;    // ok

```
    


    * - cast away const
- ---
// Yes:
// ptr to const int
const(int)* p;
int* q = cast(int*)p; // ok

---

- ```cpp
// Yes:
// ptr to const int
const int* p;
int* q = const_cast<int*>p; //ok

```
    


    * - cast+mutate
- ---
// No:
// ptr to const int
const(int)* p;
int* q = cast(int*)p;
*q = 3;   // undefined behavior

---

- ```cpp
// Yes:
// ptr to const int
const int* p;
int* q = const_cast<int*>p;
*q = 3;   // ok

```
    


    * - overloading
- ---
// Yes:
void foo(int x);
void foo(const int x);  //ok

---

- ```cpp
// No:
void foo(int x);
void foo(const int x);  //error

```
    


    * - const/mutable aliasing
- ---
// Yes:
void foo(const int* x, int* y)
{
    bar(*x); // bar(3)
    *y = 4;
    bar(*x); // bar(4)
}
...
int i = 3;
foo(&amp;i, &amp;i);

---

- ```cpp
// Yes:
void foo(const int* x, int* y)
{
    bar(*x); // bar(3)
    *y = 4;
    bar(*x); // bar(4)
}
...
int i = 3;
foo(&i, &i);

```
    


    * - immutable/mutable aliasing
- ---
// No:
void foo(immutable int* x, int* y)
{
    bar(*x); // bar(3)
    *y = 4;  // undefined behavior
    bar(*x); // bar(??)
}
...
int i = 3;
foo(cast(immutable)&amp;i, &amp;i);

---

-     No immutables
    


    * - type of string literal
-     `immutable(char)[]`
-     `const char*`
    



    * - string literal to non-const
-     not allowed
-     allowed, but deprecated
    


)


interfaceToC, Interfacing to C, objc_interface, Interfacing to Objective-C




Link_References:
	ACC = Associated C Compiler
+/
module cpp_interface.dd;