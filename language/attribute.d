// just docs: Attributes
/++





$(PRE $(CLASS GRAMMAR)
$(B $(ID AttributeSpecifier) AttributeSpecifier):
    [#Attribute|Attribute] `:`
    [#Attribute|Attribute] [#DeclarationBlock|DeclarationBlock]

$(B $(ID Attribute) Attribute):
    [#AlignAttribute|AlignAttribute]
    [#AtAttribute|AtAttribute]
    [#DeprecatedAttribute|DeprecatedAttribute]
    [#FunctionAttributeKwd|FunctionAttributeKwd]
    [#LinkageAttribute|LinkageAttribute]
    [pragma#Pragma|pragma, Pragma]
    [#VisibilityAttribute|VisibilityAttribute]
    [#abstract|`abstract`]
    [#auto|`auto`]
    [#const|`const`]
    [#final|`final`]
    [#gshared|`__gshared`]
    [#linkage|`extern`]
    [#immutable|`immutable`]
    [#inout|`inout`]
    [#override|`override`]
    [#ref|`ref`]
    [#return|`return`]
    [#scope|`scope`]
    [#shared|`shared`]
    [#static|`static`]
    [#synchronized|`synchronized`]

$(B $(ID FunctionAttributeKwd) FunctionAttributeKwd):
    [#nothrow|`nothrow`]
    [#pure|`pure`]

$(B $(ID AtAttribute) AtAttribute):
    `@` [#disable|`disable`]
    `@` [#nogc|`nogc`]
    `@` $(LINK2 spec/ob, Live Functions)
    [#Property|Property]
    `@` [#safe|`safe`]
    `@` [#safe|`system`]
    `@` [#safe|`trusted`]
    [#UserDefinedAttribute|UserDefinedAttribute]

$(B $(ID Property) Property):
    `@` [#property|`property`]

$(B $(ID DeclarationBlock) DeclarationBlock):
    [module#DeclDef|module, DeclDef]
    `{` [module#DeclDefs|module, DeclDefs]$(SUBSCRIPT opt) `}`

)

        Attributes are a way to modify one or more declarations.
        The general forms are:
        

---
attribute declaration; // affects the declaration

attribute:     // affects all declarations until the end of
               // the current scope
  declaration;
  declaration;
  ...

attribute {    // affects all declarations in the block
  declaration;
  declaration;
  ...
}

---

$(H2 $(ID linkage) Linkage Attribute)

$(PRE $(CLASS GRAMMAR)
$(B $(ID LinkageAttribute) LinkageAttribute):
    `extern` `(` [#LinkageType|LinkageType] `)`
    `extern` `(` `C` `++` `,` `)`
    `extern` `(` `C` `++` `,` [type#QualifiedIdentifier|type, QualifiedIdentifier] `)`
    `extern` `(` `C` `++` `,` [#NamespaceList|NamespaceList] `)`
    `extern` `(` `C` `++` `,` `class` `)`
    `extern` `(` `C` `++` `,` `struct` `)`

$(B $(ID LinkageType) LinkageType):
    `C`
    `C` `++`
    `D`
    `Windows`
    `System`
    `Objective` `-` `C`

$(B $(ID NamespaceList) NamespaceList):
    [expression#ConditionalExpression|expression, ConditionalExpression]
    [expression#ConditionalExpression|expression, ConditionalExpression]`,`
    [expression#ConditionalExpression|expression, ConditionalExpression]`,` NamespaceList

)

        D provides an easy way to call C functions and operating
        system API functions, as compatibility with both is essential.
        The $(I LinkageType) is case sensitive, and is meant to be
        extensible by the implementation ($(I they are not keywords)).
        `C` and `D` must be supplied, the others are what
        makes sense for the implementation.
        `C++` offers limited compatibility with C++, see the
        $(LINK2 cpp_interface.html, Interfacing to C++)
        documentation for more information.
        `Objective-C` offers compatibility with Objective-C,
        see the $(LINK2 objc_interface.html, Interfacing to Objective-C)
        documentation for more information.
        `System` is the same as `Windows` on Windows platforms,
        and `C` on other platforms.
        
        $(B Implementation Note:)
        for Win32 platforms, `Windows` should exist.
        

        C function calling conventions are
        specified by:
        

---
extern (C):
    int foo(); // call foo() with C conventions

---
        Note that `extern(C)` can be provided for all types of
        declarations, including `struct` or `class`, even though
        there is no corresponding match on the `C` side. In that case,
        the attribute is ignored. This behavior applies for nested
        functions and nested variables as well. However, for `static` member
        methods and `static` nested functions, adding `extern(C)` will
        change the calling convention, but not the mangling.

        D conventions are:

---
extern (D):

---

        Windows API conventions are:

---
extern (Windows):
    void *VirtualAlloc(
        void *lpAddress,
        uint dwSize,
        uint flAllocationType,
        uint flProtect
    );

---

        The Windows convention is distinct from the C convention only on Win32 platforms,
        where it is equivalent to the
        $(LINK2 https://en.wikipedia.org/wiki/X86_calling_conventions, stdcall) convention.

        Note that a $(LINK2 spec/declaration#extern,lone `extern` keyword)
        is used as a storage class.

$(H3 C++ $(ID namespace) Namespaces)

        The linkage form `extern (C++, `$(I QualifiedIdentifier)`)`
        creates C++ declarations that reside in C++ namespaces. The $(I QualifiedIdentifier)
        specifies the namespaces.
        

---
extern (C++, N) { void foo(); }

---

        refers to the C++ declaration:

        ```cpp
namespace N { void foo(); }
```

        and can be referred to with or without qualification:

---
foo();
N.foo();

---

        Namespaces create a new named scope that is imported into its enclosing scope.

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
extern (C++, N) { void foo(); void bar(); }
extern (C++, M) { void foo(); }

void main()
{
    bar();   // ok
    //foo(); // error - N.foo() or M.foo() ?
    M.foo(); // ok
}

---
        
)

        Multiple dotted identifiers in the $(I QualifiedIdentifier) create nested namespaces:

---
extern (C++, N.M) { extern (C++) { extern (C++, R) { void foo(); } } }
N.M.R.foo();

---

        refers to the C++ declaration:

        ```cpp
namespace N { namespace M { namespace R { void foo(); } } }
```


$(H2 $(ID align) `align` Attribute)

$(PRE $(CLASS GRAMMAR)
$(B $(ID AlignAttribute) AlignAttribute):
    `align`
    `align` `(` [expression#AssignExpression|expression, AssignExpression] `)`

)


        Specifies the alignment of:

        $(NUMBERED_LIST
        * variables
        * struct fields
        * union fields
        * class fields
        * struct, union, and class types
        
)

        `align` by itself
        sets it to the default, which matches the default member alignment
        of the companion C compiler.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
struct S
{
  align:
    byte a;   // placed at offset 0
    int b;    // placed at offset 4
    long c;   // placed at offset 8
}
static assert(S.alignof == 8);
static assert(S.c.offsetof == 8);
static assert(S.sizeof == 16);

---

)
        The $(I AssignExpression) specifies the alignment
        which matches the behavior of the companion C compiler when non-default
        alignments are used. It must be a non-negative power of 2.
        

        A value of 1 means that no alignment is done;
        fields are packed together.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
struct S
{
  align (1):
    byte a;   // placed at offset 0
    int b;    // placed at offset 1
    long c;   // placed at offset 5
}
static assert(S.alignof == 1);
static assert(S.c.offsetof == 5);
static assert(S.sizeof == 13);

---

)
        The natural alignment of an aggregate is the maximum alignment of its
        fields. It can be overridden by setting the alignment outside of the
        aggregate.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
align (2) struct S
{
  align (1):
    byte a;   // placed at offset 0
    int b;    // placed at offset 1
    long c;   // placed at offset 5
}
static assert(S.alignof == 2);
static assert(S.c.offsetof == 5);
static assert(S.sizeof == 14);

---

)
        Setting the alignment of a field aligns it to that power of 2, regardless
        of the size of the field.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
struct S
{
               byte a;  // placed at offset 0
    align (4)  byte b;  // placed at offset 4
    align (16) short c; // placed at offset 16
}
static assert(S.alignof == 16);
static assert(S.c.offsetof == 16);
static assert(S.sizeof == 32);

---

)
        The $(I AlignAttribute) is reset to the default when
        entering a function scope or a non-anonymous struct, union, class, and restored
        when exiting that scope.
        It is not inherited from a base class.
        

        See also: $(LINK2 spec/struct#struct_layout,Struct Layout).

$(H3 $(ID align_gc) GC Compatibility)

        Do not align references or pointers that were allocated
        using [expression#NewExpression|expression, NewExpression] on boundaries that are not
        a multiple of `size_t`. The garbage collector assumes that pointers
        and references to GC allocated objects will be on `size_t`
        byte boundaries.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
struct S
{
  align(1):
    byte b;
    int* p;
}

static assert(S.p.offsetof == 1);

@safe void main()
{
    S s;
    s.p = new int; // error: can't modify misaligned pointer in @safe code
}

---

)
        $(PITFALL If any pointers and references to GC
        allocated objects are not aligned on `size_t` byte boundaries.)


$(H2 $(ID deprecated) `deprecated` Attribute)

$(PRE $(CLASS GRAMMAR)
$(B $(ID DeprecatedAttribute) DeprecatedAttribute):
    `deprecated`
    `deprecated (` [expression#AssignExpression|expression, AssignExpression] `)`

)

        It is often necessary to deprecate a feature in a library,
        yet retain it for backwards compatibility. Such
        declarations can be marked as `deprecated`, which means
        that the compiler can be instructed to produce an error
        if any code refers to deprecated declarations:
        

---
deprecated
{
    void oldFoo();
}

oldFoo();   // Deprecated: function test.oldFoo is deprecated

---

        Optionally a string literal or manifest constant can be used
        to provide additional information in the deprecation message.
        

---
deprecated("Don't use bar") void oldBar();
oldBar();   // Deprecated: function test.oldBar is deprecated - Don't use bar

---

        Calling CTFE-able functions or using manifest constants is also possible.
        

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
import std.format;

enum message = format("%s and all its members are obsolete", Foobar.stringof);
deprecated(message) class Foobar {}
deprecated(format("%s is also obsolete", "This class")) class BarFoo {}

void main()
{
    auto fb = new Foobar();   // Deprecated: class test.Foobar is deprecated - Foobar
                             // and all its members are obsolete
    auto bf = new BarFoo();  // Deprecated: class test.BarFoo is deprecated - This
                             // class is also obsolete
}

---
        
)

        $(B Implementation Note:) The compiler should have a switch
        specifying if `deprecated` should be ignored, cause a warning, or cause an error during compilation.
        


$(H2 $(ID visibility_attributes) Visibility Attribute)

$(PRE $(CLASS GRAMMAR)
$(B $(ID VisibilityAttribute) VisibilityAttribute):
    `export`
    `package`
    `package` `(` [type#QualifiedIdentifier|type, QualifiedIdentifier] `)`
    `private`
    `protected`
    `public`

)

Visibility is an attribute that is one of `private`, `package`,
`protected`, `public`, or `export`. They may be referred to as protection
attributes in documents predating $(LINK2 http://wiki.dlang.org/DIP22, DIP22).

        Visibility participates in $(LINK2 spec/module#name_lookup,symbol name lookup).
        

$(H3 $(ID export) `export` Attribute)

        `export` means that a symbol can be accessed from outside the executable,
        shared library, or DLL. The symbol is said to be exported from where it is defined
        in an executable, shared library, or DLL, and imported by another executable, shared library,
        or DLL.

        `export` applied to the definition of a symbol will export it. `export` applied to
        a declaration of a symbol will import it.
        A variable is a definition unless `extern` is applied to it.

---
export int x = 3;    // definition, exporting `x`
export int y;        // definition, exporting `y`
export extern int z; // declaration, importing `z`

export __gshared h = 3;        // definition, exporting `h`
export __gshared i;            // definition, exporting `i`
export extern __gshared int j; // declaration, importing `j`

---

        A function with a body is a definition, without a body is a declaration.

---
export void f() { }  // definition, exporting `f`
export void g();     // declaration, importing `g`

---

        In Windows terminology, $(I dllexport) means exporting a symbol from a DLL, and $(I dllimport) means
        a DLL or executable is importing a symbol from a DLL.

$(H3 $(ID package) `package` Attribute)

        `package` extends `private` so that package members can be accessed
        from code in other modules that are in the same package.
        If no identifier is provided, this applies to the innermost package only,
        or defaults to `private` if a module is not nested in a package.
        

        `package` may have an optional parameter in the form of a dot-separated identifier
        list which is resolved as the qualified package name. The package must be either the module's
        parent package or one of its ancestors. If this parameter is present, the symbol
        will be visible in the specified package and all of its descendants.
        

$(H3 $(ID private) `private` Attribute)

        Symbols with `private` visibility can only be accessed from
        within the same module.
        Private member functions are implicitly $(LINK2 spec/function#final,`final`)
        and cannot be overridden.
        

$(H3 $(ID protected) `protected` Attribute)

        `protected` only applies inside classes (and templates as they can be mixed in)
        and means that a symbol can only be seen by members of the same module,
        or by a derived class.
        If accessing a protected instance member through a derived class member
        function, that member can only be accessed for the object instance
        which can be implicitly cast to the same type as 'this'.
        `protected` module members are illegal.
        

$(H3 $(ID public) `public` Attribute)

        `public` means that any code within the executable can see the member.
        It is the default visibility attribute.
        


$(H2 $(ID mutability) Mutability Attributes)

$(H3 $(ID const) `const` Attribute)

        The $(LINK2 spec/const3, Type Qualifiers)
        changes the type of the declared symbol from `T` to `const(T)`,
        where `T` is the type specified (or inferred) for the introduced symbol in the absence of `const`.
        

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
const int foo = 7;
static assert(is(typeof(foo) == const(int)));

const double bar = foo + 6;
static assert(is(typeof(bar) == const(double)));

---
        
)
        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
class C
{
    const void foo();
    const
    {
        void bar();
    }
    void baz() const;
}
pragma(msg, typeof(C.foo)); // const void()
pragma(msg, typeof(C.bar)); // const void()
pragma(msg, typeof(C.baz)); // const void()

static assert(is(typeof(C.foo) == typeof(C.bar)) &amp;&amp;
              is(typeof(C.bar) == typeof(C.baz)));

---
        
)

        See also: $(LINK2 spec/declaration#methods-returning-qualified,Methods Returning a Qualified Type).

$(H3 $(ID immutable) `immutable` Attribute)

        The `immutable` attribute modifies the type from `T` to `immutable(T)`,
        the same way as `const` does. See:
        
$(LIST
* $(LINK2 spec/const3#immutable_storage_class,`immutable` storage class)
* $(LINK2 spec/const3#immutable_type,`immutable` type qualifier)


)
$(H3 $(ID inout) `inout` Attribute)

        The $(LINK2 spec/const3#inout,`inout` attribute) modifies the type from `T` to `inout(T)`,
        the same way as `const` does.
        


$(H2 $(ID shared-storage) Shared Storage Attributes)

$(H3 $(ID shared) `shared` Attribute)

        See $(LINK2 spec/const3#shared,`shared`).

$(H3 $(ID gshared) `__gshared` Attribute)

        By default, non-immutable global declarations reside in thread local
        storage. When a global variable is marked with the `__gshared`
        attribute, its value is shared across all threads.

---
int foo;            // Each thread has its own exclusive copy of foo.
__gshared int bar;  // bar is shared by all threads.

---

        `__gshared` may also be applied to member variables and local
        variables. In these cases, `__gshared` is equivalent to `static`,
        except that the variable is shared by all threads rather than being
        thread local.

---
class Foo
{
    __gshared int bar;
}

int foo()
{
    __gshared int bar = 0;
    return bar++; // Not thread safe.
}

---

        Warning:
        Unlike the [#shared|`shared`] attribute, `__gshared` provides no
        safeguards against data races or other multi-threaded synchronization
        issues. It is the responsibility of the programmer to ensure that
        access to variables marked `__gshared` is synchronized correctly.

        `__gshared` is disallowed in `@safe` code.

$(H3 $(ID synchronized) `@synchronized` Attribute)

        See $(LINK2 spec/class#synchronized-classes,Synchronized Classes).


$(H2 $(ID disable) `@disable` Attribute)

A reference to a declaration marked with the `@disable` attribute
causes a compile time error. This can be used to explicitly disallow certain
operations or overloads at compile time rather than relying on generating a
runtime error.

---
@disable void foo() { }

---
---
void main() { foo(); /* error, foo is disabled */ }

---

        $(LINK2 spec/struct#disable_default_construction,`@disable this();`)
        inside a struct disallows default construction.
        

        $(LINK2 spec/struct#disable-copy,Disabling a struct copy constructor)
        makes the struct not copyable.
        


$(H2 $(ID safe) `@safe`)

    See $(LINK2 spec/function#function-safety,Function Safety).


$(H2 $(ID function-attributes) Function Attributes)

$(H3 $(ID nogc) `@nogc` Attribute)

    See $(LINK2 spec/function#nogc-functions,No-GC Functions).

$(H3 $(ID property) `@property` Attribute)

    See $(LINK2 spec/function#property-functions,Property Functions).

$(H3 $(ID nothrow) `nothrow` Attribute)

    See $(LINK2 spec/function#nothrow-functions,Nothrow Functions).

$(H3 $(ID pure) `pure` Attribute)

    See $(LINK2 spec/function#pure-functions,Pure Functions).

$(H3 $(ID ref) `ref` Attribute)

    See $(LINK2 spec/declaration#ref-storage,`ref` Storage Class).

$(H3 $(ID return) `return` Attribute)

$(LIST
* $(LINK2 spec/function#return-ref-parameters,Return Ref Parameters).
* $(LINK2 spec/function#return-scope-parameters,Return Scope Parameters).


)
$(H2 $(ID static) `static` Attribute)

        The `static` attribute applies to types, functions and data.
        `static` is ignored when applied to other declarations.

        Inside an aggregate type, a `static`
        declaration does not apply to a particular
        instance of an object, but to the type of the object. In
        other words, it means there is no `this` reference.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
class Foo
{
    static int x;
    static int bar() { return x; }
    int foobar() { return 7; }
}

Foo.x = 6; // no instance needed
assert(Foo.bar() == 6);
//Foo.foobar(); // error, no instance of Foo

Foo f = new Foo;
assert(f.bar() == 6);
assert(f.foobar() == 7);

---

)

        Static methods are never $(LINK2 spec/function#virtual-functions,virtual).

        Static data has one instance per thread, not one per object.


A static $(LINK2 spec/function#nested,nested function)
or $(LINK2 spec/struct#nested,type) cannot
access variables in the parent scope.

Inside a function, a $(LINK2 spec/function#local-static-variables,static local variable) persists after the function returns.

        Static does not have the additional C meaning of being local
        to a file. Use the [#VisibilityAttribute|`private`]
        attribute in D to achieve that.
        For example:


---
module foo;
int x = 3;         // x is global
private int y = 4; // y is local to module foo

---


$(H2 $(ID auto) `auto` Attribute)

        The `auto` attribute is used when there are no other attributes
        and $(LINK2 spec/declaration#auto-declaration,type inference) is desired.
        

---
auto i = 6.8;   // declare i as a double

---

    For functions, the `auto` attribute means return type inference.
        See $(LINK2 spec/function#auto-functions,Auto Functions).
    

$(H2 $(ID scope) `scope` Attribute)

        The `scope` attribute signifies a variable's pointer values will not escape the scope that the variable is declared in.


        If the variable has a type that does not contain any indirections, the `scope` attribute is ignored.


        When applied to a global variable, `scope` is also ignored, since there is no scope larger than global scope that pointers could escape to.


$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
scope int* x; // scope ignored, global variable

void main()
{
    // scope static int* x;  // cannot be both scope and static
    scope float y;           // scope ignored, no indirections
    scope int[2] z;          // scope ignored, static array is value type
    scope int[] w;           // scope dynamic array
}

---

)

        When applied to a local variable with a type that has indirections,
        its value may not be assigned to a variable with longer lifetime:

        $(LIST
            * Variables outside the $(LINK2 spec/statement#scope-statement,Scope Statement) that the variable is declared in
            * Variables declared before the `scope` variable, since local variables are destructed in the reverse order that they are declared in
            * `__gshared` or `static` variables
        
)

        Other operations implicitly assigning them to variables with longer lifetime are also disallowed:

        $(LIST
            * Returning a `scope` variable from a function
            * Assigning a `scope` variable to a non-scope parameter by calling a function
            * Putting a `scope` variable in an array literal
        
)
        The `scope` attribute is part of the variable declaration, not the type, and it only applies to the first level of indirection.
        For example, it is impossible to declare a variable as a dynamic array of scope pointers, because `scope` only applies to the `.ptr`
        of the array itself, not its elements. `scope` affects various types as follows:


        $(TABLE_ROWS

        * + Type of local variable
+ What `scope` applies to


        * - Any $(LINK2 spec/type#basic-data-types,Basic Data Type)
- nothing

        * - $(LINK2 spec/type#pointers,Pointer) `T*`
- the pointer value

        * - $(LINK2 spec/arrays#dynamic-arrays,Dynamic Array) `T[]`
- the `.ptr` to the elements

        * - $(LINK2 spec/arrays#static-arrays,Static Array) `T[n]`
- each element `T`

        * - [hash-map#Associative Array|hash-map, Associative Array] `K[V]`
- the pointer to the implementation defined structure

        * - `struct` or `union`
- each of its member variables

        * - `function` pointer
- the pointer value

        * - $(LINK2 spec/function#closures,delegate)
- both the `.funcptr` and `.ptr` (closure context) pointer values

        * - `class` or `interface`
- the class reference

        * - [enum#enum|enum, enum]
- the base type

        
)

---
struct S
{
    string str; // note: string = immutable(char)[]
    string* strPtr;
}

string escape(scope S s, scope S* sPtr, scope string[2] sarray, scope string[] darray)
{
    return s.str;        // invalid, scope applies to struct members
    return *s.strPtr;    // valid, scope struct member is dereferenced
    return sPtr.str;     // valid, struct pointer is dereferenced
    return *sPtr.strPtr; // valid, two pointers are dereferenced
    return sarray[0];    // invalid, scope applies to static array elements
    return sarray[1];    // invalid, ditto
    return darray[0];    // valid, scope applies to array pointer, not elements
}

---

$(H3 $(ID scope-values) Scope Values)

    A "`scope` value" is the value of a `scope` variable, or a generated value pointing to stack allocated memory.
    Such values are generated by $(LINK2 spec/arrays#slicing,slicing) a static array
    or creating $(LINK2 spec/type#pointers,a pointer)
    to a variable that is (or may be) allocated on the stack:

    $(LIST
        * A function parameter
        * A local variable
        * A struct member accessed through the implicit `this` parameter
        * The return value of a $(LINK2 spec/function#ref-functions,Ref Function)
    
)

    The variadic parameter from $(LINK2 spec/function#typesafe_variadic_functions,Typesafe Variadic Functions) is also a scope value,
    since the arguments are passed on the stack.


    When a local variable is assigned a `scope` value, it is inferred `scope`, even when the variable has an explicit type and does not use the `auto` keyword.


---
@safe:
ref int[2] identity(return ref int[2] x) {return x;}

int* escape(int[2] y, scope int* z)
{
    int x;

    auto  xPtr  = &amp;x;            // inferred `scope int*`
    int[] yArr  = identity(y)[]; // inferred `scope int[]`
    int*  zCopy = z;             // inferred `scope int*`

    return zCopy; // error
}

void variadic(int[] a...)
{
    int[] x = a; // inferred `scope int[]`
}

void main()
{
    variadic(1, 2, 3);
}

---

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
struct S
{
    int x;

    // this method may be called on a stack-allocated instance of S
    void f()
    {
        int* p = &amp;x; // inferred `scope int* p`
        int* q = &amp;this.x; // equivalent
    }
}

---

)

    $(LINK2 spec/function#scope-parameters,Scope Parameters) are treated the same as scope local variables,
    except that returning them is allowed when the function has $(LINK2 spec/function#function-attribute-inference,Function Attribute Inference).
    In that case, they are inferred as $(LINK2 spec/function#return-scope-parameters,Return Scope Parameters).


$(H3 $(ID scope-class-var) `scope` Class Instances)
        When used to allocate a class instance directly, a `scope` variable signifies the RAII
        (Resource Acquisition Is Initialization) protocol.
        This means that the destructor for an object is automatically called when the
        reference to it goes out of scope. The destructor is called even
        if the scope is exited via a thrown exception, thus `scope`
        is used to guarantee cleanup.

        When a class is constructed with `new` and assigned to a local `scope` variable,
        it may be allocated on the stack and permitted in a `@nogc` context.

        If there is more than one `scope` class variable going out of scope
        at the same point, then the destructors are called in the reverse
        order that the variables were constructed.

        Assignment to a `scope` variable with class type,
        other than initialization, is not allowed, because that would complicate
        proper destruction of the variable.


$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
import core.stdc.stdio : puts;

class C
{
    ~this() @nogc { puts(__FUNCTION__); }
}

void main() @nogc
{
    {
        scope c0 = new C(); // allocated on the stack
        scope c1 = new C();

        //c1 = c0; // Error: cannot rebind scope variables

        // destructor of `c1` and `c0` are called here in that order
    }
    puts("bye");
}

---

)


$(H2 $(ID class-attributes) OOP Attributes)

$(H3 $(ID abstract) `abstract` Attribute)

        An $(LINK2 spec/class#abstract,abstract class) must be overridden by a derived class.
        Declaring an abstract member function makes the class abstract.


$(H3 $(ID final) `final` Attribute)

$(LIST
* A class can be declared $(LINK2 spec/class#final,`final`) to prevent
    subclassing.
* A class method can be declared $(LINK2 spec/function#final,`final`)
    to prevent a derived class overriding it.
* Interfaces can define $(LINK2 spec/interface#method-bodies,`final` methods).

)

$(H3 $(ID override) `override` Attribute)

    See $(LINK2 spec/function#virtual-functions,Virtual Functions).


$(H2 $(ID mustuse-attribute) `@mustuse` Attribute)

            The `@mustuse` attribute is a compiler-recognized [#uda|        UDA] defined in the D runtime module [phobos/core_attribute.html,
        `core.attribute`].
    


            An expression is considered to be discarded if and only if either of the
        following is true:
    
    $(LIST
        *             it is the top-level [expression#Expression|expression, Expression] in an [            statement#ExpressionStatement|           statement, ExpressionStatement], or
        
        *             it is the [expression#AssignExpression|expression, AssignExpression] on the left-hand
            side of the comma in a [expression#CommaExpression|expression, CommaExpression].
        
    
)

            It is a compile-time error to discard an expression if all of the
        following are true:
    

    $(LIST
        *             it is not an assignment expression, an increment expression, or a
            decrement expression; and
        

        *             its type is a `struct` or `union` type whose declaration is
            annotated with `@mustuse`.
        
    
)

            "Assignment expression" means either a $(LINK2 spec/expression#simple_assignment_expressions,        simple assignment expression) or an
        $(LINK2 spec/expression#assignment_operator_expressions,assignment
        operator expression).
    

            "Increment expression" means a [expression#UnaryExpression|expression, UnaryExpression] or
        [expression#PostfixExpression|expression, PostfixExpression] whose operator is `++`.
    

            "Decrement expression" means a [expression#UnaryExpression|expression, UnaryExpression] or
        [expression#PostfixExpression|expression, PostfixExpression] whose operator is `--`.
    

            It is a compile-time error to attach `@mustuse` to a function
        declaration or to any aggregate declaration other than a `struct` or
        `union` declaration. The purpose of this rule is to reserve such usage
        for possible future expansion.
    

$(H2 $(ID uda) User-Defined Attributes)

$(PRE $(CLASS GRAMMAR)
$(B $(ID UserDefinedAttribute) UserDefinedAttribute):
    `@ (` [expression#TemplateArgumentList|expression, TemplateArgumentList] `)`
    `@` [template#TemplateSingleArgument|template, TemplateSingleArgument]
    `@` $(LINK2 lex#Identifier, Identifier) `(` [expression#NamedArgumentList|expression, NamedArgumentList]$(SUBSCRIPT opt) `)`
    `@` [template#TemplateInstance|template, TemplateInstance]
    `@` [template#TemplateInstance|template, TemplateInstance] `(` [expression#NamedArgumentList|expression, NamedArgumentList]$(SUBSCRIPT opt) `)`

)

            User-Defined Attributes (UDA) are compile-time annotations that can be attached
        to a declaration. These attributes can then be queried, extracted, and manipulated
        at compile time. There is no runtime component to them.
    

A user-defined attribute is defined using:
$(LIST
* Compile-time expressions
* A named manifest constant
* A type name
* A type to instantiate using a compile-time argument list


)
$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
@(3) int a; // value argument
@("string", 7) int b; // multiple values

// using compile-time constant
enum val = 3;
@val int a2; // has same attribute as `a`

enum Foo;
@Foo int c; // type name attribute

struct Bar
{
    int x;
}
@Bar() int d; // type instance
@Bar(3) int e; // type instance using initializer

---

)
        For `e`, the attribute is an instance of struct `Bar` which is
        $(LINK2 spec/struct#static_struct_init,statically initialized)
        using its argument.

                    If there are multiple UDAs in scope for a declaration, they are concatenated:
        

---
@(1)
{
    @(2) int a;         // has UDAs (1, 2)
    @("string") int b;  // has UDAs (1, "string")
}

---

        A function parameter can have a UDA:
---
void f(@(3) int p);

---

$(H3 $(ID getAttributes) `__traits(getAttributes)`)

                    UDAs can be extracted into a
            $(LINK2 spec/template#variadic-templates,compile-time sequence) using `__traits`:
        

---
@('c') string s;
pragma(msg, __traits(getAttributes, s)); // prints tuple('c')

---

                    If there are no user-defined attributes for the symbol, an empty sequence is returned.
            The result can be used just like any compile-time sequence - it can be indexed,
            passed as template parameters, etc.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
enum e = 7;
@("hello") struct SSS { }
@(3)
{
    @(4) @e @SSS int foo;
}

alias TP = __traits(getAttributes, foo);

pragma(msg, TP); // prints tuple(3, 4, 7, (SSS))
pragma(msg, TP[2]); // prints 7

---

)

                    Any types in the sequence can be used to declare things:
        

---
TP[3] a; // a is declared as an SSS

---

                    The attribute of the type name is not the same as the attribute of the variable:
        

---
pragma(msg, __traits(getAttributes, a)); // prints tuple()
pragma(msg, __traits(getAttributes, typeof(a))); // prints tuple("hello")

---

$(H3 $(ID uda-usage) Usage)

                    Of course, the real value of UDAs is to be able to create user-defined types with
            specific values. Having attribute values of basic types does not scale.
        

                    Whether the attributes are values or types is up to the user, and whether later
            attributes accumulate or override earlier ones is also up to how the user
            interprets them.
        

$(H3 $(ID uda-templates) Templates)

                    If a UDA is attached to a template declaration, then it will be automatically
            attached to all direct members of instances of that template. If any of those
            members are templates themselves, this rule applies recursively:
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
@("foo") template Outer(T)
{
    struct S
    {
        int x;
    }
    int y;
    void fun() {}
    @("bar") template Inner(U)
    {
        int z;
    }
}

pragma(msg, __traits(getAttributes, Outer!int.S));
// prints tuple("foo")
pragma(msg, __traits(getAttributes, Outer!int.S.x));
// prints tuple()
pragma(msg, __traits(getAttributes, Outer!int.y));
// prints tuple("foo")
pragma(msg, __traits(getAttributes, Outer!int.fun));
// prints tuple("foo")
pragma(msg, __traits(getAttributes, Outer!int.Inner));
// prints tuple("foo", "bar")
pragma(msg, __traits(getAttributes, Outer!int.Inner!int.z));
// prints tuple("foo", "bar")

---

)

                    UDAs cannot be attached to template parameters.
        
property, Properties, pragma, Pragmas




Link_References:
	ACC = Associated C Compiler
+/
module attribute.dd;