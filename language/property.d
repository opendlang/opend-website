// just docs: Properties
/++





        Every symbol, type, and expression has properties that can be queried:

$(TABLE_ROWS
Property Examples
* + Expression
+     Value

* - `int.sizeof`
- yields 4

* - `float.nan`
-  yields the floating point nan (Not A Number) value

* - `(float).nan`
-        yields the floating point nan value

* - `(3).sizeof`
- yields 4 (because 3 is an int)


* - `int.init`
-   default initializer for ints

* - `int.mangleof`
-       yields the string "i"

* - `int.stringof`
-       yields the string "int"

* - `(1+2).stringof`
-     yields the string "1 + 2"


)

<br>

$(TABLE_ROWS
Properties for All Types
* +  Property
+ Description

* - [#init|`.init`]
-      initializer

* - [#sizeof|`.sizeof`]
- size in bytes

* - [#alignof|`.alignof`]
- alignment size

* - [#mangleof|`.mangleof`]
- string representing the 'mangled' representation of the type

* - [#stringof|`.stringof`]
- string representing the source representation of the type


)

<br>

$(TABLE_ROWS
Properties for Integral Types
* + Property
+ Description

* - `.init`
-      initializer

* - `.max`
- maximum value

* - `.min`
- minimum value


)

<br>

$(TABLE_ROWS
Properties for Floating Point Types
* + Property
+ Description

* - `.init`
- initializer (NaN)

* - `.infinity`
- infinity value

* - `.nan`
- NaN value

* - `.dig`
- number of decimal digits of precision

* - `.epsilon`
- smallest increment to the value 1

* - `.mant_dig`
- number of bits in mantissa

* - `.max_10_exp`
- maximum int value such that 10$(SUPERSCRIPT `max_10_exp`) is representable

* - `.max_exp`
- maximum int value such that 2$(SUPERSCRIPT `max_exp-1`) is representable

* - `.min_10_exp`
- minimum int value such that 10$(SUPERSCRIPT `min_10_exp`) is representable as a normalized value

* - `.min_exp`
- minimum int value such that 2$(SUPERSCRIPT `min_exp-1`) is representable as a normalized value

* - `.max`
- largest representable value that's not infinity


* - `.min_normal`
- smallest representable normalized value that's not 0

* - `.re`
- real part

* - `.im`
- imaginary part


)

<br>

$(TABLE_ROWS
Properties for Class Types
* + Property
+ Description

* - [#classinfo|`.classinfo`]
- Information about the dynamic type of the class


)

$(H2 $(ID init) .init Property)

        `.init` produces a constant expression that is the default
        initializer. If applied to a type, it is the default initializer
        for that type. If applied to a variable or field, it is the
        default initializer for that variable or field's type.
        

---
int a;
int b = 1;

int.init // is 0
a.init   // is 0
b.init   // is 0

struct Foo
{
    int a;
    int b = 7;
}

Foo.init.a  // is 0
Foo.init.b  // is 7

---

    $(B Note:) `.init` produces a default initialized object, not
    default constructed. If there is a default constructor for an object,
    it may produce a different value.

    $(NUMBERED_LIST
        * If `T` is a nested struct, the context pointer in `T.init`
        is `null`.

---
void main()
{
    int x;
    struct S
    {
        void foo() { x = 1; }  // access x in enclosing scope via context pointer
    }
    S s1;           // OK. S() correctly initialize its context pointer.
    S s2 = S();     // OK. same as s1
    S s3 = S.init;  // Bad. the context pointer in s3 is null
    s3.foo();       // Access violation
}

---

        * If `T` is a struct which has `@disable this();`, `T.init`
        might return a logically incorrect object.

---
struct S
{
    int x;
    @disable this();
    this(int n) { x = n; }
    invariant { assert(x &gt; 0); }
    void check() {}
}

void main()
{
  //S s1;           // Error: variable s1 initializer required for type S
  //S s2 = S();     // Error: constructor S.this is not callable
                    // because it is annotated with @disable
    S s3 = S.init;  // Bad. s3.x == 0, and it violates the invariant of S
    s3.check();     // Assertion failure
}

---
    
)

$(H2 $(ID stringof) .stringof Property)

        `.stringof` produces a constant string that is the
        source representation of its prefix.
        If applied to a type, it is the string for that type.
        If applied to an expression, it is the source representation
        of that expression. The expression will not be evaluated.
        

---
module test;
import std.stdio;

struct Dog { }

enum Color { Red }

int i = 4;

void main()
{
    writeln((1+2).stringof);       // "1 + 2"
    writeln(Dog.stringof);         // "Dog"
    writeln(test.Dog.stringof);    // "Dog"
    writeln(int.stringof);         // "int"
    writeln((int*[5][]).stringof); // "int*[5][]"
    writeln(Color.Red.stringof);   // "Red"
    writeln((5).stringof);         // "5"

    writeln((++i).stringof);       // "i += 1"
    writeln(i);                    // 4
}

---

    $(WARNING The string representation for a type or expression
    can vary.)

    $(TIP Do not use `.stringof` for code generation.
    Instead use the
    $(LINK2 spec/traits#identifier,identifier) trait,
    or one of the Phobos helper functions such as $(REF fullyQualifiedName, std,traits).)

$(H2 $(ID sizeof) .sizeof Property)

        `e.sizeof` gives the size in bytes of the expression
        `e`.
        

        When getting the size of a member, it is not necessary for
        there to be a $(I this) object:
        

---
struct S
{
    int a;
    static int foo()
    {
        return a.sizeof; // returns 4
    }
}

void test()
{
    int x = S.a.sizeof; // sets x to 4
}

---

        `.sizeof` applied to a class object returns the size of
        the class reference, not the class instantiation.

$(H2 $(ID alignof) .alignof Property)

        `.alignof` gives the aligned size of an expression or type.
        For example, an aligned size of 1 means that it is aligned on
        a byte boundary, 4 means it is aligned on a 32 bit boundary.
        

    $(WARNING the actual aligned size.)

    $(TIP Be particularly careful when laying out an object that must
    line up with an externally imposed layout. Data misalignment can result in
    particularly pernicious bugs. It's often worth putting in an `assert` to assure
    it is correct.)

$(H2 $(ID mangleof) .mangleof Property)

    Mangling refers to how a symbol is represented in text form in the
    generated object file. `.mangleof` returns a string literal
    of the representation of the type or symbol it is applied to.
    The mangling of types and symbols with D linkage is defined by
    $(LINK2 spec/abi#name_mangling,Name Mangling).
    

    $(WARNING     $(NUMBERED_LIST
    * whether a leading underscore is added to a symbol
    * the mangling of types and symbols with non-D linkage.
    For C and C++ linkage, this will typically
    match what the associated C or C++ compiler does.
    
)
    )

$(H2 $(ID classinfo) .classinfo Property)

`.classinfo` provides information about the dynamic type of a class
object. It returns a reference to type $(LINK2 phobos/object, TypeInfo_Class).

`.classinfo` applied to an interface gives the information for the
interface, not the class it might be an instance of.

$(H2 $(ID classproperties) User-Defined Properties)

        User-defined properties can be created using $(LINK2 function.html#property-functions, Property Functions).

type, Types, attribute, Attributes




Link_References:
	ACC = Associated C Compiler
+/
module property.dd;