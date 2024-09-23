// just docs: Templates
/++





$(H2 $(ID declarations) Template Declarations)

    Templates are D's approach to generic programming.
        Templates can be defined with a $(I TemplateDeclaration):
    

$(PRE $(CLASS GRAMMAR)
$(B $(ID TemplateDeclaration) TemplateDeclaration):
    `template` $(LINK2 lex#Identifier, Identifier) [#TemplateParameters|TemplateParameters] [#Constraint|Constraint]$(SUBSCRIPT opt) `{` [module#DeclDefs|module, DeclDefs]$(SUBSCRIPT opt) `}`

$(B $(ID TemplateParameters) TemplateParameters):
    `(` [#TemplateParameterList|TemplateParameterList]$(SUBSCRIPT opt) `)`

$(B $(ID TemplateParameterList) TemplateParameterList):
    [#TemplateParameter|TemplateParameter]
    [#TemplateParameter|TemplateParameter] `,`
    [#TemplateParameter|TemplateParameter] `,` TemplateParameterList

)

    The <em>DeclDefs</em> body of the template must be syntactically correct
        even if never instantiated. Semantic analysis is not done until
        instantiation. A template forms its own scope, and the template
        body can contain declarations such as classes, structs, types,
        enums, variables, functions, and other templates.
    

    [#parameters|Template parameters] can take types,
        values, symbols, or sequences.

---
template t(T) // declare type parameter T
{
    T v; // declare a member variable of type T within template t
}

---

    A template parameter can have a <em>specialization</em> which
        constrains an argument the $(I TemplateParameter) can
        accept.

---
template t(T : int) // type T must implicitly convert to int
{
    ...
}

---

    If multiple templates with the same $(I Identifier) are
        declared, they are distinct if they have different parameters
        or are differently specialized.
    

    If a template has a member which has the same identifier as the
        template, the template is an
        [#implicit_template_properties|Eponymous Template].
        `template` declarations with one eponymous member are usually
        written as specific [#aggregate_templates|short syntax]
        template declarations instead.


$(H2 $(ID template_instantiation) Template Instantiation)

    A template must be instantiated before use. This means
    passing an argument list to the template.
    Those arguments are typically then substituted
    into the template body, which becomes a new scoped entity.

    [#function-templates|Function templates] can
    be implicitly instantiated if the compiler can infer the template
    arguments from a function call. Otherwise the template must be
    instantiated explicitly.

$(H3 $(ID explicit_tmp_instantiation) Explicit Template Instantiation)

    Templates are explicitly instantiated using a `!` after the
    template name, then either an argument list or a single token
    argument.

$(PRE $(CLASS GRAMMAR)
$(B $(ID TemplateInstance) TemplateInstance):
    $(LINK2 lex#Identifier, Identifier) [#TemplateArguments|TemplateArguments]

$(B $(ID TemplateArguments) TemplateArguments):
    `! (` [#TemplateArgumentList|TemplateArgumentList]$(SUBSCRIPT opt) `)`
    `!` [#TemplateSingleArgument|TemplateSingleArgument]

$(B $(ID TemplateArgumentList) TemplateArgumentList):
    [#TemplateArgument|TemplateArgument]
    [#TemplateArgument|TemplateArgument] `,`
    [#TemplateArgument|TemplateArgument] `,` TemplateArgumentList

$(B $(ID TemplateSingleArgument) TemplateSingleArgument):
    $(LINK2 lex#Identifier, Identifier)
    [type#FundamentalType|type, FundamentalType]
    $(LINK2 lex#CharacterLiteral, CharacterLiteral)
    $(LINK2 lex#StringLiteral, StringLiteral)
    [istring#InterpolationExpressionSequence|istring, InterpolationExpressionSequence]
    $(LINK2 lex#IntegerLiteral, IntegerLiteral)
    $(LINK2 lex#FloatLiteral, FloatLiteral)
    `true`
    `false`
    `null`
    `this`
    [expression#SpecialKeyword|expression, SpecialKeyword]

)

    A template argument can be a type, compile-time expression
    or a symbol.

$(PRE $(CLASS GRAMMAR)
$(B $(ID TemplateArgument) TemplateArgument):
    [type#Type|type, Type]
    AssignExpression
    [#Symbol|Symbol]

$(B $(ID Symbol) Symbol):
    [#SymbolTail|SymbolTail]
    `.` [#SymbolTail|SymbolTail]

$(B $(ID SymbolTail) SymbolTail):
    $(LINK2 lex#Identifier, Identifier)
    $(LINK2 lex#Identifier, Identifier) `.` SymbolTail
    [#TemplateInstance|TemplateInstance]
    [#TemplateInstance|TemplateInstance] `.` SymbolTail

)

    Once instantiated, the declarations inside the template, called
        the template members, are in the scope
        of the $(I TemplateInstance):

---
template TFoo(T) { alias Ptr = T*; }
...
TFoo!(int).Ptr x; // declare x to be of type int*

---

    If the [#TemplateArgument|TemplateArgument] is one token long, the parentheses can be omitted:

---
TFoo!int.Ptr x;   // same as TFoo!(int).Ptr x;

---

    A template instantiation can be aliased:

---
template TFoo(T) { alias Ptr = T*; }
alias foo = TFoo!(int);
foo.Ptr x;        // declare x to be of type int*

---

$(H3 $(ID common_instantiation) Common Instantiation)

    Multiple instantiations of a $(I TemplateDeclaration) with the same
        $(I TemplateArgumentList) will all refer to the same instantiation.
        For example:

---
template TFoo(T) { T f; }
alias a = TFoo!(int);
alias b = TFoo!(int);
...
a.f = 3;
assert(b.f == 3);  // a and b refer to the same instance of TFoo

---

    This is true even if the $(I TemplateInstance)s are done in
        different modules.
    

    Even if template arguments are implicitly converted to the same
        template parameter type, they still refer to the same instance.
        This example uses a [#TemplateValueParameter|TemplateValueParameter] and a
        [#aggregate_templates|`struct` template]:

---
struct TFoo(int x) { }

// Different template parameters create different struct types
static assert(!is(TFoo!(3) == TFoo!(2)));
// 3 and 2+1 are both 3 of type int - same TFoo instance
static assert(is(TFoo!(3) == TFoo!(2 + 1)));

// 3u is implicitly converted to 3 to match int parameter,
// and refers to exactly the same instance as TFoo!(3)
static assert(is(TFoo!(3) == TFoo!(3u)));

---

    $(H3 $(ID copy_example) Practical Example)

    A simple generic copy template would be:

---
template TCopy(T)
{
    void copy(out T to, T from)
    {
        to = from;
    }
}

---

    To use this template, it must first be instantiated with a specific
        type:

---
int i;
TCopy!(int).copy(i, 3);

---
    See also [#function-templates|function templates].

$(H3 $(ID instantiation_scope) Instantiation Scope)

    $(I TemplateInstance)s are always instantiated in the scope of where
        the $(I TemplateDeclaration) is declared, with the addition of the
        template parameters being declared as aliases for their deduced types.
    
    $(B Example:)

        <u>module a:</u>
---
template TFoo(T) { void bar() { func(); } }

---

        <u>module b:</u>
---
import a;

void func() { }
alias f = TFoo!(int); // error: func not defined in module a

---

    $(B Example:)

        <u>module a:</u>
---
template TFoo(T) { void bar() { func(1); } }
void func(double d) { }

---

        <u>module b:</u>
---
import a;

void func(int i) { }
alias f = TFoo!(int);
...
f.bar();  // will call a.func(double)

---

    $(I TemplateParameter) specializations and default
        arguments are evaluated in the scope of the $(I TemplateDeclaration).
    


$(H2 $(ID parameters) Template Parameters)

$(PRE $(CLASS GRAMMAR)
$(B $(ID TemplateParameter) TemplateParameter):
    [#TemplateTypeParameter|TemplateTypeParameter]
    [#TemplateValueParameter|TemplateValueParameter]
    [#TemplateAliasParameter|TemplateAliasParameter]
    [#TemplateSequenceParameter|TemplateSequenceParameter]
    [#TemplateThisParameter|TemplateThisParameter]

)

    Template parameters can take types, values, symbols, or sequences.

    $(LIST
    * Type parameters can take any type.
    * Value parameters can take any expression which can be statically
        evaluated at compile time.
    * Alias parameters can take almost any symbol.
    * Sequence parameters can take zero or more types, values or symbols.
    
)

    [#template_parameter_def_values|A default argument]
        specifies the type, value or symbol to use for the
        $(I TemplateParameter) when a matching argument is not supplied.
    

$(H3 $(ID template_type_parameters) Type Parameters)

$(PRE $(CLASS GRAMMAR)
$(B $(ID TemplateTypeParameter) TemplateTypeParameter):
    $(LINK2 lex#Identifier, Identifier)
    $(LINK2 lex#Identifier, Identifier) [#TemplateTypeParameterSpecialization|TemplateTypeParameterSpecialization]
    $(LINK2 lex#Identifier, Identifier) [#TemplateTypeParameterDefault|TemplateTypeParameterDefault]
    $(LINK2 lex#Identifier, Identifier) [#TemplateTypeParameterSpecialization|TemplateTypeParameterSpecialization] [#TemplateTypeParameterDefault|TemplateTypeParameterDefault]

$(B $(ID TemplateTypeParameterSpecialization) TemplateTypeParameterSpecialization):
    `:` [type#Type|type, Type]

$(B $(ID TemplateTypeParameterDefault) TemplateTypeParameterDefault):
    `=` [type#Type|type, Type]

)

$(H4 $(ID parameters_specialization) Specialization and Pattern Matching)

    Templates may be specialized for particular types of arguments
        by following the template parameter identifier with a `:` and the
        pattern for the specialized type.
        For example:

---
template TFoo(T)        { ... } // #1
template TFoo(T : T[])  { ... } // #2
template TFoo(T : char) { ... } // #3
template TFoo(T, U, V)  { ... } // #4

alias foo1 = TFoo!(int);            // instantiates #1
alias foo2 = TFoo!(double[]);       // instantiates #2 matching pattern T[] with T being double
alias foo3 = TFoo!(char);           // instantiates #3
alias fooe = TFoo!(char, int);      // error, number of arguments mismatch
alias foo4 = TFoo!(char, int, int); // instantiates #4

---

    The template picked to instantiate is the one that is most specialized
        that fits the types of the $(I TemplateArgumentList).
        If the result is ambiguous, it is an error.
    

$(H4 $(ID argument_deduction) Type Parameter Deduction)

    The types of template parameters are deduced for a particular
        template instantiation by comparing the template argument with
        the corresponding template parameter.
    

    For each template parameter, the following rules are applied in
        order until a type is deduced for each parameter:
    

    $(NUMBERED_LIST
        * If there is no type specialization for the parameter,
        the type of the parameter is set to the template argument.

        * If the type specialization is dependent on a type parameter,
        the type of that parameter is set to be the corresponding part
        of the type argument.

        * If after all the type arguments are examined, there are any
        type parameters left with no type assigned, they are assigned
        types corresponding to the template argument in the same position
        in the $(I TemplateArgumentList).

        * If applying the above rules does not result in exactly one
        type for each template parameter, then it is an error.
    
)

    For example:

---
template TFoo(T) { }
alias foo1 = TFoo!(int);     // (1) T is deduced to be int
alias foo2 = TFoo!(char*);   // (1) T is deduced to be char*

template TBar(T : T*) { }    // match template argument against T* pattern
alias bar = TBar!(char*);    // (2) T is deduced to be char

template TAbc(D, U : D[]) { }    // D[] is pattern to be matched
alias abc1 = TAbc!(int, int[]);  // (2) D is deduced to be int, U is int[]
alias abc2 = TAbc!(char, int[]); // (4) error, D is both char and int

template TDef(D : E*, E) { }   // E* is pattern to be matched
alias def = TDef!(int*, int);  // (1) E is int
                               // (3) D is int*

---

    Deduction from a specialization can provide values
        for more than one parameter:

---
template Foo(T: T[U], U)
{
    ...
}

Foo!(int[long])  // instantiates Foo with T set to int, U set to long

---

    When considering matches, a class is
        considered to be a match for any super classes or interfaces:

---
class A { }
class B : A { }

template TFoo(T : A) { }
alias foo = TFoo!(B);      // (3) T is B

template TBar(T : U*, U : A) { }
alias bar = TBar!(B*, B);  // (2) T is B*
                           // (3) U is B

---


$(H3 $(ID template_this_parameter) This Parameters)

$(PRE $(CLASS GRAMMAR)
$(B $(ID TemplateThisParameter) TemplateThisParameter):
    `this` [#TemplateTypeParameter|TemplateTypeParameter]

)

    $(I TemplateThisParameter)s are used in member function templates
        to pick up the type of the $(I this) reference. It also will
        infer the mutability of the `this` reference. For example, if
        `this` is `const`, then the function is marked `const`.

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
struct S
{
    void foo(this T)() const
    {
        pragma(msg, T);
    }
}

void main()
{
    const(S) s;
    (&amp;s).foo();
    S s2;
    s2.foo();
    immutable(S) s3;
    s3.foo();
}

---
        
)

    Prints:

$(CONSOLE const(S)
S
immutable(S)
)

$(H4 $(ID this_rtti) Avoiding Runtime Type Checks)

    <em>TemplateThisParameter</em> is especially useful when used with inheritance. For example,
        consider the implementation of a final base method which returns a derived
        class type. Typically this would return a base type, but that would prohibit
        calling or accessing derived properties of the type:

---
interface Addable(T)
{
    final auto add(T t)
    {
        return this;
    }
}

class List(T) : Addable!T
{
    List remove(T t)
    {
        return this;
    }
}

void main()
{
    auto list = new List!int;
    list.add(1).remove(1);  // error: no 'remove' method for Addable!int
}

---

    Here the method `add` returns the base type, which doesn't implement the
        `remove` method. The template `this` parameter can be used for this purpose:

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
interface Addable(T)
{
    final R add(this R)(T t)
    {
        return cast(R)this;  // cast is necessary, but safe
    }
}

class List(T) : Addable!T
{
    List remove(T t)
    {
        return this;
    }
}

void main()
{
    auto list = new List!int;
    static assert(is(typeof(list.add(1)) == List!int));
    list.add(1).remove(1);  // ok, List.add

    Addable!int a = list;
    // a.add calls Addable.add
    static assert(is(typeof(a.add(1)) == Addable!int));
}

---
        
)

$(H3 $(ID template_value_parameter) Value Parameters)

$(PRE $(CLASS GRAMMAR)
$(B $(ID TemplateValueParameter) TemplateValueParameter):
    [type#BasicType|type, BasicType] [declaration#Declarator|declaration, Declarator]
    [type#BasicType|type, BasicType] [declaration#Declarator|declaration, Declarator] [#TemplateValueParameterSpecialization|TemplateValueParameterSpecialization]
    [type#BasicType|type, BasicType] [declaration#Declarator|declaration, Declarator] [#TemplateValueParameterDefault|TemplateValueParameterDefault]
    [type#BasicType|type, BasicType] [declaration#Declarator|declaration, Declarator] [#TemplateValueParameterSpecialization|TemplateValueParameterSpecialization] [#TemplateValueParameterDefault|TemplateValueParameterDefault]

$(B $(ID TemplateValueParameterSpecialization) TemplateValueParameterSpecialization):
    `:` [expression#ConditionalExpression|expression, ConditionalExpression]

$(B $(ID TemplateValueParameterDefault) TemplateValueParameterDefault):
    `=` AssignExpression
    `=` [expression#SpecialKeyword|expression, SpecialKeyword]

)

    A template value parameter can take an argument of any expression which can
        be statically evaluated at compile time.
        Template value arguments can be integer values, floating point values,
        nulls, string values, array literals of template value arguments,
        associative array literals of template value arguments,
        or struct literals of template value arguments.

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
template foo(string s)
{
    string bar() { return s ~ " betty"; }
}

void main()
{
    import std.stdio;
    writeln(foo!("hello").bar()); // prints: hello betty
}

---
        
)

$(H4 $(ID value_specialization) Specialization)

    Any specialization or default expression provided must be evaluatable
        at compile-time.

    In this example, template `foo` has a value parameter that
        is specialized for `10`:

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
template foo(U : int, int v : 10)
{
    U x = v;
}

void main()
{
    assert(foo!(int, 10).x == 10);
    static assert(!__traits(compiles, foo!(int, 11)));
}

---
        
)

    This can be useful when a different template body is required for a specific value.
        Another template overload would be defined to take other integer literal values.

$(H3 $(ID aliasparameters) Alias Parameters)

$(PRE $(CLASS GRAMMAR)
$(B $(ID TemplateAliasParameter) TemplateAliasParameter):
    `alias` $(LINK2 lex#Identifier, Identifier) [#TemplateAliasParameterSpecialization|TemplateAliasParameterSpecialization]$(SUBSCRIPT opt) [#TemplateAliasParameterDefault|TemplateAliasParameterDefault]$(SUBSCRIPT opt)
    `alias` [type#BasicType|type, BasicType] [declaration#Declarator|declaration, Declarator] [#TemplateAliasParameterSpecialization|TemplateAliasParameterSpecialization]$(SUBSCRIPT opt) [#TemplateAliasParameterDefault|TemplateAliasParameterDefault]$(SUBSCRIPT opt)

$(B $(ID TemplateAliasParameterSpecialization) TemplateAliasParameterSpecialization):
    `:` [type#Type|type, Type]
    `:` [expression#ConditionalExpression|expression, ConditionalExpression]

$(B $(ID TemplateAliasParameterDefault) TemplateAliasParameterDefault):
    `=` [type#Type|type, Type]
    `=` [expression#ConditionalExpression|expression, ConditionalExpression]

)

    Alias parameters enable templates to be parameterized with
        symbol names or values computed at compile-time.
        Almost any kind of D symbol can be used, including type names,
        global names, local names, module names, template names, and
        template instances.
    

$(H4 $(ID alias_symbol) Symbol Aliases)

    $(LIST
        * Type names

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
class Foo
{
    static int x;
}

template Bar(alias a)
{
    alias sym = a.x;
}

void main()
{
    alias bar = Bar!(Foo);
    bar.sym = 3;  // sets Foo.x to 3
    assert(Foo.x == 3);
}

---
        
)
        

        * Global names

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
shared int x;

template Foo(alias var)
{
    auto ptr = &amp;var;
}

void main()
{
    alias bar = Foo!(x);
    *bar.ptr = 3;       // set x to 3
    assert(x == 3);

    static shared int y;
    alias abc = Foo!(y);
    *abc.ptr = 3;       // set y to 3
    assert(y == 3);
}

---
        
)
        

        * Local names
        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
template Foo(alias var)
{
    void inc() { var++; }
}

void main()
{
    int v = 4;
    alias foo = Foo!v;
    foo.inc();
    assert(v == 5);
}

---
        
)
        See also [#implicit-nesting|Implicit Template Nesting].
        

        * Module names

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
import std.conv;

template Foo(alias a)
{
    alias sym = a.text;
}

void main()
{
    alias bar = Foo!(std.conv);
    string s = bar.sym(3);   // calls std.conv.text(3)
    assert(s == "3");
}

---
        
)
        

        * Template names

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
shared int x;

template Foo(alias var)
{
    auto ptr = &amp;var;
}

template Bar(alias Tem)
{
    alias instance = Tem!(x);
}

void main()
{
    alias bar = Bar!(Foo);
    *bar.instance.ptr = 3;  // sets x to 3
    assert(x == 3);
}

---
        
)
        

        * Template instance names

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
shared int x;

template Foo(alias var)
{
    auto ptr = &amp;var;
}

template Bar(alias sym)
{
    alias p = sym.ptr;
}

void main()
{
    alias foo = Foo!(x);
    alias bar = Bar!(foo);
    *bar.p = 3;  // sets x to 3
    assert(x == 3);
}

---
        
)
        
    
)

$(H4 $(ID alias_value) Value Aliases)

    $(LIST

        * Literals

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
template Foo(alias x, alias y)
{
    static int i = x;
    static string s = y;
}

void main()
{
    import std.stdio;
    alias foo = Foo!(3, "bar");
    writeln(foo.i, foo.s);  // prints 3bar
}

---
        
)

        * Compile-time values
        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
template Foo(alias x)
{
    static int i = x;
}

void main()
{
    // compile-time argument evaluation
    enum two = 1 + 1;
    alias foo = Foo!(5 * two);
    assert(foo.i == 10);
    static assert(foo.stringof == "Foo!10");

    // compile-time function evaluation
    int get10() { return 10; }
    alias bar = Foo!(get10());
    // bar is the same template instance as foo
    assert(&amp;bar.i is &amp;foo.i);
}

---
        
)

        * Function Literals
        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
template Foo(alias fun)
{
    enum val = fun(2);
}

alias foo = Foo!((int x) =&gt; x * x);
static assert(foo.val == 4);

---
        
)
    
)

$(H4 $(ID typed_alias_op) Typed Alias Parameters)

    Alias parameters can also be typed.
        These parameters will accept symbols of that type:

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
template Foo(alias int p) { alias a = p; }

void fun()
{
    int i = 0;
    Foo!i.a++;  // ok
    assert(i == 1);

    float f;
    //Foo!f;  // fails to instantiate
}

---
        
)

$(H4 $(ID alias_parameter_specialization) Specialization)

    Alias parameters can accept both literals and user-defined type symbols,
        but they are less specialized than the matches to type parameters and
        value parameters:

---
template Foo(T)         { ... }  // #1
template Foo(int n)     { ... }  // #2
template Foo(alias sym) { ... }  // #3

struct S {}
int var;

alias foo1  = Foo!(S);      // instantiates #1
alias foo2  = Foo!(1);      // instantiates #2
alias foo3a = Foo!([1,2]);  // instantiates #3
alias foo3b = Foo!(var);    // instantiates #3

---

---
template Bar(alias A) { ... }                 // #4
template Bar(T : U!V, alias U, V...) { ... }  // #5

class C(T) {}
alias bar = Bar!(C!int);    // instantiates #5

---

$(H3 $(ID variadic-templates) Sequence Parameters)

$(PRE $(CLASS GRAMMAR)
$(B $(ID TemplateSequenceParameter) TemplateSequenceParameter):
    $(LINK2 lex#Identifier, Identifier) `...`

)

    If the last template parameter in the $(I TemplateParameterList)
        is declared as a $(I TemplateSequenceParameter),
        it is a match with zero or more trailing template arguments.
        Any argument that can be passed to a [#TemplateAliasParameter|TemplateAliasParameter]
        can be passed to a sequence parameter.
    
    Such a sequence of arguments can itself be aliased for use outside
        a template. The $(REF AliasSeq, std,meta) template simply
        aliases its sequence parameter:
---
alias AliasSeq(Args...) = Args;

---
    A <em>TemplateSequenceParameter</em> will thus henceforth
        be referred to by that name for clarity.
        An $(I AliasSeq) is not itself a type, value, or symbol. It is a
        $(LINK2 articles/ctarguments, Compile-time Sequences)
        of any mix of types, values or symbols, or none.
    

    The elements of an $(I AliasSeq) are automatically expanded
        when it is referenced in a declaration or expression.
        An $(I AliasSeq) can be
        $(LINK2 articles/ctarguments#auto-expansion,used as arguments)
        to instantiate a template.
    

$(H4 $(ID homogeneous_sequences) Homogeneous Sequences)

    $(LIST
    * An $(I AliasSeq) whose elements consist entirely of types is
        called a type sequence or $(I TypeSeq).
    * An $(I AliasSeq) whose elements consist entirely of values is
        called a value sequence or $(I ValueSeq).
    * `typeof` can be used on a <em>ValueSeq</em> to obtain a <em>TypeSeq</em>.
    
)

    A <em>ValueSeq</em> can be used as arguments to call a
        function:

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
import std.stdio : writeln;

template print(args...) // args must be a ValueSeq
{
    void print()
    {
        writeln("args are ", args);
    }
}

void main()
{
    print!(1, 'a', 6.8)(); // prints: args are 1a6.8
}

---
        
)

        A <em>TypeSeq</em> can be used to declare parameters for a function:

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
import std.stdio : writeln;

template print(Types...) // Types must be a TypeSeq
{
    void print(Types args) // args is a ValueSeq
    {
        writeln("args are ", args);
    }
}

void main()
{
    print!(int, char, double)(1, 'a', 6.8); // prints: args are 1a6.8
}

---
        
)

    Note: A value sequence cannot be returned from a function - instead, return a
        $(REF Tuple, std,typecons).

$(H4 $(ID lvalue-sequences) Lvalue Sequences)

    A <em>TypeSeq</em> can similarly be used to
        $(LINK2 articles/ctarguments#type-seq-instantiation,declare variables).
        Parameters or variables whose type is a <em>TypeSeq</em> are called an
        <em>lvalue sequence</em>.

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
void main()
{
    import std.meta: AliasSeq;

    // use a type alias just for convenience
    alias TS = AliasSeq!(string, int);
    TS tup; // lvalue sequence
    assert(tup == AliasSeq!("", 0)); // TS.init

    int i = 5;
    // initialize another lvalue sequence from a sequence of a value and a symbol
    auto tup2 = AliasSeq!("hi", i); // value of i is copied
    i++;
    enum hi5 = AliasSeq!("hi", 5); // rvalue sequence
    static assert(is(typeof(hi5) == TS));
    assert(tup2 == hi5);

    // lvalue sequence elements can be modified
    tup = tup2;
    assert(tup == hi5);
}

---
        
)

    $(LIST
        * `.tupleof` can be $(LINK2 spec/class#class_properties,used on a class)
            or struct instance to obtain an lvalue sequence of its fields.
        * `.tupleof` can be $(LINK2 spec/arrays#array-properties,used on a static array)
            instance to obtain an lvalue sequence of its elements.
    
)

$(H4 $(ID seq-ops) Sequence Operations)

    $(LIST
    * The number of elements in an $(I AliasSeq) can be retrieved with
        the `.length` property.
    * The $(I n)th element can be retrieved by
        $(LINK2 spec/expression#index_operations,indexing) an
        $(I AliasSeq) with `Seq[n]`. Indexes must be known at compile-time.
        The result is an lvalue when the element is a symbol which resolves to a variable,
        or when the sequence is an lvalue sequence.
    * $(LINK2 spec/expression#slice_operations,Slicing)
        produces a new sequence with a subset of the elements of the original sequence.
    
)

    $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
import std.meta : AliasSeq;

int v = 4;
// alias a sequence of 3 values and one symbol
alias nums = AliasSeq!(1, 2, 3, v);
static assert(nums.length == 4);
static assert(nums[1] == 2);

//nums[0]++; // Error, nums[0] is an rvalue
nums[3]++; // OK, nums[3] is bound to v, an lvalue
assert(v == 5);

// slice first 3 elements
alias trio = nums[0 .. $-1];
// expand into an array literal
static assert([trio] == [1, 2, 3]);

---
    
)

    $(I AliasSeq)s are static compile-time entities, there is no way
        to dynamically change, add, or remove elements either at compile-time or run-time.
        Instead, either:
    $(LIST
    * Construct a new sequence using the original sequence (or a slice of it) and additional elements before or after it.
    * Use $(LINK2 spec/declaration#AliasAssign,Alias Assignment)
        to build new sequences iteratively.
    
)
    Sequences can 'unroll' code for each element using a
        $(LINK2 spec/statement#foreach_over_tuples,`foreach` statement).

$(H4 $(ID typeseq_deduction) Type Sequence Deduction)

    Type sequences can be deduced from the trailing parameters
        of an [#ifti|implicitly instantiated] function template:

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
import std.stdio;

template print(T, Args...)
{
    void print(T first, Args args)
    {
        writeln(first);
        static if (args.length) // if more arguments
            print(args);        // recurse for remaining arguments
    }
}

void main()
{
    print(1, 'a', 6.8);
}

---
        
)

    prints:

$(CONSOLE 1
a
6.8
)

    Type sequences can also be deduced from the type of a delegate
        or function parameter list passed as a function argument:

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
import std.stdio;

/* Partially applies a delegate by tying its first argument to a particular value.
 * R = return type
 * T = first argument type
 * Args = TypeSeq of remaining argument types
 */
R delegate(Args) partial(R, T, Args...)(R delegate(T, Args) dg, T first)
{
    // return a closure
    return (Args args) =&gt; dg(first, args);
}

void main()
{
    int plus(int x, int y, int z)
    {
        return x + y + z;
    }

    import std.stdio;
    auto plus_two = partial(&amp;plus, 2);
    writeln(plus_two(6, 8)); // prints 16
}

---
        
)
        See also: $(REF partial, std,functional)

$(H4 $(ID variadic_template_specialization) Specialization)

    If both a template with a sequence parameter and a template
        without a sequence parameter exactly match a template instantiation,
        the template without a $(I TemplateSequenceParameter) is selected.

---
template Foo(T)         { pragma(msg, "1"); }   // #1
template Foo(int n)     { pragma(msg, "2"); }   // #2
template Foo(alias sym) { pragma(msg, "3"); }   // #3
template Foo(Args...)   { pragma(msg, "4"); }   // #4

import std.stdio;

// Any sole template argument will never match to #4
alias foo1 = Foo!(int);          // instantiates #1
alias foo2 = Foo!(3);            // instantiates #2
alias foo3 = Foo!(std);          // instantiates #3

alias foo4 = Foo!(int, 3, std);  // instantiates #4

---

$(H3 $(ID template_parameter_def_values) Default Arguments)

    Trailing template parameters can be given default arguments:

---
template Foo(T, U = int) { ... }
Foo!(uint,long); // instantiate Foo with T as uint, and U as long
Foo!(uint);      // instantiate Foo with T as uint, and U as int

template Foo(T, U = T*) { ... }
Foo!(uint);      // instantiate Foo with T as uint, and U as uint*

---

    See also: [#function-default|Function Template Default Arguments].

$(H2 $(ID implicit_template_properties) Eponymous Templates)

    If a template contains members whose name is the same as the
        template identifier then these members are assumed to be referred
        to in a template instantiation:

---
template foo(T)
{
    T foo; // declare variable foo of type T
}

void main()
{
    foo!(int) = 6; // instead of foo!(int).foo
}

---

        The following example has more than one eponymous member and uses
        [#ifti|Implicit Function Template Instantiation]:

---
template foo(S, T)
{
    // each member contains all the template parameters
    void foo(S s, T t) {}
    void foo(S s, T t, string) {}
}

void main()
{
    foo(1, 2, "test"); // foo!(int, int).foo(1, 2, "test")
    foo(1, 2); // foo!(int, int).foo(1, 2)
}

---

$(H2 $(ID aggregate_templates) Aggregate Type Templates)

$(PRE $(CLASS GRAMMAR)
$(B $(ID ClassTemplateDeclaration) ClassTemplateDeclaration):
    `class` $(LINK2 lex#Identifier, Identifier) [#TemplateParameters|TemplateParameters] `;`
    `class` $(LINK2 lex#Identifier, Identifier) [#TemplateParameters|TemplateParameters] [#Constraint|Constraint]$(SUBSCRIPT opt) [class#BaseClassList|class, BaseClassList]$(SUBSCRIPT opt) [struct#AggregateBody|struct, AggregateBody]
    `class` $(LINK2 lex#Identifier, Identifier) [#TemplateParameters|TemplateParameters] [class#BaseClassList|class, BaseClassList]$(SUBSCRIPT opt) [#Constraint|Constraint]$(SUBSCRIPT opt) [struct#AggregateBody|struct, AggregateBody]

$(B $(ID InterfaceTemplateDeclaration) InterfaceTemplateDeclaration):
    `interface` $(LINK2 lex#Identifier, Identifier) [#TemplateParameters|TemplateParameters] `;`
    `interface` $(LINK2 lex#Identifier, Identifier) [#TemplateParameters|TemplateParameters] [#Constraint|Constraint]$(SUBSCRIPT opt) [interface#BaseInterfaceList|interface, BaseInterfaceList]$(SUBSCRIPT opt) [struct#AggregateBody|struct, AggregateBody]
    `interface` $(LINK2 lex#Identifier, Identifier) [#TemplateParameters|TemplateParameters] [interface#BaseInterfaceList|interface, BaseInterfaceList] [#Constraint|Constraint] [struct#AggregateBody|struct, AggregateBody]

$(B $(ID StructTemplateDeclaration) StructTemplateDeclaration):
    `struct` $(LINK2 lex#Identifier, Identifier) [#TemplateParameters|TemplateParameters] `;`
    `struct` $(LINK2 lex#Identifier, Identifier) [#TemplateParameters|TemplateParameters] [#Constraint|Constraint]$(SUBSCRIPT opt) [struct#AggregateBody|struct, AggregateBody]

$(B $(ID UnionTemplateDeclaration) UnionTemplateDeclaration):
    `union` $(LINK2 lex#Identifier, Identifier) [#TemplateParameters|TemplateParameters] `;`
    `union` $(LINK2 lex#Identifier, Identifier) [#TemplateParameters|TemplateParameters] [#Constraint|Constraint]$(SUBSCRIPT opt) [struct#AggregateBody|struct, AggregateBody]

)

    If a template declares exactly one member, and that member is a class
        with the same name as the template (see
        [#implicit_template_properties|Eponymous Templates]:)

---
template /* adrdox_highlight{ */Bar/* }adrdox_highlight */(T)
{
    class /* adrdox_highlight{ */Bar/* }adrdox_highlight */
    {
        T member;
    }
}

---

        then the semantic equivalent, called a $(I ClassTemplateDeclaration)
        can be written as:

---
class Bar(T)
{
    T member;
}

---

    See also: [#template_this_parameter|This Parameters].
    

    Analogously to class templates, struct, union and interfaces
        can be transformed into templates by supplying a template parameter list.
    

$(H2 $(ID function-templates) Function Templates)

    If a template declares exactly one member, and that member is a function
        with the same name as the template, it is a function template declaration.
        Alternatively, a function template declaration is a function declaration
        with a [#TemplateParameterList|TemplateParameterList] immediately preceding the
        [function#Parameters|function, Parameters].
    

    A function template to compute the square of type $(I T) is:

---
T /* adrdox_highlight{ */square/* }adrdox_highlight */(T)(T t)
{
    return t * t;
}

---

    It is lowered to:

---
template /* adrdox_highlight{ */square/* }adrdox_highlight */(T)
{
    T /* adrdox_highlight{ */square/* }adrdox_highlight */(T t)
    {
        return t * t;
    }
}

---

    Function templates can be explicitly instantiated with
        <em>Identifier</em>`!(`<em>TemplateArgumentList</em>`)`:

---
writefln("The square of %s is %s", 3, square!(int)(3));

---

$(H3 $(ID ifti) Implicit Function Template Instantiation (IFTI))

    Function templates can be $(I implicitly) instantiated if the
        $(I TemplateArgumentList) is deducible from the types of the
        function arguments:

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
T square(T)(T t)
{
    return t * t;
}

writefln("The square of %s is %s", 3, square(3));  // T is deduced to be int

---
        
)

    Type parameter deduction is not influenced by the order of function
        arguments.
    

    If there are fewer arguments supplied in the $(I TemplateArgumentList)
        than parameters in the $(I TemplateParameterList), the arguments fill
        parameters from left to right, and the rest of the parameters are then deduced
        from the function arguments.
    

$(H4 $(ID ifti-restrictions) Restrictions)

    Function template type parameters that are to be implicitly
        deduced must appear in the type of at least one function parameter:

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
void foo(T : U*, U)(U t) {}

void main()
{
    int x;
    foo!(int*)(x);   // ok, U is deduced and T is specified explicitly
    //foo(x);        // error, only U can be deduced, not T
}

---
        
)

        When the template parameters must be deduced, the
        [#implicit_template_properties|eponymous members]
        can't rely on a $(LINK2 version.html#StaticIfCondition, `static if`)
        condition since the deduction relies on how the members are used:

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
template foo(T)
{
    static if (is(T)) // T is not yet known...
        void foo(T t) {} // T is deduced from the member usage
}

void main()
{
    //foo(0); // Error: cannot deduce function from argument types
    foo!int(0); // Ok since no deduction necessary
}

---
        
)

        IFTI does not work when the parameter type is an
        [#alias-template|alias template] instance:
        

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
struct S(T) {}
alias A(T) = S!T;
void f(T)(A!T) {}

void main()
{
    A!int v;
    //f(v); // error
    f!int(v); // OK
}

---
        
)

$(H4 $(ID ifti-conversions) Type Conversions)

    If template type parameters match the literal expressions on function arguments,
        the deduced types may consider narrowing conversions of them.
    

    $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
void foo(T)(T v)        { pragma(msg, "in foo, T = ", T); }
void bar(T)(T v, T[] a) { pragma(msg, "in bar, T = ", T); }

void main()
{
    foo(1);
    // an integer literal type is analyzed as int by default
    // then T is deduced to int

    short[] arr;
    bar(1, arr);
    // arr is short[], and the integer literal 1 is
    // implicitly convertible to short.
    // then T will be deduced to short.

    bar(1, [2.0, 3.0]);
    // the array literal is analyzed as double[],
    // and the integer literal 1 is implicitly convertible to double.
    // then T will be deduced to double.
}

---
    
)

    The deduced type parameter for dynamic array and pointer arguments
        has an unqualified head:

    $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
void foo(T)(T arg) { pragma(msg, T); }

void test()
{
    int[] marr;
    const(int[]) carr;
    immutable(int[]) iarr;
    foo(marr);  // T == int[]
    foo(carr);  // T == const(int)[]
    foo(iarr);  // T == immutable(int)[]

    int* mptr;
    const(int*) cptr;
    immutable(int*) iptr;
    foo(mptr);  // T == int*
    foo(cptr);  // T == const(int)*
    foo(iptr);  // T == immutable(int)*
}

---
    
)

$(H3 $(ID return-deduction) Return Type Deduction)

    Function templates can have their return types deduced based on the
        [statement#ReturnStatement|statement, ReturnStatement]s in the function, just as with
        normal functions.
        See $(LINK2 spec/function#auto-functions,Auto Functions).
    

    $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
auto square(T)(T t)
{
    return t * t;
}

auto i = square(2);
static assert(is(typeof(i) == int));

---
    
)

$(H3 $(ID auto-ref-parameters) Auto Ref Parameters)

    Template functions can have auto ref parameters.
        An auto ref parameter becomes a ref parameter
        if its corresponding argument is an lvalue, otherwise it becomes
        a value parameter:

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
int countRefs(Args...)(auto ref Args args)
{
    int result;

    foreach (i, _; args)
    {
        if (__traits(isRef, args[i]))
            result++;
    }
    return result;
}

void main()
{
    int y;
    assert(countRefs(3, 4) == 0);
    assert(countRefs(3, y, 4) == 1);
    assert(countRefs(y, 6, y) == 2);
}

---
        
)

    Auto ref parameters can be combined with auto ref return
        attributes:

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
auto ref min(T, U)(auto ref T lhs, auto ref U rhs)
{
    return lhs &gt; rhs ? rhs : lhs;
}

void main()
{
    int i;
    i = min(4, 3);
    assert(i == 3);

    int x = 7, y = 8;
    i = min(x, y);
    assert(i == 7);
    // result is an lvalue
    min(x, y) = 10;    // sets x to 10
    assert(x == 10 &amp;&amp; y == 8);

    static assert(!__traits(compiles, min(3, y) = 10));
    static assert(!__traits(compiles, min(y, 3) = 10));
}

---
        
)

$(H3 $(ID function-default) Default Arguments)

    Template arguments not implicitly deduced can have default values:

---
void /* adrdox_highlight{ */foo/* }adrdox_highlight */(T, U=T*)(T t) { U p; ... }

int x;
foo(x);    // T is int, U is int*

---

    Variadic Function Templates can have parameters with default values.
        These parameters are always set to their default value in case of IFTI.
    

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
size_t fun(T...)(T t, string file = __FILE__)
{
    import std.stdio;
    writeln(file, " ", t);
    return T.length;
}

assert(fun(1, "foo") == 2);  // uses IFTI
assert(fun!int(1, "filename") == 1);  // no IFTI

---
        
)

$(H2 $(ID template_ctors) Template Constructors)

$(PRE $(CLASS GRAMMAR)
$(B $(ID ConstructorTemplate) ConstructorTemplate):
    `this` [#TemplateParameters|TemplateParameters] [function#Parameters|function, Parameters] [function#MemberFunctionAttributes|function, MemberFunctionAttributes]$(SUBSCRIPT opt) [#Constraint|Constraint]$(SUBSCRIPT opt) [function#FunctionBody|function, FunctionBody]

)

    Templates can be used to form constructors for classes and structs.
    

$(H2 $(ID variable-template) Enum &amp; Variable Templates)

    Like aggregates and functions, $(LINK2 spec/declaration#variable-declarations,variable
        declarations) and manifest constants can have template parameters, providing there is
        an [declaration#Initializer|declaration, Initializer]:

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
enum bool within(alias v, T) = v &lt;= T.max &amp;&amp; v &gt;= T.min;
ubyte[T.sizeof] storage(T) = 0;
const triplet(alias v) = [v, v+1, v+2];

static assert(within!(-128F, byte));
static assert(storage!(int[2]).length == 8);
static assert(triplet!3 == [3, 4, 5]);

---
        
)

    Those declarations are transformed into these <em>TemplateDeclaration</em>s:

---
template within(alias v, T)
{
    enum bool within = v &lt;= T.max &amp;&amp; v &gt;= T.min;
}
template storage(T)
{
    ubyte[T.sizeof] storage = 0;
}
template triplet(alias v)
{
    const triplet = [v, v+1, v+2];
}

---

$(H2 $(ID alias-template) Alias Templates)

    [declaration#AliasDeclaration|declaration, AliasDeclaration] can also have optional template
        parameters:

---
alias ElementType(T : T[]) = T;
alias Sequence(TL...) = TL;

---

    It is lowered to:

---
template ElementType(T : T[])
{
    alias ElementType = T;
}
template Sequence(TL...)
{
    alias Sequence = TL;
}

---

$(H2 $(ID nested-templates) Nested Templates)

    If a template is declared in aggregate or function local scope, the
        instantiated functions will implicitly capture the context of the
        enclosing scope.

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
class C
{
    int num;

    this(int n) { num = n; }

    template Foo()
    {
        // 'foo' can access 'this' reference of class C object.
        void foo(int n) { this.num = n; }
    }
}

void main()
{
    auto c = new C(1);
    assert(c.num == 1);

    c.Foo!().foo(5);
    assert(c.num == 5);

    template Bar()
    {
        // 'bar' can access local variable of 'main' function.
        void bar(int n) { c.num = n; }
    }
    Bar!().bar(10);
    assert(c.num == 10);
}

---
        
)

    Above, `Foo!().foo` will work just the same as a `final` member function
        of class `C`, and `Bar!().bar` will work just the same as a nested
        function within function `main()`.

$(H3 $(ID limitations) Aggregate Type Limitations)

    A nested template cannot add non-static fields to an aggregate type.
        Fields declared in a nested template will be implicitly `static`.
    A nested template cannot add virtual functions to a class or interface.
        Methods inside a nested template will be implicitly `final`.

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
class Foo
{
    template TBar(T)
    {
        T xx;           // becomes a static field of Foo
        void func(T) {} // implicitly final
        //abstract void baz(); // error, final functions cannot be abstract

        static T yy;                    // Ok
        static void func(T t, int y) {} // Ok
    }
}

void main()
{
    alias bar = Foo.TBar!int;
    bar.xx++;
    //bar.func(1); // error, no this

    auto o = new Foo;
    o.TBar!int.func(1); // OK
}

---
        
)

$(H3 $(ID implicit-nesting) Implicit Nesting)

    If a template has a [#aliasparameters|template alias parameter],
        and is instantiated with a local symbol, the instantiated function will
        implicitly become nested in order to access runtime data of the given
        local symbol.

---
template Foo(alias sym)
{
    void foo() { sym = 10; }
}

class C
{
    int num;

    this(int n) { num = n; }

    void main()
    {
        assert(this.num == 1);

        alias fooX = Foo!(C.num).foo;

        // fooX will become member function implicitly, so &amp;fooX
        //     returns a delegate object.
        static assert(is(typeof(&amp;fooX) == delegate));

        fooX(); // called by using valid 'this' reference.
        assert(this.num == 10);  // OK
    }
}

void main()
{
    new C(1).main();

    int num;
    alias fooX = Foo!num.foo;

    // fooX will become nested function implicitly, so &amp;fooX
    //     returns a delegate object.
    static assert(is(typeof(&amp;fooX) == delegate));

    fooX();
    assert(num == 10);  // OK
}

---

    Not only functions, but also instantiated class and struct types can
        become nested via implicitly captured context.

---
class C
{
    int num;
    this(int n) { num = n; }

    class N(T)
    {
        // instantiated class N!T can become nested in C
        T foo() { return num * 2; }
    }
}

void main()
{
    auto c = new C(10);
    auto n = c.new N!int();
    assert(n.foo() == 20);
}

---

    See also: $(LINK2 spec/class#nested-explicit,Nested Class Instantiation).

---
void main()
{
    int num = 10;
    struct S(T)
    {
        // instantiated struct S!T can become nested in main()
        T foo() { return num * 2; }
    }
    S!int s;
    assert(s.foo() == 20);
}

---

    A templated `struct` can become a nested `struct` if it
        is instantiated with a local symbol passed as an aliased argument:

---
struct A(alias F)
{
    int fun(int i) { return F(i); }
}

A!F makeA(alias F)() { return A!F(); }

void main()
{
    int x = 40;
    int fun(int i) { return x + i; }
    A!fun a = makeA!fun();
    assert(a.fun(2) == 42);
}

---

    $(H3 $(ID nested_template_limitation) Context Limitation)

    Currently nested templates can capture at most one context. As a typical
        example, non-static template member functions cannot take local symbol
        by using template alias parameter.

---
class C
{
    int num;
    void foo(alias sym)() { num = sym * 2; }
}

void main()
{
    auto c = new C();
    int var = 10;
    c.foo!var();    // NG, foo!var requires two contexts, 'this' and 'main()'
}

---

    But, if one context is indirectly accessible from other context, it is allowed.

---
int sum(alias x, alias y)() { return x + y; }

void main()
{
    int a = 10;
    void nested()
    {
        int b = 20;
        assert(sum!(a, b)() == 30);
    }
    nested();
}

---

        Two local variables `a` and `b` are in different contexts, but
        outer context is indirectly accessible from innter context, so nested
        template instance `sum!(a, b)` will capture only
        inner context.

$(H2 $(ID recursive_templates) Recursive Templates)

    Template features can be combined to produce some interesting
        effects, such as compile time evaluation of non-trivial functions.
        For example, a factorial template can be written:

    $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
template factorial(int n)
{
    static if (n == 1)
        enum factorial = 1;
    else
        enum factorial = n * factorial!(n - 1);
}

static assert(factorial!(4) == 24);

---
    
)
    For more information and a CTFE (Compile-time Function Execution)
        factorial alternative, see:
        $(LINK2 articles/templates-revisited#template-recursion,Template Recursion).
    

$(H2 $(ID template_constraints) Template Constraints)

$(PRE $(CLASS GRAMMAR)
$(B $(ID Constraint) Constraint):
    `if` `(` [expression#Expression|expression, Expression] `)`

)

    $(I Constraint)s are used to impose additional constraints
        on matching arguments to a template beyond what is possible
        in the [#TemplateParameterList|TemplateParameterList].
        The $(I Expression) is computed at compile time
        and returns a result that is converted to a boolean value.
        If that value is true, then the template is matched,
        otherwise the template is not matched.
    

    For example, the following function template only
        matches with odd values of `N`:

---
void foo(int N)()
    if (N &amp; 1)
{
    ...
}
...
foo!(3)();  // OK, matches
foo!(4)();  // Error, no match

---

    Template constraints can be used with aggregate types (structs, classes, unions).
        Constraints are effectively used with library module [std.traits]:

---
import std.traits;

struct Bar(T)
    if (isIntegral!T)
{
    ...
}
...
auto x = Bar!int;       // OK, int is an integral type
auto y = Bar!double;    // Error, double does not satisfy constraint

---

operatoroverloading, Operator Overloading, template-mixin, Template Mixins




Link_References:
	ACC = Associated C Compiler
+/
module template.dd;