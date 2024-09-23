// just docs: Types
/++





$(H2 $(ID grammar) Grammar)

    D is statically typed. Every expression has a type. Types constrain the values
    an expression can hold, and determine the semantics of operations on those values.
    

$(PRE $(CLASS GRAMMAR)
$(B $(ID Type) Type):
    [#TypeCtors|TypeCtors]$(SUBSCRIPT opt) [#BasicType|BasicType] [#TypeSuffixes|TypeSuffixes]$(SUBSCRIPT opt)

$(B $(ID TypeCtors) TypeCtors):
    [#TypeCtor|TypeCtor]
    [#TypeCtor|TypeCtor] TypeCtors

$(B $(ID TypeCtor) TypeCtor):
    `const`
    `immutable`
    `inout`
    `shared`

$(B $(ID BasicType) BasicType):
    [#FundamentalType|FundamentalType]
    `.` [#QualifiedIdentifier|QualifiedIdentifier]
    [#QualifiedIdentifier|QualifiedIdentifier]
    [#Typeof|Typeof]
    [#Typeof|Typeof] `.` [#QualifiedIdentifier|QualifiedIdentifier]
    [#TypeCtor|TypeCtor] `(` [#Type|Type] `)`
    [#Vector|Vector]
    [traits#TraitsExpression|traits, TraitsExpression]
    [#MixinType|MixinType]

$(B $(ID Vector) Vector):
    `__vector` `(` [#VectorBaseType|VectorBaseType] `)`

$(B $(ID VectorBaseType) VectorBaseType):
    [#Type|Type]

$(B $(ID FundamentalType) FundamentalType):
    `bool`
    `byte`
    `ubyte`
    `short`
    `ushort`
    `int`
    `uint`
    `long`
    `ulong`
    `cent`
    `ucent`
    `char`
    `wchar`
    `dchar`
    `float`
    `double`
    `real`
    `ifloat`
    `idouble`
    `ireal`
    `cfloat`
    `cdouble`
    `creal`
    `void`

$(B $(ID TypeSuffixes) TypeSuffixes):
    [#TypeSuffix|TypeSuffix] TypeSuffixes$(SUBSCRIPT opt)

$(B $(ID TypeSuffix) TypeSuffix):
    `*`
    `[ ]`
    `[` [expression#AssignExpression|expression, AssignExpression] `]`
    `[` [expression#AssignExpression|expression, AssignExpression] `..` [expression#AssignExpression|expression, AssignExpression] `]`
    `[` [#Type|Type] `]`
    `delegate` [function#Parameters|function, Parameters] [function#MemberFunctionAttributes|function, MemberFunctionAttributes]$(SUBSCRIPT opt)
    `function` [function#Parameters|function, Parameters] [function#FunctionAttributes|function, FunctionAttributes]$(SUBSCRIPT opt)

$(B $(ID QualifiedIdentifier) QualifiedIdentifier):
    $(LINK2 lex#Identifier, Identifier)
    $(LINK2 lex#Identifier, Identifier) `.` QualifiedIdentifier
    [template#TemplateInstance|template, TemplateInstance]
    [template#TemplateInstance|template, TemplateInstance] `.` QualifiedIdentifier
    $(LINK2 lex#Identifier, Identifier) `[` [expression#AssignExpression|expression, AssignExpression] `]`
    $(LINK2 lex#Identifier, Identifier) `[` [expression#AssignExpression|expression, AssignExpression] `] .` QualifiedIdentifier

)

$(LIST
* [#basic-data-types|Basic Data Types] are leaf types.
* [#derived-data-types|Derived Data Types] build on leaf types.
* [#user-defined-types|User-Defined Types] are aggregates of basic and derived types.


)
$(H2 $(ID basic-data-types)Basic Data Types)

    $(TABLE_ROWS
Basic Data Types
    * + Keyword
+ Default Initializer (`.init`)
+ Description

    * - `void`
- no default initializer
- `void` has no value

    * - [#bool|`bool`]
- `false`
- boolean value

    * - `byte`
- `0`
- signed 8 bits

    * - `ubyte`
- `0u`
- unsigned 8 bits

    * - `short`
- `0`
- signed 16 bits

    * - `ushort`
- `0u`
- unsigned 16 bits

    * - `int`
- `0`
- signed 32 bits

    * - `uint`
- `0u`
- unsigned 32 bits

    * - `long`
- `0L`
- signed 64 bits

    * - `ulong`
- `0uL`
- unsigned 64 bits

    * - `cent`
- `0`
- signed 128 bits

    * - `ucent`
- `0u`
- unsigned 128 bits

    * - `float`
- `float.nan`
- 32 bit floating point

    * - `double`
- `double.nan`
- 64 bit floating point

    * - `real`
- `real.nan`
- largest floating point size available

    * - `ifloat`
- `float.nan*1.0i`
- imaginary float

    * - `idouble`
- `double.nan*1.0i`
- imaginary double

    * - `ireal`
- `real.nan*1.0i`
- imaginary real

    * - `cfloat`
- `float.nan+float.nan*1.0i`
- a complex number of two float values

    * - `cdouble`
- `double.nan+double.nan*1.0i`
- complex double

    * - `creal`
- `real.nan+real.nan*1.0i`
- complex real

    * - `char`
- `'\xFF'`
- unsigned 8 bit (UTF-8 code unit)

    * - `wchar`
- `'\uFFFF'`
- unsigned 16 bit (UTF-16 code unit)

    * - `dchar`
- `'\U0000FFFF'`
- unsigned 32 bit (UTF-32 code unit)

    
)

    Endianness of basic types is part of the $(LINK2 spec/abi#endianness,ABI)

    $(WARNING The real floating point type has at least the range and precision
    of the `double` type. On x86 CPUs it is often implemented as the 80 bit Extended Real
    type supported by the x86 FPU.
    )

    NOTE: Complex and imaginary types `ifloat`, `idouble`, `ireal`, `cfloat`, `cdouble`,
    and `creal` have been deprecated in favor of `std.complex.Complex`.

$(H2 $(ID derived-data-types)Derived Data Types)

    $(LIST
    * Pointers
    * $(LINK2 spec/arrays#static-arrays,Static Arrays)
    * $(LINK2 spec/arrays#dynamic-arrays,Dynamic Arrays)
    * $(LINK2 spec/hash-map, Associative Array)
    * [#functions|Function Types]
    * [#delegates|Delegate Types]
    
)

$(H3 $(ID pointers) Pointers)

        A pointer to type `T` has a value which is a reference (address) to another
        object of type `T`. It is commonly called a $(I pointer to T) and its type is
        `T*`. To access the object value, use the `*` dereference operator:
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
int* p;

assert(p == null);
p = new int(5);
assert(p != null);

assert(*p == 5);
(*p)++;
assert(*p == 6);

---

)

        If a pointer contains a $(I null) value, it is not pointing to a valid object.

        When a pointer to $(I T) is dereferenced, it must either contain a $(I null) value,
        or point to a valid object of type $(I T).

        $(WARNING         $(NUMBERED_LIST
        * The behavior when a $(I null) pointer is dereferenced. Typically the program
        will be aborted.
        
))

        $(PITFALL dereferencing a pointer that is not $(I null) and does not point
        to a valid object of type $(I T).)

        To set a pointer to point at an existing object, use the
        `&amp;` <em>address of</em> operator:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
int i = 2;
int* p = &amp;i;

assert(p == &amp;i);
assert(*p == 2);
*p = 4;
assert(i == 4);

---

)
        See also $(LINK2 spec/expression#pointer_arithmetic,Pointer Arithmetic).


$(H2 $(ID user-defined-types)User-Defined Types)

    $(LIST
    * $(LINK2 spec/enum, Enums)
    * $(LINK2 spec/struct, Structs and Unions)
    * $(LINK2 spec/class, Classes)
    * $(LINK2 spec/interface, Interfaces)
    
)

$(H2 $(ID type-conversions) Type Conversions)

    See also: [expression#CastExpression|expression, CastExpression].

$(H3 $(ID pointer-conversions)Pointer Conversions)

    [#pointers|Pointers] implicitly convert to `void*`.

    Casting between pointers and non-pointers is allowed. Some pointer casts
    are disallowed in $(LINK2 spec/memory-safe-d, Memory-Safe-D-Spec).

    $(TIP do not cast any pointer to a non-pointer type that points to data
    allocated by the garbage collector.
    )

$(H3 $(ID implicit-conversions)Implicit Conversions)

    Implicit conversions are used to automatically convert
    types as required. The rules for integers are detailed in the next sections.
    

    An enum can be $(LINK2 spec/enum#named_enums,implicitly converted) to its base
    type, but going the other way requires an explicit
    conversion.

    $(LIST
    * All types implicitly convert to [#noreturn|`noreturn`].
    * Static and dynamic arrays implicitly convert to $(LINK2 spec/arrays#void_arrays,`void[]`).
    * $(LINK2 spec/function#function-pointers-delegates,Function pointers and delegates)
        can convert to covariant types.
    
)

$(H4 $(ID class-conversions) Class Conversions)

    A derived class can be implicitly converted to its base class, but going
    the other way requires an explicit cast. For example:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
class Base {}
class Derived : Base {}
Base bd = new Derived();              // implicit conversion
Derived db = cast(Derived)new Base(); // explicit conversion

---

)

    A dynamic array, say `x`, of a derived class can be implicitly converted
    to a dynamic array, say `y`, of a base class iff elements of `x` and `y` are
    qualified as being either both `const` or both `immutable`.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
class Base {}
class Derived : Base {}
const(Base)[] ca = (const(Derived)[]).init; // `const` elements
immutable(Base)[] ia = (immutable(Derived)[]).init; // `immutable` elements

---

)

    A static array, say `x`, of a derived class can be implicitly converted
    to a static array, say `y`, of a base class iff elements of `x` and `y` are
    qualified as being either both `const` or both `immutable` or both mutable
    (neither `const` nor `immutable`).

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
class Base {}
class Derived : Base {}
Base[3] ma = (Derived[3]).init; // mutable elements
const(Base)[3] ca = (const(Derived)[3]).init; // `const` elements
immutable(Base)[3] ia = (immutable(Derived)[3]).init; // `immutable` elements

---

)

$(H3 $(ID integer-promotions)Integer Promotions)

    Integer Promotions are conversions of the following types:
    

    $(TABLE_ROWS
Integer Promotions
    * + from
+ to

    * -     `bool`
-     `int`
    

    * -     `byte`
-     `int`
    

    * -     `ubyte`
-     `int`
    

    * -     `short`
-     `int`
    

    * -     `ushort`
-     `int`
    

    * -     `char`
-     `int`
    

    * -     `wchar`
-     `int`
    

    * -     `dchar`
-     `uint`
    

    
)

    If an enum has as a base type one of the types
    in the left column, it is converted to the type in the right
    column.
    

    Integer promotion applies to each operand of a binary expression:

    $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
void fun()
{
    byte a;
    auto b = a + a;
    static assert(is(typeof(b) == int));
    // error: can't implicitly convert expression of type int to byte:
    //byte c = a + a;

    ushort d;
    // error: can't implicitly convert expression of type int to ushort:
    //d = d * d;
    int e = d * d; // OK
    static assert(is(typeof(int() * d) == int));

    dchar f;
    static assert(is(typeof(f - f) == uint));
}

---
    
)

    Rationale: $(LIST
* 32-bit integer operations are often faster than smaller integer types
      for single variables on modern architectures.
* Promotion helps avoid accidental overflow which is more common with small integer types.

)
    

$(H3 $(ID usual-arithmetic-conversions)Usual Arithmetic Conversions)

    The usual arithmetic conversions convert operands of binary
    operators to a common type. The operands must already be
    of arithmetic types.
    The following rules are applied
    in order, looking at the base type:
    

    $(NUMBERED_LIST
    * If either operand is `real`, the other operand is
    converted to `real`.

    * Else if either operand is `double`, the other operand is
    converted to `double`.

    * Else if either operand is `float`, the other operand is
    converted to `float`.

    * Else the integer promotions above are done on each operand,
    followed by:

    $(NUMBERED_LIST
        * If both are the same type, no more conversions are done.

        * If both are signed or both are unsigned, the
        smaller type is converted to the larger.

        * If the signed type is larger than the unsigned
        type, the unsigned type is converted to the signed type.

        * The signed type is converted to the unsigned type.
    
)
    
    
)

    Rationale: The above rules follow C99, which makes porting code from C easier.

    $(B Example:) Signed and unsigned conversions:
    $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
int i;
uint u;
static assert(is(typeof(i + u) == uint));
static assert(is(typeof(short() + u) == uint));
static assert(is(typeof(ulong() + i) == ulong));
static assert(is(typeof(long() - u) == long));
static assert(is(typeof(long() * ulong()) == ulong));

---
    
)

    $(B Example:) Floating point:
    $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
float f;
static assert(is(typeof(f + ulong()) == float));

double d;
static assert(is(typeof(f * d) == double));
static assert(is(typeof(real() / d) == real));

---
    
)

$(H4 $(ID enum-ops) Enum Operations)

    If one or both of the operand types is an $(LINK2 spec/enum, Enums) after
    undergoing the above conversions, the result type is determined as follows:

    $(NUMBERED_LIST
    * If the operands are the same type, the result will be of
    that type.
    * If one operand is an enum  and the other is the base type
    of that  enum, the result is the base type.
    * If the two operands are different  enums,
    the result is the closest base type common to both. A base type being closer
    means there is a shorter sequence of conversions to base type to get there from the
    original type.
    
)

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
enum E { a, b, c }
enum F { x, y }

void test()
{
    E e = E.a;
    e = e | E.c;
    //e = e + 4; // error, can't assign int to E
    int i = e + 4;
    e += 4; // OK, see below

    F f;
    //f = e | f; // error, can't assign int to F
    i = e | f;
}

---

)

    Note: Above, `e += 4` compiles because the
    $(LINK2 spec/expression#assignment_operator_expressions,operator assignment)
    is equivalent to `e = cast(E)(e + 4)`.

$(H3 $(ID disallowed-conversions) Preserving Bit Patterns)

    Integer values cannot be implicitly converted to another
    type that cannot represent the integer bit pattern after integral
    promotion. For example:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
ubyte  u1 = -1;       // error, -1 cannot be represented in a ubyte
ushort u2 = -1;       // error, -1 cannot be represented in a ushort
uint   u3 = int(-1);  // ok, -1 can be represented in an int, which can be converted to a uint
ulong  u4 = long(-1); // ok, -1 can be represented in a long, which can be converted to a ulong

---

)

$(LIST
* Floating point types cannot be implicitly converted to
      integral types.
* Complex or imaginary floating point types cannot be implicitly converted
      to non-complex floating point types.
* Non-complex floating point types cannot be implicitly converted to imaginary floating
      point types.


)
$(H3 $(ID vrp) Value Range Propagation)

    Besides type-based implicit conversions, D allows certain integer
        expressions to implicitly convert to a narrower type after
        integer promotion. This works by analysing the minimum and
        maximum possible range of values for each expression.
        If that range of values matches or is a subset of a narrower
        target type's value range, implicit
        conversion is allowed. If a subexpression is known at compile-time,
        that can further narrow the range of values.

    $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
void fun(char c, int i, ubyte b)
{
    // min is c.min + 100 &gt; short.min
    // max is c.max + 100 &lt; short.max
    short s = c + 100; // OK

    ubyte j = i &amp; 0x3F; // OK, 0 ... 0x3F
    //ubyte k = i &amp; 0x14A; // error, 0x14A &gt; ubyte.max
    ushort k = i &amp; 0x14A; // OK

    k = i &amp; b; // OK, 0 ... b.max
    //b = b + b; // error, b.max + b.max &gt; b.max
    s = b + b; // OK, 0 ... b.max + b.max
}

---
    
)
    Note the implementation does not track the range of possible values for
    mutable variables:

    $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
void fun(int i)
{
    ushort s = i &amp; 0xff; // OK
    // s is now assumed to be s.min ... s.max, not 0 ... 0xff
    //ubyte b = s; // error
    ubyte b = s &amp; 0xff; // OK

    const int c = i &amp; 0xff;
    // c's range is fixed and known
    b = c; // OK
}

---
    
)
$(LIST
* For more information, see $(LINK2 https://digitalmars.com/articles/b62.html, the dmc article).
* See also: <a href="https://en.wikipedia.org/wiki/Value_range_analysis">https://en.wikipedia.org/wiki/Value_range_analysis</a>.



)
$(H2 $(ID bool) `bool`)

The bool type is a byte-size type that can only hold the value `true` or
`false`.

The only operators that can accept operands of type bool are: &
|, `^`, &`=`, |`=`, `^=`, !,
&&, ||, and `?:`.

A `bool` value can be implicitly converted to any integral type, with
`false` becoming 0 and `true` becoming 1.

The numeric literals `0` and `1` can be implicitly converted to the `bool`
values `false` and `true`, respectively. Casting an expression to `bool` means
testing for `0` or `!=0` for arithmetic types, and `null` or `!=null` for
pointers or references.


$(H2 $(ID functions) Function Types)

A function type has the form:

$(PRE $(CLASS GRAMMAR_INFORMATIVE)[declaration#StorageClasses|declaration, StorageClasses]$(SUBSCRIPT opt) [#Type|Type] [function#Parameters|function, Parameters] [function#FunctionAttributes|function, FunctionAttributes]$(SUBSCRIPT opt)
)

Function types are not included in the [#Type|Type] grammar.
A function type e.g. `int(int)` $(LINK2 spec/declaration#alias-function,can be aliased).
A function type is only used for type tests or as the target type of a pointer.

Instantiating a function type is illegal. Instead, a pointer to function
or delegate can be used. Those have these type forms respectively:

$(PRE $(CLASS GRAMMAR_INFORMATIVE)[#Type|Type] `function` [function#Parameters|function, Parameters] [function#FunctionAttributes|function, FunctionAttributes]$(SUBSCRIPT opt)
[#Type|Type] `delegate` [function#Parameters|function, Parameters] [function#MemberFunctionAttributes|function, MemberFunctionAttributes]$(SUBSCRIPT opt)
)

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
void f(int);
alias Fun = void(int);
static assert(is(typeof(f) == Fun));
static assert(is(Fun* == void function(int)));

---

)

See $(LINK2 spec/function#function-pointers,Function Pointers).

$(H3 $(ID delegates) Delegates)

Delegates are an aggregate of two pieces of data, either:
$(LIST
* An object reference and a pointer to a non-static
  $(LINK2 spec/class#member-functions,member function).
* A pointer to a closure and a pointer to a
  $(LINK2 spec/function#nested,nested function).
  The object reference forms the `this` pointer when the function is called.

)

Delegates are declared and initialized similarly to function pointers:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
int delegate(int) dg; // dg is a delegate to a function

class OB
{
    int member(int);
}

void f(OB o)
{
    dg = &amp;o.member; // dg is a delegate to object o and member function member
}

---

)

    Delegates cannot be initialized with static member functions
    or non-member functions.
    

    Delegates are called analogously to function pointers:
    

---
fp(3);   // call func(3)
dg(3);   // call o.member(3)

---

    The equivalent of member function pointers can be constructed
    using $(LINK2 spec/expression#function_literals,anonymous lambda functions):

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
class C
{
    int a;
    int foo(int i) { return i + a; }
}

// mfp is the member function pointer
auto mfp = function(C self, int i) { return self.foo(i); };
auto c = new C();  // create an instance of C
mfp(c, 1);  // and call c.foo(1)

---

)

$(H2 $(ID typeof) `typeof`)

$(PRE $(CLASS GRAMMAR)
$(B $(ID Typeof) Typeof):
    `typeof (` [expression#Expression|expression, Expression] `)`
    `typeof (` `return` `)`

)

                `typeof` is a way to specify a type based on the type
        of an expression. For example:
        

---
void func(int i)
{
    typeof(i) j;       // j is of type int
    typeof(3 + 6.0) x; // x is of type double
    typeof(1)* p;      // p is of type pointer to int
    int[typeof(p)] a;  // a is of type int[int*]

    writeln(typeof('c').sizeof); // prints 1
    double c = cast(typeof(1.0))j; // cast j to double
}

---

                $(I Expression) is not evaluated, it is used purely to
        generate the type:
        

---
void func()
{
    int i = 1;
    typeof(++i) j; // j is declared to be an int, i is not incremented
    writeln(i);  // prints 1
}

---

        If <em>Expression</em> is a
        $(LINK2 spec/template#variadic-templates,$(I ValueSeq))
        it will produce a <em>TypeSeq</em> containing the types of each element.

        Special cases: 
    $(NUMBERED_LIST
        * `typeof(return)` will, when inside a function scope,
        give the return type of that function.
        
        * $(ID typeof-this) `typeof(this)` will generate the type of what `this`
        would be in a non-static member function, even if not in a member
        function.
        
        * Analogously, `typeof(super)` will generate the type of what
        `super` would be in a non-static member function.
        

---
class A { }

class B : A
{
    typeof(this) x;  // x is declared to be a B
    typeof(super) y; // y is declared to be an A
}

struct C
{
    static typeof(this) z;  // z is declared to be a C

    typeof(super) q; // error, no super struct for C
}

typeof(this) r;   // error, no enclosing struct or class

---
    
)

        If the expression is a $(LINK2 spec/function#property-functions,        Property Function), `typeof` gives its return type.
        

---
struct S
{
    @property int foo() { return 1; }
}
typeof(S.foo) n;  // n is declared to be an int

---

        If the expression is a $(LINK2 , spec/template),
        `typeof` gives the type `void`.
        

---
template t {}
static assert(is(typeof(t) == void));

---

        $(TIP         $(NUMBERED_LIST
        * $(I Typeof) is most useful in writing generic
        template code.
        
)
        )

$(H2 $(ID mixin_types) Mixin Types)

$(PRE $(CLASS GRAMMAR)
$(B $(ID MixinType) MixinType):
    `mixin (` [expression#ArgumentList|expression, ArgumentList] `)`

)

    Each [expression#AssignExpression|expression, AssignExpression] in the $(I ArgumentList) is
        evaluated at compile time, and the result must be representable
        as a string.
        The resulting strings are concatenated to form a string.
        The text contents of the string must be compilable as a valid
        [type#Type|type, Type], and is compiled as such.

---
void test(mixin("int")* p) // int* p
{
    mixin("int")[] a;      // int[] a;
    mixin("int[]") b;      // int[] b;
}

---


$(H2 $(ID aliased-types) Aliased Types)

$(H3 $(ID size_t) `size_t`)

    `size_t` is an alias to one of the unsigned integral basic types,
    and represents a type that is large enough to represent an offset into
    all addressable memory.

$(H3 $(ID ptrdiff_t) `ptrdiff_t`)
    `ptrdiff_t` is an alias to the signed integral basic type the same size as `size_t`.

$(H3 $(ID string) `string`)

    A $(LINK2 spec/arrays#strings,$(I string) is a special case of an array.)

$(H3 $(ID noreturn) `noreturn`)

    `noreturn` is the $(LINK2 https://en.wikipedia.org/wiki/Bottom_type, bottom type)
    which can implicitly convert to any type, including `void`.
    A value of type `noreturn` will never be produced and the compiler can
    optimize such code accordingly.

    A function that $(LINK2 spec/function#function-return-values,never returns)
    has the return type `noreturn`. This can
    occur due to an infinite loop or always throwing an exception.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
noreturn abort(const(char)[] message);

int example(int i)
{
    if (i &lt; 0)
    {
        // abort does not return, so it doesn't need to produce an int
        int val = abort("less than zero");
    }
    // ternary expression's common type is still int
    return i != 0 ? 1024 / i : abort("calculation went awry.");
}

---

)

    `noreturn` is defined as `typeof(*null)`. This is because
    dereferencing a null literal halts execution.


declaration, Declarations, property, Properties
)



Link_References:
	ACC = Associated C Compiler
+/
module type.dd;