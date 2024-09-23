// just docs: Classes
/++





        The object-oriented features of D all come from classes. The class
        hierarchy
        has as its root the class Object. Object defines a minimum level of functionality
        that each derived class has, and a default implementation for that functionality.
        

        Classes are programmer defined types. Support for classes are what
        make D an object oriented language, giving it encapsulation, inheritance,
        and polymorphism. D classes support the single inheritance paradigm, extended
        by adding support for interfaces. Class objects are instantiated by reference
        only.
        

        A class can be exported, which means its name and all its
        non-private
        members are exposed externally to the DLL or EXE.
        

        A class declaration is defined:
        

$(PRE $(CLASS GRAMMAR)
$(B $(ID ClassDeclaration) ClassDeclaration):
    `class` $(LINK2 lex#Identifier, Identifier) `;`
    `class` $(LINK2 lex#Identifier, Identifier) [#BaseClassList|BaseClassList]$(SUBSCRIPT opt) [struct#AggregateBody|struct, AggregateBody]
    [template#ClassTemplateDeclaration|template, ClassTemplateDeclaration]

$(B $(ID BaseClassList) BaseClassList):
    `:` [#SuperClassOrInterface|SuperClassOrInterface]
    `:` [#SuperClassOrInterface|SuperClassOrInterface] `,` [#Interfaces|Interfaces]

$(B $(ID SuperClassOrInterface) SuperClassOrInterface):
    [type#BasicType|type, BasicType]

$(B $(ID Interfaces) Interfaces):
    [#Interface|Interface]
    [#Interface|Interface] `,` Interfaces

$(B $(ID Interface) Interface):
    [type#BasicType|type, BasicType]

)

A class consists of:

$(COMMENT list of notable components, not exhaustive)
$(LIST
        * a [#super_class|super class]
        * $(LINK2 spec/interface, Interfaces)
        * dynamic fields
        * $(LINK2 spec/attribute#static,static) fields
        * [#nested|nested classes]
        * [#member-functions|member functions]
        $(LIST
            * static member functions
            * $(LINK2 spec/function#virtual-functions,Virtual Functions)
            * [#constructors|Constructors]
            * [#destructors|Destructors]
            * [#invariants|Class Invariants]
            * $(LINK2 spec/operatoroverloading, Operator Overloading)
        
)
        * other declarations (see [module#DeclDef|module, DeclDef])
        

)

A class is defined:

---
class Foo
{
    ... members ...
}

---

$(NOTE         Note: Unlike C++, there is no trailing `;` after the closing `}` of the class
        definition.
        It is also not possible to declare a variable `var` inline:

---
class Foo { } var;

---

        Instead, use:

---
class Foo { }
Foo var;

---
)

$(H2 $(ID access_control) Access Control)

        Access to class members is controlled using
        $(LINK2 spec/attribute#visibility_attributes,        visibility attributes).
        The default visibility attribute is `public`.
        

$(H2 $(ID super_class) Super Class)

                All classes inherit from a super class. If one is not specified,
        a class inherits from [object.Object|Object]. `Object` forms the root
        of the D class inheritance hierarchy.
        

---
class A { }     // A inherits from Object
class B : A { } // B inherits from A

---

        Multiple class inheritance is not supported, however a class can inherit from
        multiple $(LINK2 spec/interface, Interfaces).
        If a super class is declared, it must come before any interfaces.
        Commas are used to separate inherited types.


$(H2 $(ID fields) Fields)

        Class members are always accessed with the `.` operator.
        

        Members of a base class can be accessed by prepending the name of
        the base class followed by a dot:

---
class A { int a; int a2;}
class B : A { int a; }

void foo(B b)
{
    b.a = 3;   // accesses field B.a
    b.a2 = 4;  // accesses field A.a2
    b.A.a = 5; // accesses field A.a
}

---

        The D compiler is free to rearrange the order of fields in a class to
        optimally pack them in an implementation-defined manner.
        Consider the fields much like the local
        variables in a function -
        the compiler assigns some to registers and shuffles others around all to
        get the optimal
        stack frame layout. This frees the code designer to organize the fields
        in a manner that
        makes the code more readable rather than being forced to organize it
        according to
        machine optimization rules. Explicit control of field layout is provided
        by struct/union
        types, not classes.
        

        Fields of `extern(Objective-C)` classes have a dynamic offset. That
        means that the base class can change (add or remove instance variables)
        without the subclasses needing to recompile or relink.
        

$(H3 $(ID field_properties) Field Properties)

        The `.offsetof` property gives the offset in bytes of the field
        from the beginning of the class instantiation.
        `.offsetof` is not available for fields of `extern(Objective-C)` classes
        due to their fields having a dynamic offset.
        

$(H2 $(ID class_properties) Class Properties)

        The `.tupleof` property is an
        $(LINK2 spec/template#homogeneous_sequences,lvalue sequence)
        of all the non-static fields in the class, excluding the hidden fields and
        the fields in the base class.
        The order of the fields in the tuple matches the order in which the fields are declared.
        Note: `.tupleof` is not available for `extern(Objective-C)` classes due to
        their fields having a dynamic offset.
        
$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
class Foo { int x; long y; }

static assert(__traits(identifier, Foo.tupleof[0]) == "x");
static assert(is(typeof(Foo.tupleof)[1] == long));

void main()
{
    import std.stdio;

    auto foo = new Foo;
    foo.tupleof[0] = 1; // set foo.x to 1
    foo.tupleof[1] = 2; // set foo.y to 2
    foreach (ref x; foo.tupleof)
        x++;
    assert(foo.x == 2);
    assert(foo.y == 3);

    auto bar = new Foo;
    bar.tupleof = foo.tupleof; // copy fields
    assert(bar.x == 2);
    assert(bar.y == 3);
}

---

)

$(H3 $(ID hidden-fields) Accessing Hidden Fields)

        The [#outer-property|`.outer` property] for
        a nested class instance provides either the parent class instance,
        or the parent function's context pointer when there is no parent
        class.

        The properties `.__vptr` and `.__monitor` give access
        to the class object's vtbl[] and monitor, respectively, but
        should not be used in user code.
        

$(H2 $(ID member-functions) Member Functions (a.k.a. Methods))

        Non-static member functions have an extra hidden parameter
        called $(LINK2 spec/expression#this,`this`) through which the class object's other members
        can be accessed.
        

        Non-static member functions can have, in addition to the usual
        [function#FunctionAttribute|function, FunctionAttribute]s, the attributes
        `const`, `immutable`, `shared`, `inout`, `scope` or `return scope`.
        These attributes apply to the hidden $(I this) parameter.
        
$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
class C
{
    int a;
    void foo() const
    {
        a = 3; // error, 'this' is const
    }
    void foo() immutable
    {
        a = 3; // error, 'this' is immutable
    }
    C bar() @safe scope
    {
        return this; // error, 'this' is scope
    }
}

---

)

$(H3 $(ID objc-member-functions) Objective-C linkage)

        Static member functions with
        `Objective-C` linkage also have an extra hidden parameter called $(I this)
        through which the class object's other members can be accessed.
        

        Member functions with Objective-C linkage have an additional
        hidden, anonymous, parameter which is the selector the function was
        called with.
        

        Static member functions with Objective-C linkage are placed in
        a hidden nested metaclass as non-static member functions.
        


$(H2 $(ID synchronized-methods) Synchronized Method Calls)

        Member functions of a (non-`synchronized`) class can be individually
        marked as `synchronized`.
        The class instance's monitor object will be locked when the method is
        called and unlocked when the call terminates.
        

        A synchronized method can only be called on a
        $(LINK2 spec/const3#shared,`shared`) class instance.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
class C
{
    void foo();
    synchronized int bar();
}

void test(C c)
{
    c.foo; // OK
    //c.bar; // Error, `c` is not `shared`

    shared C sc = new shared C;
    //sc.foo; // Error, `foo` not callable using a `shared` object
    sc.bar; // OK
}

---

)
        See also [statement#SynchronizedStatement|statement, SynchronizedStatement].

$(H3 $(ID synchronized-classes) Synchronized Classes)

        Each member function of a `synchronized` class is implicitly `synchronized`.
        A static member function is synchronized on the $(I classinfo)
        object for the class, which means that one monitor is used
        for all static member functions for that synchronized class.
        For non-static functions of a synchronized class, the monitor
        used is part of the class object. For example:
        

---
synchronized class Foo
{
    void bar() { ...statements... }
}

---

        is equivalent to (as far as the monitors go):
        

---
synchronized class Foo
{
    void bar()
    {
        synchronized (this) { ...statements... }
    }
}

---
        Note: `bar` uses a [statement#SynchronizedStatement|statement, SynchronizedStatement].

        Member fields of a synchronized class cannot be public:
        

---
synchronized class Foo
{
    int foo;  // Error: public field
}

synchronized class Bar
{
    private int bar;  // ok
}

---

        Note: struct types cannot be marked `synchronized`.


$(H2 $(ID constructors) Constructors)

$(PRE $(CLASS GRAMMAR)
$(B $(ID Constructor) Constructor):
    `this` [function#Parameters|function, Parameters] [function#MemberFunctionAttributes|function, MemberFunctionAttributes]$(SUBSCRIPT opt) [function#FunctionBody|function, FunctionBody]
    [template#ConstructorTemplate|template, ConstructorTemplate]

)

        Fields are by default initialized to the
        $(ID class-default-initializer) default initializer
        for their type (usually 0 for integer types and
        NAN for floating point types).
        If the field declaration has an optional [declaration#Initializer|declaration, Initializer]
        that will be used instead of the default.
        
---
class Abc
{
    int a;      // default initializer for a is 0
    long b = 7; // default initializer for b is 7
    float f;    // default initializer for f is NAN
}

---

        The $(I Initializer) is evaluated at compile time.

        This initialization is done before any constructors are
        called.

        Constructors are defined with a function name of `this`
        and have no return value:

---
class Foo
{
    /* adrdox_highlight{ */this/* }adrdox_highlight */(int x)  // declare constructor for Foo
    {   ...
    }
    /* adrdox_highlight{ */this/* }adrdox_highlight */()
    {   ...
    }
}

---

$(H3 $(ID base-construction) Base Class Construction)

        Base class construction is done by calling the base class
        constructor by the name `super`:

---
class A { this(int y) { } }

class B : A
{
    int j;
    this()
    {
        ...
        /* adrdox_highlight{ */super/* }adrdox_highlight */(3);  // call base constructor A.this(3)
        ...
    }
}

---

$(H3 $(ID delegating-constructors) Delegating Constructors)

        A constructor can call another constructor for the same class
        in order to share common initializations.
        This is called a $(I delegating constructor):
        

---
class C
{
    int j;
    this()
    {
        ...
    }
    this(int i)
    {
        /* adrdox_highlight{ */this/* }adrdox_highlight */(); // delegating constructor call
        j = i;
    }
}

---

        The following restrictions apply:

    $(NUMBERED_LIST
        * It is illegal for constructors to mutually call each other.

---
this() { this(1); }
this(int i) { this(); } // illegal, cyclic constructor calls

---

        $(WARNING The compiler is not required to detect
        cyclic constructor calls.)

        $(PITFALL If the program executes with cyclic constructor
        calls.)
        

        * If a constructor's code contains a delegating constructor call, all
        possible execution paths through the constructor must make exactly one
        delegating constructor call:

---
this() { a || super(); }       // illegal

this() { (a) ? this(1) : super(); }     // ok

this()
{
    for (...)
    {
        super();  // illegal, inside loop
    }
}

---
        

        * It is illegal to refer to `this` implicitly or explicitly
        prior to making a delegating constructor call.

        * Delegating constructor calls cannot appear after labels.
    
)

$(H3 $(ID implicit-base-construction) Implicit Base Class Construction)

        If there is no constructor for a class, but there is a constructor
        for the base class, a default constructor is implicitly generated with
        the form:

---
this() { }

---

        If no calls to a delegating constructor or `super` appear in a
        constructor, and the base class has a nullary constructor, a call to
        `super()` is inserted at the beginning of the constructor. If that
        base class has a constructor that requires arguments and no
        nullary constructor, a matching call to `super` is required.

$(H3 $(ID class-instantiation) Class Instantiation)

        Instances of class objects are created with a [expression#NewExpression|expression, NewExpression]:

---
A a = new A(3);

---

        A $(LINK2 spec/attribute#scope-class-var,`scope` class instance)
        is allocated on the stack.

        The following steps happen:

    $(NUMBERED_LIST
        * Storage is allocated for the object.
        If this fails, rather than return `null`, an
        $(LINK2 library/core/exception/out_of_memory_error.html, OutOfMemoryError) is thrown.
        Thus, tedious checks for null references are unnecessary.
        

        * The raw data is statically initialized using the values provided
        in the class definition.
        The pointer to the vtbl[] (the array of pointers to virtual functions)
        is assigned.
        Constructors are
        passed fully formed objects for which virtual functions can be called.
        This operation is equivalent to doing a memory copy of a static
        version of the object onto the newly allocated one.
        

        * If there is a constructor defined for the class,
        the constructor matching the
        argument list is called.
        

        * If a delegating constructor is not called, a call to the base
        class's default constructor is issued.

        * The body of the constructor is executed.

        * If class invariant checking is turned on, the class invariant
        is called at the end of the constructor.
        
    
)

$(H3 $(ID constructor-attributes) Constructor Attributes)

        Constructors can have one of these member function attributes:
        `const`, `immutable`, and `shared`. Construction of qualified
        objects will then be restricted to the implemented qualified constructors.
        
---
class C
{
    this();   // non-shared mutable constructor
}

// create mutable object
C m = new C();

// create const object using mutable constructor
const C c2 = new const C();

// a mutable constructor cannot create an immutable object
// immutable C i = new immutable C();

// a mutable constructor cannot create a shared object
// shared C s = new shared C();

---

        Constructors can be overloaded with different attributes.
        
---
class C
{
    this();               // non-shared mutable constructor
    this() shared;        // shared mutable constructor
    this() immutable;     // immutable constructor
}

C m = new C();
shared s = new shared C();
immutable i = new immutable C();

---

$(H4 $(ID pure-constructors) Pure Constructors)

        If the constructor can create a unique object (e.g. if it is `pure`),
        the object can be implicitly convertible to any qualifiers.
        
---
class C
{
    this() pure;
    // Based on the definition, this creates a mutable object. But the
    // created object cannot contain any mutable global data.
    // Therefore the created object is unique.

    this(int[] arr) immutable pure;
    // Based on the definition, this creates an immutable object. But
    // the argument int[] never appears in the created object so it
    // isn't implicitly convertible to immutable. Also, it cannot store
    // any immutable global data.
    // Therefore the created object is unique.
}

immutable i = new immutable C();           // this() pure is called
shared s = new shared C();                 // this() pure is called
C m = new C([1,2,3]);       // this(int[]) immutable pure is called

---

$(H3 $(ID field-init) Field initialization inside a constructor)

        In a constructor body, the first instance of field assignment is
        its initialization.
        

---
class C
{
    int num;
    this()
    {
        num = 1;  // initialization
        num = 2;  // assignment
    }
}

---

       If the field type has an $(LINK2 operatoroverloading.html#assignment, `opAssign`)
       method, it will not be used for initialization.

---
struct A
{
    this(int n) {}
    void /* adrdox_highlight{ */opAssign/* }adrdox_highlight */(A rhs) {}
}
class C
{
    A val;
    this()
    {
        val = A(1);  // val is initialized to the value of A(1)
        val = A(2);  // rewritten to val.opAssign(A(2))
    }
}

---

        If the field type is not mutable, multiple initialization will be rejected.

---
class C
{
    immutable int num;
    this()
    {
        num = 1;  // OK
        num = 2;  // Error: multiple field initialization
    }
}

---

        If the field is initialized on one path, it must be initialized on all paths.
---
class C
{
    immutable int num;
    immutable int ber;
    this(int i)
    {
        if (i)
            num = 3;   // initialization
        else
            num = 4;   // initialization
    }
    this(long j)
    {
        j ? (num = 3) : (num = 4); // ok
        j || (ber = 3);  // error, intialized on only one path
        j &amp;&amp; (ber = 3);  // error, intialized on only one path
    }
}

---

        A field initialization may not appear in a loop or after
        a label.

---
class C
{
    immutable int num;
    immutable string str;
    this()
    {
        foreach (i; 0..2)
        {
            num = 1;    // Error: field initialization not allowed in loops
        }
        size_t i = 0;
    Label:
        str = "hello";  // Error: field initialization not allowed after labels
        if (i++ &lt; 2)
            goto Label;
    }
}

---

        If a field's type has disabled default construction, then it must be initialized
        in the constructor.
---
struct S { int y; @disable this(); }

class C
{
    S s;
    this(S t) { s = t; }    // ok
    this(int i) { this(); } // ok
    this() { }              // error, s not initialized
}

---

$(H2 $(ID destructors) Destructors)

$(PRE $(CLASS GRAMMAR)
$(B $(ID Destructor) Destructor):
    `~ this ( )` [function#MemberFunctionAttributes|function, MemberFunctionAttributes]$(SUBSCRIPT opt) [function#FunctionBody|function, FunctionBody]

)

        The destructor function is called when:

$(LIST
* A live object is deleted by the garbage collector
* A live $(LINK2 spec/attribute#scope-class-var,`scope` class instance) goes out of scope
* [object.destroy|destroy] is called on the object


)
        Example:

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
import std.stdio;

class Foo
{
    ~this() // destructor for Foo
    {
        writeln("dtor");
    }
}

void main()
{
    auto foo = new Foo;
    destroy(foo);
    writeln("end");
}

---
        
)

$(LIST
* Only one destructor can be declared per class, although
          other destructors $(LINK2 spec/template-mixin#destructors,can be mixed in).
* A destructor does not have any parameters or attributes.
* A destructor is always virtual.


)
        The destructor is expected to release any non-GC resources held by the
        object.
        

        The program can explicitly call the destructor of a live
        object immediately with [object.destroy|destroy].
        The runtime marks the object so the destructor is never called twice.
        

        The destructor for the [#super_class|super class] automatically gets called when
        the destructor ends. There is no way to call the super class destructor
        explicitly.
        

        $(WARNING The garbage collector is not guaranteed to run the destructor
        for all unreferenced objects.)

        $(NOTE         $(DIVC spec-boxes, $(B Important:) The order in which the
        garbage collector calls destructors for unreferenced objects
        is not specified.
        This means that
        when the garbage collector calls a destructor for an object of a class
        that has
        members which are references to garbage collected objects, those
        references may no longer be valid. This means that destructors
        cannot reference sub objects.)

        Note: This rule does not apply to a `scope` class instance or an object destructed
        with `destroy`, as the destructor is not being run
        during a garbage collection cycle, meaning all references are valid.
        )

        Objects referenced from the static data segment never get collected
        by the GC.
        

$(H2 $(ID static-constructor) Static Constructors)

$(PRE $(CLASS GRAMMAR)
$(B $(ID StaticConstructor) StaticConstructor):
    `static this ( )` [function#MemberFunctionAttributes|function, MemberFunctionAttributes]$(SUBSCRIPT opt) [function#FunctionBody|function, FunctionBody]

)

        A static constructor is a function that performs initializations of
        thread local data before the `main()` function gets control for the main
        thread, and upon thread startup.

        Static constructors are used to initialize static class members with
        values that cannot be computed at compile time.

        Static constructors in other languages are built implicitly by using
        member
        initializers that can't be computed at compile time. The trouble with
        this stems from not
        having good control over exactly when the code is executed, for example:
        

---
class Foo
{
    static int a = b + 1;
    static int b = a * 2;
}

---

        What values do a and b end up with, what order are the initializations
        executed in, what
        are the values of a and b before the initializations are run, is this a
        compile error, or is this
        a runtime error? Additional confusion comes from it not being obvious if
        an initializer is
        static or dynamic.

        D makes this simple. All member initializations must be determinable by
        the compiler at
        compile time, hence there is no order-of-evaluation dependency for
        member
        initializations, and it is not possible to read a value that has not
        been initialized. Dynamic
        initialization is performed by a static constructor, defined with
        a special syntax `static this()`.

---
class Foo
{
    static int a;         // default initialized to 0
    static int b = 1;
    static int c = b + a; // error, not a constant initializer

    /* adrdox_highlight{ */static this/* }adrdox_highlight */()    // static constructor
    {
        a = b + 1;          // a is set to 2
        b = a * 2;          // b is set to 4
    }
}

---

If `main()` or the thread returns normally, (does not throw an
exception), the static destructor is added to the list of functions to be called
on thread termination.

Static constructors have empty parameter lists.

                Static constructors within a module are executed in the lexical
        order in which they appear.
        All the static constructors for modules that are directly or
        indirectly imported
        are executed before the static constructors for the importer.
        

                The `static` in the static constructor declaration is not
        an attribute, it must appear immediately before the `this`:
        

---
class Foo
{
    static this() { ... } // a static constructor
    static private this() { ... } // not a static constructor
    static
    {
        this() { ... }      // not a static constructor
    }
    static:
        this() { ... }      // not a static constructor
}

---

$(H2 $(ID static-destructor) Static Destructors)

$(PRE $(CLASS GRAMMAR)
$(B $(ID StaticDestructor) StaticDestructor):
    `static ~ this ( )` [function#MemberFunctionAttributes|function, MemberFunctionAttributes]$(SUBSCRIPT opt) [function#FunctionBody|function, FunctionBody]

)

        A static destructor is defined as a special static function with the
        syntax `static ~this()`.

---
class Foo
{
    static ~this() // static destructor
    {
    }
}

---

                A static destructor gets called on thread termination,
        but only if the static constructor
        completed successfully.
        Static destructors have empty parameter lists.
        Static destructors get called in the reverse order that the static
        constructors were called in.
        

                The `static` in the static destructor declaration is not
        an attribute, it must appear immediately before the `~this`:
        

---
class Foo
{
    static ~this() { ... }  // a static destructor
    static private ~this() { ... } // not a static destructor
    static
    {
        ~this() { ... }  // not a static destructor
    }
    static:
        ~this() { ... }  // not a static destructor
}

---

$(H2 $(ID shared_static_constructors) Shared Static Constructors)

$(PRE $(CLASS GRAMMAR)
$(B $(ID SharedStaticConstructor) SharedStaticConstructor):
    `shared static this ( )` [function#MemberFunctionAttributes|function, MemberFunctionAttributes]$(SUBSCRIPT opt) [function#FunctionBody|function, FunctionBody]

)

        Shared static constructors are executed before any [#StaticConstructor|StaticConstructor]s,
        and are intended for initializing any shared global data.
        

$(H2 $(ID shared_static_destructors) Shared Static Destructors)

$(PRE $(CLASS GRAMMAR)
$(B $(ID SharedStaticDestructor) SharedStaticDestructor):
    `shared static ~ this ( )` [function#MemberFunctionAttributes|function, MemberFunctionAttributes]$(SUBSCRIPT opt) [function#FunctionBody|function, FunctionBody]

)

        Shared static destructors are executed at program termination
        in the reverse order that
        [#SharedStaticConstructor|SharedStaticConstructor]s were executed.
        


$(H2 $(ID invariants) Class Invariants)

$(PRE $(CLASS GRAMMAR)
$(B $(ID Invariant) Invariant):
    `invariant ( )` [statement#BlockStatement|statement, BlockStatement]
    `invariant` [statement#BlockStatement|statement, BlockStatement]
    `invariant (` [expression#AssertArguments|expression, AssertArguments] `) ;`

)

    Class $(I Invariant)s specify the relationships among the members of a class instance.
    Those relationships must hold for any interactions with the instance from its
    public interface.
    

    The invariant is in the form of a `const` member function. The invariant is defined
    to $(I hold) if all the [expression#AssertExpression|expression, AssertExpression]s within the invariant that are executed
    succeed.
    

    $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
class Date
{
    this(int d, int h)
    {
        day = d;    // days are 1..31
        hour = h;   // hours are 0..23
    }

    invariant
    {
        assert(1 &lt;= day &amp;&amp; day &lt;= 31);
        assert(0 &lt;= hour &amp;&amp; hour &lt; 24);
    }

  private:
    int day;
    int hour;
}

---
    
)

    Any class invariants for base classes are applied before the class invariant for the derived class.

    There may be multiple invariants in a class. They are applied in lexical order.

    Class $(I Invariant)s must hold at the exit of the class constructor (if any), and
    at the entry of the class destructor (if any).

    Class $(I Invariant)s must hold
    at the entry and exit of all public or exported non-static member functions.
    The order of application of invariants is:
    $(NUMBERED_LIST
    * preconditions
    * invariant
    * function body
    * invariant
    * postconditions
    
)

    If the invariant does not hold, then the program enters an invalid state.

    $(WARNING     $(NUMBERED_LIST
    * Whether the class $(I Invariant) is executed at runtime or not. This is typically
    controlled with a compiler switch.
    * The behavior when the invariant does not hold is typically the same as
    for when [expression#AssertExpression|expression, AssertExpression]s fail.
    
)
    )

    $(PITFALL happens if the invariant does not hold and execution continues.)

    Public or exported non-static member functions cannot be called from within an invariant.

---
class Foo
{
    public void f() { }
    private void g() { }

    invariant
    {
        f();  // error, cannot call public member function from invariant
        g();  // ok, g() is not public
    }
}

---

    $(TIP     $(NUMBERED_LIST
    * Do not indirectly call exported or public member functions within a class invariant,
    as this can result in infinite recursion.
    * Avoid reliance on side effects in the invariant. as the invariant may or may not
    be executed.
    * Avoid having mutable public fields of classes with invariants,
    as then the invariant cannot verify the public interface.
    
)
    )


$(H2 $(ID auto) Scope Classes)
Note: Scope classes have been $(LINK2 deprecate#scope as a type constraint, deprecated). See also
$(LINK2 spec/attribute#scope-class-var,`scope` class instances).

        A scope class is a class with the `scope` attribute, as in:

---
scope class Foo { ... }

---

The scope characteristic is inherited, so any classes derived from a scope
class are also scope.

        A scope class reference can only appear as a function local variable.
        It must be declared as being `scope`:

---
scope class Foo { ... }

void func()
{
    Foo f;    // error, reference to scope class must be scope
    scope Foo g = new Foo(); // correct
}

---

When a scope class reference goes out of scope, the destructor (if any) for
it is automatically called. This holds true even if the scope was exited via a
thrown exception.


$(H2 $(ID abstract) Abstract Classes)

        An abstract member function must be overridden by a derived class.
        Only virtual member functions may be declared abstract; non-virtual
        member functions and free-standing functions cannot be declared
        abstract.


        A class is abstract if any of its virtual member functions
        are declared abstract or if they are defined within an
        abstract attribute.
        Note that an abstract class may also contain non-virtual member functions.
        Abstract classes cannot be instantiated directly.
        They can only be instantiated as a base class of
        another, non-abstract, class.


$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
class C
{
    abstract void f();
}

auto c = new C; // error, C is abstract

class D : C {}

auto d = new D; // error, D is abstract

class E : C
{
    override void f() {}
}

auto e = new E; // OK

---

)

        Member functions declared as abstract can still have function
        bodies. This is so that even though they must be overridden,
        they can still provide 'base class functionality',
        e.g. through $(LINK2 spec/expression#super,`super.foo()`) in a derived class.
        Note that the class is still abstract and cannot be instantiated directly.


        A class can be declared abstract:


$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
abstract class A
{
    // ...
}

auto a = new A; // error, A is abstract

class B : A {}

auto b = new B; // OK

---

)


$(H2 $(ID final) Final Classes)

        Final classes cannot be subclassed:

---
final class A { }
class B : A { }  // error, class A is final

---

        Methods of a final class are always
        $(LINK2 spec/function#final,`final`).

$(H2 $(ID nested) Nested Classes)

A $(I nested class) is a class that is declared inside the scope of a
function or another class. A nested class has access to the variables and other
symbols of the classes and functions it is nested inside:

---
class Outer
{
    int m;

    class Inner
    {
        int foo()
        {
            return m;   // Ok to access member of Outer
        }
    }
}

---
---
void func()
{
    int m;

    class Inner
    {
        int foo()
        {
            return m; // Ok to access local variable m of func()
        }
    }
}

---

$(H3 $(ID static-nested) Static Nested Classes)

If a nested class has the `static` attribute, then it can not access
variables of the enclosing scope that are local to the stack or need a
`this` reference:

---
class Outer
{
    int m;
    static int n;

    static class Inner
    {
        int foo()
        {
            return m;   // Error, Inner is static and m needs a this
            return n;   // Ok, n is static
        }
    }
}

---
---
void func()
{
    int m;
    static int n;

    static class Inner
    {
        int foo()
        {
            return m;   // Error, Inner is static and m is local to the stack
            return n;   // Ok, n is static
        }
    }
}

---

$(H3 $(ID nested-context) Context Pointer)

Non-static nested classes work by containing an extra hidden member (called
the context pointer) that is the frame pointer of the enclosing function if it
is nested inside a function, or the `this` reference of the enclosing class's instance
if it is nested inside a class.

        When a non-static nested class is instantiated, the context pointer
        is assigned before the class's constructor is called, therefore
        the constructor has full access to the enclosing variables.
        A non-static nested class can only be instantiated when the necessary
        context pointer information is available:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
class Outer
{
    class Inner { }

    static class SInner { }
}

void main()
{
    Outer o = new Outer;        // Ok
    //Outer.Inner oi = new Outer.Inner; // Error, no 'this' for Outer
    Outer.SInner os = new Outer.SInner; // Ok
}

---

)

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
void main()
{
    class Nested { }

    Nested n = new Nested;      // Ok

    static f()
    {
        //Nested sn = new Nested; // Error, no 'this' for Nested
    }
}

---

)

$(H3 $(ID nested-explicit) Explicit Instantiation)

        A `this` reference can be supplied to the creation of an
        inner class instance by prefixing it to the $(I NewExpression):
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
class Outer
{
    int a;

    class Inner
    {
        int foo()
        {
            return a;
        }
    }
}

void main()
{
    Outer o = new Outer;
    o.a = 3;
    Outer.Inner oi = o.new Inner;
    assert(oi.foo() == 3);
}

---

)

        Here `o` supplies the `this` reference to the inner class
        instance of `Outer`.
        

$(H3 $(ID outer-property) `outer` Property)

        For a nested class instance, the `.outer` property provides
        the `this` reference of the enclosing class's instance.
        If there is no accessible parent class instance, the property
        provides a `void*` to the enclosing function frame.

---
class Outer
{
    class Inner1
    {
        Outer getOuter()
        {
            return this./* adrdox_highlight{ */outer/* }adrdox_highlight */;
        }
    }

    void foo()
    {
        Inner1 i = new Inner1;
        assert(i.getOuter() is this);
    }
}

---
---
class Outer
{
    void bar()
    {
        // x is referenced from nested scope, so
        // bar makes a closure environment.
        int x = 1;

        class Inner2
        {
            Outer getOuter()
            {
                x = 2;
                // The Inner2 instance has access to the function frame
                // of bar as a static frame pointer, but .outer returns
                // the enclosing Outer class instance property.
                return this./* adrdox_highlight{ */outer/* }adrdox_highlight */;
            }
        }

        Inner2 i = new Inner2;
        assert(i.getOuter() is this);
    }
}

---
---
class Outer
{
    // baz cannot access an instance of Outer
    static void baz()
    {
        // make a closure environment
        int x = 1;

        class Inner3
        {
            void* getOuter()
            {
                x = 2;
                // There's no accessible enclosing class instance, so the
                // .outer property returns the function frame of baz.
                return this./* adrdox_highlight{ */outer/* }adrdox_highlight */;
            }
        }

        Inner3 i = new Inner3;
        assert(i.getOuter() !is null);
    }
}

---

$(H3 $(ID anonymous) Anonymous Nested Classes)

        An anonymous nested class is both defined and instantiated with
        a $(I NewAnonClassExpression):
        

$(PRE $(CLASS GRAMMAR)
$(B $(ID NewAnonClassExpression) NewAnonClassExpression):
    `new` `class` [#ConstructorArgs|ConstructorArgs]$(SUBSCRIPT opt) [#AnonBaseClassList|AnonBaseClassList]$(SUBSCRIPT opt) [struct#AggregateBody|struct, AggregateBody]

$(B $(ID ConstructorArgs) ConstructorArgs):
    `(` [expression#NamedArgumentList|expression, NamedArgumentList]$(SUBSCRIPT opt) `)`

$(B $(ID AnonBaseClassList) AnonBaseClassList):
    [#SuperClassOrInterface|SuperClassOrInterface]
    [#SuperClassOrInterface|SuperClassOrInterface] `,` [#Interfaces|Interfaces]

)

which is equivalent to:

$(PRE $(CLASS GRAMMAR_INFORMATIVE)`class` $(LINK2 lex#Identifier, Identifier) `:` $(I AnonBaseClassList) $(I AggregateBody)
// ...
`new` $(I Identifier) $(I ConstructorArgs)
)

where $(I Identifier) is the name generated for the anonymous nested class.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
interface I
{
    void foo();
}

auto obj = new class I
{
    void foo()
    {
        writeln("foo");
    }
};
obj.foo();

---

)

$(H3 $(ID const-class)Const, Immutable and Shared Classes)

    If a $(I ClassDeclaration) has a `const`, `immutable`
        or `shared` storage class, then it is as if each member of the class
        was declared with that storage class.
        If a base class is const, immutable or shared, then all classes derived
        from it are also const, immutable or shared.
    

struct, Structs and Unions, interface, Interfaces




Link_References:
	ACC = Associated C Compiler
+/
module class.dd;