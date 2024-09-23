// just docs: Statements
/++





    The order of execution within a function is controlled by [#Statement|Statement]s.
    A function's body consists of a sequence of zero or more $(I Statement)s.
    Execution occurs in lexical order, though certain statements may have deferred effects.
    A $(I Statement) has no value; it is executed for its effects.
    

$(PRE $(CLASS GRAMMAR)
$(B $(ID Statement) Statement):
    [#EmptyStatement|EmptyStatement]
    [#NonEmptyStatement|NonEmptyStatement]
    [#ScopeBlockStatement|ScopeBlockStatement]

$(B $(ID EmptyStatement) EmptyStatement):
    `;`

$(B $(ID NoScopeNonEmptyStatement) NoScopeNonEmptyStatement):
    [#NonEmptyStatement|NonEmptyStatement]
    [#BlockStatement|BlockStatement]

$(B $(ID NoScopeStatement) NoScopeStatement):
    [#EmptyStatement|EmptyStatement]
    [#NonEmptyStatement|NonEmptyStatement]
    [#BlockStatement|BlockStatement]

$(B $(ID NonEmptyOrScopeBlockStatement) NonEmptyOrScopeBlockStatement):
    [#NonEmptyStatement|NonEmptyStatement]
    [#ScopeBlockStatement|ScopeBlockStatement]

$(B $(ID NonEmptyStatement) NonEmptyStatement):
    [#NonEmptyStatementNoCaseNoDefault|NonEmptyStatementNoCaseNoDefault]
    [#CaseStatement|CaseStatement]
    [#CaseRangeStatement|CaseRangeStatement]
    [#DefaultStatement|DefaultStatement]

$(B $(ID NonEmptyStatementNoCaseNoDefault) NonEmptyStatementNoCaseNoDefault):
    [#LabeledStatement|LabeledStatement]
    [#ExpressionStatement|ExpressionStatement]
    [#DeclarationStatement|DeclarationStatement]
    [#IfStatement|IfStatement]
    [#WhileStatement|WhileStatement]
    [#DoStatement|DoStatement]
    [#ForStatement|ForStatement]
    [#ForeachStatement|ForeachStatement]
    [#SwitchStatement|SwitchStatement]
    [#FinalSwitchStatement|FinalSwitchStatement]
    [#ContinueStatement|ContinueStatement]
    [#BreakStatement|BreakStatement]
    [#ReturnStatement|ReturnStatement]
    [#GotoStatement|GotoStatement]
    [#WithStatement|WithStatement]
    [#SynchronizedStatement|SynchronizedStatement]
    [#TryStatement|TryStatement]
    [#ScopeGuardStatement|ScopeGuardStatement]
    [#AsmStatement|AsmStatement]
    [#MixinStatement|MixinStatement]
    [#ForeachRangeStatement|ForeachRangeStatement]
    [pragma#PragmaStatement|pragma, PragmaStatement]
    [version#ConditionalStatement|version, ConditionalStatement]
    [version#StaticForeachStatement|version, StaticForeachStatement]
    [module#ImportDeclaration|module, ImportDeclaration]

)

        Any ambiguities in the grammar between $(I Statement)s and
        [declaration#Declaration|declaration, Declaration]s are
        resolved by the declarations taking precedence.
        Wrapping such a statement in parentheses will
        disambiguate it in favor of being a $(I Statement).
        

$(H2 $(ID scope-statement)Scope Statements)

$(PRE $(CLASS GRAMMAR)
$(B $(ID ScopeStatement) ScopeStatement):
    [#NonEmptyStatement|NonEmptyStatement]
    [#BlockStatement|BlockStatement]

)

        A new scope for local symbols
        is introduced for the $(I NonEmptyStatement)
        or [#BlockStatement|BlockStatement].
        

        Even though a new scope is introduced,
        local symbol declarations cannot shadow (hide) other
        local symbol declarations in the same function.
        

---
void func1(int x)
{
    int x;    // illegal, x shadows parameter x

    int y;

    { int y; } // illegal, y shadows enclosing scope's y

    void delegate() dg;
    dg = { int y; }; // ok, this y is not in the same function

    struct S
    {
        int y;    // ok, this y is a member, not a local
    }

    { int z; }
    { int z; }  // ok, this z is not shadowing the other z

    { int t; }
    { t++;   }  // illegal, t is undefined
}

---

    $(TIP Local declarations within a function should
    all have unique names, even if they are in non-overlapping scopes.
    )


$(H2 $(ID scope-block-statement)Scope Block Statements)

$(PRE $(CLASS GRAMMAR)
$(B $(ID ScopeBlockStatement) ScopeBlockStatement):
    [#BlockStatement|BlockStatement]

)

        A scope block statement introduces a new scope for the
        [#BlockStatement|BlockStatement].
        

$(H2 $(ID labeled-statement)Labeled Statements)

    Statements can be labeled. A label is an identifier that
        precedes a statement.


$(PRE $(CLASS GRAMMAR)
$(B $(ID LabeledStatement) LabeledStatement):
    $(LINK2 lex#Identifier, Identifier) `:`
    $(LINK2 lex#Identifier, Identifier) `:` [#Statement|Statement]

)

        Any statement can be labeled, including empty statements,
        and so can serve as the target of a [#goto-statement|goto statement].
        Labeled statements can also serve as the
        target of a [#break-statement|break] or
        [#continue-statement|continue] statement.

        A label can appear without a following statement at the end of
        a block.

        Labels are in a name space independent of declarations, variables,
        types, etc.
        Even so, labels cannot have the same name as local declarations.
        The label name space is the body of the function
        they appear in. Label name spaces do not nest, i.e. a label
        inside a block statement is accessible from outside that block.


    Labels in one function cannot be referenced from another function.


$(H2 $(ID block-statement)Block Statement)

$(PRE $(CLASS GRAMMAR)
$(B $(ID BlockStatement) BlockStatement):
    `{ }`
    `{` [#StatementList|StatementList] `}`

$(B $(ID StatementList) StatementList):
    [#Statement|Statement]
    [#Statement|Statement] StatementList

)

    A block statement is a sequence of statements enclosed by `{ }`.
    The statements are executed in lexical order,
    until the end of the block is reached or
    a statement transfers control elsewhere.
    


$(H2 $(ID expression-statement)Expression Statement)

$(PRE $(CLASS GRAMMAR)
$(B $(ID ExpressionStatement) ExpressionStatement):
    [expression#Expression|expression, Expression] `;`

)

        The expression is evaluated.

        Expressions that have no effect, like `(x + x)`,
        are illegal as expression statements unless they are cast
        to void.

---
int x;
x++;               // ok
x;                 // illegal
1+1;               // illegal
cast(void)(x + x); // ok

---


$(H2 $(ID declaration-statement)Declaration Statement)

    Declaration statements define variables,
    and declare types, templates, functions, imports,
    conditionals, static foreaches, and static asserts.
    

$(PRE $(CLASS GRAMMAR)
$(B $(ID DeclarationStatement) DeclarationStatement):
    [declaration#StorageClasses|declaration, StorageClasses]$(SUBSCRIPT opt) [declaration#Declaration|declaration, Declaration]

)

        Some declaration statements:

---
int a;        // declare a as type int and initialize it to 0
struct S { }  // declare struct s
alias myint = int;

---

$(H2 $(ID if-statement)If Statement)

If statements provide simple conditional execution of statements.

$(PRE $(CLASS GRAMMAR)
$(B $(ID IfStatement) IfStatement):
    `if (` [#IfCondition|IfCondition] `)` [#ThenStatement|ThenStatement]
    `if (` [#IfCondition|IfCondition] `)` [#ThenStatement|ThenStatement] `else` [#ElseStatement|ElseStatement]

$(B $(ID IfCondition) IfCondition):
    [expression#Expression|expression, Expression]
    `auto` $(LINK2 lex#Identifier, Identifier) `=` [expression#Expression|expression, Expression]
    `scope` $(LINK2 lex#Identifier, Identifier) `=` [expression#Expression|expression, Expression]
    [type#TypeCtors|type, TypeCtors] $(LINK2 lex#Identifier, Identifier) `=` [expression#Expression|expression, Expression]
    [type#TypeCtors|type, TypeCtors]$(SUBSCRIPT opt) [type#BasicType|type, BasicType] [declaration#Declarator|declaration, Declarator] `=` [expression#Expression|expression, Expression]

$(B $(ID ThenStatement) ThenStatement):
    [#ScopeStatement|ScopeStatement]

$(B $(ID ElseStatement) ElseStatement):
    [#ScopeStatement|ScopeStatement]

)

        If there is a declared <em>Identifier</em> variable, it is evaluated.
        Otherwise, <em>Expression</em> is evaluated. The result is converted to a
        boolean, using $(LINK2 spec/operatoroverloading#cast,`opCast!bool()`)
        if the method is defined.
        If the boolean is `true`, the $(I ThenStatement) is transferred
        to, otherwise the $(I ElseStatement) is transferred to.

        The $(I ElseStatement) is associated with the innermost `if`
        statement which does not already have an associated $(I ElseStatement).

    $(NOTE         When an $(I Identifier) form of <em>IfCondition</em> is used, a
        variable is declared with that name and initialized to the
        value of the <em>Expression</em>.

$(LIST
* If `auto` $(I Identifier) is provided, the type of the variable
          is the same as <em>Expression</em>.

* If $(I TypeCtors) $(I Identifier) is provided, the variable is
          declared to be the type of <em>Expression</em> but with $(I TypeCtors) applied.

* If the $(I BasicType) form is provided, it declares the type of the
          variable as it would for a normal
          $(LINK2 spec/declaration#variable-declarations,variable declaration).


)
        The scope of the variable is the <em>ThenStatement</em> only.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
import std.regex;

if (auto m = matchFirst("abcdef", "b(c)d"))
{
    writefln("[%s]", m.pre);    // prints [a]
    writefln("[%s]", m.post);   // prints [ef]
    writefln("[%s]", m[0]);     // prints [bcd]
    writefln("[%s]", m[1]);     // prints [c]
}
else
{
    writeln("no match");
    //writeln(m.post); // Error: undefined identifier 'm'
}
//writeln(m.pre);      // Error: undefined identifier 'm'

---

)
    )

$(H2 $(ID while-statement)While Statement)

$(PRE $(CLASS GRAMMAR)
$(B $(ID WhileStatement) WhileStatement):
    `while (` [#IfCondition|IfCondition] `)` [#ScopeStatement|ScopeStatement]

)

A $(I While Statement) implements a simple loop.

If the $(I IfCondition) is an <em>Expression</em>, it is evaluated and must have a type
that can be converted to a boolean. If it's `true` the <em>ScopeStatement</em> is executed.
After the <em>ScopeStatement</em> is executed, the <em>Expression</em> is evaluated again, and
if `true` the <em>ScopeStatement</em> is executed again. This continues until the <em>Expression</em>
evaluates to `false`.

---
int i = 0;
while (i &lt; 10)
{
    foo(i);
    ++i;
}

---

If an `auto` $(I Identifier) is provided, it is declared and
initialized to the value and type of the <em>Expression</em>. Its scope
extends from when it is initialized to the end of the <em>ScopeStatement</em>.

If a $(I TypeCtors) $(I Identifier) is provided, it is declared
to be of the type specified by $(I TypeCtors) and is initialized with
the value of the <em>Expression</em>. Its scope extends from when it is
initialized to the end of the <em>ScopeStatement</em>.

If a $(I Declarator) is provided, it is declared and initialized
to the value of the <em>Expression</em>. Its scope extends from when it is
initialized to the end of the <em>ScopeStatement</em>.

A [#BreakStatement|BreakStatement] will exit the loop.

A [#ContinueStatement|ContinueStatement] will transfer directly to evaluating $(I IfCondition) again.

$(H2 $(ID do-statement)Do Statement)

$(PRE $(CLASS GRAMMAR)
$(B $(ID DoStatement) DoStatement):
    `do` [#ScopeStatement|ScopeStatement] ` while (` [expression#Expression|expression, Expression] `)` `;`

)


Do while statements implement simple loops.

<em>ScopeStatement</em> is executed. Then <em>Expression</em> is evaluated and must have a
type that can be converted to a boolean. If it's `true` the loop is iterated
again. This continues until the <em>Expression</em> evaluates to `false`.

---
int i = 0;
do
{
    foo(i);
} while (++i &lt; 10);

---

A [#BreakStatement|BreakStatement] will exit the loop. A [#ContinueStatement|ContinueStatement]
will transfer directly to evaluating <em>Expression</em> again.

$(H2 $(ID for-statement)For Statement)

For statements implement loops with initialization, test, and increment
clauses.

$(PRE $(CLASS GRAMMAR)
$(B $(ID ForStatement) ForStatement):
    `for (` [#Initialize|Initialize] [#Test|Test]$(SUBSCRIPT opt) `;` [#Increment|Increment]$(SUBSCRIPT opt) `)` [#ScopeStatement|ScopeStatement]

$(B $(ID Initialize) Initialize):
    `;`
    [#NoScopeNonEmptyStatement|NoScopeNonEmptyStatement]

$(B $(ID Test) Test):
    [expression#Expression|expression, Expression]

$(B $(ID Increment) Increment):
    [expression#Expression|expression, Expression]

)

        $(I Initialize) is executed.
        $(I Test) is evaluated and must have a type that
        can be converted to a boolean. If <em>Test</em> is `true` the
        <em>ScopeStatement</em> is executed. After execution,
        $(I Increment) is executed.
        Then $(I Test) is evaluated again, and if `true` the
        <em>ScopeStatement</em> is executed again. This continues until the
        $(I Test) evaluates to `false`.
        

        A [#BreakStatement|BreakStatement] will exit the loop.
        A [#ContinueStatement|ContinueStatement]
        will transfer directly to the $(I Increment).
        

        A $(I ForStatement) creates a new scope.
        If $(I Initialize) declares a variable, that variable's scope
        extends through <em>ScopeStatement</em>. For example:
        

---
for (int i = 0; i &lt; 10; i++)
    foo(i);

---

        is equivalent to:

---
{
    int i;
    for (i = 0; i &lt; 10; i++)
        foo(i);
}

---

<em>ScopeStatement</em> cannot be an empty statement:

---
for (int i = 0; i &lt; 10; i++)
    ;       // illegal

---

        Use instead:

---
for (int i = 0; i &lt; 10; i++)
{
}

---

    $(I Initialize) may be just `;`.
    $(I Test) may be omitted, and if
    so, it is treated as if it evaluated to `true`.

    $(TIP Consider replacing $(I ForStatements) with
    $(LINK2 spec/statement#foreach-statement,Foreach Statements) or
    $(LINK2 spec/statement#ForeachRangeStatement,Foreach Range Statements).
    Foreach loops are easier to understand, less prone to error, and easier to refactor.
    )

$(H2 $(ID foreach-statement)Foreach Statement)

A `foreach` statement iterates a series of values.

$(PRE $(CLASS GRAMMAR)
$(B $(ID AggregateForeach) AggregateForeach):
    [#Foreach|Foreach] `(` [#ForeachTypeList|ForeachTypeList] `;` [#ForeachAggregate|ForeachAggregate] `)`

$(B $(ID ForeachStatement) ForeachStatement):
    [#AggregateForeach|AggregateForeach] [#NoScopeNonEmptyStatement|NoScopeNonEmptyStatement]

$(B $(ID Foreach) Foreach):
    `foreach`
    `foreach_reverse`

$(B $(ID ForeachTypeList) ForeachTypeList):
    [#ForeachType|ForeachType]
    [#ForeachType|ForeachType] `,` ForeachTypeList

$(B $(ID ForeachType) ForeachType):
    [#ForeachTypeAttributes|ForeachTypeAttributes]$(SUBSCRIPT opt) [type#BasicType|type, BasicType] [declaration#Declarator|declaration, Declarator]
    [#ForeachTypeAttributes|ForeachTypeAttributes]$(SUBSCRIPT opt) $(LINK2 lex#Identifier, Identifier)
    [#ForeachTypeAttributes|ForeachTypeAttributes]$(SUBSCRIPT opt) `alias` $(LINK2 lex#Identifier, Identifier)

$(B $(ID ForeachTypeAttributes) ForeachTypeAttributes):
    [#ForeachTypeAttribute|ForeachTypeAttribute]
    [#ForeachTypeAttribute|ForeachTypeAttribute] ForeachTypeAttributes

$(B $(ID ForeachTypeAttribute) ForeachTypeAttribute):
    `enum`
    `ref`
    `scope`
    [type#TypeCtor|type, TypeCtor]

$(B $(ID ForeachAggregate) ForeachAggregate):
    [expression#Expression|expression, Expression]

)

        $(I ForeachAggregate) is evaluated. It must evaluate to an expression
        which is a static array, dynamic array, associative array,
        struct, class, delegate, or sequence.
        The <em>NoScopeNonEmptyStatement</em> is executed, once for each element of the
        aggregate.

        The number of variables declared in $(I ForeachTypeList)
        depends on the kind of aggregate. The declared variables are
        set at the start of each iteration.

$(LIST
        * By default a single declared variable is a copy of the current element.
        * If the $(I ForeachTypeAttribute) is `ref`, that variable will
        be a reference to the current element of the aggregate.
        * If the $(I ForeachTypeAttribute) is `scope`, the variable
        will have $(LINK2 spec/function#scope-parameters,`scope`) semantics.

)
        If not specified, the type of a $(I ForeachType) variable
        can be inferred from the type of the $(I ForeachAggregate).
        Note that `auto` is not a valid $(I ForeachTypeAttribute).
        The two `foreach` statements below are equivalent:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
int[] arr = [1, 2, 3];

foreach (int n; arr)
    writeln(n);

foreach (n; arr) // ok, n is an int
    writeln(n);

---

)
        The aggregate must be [#foreach_restrictions|loop invariant],
        meaning that elements cannot be added or removed from it
        in the <em>NoScopeNonEmptyStatement</em>.


        A [#BreakStatement|BreakStatement] in the body of the foreach will exit the
        loop. A [#ContinueStatement|ContinueStatement] will immediately start the
        next iteration.
        

$(H3 $(ID foreach_over_arrays) Foreach over Arrays)

        If the aggregate is a static or dynamic array, there
        can be one or two variables declared. If one, then the variable
        is said to be the $(I value), which is set successively to each
        element of the array. The type of the variable, if specified,
        must be compatible with the array element type (except for the
        special handling of character elements outlined below).
        The <em>value</em> variable can modify array elements when
        [#foreach_ref_parameters|declared with `ref`].

        If there are
        two variables declared, the first is said to be the $(I index)
        and the second is said to be the $(I value) as above.
        $(I index) cannot be declared with `ref`.
        It is set to the index of the array element on each iteration.
        The index type can be inferred:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
char[] a = ['h', 'i'];

foreach (i, char c; a)
{
    writefln("a[%d] = '%c'", i, c);
}

---

)
        For a dynamic array, the $(I index) type must be compatible
        with `size_t`.
        Static arrays may use any integral type that spans the length
        of the array.

        For `foreach`, the
        elements for the array are iterated over starting at index 0
        and continuing to the last element of the array.
        For `foreach_reverse`, the array elements are visited in the reverse
        order.
        

$(H3 $(ID foreach_over_arrays_of_characters) Foreach over Arrays of Characters)

        If the aggregate expression is a static or dynamic array of
        `char`s, `wchar`s, or `dchar`s, then the type of
        the $(I value) variable
        can be any of `char`, `wchar`, or `dchar`.
        In this manner any UTF array
        can be decoded into any UTF type:
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
char[] a = "\xE2\x89\xA0".dup;  // \u2260 encoded as 3 UTF-8 bytes

foreach (dchar c; a)
{
    writefln("a[] = %x", c); // prints 'a[] = 2260'
}

dchar[] b = "\u2260"d.dup;

foreach (char c; b)
{
    writef("%x, ", c);  // prints 'e2, 89, a0, '
}

---

)

        Aggregates can be string literals, which can be accessed
        as `char`, `wchar`, or `dchar` arrays:
        

    $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
foreach (char c; "ab")
{
    writefln("'%s'", c);
}
foreach (wchar w; "xy")
{
    writefln("'%s'", w);
}

---
    
)

        which would print:
        

$(CONSOLE 'a'
'b'
'x'
'y'
)

$(H3 $(ID foreach_over_associative_arrays) Foreach over Associative Arrays)

        If the aggregate expression is an associative array, there
        can be one or two variables declared. If one, then the variable
        is said to be the $(I value) set to the elements of the array,
        one by one. If the type of the
        variable is provided, it must implicitly convert from the array element type.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
// value type is int
int[string] userAges = ["john":30, "sue":32];

foreach (ref age; userAges)
{
    age++;
}
assert(userAges == ["john":31, "sue":33]);

---

)

        If there are
        two variables declared, the first is said to be the $(I index)
        and the second is said to be the $(I value). The $(I index)
        must be compatible with the indexing type of the associative
        array. It cannot be `ref`,
        and it is set to be the index of the array element.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
// index type is string, value type is double
double[string] aa = ["pi":3.14, "e":2.72];

foreach (string s, double d; aa)
{
    writefln("aa['%s'] = %g", s, d);
}

---

)

        The order in which the elements of the
        array are iterated over is unspecified for `foreach`.
        This is why `foreach_reverse` for associative arrays is illegal.

$(H3 $(ID foreach_over_struct_and_classes) Foreach over Structs and Classes with `opApply`)

    If the aggregate expression is a struct or class object,
        the `foreach` is defined by the
        special $(ID op-apply)`opApply` member function, and the
        `foreach_reverse` behavior is defined by the special
        $(ID op-apply-reverse)`opApplyReverse` member function.
        These functions must each have the signature below:
    

$(PRE $(CLASS GRAMMAR)
$(B $(ID OpApplyDeclaration) OpApplyDeclaration):
    `int opApply` `(` `scope` `int delegate` `(` $(I OpApplyParameters) `)` `dg` `)` `;`

$(B $(ID OpApplyParameters) OpApplyParameters):
    <em>OpApplyParameter</em>
    <em>OpApplyParameter</em>, <em>OpApplyParameters</em>

$(B $(ID OpApplyParameter) OpApplyParameter):
    [#ForeachTypeAttributes|ForeachTypeAttributes]$(SUBSCRIPT opt) [type#BasicType|type, BasicType] [declaration#Declarator|declaration, Declarator]

)

    where each $(I OpApplyParameter) of `dg` must match a [#ForeachType|ForeachType]
        in a <em>ForeachStatement</em>,
        otherwise the <em>ForeachStatement</em> will cause an error.

    Any <em>ForeachTypeAttribute</em> cannot be `enum`.

    $(NOTE     To support a `ref` iteration variable, the delegate must take a `ref` parameter:

    $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
struct S
{
    int opApply(scope int delegate(ref uint n) dg);
}
void f(S s)
{
    foreach (ref uint i; s)
        i++;
}

---
    
)
    Above, `opApply` is still matched when `i` is not `ref`, so by using
    a `ref` delegate parameter both forms are supported.
    )

    There can be multiple `opApply` and `opApplyReverse` functions -
        one is selected
        by matching each parameter of `dg` to each $(I ForeachType)
        declared in the $(I ForeachStatement).

    The body of the apply
        function iterates over the elements it aggregates, passing each one
        in successive calls to the `dg` delegate. The delegate return value
        determines whether to interrupt iteration:

    $(LIST
        * If the result is nonzero, apply must cease
        iterating and return that value.
        * If the result is 0, then iteration should continue.
        If there are no more elements to iterate,
        apply must return 0.
    
)

    For example, consider a class that is a container for two elements:

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
class Foo
{
    uint[2] array;

    int opApply(scope int delegate(ref uint) dg)
    {
        foreach (e; array)
        {
            int result = dg(e);
            if (result)
                return result;
        }
        return 0;
    }
}

void main()
{
    import std.stdio;

    Foo a = new Foo();
    a.array = [73, 82];

    foreach (uint u; a)
    {
        writeln(u);
    }
}

---
        
)

    This would print:

$(CONSOLE 73
82
)
    $(NOTE     The `scope` storage class on the `dg` parameter means that the delegate does
    not escape the scope of the `opApply` function (an example would be assigning `dg` to a
    global variable). If it cannot be statically guaranteed that `dg` does not escape, a closure may
    be allocated for it on the heap instead of the stack.

    $(TIP Annotate delegate parameters to `opApply` functions with `scope` when possible.)
    )

    $(B Important:) If `opApply` catches any exceptions, ensure that those
        exceptions did not originate from the delegate passed to `opApply`. The user would expect
        exceptions thrown from a `foreach` body to both terminate the loop, and propagate outside
        the `foreach` body.
     

$(H4 $(ID template-op-apply) Template `opApply`)

    `opApply` can also be a templated function,
        which will infer the types of parameters based on the $(I ForeachStatement).
        For example:

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
struct S
{
    import std.traits : ParameterTypeTuple;  // introspection template
    import std.stdio;

    int opApply(Dg)(scope Dg dg)
    if (ParameterTypeTuple!Dg.length == 2) // foreach with 2 parameters
    {
        writeln(2);
        return 0;
    }

    int opApply(Dg)(scope Dg dg)
    if (ParameterTypeTuple!Dg.length == 3) // foreach with 3 parameters
    {
        writeln(3);
        return 0;
    }
}

void main()
{
    foreach (int a, int b; S()) { }  // calls first opApply function
    foreach (int a, int b, float c; S()) { }  // calls second opApply function
}

---
        
)

$(H3 $(ID foreach-with-ranges)Foreach over Structs and Classes with Ranges)

    If the aggregate expression is a struct or class object, but the
        `opApply` for `foreach`, or `opApplyReverse` for `foreach_reverse` do not exist,
        then iteration can be done with $(LINK2 phobos/std_range.html, range) primitives.
        For `foreach`, this means the following properties and methods must
        be defined:
    

        $(TABLE_ROWS
Foreach Range Properties
        * + Property
+ Purpose

        * - `.empty`
- returns true if no more elements

        * - `.front`
- return the leftmost element of the range

        
)

        $(TABLE_ROWS
Foreach Range Methods
        * + Method
+ Purpose

        * - `.popFront()`
- move the left edge of the range
        right by one

        
)

    Meaning:

---
foreach (e; range) { ... }

---

    translates to:

---
for (auto __r = range; !__r.empty; __r.popFront())
{
    auto e = __r.front;
    ...
}

---

    Similarly, for `foreach_reverse`, the following properties and
        methods must be defined:
    

        $(TABLE_ROWS
Foreach_reverse Range Properties
        * + Property
+ Purpose

        * - `.empty`
- returns true if no more elements

        * - `.back`
- return the rightmost element of the range

        
)

        $(TABLE_ROWS
Foreach_reverse Range Methods
        * + Method
+ Purpose

        * - `.popBack()`
- move the right edge of the range
        left by one

        
)

    Meaning:

---
foreach_reverse (e; range) { ... }

---

    translates to:

---
for (auto __r = range; !__r.empty; __r.popBack())
{
    auto e = __r.back;
    ...
}

---

    Example with a linked list:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
struct Node
{
    int i;
    Node* next;
}

// range
struct List
{
    Node* node;

    bool empty() { return node == null; }

    ref int front() { return node.i; }

    void popFront() { node = node.next; }
}

void main()
{
    import std.stdio;
    auto l = new Node(1, new Node(2, null));
    auto r = List(l);

    foreach (e; r)
    {
        writeln(e);
    }
}

---

)

$(H4 $(ID front-seq) Multiple Element Values)

    Multiple loop variables are allowed if the `front` property returns a type that
        expands to a $(LINK2 spec/template#homogeneous_sequences,value sequence)
        whose length matches the number of variables. Each variable is assigned
        to the corresponding value in the sequence.
    

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
struct Tuple(Types...) // takes a TypeSeq
{
    Types items; // ValueSeq
    alias items this; // decay to a value sequence
}

// Infinite range with a repeating element, which is a tuple
struct TupleRange
{
    enum front = Tuple!(char, bool, int)('a', true, 2);
    enum bool empty = false;

    void popFront() {}
}

void main()
{
    // Tuple destructuring
    foreach (a, b, c; TupleRange())
    {
        assert(a == 'a');
        assert(b == true);
        assert(c == 2);
        break;
    }
    // Tuple variable
    foreach (tup; TupleRange())
    {
        assert(tup[0] == 'a');
        assert(tup == TupleRange.front);
        break;
    }
}

---
        
)
        See also: $(REF Tuple, std,typecons).

$(H3 $(ID foreach_over_delegates) Foreach over Delegates)

        If $(I ForeachAggregate) is a delegate, the type signature of
        the delegate is of the same as for
        [#foreach_over_struct_and_classes|opApply]. This enables
        many different named looping strategies to coexist in the same
        class or struct.

        The delegate can generate the elements on the fly:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
// Custom loop implementation, that iterates over powers of 2 with
// alternating sign. The foreach loop body is passed in dg.
int myLoop(int delegate(int) dg)
{
    for (int z = 1; z &lt; 128; z *= -2)
    {
        auto ret = dg(z);

        // If the loop body contains a break, ret will be non-zero.
        if (ret != 0)
            return ret;
    }
    return 0;
}

// Append each value in the iteration to an array
int[] result;
foreach (x; &amp;myLoop)
{
    result ~= x;
}
assert(result == [1, -2, 4, -8, 16, -32, 64, -128]);

---

)

        $(B Note:) When $(I ForeachAggregate) is a delegate, the compiler
        does not try to implement reverse traversal of the results returned by
        the delegate when `foreach_reverse` is used. This may result in code
        that is confusing to read. Therefore, using `foreach_reverse` with a
        delegate is now deprecated, and will be rejected in the future.

$(H3 $(ID foreach_over_tuples) Foreach over Sequences)

        If the aggregate expression is a
        $(LINK2 spec/template#variadic-templates,sequence),
        the loop body is statically expanded once for each element. This is
        the same as $(LINK2 spec/version#staticforeach,Static Foreach)
        on a sequence.

        There
        can be one or two iteration symbols declared. If one, then the symbol
        is an $(I element alias) of each element in the sequence in turn.

$(LIST
*         If the sequence is a $(I TypeSeq), the element alias is set to each
        type in turn.
*         If the sequence is a $(I ValueSeq), the element alias
        is set to each value in turn. If the type of the element alias
        is given, it must be compatible with the type of every sequence element.
        If no type is given, the type of the element alias will match the type
        of each sequence element, which may change between elements.

)
        If there are
        two symbols declared, the first is the $(I index variable)
        and the second is the $(I element alias). The index
        must be of `int`, `uint`, `long` or `ulong` type,
        it cannot be `ref`,
        and it is set to the index of each sequence element.

        Example:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
import std.meta : AliasSeq;

void main()
{
    alias Seq = AliasSeq!(int, "literal", main);

    foreach (int i, sym; Seq)
    {
        pragma(msg, i, ": ", sym.stringof);
    }
}

---

)
        Output:

$(CONSOLE 0: int
1: "literal"
2: main()
)

        Example:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
void fun()
{
    import std.meta : AliasSeq;

    alias values = AliasSeq!(7.4, "hi", [2,5]);

    foreach (sym; values)
    {
        pragma(msg, sym, " has type ", typeof(sym));
    }
}

---

)

        Output:

$(CONSOLE 7.4 has type double
hi has type string
[2, 5] has type int[]
)

$(H3 $(ID foreach_ref_parameters) Foreach Ref Parameters)

        `ref` can be used to modify the elements of the <em>ForeachAggregate</em>.
        This works for containers that expose lvalue elements, and
        $(LINK2 spec/template#homogeneous_sequences,lvalue sequences).
        

    $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
uint[2] a = [7, 8];

foreach (ref u; a)
{
    u++;
}
foreach (u; a)
{
    writeln(u);
}

---
    
)

        which would print:

$(CONSOLE 8
9
)
        `ref` cannot be applied to an array index variable.

$(H3 $(ID foreach_restrictions) Foreach Restrictions)

        The aggregate itself must not be resized, reallocated, free'd,
        reassigned or destructed
        while `foreach` is iterating over the elements.
        

---
int[] a = [1, 2, 3];
auto fun = { a ~= 4; };

foreach (int v; a)
{
    // resizing is unspecified!
    fun();
    a ~= 4;
    a.length += 10;

    // reallocating is unspecified!
    a.reserve(10);

    // reassigning is unspecified!
    a = null;
    a = [5, 6];
}
a ~= 4;   // OK
a = null; // OK

---
---
auto aa = [1: 1, 2: 2];

foreach (v; aa)
{
    aa[3] = 3; // unspecified resize
    aa.rehash; // unspecified reallocation
    aa = [4: 4]; // unspecified reassign
}
aa[3] = 3; // OK
aa = null; // OK

---

        Note: Resizing or reassigning a dynamic or associative array during
        `foreach` is still `@safe`.
        

$(H3 $(ID foreach-range-statement)Foreach Range Statement)

A foreach range statement loops over the specified range.

$(PRE $(CLASS GRAMMAR)
$(B $(ID RangeForeach) RangeForeach):
    [#Foreach|Foreach] `(` [#ForeachType|ForeachType] `;` [#LwrExpression|LwrExpression] `..` [#UprExpression|UprExpression] `)`

$(B $(ID LwrExpression) LwrExpression):
    [expression#Expression|expression, Expression]

$(B $(ID UprExpression) UprExpression):
    [expression#Expression|expression, Expression]

$(B $(ID ForeachRangeStatement) ForeachRangeStatement):
    [#RangeForeach|RangeForeach] [#ScopeStatement|ScopeStatement]

)

                $(I ForeachType) declares a variable with either an explicit type,
        or a common type inferred from $(I LwrExpression) and $(I UprExpression).
        The $(I ScopeStatement) is then executed $(I n) times, where $(I n)
        is the result of $(I UprExpression) `-` $(I LwrExpression).
        If $(I UprExpression) is less than or equal to $(I LwrExpression),
        the $(I ScopeStatement) is not executed.

                If $(I Foreach) is `foreach`, then the variable is set to
        $(I LwrExpression), then incremented at the end of each iteration.
        If $(I Foreach) is `foreach_reverse`, then the variable is set to
        $(I UprExpression), then decremented before each iteration.
        $(I LwrExpression) and $(I UprExpression) are each evaluated
        exactly once, regardless of how many times the $(I ScopeStatement)
        is executed.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
import std.stdio;

int foo()
{
    write("foo");
    return 10;
}

void main()
{
    foreach (i; 0 .. foo())
    {
        write(i);
    }
}

---

)

prints:

$(CONSOLE foo0123456789
)


$(H2 $(ID switch-statement)Switch Statement)

        A switch statement goes to one of a collection of case
        statements depending on the value of the switch
        expression.

$(PRE $(CLASS GRAMMAR)
$(B $(ID SwitchStatement) SwitchStatement):
    `switch (` [#IfCondition|IfCondition] `)` [#ScopeStatement|ScopeStatement]

$(B $(ID CaseStatement) CaseStatement):
    `case` [expression#ArgumentList|expression, ArgumentList] `:` [#ScopeStatementList|ScopeStatementList]$(SUBSCRIPT opt)

$(B $(ID DefaultStatement) DefaultStatement):
    `default :` [#ScopeStatementList|ScopeStatementList]$(SUBSCRIPT opt)

$(B $(ID ScopeStatementList) ScopeStatementList):
    [#StatementListNoCaseNoDefault|StatementListNoCaseNoDefault]

$(B $(ID StatementListNoCaseNoDefault) StatementListNoCaseNoDefault):
    [#StatementNoCaseNoDefault|StatementNoCaseNoDefault]
    [#StatementNoCaseNoDefault|StatementNoCaseNoDefault] StatementListNoCaseNoDefault

$(B $(ID StatementNoCaseNoDefault) StatementNoCaseNoDefault):
    [#EmptyStatement|EmptyStatement]
    [#NonEmptyStatementNoCaseNoDefault|NonEmptyStatementNoCaseNoDefault]
    [#ScopeBlockStatement|ScopeBlockStatement]

)

        The <em>Expression</em> from the $(I IfCondition) is evaluated.
        If the type of the <em>Expression</em> is an `enum`, it is
        (recursively) converted to its [enum#EnumBaseType|enum, EnumBaseType].
        Then, if the type is an integral, the <em>Expression</em> undergoes
        $(LINK2 spec/type#integer-promotions,Integer Promotions).
        Then, the type of the <em>Expression</em> must be either an integral or
        a static or dynamic array of `char`, `wchar`, or `dchar`.
        

        If an $(I Identifier) `=` prefix is provided, a variable is declared with that
        name, initialized to the value and type of the <em>Expression</em>. Its scope
        extends from when it is initialized to the end of the <em>ScopeStatement</em>.

        If $(I TypeCtors) and/or a specific type is provided for <em>Identifier</em>, those
        are used for the variable declaration which is initialized by an implicit
        conversion from the value of the <em>Expression</em>.

        The resulting value is
        compared against each of the case expressions. If there is
        a match, the corresponding case statement is transferred to.
        

        The case expressions in $(I ArgumentList)
        are a comma separated list of expressions.
        Each expression must evaluate to a compile-time value or array,
        or a runtime initialized const or immutable variable of integral type.
        Each expression must be implicitly convertible to the type of the switch
        <em>Expression</em>.

        Compile-time case values must all be distinct. Const or
        immutable runtime variables must all have different names.
        If two case expressions share a
        value, the first case statement with that value gets control.

        The [#ScopeStatementList|ScopeStatementList] introduces a new scope.
        

        A matching `break` statement will exit the switch $(I BlockStatement).

        A switch statement must have exactly one <em>DefaultStatement</em>.
        If none of the case expressions match, control is transferred
        to the default statement.
        

        Rationale: This makes it clear that all possible cases are intentionally handled.
        See also: [#final-switch-statement|`final switch`].

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
foreach (i; 2 .. 10)
{
    bool prime;

    switch (i)
    {
        case 2, 3, 5, 7:
            prime = true;
            break;
        default:
            prime = false;
    }
    writeln(i, ": ", prime);
}

---

)
        Case statements and default statements associated with the switch
        can be nested within block statements; they do not have to be in
        the outermost block. For example, this is allowed:
        

---
switch (i)
{
    case 1:
    {
        case 2:
    }
    i++;
    break;
    default:
}

---

        $(B Implementation Note:) The compiler's code generator may
        assume that the case
        statements are sorted by frequency of use, with the most frequent
        appearing first and the least frequent last. Although this is
        irrelevant as far as program correctness is concerned, it is of
        performance interest.
        

$(H3 $(ID case-range) Case Range Statement)

$(PRE $(CLASS GRAMMAR)
$(B $(ID CaseRangeStatement) CaseRangeStatement):
    `case` [#FirstExp|FirstExp] `: .. case` [#LastExp|LastExp] `:` [#ScopeStatementList|ScopeStatementList]$(SUBSCRIPT opt)

$(B $(ID FirstExp) FirstExp):
    AssignExpression

$(B $(ID LastExp) LastExp):
    AssignExpression

)

        A $(I CaseRangeStatement) is a shorthand for listing a series
        of case statements from $(I FirstExp) to $(I LastExp), inclusive.

---
case 1: .. case 3:

---

        The above is equivalent to:

---
case 1, 2, 3:

---

$(H3 $(ID no-implicit-fallthrough) No Implicit Fall-Through)


        A [#ScopeStatementList|ScopeStatementList] must either be empty, or be ended with
        a [#ContinueStatement|ContinueStatement], [#BreakStatement|BreakStatement],
        [#ReturnStatement|ReturnStatement], [#GotoStatement|GotoStatement], [expression#ThrowExpression|expression, ThrowExpression]
        or `assert(0)` expression unless this is the last case.

---
switch (i)
{
    case 1:
        message ~= "one";
        // ERROR: implicit fall-through
    case 2:
        // valid: the body is empty
    default:
        message ~= "unknown";
}

---

        `goto case;` can be used for explicit fall-through:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
string message;

foreach (i; 1..5)
{
    switch (i)
    {
        default:    // valid: ends with 'throw'
            throw new Exception("unknown number");

        case 3:     // valid: ends with 'break' (break out of the 'switch' only)
            message ~= "three";
            break;

        case 4:     // valid: ends with 'continue' (continue the enclosing loop)
            message ~= "four";
            continue; // don't append a comma

        case 1:     // valid: ends with 'goto' (explicit fall-through to next case.)
            message ~= "&gt;";
            goto case;

        case 2:     // valid: this is the last case in the switch statement.
            message ~= "one or two";
    }
    message ~= ", ";
}
writeln(message);

---

)
        [#goto-statement|`goto`] also supports jumping to
        a specific case or the default case statement.

$(H3 $(ID string-switch) String Switch)

        Strings can be used in switch expressions.
        For example:
        

---
string name;
...
switch (name)
{
    case "fred":
    case "sally":
        ...
}

---

        For applications like command line switch processing, this
        can lead to much more straightforward code, being clearer and
        less error prone. `char`, `wchar` and `dchar` strings are allowed.
        


$(H2 $(ID final-switch-statement)Final Switch Statement)

$(PRE $(CLASS GRAMMAR)
$(B $(ID FinalSwitchStatement) FinalSwitchStatement):
    `final switch (` [#IfCondition|IfCondition] `)` [#ScopeStatement|ScopeStatement]

)

        A final switch statement is just like a switch statement,
        except that:

        $(LIST
        * No [#DefaultStatement|DefaultStatement] is allowed.
        * No [#CaseRangeStatement|CaseRangeStatement]s are allowed.
        * If the switch <em>Expression</em> is of enum type, all
        the enum members must appear in the [#CaseStatement|CaseStatement]s.
        * The case expressions cannot evaluate to a run time
        initialized value.
        
)

        $(WARNING If the <em>Expression</em> value does not match any
        of the $(I CaseRangeStatements), whether that is diagnosed at compile
        time or at runtime.)


$(H2 $(ID continue-statement)Continue Statement)

$(PRE $(CLASS GRAMMAR)
$(B $(ID ContinueStatement) ContinueStatement):
    `continue` $(LINK2 lex#Identifier, Identifier)$(SUBSCRIPT opt) `;`

)

        `continue` aborts the current iteration of its innermost enclosing
        loop statement, and starts the next iteration.
        If the enclosing loop is a `for` statement,
        its [#Increment|Increment] clause is executed.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
string[] words = ["OK", "just", "longer", "words", "now"];

foreach (w; words)
{
    if (w.length &lt; 4)
        continue; // skip writeln

    writeln(w);
}

---

)
        Output:

$(CONSOLE just
longer
words
)

        If `continue` is followed by $(I Identifier), the $(I Identifier)
        must be the label of an enclosing loop statement,
        and the next iteration of that loop is executed.
        It is an error if
        there is no such statement.

---
outer:
foreach (item; list)
{
    // try 3 times
    foreach (i; 0 .. 3)
    {
        if (item.buy())
            continue outer; // skip to next item

        log("attempt failed");
    }
}

---

        Any intervening [#try-statement|`finally`] clauses are executed,
        and any intervening synchronization objects are released.

        `Note:` If a `finally` clause executes a `throw` out of the finally
        clause, the continue target is never reached.

$(H2 $(ID break-statement)Break Statement)

$(PRE $(CLASS GRAMMAR)
$(B $(ID BreakStatement) BreakStatement):
    `break` $(LINK2 lex#Identifier, Identifier)$(SUBSCRIPT opt) `;`

)

`break` exits the innermost enclosing loop or [#switch-statement|`switch`]
statement, resuming execution at the statement following it.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
const n = 55;

// find the smallest factor of n
foreach (i; 2 .. n)
{
    writeln("Trying: ", i);
    if (n % i == 0)
    {
        writeln("smallest factor is ", i);
        break; // stop looking
    }
}
writeln("finished");

---

)
        Output:

$(CONSOLE Trying: 2
Trying: 3
Trying: 4
Trying: 5
smallest factor is 5
finished
)

        If `break` is followed by $(I Identifier), the $(I Identifier)
        must be the label of an enclosing loop or `switch`
        statement, and that statement is exited. It is an error if
        there is no such statement.

---
// display messages cyclically until the shop is closed
outer:
while (true)
{
    foreach (msg; messages)
    {
        if (shop.isClosed())
            break outer; // end the while loop

        display(msg);
    }
}
display("opens at 9am");

---

        Any intervening [#try-statement|`finally`] clauses are executed,
        and any intervening synchronization objects are released.

        `Note:` If a `finally` clause executes a `throw` out of the finally
        clause, the break target is never reached.

$(H2 $(ID return-statement)Return Statement)

$(PRE $(CLASS GRAMMAR)
$(B $(ID ReturnStatement) ReturnStatement):
    `return` [expression#Expression|expression, Expression]$(SUBSCRIPT opt) `;`

)

`return` exits the current function and supplies its
$(LINK2 spec/function#function-return-values,return value).

<em>Expression</em> is required if the function specifies a return type that is
not void. The <em>Expression</em> is implicitly converted to the function return
type.

        An <em>Expression</em> of type void is allowed if the function specifies
        a void return type. The <em>Expression</em> will be evaluated,
        but nothing will be returned. This is useful in generic programming.

        Before the function actually returns,
        any objects with `scope` storage duration are destroyed,
        any enclosing `finally` clauses are executed,
        any `scope(exit)` statements are executed,
        any `scope(success)` statements are executed,
        and any enclosing synchronization
        objects are released.

        The function will not return if any enclosing `finally` clause
        does a return, goto or throw that exits the `finally` clause.

        If there is an $(LINK2 spec/function#postconditions,`out` postcondition),
        that postcondition is executed
        after the <em>Expression</em> is evaluated and before the function
        actually returns.

---
int foo(int x)
{
    return x + 3;
}

---

$(H2 $(ID goto-statement)Goto Statement)

$(PRE $(CLASS GRAMMAR)
$(B $(ID GotoStatement) GotoStatement):
    `goto` $(LINK2 lex#Identifier, Identifier) `;`
    `goto` `default` `;`
    `goto` `case` `;`
    `goto` `case` [expression#Expression|expression, Expression] `;`

)

`goto` transfers to the statement labeled with $(I Identifier).

---
    if (foo)
        goto L1;
    x = 3;
L1:
    x++;

---

The second form, `goto default;`, transfers to the innermost [#DefaultStatement|DefaultStatement] of an enclosing [#SwitchStatement|SwitchStatement].

        The third form, `goto case;`, transfers to the
        next [#CaseStatement|CaseStatement] of the innermost enclosing
        [#SwitchStatement|SwitchStatement].

        The fourth form, `goto case` <em>Expression</em>`;`, transfers to the
        [#CaseStatement|CaseStatement] of the innermost enclosing
        [#SwitchStatement|SwitchStatement]
        with a matching <em>Expression</em>.

---
switch (x)
{
    case 3:
        goto case;
    case 4:
        goto default;
    case 5:
        goto case 4;
    default:
        x = 4;
        break;
}

---

Any intervening finally clauses are executed, along with releasing any
intervening synchronization mutexes.

        It is illegal for a $(I GotoStatement) to be used to skip
        initializations.

$(H2 $(ID with-statement)With Statement)

The `with` statement is a way to simplify repeated references to the same
object.

$(PRE $(CLASS GRAMMAR)
$(B $(ID WithStatement) WithStatement):
    `with` `(` [expression#Expression|expression, Expression] `)` [#ScopeStatement|ScopeStatement]
    `with` `(` [template#Symbol|template, Symbol] `)` [#ScopeStatement|ScopeStatement]
    `with` `(` [template#TemplateInstance|template, TemplateInstance] `)` [#ScopeStatement|ScopeStatement]

)

        where <em>Expression</em> evaluates to one of:

        $(LIST
        * a class reference
        * a struct instance
        * an enum instance
        * a pointer to one of the above
        
)

        Within the with body the referenced object is searched first for
        identifier symbols.

---
enum E { A, B }

void test(E e)
{
    with (e)       // affects the switch statement
    switch (e)
    {
        case A:    // no need for E.A
        case B:
        default:
            break;
    }
}

---

Below, if `ident` is a member of the type of `expression`, the $(I WithStatement):

---
with (expression)
{
    ...
    ident;
}

---

        is semantically equivalent to:

---
(auto ref tmp)
{
    ...
    tmp.ident;
}(expression);

---

        Note that <em>Expression</em> only gets evaluated once and is not copied.
        The with statement does not change what `this` or
        `super` refer to.
        

        For $(I Symbol) which is a scope or $(I TemplateInstance),
        the corresponding scope is searched when looking up symbols.
        For example:
        

---
struct Foo
{
    alias Y = int;
}
...
Y y;        // error, Y undefined
with (Foo)
{
    Y y;    // same as Foo.Y y;
}

---

        Use of `with` object symbols that shadow local symbols with
        the same identifier are not allowed.
        This is to reduce the risk of inadvertent breakage of with
        statements when new members are added to the object declaration.
        
---
struct S
{
    float x;
}

void main()
{
    int x;
    S s;
    with (s)
    {
        x++;  // error, shadows the int x declaration
    }
}

---

        In nested $(I WithStatement)s, the inner-most scope takes precedence.  If
        a symbol cannot be resolved at the inner-most scope, resolution is forwarded
        incrementally up the scope hierarchy.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
import std.stdio;

struct Foo
{
    void f() { writeln("Foo.f"); }
}

struct Bar
{
    void f() { writeln("Bar.f"); }
}

struct Baz
{
    // f() is not implemented
}

void f()
{
    writeln("f");
}

void main()
{
    Foo foo;
    Bar bar;
    Baz baz;

    f();               // prints "f"

    with(foo)
    {
        f();           // prints "Foo.f"

        with(bar)
        {
            f();       // prints "Bar.f"

            with(baz)
            {
                f();   // prints "Bar.f".  `Baz` does not implement `f()` so
                       // resolution is forwarded to `with(bar)`'s scope
            }
        }
        with(baz)
        {
            f();       // prints "Foo.f".  `Baz` does not implement `f()` so
                       // resolution is forwarded to `with(foo)`'s scope
        }
    }
    with(baz)
    {
        f();           // prints "f".  `Baz` does not implement `f()` so
                       // resolution is forwarded to `main`'s scope. `f()` is
                       // not implemented in `main`'s scope, so resolution is
                       // subsequently forward to module scope.
    }
}

---

)

$(H2 $(ID synchronized-statement)Synchronized Statement)

        The synchronized statement wraps a statement with
        mutex locking and unlocking to synchronize access among multiple threads.
        

$(PRE $(CLASS GRAMMAR)
$(B $(ID SynchronizedStatement) SynchronizedStatement):
    `synchronized` [#ScopeStatement|ScopeStatement]
    `synchronized (` [expression#Expression|expression, Expression] `)` [#ScopeStatement|ScopeStatement]

)

        A synchronized statement without <em>Expression</em> allows only one thread
        at a time to execute $(I ScopeStatement) by locking a mutex.
        A global mutex is created, one per synchronized statement.
        Different synchronized statements will have different global mutexes.
        

        If there is an <em>Expression</em>, it must evaluate to either an
        Object or an instance of an $(LINK2 spec/interface, Interfaces),
        in which case it
        is cast to the Object instance that implemented that interface.
        The mutex used is specific to that Object instance, and
        is shared by all synchronized statements referring to that instance.
        If the object's mutex is already locked when reaching the synchronized
        statement, it will block every thread until that mutex is unlocked by
        other code.
        

$(NOTE $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
void work();

void f(Object o)
{
    synchronized (o) work();
}

void g(Object o)
{
    synchronized (o) work();
}

---

)
        If `f` and `g` are called by different threads but with the same
        argument, the `work` calls cannot execute simultaneously. If the
        `(o)` part of the `synchronized` statements is removed in one
        or both functions, then both `work` calls could execute
        simultaneously, because they would be protected by different mutexes.
)
        The synchronization gets released even if $(I ScopeStatement)
        terminates with an exception, goto, or return.
        

        This implements a standard critical section.
        

        Synchronized statements support recursive locking; that is, a
        function wrapped in synchronized is allowed to recursively call
        itself and the behavior will be as expected: The mutex will be
        locked and unlocked as many times as there is recursion.
        

        See also $(LINK2 spec/class#synchronized-classes,synchronized classes).

$(H2 $(ID try-statement)Try Statement)

Exception handling is done with the try-catch-finally statement.

$(PRE $(CLASS GRAMMAR)
$(B $(ID TryStatement) TryStatement):
    `try` [#ScopeStatement|ScopeStatement] [#Catches|Catches]
    `try` [#ScopeStatement|ScopeStatement] [#Catches|Catches] [#FinallyStatement|FinallyStatement]
    `try` [#ScopeStatement|ScopeStatement] [#FinallyStatement|FinallyStatement]

$(B $(ID Catches) Catches):
    [#Catch|Catch]
    [#Catch|Catch] Catches

$(B $(ID Catch) Catch):
    `catch (` [#CatchParameter|CatchParameter] `)` [#NoScopeNonEmptyStatement|NoScopeNonEmptyStatement]

$(B $(ID CatchParameter) CatchParameter):
    [type#BasicType|type, BasicType] $(LINK2 lex#Identifier, Identifier)$(SUBSCRIPT opt)

$(B $(ID FinallyStatement) FinallyStatement):
    `finally` [#NoScopeNonEmptyStatement|NoScopeNonEmptyStatement]

)

        $(I CatchParameter) declares a variable v of type T, where T is
        Throwable or derived from Throwable. v is initialized by the throw
        expression if T is of the same type or a base class of the throw
        expression. The catch clause will be executed if the exception object is
        of type T or derived from T.

        If just type T is given and no variable v, then the catch clause
        is still executed.
        

        It is an error if any $(I CatchParameter) type T1 hides
        a subsequent $(I Catch) with type T2, i.e. it is an error if
        T1 is the same type as or a base class of T2.
        

        The $(I FinallyStatement) is always executed, whether
        the `try` $(I ScopeStatement) exits with a goto, break,
        continue, return, exception, or fall-through.
        

        If an exception is raised in the $(I FinallyStatement) and is not
        caught before the original exception is caught, it is chained to the
        previous exception via the $(I next) member of $(I Throwable).
        Note that, in contrast to most other programming languages, the new
        exception does not replace the original exception. Instead, later
        exceptions are regarded as 'collateral damage' caused by the first
        exception. The original exception must be caught, and this results in
        the capture of the entire chain.
        

        Thrown objects derived from the $(LINK2 https://dlang.org/phobos/object.html#.Error, `Error`) class are treated differently. They
        bypass the normal chaining mechanism, such that the chain can only be
        caught by catching the first `Error`. In addition to the list of
        subsequent exceptions, `Error` also contains a pointer that points
        to the original exception (the head of the chain) if a bypass occurred,
        so that the entire exception history is retained.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
import std.stdio;

int main()
{
    try
    {
        try
        {
            throw new Exception("first");
        }
        finally
        {
            writeln("finally");
            throw new Exception("second");
        }
    }
    catch (Exception e)
    {
        writefln("catch %s", e.msg);
    }
    writeln("done");
    return 0;
}

---

)

    prints:

$(CONSOLE finally
catch first
done
)


        A $(I FinallyStatement) may not exit with a goto, break,
        continue, or return; nor may it be entered with a goto.
        

        A $(I FinallyStatement) may not contain any $(I Catches).
        This restriction may be relaxed in future versions.
        

$(H2 $(ID scope-guard-statement)Scope Guard Statement)

$(PRE $(CLASS GRAMMAR)
$(B $(ID ScopeGuardStatement) ScopeGuardStatement):
    `scope ( exit )` [#NonEmptyOrScopeBlockStatement|NonEmptyOrScopeBlockStatement]
    `scope ( success )` [#NonEmptyOrScopeBlockStatement|NonEmptyOrScopeBlockStatement]
    `scope ( failure )` [#NonEmptyOrScopeBlockStatement|NonEmptyOrScopeBlockStatement]

)

The $(I ScopeGuardStatement) executes <em>NonEmptyOrScopeBlockStatement</em> at the close of the
current scope, rather than at the point where the $(I ScopeGuardStatement)
appears. `scope(exit)` executes <em>NonEmptyOrScopeBlockStatement</em> when the scope exits normally
or when it exits due to exception unwinding. `scope(failure)` executes
<em>NonEmptyOrScopeBlockStatement</em> when the scope exits due to exception unwinding.
`scope(success)` executes <em>NonEmptyOrScopeBlockStatement</em> when the scope exits normally.

        If there are multiple $(I ScopeGuardStatement)s in a scope, they
        will be executed in the reverse lexical order in which they appear.
        If any scope instances are to be destroyed upon the close of the
        scope, their destructions will be interleaved with the $(I ScopeGuardStatement)s
        in the reverse lexical order in which they appear.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
write("1");
{
    write("2");
    scope(exit) write("3");
    scope(exit) write("4");
    write("5");
}
writeln();

---

)

        writes:

$(CONSOLE 12543
)


$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
{
    scope(exit) write("1");
    scope(success) write("2");
    scope(exit) write("3");
    scope(success) write("4");
}
writeln();

---

)

        writes:

$(CONSOLE 4321
)

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
struct Foo
{
    this(string s) { write(s); }
    ~this() { write("1"); }
}

try
{
    scope(exit) write("2");
    scope(success) write("3");
    Foo f = Foo("0");
    scope(failure) write("4");
    throw new Exception("msg");
    scope(exit) write("5");
    scope(success) write("6");
    scope(failure) write("7");
}
catch (Exception e)
{
}
writeln();

---

)

        writes:

$(CONSOLE 0412
)

        A `scope(exit)` or `scope(success)` statement
        may not exit with a throw, goto, break, continue, or
        return; nor may it be entered with a goto. A `scope(failure)`
        statement may not exit with a return.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
import std.stdio;

int foo()
{
    scope(exit) writeln("Inside foo()");
    return bar();
}

int bar()
{
    writeln("Inside bar()");
    return 0;
}

int main()
{
    foo();
    return 0;
}

---

)

        writes:

$(CONSOLE Inside bar()
Inside foo()
)

$(H3 $(ID catching_cpp_class_objects) Catching C++ Class Objects)

                On many platforms, catching C++ class objects is supported.
        Catching C++ objects and D objects cannot both be done
        in the same $(I TryStatement).
        Upon exit from the $(I Catch), any destructors for the C++
        object will be run and the storage used for it reclaimed.
        C++ objects cannot be caught in `@safe` code.
        

$(H2 $(ID asm) Asm Statement)

Inline assembler is supported with the asm statement:

$(PRE $(CLASS GRAMMAR)
$(B $(ID AsmStatement) AsmStatement):
    `asm` [function#FunctionAttributes|function, FunctionAttributes]$(SUBSCRIPT opt) `{` [#AsmInstructionList|AsmInstructionList]$(SUBSCRIPT opt) `}`

$(B $(ID AsmInstructionList) AsmInstructionList):
    [iasm#AsmInstruction|iasm, AsmInstruction] `;`
    [iasm#AsmInstruction|iasm, AsmInstruction] `;` AsmInstructionList

)

An asm statement enables the direct use of assembly language instructions.
This makes it easy to obtain direct access to special CPU features without
resorting to an external assembler. The D compiler will take care of the
function calling conventions, stack setup, etc.

        The format of the instructions is, of course, highly dependent
        on the native instruction set of the target CPU, and so is
        $(LINK2 spec/iasm, Inline Assembler).
        But, the format will follow the following
        conventions:

        $(LIST
        * It must use the same tokens as the D language uses.
        * The comment form must match the D language comments.
        * Asm instructions are terminated by a ;, not by an
        end of line.
        
)

        These rules exist to ensure that D source code can be tokenized
        independently of syntactic or semantic analysis.

        For example, for the Intel Pentium:

---
int x = 3;
asm
{
    mov EAX,x; // load x and put it in register EAX
}

---

Inline assembler can be used to access hardware directly:

---
int gethardware()
{
    asm
    {
        mov EAX, dword ptr 0x1234;
    }
}

---

For some D implementations, such as a translator from D to C, an inline
assembler makes no sense, and need not be implemented. The version statement can
be used to account for this:

---
version (D_InlineAsm_X86)
{
    asm
    {
        ...
    }
}
else
{
    /* ... some workaround ... */
}

---

        Semantically consecutive $(I AsmStatement)s shall not have
        any other instructions (such as register save or restores) inserted
        between them by the compiler.
        

$(H2 $(ID pragma-statement)Pragma Statement)

See [pragma#PragmaStatement|pragma, PragmaStatement].

$(H2 $(ID mixin-statement)Mixin Statement)

$(PRE $(CLASS GRAMMAR)
$(B $(ID MixinStatement) MixinStatement):
    `mixin` `(` [expression#ArgumentList|expression, ArgumentList] `)` `;`

)

    Each [expression#AssignExpression|expression, AssignExpression] in the $(I ArgumentList) is
        evaluated at compile time, and the result must be representable
        as a string.
        The resulting strings are concatenated to form a string.
        The text contents of the string must be compilable as a valid
        [#StatementList|StatementList], and is compiled as such.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
import std.stdio;

void main()
{
    int i = 0;
    mixin("
        int x = 3;
        for (; i &lt; 3; i++)
            writeln(x + i, i);
        ");    // ok

    enum s = "int y;";
    mixin(s);  // ok
    y = 4;     // ok, mixin declared y

    string t = "y = 3;";
    //mixin(t);  // error, t is not evaluatable at compile time
    //mixin("y =") 4; // error, string must be complete statement

    mixin("y =" ~ "4;");  // ok
    mixin("y =", 2+2, ";");  // ok
}

---

)

expression, Expressions, arrays, Arrays




Link_References:
	ACC = Associated C Compiler
+/
module statement.dd;