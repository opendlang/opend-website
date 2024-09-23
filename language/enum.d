// just docs: Enums
/++





$(PRE $(CLASS GRAMMAR)
$(B $(ID EnumDeclaration) EnumDeclaration):
    `enum` $(LINK2 lex#Identifier, Identifier) [#EnumBody|EnumBody]
    `enum` $(LINK2 lex#Identifier, Identifier) `:` [#EnumBaseType|EnumBaseType] [#EnumBody|EnumBody]
    [#AnonymousEnumDeclaration|AnonymousEnumDeclaration]

$(B $(ID EnumBaseType) EnumBaseType):
    [type#Type|type, Type]

$(B $(ID EnumBody) EnumBody):
    `{` [#EnumMembers|EnumMembers] `}`
    `;`

$(B $(ID EnumMembers) EnumMembers):
    [#EnumMember|EnumMember]
    [#EnumMember|EnumMember] `,`
    [#EnumMember|EnumMember] `,` EnumMembers

$(B $(ID EnumMember) EnumMember):
    [#EnumMemberAttributes|EnumMemberAttributes]$(SUBSCRIPT opt) $(LINK2 lex#Identifier, Identifier)
    [#EnumMemberAttributes|EnumMemberAttributes]$(SUBSCRIPT opt) $(LINK2 lex#Identifier, Identifier) `=` AssignExpression

$(B $(ID EnumMemberAttributes) EnumMemberAttributes):
    [#EnumMemberAttribute|EnumMemberAttribute]
    [#EnumMemberAttribute|EnumMemberAttribute] EnumMemberAttributes

$(B $(ID EnumMemberAttribute) EnumMemberAttribute):
    [attribute#DeprecatedAttribute|attribute, DeprecatedAttribute]
    [attribute#UserDefinedAttribute|attribute, UserDefinedAttribute]
    `@`$(LINK2 attribute.html#disable, `disable`)

)
$(PRE $(CLASS GRAMMAR)
$(B $(ID AnonymousEnumDeclaration) AnonymousEnumDeclaration):
    `enum` `:` [#EnumBaseType|EnumBaseType] `{` [#EnumMembers|EnumMembers] `}`
    `enum` `{` [#AnonymousEnumMembers|AnonymousEnumMembers] `}`

$(B $(ID AnonymousEnumMembers) AnonymousEnumMembers):
    [#AnonymousEnumMember|AnonymousEnumMember]
    [#AnonymousEnumMember|AnonymousEnumMember] `,`
    [#AnonymousEnumMember|AnonymousEnumMember] `,` AnonymousEnumMembers

$(B $(ID AnonymousEnumMember) AnonymousEnumMember):
    [#EnumMember|EnumMember]
    [#EnumMemberAttributes|EnumMemberAttributes]$(SUBSCRIPT opt) [type#Type|type, Type] $(LINK2 lex#Identifier, Identifier) `=` AssignExpression

)

        Enum declarations are used to define a group of constants.
        

$(H2 $(ID named_enums) Named Enums)

                Named enums are used to declare related
        constants and group them by giving them a unique type.
        The [#EnumMembers|EnumMembers] are declared in the scope of the named enum. The named
        enum declares a new type, and all the $(I EnumMembers) have that type.
        

        This defines a new type `X` which has values
        `X.A=0`, `X.B=1`, `X.C=2`:

---
enum X { A, B, C }  // named enum

---


        If the [#EnumBaseType|EnumBaseType] is not explicitly set, and the first
        $(I EnumMember) has an <em>AssignExpression</em>, it is set to the type of that
        <em>AssignExpression</em>. Otherwise, it defaults to
        type `int`.

$(LIST
* A named enum member can be implicitly cast to its $(I EnumBaseType).
* An $(I EnumBaseType) instance cannot be implicitly cast to a named enum type.


)
$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
int i;

enum Foo { E }
Foo f;
i = f;           // OK
f = i;           // error
f = cast(Foo)i;  // OK
f = 0;           // error
f = Foo.E;       // OK

---

)

        A named enum member does not have an individual $(I Type).

        The value of an [#EnumMember|EnumMember] is given by its <em>AssignExpression</em> if present.
        If there is no <em>AssignExpression</em> and it is the first $(I EnumMember),
        its value is converted to [#EnumBaseType|EnumBaseType] from `0`.
        If there is no <em>AssignExpression</em> and it is not the first $(I EnumMember),
        it is given the value of the previous $(I EnumMember)`+1`:

$(LIST
* If the value of the previous $(I EnumMember) is [#EnumBaseType|EnumBaseType]`.max`,
          it is an error. This prevents value overflow. It is an error if the previous
          member cannot be compared with <em>EnumBaseType</em>`.max` at compile-time.
* It is an error if the base type does not define a compile-time
          evaluable `+1` operation.
* If the value of the previous $(I EnumMember)`+1` is the same as the
          value of the previous $(I EnumMember), it is an error. (This can happen
          with floating point types).


)
$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
enum E : char
{
    a,
    b = char.max,
    c // overflow
}

static assert(E.a == 0);

---

)

        All $(I EnumMember)s are in scope for the <em>AssignExpression</em>s.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
enum A = 3;
enum B
{
    A = A // error, circular reference
}
enum C
{
    A = B,  // A = 4
    B = D,  // B = 4
    C = 3,  // C = 3
    D       // D = 4
}
enum E : C
{
    E1 = C.D,
    E2      // error, C.D is C.max
}

---

)

        An empty enum body signifies an opaque enum - the enum members are unknown.
---
enum X;          // opaque enum
writeln(X.init); // error: enum X is opaque and has no default initializer

---

$(H3 $(ID enum_variables)Enum Variables)

        A variable can be of named enum type.
        The default initializer is the first member defined for the enum type.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
enum X { A=3, B, C }
X x;
assert(x == X.A);
x |= X.B;
assert(x &amp; X.A);

---

)

        The result type of a binary operation performed when the operands have
        different types is defined $(LINK2 spec/type#enum-ops,here).

        See also: $(LINK2 spec/statement#final-switch-statement,`final switch`).

$(H3 $(ID enum_properties) Enum Properties)

        Enum properties only exist for named enums.
        

        $(TABLE         $(CAPTION Named Enum Properties)
        * - `.init`
- First enum member value

        * - `.min`
- Smallest enum member value

        * - `.max`
- Largest enum member value

        * - `.sizeof`
- Size of storage for an enumerated value

        )

        For example:

---
enum X { A=3, B=1, C=4, D, E=2 }
X.init   // is X.A
X.min    // is X.B
X.max    // is X.D
X.sizeof // is same as int.sizeof

---

        The [#EnumBaseType|EnumBaseType] of named enums must support comparison
        in order to compute the `.max` and `.min` properties.
        

$(H3 $(ID enum_copying_and_assignment) Enum Copying and Assignment)

        A named enum type never has a
        $(LINK2 spec/struct#struct-copy-constructor,copy constructor),
        $(LINK2 spec/struct#struct-postblit,postblit), or
        $(LINK2 spec/struct#assign-overload,identity assignment overload),
        even if one is defined by its [#EnumBaseType|EnumBaseType].

        When copying a named enum value whose base type is a `struct` with
        a copy constructor, the copy constructor is not called:

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
struct S
{
    this(ref S rhs) { assert(0); }
}

enum E : S { A = S.init }

void main()
{
    E e1;
    E e2 = e1; // ok - copy constructor not called
}

---
        
)

        When copying a named enum value whose base type is a `struct` with
        a postblit, the postblit is not called:

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
struct S
{
    this(this) { assert(0); }
}

enum E : S { A = S.init }

void main()
{
    E e1;
    E e2 = e1; // ok - postblit not called
}

---
        
)

        When assigning a named enum value to another object of the same
        type, if the base type of those values is a `struct` with an identity
        assignment overload, the identity assignment overload is not called:

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
struct S
{
    void opAssign(S rhs) { assert(0); }
}

enum E : S { A = S.init }

void main()
{
    E e1, e2;
    e2 = e1; // ok - opAssign not called
}

---
        
)


$(H2 $(ID anonymous_enums) Anonymous Enums)

        If the enum $(I Identifier) is not present, then the enum
        is an $(I anonymous enum), and the [#EnumMembers|EnumMembers] are declared
        in the scope the [#EnumDeclaration|EnumDeclaration] appears in.
        No new type is created.
        

        The $(I EnumMembers) can have different types.
        Those types are given by the first of:
        

        $(NUMBERED_LIST
        * The $(I Type), if present. Types are not permitted when an
                [#EnumBaseType|EnumBaseType] is present.
        * The $(I EnumBaseType), if present.
        * The type of the $(I AssignExpression), if present.
        * The type of the previous $(I EnumMember), if present.
        * `int`
        
)


---
enum { A, B, C }  // anonymous enum

---

        Defines the constants A=0, B=1, C=2, all of type `int`.

        Enums must have at least one member.
        

        The value of an $(I EnumMember) is given by its <em>AssignExpression</em> if present.
        If there is no <em>AssignExpression</em> and it is the first $(I EnumMember),
        its value is the `.init` property of the $(I EnumMember)'s type.
        If there is no <em>AssignExpression</em> and it is not the first $(I EnumMember),
        it is given the value of the previous $(I EnumMember)`+1`:

$(LIST
* If the value of the previous $(I EnumMember) is the `.max` property
          of the previous $(I EnumMember)'s type, it is an error.
          This prevents value overflow. It is an error if the previous
          member cannot be compared with its `.max` property at compile-time.
* It is an error if the type of the previous member does not define a compile-time
          evaluable `+1` operation.
* If the value of the previous $(I EnumMember)`+1` is the same as the
          value of the previous $(I EnumMember), it is an error. (This can happen
          with floating point types).


)
        All $(I EnumMember)s are in scope for the <em>AssignExpression</em>s.
        

---
enum { A, B = 5+7, C, D = 8+C, E }

---

        Sets A=0, B=12, C=13, D=21, and E=22, all of type `int`.

---
enum : long { A = 3, B }

---

        Sets A=3, B=4 all of type `long`.

---
enum : string
{
    A = "hello",
    B = "betty",
    C     // error, cannot add 1 to "betty"
}

---

---
enum
{
    A = 1.2f,  // A is 1.2f of type float
    B,         // B is 2.2f of type float
    int C = 3, // C is 3 of type int
    D          // D is 4 of type int
}

---

$(H3 $(ID single_member) Single Member Syntax)

        If there is only one member of an anonymous enum, the `{ }` can
        be omitted. Gramatically speaking, this is an [declaration#AutoDeclaration|declaration, AutoDeclaration].
        

---
enum i = 4;      // i is 4 of type int
enum long l = 3; // l is 3 of type long

---

$(H2 $(ID manifest_constants) Manifest Constants)

        Enum members are manifest constants, which exist only at compile-time.

        Manifest constants are not lvalues, meaning their address
        cannot be taken.  They exist only in the memory of the compiler.

---
enum size = __traits(classInstanceSize, Foo);  // evaluated at compile-time

---

        The initializer for a manifest constant is evaluated using compile time function evaluation.

---
template Foo(T)
{
    // Not bad, but the 'size' variable will be located in the executable.
    const size_t size = T.sizeof;       // evaluated at compile-time

    // ... use of 'size' at compile time ...
}

template Bar(T)
{
    // Better, the manifest constant has no runtime location in the executable.
    enum size_t size = T.sizeof;        // evaluated at compile-time

    // ... use of 'size' at compile time ...

    // Taking the address of Foo!T.size also causes it to go into the exe file.
    auto p = &amp;Foo!T.size;
}

---


interface, Interfaces, const3, Type Qualifiers




Link_References:
	ACC = Associated C Compiler
+/
module enum.dd;