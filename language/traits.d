// just docs: Traits
/++





$(H2 $(ID grammar) Grammar)

        Traits are extensions to the language to enable
        programs, at compile time, to get at information
        internal to the compiler. This is also known as
        compile time reflection.
        It is done as a special, easily extended syntax (similar
        to Pragmas) so that new capabilities can be added
        as required.
        

$(PRE $(CLASS GRAMMAR)
$(B $(ID TraitsExpression) TraitsExpression):
    `__traits` `(` [#TraitsKeyword|TraitsKeyword] `,` [#TraitsArguments|TraitsArguments] `)`

$(B $(ID TraitsKeyword) TraitsKeyword):
    [#isAbstractClass|`isAbstractClass`]
    [#isArithmetic|`isArithmetic`]
    [#isAssociativeArray|`isAssociativeArray`]
    [#isFinalClass|`isFinalClass`]
    [#isPOD|`isPOD`]
    [#isNested|`isNested`]
    [#isFuture|`isFuture`]
    [#isDeprecated|`isDeprecated`]
    [#isFloating|`isFloating`]
    [#isIntegral|`isIntegral`]
    [#isScalar|`isScalar`]
    [#isStaticArray|`isStaticArray`]
    [#isUnsigned|`isUnsigned`]
    [#isDisabled|`isDisabled`]
    [#isVirtualFunction|`isVirtualFunction`]
    [#isVirtualMethod|`isVirtualMethod`]
    [#isAbstractFunction|`isAbstractFunction`]
    [#isFinalFunction|`isFinalFunction`]
    [#isStaticFunction|`isStaticFunction`]
    [#isOverrideFunction|`isOverrideFunction`]
    [#isTemplate|`isTemplate`]
    [#isRef|`isRef`]
    [#isOut|`isOut`]
    [#isLazy|`isLazy`]
    [#isReturnOnStack|`isReturnOnStack`]
    [#isCopyable|`isCopyable`]
    [#isZeroInit|`isZeroInit`]
    [#isModule|`isModule`]
    [#isPackage|`isPackage`]
    [#hasMember|`hasMember`]
    [#hasCopyConstructor|`hasCopyConstructor`]
    [#hasPostblit|`hasPostblit`]
    [#identifier|`identifier`]
    [#getAliasThis|`getAliasThis`]
    [#getAttributes|`getAttributes`]
    [#getFunctionAttributes|`getFunctionAttributes`]
    [#getFunctionVariadicStyle|`getFunctionVariadicStyle`]
    [#getLinkage|`getLinkage`]
    [#getLocation|`getLocation`]
    [#getMember|`getMember`]
    [#getOverloads|`getOverloads`]
    [#getParameterStorageClasses|`getParameterStorageClasses`]
    [#getPointerBitmap|`getPointerBitmap`]
    [#getCppNamespaces|`getCppNamespaces`]
    [#getVisibility|`getVisibility`]
    [#getProtection|`getProtection`]
    [#getTargetInfo|`getTargetInfo`]
    [#getVirtualFunctions|`getVirtualFunctions`]
    [#getVirtualMethods|`getVirtualMethods`]
    [#getUnitTests|`getUnitTests`]
    [#parent|`parent`]
    [#child|`child`]
    [#classInstanceSize|`classInstanceSize`]
    [#classInstanceAlignment|`classInstanceAlignment`]
    [#getVirtualIndex|`getVirtualIndex`]
    [#allMembers|`allMembers`]
    [#derivedMembers|`derivedMembers`]
    [#isSame|`isSame`]
    [#compiles|`compiles`]
    [#toType|`toType`]
    [#initSymbol|`initSymbol`]
    [#parameters|`parameters`]

$(B $(ID TraitsArguments) TraitsArguments):
    [#TraitsArgument|TraitsArgument]
    [#TraitsArgument|TraitsArgument] `,` TraitsArguments

$(B $(ID TraitsArgument) TraitsArgument):
    [expression#AssignExpression|expression, AssignExpression]
    [type#Type|type, Type]

)


$(H2 $(ID types) Type Traits)

$(H3 $(B $(ID isArithmetic) isArithmetic))

        If the arguments are all either types that are arithmetic types,
        or expressions that are typed as arithmetic types, then `true`
        is returned.
        Otherwise, `false` is returned.
        If there are no arguments, `false` is returned.

        Arithmetic types are integral types and floating point types.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
import std.stdio;

void main()
{
    int i;
    writeln(__traits(isArithmetic, int));
    writeln(__traits(isArithmetic, i, i+1, int));
    writeln(__traits(isArithmetic));
    writeln(__traits(isArithmetic, int*));
}

---

)

        Prints:

$(CONSOLE true
true
false
false
)

$(H3 $(B $(ID isFloating) isFloating))

        If the arguments are all either types that are floating point types,
        or expressions that are typed as floating point types, then `true`
        is returned.
        Otherwise, `false` is returned.
        If there are no arguments, `false` is returned.

        The floating point types are:
        `float`, `double`, `real`,
        `ifloat`, `idouble`, `ireal`,
        `cfloat`, `cdouble`, `creal`,
        vectors of floating point types, and enums with a floating point base type.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
import core.simd : float4;

enum E : float { a, b }

static assert(__traits(isFloating, float));
static assert(__traits(isFloating, E));
static assert(__traits(isFloating, float4));

static assert(!__traits(isFloating, float[4]));

---

)

$(H3 $(B $(ID isIntegral) isIntegral))

        If the arguments are all either types that are integral types,
        or expressions that are typed as integral types, then `true`
        is returned.
        Otherwise, `false` is returned.
        If there are no arguments, `false` is returned.

        The integral types are:
        `byte`, `ubyte`, `short`, `ushort`, `int`, `uint`, `long`, `ulong`, `cent`, `ucent`,
        `bool`, `char`, `wchar`, `dchar`,
        vectors of integral types, and enums with an integral base type.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
import core.simd : int4;

enum E { a, b }

static assert(__traits(isIntegral, bool));
static assert(__traits(isIntegral, char));
static assert(__traits(isIntegral, int));
static assert(__traits(isIntegral, E));
static assert(__traits(isIntegral, int4));

static assert(!__traits(isIntegral, float));
static assert(!__traits(isIntegral, int[4]));
static assert(!__traits(isIntegral, void*));

---

)

$(H3 $(B $(ID isScalar) isScalar))

        If the arguments are all either types that are scalar types,
        or expressions that are typed as scalar types, then `true`
        is returned.
        Otherwise, `false` is returned.
        If there are no arguments, `false` is returned.

        Scalar types are integral types,
        floating point types,
        pointer types,
        vectors of scalar types,
        and enums with a scalar base type.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
import core.simd : int4, void16;

enum E { a, b }

static assert(__traits(isScalar, bool));
static assert(__traits(isScalar, char));
static assert(__traits(isScalar, int));
static assert(__traits(isScalar, float));
static assert(__traits(isScalar, E));
static assert(__traits(isScalar, int4));
static assert(__traits(isScalar, void*)); // Includes pointers!

static assert(!__traits(isScalar, int[4]));
static assert(!__traits(isScalar, void16));
static assert(!__traits(isScalar, void));
static assert(!__traits(isScalar, typeof(null)));
static assert(!__traits(isScalar, Object));

---

)

$(H3 $(B $(ID isUnsigned) isUnsigned))

        If the arguments are all either types that are unsigned types,
        or expressions that are typed as unsigned types, then `true`
        is returned.
        Otherwise, `false` is returned.
        If there are no arguments, `false` is returned.

        The unsigned types are:
        `ubyte`, `ushort`, `uint`, `ulong`, `ucent`,
        `bool`, `char`, `wchar`, `dchar`,
        vectors of unsigned types, and enums with an unsigned base type.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
import core.simd : uint4;

enum SignedEnum { a, b }
enum UnsignedEnum : uint { a, b }

static assert(__traits(isUnsigned, bool));
static assert(__traits(isUnsigned, char));
static assert(__traits(isUnsigned, uint));
static assert(__traits(isUnsigned, UnsignedEnum));
static assert(__traits(isUnsigned, uint4));

static assert(!__traits(isUnsigned, int));
static assert(!__traits(isUnsigned, float));
static assert(!__traits(isUnsigned, SignedEnum));
static assert(!__traits(isUnsigned, uint[4]));
static assert(!__traits(isUnsigned, void*));

---

)

$(H3 $(B $(ID isStaticArray) isStaticArray))

        Works like `isArithmetic`, except it's for static array
        types.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
import core.simd : int4;

enum E : int[4] { a = [1, 2, 3, 4] }

static array = [1, 2, 3]; // Not a static array: the type is inferred as int[] not int[3].

static assert(__traits(isStaticArray, void[0]));
static assert(__traits(isStaticArray, E));
static assert(!__traits(isStaticArray, int4));
static assert(!__traits(isStaticArray, array));

---

)

$(H3 $(B $(ID isAssociativeArray) isAssociativeArray))

        Works like `isArithmetic`, except it's for associative array
        types.

$(H3 $(B $(ID isAbstractClass) isAbstractClass))

        If the arguments are all either types that are abstract classes,
        or expressions that are typed as abstract classes, then `true`
        is returned.
        Otherwise, `false` is returned.
        If there are no arguments, `false` is returned.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
import std.stdio;

abstract class C { int foo(); }

void main()
{
    C c;
    writeln(__traits(isAbstractClass, C));
    writeln(__traits(isAbstractClass, c, C));
    writeln(__traits(isAbstractClass));
    writeln(__traits(isAbstractClass, int*));
}

---

)

        Prints:

$(CONSOLE true
true
false
false
)

$(H3 $(B $(ID isFinalClass) isFinalClass))

        Works like `isAbstractClass`, except it's for final
        classes.

$(H3 $(B $(ID isCopyable) isCopyable))

Takes one argument. If that argument is a copyable type then `true` is returned,
otherwise `false`.


$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
struct S
{
}
static assert( __traits(isCopyable, S));

struct T
{
    @disable this(this); // disable copy construction
}
static assert(!__traits(isCopyable, T));

---

)

$(H3 $(B $(ID isPOD) isPOD))

        Takes one argument, which must be a type. It returns
        `true` if the type is a $(LINK2 spec/glossary#pod,POD) type, otherwise `false`.

$(H3 $(B $(ID toType) toType))

        Takes a single argument, which must evaluate to an expression of type `string`.
        The contents of the string must correspond to the $(LINK2 spec/abi#name_mangling,mangled contents of a type)
        that has been seen by the implementation.

        Only D mangling is supported. Other manglings, such as C++ mangling, are not.

        The value returned is a type.

---
template Type(T) { alias Type = T; }

Type!(__traits(toType, "i")) j = 3; // j is declared as type `int`

static assert(is(Type!(__traits(toType, (int*).mangleof)) == int*));

__traits(toType, "i") x = 4; // x is also declared as type `int`

---

        Rationale: Provides the inverse operation of the $(LINK2 spec/property#mangleof,`.mangleof`) property.

$(H3 $(B $(ID isZeroInit) isZeroInit))

        Takes one argument which must be a type. If the type's
        $(LINK2 spec/property#init,default initializer) is all zero
        bits then `true` is returned, otherwise `false`.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
struct S1 { int x; }
struct S2 { int x = -1; }

static assert(__traits(isZeroInit, S1));
static assert(!__traits(isZeroInit, S2));

void test()
{
    int x = 3;
    static assert(__traits(isZeroInit, typeof(x)));
}

// `isZeroInit` will always return true for a class C
// because `C.init` is null reference.

class C { int x = -1; }

static assert(__traits(isZeroInit, C));

// For initializing arrays of element type `void`.
static assert(__traits(isZeroInit, void));

---

)

$(H3 $(B $(ID hasCopyConstructor) hasCopyConstructor))

        The argument is a type. If it is a struct with a copy constructor, returns `true`. Otherwise, return `false`. Note that a copy constructor is distinct from a postblit.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---

import std.stdio;

struct S
{
}

class C
{
}

struct P
{
    this(ref P rhs) {}
}

struct B
{
    this(this) {}
}

void main()
{
    writeln(__traits(hasCopyConstructor, S)); // false
    writeln(__traits(hasCopyConstructor, C)); // false
    writeln(__traits(hasCopyConstructor, P)); // true
    writeln(__traits(hasCopyConstructor, B)); // false, this is a postblit
}

---

)

$(H3 $(B $(ID hasPostblit) hasPostblit))

        The argument is a type. If it is a struct with a postblit, returns `true`. Otherwise, return `false`. Note a postblit is distinct from a copy constructor.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---

import std.stdio;

struct S
{
}

class C
{
}

struct P
{
    this(ref P rhs) {}
}

struct B
{
    this(this) {}
}


void main()
{
    writeln(__traits(hasPostblit, S)); // false
    writeln(__traits(hasPostblit, C)); // false
    writeln(__traits(hasPostblit, P)); // false, this is a copy ctor
    writeln(__traits(hasPostblit, B)); // true
}

---

)

$(H3 $(B $(ID getAliasThis) getAliasThis))

    Takes one argument, a type. If the type has `alias this` declarations,
        returns a <em>ValueSeq</em> of the names (as `string`s) of the members used in
        those declarations. Otherwise returns an empty sequence.
    

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
alias AliasSeq(T...) = T;

struct S1
{
    string var;
    alias var this;
}
static assert(__traits(getAliasThis, S1) == AliasSeq!("var"));
static assert(__traits(getAliasThis, int).length == 0);

pragma(msg, __traits(getAliasThis, S1));
pragma(msg, __traits(getAliasThis, int));

---

)

        Prints:

$(CONSOLE tuple("var")
tuple()
)

$(H3 $(B $(ID getPointerBitmap) getPointerBitmap))

    The argument is a type.
    The result is an array of `size_t` describing the memory used by an instance of the given type.
    
    The first element of the array is the size of the type (for classes it is
    the [#classInstanceSize|classInstanceSize]).
    The following elements describe the locations of GC managed pointers within the
    memory occupied by an instance of the type.
    For type T, there are `T.sizeof / size_t.sizeof` possible pointers represented
    by the bits of the array values.
    This array can be used by a precise GC to avoid false pointers.
$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
void main()
{
    static class C
    {
        // implicit virtual function table pointer not marked
        // implicit monitor field not marked, usually managed manually
        C next;
        size_t sz;
        void* p;
        void function () fn; // not a GC managed pointer
    }

    static struct S
    {
        size_t val1;
        void* p;
        C c;
        byte[] arr;          // { length, ptr }
        void delegate () dg; // { context, func }
    }

    static assert (__traits(getPointerBitmap, C) == [6*size_t.sizeof, 0b010100]);
    static assert (__traits(getPointerBitmap, S) == [7*size_t.sizeof, 0b0110110]);
}

---

)

$(H3 $(B $(ID getVirtualFunctions) getVirtualFunctions))

        The same as [#getVirtualMethods|getVirtualMethods], except that
        final functions that do not override anything are included.
        

$(H3 $(B $(ID getVirtualMethods) getVirtualMethods))

        The first argument is a class type or an expression of
        class type.
        The second argument is a string that matches the name of
        one of the functions of that class.
        The result is a symbol sequence of the virtual overloads of that function.
        It does not include final functions that do not override anything.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
import std.stdio;

class D
{
    this() { }
    ~this() { }
    void foo() { }
    int foo(int) { return 2; }
}

void main()
{
    D d = new D();

    foreach (t; __traits(getVirtualMethods, D, "foo"))
        writeln(typeid(typeof(t)));

    alias b = typeof(__traits(getVirtualMethods, D, "foo"));
    foreach (t; b)
        writeln(typeid(t));

    auto i = __traits(getVirtualMethods, d, "foo")[1](1);
    writeln(i);
}

---

)

        Prints:

$(CONSOLE void()
int()
void()
int()
2
)

$(H3 $(B $(ID classInstanceSize) classInstanceSize))

        Takes a single argument, which must evaluate to either
        a class type or an expression of class type.
        The result
        is of type `size_t`, and the value is the number of
        bytes in the runtime instance of the class type.
        It is based on the static type of a class, not the
        polymorphic type.
        

$(H3 $(B $(ID classInstanceAlignment) classInstanceAlignment))

        Takes a single argument, which must evaluate to either
        a class type or an expression of class type.
        The result
        is of type `size_t`, and the value is the alignment
        of a runtime instance of the class type.
        It is based on the static type of a class, not the
        polymorphic type.
        

$(H3 $(B $(ID initSymbol) initSymbol))

        Takes a single argument, which must evaluate to a `class`, `struct` or `union` type.
            Returns a `const(void)[]` that holds the initial state of any instance of the supplied type.
            The slice is constructed for any type `T` as follows:

$(LIST
* `ptr` points to either the initializer symbol of `T`
               or `null` if `T` is a zero-initialized struct / unions.

* `length` is equal to the size of an instance, i.e. `T.sizeof` for structs / unions and
              [#classInstanceSize|`__traits(classInstanceSize, T)``] for classes.

)
        

                    This trait matches the behaviour of `TypeInfo.initializer()` but can also be used when
            `TypeInfo` is not available.
        

                    This traits is not available during $(LINK2 spec/glossary#ctfe,CTFE) because the actual address
            of the initializer symbol will be set by the linker and hence is not available at compile time.
        

---
class C
{
    int i = 4;
}

/// Initializes a malloc'ed instance of `C`
void main()
{
    const void[] initSym = __traits(initSymbol, C);

    void* ptr = malloc(initSym.length);
    scope (exit) free(ptr);

    ptr[0..initSym.length] = initSym[];

    C c = cast(C) ptr;
    assert(c.i == 4);
}

---


$(H2 $(ID functions) Function Traits)

$(H3 $(B $(ID isDisabled) isDisabled))

    Takes one argument and returns `true` if it's a function declaration
    marked with `@disable`.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
struct Foo
{
    @disable void foo();
    void bar(){}
}

static assert(__traits(isDisabled, Foo.foo));
static assert(!__traits(isDisabled, Foo.bar));

---

)

    For any other declaration even if `@disable` is a syntactically valid
    attribute `false` is returned because the annotation has no effect.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
@disable struct Bar{}

static assert(!__traits(isDisabled, Bar));

---

)

$(H3 $(B $(ID getVirtualIndex) getVirtualIndex))

  Takes a single argument which must evaluate to a function.
  The result is a `ptrdiff_t` containing the index
  of that function within the vtable of the parent type.
  If the function passed in is final and does not override
  a virtual function, `-1` is returned instead.
  

$(H3 $(B $(ID isVirtualFunction) isVirtualFunction))

        The same as [#isVirtualMethod|isVirtualMethod], except
        that final functions that don't override anything return true.
        

$(H3 $(B $(ID isVirtualMethod) isVirtualMethod))

        Takes one argument. If that argument is a virtual function,
        `true` is returned, otherwise `false`.
        Final functions that don't override anything return false.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
import std.stdio;

struct S
{
    void bar() { }
}

class C
{
    void bar() { }
}

void main()
{
    writeln(__traits(isVirtualMethod, C.bar));  // true
    writeln(__traits(isVirtualMethod, S.bar));  // false
}

---

)

$(H3 $(B $(ID isAbstractFunction) isAbstractFunction))

        Takes one argument. If that argument is an abstract function,
        `true` is returned, otherwise `false`.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
import std.stdio;

struct S
{
    void bar() { }
}

class C
{
    void bar() { }
}

class AC
{
    abstract void foo();
}

void main()
{
    writeln(__traits(isAbstractFunction, C.bar));   // false
    writeln(__traits(isAbstractFunction, S.bar));   // false
    writeln(__traits(isAbstractFunction, AC.foo));  // true
}

---

)

$(H3 $(B $(ID isFinalFunction) isFinalFunction))

        Takes one argument. If that argument is a final function,
        `true` is returned, otherwise `false`.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
import std.stdio;

struct S
{
    void bar() { }
}

class C
{
    void bar() { }
    final void foo();
}

final class FC
{
    void foo();
}

void main()
{
    writeln(__traits(isFinalFunction, C.bar));  // false
    writeln(__traits(isFinalFunction, S.bar));  // false
    writeln(__traits(isFinalFunction, C.foo));  // true
    writeln(__traits(isFinalFunction, FC.foo)); // true
}

---

)

$(H3 $(B $(ID isOverrideFunction) isOverrideFunction))

        Takes one argument. If that argument is a function marked with
        override, `true` is returned, otherwise `false`.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
import std.stdio;

class Base
{
    void foo() { }
}

class Foo : Base
{
    override void foo() { }
    void bar() { }
}

void main()
{
    writeln(__traits(isOverrideFunction, Base.foo)); // false
    writeln(__traits(isOverrideFunction, Foo.foo));  // true
    writeln(__traits(isOverrideFunction, Foo.bar));  // false
}

---

)

$(H3 $(B $(ID isStaticFunction) isStaticFunction))

        Takes one argument. If that argument is a static function,
        meaning it has no context pointer,
        `true` is returned, otherwise `false`.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
struct A
{
    int foo() { return 3; }
    static int boo(int a) { return a; }
}

void main()
{
    assert(__traits(isStaticFunction, A.boo));
    assert(!__traits(isStaticFunction, A.foo));
    assert(__traits(isStaticFunction, main));
}

---

)

$(H3 $(B $(ID isReturnOnStack) isReturnOnStack))

            Takes one argument which must either be a function symbol, function literal,
        a delegate, or a function pointer.
        It returns a `bool` which is `true` if the return value of the function is
        returned on the stack via a pointer to it passed as a hidden extra
        parameter to the function.
    

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
struct S { int[20] a; }
int test1();
S test2();

static assert(__traits(isReturnOnStack, test1) == false);
static assert(__traits(isReturnOnStack, test2) == true);

---

)

    $(WARNING         This is determined by the function ABI calling convention in use,
        which is often complex.
    )

    $(TIP This has applications in:
    $(NUMBERED_LIST
    * Returning values in registers is often faster, so this can be used as
    a check on a hot function to ensure it is using the fastest method.
    * When using inline assembly to correctly call a function.
    * Testing that the compiler does this correctly is normally hackish and awkward,
    this enables efficient, direct, and simple testing.
    
))

$(H4 $(B $(ID getFunctionVariadicStyle) getFunctionVariadicStyle))
            Takes one argument which must either be a function symbol, or a type
        that is a function, delegate or a function pointer.
        It returns a string identifying the kind of
        $(LINK2 function.html#variadic, variadic arguments) that are supported.
    

    $(TABLE_ROWS
getFunctionVariadicStyle
        * + result
+ kind
+ access
+ example

        * - `"none"`
- not a variadic function
- $(NBSP)
- `void foo();`

        * - `"argptr"`
- D style variadic function
- `_argptr` and `_arguments`
- `void bar(...)`

        * - `"stdarg"`
- C style variadic function
- $(LINK2 phobos/core_stdc_stdarg.html, `core.stdc.stdarg`)
- `extern (C) void abc(int, ...)`

        * - `"typesafe"`
- typesafe variadic function
- array on stack
- `void def(int[] ...)`

    
)

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
import core.stdc.stdarg;

void novar() {}
extern(C) void cstyle(int, ...) {}
extern(C++) void cppstyle(int, ...) {}
void dstyle(...) {}
void typesafe(int[]...) {}

static assert(__traits(getFunctionVariadicStyle, novar) == "none");
static assert(__traits(getFunctionVariadicStyle, cstyle) == "stdarg");
static assert(__traits(getFunctionVariadicStyle, cppstyle) == "stdarg");
static assert(__traits(getFunctionVariadicStyle, dstyle) == "argptr");
static assert(__traits(getFunctionVariadicStyle, typesafe) == "typesafe");

static assert(__traits(getFunctionVariadicStyle, (int[] a...) {}) == "typesafe");
static assert(__traits(getFunctionVariadicStyle, typeof(cstyle)) == "stdarg");

---

)


$(H4 $(B $(ID getFunctionAttributes) getFunctionAttributes))
            Takes one argument which must either be a function symbol, function literal,
        or a function pointer. It returns a string <em>ValueSeq</em> of all the attributes of
        that function $(B excluding) any user-defined attributes (UDAs can be
        retrieved with the [#getAttributes|getAttributes] trait).
        If no attributes exist it will return an empty sequence.
    


        $(B Note:) The order of the attributes in the returned sequence is
        implementation-defined and should not be relied upon.

                    A list of currently supported attributes are:
            $(LIST
* `pure`, `nothrow`, `@nogc`, `@property`, `@system`, `@trusted`, `@safe`, `ref` and `@live`
)
            $(B Note:) `ref` is a function attribute even though it applies to the return type.

                    Additionally the following attributes are only valid for non-static member functions:
            $(LIST
* `const`, `immutable`, `inout`, `shared`
)

    For example:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
int sum(int x, int y) pure nothrow { return x + y; }

pragma(msg, __traits(getFunctionAttributes, sum));

struct S
{
    void test() const @system { }
}

pragma(msg, __traits(getFunctionAttributes, S.test));

---

)

        Prints:

$(CONSOLE tuple("pure", "nothrow", "@system")
tuple("const", "@system")
)

    Note that some attributes can be inferred. For example:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
pragma(msg, __traits(getFunctionAttributes, (int x) @trusted { return x * 2; }));

---

)

        Prints:

$(CONSOLE tuple("pure", "nothrow", "@nogc", "@trusted")
)




$(H2 $(ID function-parameters) Function Parameter Traits)

$(H3 $(B $(ID isRef) isRef), $(B $(ID isOut) isOut), $(B $(ID isLazy) isLazy))

        Takes one argument. If that argument is a declaration,
        `true` is returned if it is ref, out,
        or lazy, otherwise `false`.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
void fooref(ref int x)
{
    static assert(__traits(isRef, x));
    static assert(!__traits(isOut, x));
    static assert(!__traits(isLazy, x));
}

void fooout(out int x)
{
    static assert(!__traits(isRef, x));
    static assert(__traits(isOut, x));
    static assert(!__traits(isLazy, x));
}

void foolazy(lazy int x)
{
    static assert(!__traits(isRef, x));
    static assert(!__traits(isOut, x));
    static assert(__traits(isLazy, x));
}

---

)

$(H3 $(B $(ID getParameterStorageClasses) getParameterStorageClasses))

            Takes two arguments.
        The first must either be a function symbol, a function call, or a type
        that is a function, delegate or a function pointer.
        The second is an integer identifying which parameter, where the first parameter is
        0.
        It returns a <em>ValueSeq</em> of strings representing the storage classes of that parameter.
    

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
ref int foo(return ref const int* p, scope int* a, out int b, lazy int c);

static assert(__traits(getParameterStorageClasses, foo, 0)[0] == "return");
static assert(__traits(getParameterStorageClasses, foo, 0)[1] == "ref");

static assert(__traits(getParameterStorageClasses, foo, 1)[0] == "scope");
static assert(__traits(getParameterStorageClasses, foo, 2)[0] == "out");
static assert(__traits(getParameterStorageClasses, typeof(&amp;foo), 3)[0] == "lazy");

int* p, a;
int b, c;

static assert(__traits(getParameterStorageClasses, foo(p, a, b, c), 1)[0] == "scope");
static assert(__traits(getParameterStorageClasses, foo(p, a, b, c), 2)[0] == "out");
static assert(__traits(getParameterStorageClasses, foo(p, a, b, c), 3)[0] == "lazy");

---

)

$(H3 $(B $(ID parameters) parameters))

        May only be used inside a function. Takes no arguments, and returns
        a sequence of the enclosing function's parameters.

        If the function is nested, the parameters returned are those of the
        inner function, not the outer one.

---
int add(int x, int y)
{
    return x + y;
}

int forwardToAdd(int x, int y)
{
    return add(__traits(parameters));
    // equivalent to;
    //return add(x, y);
}

int nestedExample(int x)
{
    // outer function's parameters
    static assert(typeof(__traits(parameters)).length == 1);

    int add(int x, int y)
    {
        // inner function's parameters
        static assert(typeof(__traits(parameters)).length == 2);
        return x + y;
    }

    return add(x, x);
}

class C
{
    int opApply(int delegate(size_t, C) dg)
    {
        if (dg(0, this)) return 1;
        return 0;
    }
}

void foreachExample(C c, int x)
{
    foreach(idx; 0..5)
    {
        static assert(is(typeof(__traits(parameters)) == AliasSeq!(C, int)));
    }
    foreach(idx, elem; c)
    {
        //  __traits(parameters) sees past the delegate passed to opApply
        static assert(is(typeof(__traits(parameters)) == AliasSeq!(C, int)));
    }
}

---


$(H2 $(ID symbols) Symbol Traits)

$(H3 $(B $(ID isNested) isNested))

    Takes one argument.
    It returns `true` if the argument is a nested type which internally
    stores a context pointer, otherwise it returns `false`.
    Nested types can be  $(LINK2 spec/class#nested,classes),
    $(LINK2 spec/struct#nested,structs), and
    $(LINK2 spec/function#variadicnested,functions).

$(H3 $(B $(ID isFuture) isFuture))

    Takes one argument. It returns `true` if the argument is a symbol
    marked with the `@future` keyword, otherwise `false`. Currently, only
    functions and variable declarations have support for the `@future` keyword.

$(H3 $(B $(ID isDeprecated) isDeprecated))

    Takes one argument. It returns `true` if the argument is a symbol
    marked with the `deprecated` keyword, otherwise `false`.

$(H3 $(B $(ID isTemplate) isTemplate))

        Takes one argument. If that argument or any of its overloads is a template
        then `true` is returned, otherwise `false`.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
void foo(T)(){}
static assert(__traits(isTemplate,foo));
static assert(!__traits(isTemplate,foo!int()));
static assert(!__traits(isTemplate,"string"));

---

)

$(H3 $(B $(ID isModule) isModule))

        Takes one argument. If that argument is a symbol that refers to a
        $(LINK2 spec/module, Modules) then `true` is returned, otherwise `false`.
        $(LINK2 spec/module#package-module,Package modules) are considered to be
        modules even if they have not been directly imported as modules.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
import core.thread;
import std.algorithm.sorting;

// A regular package (no package.d)
static assert(!__traits(isModule, core));
// A package module (has a package.d file)
// Note that we haven't imported std.algorithm directly.
// (In other words, we don't have an "import std.algorithm;" directive.)
static assert(__traits(isModule, std.algorithm));
// A regular module
static assert(__traits(isModule, std.algorithm.sorting));

---

)

$(H3 $(B $(ID isPackage) isPackage))

        Takes one argument. If that argument is a symbol that refers to a
        $(LINK2 spec/module#PackageName,package) then `true` is returned,
        otherwise `false`.
        

---
import std.algorithm.sorting;
static assert(__traits(isPackage, std));
static assert(__traits(isPackage, std.algorithm));
static assert(!__traits(isPackage, std.algorithm.sorting));

---

$(H3 $(B $(ID hasMember) hasMember))

        The first argument is a type that has members, or
        is an expression of a type that has members.
        The second argument is a string.
        If the string is a valid property of the type,
        `true` is returned, otherwise `false`.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
import std.stdio;

struct S
{
    int m;
}

void main()
{
    S s;

    writeln(__traits(hasMember, S, "m")); // true
    writeln(__traits(hasMember, s, "m")); // true
    writeln(__traits(hasMember, S, "y")); // false
    writeln(__traits(hasMember, S, "write")); // false, but callable like a member via UFCS
    writeln(__traits(hasMember, int, "sizeof")); // true
}

---

)

$(H3 $(B $(ID identifier) identifier))

        Takes one argument, a symbol. Returns the identifier
        for that symbol as a string literal.
        
$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
int var = 123;
pragma(msg, typeof(var));                       // int
pragma(msg, typeof(__traits(identifier, var))); // string
writeln(var);                                   // 123
writeln(__traits(identifier, var));             // "var"

---

)

$(H4 $(B $(ID getAttributes) getAttributes))
            Takes one argument, a symbol. Returns a sequence of all attached user-defined attributes.
        If no UDAs exist it will return an empty sequence
    

            For more information, see: $(LINK2 spec/attribute#uda,User-Defined Attributes)
    

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
@(3) int a;
@("string", 7) int b;

enum Foo;
@Foo int c;

pragma(msg, __traits(getAttributes, a));
pragma(msg, __traits(getAttributes, b));
pragma(msg, __traits(getAttributes, c));

---

)

        Prints:

$(CONSOLE tuple(3)
tuple("string", 7)
tuple((Foo))
)


$(H3 $(B $(ID getLinkage) getLinkage))

        Takes one argument, which is a declaration symbol, or the type of a function, delegate,
        pointer to function, struct, class, or interface.
        Returns a string representing the $(LINK2 attribute.html#LinkageAttribute, LinkageAttribute)
        of the declaration.
        The string is one of:
        

        $(LIST
        * `"D"`
        * `"C"`
        * `"C++"`
        * `"Windows"`
        * `"Objective-C"`
        * `"System"`
        
)

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
extern (C) int fooc();
alias aliasc = fooc;

static assert(__traits(getLinkage, fooc) == "C");
static assert(__traits(getLinkage, aliasc) == "C");

extern (C++) struct FooCPPStruct {}
extern (C++) class FooCPPClass {}
extern (C++) interface FooCPPInterface {}

static assert(__traits(getLinkage, FooCPPStruct) == "C++");
static assert(__traits(getLinkage, FooCPPClass) == "C++");
static assert(__traits(getLinkage, FooCPPInterface) == "C++");

---

)

$(H3 $(B $(ID getLocation) getLocation))
        Takes one argument which is a symbol.
        To disambiguate between overloads, pass the result of [#getOverloads|getOverloads] with the desired index, to `getLocation`.
        Returns a <em>ValueSeq</em> of a string and two `int`s which correspond to the filename, line number and column number where the argument
        was declared.
        

$(H3 $(B $(ID getMember) getMember))

        Takes two arguments, the second must be a string.
        The result is an expression formed from the first
        argument, followed by a '.', followed by the second
        argument as an identifier.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
import std.stdio;

struct S
{
    int mx;
    static int my;
}

void main()
{
    S s;

    __traits(getMember, s, "mx") = 1;  // same as s.mx=1;
    writeln(__traits(getMember, s, "m" ~ "x")); // 1

    // __traits(getMember, S, "mx") = 1;  // error, no this for S.mx
    __traits(getMember, S, "my") = 2;  // ok
}

---

)

$(H3 $(B $(ID getOverloads) getOverloads))

        The first argument is an aggregate (e.g. struct/class/module).
        The second argument is a `string` that matches the name of
        the member(s) to return.
        The third argument is a `bool`, and is optional.  If `true`, the
        result will also include template overloads.
        The result is a symbol sequence of all the overloads of the supplied name.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
import std.stdio;

class D
{
    this() { }
    ~this() { }
    void foo() { }
    int foo(int) { return 2; }
    void bar(T)() { return T.init; }
    class bar(int n) {}
}

void main()
{
    D d = new D();

    foreach (t; __traits(getOverloads, D, "foo"))
        writeln(typeid(typeof(t)));

    alias b = typeof(__traits(getOverloads, D, "foo"));
    foreach (t; b)
        writeln(typeid(t));

    auto i = __traits(getOverloads, d, "foo")[1](1);
    writeln(i);

    foreach (t; __traits(getOverloads, D, "bar", true))
        writeln(t.stringof);
}

---

)

        Prints:

$(CONSOLE void()
int()
void()
int()
2
bar(T)()
bar(int n)
)

$(H3 $(B $(ID getCppNamespaces) getCppNamespaces))
    The argument is a symbol.
    The result is a <em>ValueSeq</em> of strings, possibly empty, that correspond to the namespaces the symbol resides in.
    
$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
extern(C++, "ns")
struct Foo {}
struct Bar {}
extern(C++, __traits(getCppNamespaces, Foo)) struct Baz {}
static assert(__traits(getCppNamespaces, Foo) ==  __traits(getCppNamespaces, Baz));
void main()
{
    static assert(__traits(getCppNamespaces, Foo)[0] == "ns");
    static assert(!__traits(getCppNamespaces, Bar).length);
    static assert(__traits(getCppNamespaces, Foo) ==  __traits(getCppNamespaces, Baz));
}

---

)

$(H3 $(B $(ID getVisibility) getVisibility))

        The argument is a symbol.
        The result is a string giving its visibility level: "public", "private", "protected", "export", or "package".
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
import std.stdio;

class D
{
    export void foo() { }
    public int bar;
}

void main()
{
    D d = new D();

    auto i = __traits(getVisibility, d.foo);
    writeln(i);

    auto j = __traits(getVisibility, d.bar);
    writeln(j);
}

---

)

        Prints:

$(CONSOLE export
public
)

$(H3 $(B $(ID getProtection) getProtection))

        A backward-compatible alias for [#getVisibility|getVisibility].

$(H3 $(B $(ID getTargetInfo) getTargetInfo))

        Receives a string key as argument.
        The result is an expression describing the requested target information.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
version (CppRuntime_Microsoft)
    static assert(__traits(getTargetInfo, "cppRuntimeLibrary") == "libcmt");

---

)

        Keys are implementation defined, allowing relevant data for exotic targets.
        A reliable subset exists which are always available:
        

        $(LIST
        * `"cppRuntimeLibrary"` - The C++ runtime library affinity for this toolchain
        * `"cppStd"` - The version of the C++ standard supported by `extern(C++)` code, equivalent to the `__cplusplus` macro in a C++ compiler
        * `"floatAbi"` - Floating point ABI; may be `"hard"`, `"soft"`, or `"softfp"`
        * `"objectFormat"` - Target object format
        
)

$(H3 $(B $(ID getUnitTests) getUnitTests))

                        Takes one argument, a symbol of an aggregate (e.g. struct/class/module).
                The result is a symbol sequence of all the unit test functions of that aggregate.
                The functions returned are like normal nested static functions,
                $(LINK2 spec/glossary#ctfe,CTFE) will work and
                $(LINK2 spec/attribute#uda,UDAs) will be accessible.
        

        $(H4 Note:)

                        The -unittest flag needs to be passed to the compiler. If the flag
                is not passed `__traits(getUnitTests)` will always return an
                empty sequence.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
module foo;

import core.runtime;
import std.stdio;

struct name { string name; }

class Foo
{
    unittest
    {
        writeln("foo.Foo.unittest");
    }
}

@name("foo") unittest
{
    writeln("foo.unittest");
}

template Tuple (T...)
{
    alias Tuple = T;
}

shared static this()
{
  // Override the default unit test runner to do nothing. After that, "main" will
  // be called.
  Runtime.moduleUnitTester = { return true; };
}

void main()
{
    writeln("start main");

    alias tests = Tuple!(__traits(getUnitTests, foo));
    static assert(tests.length == 1);

    alias attributes = Tuple!(__traits(getAttributes, tests[0]));
    static assert(attributes.length == 1);

    foreach (test; tests)
        test();

    foreach (test; __traits(getUnitTests, Foo))
        test();
}

---

)

        By default, the above will print:

$(CONSOLE start main
foo.unittest
foo.Foo.unittest
)

$(H3 $(B $(ID parent) parent))

        Takes a single argument which must evaluate to a symbol.
        The result is the symbol that is the parent of it.
        

$(H3 $(B $(ID child) child))

        Takes two arguments.
        The first must be a symbol or expression.
        The second is a symbol, such as an alias to a member of the first
        argument.
        The result is the second argument interpreted with its `this`
        context set to the value of the first argument.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
import std.stdio;

struct A
{
    int i;
    int foo(int j) {
        return i * j;
    }
    T bar(T)(T t) {
        return i + t;
    }
}

alias Ai = A.i;
alias Abar = A.bar!int;

void main()
{
    A a;

    __traits(child, a, Ai) = 3;
    writeln(a.i);
    writeln(__traits(child, a, A.foo)(2));
    writeln(__traits(child, a, Abar)(5));
}

---

)

        Prints:

$(CONSOLE 3
6
8
)

$(H3 $(B $(ID allMembers) allMembers))

        Takes a single argument, which must evaluate to either
        a module, a struct, a union, a class, an interface, an enum, or a
        template instantiation.

        A sequence of string literals is returned, each of which
        is the name of a member of that argument combined with all
        of the members of its base classes (if the argument is a class).
        No name is repeated.
        Builtin properties are not included.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
import std.stdio;

class D
{
    this() { }
    ~this() { }
    void foo() { }
    int foo(int) { return 0; }
}

void main()
{
    auto b = [ __traits(allMembers, D) ];
    writeln(b);
    // ["__ctor", "__dtor", "foo", "toString", "toHash", "opCmp", "opEquals",
    // "Monitor", "factory"]
}

---

)

        The order in which the strings appear in the result
        is not defined.

$(H3 $(B $(ID derivedMembers) derivedMembers))

        Takes a single argument, which must evaluate to either
        a type or an expression of type.
        A sequence of string literals is returned, each of which
        is the name of a member of that type.
        No name is repeated.
        Base class member names are not included.
        Builtin properties are not included.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
import std.stdio;

class D
{
    this() { }
    ~this() { }
    void foo() { }
    int foo(int) { return 0; }
}

void main()
{
    auto a = [__traits(derivedMembers, D)];
    writeln(a);    // ["__ctor", "__dtor", "foo"]
}

---

)

        The order in which the strings appear in the result
        is not defined.

$(H3 $(B $(ID isSame) isSame))

        Compares two arguments and evaluates to `bool`.

        The result is `true` if the two arguments are the same symbol
        (once aliases are resolved).

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
struct S { }

int foo();
int bar();

static assert(__traits(isSame, foo, foo));
static assert(!__traits(isSame, foo, bar));
static assert(!__traits(isSame, foo, S));
static assert(__traits(isSame, S, S));
static assert(!__traits(isSame, object, S));
static assert(__traits(isSame, object, object));

alias daz = foo;
static assert(__traits(isSame, foo, daz));

---

)

        The result is `true` if the two arguments are expressions
        made up of literals or enums that evaluate to the same value.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
enum e = 3;
static assert(__traits(isSame, (e), 3));
static assert(__traits(isSame, 5, 2 + e));

---

)
        If the two arguments are both
        $(LINK2 spec/expression#function_literals,lambda functions) (or aliases
        to lambda functions), then they are compared for equality. For
        the comparison to be computed correctly, the following conditions
        must be met for both lambda functions:

        $(NUMBERED_LIST
        * The lambda function arguments must not have a template
        instantiation as an explicit argument type. Any other argument
        types (basic, user-defined, template) are supported.
        * The lambda function body must contain a single expression
        (no return statement) which contains only numeric values,
        manifest constants, enum values, function arguments and function
        calls. If the expression contains local variables or return
        statements, the function is considered incomparable.
        
)

        If these constraints aren't fulfilled, the function is considered
        incomparable and the result is `false`.

    $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
static assert(__traits(isSame, (a, b) =&gt; a + b, (c, d) =&gt; c + d));
static assert(__traits(isSame, a =&gt; ++a, b =&gt; ++b));
static assert(!__traits(isSame, (int a, int b) =&gt; a + b, (a, b) =&gt; a + b));
static assert(__traits(isSame, (a, b) =&gt; a + b + 10, (c, d) =&gt; c + d + 10));

---
    
)
$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
int f() { return 2; }

void test(alias pred)()
{
    // f() from main is a different function from top-level f()
    static assert(!__traits(isSame, (int a) =&gt; a + f(), pred));
}

void main()
{
    // lambdas accessing local variables are considered incomparable
    int b;
    static assert(!__traits(isSame, a =&gt; a + b, a =&gt; a + b));

    // lambdas calling other functions are comparable
    int f() { return 3;}
    static assert(__traits(isSame, a =&gt; a + f(), a =&gt; a + f()));
    test!((int a) =&gt; a + f())();
}

---

)
    $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
class A
{
    int a;
    this(int a)
    {
        this.a = a;
    }
}

class B
{
    int a;
    this(int a)
    {
        this.a = a;
    }
}

static assert(__traits(isSame, (A a) =&gt; ++a.a, (A b) =&gt; ++b.a));
// lambdas with different data types are considered incomparable,
// even if the memory layout is the same
static assert(!__traits(isSame, (A a) =&gt; ++a.a, (B a) =&gt; ++a.a));

---
    
)

        If the two arguments are tuples then the result is `true` if the
        two tuples, after expansion, have the same length and if each pair
        of nth argument respects the constraints previously specified.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
import std.meta;

struct S { }

// like __traits(isSame,0,0) &amp;&amp; __traits(isSame,1,1)
static assert(__traits(isSame, AliasSeq!(0,1), AliasSeq!(0,1)));
// like __traits(isSame,S,std.meta) &amp;&amp; __traits(isSame,1,1)
static assert(!__traits(isSame, AliasSeq!(S,1), AliasSeq!(std.meta,1)));
// the length of the sequences is different
static assert(!__traits(isSame, AliasSeq!(1), AliasSeq!(1,2)));

---

)

$(H3 $(B $(ID compiles) compiles))

        Returns a bool `true` if all of the arguments
        compile (are semantically correct).
        The arguments can be symbols, types, or expressions that
        are syntactically correct.
        The arguments cannot be statements or declarations - instead
        these can be wrapped in a $(LINK2 spec/expression#function_literals,        function literal) expression.
        

        If there are no arguments, the result is `false`.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
static assert(!__traits(compiles));
static assert(__traits(compiles, 1 + 1)); // expression
static assert(__traits(compiles, typeof(1))); // type
static assert(__traits(compiles, object)); // symbol
static assert(__traits(compiles, 1, 2, 3, int, long));
static assert(!__traits(compiles, 3[1])); // semantic error
static assert(!__traits(compiles, 1, 2, 3, int, long, 3[1]));

enum n = 3;
// wrap a declaration/statement in a function literal
static assert(__traits(compiles, { int[n] arr; }));
static assert(!__traits(compiles, { foreach (e; n) {} }));

struct S
{
    static int s1;
    int s2;
}

static assert(__traits(compiles, S.s1 = 0));
static assert(!__traits(compiles, S.s2 = 0));
static assert(!__traits(compiles, S.s3));

int foo();

static assert(__traits(compiles, foo));
static assert(__traits(compiles, foo + 1)); // call foo with optional parens
static assert(!__traits(compiles, &amp;foo + 1));

---

)

        This is useful for:

        $(LIST
        * Giving better error messages (using $(LINK2 spec/version#static-assert,        `static assert`)) inside generic code than
        the sometimes hard to follow compiler ones.
        * Doing a finer grained specialization than template
        partial specialization allows for.
        
)

version, Conditional Compilation, errors, Error Handling



Link_References:
	ACC = Associated C Compiler
+/
module traits.dd;