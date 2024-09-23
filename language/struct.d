// just docs: Structs, Unions
/++





$(H2 $(ID intro) Introduction)

    Whereas $(LINK2 spec/class, Classes) are reference types,
    structs and unions are value types.
    Structs are simple aggregations of data and their
    associated operations on that data.
    

$(PRE $(CLASS GRAMMAR)
$(B $(ID StructDeclaration) StructDeclaration):
    `struct` $(LINK2 lex#Identifier, Identifier) `;`
    `struct` $(LINK2 lex#Identifier, Identifier) [#AggregateBody|AggregateBody]
    [template#StructTemplateDeclaration|template, StructTemplateDeclaration]
    $(I AnonStructDeclaration)

$(B $(ID AnonStructDeclaration) AnonStructDeclaration):
    `struct` [#AggregateBody|AggregateBody]

)
$(PRE $(CLASS GRAMMAR)
$(B $(ID UnionDeclaration) UnionDeclaration):
    `union` $(LINK2 lex#Identifier, Identifier) `;`
    `union` $(LINK2 lex#Identifier, Identifier) [#AggregateBody|AggregateBody]
    [template#UnionTemplateDeclaration|template, UnionTemplateDeclaration]
    $(I AnonUnionDeclaration)

$(B $(ID AnonUnionDeclaration) AnonUnionDeclaration):
    `union` [#AggregateBody|AggregateBody]

)
$(PRE $(CLASS GRAMMAR)
$(B $(ID AggregateBody) AggregateBody):
    `{` [module#DeclDefs|module, DeclDefs]$(SUBSCRIPT opt) `}`

)

    The following example declares a struct type with a single integer field:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
struct S
{
    int i;
}

void main()
{
    S a;
    a.i = 3;

    S b = a; // copy a
    a.i++;
    assert(a.i == 4);
    assert(b.i == 3);
}

---

)

    For local variables, a struct instance is allocated on the stack
    by default. To allocate on the heap, use `new`:
---
S* p = new S;
assert(p.i == 0);

---

    A struct can contain multiple fields which are stored sequentially.
    Conversely, multiple fields in a union use overlapping storage.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
union U
{
    ubyte i;
    char c;
}

void main()
{
    U u;
    u.i = 3;
    assert(u.c == '\x03');
    u.c++;
    assert(u.i == 4);
}

---

)

$(H2 $(ID members) Members)

$(H3 $(ID struct-members) Struct Members)

    A struct definition can contain:
    $(LIST
        * Fields
        * $(LINK2 spec/attribute#static,Static) fields
        * [#anonymous|Anonymous Structs and Unions]
        * $(LINK2 spec/class#member-functions,member functions)
        $(LIST
            * static member functions
            * [#struct-constructor|Constructors]
            * [#struct-destructor|Destructors]
            * [#Invariant|Invariants]
            * $(LINK2 spec/operatoroverloading, Operator Overloading)
        
)
        * [#alias-this|Alias This]
        * Other declarations (see [module#DeclDef|module, DeclDef])
        
    
)

    A struct is defined to not have an identity; that is,
    the implementation is free to make bit copies of the struct
    as convenient.

    $(TIP     $(NUMBERED_LIST
    * Bit fields are supported with the
    $(LINK2 https://dlang.org/phobos/std_bitmanip.html#bitfields, bitfields) template.
    
))

$(H3 $(ID union-members) Union Members)

    A union definition can contain:
    $(LIST
        * Fields
        * $(LINK2 spec/attribute#static,Static) fields
        * [#anonymous|Anonymous Structs and Unions]
        * $(LINK2 spec/class#member-functions,member functions)
        $(LIST
            * static member functions
            * [#UnionConstructor|Constructors]
            * $(LINK2 spec/operatoroverloading, Operator Overloading)
        
)
        * [#alias-this|Alias This]
        * Other declarations (see [module#DeclDef|module, DeclDef])
        
    
)

$(H3 $(ID recursive-types) Recursive Structs and Unions)

    Structs and unions may not contain a non-static instance of themselves,
    however, they may contain a pointer to the same type.
    

    $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
struct S
{
    S* ptr;     // OK
    S[] slice;  // OK

    S s;        // error
    S[2] array; // error

    static S global; // OK
}

---
    
)


$(H2 $(ID struct_layout) Struct Layout)

    The non-static data members of a struct are called $(I fields). Fields are laid
    out in lexical order. Fields are aligned according to the $(LINK2 spec/attribute#align,Align Attribute)
    in effect.
    Unnamed padding is inserted between fields to align fields. There is no padding between
    the first field and the start of the object.
    

    Structs with no fields of non-zero size (aka $(I Empty Structs)) have a size of one byte.

    Non-static [#nested|function-nested D structs], which access the context of
    their enclosing scope, have an extra field.
    

    $(WARNING     $(NUMBERED_LIST
    * The default layout of the fields of a struct is an exact
    match with the $(I associated C compiler).
    * g++ and clang++ differ in how empty structs are handled. Both return `1` from `sizeof`,
    however, clang++ does not push them onto the parameter stack while g++ does. This is a
    binary incompatibility between g++ and clang++.
    dmd follows clang++ behavior for OSX and FreeBSD, and g++ behavior for Linux and other
    Posix platforms.
    
    * clang and gcc both return `0` from `sizeof` for empty structs. Using `extern "C++"`
    in clang++ and g++ does not cause them to conform to the behavior of their respective C compilers.
    
))

    $(PITFALL     $(NUMBERED_LIST
    * The padding data can be accessed, but its contents are undefined.
    * Do not pass or return structs with no fields of non-zero size to `extern (C)` functions.
    According to C11 6.7.2.1p8 this is undefined behavior.
    
))

    $(TIP     $(NUMBERED_LIST
    * When laying out a struct to match an externally defined layout, use align
    attributes to describe an exact match. Using a $(LINK2 spec/version#static-assert,Static Assert)
    to ensure the result is as expected.
    * Although the contents of the padding are often zero, do not rely on that.
    * Avoid using empty structs when interfacing with C and C++ code.
    * Avoid using empty structs as parameters or arguments to variadic functions.
    
))

$(H2 $(ID POD) Plain Old Data)

    A struct or union is $(I Plain Old Data) (POD) if it meets the following criteria:

    $(NUMBERED_LIST
    * it is static, or not nested
    * it has no postblits, copy constructors, destructors, or assignment operators
    * it has no fields that are themselves non-POD
    
)

    $(TIP Structs or unions that interface with C code should be POD.)


$(H2 $(ID opaque_struct_unions) Opaque Structs and Unions)

    Opaque struct and union declarations do not have an [#AggregateBody|AggregateBody]:

---
struct S;
union U;
struct V(T);
union W(T);

---

        The members are completely hidden to the user, and so the only operations
        on those types are ones that do not require any knowledge of the contents
        of those types. For example:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
struct S;
S.sizeof; // error, size is not known
S s;      // error, cannot initialize unknown contents
S* p;     // ok, knowledge of members is not necessary

---

)

        $(TIP They can be used to implement the
        $(LINK2 https://en.wikipedia.org/wiki/Opaque_pointer, PIMPL idiom).)


$(H2 $(ID initialization) Initialization)

$(H3 $(ID default_struct_init) Default Initialization of Structs)

        Struct fields are by default initialized to whatever the
        [declaration#Initializer|declaration, Initializer] for the field is, and if none is supplied, to
        the default initializer for the field's type.
        

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
struct S { int a = 4; int b; }
S x; // x.a is set to 4, x.b to 0

---
        
)

        The default initializers are evaluated at compile time.

$(H3 $(ID static_struct_init) Static Initialization of Structs)

$(PRE $(CLASS GRAMMAR)
$(B $(ID StructInitializer) StructInitializer):
    `{` $(I StructMemberInitializers)$(SUBSCRIPT opt) `}`

$(B $(ID StructMemberInitializers) StructMemberInitializers):
    $(I StructMemberInitializer)
    $(I StructMemberInitializer) `,`
    $(I StructMemberInitializer) `,` StructMemberInitializers

$(B $(ID StructMemberInitializer) StructMemberInitializer):
    [declaration#NonVoidInitializer|declaration, NonVoidInitializer]
    $(LINK2 lex#Identifier, Identifier) `:` [declaration#NonVoidInitializer|declaration, NonVoidInitializer]

)

        If a $(I StructInitializer) is supplied, the
        fields are initialized by the $(I StructMemberInitializer) syntax.
        $(I StructMemberInitializers) with the $(I Identifier : NonVoidInitializer) syntax
        may be appear in any order, where $(I Identifier) is the field identifier.
        $(I StructMemberInitializer)s with the [declaration#NonVoidInitializer|declaration, NonVoidInitializer] syntax
        appear in the lexical order of the fields in the [#StructDeclaration|StructDeclaration].
        

        Fields not specified in the $(I StructInitializer) are default initialized.

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
struct S { int a, b, c, d = 7; }
S r;                          // r.a = 0, r.b = 0, r.c = 0, r.d = 7
S s = { a:1, b:2 };           // s.a = 1, s.b = 2, s.c = 0, s.d = 7
S t = { c:4, b:5, a:2, d:5 }; // t.a = 2, t.b = 5, t.c = 4, t.d = 5
S u = { 1, 2 };               // u.a = 1, u.b = 2, u.c = 0, u.d = 7
S v = { 1, d:3 };             // v.a = 1, v.b = 0, v.c = 0, v.d = 3
S w = { b:1, 3 };             // w.a = 0, w.b = 1, w.c = 3, w.d = 7

---
        
)

        Initializing a field more than once is an error:

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
S x = { 1, a:2 };  // error: duplicate initializer for field `a`

---
        
)

$(H3 $(ID default_union_init) Default Initialization of Unions)

        Unions are by default initialized to whatever the
        [declaration#Initializer|declaration, Initializer] for the first field is, and if none is supplied, to
        the default initializer for the first field's type.
        If the union is larger than the first field, the remaining bits
        are set to 0.

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
union U { int a = 4; long b; }
U x; // x.a is set to 4, x.b to an implementation-defined value

---
        
)

        It is an error to supply initializers for members other than the first one.

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
union V { int a; long b = 4; }     // error: union field `b` with default initialization `4` must be before field `a`
union W { int a = 4; long b = 5; } // error: overlapping default initialization for `a` and `b`

---
        
)

        The default initializer is evaluated at compile time.

        $(WARNING The values the fields other than the
        default initialized field are set to.)

$(H3 $(ID static_union_init) Static Initialization of Unions)

        Unions are initialized similarly to structs, except that only
        one member initializer is allowed.

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
union U { int a; double b; }
U u = { 2 };       // u.a = 2
U v = { b : 5.0 }; // v.b = 5.0

---
        
)

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
U w = { 2, 3 };    // error: overlapping initialization for field `a` and `b`

---
        
)

        If the union is larger than the initialized field, the remaining bits
        are set to 0.

        $(WARNING The values the fields other than the
        initialized field are set to.)

$(H3 $(ID dynamic_struct_init) Dynamic Initialization of Structs)

        The [#static_struct_init|static initializer syntax]
        can also be used to initialize non-static variables.
        The initializer need not be evaluable at compile time.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
struct S { int a, b, c, d = 7; }

void test(int i)
{
    S q = { 1, b:i }; // q.a = 1, q.b = i, q.c = 0, q.d = 7
}

---

)

        Structs can be dynamically initialized from another
        value of the same type:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
struct S { int a; }
S t;      // default initialized
t.a = 3;
S s = t;  // s.a is set to 3

---

)

        If the struct has a [#struct-constructor|constructor], and
        the struct is initialized with a value that is of a different type,
        then the constructor is called:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
struct S
{
    int a;

    this(int v)
    {
        this.a = v;
    }
}

S s = 3; // sets s.a to 3 using S's constructor

---

)

        If the struct does not have a constructor but
        $(LINK2 spec/operatoroverloading#FunctionCall,`opCall`) is
        overridden for the struct, and the struct is initialized with a value
        that is of a different type, then the `opCall` operator is called:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
struct S
{
    int a;

    static S opCall(int v)
    {
        S s;
        s.a = v;
        return s;
    }

    static S opCall(S v)
    {
        assert(0);
    }
}

S s = 3; // sets s.a to 3 using S.opCall(int)
S t = s; // sets t.a to 3, S.opCall(S) is not called

---

)

$(H3 $(ID dynamic_union_init) Dynamic Initialization of Unions)

        The [#static_union_init|static initializer syntax]
        can also be used to initialize non-static variables.
        The initializer need not be evaluable at compile time.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
union U { int a; double b; }

void test(int i)
{
    U u = { a : i };   // u.a = i
    U v = { b : 5.0 }; // v.b = 5.0
}

---

)

$(H2 $(ID struct-literal)Struct Literals)

        A struct literal consists of the name of the struct followed
        by a parenthesized named argument list:

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
struct S { int x; float y; }

S s1 = S(1, 2); // set field x to 1, field y to 2
S s2 = S(y: 2, x: 1); // same as above
assert(s1 == s2);

---
        
)

                If a struct has a [#struct-constructor|constructor]
        or a member function named `opCall`, then
        struct literals for that struct are not possible. See also
        $(LINK2 spec/operatoroverloading#FunctionCall,opCall operator overloading)
        for the issue workaround.

        Struct literals are syntactically like function calls.

        $(NOTE         Arguments are assigned to fields as follows:

$(NUMBERED_LIST
* If the first argument has no name, it will be assigned to the struct field that is defined first lexically.
* A named argument is assigned to the struct field with the same name.
             It is an error if no such field exists.
* Any other argument is assigned to the next lexically defined struct field relative to the preceding argument's struct field.
             It is an error if no such field exists, i.e. when the preceding argument assigns to the last struct field.
* It is also an error to assign a field more than once.
* Any fields not assigned a value are initialized with their respective default initializers.


)
        <strong>Note:</strong>
            These rules are consistent with function calls, see $(LINK2 spec/function#argument-parameter-matching,Matching Arguments to Parameters).
        )
                If there is a union field in the struct, only one
        member of the union can be initialized inside a
        struct literal. This matches the behaviour for union literals.
        

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
struct S { int x = 1, y = 2, z = 3; }

S s0 = S(y: 5, 6, x: 4); // `6` is assigned to field `z`, which comes after `y`
assert(s0.z == 6);

S s1 = S(y: 5, z: 6);    // Field x is not assigned, set to default initializer `1`
assert(s1.x == 1);

//S s2 = S(y: 5, x: 4, 5); // Error: field `y` is assigned twice
//S s3 = S(z: 2, 3);       // Error: no field beyond `z`

---
        
)

$(H2 $(ID union-literal) Union Literals)

    A union literal is like a struct literal, but only one field can
    be initialized with an initializer expression.
    The remainder of the union's memory is initialized to zero.
    

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
union U
{
    byte a;
    char[2] b;
}

U u = U(2);
assert(u.a == 2);
assert(u.b == [2, 0]);

---

)

$(H2 $(ID anonymous) Anonymous Structs and Unions)

    An anonymous struct or union can be declared as a member of a
    parent class, struct or union by omitting the identifier after `struct` or `union`.
    An anonymous struct declares sequentially stored fields in the
    parent type. An anonymous union declares overlapping fields in
    the parent type.

    An anonymous union is useful inside a class or struct to share
    memory for fields, without having to name a parent field with a
    separate union type.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
struct S
{
    int a;
    union
    {
        byte b;
        char c;
    }
}

S s = S(1, 2);
assert(s.a == 1);
assert(s.b == 2);
assert(s.c == 2); // overlaps with `b`

---

)

    Conversely, an anonymous struct is useful inside a union to
    declare multiple fields that are stored sequentially.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
union U
{
    int a;
    struct
    {
        uint b;
        bool c;
    }
}

U u = U(1);
assert(u.a == 1);
assert(u.b == 1); // overlaps with `a`
assert(u.c == false); // no overlap

---

)

$(H2 $(ID struct_properties) Struct Properties)

$(TABLE_ROWS
Struct Properties
* + Name
+ Description

* - `.sizeof`
- Size in bytes of struct

* - `.alignof`
- Size boundary struct needs to be aligned on


)

$(H3 $(ID struct_instance_properties) Struct Instance Properties)

$(TABLE_ROWS
Struct Instance Properties
* + Name
+ Description

* - `.tupleof`
- An $(LINK2 spec/template#homogeneous_sequences,lvalue sequence)
    of all struct fields - see
    $(LINK2 spec/class#class_properties,Class Properties) for a class-based example.


)

$(H3 $(ID struct_field_properties) Struct Field Properties)

$(TABLE_ROWS
Struct Field Properties
* + Name
+ Description

* - `.offsetof`
- Offset in bytes of field from beginning of struct


)

$(H2 $(ID const-struct)Const)

        A struct declaration can have a storage class of
        `const`, `immutable` or `shared`. It has an equivalent
        effect as declaring each member of the struct as
        `const`, `immutable` or `shared`.
        

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
const struct S { int a; int b = 2; }
void main()
{
    S s = S(3); // initializes s.a to 3
    S t;        // initializes t.a to 0
    t = s;      // error, t.a and t.b are const, so cannot modify them.
    t.a = 4;    // error, t.a is const
}

---
        
)


$(H2 $(ID UnionConstructor) Union Constructors)

        Unions are constructed in the same way as structs.


$(H2 $(ID struct-constructor)Struct Constructors)

        Struct constructors are used to initialize an instance of a struct when a more
        complex construction is needed than is allowed by
        [#static_struct_init|static initialization] or a
        [#struct-literal|struct literal].
        

        Constructors are defined with a function name of `this` and have no return value.
        The grammar is the same as for the class [class#Constructor|class, Constructor].
        

        A struct constructor is called by the name of the struct followed by
        [function#Parameters|function, Parameters].
        
        If the [function#ParameterList|function, ParameterList] is empty,
        the struct instance is default initialized.

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
struct S
{
    int x, y = 4, z = 6;
    this(int a, int b)
    {
        x = a;
        y = b;
    }
}

void main()
{
    S a = S(4, 5); // calls S.this(4, 5):  a.x = 4, a.y = 5, a.z = 6
    S b = S();  // default initialized:    b.x = 0, b.y = 4, b.z = 6
    S c = S(1); // error, matching this(int) not found
}

---
        
)

        Named arguments will be forwarded to the constructor and match parameter names, not struct field names.

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
struct S
{
    int x;
    int y;
    this(int y, int z) { this.x = y; this.y = z; }
}
S a = S(x: 3, y: 4); // Error: constructor has no parameter named `x`
S b = S(y: 3, 4); // `y: 3` will set field `x` through parameter `y`

---
        
)

        A $(I default constructor) (i.e. one with an empty [function#ParameterList|function, ParameterList])
        is not allowed.

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
struct S
{
    int x;
    this() { } // error, struct default constructor not allowed
}

---
        
)

$(H3 $(ID delegating-constructor) Delegating Constructors)

        A constructor can call another constructor for the same struct
        in order to share common initializations. This is called a
        $(I delegating constructor):
        

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
struct S
{
    int j = 1;
    long k = 2;
    this(long k)
    {
        this.k = k;
    }
    this(int i)
    {
        // At this point: j=1, k=2
        /* adrdox_highlight{ */this/* }adrdox_highlight */(6); // delegating constructor call
        // At this point: j=1, k=6
        j = i;
        // At this point: j=i, k=6
    }
}

---
        
)

        The following restrictions apply:

        $(NUMBERED_LIST
        * If a constructor's code contains a delegating constructor call, all
        possible execution paths through the constructor must make exactly one
        delegating constructor call:

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
struct S
{
    int a;
    this(int i) { }

    this(char c)
    {
        c || this(1);  // error, not on all paths
    }

    this(wchar w)
    {
        (w) ? this(1) : this('c');  // ok
    }

    this(byte b)
    {
        foreach (i; 0 .. b)
        {
            this(1);  // error, inside loop
        }
    }
}

---
        
)
        

        * It is illegal to refer to `this` implicitly or explicitly
        prior to making a delegating constructor call.

        * Once the delegating constructor returns, all fields are considered
        constructed.

        * Delegating constructor calls cannot appear after labels.
        
)

        See also: $(LINK2 spec/class#delegating-constructors,delegating class constructors).


$(H3 $(ID struct-instantiation) Struct Instantiation)

        When an instance of a struct is created, the following steps happen:

        $(NUMBERED_LIST
        * The raw data is statically initialized using the values provided
        in the struct definition.
        This operation is equivalent to doing a memory copy of a static
        version of the object onto the newly allocated one.
        

        * If there is a constructor defined for the struct,
        the constructor matching the argument list is called.
        

        * If struct invariant checking is turned on, the struct invariant
        is called at the end of the constructor.
        
        
)


$(H3 $(ID constructor-attributes) Constructor Attributes)

        A constructor qualifier (`const`, `immutable` or `shared`) constructs the object instance
        with that specific qualifier.
        
        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
struct S1
{
    int[] a;
    this(int n) { a = new int[](n); }
}
struct S2
{
    int[] a;
    this(int n) immutable { a = new int[](n); }
}
void main()
{
    // Mutable constructor creates mutable object.
    S1 m1 = S1(1);

    // Constructed mutable object is implicitly convertible to const.
    const S1 c1 = S1(1);

    // Constructed mutable object is not implicitly convertible to immutable.
    immutable i1 = S1(1); // error

    // Mutable constructor cannot construct immutable object.
    auto x1 = immutable S1(1); // error


    // Immutable constructor creates immutable object.
    immutable i2 = immutable S2(1);

    // Immutable constructor cannot construct mutable object.
    auto x2 = S2(1); // error

    // Constructed immutable object is not implicitly convertible to mutable.
    S2 m2 = immutable S2(1); // error

    // Constructed immutable object is implicitly convertible to const.
    const S2 c2 = immutable S2(1);
}

---
        
)

        Constructors can be overloaded with different attributes.

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
struct S
{
    this(int);           // non-shared mutable constructor
    this(int) shared;    // shared mutable constructor
    this(int) immutable; // immutable constructor
}

void fun()
{
    S m = S(1);
    shared s = shared S(2);
    immutable i = immutable S(3);
}

---
        
)

$(H4 $(ID pure-constructors) Pure Constructors)

        If the constructor can create a unique object (i.e. if it is `pure`),
        the object is implicitly convertible to any qualifiers.
        
        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
struct S
{
    this(int) pure;
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

void fun()
{
    immutable i = immutable S(1); // this(int) pure is called
    shared s = shared S(1);       // this(int) pure is called
    S m = S([1,2,3]);             // this(int[]) immutable pure is called
}

---
        
)



$(H3 $(ID disable_default_construction) Disabling Default Struct Construction)

        If a struct constructor is annotated with `@disable` and has
        an empty [function#ParameterList|function, ParameterList], the struct has disabled default construction.
        The only way it can be constructed is via a call to another constructor with a non-empty
        $(I ParameterList).
        

        A struct with a disabled default constructor, and no other constructors, cannot
        be instantiated other than via a [declaration#VoidInitializer|declaration, VoidInitializer].

        A disabled default constructor may not have a [function#FunctionBody|function, FunctionBody].

        If any fields have disabled default construction, struct default construction is
        also disabled.

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
struct S
{
    int x;

    // Disables default construction
    @disable this();

    this(int v) { x = v; }
}
struct T
{
    int y;
    S s;
}
void main()
{
    S s;          // error: default construction is disabled
    S t = S();    // error: also disabled
    S u = S(1);   // constructed by calling `S.this(1)`
    S v = void;   // not initialized, but allowed
    S w = { 1 };  // error: cannot use { } since constructor exists
    S[3] a;       // error: default construction is disabled
    S[3] b = [S(1), S(20), S(-2)]; // ok
    T t;          // error: default construction is disabled
}

---
        
)

        $(TIP Disabling default construction is useful when the default value,
        such as `null`, is not acceptable.)


$(H3 $(ID field-init) Field initialization inside a constructor)

        In a constructor body, if a delegating constructor is called,
        all field assignments are considered assignments.
        Otherwise, the first instance of field assignment is
        its initialization, and assignments of the form `field = expression`
        are treated as equivalent to `typeof(field)(expression)`.
        The values of fields may be read before initialization or construction
        with a delegating constructor.
        

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
struct S
{
    int num;
    int ber;
    this(int i)
    {
        num = i + 1;   // initialization
        num = i + 2;   // assignment
        ber = ber + 1; // ok to read before initialization
    }
    this(int i, int j)
    {
        this(i);
        num = i + 1;  // assignment
    }
}

---
        
)

        If the field type has an $(LINK2 spec/operatoroverloading#assignment,`opAssign`)
        method, it will not be used for initialization.

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
struct A
{
    this(int n) {}
    void opAssign(A rhs) {}
}
struct S
{
    A val;
    this(int i)
    {
        val = A(i);  // val is initialized to the value of A(i)
        val = A(2);  // rewritten to val.opAssign(A(2))
    }
}

---
        
)

        If the field type is not mutable, multiple initialization will be rejected.

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
struct S
{
    immutable int num;
    this(int)
    {
        num = 1;  // OK
        num = 2;  // Error: assignment to immutable
    }
}

---
        
)

        If the field is initialized on one path, it must be initialized on all paths.
        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
struct S
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
        j || (ber = 3);  // Error: initialized on only one path
        j &amp;&amp; (ber = 3);  // Error: initialized on only one path
    }
}

---
        
)

        A field initialization may not appear in a loop or after
        a label.

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
struct S
{
    immutable int num;
    immutable string str;
    this(int j)
    {
        foreach (i; 0..j)
        {
            num = 1;    // Error: field initialization not allowed in loops
        }
        size_t i = 0;
    Label:
        str = "hello";  // Error: field initialization not allowed after labels
        if (i++ &lt; 2)
            goto Label;
    }
    this(int j, int k)
    {
        switch (j)
        {
            case 1: ++j; break;
            default: break;
        }
        num = j;        // Error: `case` and `default` are also labels
    }
}

---
        
)

        If a field's type has disabled default construction, then it must be initialized
        in the constructor.
        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
struct S { int y; @disable this(); }

struct T
{
    S s;
    this(S t) { s = t; }       // ok
    this(int i) { this('c'); } // ok
    this(char) { }             // Error: s not initialized
}

---
        
)

$(H2 $(ID struct-copy-constructor)Struct Copy Constructors)

    Copy constructors are used to initialize a `struct` instance from
    another instance of the same type. A `struct` that defines a copy constructor
    is not [#POD|POD].

    A constructor declaration is a copy constructor declaration if it meets
    the following requirements:

    $(LIST
    * It takes exactly one parameter without a
    $(LINK2 spec/function#function-default-args,default argument),
    followed by any number of parameters with default arguments.

    * Its first parameter is a
    $(LINK2 spec/function#ref-params,`ref` parameter).

    * The type of its first parameter is the same type as
    $(LINK2 spec/type#typeof,`typeof(this)`), optionally with one or more
    $(LINK2 spec/const3, Type Qualifiers) applied to it.

    * It is not a
    $(LINK2 spec/template#template_ctors,template constructor declaration).
    
)

---
struct A
{
    this(ref return scope A rhs) {}                        // copy constructor
    this(ref return scope const A rhs, int b = 7) {}       // copy constructor with default parameter
}

---

    The copy constructor is type checked as a normal constructor.

    If a copy constructor is defined, implicit calls to it will be inserted
    in the following situations:

    $(NUMBERED_LIST
    * When a variable is explicitly initialized:

    $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
struct A
{
    int[] arr;
    this(ref return scope A rhs) { arr = rhs.arr.dup; }
}

void main()
{
    A a;
    a.arr = [1, 2];

    A b = a; // copy constructor gets called
    b.arr[] += 1;
    assert(a.arr == [1, 2]); // a is unchanged
    assert(b.arr == [2, 3]);
}

---
    
)

    * When a parameter is passed by value to a function:

    $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
struct A
{
    this(ref return scope A another) {}
}

void fun(A a) {}

void main()
{
    A a;
    fun(a);    // copy constructor gets called
}

---
    
)

    * When a parameter is returned by value from a function and Named Returned Value Optimization (NRVO)
    cannot be performed:

    $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
struct A
{
    this(ref return scope A another) {}
}

A fun()
{
    A a;
    return a;       // NRVO, no copy constructor call
}

A a;
A gun()
{
    return a;       // cannot perform NRVO, rewrite to: return (A __tmp; __tmp.copyCtor(a));
}

void main()
{
    A a = fun();
    A b = gun();
}

---
    
)
    
)

$(H3 $(ID disable-copy) Disabled Copying)

    When a copy constructor is defined for a `struct` (or marked `@disable`), the compiler no
    longer implicitly generates default copy/blitting constructors for that `struct`:
    

    $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
struct A
{
    int[] a;
    this(ref return scope A rhs) {}
}

void fun(immutable A) {}

void main()
{
    immutable A a;
    fun(a);        // error: copy constructor cannot be called with types (immutable) immutable
}

---
    
)

    $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
struct A
{
    @disable this(ref A);
}

void main()
{
    A a;
    A b = a; // error: copy constructor is disabled
}

---
    
)

    If a `union U` has fields that define a copy constructor, whenever an object of type `U`
    is initialized by copy, an error will be issued. The same rule applies to overlapped fields
    (anonymous unions).

    $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
struct S
{
    this(ref S);
}

union U
{
    S s;
}

void main()
{
    U a;
    U b = a; // error, could not generate copy constructor for U
}

---
    
)

$(H3 $(ID copy-constructor-attributes) Copy Constructor Attributes)

    The copy constructor can be overloaded with different qualifiers applied
    to the parameter (copying from a qualified source) or to the copy constructor
    itself (copying to a qualified destination):
    

    $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
struct A
{
    this(ref return scope A another) {}                        // 1 - mutable source, mutable destination
    this(ref return scope immutable A another) {}              // 2 - immutable source, mutable destination
    this(ref return scope A another) immutable {}              // 3 - mutable source, immutable destination
    this(ref return scope immutable A another) immutable {}    // 4 - immutable source, immutable destination
}

void main()
{
    A a;
    immutable A ia;

    A a2 = a;      // calls 1
    A a3 = ia;     // calls 2
    immutable A a4 = a;     // calls 3
    immutable A a5 = ia;    // calls 4
}

---
    
)

    The `inout` qualifier may be applied to the copy constructor parameter in
    order to specify that mutable, `const`, or `immutable` types are treated the same:
    

    $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
struct A
{
    this(ref return scope inout A rhs) immutable {}
}

void main()
{
    A r1;
    const(A) r2;
    immutable(A) r3;

    // All call the same copy constructor because `inout` acts like a wildcard
    immutable(A) a = r1;
    immutable(A) b = r2;
    immutable(A) c = r3;
}

---
    
)

$(H3 $(ID implicit-copy-constructors) Implicit Copy Constructors)

    A copy constructor is generated implicitly by the compiler for a `struct S`
    if all of the following conditions are met:

    $(NUMBERED_LIST
    * `S` does not explicitly declare any copy constructors;
    * `S` defines at least one direct member that has a copy constructor, and that
    member is not overlapped (by means of `union`) with any other member.
    
)

    If the restrictions above are met, the following copy constructor is generated:

---
this(ref return scope inout(S) src) inout
{
    foreach (i, ref inout field; src.tupleof)
        this.tupleof[i] = field;
}

---

    If the generated copy constructor fails to type check, it will receive the `@disable` attribute.


$(H2 $(ID struct-postblit)Struct Postblits)

$(PRE $(CLASS GRAMMAR)
$(B $(ID Postblit) Postblit):
    `this ( this )` [function#MemberFunctionAttributes|function, MemberFunctionAttributes]$(SUBSCRIPT opt) [function#FunctionBody|function, FunctionBody]

)

    Warning: The postblit is considered legacy and is not recommended for new code.
    Code should use [#struct-copy-constructor|copy constructors]
    defined in the previous section. For backward compatibility reasons, a `struct` that
    explicitly defines both a copy constructor and a postblit will only use the postblit
    for implicit copying. However, if the postblit is disabled, the copy constructor will
    be used. If a struct defines a copy constructor (user-defined or generated) and has
    fields that define postblits, a deprecation will be issued, informing that the postblit
    will have priority over the copy constructor.

        $(I Copy construction) is defined as initializing
         a struct instance from another instance of the same type.
         Copy construction is divided into two parts:

        $(NUMBERED_LIST
        * blitting the fields, i.e. copying the bits
        * running $(I postblit) on the result
        
)

        The first part is done automatically by the language,
        the second part is done if a postblit function is defined
        for the struct.
        The postblit has access only to the destination struct object,
        not the source.
        Its job is to 'fix up' the destination as necessary, such as
        making copies of referenced data, incrementing reference counts,
        etc. For example:
        

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
struct S
{
    int[] a;    // array is privately owned by this instance
    this(this)
    {
        a = a.dup;
    }
}

---
        
)

        Disabling struct postblit makes the object not copyable.
        

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
struct T
{
    @disable this(this);  // disabling makes T not copyable
}
struct S
{
    T t;   // uncopyable member makes S also not copyable
}

void main()
{
    S s;
    S t = s; // error, S is not copyable
}

---
        
)

        Depending on the struct layout, the compiler may generate the following
        internal postblit functions:

        $(NUMBERED_LIST
        * `void __postblit()`. The compiler assigns this name to the explicitly
        defined postblit `this(this)` so that it can be treated exactly as
        a normal function. Note that if a struct defines a postblit, it cannot
        define a function named `__postblit` - no matter the signature -
        as this would result in a compilation error due to the name conflict.
        * `void __fieldPostblit()`. If a struct `X` has at least one `struct`
        member that in turn defines (explicitly or implicitly) a postblit, then a field
        postblit is generated for `X` that calls all the underlying postblits
        of the struct fields in declaration order.
        * `void __aggrPostblit()`. If a struct has an explicitly defined postblit
        and at least 1 struct member that has a postblit (explicit or implicit)
        an aggregated postblit is generated which calls `__fieldPostblit` first
        and then `__postblit`.
        * `void __xpostblit()`. The field and aggregated postblits, although
        generated for a struct, are not actual struct members. In order to be able
        to call them, the compiler internally creates an alias, called `__xpostblit`
        which is a member of the struct and which points to the generated postblit that
        is the most inclusive.
        
)

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
// struct with alias __xpostblit = __postblit
struct X
{
    this(this) {}
}

// struct with alias __xpostblit = __fieldPostblit
// which contains a call to X.__xpostblit
struct Y
{
    X a;
}

// struct with alias __xpostblit = __aggrPostblit which contains
// a call to Y.__xpostblit and a call to Z.__postblit
struct Z
{
    Y a;
    this(this) {}
}

void main()
{
    // X has __postblit and __xpostblit (pointing to __postblit)
    static assert(__traits(hasMember, X, "__postblit"));
    static assert(__traits(hasMember, X, "__xpostblit"));

    // Y does not have __postblit, but has __xpostblit (pointing to __fieldPostblit)
    static assert(!__traits(hasMember, Y, "__postblit"));
    static assert(__traits(hasMember, Y, "__xpostblit"));
    // __fieldPostblit is not a member of the struct
    static assert(!__traits(hasMember, Y, "__fieldPostblit"));

    // Z has  __postblit and __xpostblit (pointing to __aggrPostblit)
    static assert(__traits(hasMember, Z, "__postblit"));
    static assert(__traits(hasMember, Z, "__xpostblit"));
    // __aggrPostblit is not a member of the struct
    static assert(!__traits(hasMember, Z, "__aggrPostblit"));
}

---

)

        Neither of the above postblits is defined for structs that don't
        define `this(this)` and don't have fields that transitively define it.
        If a struct does not define a postblit (implicit or explicit) but
        defines functions that use the same name/signature as the internally
        generated postblits, the compiler is able to identify that the functions
        are not actual postblits and does not insert calls to them when the
        struct is copied. Example:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
struct X
{}

int a;

struct Y
{
    int a;
    X b;
    void __fieldPostPostblit()
    {
        a = 42;
    }
}

void main()
{
    static assert(!__traits(hasMember, X, "__postblit"));
    static assert(!__traits(hasMember, X, "__xpostblit"));

    static assert(!__traits(hasMember, Y, "__postblit"));
    static assert(!__traits(hasMember, Y, "__xpostblit"));

    Y y;
    auto y2 = y;
    assert(a == 0); // __fieldPostBlit does not get called
}

---

)

        Postblits cannot be overloaded. If two or more postblits are defined,
        even if the signatures differ, the compiler assigns the
        `__postblit` name to both and later issues a conflicting function
        name error:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
struct X
{
    this(this) {}
    this(this) const {} // error: function X.__postblit conflicts with function X.__postblit
}

---

)

        The following describes the behavior of the
        qualified postblit definitions:

        $(NUMBERED_LIST
        * `const`. When a postblit is qualified with `const` as in
        `this(this) const;` or `const this(this);` then the postblit
        is successfully called on mutable (unqualified), `const`,
        and `immutable` objects, but the postblit cannot modify the object
        because it regards it as `const`; hence `const` postblits are of
        limited usefulness. Example:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
struct S
{
    int n;
    this(this) const
    {
        import std.stdio : writeln;
        writeln("postblit called");
        //++n; // error: cannot modify this.n in `const` function
    }
}

void main()
{
    S s1;
    auto s2 = s1;
    const S s3;
    auto s4 = s3;
    immutable S s5;
    auto s6 = s5;
}

---

)
        * `immutable`. When a postblit is qualified with `immutable`
        as in `this(this) immutable` or `immutable this(this)`
        the code is ill-formed. The `immutable` postblit passes the
        compilation phase but cannot be invoked. Example:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
struct Y
{
    // not invoked anywhere, no error is issued
    this(this) immutable
    { }
}

struct S
{
    this(this) immutable
    { }
}

void main()
{
    S s1;
    auto s2 = s1;    // error: immutable method `__postblit` is not callable using a mutable object
    const S s3;
    auto s4 = s3;    // error: immutable method `__postblit` is not callable using a mutable object
    immutable S s5;
    auto s6 = s5;    // error: immutable method `__postblit` is not callable using a mutable object
}

---

)

        * `shared`. When a postblit is qualified with `shared` as in
        `this(this) shared` or `shared this(this)` solely `shared`
        objects may invoke the postblit; attempts of postbliting unshared
        objects will result in compile time errors:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
struct S
{
    this(this) shared
    { }
}

void main()
{
    S s1;
    auto s2 = s1;    // error: shared method `__postblit` is not callable using a non-shared object
    const S s3;
    auto s4 = s3;    // error: shared method `__postblit` is not callable using a non-shared object
    immutable S s5;
    auto s6 = s5;    // error: shared method `__postblit` is not callable using a non-shared object

    // calling the shared postblit on a shared object is accepted
    shared S s7;
    auto s8 = s7;
}

---

)
        
)

        An unqualified postblit will get called even if the
        struct is instantiated as `immutable` or `const`, but
        the compiler issues an error if the struct is instantiated
        as `shared`:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
struct S
{
    int n;
    this(this) { ++n; }
}

void main()
{
    immutable S a;      // shared S a; =&gt; error : non-shared method is not callable using a shared object
    auto a2 = a;
    import std.stdio: writeln;
    writeln(a2.n);     // prints 1
}

---

)

        From a postblit perspective, qualifiying the struct definition
        yields the same result as explicitly qualifying the postblit.

        The following table lists all the possibilities of grouping
        qualifiers for a postblit associated with the type of object that
        needs to be used in order to successfully invoke the postblit:

        $(TABLE_ROWS
Qualifier Groups
        $(VERTROW object type to be invoked on, `const`, `immutable`, `shared`),
        * - any object type
-                 yes
-     no
-          no 

        * - uncallable
-                      no
-      yes
-         no 

        * - shared object
-                   no
-      no
-          yes

        * - uncallable
-                      yes
-     yes
-         no 

        * - shared object
-                   yes
-     no
-          yes

        * - uncallable
-                      no
-      yes
-         yes

        * - uncallable
-                      yes
-     yes
-         yes

        
)

        Note that when `const` and `immutable` are used to explicitly
        qualify a postblit as in `this(this) const immutable;` or
        `const immutable this(this);` - the order in which the qualifiers
        are declared does not matter - the compiler generates a conflicting
        attribute error, however declaring the struct as `const`/`immutable`
        and the postblit as `immutable`/`const` achieves the effect of applying
        both qualifiers to the postblit. In both cases the postblit is
        qualified with the more restrictive qualifier, which is `immutable`.
        

        The postblits `__fieldPostblit` and `__aggrPostblit`
        are generated without any implicit qualifiers and are not considered
        struct members. This leads to the situation where qualifying an
        entire struct declaration with `const` or `immutable` does not have
        any impact on the above-mentioned postblits. However, since `__xpostblit`
        is a member of the struct and an alias of one of the other postblits,
        the qualifiers applied to the struct will affect the aliased postblit.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
struct S
{
    this(this)
    { }
}

// `__xpostblit` aliases the aggregated postblit so the `const` applies to it.
// However, the aggregated postblit calls the field postblit which does not have
// any qualifier applied, resulting in a qualifier mismatch error
const struct B
{
    S a;        // error : mutable method B.__fieldPostblit is not callable using a const object
    this(this)
    { }
}

// `__xpostblit` aliases the field postblit; no error
const struct B2
{
    S a;
}

// Similar to B
immutable struct C
{
    S a;        // error : mutable method C.__fieldPostblit is not callable using a immutable object
    this(this)
    { }
}

// Similar to B2, compiles
immutable struct C2
{
    S a;
}

---

)

        In the above situations the errors do not contain line numbers because
        the errors are regarding generated code.
        

        Qualifying an entire struct as `shared` correctly propagates the attribute
        to the generated postblits:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
shared struct A
{
    this(this)
    {
        import std.stdio : writeln;
        writeln("the shared postblit was called");
    }
}

struct B
{
    A a;
}

void main()
{
    shared B b1;
    auto b2 = b1;
}

---

)

        Unions may have fields that have postblits. However, a union itself never has
        a postblit. Copying a union does not result in postblit calls for any fields.
        If those calls are desired, they must be inserted explicitly by the programmer:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
struct S
{
    int count;
    this(this)
    {
        ++count;
    }
}

union U
{
    S s;
}

void main()
{
    U a = U.init;
    U b = a;
    assert(b.s.count == 0);
    b.s.__postblit;
    assert(b.s.count == 1);
}

---

)

$(H2 $(ID struct-destructor)Struct Destructors)

        Destructors are called implicitly when an object goes out of scope, or
        [#assign-overload|before an assignment] (by default).
        Their purpose is to free up resources owned by the struct
        object.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
struct S
{
    int i;

    ~this()
    {
        import std.stdio;
        writeln("S(", i, ") is being destructed");
    }
}

void main()
{
    auto s1 = S(1);
    {
        auto s2 = S(2);
        // s2 destructor called
    }
    S(3); // s3 destructor called
    // s1 destructor called
}

---

)
        If the struct has a field of another struct type which itself has a destructor,
        that destructor will be called at the end of the parent destructor. If there is no
        parent destructor, the compiler will generate one. Similarly, a
        static array of a struct type with a destructor will have the destructor
        called for each element when the array goes out of scope.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
struct S
{
    char c;

    ~this()
    {
        import std.stdio;
        writeln("S(", c, ") is being destructed");
    }
}

struct Q
{
    S a;
    S b;
}

void main()
{
    Q q = Q(S('a'), S('b'));
    S[2] arr = [S('0'), S('1')];
    // destructor called for arr[1], arr[0], q.b, q.a
}

---

)

        A destructor for a struct instance can also be called early using
        [object.destroy|destroy]. Note that the destructor will still
        be called again when the instance goes out of scope.

        Struct destructors are used for $(LINK2 spec/glossary#raii,RAII).


$(H2 $(ID union-field-destruction) Union Field Destruction)

        Unions may have fields that have destructors. However, a union itself never has
        a destructor. When a union goes out of scope, destructors for its fields <em>are not called</em>.
        If those calls are desired, they must be inserted explicitly by the programmer:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
struct S
{
    ~this()
    {
        import std.stdio;
        writeln("S is being destructed");
    }
}

union U
{
    S s;
}

void main()
{
    import std.stdio;
    {
        writeln("entering first scope");
        U u = U.init;
        scope (exit) writeln("exiting first scope");
    }
    {
        writeln("entering second scope");
        U u = U.init;
        scope (exit)
        {
            writeln("exiting second scope");
            destroy(u.s);
        }
    }
}

---

)

$(H2 $(ID Invariant) Struct Invariants)

$(PRE $(CLASS GRAMMAR)
$(B $(ID Invariant) Invariant):
    `invariant ( )` [statement#BlockStatement|statement, BlockStatement]
    `invariant` [statement#BlockStatement|statement, BlockStatement]
    `invariant (` [expression#AssertArguments|expression, AssertArguments] `) ;`

)

    Struct $(I Invariant)s specify the relationships among the members of a struct instance.
    Those relationships must hold for any interactions with the instance from its
    public interface.
    

    The invariant is in the form of a `const` member function. The invariant is defined
    to $(I hold) if all the [expression#AssertExpression|expression, AssertExpression]s within the invariant that are executed
    succeed.
    

    $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
struct Date
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

    There may be multiple invariants in a struct. They are applied in lexical order.

    Struct $(I Invariant)s must hold at the exit of the struct constructor (if any),
    and at the entry of the struct destructor (if any).

    Struct $(I Invariant)s must hold
    at the entry and exit of all public or exported non-static member functions.
    The order of application of invariants is:
    
    $(NUMBERED_LIST
    * preconditions
    * invariant
    * function body
    * invariant
    * postconditions
    
)

    The invariant need not hold if the struct instance is implicitly constructed using
    the default `.init` value.

    If the invariant does not hold, then the program enters an invalid state.

    $(WARNING     $(NUMBERED_LIST
    * Whether the struct $(I Invariant) is executed at runtime or not. This is typically
    controlled with a compiler switch.
    * The behavior when the invariant does not hold is typically the same as
    for when [expression#AssertExpression|expression, AssertExpression]s fail.
    
)
    )

    $(PITFALL happens if the invariant does not hold and execution continues.)

    Public or exported non-static member functions cannot be called from within an invariant.

    $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
struct Foo
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
    
)

    $(TIP     $(NUMBERED_LIST
    * Do not indirectly call exported or public member functions within a struct invariant,
    as this can result in infinite recursion.
    * Avoid reliance on side effects in the invariant. as the invariant may or may not
    be executed.
    * Avoid having mutable public fields of structs with invariants,
    as then the invariant cannot verify the public interface.
    
)
    )



$(H2 $(ID assign-overload)Identity Assignment Overload)

        While copy construction takes care of initializing
        an object from another object of the same type,
        assignment is defined as copying the contents of a source
        object over those of a destination object, calling the
        destination object's destructor if it has one in the process:
        

---
struct S { ... }  // S has postblit or destructor
S s;      // default construction of s
S t = s;  // t is copy-constructed from s
t = s;    // t is assigned from s

---

        Struct assignment `t=s` is defined to be semantically
        equivalent to:
        

---
t.opAssign(s);

---

        where `opAssign` is a member function of S:

---
ref S opAssign(ref S s)
{
    S tmp = this;   // bitcopy this into tmp
    this = s;       // bitcopy s into this
    tmp.__dtor();   // call destructor on tmp
    return this;
}

---

        An identity assignment overload is required for a struct if one or more of
        these conditions hold:

        $(LIST
        * it has a [#struct-destructor|destructor]
        * it has a [#struct-postblit|postblit]
        * it has a field with an identity assignment overload
        
)

        If an identity assignment overload is required and does not
        exist, an identity assignment overload function of the type
        `ref S opAssign(ref S)`  will be automatically generated.

        A user-defined one can implement the equivalent semantics, but can
        be more efficient.
        

        One reason a custom `opAssign` might be more efficient
        is if the struct has a reference to a local buffer:
        

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
struct S
{
    int[] buf;
    int a;

    ref S opAssign(ref const S s) return
    {
        a = s.a;
        return this;
    }

    this(this)
    {
        buf = buf.dup;
    }
}

---
        
)

        Here, `S` has a temporary workspace `buf[]`.
        The normal postblit
        will pointlessly free and reallocate it. The custom `opAssign`
        will reuse the existing storage.
        

$(H2 $(ID alias-this)Alias This)

$(PRE $(CLASS GRAMMAR)
$(B $(ID AliasThis) AliasThis):
    `alias` $(LINK2 lex#Identifier, Identifier) `this ;`
    `alias` `this` `=` $(LINK2 lex#Identifier, Identifier) `;`

)

        An $(I AliasThis) declaration names a member to subtype.
        The $(I Identifier) names that member.
        

        A struct or union instance can be implicitly converted to the $(I AliasThis)
        member.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
struct S
{
    int x;
    alias x this;
}

int foo(int i) { return i * 2; }

void main()
{
    S s;
    s.x = 7;
    int i = -s;
    assert(i == -7);
    i = s + 8;
    assert(i == 15);
    i = s + s;
    assert(i == 14);
    i = 9 + s;
    assert(i == 16);
    i = foo(s);  // implicit conversion to int
    assert(i == 14);
}

---

)

        If the member is a class or struct, undefined lookups will
        be forwarded to the $(I AliasThis) member.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
class Foo
{
    int baz = 4;
    int get() { return 7; }
}

struct Bar
{
    Foo foo;
    alias foo this;
}

void main()
{
    Bar bar = Bar(new Foo());
    int i = bar.baz;
    assert(i == 4);
    i = bar.get();
    assert(i == 7);
}

---

)

        If the $(I Identifier) refers to a property member
        function with no parameters then conversions and undefined
        lookups are forwarded to the return value of the function.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
struct S
{
    int x;
    @property int get()
    {
        return x * 2;
    }
    alias get this;
}

void main()
{
    S s;
    s.x = 2;
    int i = s;
    assert(i == 4);
}

---

)

        If a struct declaration defines an `opCmp` or `opEquals`
        method, it will take precedence to that of the <em>AliasThis</em> member. Note
        that, unlike an `opCmp` method, an `opEquals` method is implicitly
        defined for a `struct` declaration if a user-defined one isn't provided.
        This means that if the <em>AliasThis</em> member's `opEquals` should be used, it
        must be explicitly defined:
        
$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
struct S
{
    int a;
    bool opEquals(S rhs) const
    {
        return this.a == rhs.a;
    }
}

struct T
{
    int b;
    S s;
    alias s this;
}

void main()
{
    S s1, s2;
    T t1, t2;

    assert(s1 == s2);      // calls S.opEquals
    assert(t1 == t2);      // calls compiler generated T.opEquals that implements member-wise equality

    assert(s1 == t1);      // calls s1.opEquals(t1.s);
    assert(t1 == s1);      // calls t1.s.opEquals(s1);
}

---

)
$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
struct U
{
    int a;
    bool opCmp(U rhs) const
    {
        return this.a &lt; rhs.a;
    }
}

struct V
{
    int b;
    U u;
    alias u this;
}

void main()
{
    U u1, u2;
    V v1, v2;

    assert(!(u1 &lt; u2));    // calls U.opCmp
    assert(!(v1 &lt; v2));    // calls U.opCmp because V does not define an opCmp method
                           // so the alias this of v1 is employed; U.opCmp expects a
                           // paramter of type U, so alias this of v2 is used

    assert(!(u1 &lt; v1));    // calls u1.opCmp(v1.u);
    assert(!(v1 &lt; u1));    // calls v1.u.opCmp(v1);
}

---

)
        [attribute#Attribute|attribute, Attribute]s are ignored for `AliasThis`.
        

        A struct/union may only have a single $(I AliasThis) member.



$(H2 $(ID nested) Nested Structs)

    A struct is a $(I nested struct) if

        $(NUMBERED_LIST
        * it is declared inside the scope of a function, or
        * it is a templated struct with one or more template arguments
             that alias local functions.
        
)

    A nested struct can have member functions.
        It has access to the context of its enclosing scope
        via a hidden field.

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
void foo()
{
    int i = 7;
    struct SS
    {
        int x,y;
        int bar() { return x + i + 1; }
    }
    SS s;
    s.x = 3;
    s.bar(); // returns 11
}

---
        
)

    The static attribute will prevent a struct from being nested. As such,
        the struct will not have access to its enclosing scope.

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
void foo()
{
    int i = 7;
    static struct SS
    {
        int x, y;
        int bar()
        {
            return i; // error, SS is not a nested struct
        }
    }
}

---
        
)

$(H2 $(ID unions_and_special_memb_funct) Unions and Special Member Functions)

    Unions may not have postblits, destructors, or invariants.

hash-map, Associative Arrays, class, Classes




Link_References:
	ACC = Associated C Compiler
+/
module struct.dd;