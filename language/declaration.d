// just docs: Declarations
/++





$(H2 $(ID grammar) Grammar)

<em>Declaration</em> can be used inside a function body for a [statement#DeclarationStatement|statement, DeclarationStatement],
as well as outside a function as it is included in [module#DeclDef|module, DeclDef].

$(PRE $(CLASS GRAMMAR)
$(B $(ID Declaration) Declaration):
    [function#FuncDeclaration|function, FuncDeclaration]
    [#VarDeclarations|VarDeclarations]
    [#AliasDeclaration|AliasDeclaration]
    [#AliasAssign|AliasAssign]
    [#AggregateDeclaration|AggregateDeclaration]
    [enum#EnumDeclaration|enum, EnumDeclaration]
    [module#ImportDeclaration|module, ImportDeclaration]
    [version#ConditionalDeclaration|version, ConditionalDeclaration]
    [version#StaticForeachDeclaration|version, StaticForeachDeclaration]
    [version#StaticAssert|version, StaticAssert]
    [template#TemplateDeclaration|template, TemplateDeclaration]
    [template-mixin#TemplateMixinDeclaration|template-mixin, TemplateMixinDeclaration]
    [template-mixin#TemplateMixin|template-mixin, TemplateMixin]

)


$(H3 $(ID aggregates) Aggregates)

$(PRE $(CLASS GRAMMAR)
$(B $(ID AggregateDeclaration) AggregateDeclaration):
    [class#ClassDeclaration|class, ClassDeclaration]
    [interface#InterfaceDeclaration|interface, InterfaceDeclaration]
    [struct#StructDeclaration|struct, StructDeclaration]
    [struct#UnionDeclaration|struct, UnionDeclaration]

)

$(H3 $(ID variable-declarations) Variable Declarations)

$(PRE $(CLASS GRAMMAR)
$(B $(ID VarDeclarations) VarDeclarations):
    [#StorageClasses|StorageClasses]$(SUBSCRIPT opt) [type#BasicType|type, BasicType] [type#TypeSuffixes|type, TypeSuffixes]$(SUBSCRIPT opt) [#IdentifierInitializers|IdentifierInitializers] `;`
    [#AutoDeclaration|AutoDeclaration]

$(B $(ID IdentifierInitializers) IdentifierInitializers): $(ID DeclaratorIdentifierList)Declarators, DeclaratorIdentifierList
    [#IdentifierInitializer|IdentifierInitializer]
    [#IdentifierInitializer|IdentifierInitializer] `,` IdentifierInitializers

$(B $(ID IdentifierInitializer) IdentifierInitializer): $(ID DeclaratorIdentifier)DeclaratorInitializer, DeclaratorIdentifier
    $(LINK2 lex#Identifier, Identifier)
    $(LINK2 lex#Identifier, Identifier) [template#TemplateParameters|template, TemplateParameters]$(SUBSCRIPT opt) `=` [#Initializer|Initializer]

$(B $(ID Declarator) Declarator): $(ID VarDeclarator)VarDeclarator
    [type#TypeSuffixes|type, TypeSuffixes]$(SUBSCRIPT opt) $(LINK2 lex#Identifier, Identifier)

)

    See also:
$(LIST
* [#declaration_syntax|Declaration Syntax]
* [#AutoDeclaration|AutoDeclaration]
* $(LINK2 spec/template#variable-template,Variable Templates)


)
$(H3 $(ID storage-classes) Storage Classes)

    See [#typequal_vs_storageclass|Type Classes vs. Storage Classes].

$(PRE $(CLASS GRAMMAR)
$(B $(ID StorageClasses) StorageClasses):
    [#StorageClass|StorageClass]
    [#StorageClass|StorageClass] StorageClasses

$(B $(ID StorageClass) StorageClass):
    [attribute#LinkageAttribute|attribute, LinkageAttribute]
    [attribute#AlignAttribute|attribute, AlignAttribute]
    [attribute#AtAttribute|attribute, AtAttribute]
    $(LINK2 spec/attribute#deprecated,`deprecated`)
    $(LINK2 spec/enum#manifest_constants,`enum`)
    $(LINK2 spec/attribute#static,`static`)
    [#extern|`extern`]
    $(LINK2 spec/class#abstract,`abstract`)
    $(LINK2 spec/class#final,`final`)
    $(LINK2 spec/function#virtual-functions,`override`)
    $(LINK2 spec/class#synchronized-classes,`synchronized`)
    [#auto-declaration|`auto`]
    $(LINK2 spec/attribute#scope,`scope`)
    $(LINK2 spec/const3, Type Qualifiers)
    $(LINK2 spec/const3, Type Qualifiers)
    $(LINK2 spec/const3#inout,`inout`)
    $(LINK2 spec/const3#shared,`shared`)
    $(LINK2 spec/attribute#gshared,`__gshared`)
    [attribute#Property|attribute, Property]
    $(LINK2 spec/function#nothrow-functions,`nothrow`)
    $(LINK2 spec/function#pure-functions,`pure`)
    [#ref-storage|`ref`]

)

$(H3 $(ID initializers) Initializers)

$(PRE $(CLASS GRAMMAR)
$(B $(ID Initializer) Initializer):
    [#VoidInitializer|VoidInitializer]
    [#NonVoidInitializer|NonVoidInitializer]

$(B $(ID NonVoidInitializer) NonVoidInitializer):
    [expression#AssignExpression|expression, AssignExpression]$(ID ExpInitializer)ExpInitializer
    [expression#ArrayLiteral|expression, ArrayLiteral]$(ID ArrayInitializer)ArrayInitializer
    [struct#StructInitializer|struct, StructInitializer]$(ID StructInitializer)StructInitializer

)

See also [#VoidInitializer|VoidInitializer].

$(H2 $(ID declaration_syntax) Declaration Syntax)

Declaration syntax generally reads right to left, including arrays:

---
int x;    // x is an int
int* x;   // x is a pointer to int
int** x;  // x is a pointer to a pointer to int

int[] x;  // x is an array of ints
int*[] x; // x is an array of pointers to ints
int[]* x; // x is a pointer to an array of ints

int[3] x;     // x is a static array of 3 ints
int[3][5] x;  // x is a static array of 5 static arrays of 3 ints
int[3]*[5] x; // x is a static array of 5 pointers to static arrays of 3 ints

---

See $(LINK2 spec/type#pointers,Pointers), $(LINK2 spec/arrays, Arrays)
and [type#TypeSuffix|type, TypeSuffix].

$(H3 $(ID pointers-to-functions) Function Pointers)

$(LINK2 spec/function#function-pointers,Function Pointers)
are declared using the `function` keyword:


---
int function(char) x; // x is a pointer to
                     // a function taking a char argument
                     // and returning an int
int function(char)[] x; // x is an array of
                     // pointers to functions
                     // taking a char argument
                     // and returning an int

---

$(H3 $(ID c-style-declarations) C-Style Declarations)

C-style array, function pointer and pointer to array declarations are
not supported. The following C declarations are for comparison only:


```cpp
int x[3];          // C static array of 3 ints
int x[3][5];       // C static array of 3 arrays of 5 ints

int (*x[5])[3];    // C static array of 5 pointers to static arrays of 3 ints
int (*x)(char);    // C pointer to a function taking a char argument
                   // and returning an int
int (*[] x)(char); // C array of pointers to functions
                   // taking a char argument and returning an int

```

Rationale: $(LIST
* In D types are straightforward to read from right to left,
  unlike in C where parentheses are sometimes required and the type is
  read iteratively using the clockwise/spiral rule.
* For a C function pointer declaration `a (*b)(c);` a C parser needs
  to attempt a type lookup in order to parse it unambiguously - it
  could be a call to a function called `a` which returns a function
  pointer, which is immediately called. D function pointer syntax
  is unambiguous, avoiding the need for types to be forward declared.

)


$(H3 $(ID declaring-multiple-symbols) Declaring Multiple Symbols)

In a declaration declaring multiple symbols, all the declarations
must be of the same type:


---
int x, y;   // x and y are ints
int* x, y;  // x and y are pointers to ints
int[] x, y; // x and y are arrays of ints

---

This is in contrast to C:

```cpp
int x, *y;  // x is an int, y is a pointer to int
int x[], y; // x is an array/pointer, y is an int

```

$(H2 $(ID auto-declaration)Implicit Type Inference)

$(PRE $(CLASS GRAMMAR)
$(B $(ID AutoDeclaration) AutoDeclaration):
    [#StorageClasses|StorageClasses] [#AutoAssignments|AutoAssignments] `;`

$(B $(ID AutoAssignments) AutoAssignments):
    [#AutoAssignment|AutoAssignment]
    AutoAssignments `,` [#AutoAssignment|AutoAssignment]

$(B $(ID AutoAssignment) AutoAssignment):
    $(LINK2 lex#Identifier, Identifier) [template#TemplateParameters|template, TemplateParameters]$(SUBSCRIPT opt) `=` [#Initializer|Initializer]

)

        If a declaration starts with a $(I StorageClass) and has
        a $(I NonVoidInitializer) from which the type can be inferred,
        the type on the declaration can be omitted.
        

---
static x = 3;      // x is type int
auto y = 4u;       // y is type uint

auto s = "Apollo"; // s is type immutable(char)[] i.e., string

class C { ... }

auto c = new C();  // c is a handle to an instance of class C

---

        The $(I NonVoidInitializer) cannot contain forward references
        (this restriction may be removed in the future).
        The implicitly inferred type is statically bound
        to the declaration at compile time, not run time.
        

        An [expression#ArrayLiteral|expression, ArrayLiteral]
        is inferred to be a dynamic array
        type rather than a static array:

---
auto v = ["resistance", "is", "useless"]; // type is string[], not string[3]

---


$(H2 $(ID alias) Alias Declarations)

    Note: New code should use the <em>AliasAssignments</em> form only.

$(PRE $(CLASS GRAMMAR)
$(B $(ID AliasDeclaration) AliasDeclaration):
    `alias` [#StorageClasses|StorageClasses]$(SUBSCRIPT opt) [type#BasicType|type, BasicType] [type#TypeSuffixes|type, TypeSuffixes]$(SUBSCRIPT opt) [#Identifiers|Identifiers] `;`
    `alias` [#StorageClasses|StorageClasses]$(SUBSCRIPT opt) [type#BasicType|type, BasicType] [function#FuncDeclarator|function, FuncDeclarator] `;`
    `alias` [#AliasAssignments|AliasAssignments] `;`

$(B $(ID Identifiers) Identifiers):
    $(LINK2 lex#Identifier, Identifier)
    $(LINK2 lex#Identifier, Identifier) `,` Identifiers

$(B $(ID AliasAssignments) AliasAssignments):
    [#AliasAssignment|AliasAssignment]
    AliasAssignments `,` [#AliasAssignment|AliasAssignment]

$(B $(ID AliasAssignment) AliasAssignment):
    $(LINK2 lex#Identifier, Identifier) [template#TemplateParameters|template, TemplateParameters]$(SUBSCRIPT opt) `=` [#StorageClasses|StorageClasses]$(SUBSCRIPT opt) [type#Type|type, Type]
    $(LINK2 lex#Identifier, Identifier) [template#TemplateParameters|template, TemplateParameters]$(SUBSCRIPT opt) `=` [expression#FunctionLiteral|expression, FunctionLiteral]
    $(LINK2 lex#Identifier, Identifier) [template#TemplateParameters|template, TemplateParameters]$(SUBSCRIPT opt) `=` [#StorageClasses|StorageClasses]$(SUBSCRIPT opt) [type#Type|type, Type] [function#Parameters|function, Parameters] [function#MemberFunctionAttributes|function, MemberFunctionAttributes]$(SUBSCRIPT opt)

)

    An $(I AliasDeclaration) creates a symbol name that refers to a type or another symbol.
        That name can then be used anywhere that the target may appear.
        The following can be aliased:
    
$(LIST
* [#alias-type|Types]
$(LIST
* [#alias-function|Function Types] (with default arguments)

)
* [#alias-variable|Variables]
* Manifest Constants
* Modules
* Packages
* Functions
* [#alias-overload|Overload Sets]
* $(LINK2 spec/expression#function-literal-alias,Function Literals)
* Templates
* Template Instantiations
* Other Alias Declarations


)
$(H3 $(ID alias-type) Type Aliases)

---
alias myint = abc.Foo.bar;

---

                Aliased types are semantically identical to the types they are aliased to. The
        debugger cannot distinguish between them, and there is no difference as far as function
        overloading is concerned. For example:
        

---
alias myint = int;

void foo(int x) { ... }
void foo(myint m) { ... } // error, multiply defined function foo

---

                Type aliases can sometimes look indistinguishable from
        other symbol aliases:
        

---
alias abc = foo.bar; // is it a type or a symbol?

---

        $(TIP Other than when aliasing simple basic type names,
        type alias names should be Capitalized.)

$(H3 $(ID alias-symbol) Symbol Aliases)

    A symbol can be declared as an $(I alias) of another symbol.
        For example:
    

---
import planets;

alias myAlbedo = planets.albedo;
...
int len = myAlbedo("Saturn"); // actually calls planets.albedo()

---

                The following alias declarations are valid:
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
template Foo2(T) { alias t = T; }
alias t1 = Foo2!(int);
alias t2 = Foo2!(int).t;
alias t3 = t1.t;
alias t4 = t2;

t1.t v1;  // v1 is type int
t2 v2;    // v2 is type int
t3 v3;    // v3 is type int
t4 v4;    // v4 is type int

---

)

                Aliased symbols are useful as a shorthand for a long qualified
        symbol name, or as a way to redirect references from one symbol
        to another:
        

---
version (Win32)
{
    alias myfoo = win32.foo;
}
version (linux)
{
    alias myfoo = linux.bar;
}

---

                Aliasing can be used to 'import' a symbol from an
        $(LINK2 spec/module#import-declaration,        imported module or package) into the current scope:
        

---
static import string;
...
alias strlen = string.strlen;

---

$(H3 $(ID alias-overload) Aliasing an Overload Set)

                Aliases can also 'import' a set of overloaded functions, that can
        be overloaded with functions in the current scope:
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
class B
{
    int foo(int a, uint b) { return 2; }
}

class C : B
{
    // declaring an overload hides any base class overloads
    int foo(int a) { return 3; }
    // redeclare hidden overload
    alias foo = B.foo;
}

void main()
{
    import std.stdio;

    C c = new C();
    c.foo(1, 2u).writeln;   // calls B.foo
    c.foo(1).writeln;       // calls C.foo
}

---

)

$(H3 $(ID alias-variable) Aliasing Variables)

        Variables can be aliased, expressions cannot:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
int i = 0;
alias a = i; // OK
alias b = a; // alias a variable alias
a++;
b++;
assert(i == 2);

//alias c = i * 2; // error
//alias d = i + i; // error

---

)

        Members of an aggregate can be aliased, however non-static
        field aliases cannot be accessed outside their parent type.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
struct S
{
    static int i = 0;
    int j;
    alias a = j; // OK

    void inc() { a++; }
}

alias a = S.i; // OK
a++;
assert(S.i == 1);

alias b = S.j; // allowed
static assert(b.offsetof == 0);
//b++;   // error, no instance of S
//S.a++; // error, no instance of S

S s = S(5);
s.inc();
assert(s.j == 6);
//alias c = s.j; // scheduled for deprecation

---

)

$(H3 $(ID alias-function) Aliasing a Function Type)

        $(LINK2 spec/type#functions,Function types) can be
        aliased:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
alias Fun = int(string);
int fun(string) {return 0;}
static assert(is(typeof(fun) == Fun));

alias MemberFun1 = int() const;
alias MemberFun2 = const int();
// leading attributes apply to the func, not the return type
static assert(is(MemberFun1 == MemberFun2));

---

)
        Type aliases can be used to call a function with different default
        arguments, change an argument from required to default or vice versa:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
import std.stdio : writeln;

void fun(int v = 6)
{
    writeln("v: ", v);
}

void main()
{
    fun();  // prints v: 6

    alias Foo = void function(int=7);
    Foo foo = &amp;fun;
    foo();  // prints v: 7
    foo(8); // prints v: 8
}

---

)
$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
import std.stdio : writefln;

void main()
{
    fun(4);          // prints a: 4, b: 6, c: 7

    Bar bar = &amp;fun;
    //bar(4);           // compilation error, because the `Bar` alias
                        // requires an explicit 2nd argument
    bar(4, 5);          // prints a: 4, b: 5, c: 9
    bar(4, 5, 6);       // prints a: 4, b: 5, c: 6

    Baz baz = &amp;fun;
    baz();              // prints a: 2, b: 3, c: 4
}

alias Bar = void function(int, int, int=9);
alias Baz = void function(int=2, int=3, int=4);

void fun(int a, int b = 6, int c = 7)
{
    writefln("a: %d, b: %d, c: %d", a, b, c);
}

---

)

$(H3 $(ID AliasAssign) Alias Assign)

$(PRE $(CLASS GRAMMAR)
$(B $(ID AliasAssign) AliasAssign):
    $(LINK2 lex#Identifier, Identifier) `=` [type#Type|type, Type]

)

        An [#AliasDeclaration|AliasDeclaration] can have a new value assigned to it with an
        $(I AliasAssign):

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
template Gorgon(T)
{
    alias A = long;
    A = T; // assign new value to A
    alias Gorgon = A;
}
pragma(msg, Gorgon!int); // prints int

---

)

$(LIST
* The $(I AliasAssign) and its corresponding $(I AliasDeclaration) must both be
declared in the same [template#TemplateDeclaration|template, TemplateDeclaration].

* The corresponding $(I AliasDeclaration) must appear lexically before the
$(I AliasAssign).

* The corresponding $(I AliasDeclaration) may not refer to overloaded symbols.

* The value of an $(I AliasDeclaration) or left hand side (lvalue) of an $(I AliasAssign) may not be used prior
to another $(I AliasAssign) to the same lvalue other than in the right hand side of that $(I AliasAssign).


)

        $(TIP         $(I AliasAssign) is particularly useful when using an iterative
        computation rather than a recursive one, as it avoids creating
        the large number of intermediate templates that the recursive one
        engenders.)

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
import std.meta : AliasSeq;

static if (0) // recursive method for comparison
{
    template Reverse(T...)
    {
        static if (T.length == 0)
            alias Reverse = AliasSeq!();
        else
            alias Reverse = AliasSeq!(Reverse!(T[1 .. T.length]), T[0]);
    }
}
else // iterative method minimizes template instantiations
{
    template Reverse(T...)
    {
        alias A = AliasSeq!();
        static foreach (t; T)
            A = AliasSeq!(t, A); // Alias Assign
        alias Reverse = A;
    }
}

enum X = 3;
alias TK = Reverse!(int, const uint, X);
pragma(msg, TK); // prints tuple(3, (const(uint)), (int))

---

)

$(H3 $(ID alias-reassignment) Alias Reassignment)

$(PRE $(CLASS GRAMMAR)
$(B $(ID AliasReassignment) AliasReassignment):
    $(LINK2 lex#Identifier, Identifier) `=` [#StorageClasses|StorageClasses]$(SUBSCRIPT opt) [type#Type|type, Type]
    $(LINK2 lex#Identifier, Identifier) `=` [expression#FunctionLiteral|expression, FunctionLiteral]
    $(LINK2 lex#Identifier, Identifier) `=` [#StorageClasses|StorageClasses]$(SUBSCRIPT opt) [type#BasicType|type, BasicType] [function#Parameters|function, Parameters] [function#MemberFunctionAttributes|function, MemberFunctionAttributes]$(SUBSCRIPT opt)

)

        An alias declaration inside a template can be reassigned a new value.

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
import std.meta : AliasSeq;

template staticMap(alias F, Args...)
{
    alias A = AliasSeq!();
    static foreach (Arg; Args)
        A = AliasSeq!(A, F!Arg); // alias reassignment
    alias staticMap = A;
}

enum size(T) = T.sizeof;
static assert(staticMap!(size, char, wchar, dchar) == AliasSeq!(1, 2, 4));

---
        
)

        The $(I Identifier) must resolve to a lexically preceding [#AliasDeclaration|AliasDeclaration].
        Both must be members of the same [template#TemplateDeclaration|template, TemplateDeclaration].
        

        The right hand side of the $(I AliasReassignment) replaces the right hand side of the
        $(I AliasDeclaration).
        

        Once the $(I AliasDeclaration) has been referred to in any context other than the
        right hand side of an $(I AliasReassignment) it can no longer be reassigned.
        

        Rationale: Alias reassignment can result in faster compile times and lowered memory consumption,
        and requires significantly simpler code than the alternative recursive method.



$(H2 $(ID extern) Extern Declarations)

Variable declarations with the storage class `extern` are not allocated
storage within the module. They must be defined in some other object file with a
matching name which is then linked in.

An `extern` declaration can optionally be followed by an `extern`
$(LINK2 spec/attribute#linkage,linkage attribute). If there is no linkage
attribute it defaults to `extern(D)`:

---
// variable allocated and initialized in this module with C linkage
extern(C) int foo;
// variable allocated outside this module with C linkage
// (e.g. in a statically linked C library or another module)
extern extern(C) int bar;

---

        $(TIP         $(NUMBERED_LIST
        * The primary usefulness of $(I Extern Declarations) is to
        connect with global variables declarations and functions in C or C++ files.
        
))

$(H2 $(ID void_init) Void Initializations)

$(PRE $(CLASS GRAMMAR)
$(B $(ID VoidInitializer) VoidInitializer):
    `void`

)

        Normally, variables are initialized either with an explicit
        [#Initializer|Initializer] or are set to the default value for the
        type of the variable. If the $(I Initializer) is `void`,
        however, the variable is not initialized.
        Void initializers for variables with a type that may contain
        $(LINK2 spec/function#safe-values,unsafe values) (such as types with pointers)
        are not allowed in `@safe` code.
        

        $(WARNING If a void initialized variable's value is
        used before it is set, its value is implementation defined.

---
void bad()
{
    int x = void;
    writeln(x);  // print implementation defined value
}

---
        )

        $(PITFALL If a void initialized variable's value is
        used before it is set, and the value is a reference, pointer or an instance
        of a struct with an invariant, the behavior is undefined.

---
void muchWorse()
{
    char[] p = void;
    writeln(p);  // may result in apocalypse
}

---
        )

        $(TIP         $(NUMBERED_LIST
        * Void initializers are useful when a static array is on the stack,
        but may only be partially used, such as a temporary buffer.
        Void initializers will potentially speed up the code, but they introduce risk, since one must ensure
        that array elements are always set before read.
        * The same is true for structs.
        * Use of void initializers is rarely useful for individual local variables,
        as a modern optimizer will remove the dead store of its initialization if it is
        initialized later.
        * For hot code paths, it is worth profiling to see if the void initializer
        actually improves results.
        
)
        )

$(H2 $(ID global_static_init) Global and Static Initializers)

        The [#Initializer|Initializer] for a global or static variable must be
        evaluatable at compile time.
        Runtime initialization is done with static constructors.
        

        $(WARNING         $(NUMBERED_LIST
        * Whether some pointers can be initialized with the addresses of other
        functions or data.
        
))

$(H2 $(ID typequal_vs_storageclass) Type Qualifiers vs. Storage Classes)

        $(LINK2 spec/const3, Type Qualifiers) and
        [#storage-classes|storage classes] are distinct concepts.

        A $(I type qualifier) creates a derived type from an existing base
        type, and the resulting type may be used to create multiple instances
        of that type.

        For example, the `immutable` type qualifier can be used to
        create variables of immutable type, such as:

---
immutable(int)   x; // typeof(x) == immutable(int)
immutable(int)[] y; // typeof(y) == immutable(int)[]
                    // typeof(y[0]) == immutable(int)

// Type constructors create new types that can be aliased:
alias ImmutableInt = immutable(int);
ImmutableInt z;     // typeof(z) == immutable(int)

---

        A $(I storage class), on the other hand, does not create a new
        type, but describes only the kind of storage used by the variable or
        function being declared. For example, a member function can be declared
        with the `const` storage class to indicate that it does not modify
        its implicit `this` argument:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
struct S
{
    int x;
    int method() const
    {
        //x++;    // Error: this method is const and cannot modify this.x
        return x; // OK: we can still read this.x
    }
}

---

)
        Although some keywords can be
        [#methods-returning-qualified|used as both] a type qualifier and a
        storage class, there are some storage classes that cannot be used to
        construct new types, such as `ref`.

$(H3 $(ID ref-storage) `ref` Storage Class)

        A parameter $(LINK2 spec/function#ref-params,declared with `ref`)
        is passed by reference:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
void func(ref int i)
{
    i++; // modifications to i will be visible in the caller
}

void main()
{
    auto x = 1;
    func(x);
    assert(x == 2);

    // However, ref is not a type qualifier, so the following is illegal:
    //ref(int) y; // Error: ref is not a type qualifier.
}

---

)
        Functions can also be $(LINK2 spec/function#ref-functions,declared as `ref`),
        meaning their return value is passed by reference:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
ref int func2()
{
    static int y = 0;
    return y;
}

void main()
{
    func2() = 2; // The return value of func2() can be modified.
    assert(func2() == 2);

    // However, the reference returned by func2() does not propagate to
    // variables, because the 'ref' only applies to the return value itself,
    // not to any subsequent variable created from it:
    auto x = func2();
    static assert(is(typeof(x) == int)); // N.B.: *not* ref(int);
                                     // there is no such type as ref(int).
    x++;
    assert(x == 3);
    assert(func2() == 2); // x is not a reference to what func2() returned; it
                          // does not inherit the ref storage class from func2().
}

---

)
$(H3 $(ID methods-returning-qualified) Methods Returning a Qualified Type)

        Some keywords, such as `const`, can be used
        both as a type qualifier and a storage class.
        The distinction is determined by the syntax where it appears.

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
struct S
{
    /* Is const here a type qualifier or a storage class?
     * Is the return value const(int), or is this a const function that returns
     * (mutable) int?
     */
    const int* func() // a const function
    {
        //++p;          // error, this.p is const
        //return p;     // error, cannot convert const(int)* to int*
        return null;
    }

    const(int)* func() // a function returning a pointer to a const int
    {
        ++p;          // ok, this.p is mutable
        return p;     // ok, int* can be implicitly converted to const(int)*
    }

    int* p;
}

---
        
)

        $(TIP To avoid confusion, the type qualifier
        syntax with parentheses should be used for return types,
        and function storage classes should be written on the right-hand side of the
        declaration instead of the left-hand side where it may be visually
        confused with the return type:

---
struct S
{
    // Now it is clear that the 'const' here applies to the return type:
    const(int) func1() { return 1; }

    // And it is clear that the 'const' here applies to the function:
    int func2() const { return 1; }
}

---
        )

module, Modules, type, Types





Link_References:
	ACC = Associated C Compiler
+/
module declaration.dd;