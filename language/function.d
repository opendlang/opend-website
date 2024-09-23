// just docs: Functions
/++





$(H2 $(ID grammar) Function Declarations)

$(PRE $(CLASS GRAMMAR)
$(B $(ID FuncDeclaration) FuncDeclaration):
    [declaration#StorageClasses|declaration, StorageClasses]$(SUBSCRIPT opt) [type#BasicType|type, BasicType] [#FuncDeclarator|FuncDeclarator] [#FunctionBody|FunctionBody]
    [#AutoFuncDeclaration|AutoFuncDeclaration]

$(B $(ID AutoFuncDeclaration) AutoFuncDeclaration):
    [declaration#StorageClasses|declaration, StorageClasses] $(LINK2 lex#Identifier, Identifier) [#FuncDeclaratorSuffix|FuncDeclaratorSuffix] [#FunctionBody|FunctionBody]

$(B $(ID FuncDeclarator) FuncDeclarator):
    [type#TypeSuffixes|type, TypeSuffixes]$(SUBSCRIPT opt) $(LINK2 lex#Identifier, Identifier) [#FuncDeclaratorSuffix|FuncDeclaratorSuffix]

$(B $(ID FuncDeclaratorSuffix) FuncDeclaratorSuffix):
    [#Parameters|Parameters] [#MemberFunctionAttributes|MemberFunctionAttributes]$(SUBSCRIPT opt)
    [template#TemplateParameters|template, TemplateParameters] [#Parameters|Parameters] [#MemberFunctionAttributes|MemberFunctionAttributes]$(SUBSCRIPT opt) [template#Constraint|template, Constraint]$(SUBSCRIPT opt)

)

$(LIST
* A <em>FuncDeclaration</em> with a [#FunctionBody|FunctionBody] is called a <em>function definition</em>.
* A <em>FuncDeclaration</em> with <em>TemplateParameters</em> defines a
          $(LINK2 spec/template#function-templates,function template).



)
$(H3 Function Parameters)

$(PRE $(CLASS GRAMMAR)
$(B $(ID Parameters) Parameters):
    `(` [#ParameterList|ParameterList]$(SUBSCRIPT opt) `)`

$(B $(ID ParameterList) ParameterList):
    [#Parameter|Parameter]
    [#Parameter|Parameter] `,` ParameterList$(SUBSCRIPT opt)
    [#VariadicArgumentsAttributes|VariadicArgumentsAttributes]$(SUBSCRIPT opt) `...`

$(B $(ID Parameter) Parameter):
    [#ParameterAttributes|ParameterAttributes]$(SUBSCRIPT opt) [type#BasicType|type, BasicType] [declaration#Declarator|declaration, Declarator]
    [#ParameterAttributes|ParameterAttributes]$(SUBSCRIPT opt) [type#BasicType|type, BasicType] [declaration#Declarator|declaration, Declarator] `...`
    [#ParameterAttributes|ParameterAttributes]$(SUBSCRIPT opt) [type#BasicType|type, BasicType] [declaration#Declarator|declaration, Declarator] `=` [expression#AssignExpression|expression, AssignExpression]
    [#ParameterAttributes|ParameterAttributes]$(SUBSCRIPT opt) [type#Type|type, Type]
    [#ParameterAttributes|ParameterAttributes]$(SUBSCRIPT opt) [type#Type|type, Type] `...`
    [#ParameterAttributes|ParameterAttributes]$(SUBSCRIPT opt) [type#Type|type, Type] `=` [expression#AssignExpression|expression, AssignExpression]

$(B $(ID ParameterAttributes) ParameterAttributes):
    [#ParameterStorageClass|ParameterStorageClass]
    [attribute#UserDefinedAttribute|attribute, UserDefinedAttribute]
    ParameterAttributes [#ParameterStorageClass|ParameterStorageClass]
    ParameterAttributes [attribute#UserDefinedAttribute|attribute, UserDefinedAttribute]

$(B $(ID ParameterStorageClass) ParameterStorageClass):
    `auto`
    [type#TypeCtor|type, TypeCtor]
    `final`
    `in`
    `lazy`
    `out`
    `ref`
    `return`
    `scope`

$(B $(ID VariadicArgumentsAttributes) VariadicArgumentsAttributes):
    [#VariadicArgumentsAttribute|VariadicArgumentsAttribute]
    [#VariadicArgumentsAttribute|VariadicArgumentsAttribute] VariadicArgumentsAttributes

$(B $(ID VariadicArgumentsAttribute) VariadicArgumentsAttribute):
    `const`
    `immutable`
    `return`
    `scope`
    `shared`

)

Note: In D2, declaring a parameter `final` is a semantic error, but not a parse error.

See also: [#param-storage|parameter storage classes].

$(H3 Function Attributes)

$(PRE $(CLASS GRAMMAR)
$(B $(ID FunctionAttributes) FunctionAttributes):
    [#FunctionAttribute|FunctionAttribute]
    [#FunctionAttribute|FunctionAttribute] FunctionAttributes

$(B $(ID FunctionAttribute) FunctionAttribute):
    [attribute#FunctionAttributeKwd|attribute, FunctionAttributeKwd]
    [attribute#Property|attribute, Property]
    [attribute#AtAttribute|attribute, AtAttribute]

$(B $(ID MemberFunctionAttributes) MemberFunctionAttributes):
    [#MemberFunctionAttribute|MemberFunctionAttribute]
    [#MemberFunctionAttribute|MemberFunctionAttribute] MemberFunctionAttributes

$(B $(ID MemberFunctionAttribute) MemberFunctionAttribute):
    `const`
    `immutable`
    `inout`
    `return`
    `scope`
    `shared`
    [#FunctionAttribute|FunctionAttribute]

)

$(H3 $(ID function-bodies) Function Bodies)

$(PRE $(CLASS GRAMMAR)
$(B $(ID FunctionBody) FunctionBody):
    [#SpecifiedFunctionBody|SpecifiedFunctionBody]
    [#ShortenedFunctionBody|ShortenedFunctionBody]
    [#MissingFunctionBody|MissingFunctionBody]

$(B $(ID SpecifiedFunctionBody) SpecifiedFunctionBody):
    `do`$(SUBSCRIPT opt) [statement#BlockStatement|statement, BlockStatement]
    [#FunctionContracts|FunctionContracts]$(SUBSCRIPT opt) [#InOutContractExpression|InOutContractExpression] `do`$(SUBSCRIPT opt) [statement#BlockStatement|statement, BlockStatement]
    [#FunctionContracts|FunctionContracts]$(SUBSCRIPT opt) [#InOutStatement|InOutStatement] `do` [statement#BlockStatement|statement, BlockStatement]

$(B $(ID ShortenedFunctionBody) ShortenedFunctionBody):
    [#InOutContractExpressions|InOutContractExpressions]$(SUBSCRIPT opt) `=&gt;` [expression#AssignExpression|expression, AssignExpression] `;`

)

        Examples:

---
int hasSpecifiedBody() { return 1; }
int hasShortenedBody() =&gt; 1; // equivalent

---

$(ID FunctionLiteralBody)FunctionLiteralBody
        The <em>ShortenedFunctionBody</em> form implies a
        $(LINK2 spec/statement#ReturnStatement,return statement).
        This syntax also applies for $(LINK2 spec/expression#function_literals,function literals).


$(H3 $(ID function-declarations) Functions without Bodies)

$(PRE $(CLASS GRAMMAR)
$(B $(ID MissingFunctionBody) MissingFunctionBody):
    `;`
    [#FunctionContracts|FunctionContracts]$(SUBSCRIPT opt) [#InOutContractExpression|InOutContractExpression] `;`
    [#FunctionContracts|FunctionContracts]$(SUBSCRIPT opt) [#InOutStatement|InOutStatement]

)

    Functions without bodies:

---
int foo();

---

    that are not declared as `abstract` are expected to have their implementations
    elsewhere, and that implementation will be provided at the link step.
    This enables an implementation of a function to be completely hidden from the user
    of it, and the implementation may be in another language such as C, assembler, etc.
    


$(H2 $(ID contracts) Function Contracts)

$(PRE $(CLASS GRAMMAR)
$(B $(ID FunctionContracts) FunctionContracts):
    [#FunctionContract|FunctionContract]
    [#FunctionContract|FunctionContract] FunctionContracts

$(B $(ID FunctionContract) FunctionContract):
    [#InOutContractExpression|InOutContractExpression]
    [#InOutStatement|InOutStatement]

$(B $(ID InOutContractExpressions) InOutContractExpressions):
    [#InOutContractExpression|InOutContractExpression]
    [#InOutContractExpression|InOutContractExpression] InOutContractExpressions

$(B $(ID InOutContractExpression) InOutContractExpression):
    [#InContractExpression|InContractExpression]
    [#OutContractExpression|OutContractExpression]

$(B $(ID InOutStatement) InOutStatement):
    [#InStatement|InStatement]
    [#OutStatement|OutStatement]

$(B $(ID InContractExpression) InContractExpression):
    `in (` [expression#AssertArguments|expression, AssertArguments] `)`

$(B $(ID OutContractExpression) OutContractExpression):
    `out ( ;` [expression#AssertArguments|expression, AssertArguments] `)`
    `out (` $(LINK2 lex#Identifier, Identifier) `;` [expression#AssertArguments|expression, AssertArguments] `)`

$(B $(ID InStatement) InStatement):
    `in` [statement#BlockStatement|statement, BlockStatement]

$(B $(ID OutStatement) OutStatement):
    `out` [statement#BlockStatement|statement, BlockStatement]
    `out` `(` $(LINK2 lex#Identifier, Identifier) `)` [statement#BlockStatement|statement, BlockStatement]

)

        Function Contracts specify the preconditions and postconditions of a function.
        They are used in $(LINK2 contracts.html, Contract Programming).
        

        Preconditions and postconditions do not affect the type of the function.

    $(H3 $(ID preconditions) Preconditions)

        An [#InContractExpression|InContractExpression] is a precondition.

        The first [expression#AssignExpression|expression, AssignExpression] of the [expression#AssertArguments|expression, AssertArguments]
        must evaluate to true. If it does not, the precondition has failed.

        The second $(I AssignExpression), if present, must be implicitly convertible to type `const(char)[]`.
        

        An [#InStatement|InStatement] is also a precondition. Any [expression#AssertExpression|expression, AssertExpression] appearing
        in an $(I InStatement) will be an $(I InContractExpression).
        

        Preconditions must semantically be satisfied before the function starts executing.
        If it is not, the program enters an $(I Invalid State).
        

        $(WARNING Whether the preconditions are actually run or not is implementation defined.
        This is usually selectable with a compiler switch.
        Its behavior upon precondition failure is also usually selectable with a compiler switch.
        One option is to throw an `AssertError` with a message consisting of the optional second
        $(I AssignExpression).
        )

        $(TIP Use preconditions to validate that input arguments have values that are
        expected by the function.)

        $(TIP Since preconditions may or may not be actually checked at runtime, avoid
        using preconditions that have side effects.)

        The expression form is:

---
in (expression)
in (expression, "failure string")
{
    ...function body...
}

---

        The block statement form is:

---
in
{
    ...contract preconditions...
}
do
{
    ...function body...
}

---


    $(H3 $(ID postconditions) Postconditions)

        An [#OutContractExpression|OutContractExpression] is a postcondition.

        The first [expression#AssignExpression|expression, AssignExpression] of the [expression#AssertArguments|expression, AssertArguments]
        must evaluate to true. If it does not, the postcondition has failed.

        The second $(I AssignExpression), if present, must be implicitly convertible to type `const(char)[]`.
        

        An [#OutStatement|OutStatement] is also a postcondition. Any [expression#AssertExpression|expression, AssertExpression] appearing
        in an $(I OutStatement) will be an $(I OutContractExpression).
        

        Postconditions must semantically be satisfied after the function finishes executing.
        If it is not, the program enters an $(I Invalid State).
        

        $(WARNING Whether the postconditions are actually run or not is implementation defined.
        This is usually selectable with a compiler switch.
        Its behavior upon postcondition failure is also usually selectable with a compiler switch.
        One option is to throw an `AssertError` with a message consisting of the optional second
        $(I AssignExpression).
        )

        $(TIP Use postconditions to validate that the input arguments and return value have values that are
        expected by the function.)

        $(TIP Since postconditions may or may not be actually checked at runtime, avoid
        using postconditions that have side effects.)

        The expression form is:

---
out (identifier; expression)
out (identifier; expression, "failure string")
out (; expression)
out (; expression, "failure string")
{
    ...function body...
}

---

        The block statement form is:

---
out
{
    ...contract postconditions...
}
out (identifier)
{
    ...contract postconditions...
}
do
{
    ...function body...
}

---

        The optional identifier in either type of postcondition is set to the return value
        of the function, and can be accessed from within the postcondition.

    $(H3 Example)

---
int fun(ref int a, int b)
in (a &gt; 0)
in (b &gt;= 0, "b cannot be negative!")
out (r; r &gt; 0, "return must be positive")
out (; a != 0)
{
    // function body
}

---

---
int fun(ref int a, int b)
in
{
    assert(a &gt; 0);
    assert(b &gt;= 0, "b cannot be negative!");
}
out (r)
{
    assert(r &gt; 0, "return must be positive");
    assert(a != 0);
}
do
{
    // function body
}

---

        The two functions are identical semantically.

    $(H3 $(ID in_out_inheritance) In)

        If a function in a derived class overrides a function from its
        super class, then only the preconditions of one of the
        function and its overridden functions
        must be satisfied.
        Overriding
        functions then becomes a process of $(I loosening) the preconditions.
        

        A function without preconditions means its precondition is always
        satisfied.
        Therefore if any
        function in an inheritance hierarchy has no preconditions,
        then any preconditions on functions overriding it have no meaningful
        effect.
        

        Conversely, all of the postconditions of the function and its
        overridden functions must to be satisfied.
        Adding overriding functions then becomes a processes of $(I tightening) the
        postconditions.
        


$(H2 $(ID function-return-values) Function Return Values)

        At least one $(LINK2 spec/statement#return-statement,return statement)
        is required if the function specifies a return type that is not void,
        unless:
        $(LIST
        * the function executes an infinite loop
        * the function executes an `assert(0)` statement
        * the function evaluates an expression of type
            $(LINK2 spec/type#noreturn,`noreturn`)
        * the function contains inline assembler code
        
)

        Function return values not marked as [#ref-functions|`ref`]
        are considered to be rvalues.
        This means they cannot be passed by reference to other functions.
        

$(H2 $(ID pure-functions) Pure Functions)

        Pure functions are annotated with the `pure` attribute.
        Pure functions cannot directly access global or static
        mutable state.
        Pure functions can only call pure functions.

        Pure functions can:
        $(LIST
        * Modify the local state of the function.
        * Throw exceptions.
        
)
        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
int x;
immutable int y;

pure int foo(int i)
{
    i++;     // ok, modifying local state
    //x = i; // error, modifying global state
    //i = x; // error, reading mutable global state
    i = y;   // ok, reading immutable global state
    throw new Exception("failed"); // ok
}

---
        
)

        A pure function can override an impure function,
            but cannot be overridden by an impure function.
            I.e. it is covariant with an impure function.
        

$(H3 $(ID weak-purity) Strong vs Weak Purity)

        A $(I weakly pure function) has parameters with mutable indirections.
            Program state can be modified transitively through the matching
            argument.
        

            $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
pure size_t foo(int[] arr)
{
    arr[] += 1;
    return arr.length;
}
int[] a = [1, 2, 3];
foo(a);
assert(a == [2, 3, 4]);

---
            
)

        A $(I strongly pure function) has no parameters with mutable indirections
            and cannot modify any program state external to the function.
        

            $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
struct S { double x; }

pure size_t foo(immutable(int)[] arr, int num, S val)
{
    //arr[num] = 1; // compile error
    num = 2;        // has no side effect on the caller side
    val.x = 3.14;   // ditto
    return arr.length;
}

---
            
)

        A strongly pure function can call a weakly pure function.

$(H3 $(ID pure-special-cases) Special Cases)

        A pure function can:

        $(LIST
        * read and write the floating point exception flags
        * read and write the floating point mode flags, as long as those
        flags are restored to their initial state upon function entry
        
)

        $(PITFALL occurs if these flags are not restored to their
        initial state upon function exit. It is the programmer's responsibility
        to ensure this. Setting these flags is not allowed in `@safe` code.)

$(H4 $(ID pure-debug) Debugging)

        A pure function can perform impure operations in statements that are in a
        [version#ConditionalStatement|version, ConditionalStatement]
        controlled by a [version#DebugCondition|version, DebugCondition].
        

        $(TIP this relaxation of purity checks in <em>DebugCondition</em>s is
        intended solely to make debugging programs easier.)

---
pure int foo(int i)
{
    debug writeln("i = ", i); // ok, impure code allowed in debug statement
    ...
}

---

$(H4 $(ID pure-nested) Nested Functions)

        [#nested|Nested functions] inside a pure function are implicitly marked as pure.

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
pure int foo(int x, immutable int y)
{
    int bar()
    // implicitly marked as pure, to be "weakly pure"
    // since hidden context pointer to foo stack context is mutable
    {
        x = 10;     // can access states in enclosing scope
                    // through the mutable context pointer
        return x;
    }
    pragma(msg, typeof(&amp;bar));  // int delegate() pure

    int baz() immutable
    // qualifies hidden context pointer with immutable,
    // and has no other parameters, therefore "strongly pure"
    {
        //return x; // error, cannot access mutable data
                    // through the immutable context pointer
        return y;   // ok
    }

    // can call pure nested functions
    return bar() + baz();
}

---
        
)

$(H3 $(ID pure-factory-functions) Pure Factory Functions)

        A $(I pure factory function) is a strongly pure function
        that returns a result that has only mutable indirections.
        All mutable
        memory returned by the call cannot be referenced by any other part of the
        program, i.e. it is newly allocated by the function.
        The mutable
        references of the result similarly cannot refer to any object that
        existed before the function call.
        This allows the result to be implicitly cast
        from anything to `immutable` or `const shared`,
        and from `shared` and `const shared` to (unshared) `const`.
        For example:

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
struct List { int payload; List* next; }

pure List* make(int a, int b)
{
    auto result = new List(a, null);
    result.next = new List(b, null);
    return result;
}

void main()
{
    auto list = make(1, 2);
    pragma(msg, typeof(list));       // List*

    immutable ilist = make(1, 2);
    pragma(msg, typeof(ilist));      // immutable List*
    pragma(msg, typeof(ilist.next)); // immutable List*
}

---
        
)

        All references in `make`'s result refer to `List`
        objects created by `make`, and no other part of the program refers to
        any of these objects. Hence the result can initialize an immutable
        variable.

        This does not affect any <em>Exception</em> or <em>Error</em> thrown from the function.
        

$(H3 $(ID pure-optimization) Optimization)

        $(WARNING An implementation may assume that a strongly pure
        function called with arguments that have only immutable indirections (or none)
        that returns a result
        without mutable indirections will have the same effect for all invocations
        with equivalent arguments. It is allowed to memoize the result of the
        function under the assumption that equivalent arguments always produce
        equivalent results.)

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
int a(int) pure; // no mutable indirections
int b(const Object) pure; // depends on argument passed
immutable(Object) c(immutable Object) pure; // always memoizable

void g();

void f(int n, const Object co, immutable Object io)
{
    const int x = a(n);
    g(); // `n` does not change between calls to `a`
    int i = a(n); // same as `i = x`

    const int y = b(co);
    // `co` may have mutable indirection
    g(); // may change fields of `co` through another reference
    i = b(co); // call is not memoizable, result may differ

    const int z = b(io);
    i = b(io); // same as `i = z`
}

---
        
)

                Such a function may still have behavior
        inconsistent with memoization by e.g. using `cast`s or by changing behavior
        depending on the address of its parameters. An implementation is currently
        not required to enforce validity of memoization in all cases.
        
                If a function throws an <em>Exception</em> or an <em>Error</em>, the
        assumptions related to memoization do not carry to the thrown
        exception.

        Pure destructors do not benefit of special elision.


$(H2 $(ID nothrow-functions) Nothrow Functions)

        Nothrow functions can only throw exceptions derived
        from $(LINK2 https://dlang.org/phobos/object.html#.Error, `class Error`).
        

        Nothrow functions are covariant with throwing ones.

$(H2 $(ID ref-functions) Ref Functions)

        A `ref` function returns by reference (instead of by value).
        The return value of a `ref` function must be an lvalue
        (whereas the return value of a non-`ref` function can be an rvalue, too).
        An expression formed by calling a `ref` function is an lvalue
        (whereas an expression formed by calling a non-`ref` function is an rvalue).
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
int *p;

ref int foo()
{
    p = new int(2);
    return *p;
}

void main()
{
    int i = foo();
    assert(i == 2);

    foo() = 3;     // reference returns can be lvalues
    assert(*p == 3);
}

---

)

        Returning a reference to an expired function context is not allowed.
        This includes local variables, temporaries and parameters that are part
        of an expired function context.
        

---
ref int sun()
{
    int i;
    return i;  // error, escaping a reference to local variable i
}

---

        A `ref` parameter may not be returned by `ref`, unless it is
        [#return-ref-parameters|`return ref`].
---
ref int moon(ref int i)
{
    return i; // error
}

---


$(H2 $(ID auto-functions) Auto Functions)

    Auto functions have their return type inferred from any
        [statement#ReturnStatement|statement, ReturnStatement]s in the function body.
    

    An auto function is declared without a return type.
        Auto functions can use any valid [declaration#StorageClass|declaration, StorageClass], not just `auto`.
    

    If there are multiple $(I ReturnStatement)s, the types
        of them must be implicitly convertible to a common type.
        If there are no $(I ReturnStatement)s, the return type is inferred
        to be void.

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
auto foo(int x) { return x + 3; }          // inferred to be int
pure bar(int x) { return x; return 2.5; }  // inferred to be double

---
        
)

    Note: Return type inference also triggers
    [#function-attribute-inference|attribute inference].


$(H2 $(ID auto-ref-functions) Auto Ref Functions)

    Auto ref functions can infer their return type just as
        [#auto-functions|auto functions] do.
        In addition, they become [#ref-functions|ref functions]
        if all of these apply:

$(LIST
* All expressions returned from the function are lvalues
* No local variables are returned
* Any parameters returned are reference parameters
* Each returned expression must implicitly convert to an lvalue of the deduced return type

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
auto ref f1(int x)     { return x; }  // value return
auto ref f2()          { return 3; }  // value return
auto ref f3(ref int x) { return x; }  // ref return
auto ref f4(out int x) { return x; }  // ref return
auto ref f5()
{
    static int x;
    return x; // ref return
}

---
        
)


)
    The ref-ness of a function is determined from all
        [statement#ReturnStatement|statement, ReturnStatement]s in the function body:

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
auto ref f1(ref int x) { return 3; return x; }  // ok, value return
auto ref f2(ref int x) { return x; return 3; }  // ok, value return
auto ref f3(ref int x, ref double y)
{
    return x; return y;
    // The return type is deduced to be double, but cast(double)x is not an lvalue,
    // so f3 has a value return.
}

---
        
)

    Auto ref functions can have an explicit return type.

---
auto ref int bar(ref int x) { return x; }  // ok, ref return
auto ref int foo(double x) { return x; }   // error, cannot convert double to int

---

$(H2 $(ID inout-functions) Inout Functions)

    For extensive information see $(LINK2 spec/const3#inout,`inout` type qualifier).

$(H2 $(ID optional-parenthesis) Optional Parentheses)

    If a function call passes no explicit argument, i.e. it would syntactically use `()`, then these parentheses
    may be omitted, similar to a getter invocation of a
        [#property-functions|property function].
        A [#pseudo-member|UFCS] call can also omit empty parentheses.
        

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
void foo() {}   // no arguments
void fun(int x = 10) {}
void bar(int[] arr) {}

void main()
{
    foo();      // OK
    foo;        // also OK
    fun;        // OK

    int[] arr;
    arr.bar();  // UFCS call
    arr.bar;    // also OK
}

---
        
)

    Due to ambiguity, parentheses are required to call a delegate or a function pointer:

---
void main()
{
    int function() fp;

    assert(fp == 6);    // Error, incompatible types int function() and int
    assert(*fp == 6);   // Error, incompatible types int() and int

    int delegate() dg;
    assert(dg == 6);    // Error, incompatible types int delegate() and int
}

---

    If a function returns a delegate or a function pointer, any parentheses
    apply first to the function call, not the result. Two sets of parentheses are required
    to call the result directly:
    

    $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
int getNum() { return 6; }
int function() getFunc() { return &amp;getNum; }

void main()
{
    int function() fp;

    fp = getFunc;   // implicit call
    assert(fp() == 6);

    fp = getFunc(); // explicit call
    assert(fp() == 6);

    int x = getFunc()();
    assert(x == 6);
}

---
    
)
    $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
struct S
{
    int getNum() { return 6; }
    int delegate() getDel() return { return &amp;getNum; }
}

void main()
{
    S s;
    int delegate() dg;

    dg = s.getDel;   // implicit call
    assert(dg() == 6);

    dg = s.getDel(); // explicit call
    assert(dg() == 6);

    int y = s.getDel()();
    assert(y == 6);
}

---
    
)

$(H2 $(ID property-functions) Property Functions)

    WARNING: The definition and usefulness of property functions is being reviewed, and the implementation
    is currently incomplete.  Using property functions is not recommended until the definition is
    more certain and implementation more mature.

    Properties are functions that can be syntactically treated
    as if they were fields or variables. Properties can be read from or written to.
    A property is read by calling a method or function with no arguments;
    a property is written by calling a method or function with its argument
    being the value it is set to.
    

    Simple getter and setter properties can be written using [#pseudo-member|UFCS].
    These can be enhanced with the additon of the `@property` attribute to the function, which
    adds the following behaviors:
    

    $(LIST
    * `@property` functions cannot be overloaded with non-`@property` functions with the same name.
    * `@property` functions can only have zero, one or two parameters.
    * `@property` functions cannot have variadic parameters.
    * For the expression `typeof(exp)` where `exp` is an `@property` function,
    the type is the return type of the function, rather than the type of the function.
    * For the expression `__traits(compiles, exp)` where `exp` is an `@property` function,
    a further check is made to see if the function can be called.
    * `@property` are mangled differently, meaning that `@property` must be consistently
    used across different compilation units.
    * The ObjectiveC interface recognizes `@property` setter functions as special and modifies
    them accordingly.
    
)

    A simple property would be:


    $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
struct Foo
{
    @property int data() { return m_data; } // read property

    @property int data(int value) { return m_data = value; } // write property

  private:
    int m_data;
}

---
    
)

        To use it:

---
int test()
{
    Foo f;

    f.data = 3;        // same as f.data(3);
    return f.data + 3; // same as return f.data() + 3;
}

---

    The absence of a read method means that the property is write-only.
    The absence of a write method means that the property is read-only.
    Multiple write methods can exist; the correct one is selected using
    the usual function overloading rules.
    

    In all the other respects, these methods are like any other methods.
    They can be static, have different linkages,  have their address taken, etc.
    

    The built in properties `.sizeof`, `.alignof`, and `.mangleof`
    may not be declared as fields or methods in structs, unions, classes or enums.
    

        If a property function has no parameters, it works as a getter.
        If has exactly one parameter, it works as a setter.
        


$(H2 $(ID virtual-functions) Virtual Functions)

        Virtual functions are class member functions that are called indirectly through a
        function pointer table, called a `vtbl[]`, rather than directly.
        Member functions that are virtual can be overridden in a derived class:
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
class A
{
    void foo(int x) {}
}

class B : A
{
    override void foo(int x) {}
    //override void foo() {} // error, no foo() in A
}

void test()
{
    A a = new B();
    a.foo(1);   // calls B.foo(int)
}

---

)

        The `override` attribute is required when overriding a function.
        This is useful for catching errors when a base class's member function
        has its parameters changed, and all derived classes need to have
        their overriding functions updated.

        The $(ID final) `final` method attribute
        prevents a subclass from overriding the method.

        The following are not virtual:
        $(LIST
        * Struct and union member functions
        * `final` member functions
        * $(LINK2 spec/attribute#static,`static`) member functions
        * Member functions which are `private` or `package`
        * Member template functions
        
)

        $(B Example:)

---
class A
{
    int def() { ... }
    final int foo() { ... }
    final private int bar() { ... }
    private int abc() { ... }
}

class B : A
{
    override int def() { ... }  // ok, overrides A.def
    override int foo() { ... }  // error, A.foo is final
    int bar() { ... }  // ok, A.bar is final private, but not virtual
    int abc() { ... }  // ok, A.abc is not virtual, B.abc is virtual
}

void test()
{
    A a = new B;
    a.def();    // calls B.def
    a.foo();    // calls A.foo
    a.bar();    // calls A.bar
    a.abc();    // calls A.abc
}

---

        Member functions with `Objective-C` linkage are virtual even if marked
        with `final` or `static`, and can be overridden.
        

$(H3 $(ID covariance) Covariance)

        An overriding function may be covariant with the overridden function.
        A covariant function has a type that is implicitly convertible to the
        type of the overridden function.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
class A { }
class B : A { }

class Foo
{
    A test() { return null; }
}

class Bar : Foo
{
    // overrides and is covariant with Foo.test()
    override B test() { return null; }
}

---

)

$(H3 $(ID base-methods) Calling Base Class Methods)

        To directly call a member function of a base class `Base`,
        write `Base.` before the function name.
        This avoids dynamic dispatch through a function pointer. For
        example:
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
class B
{
    int foo() { return 1; }
}
class C : B
{
    override int foo() { return 2; }

    void test()
    {
        assert(B.foo() == 1);  // translated to this.B.foo(), and
                               // calls B.foo statically.
        assert(C.foo() == 2);  // calls C.foo statically, even if
                               // the actual instance of 'this' is D.
    }
}
class D : C
{
    override int foo() { return 3; }
}
void main()
{
    auto d = new D();
    assert(d.foo() == 3);    // calls D.foo
    assert(d.B.foo() == 1);  // calls B.foo
    assert(d.C.foo() == 2);  // calls C.foo
    d.test();
}

---

)
        Base class methods can also be called through the
        $(LINK2 spec/expression#super,`super`) reference.

        $(WARNING Normally calling a virtual function implies getting the
        address of the function at runtime by indexing into the class's `vtbl[]`.
        If the implementation can determine that the called virtual function will be statically
        known, such as if it is `final`, it can use a direct call instead.
        )

$(H3 $(ID function-inheritance) Overload Sets and Overriding)

        When doing overload resolution, the functions in the base
        class are not considered, as they are not in the same
        [#overload-sets|Overload Set]:
        

---
class A
{
    int foo(int x) { ... }
    int foo(long y) { ... }
}

class B : A
{
    override int foo(long x) { ... }
}

void test()
{
    B b = new B();
    b.foo(1);  // calls B.foo(long), since A.foo(int) is not considered

    A a = b;
    a.foo(1);  // issues runtime error (instead of calling A.foo(int))
}

---

        To include the base class's functions in the overload resolution
        process, use an [declaration#AliasDeclaration|declaration, AliasDeclaration]:
        

---
class A
{
    int foo(int x) { ... }
    int foo(long y) { ... }
}

class B : A
{
    /* adrdox_highlight{ */alias foo = A.foo;/* }adrdox_highlight */
    override int foo(long x) { ... }
}

void test()
{
    A a = new B();
    a.foo(1);      // calls A.foo(int)
    B b = new B();
    b.foo(1);      // calls A.foo(int)
}

---

        If such an $(I AliasDeclaration) is not used, the derived
        class's functions completely override all the functions of the
        same name in the base class, even if the types of the parameters
        in the base class functions are different.
        It is illegal if, through
        implicit conversions to the base class, those other functions do
        get called:
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
class A
{
    void /* adrdox_highlight{ */set/* }adrdox_highlight */(long i) { }
    void set(int i)  { }
}
class B : A
{
    override void set(long i) { }
}

void test()
{
    A a = new B;
    a.set(3);   // error, use of A.set(int) is hidden by B
                // use 'alias set = A.set;' to introduce base class overload set
}

---

)

$(H3 $(ID override-defaults) Default Values)

        A function parameter's default value is not inherited:

---
class A
{
    void /* adrdox_highlight{ */foo/* }adrdox_highlight */(int x = 5) { ... }
}

class B : A
{
    void foo(int /* adrdox_highlight{ */x = 7/* }adrdox_highlight */) { ... }
}

class C : B
{
    void foo(int /* adrdox_highlight{ */x/* }adrdox_highlight */) { ... }
}

void test()
{
    A a = new A();
    a.foo();       // calls A.foo(5)

    B b = new B();
    b.foo();       // calls B.foo(7)

    C c = new C();
    c.foo();       // error, need an argument for C.foo
}

---

$(H3 $(ID inheriting-attributes) Inherited Attributes)

        An overriding function inherits any unspecified [#FunctionAttributes|FunctionAttributes]
        from the attributes of the overridden function.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
class B
{
    void foo() pure nothrow @safe {}
}
class D : B
{
    override void foo() {}
}
void main()
{
    auto d = new D();
    pragma(msg, typeof(&amp;d.foo));
    // prints "void delegate() pure nothrow @safe" in compile time
}

---

)

$(H3 $(ID override-restrictions) Restrictions)

        The attributes
        $(LINK2 attribute.html#disable, `@disable`) and
        $(LINK2 attribute.html#deprecated, `deprecated`)
        are not allowed on overriding functions.
        

        Rationale: To stop the compilation or to output the deprecation message, the implementation
        must be able to determine the target of the call, which can't be guaranteed
        when it is virtual.
        

---
class B
{
    void foo() {}
}

class D : B
{
    @disable override void foo() {}  // error, can't apply @disable to overriding function
}

---


$(H2 $(ID inline-functions) Inline Functions)

        The compiler makes the decision whether to inline a function or not.
        This decision may be controlled by $(LINK2 pragma.html#inline, `pragma(inline)`).

        $(WARNING         Whether a function is inlined or not is implementation defined, though
        any [expression#FunctionLiteral|expression, FunctionLiteral] should be inlined
        when used in its declaration scope.
        )

$(H2 $(ID function-overloading) Function Overloading)

        $(I Function overloading) occurs when two or more functions in the same scope
        have the same name.
        The function selected is the one that is the $(I best match) to the arguments.
        The matching levels are:
        

        $(NUMBERED_LIST
        * No match
        * Match with implicit conversions
        * Match with qualifier conversion (if the argument type is
        [qualifier-convertible] to the parameter type)
        * Exact match
        
)

        Named arguments are resolved for a candidate according to
        $(LINK2 spec/expression#argument-parameter-matching,Matching Arguments to Parameters).
        If this fails (for example, because the overload does not have a parameter matching a named argument),
        the level is $(I no match). Other than that, named arguments do not affect the matching level.
        

        Each argument (including any `this` reference) is
        compared against the function's corresponding parameter to
        determine the match level for that argument. The match level
        for a function is the $(I worst) match level of each of its
        arguments.

        Literals do not match `ref` or `out` parameters.

        `scope` parameter storage class does not affect function overloading.

        If two or more functions have the same match level,
        then $(ID partial-ordering) $(I partial ordering)
        is used to disambiguate to find the best match.
        Partial ordering finds the most specialized function.
        If neither function is more specialized than the other,
        then it is an ambiguity error.
        Partial ordering is determined for functions $(I f)
        and $(I g) by taking the parameter types of $(I f),
        constructing a list of arguments by taking the default values
        of those types, and attempting to match them against $(I g).
        If it succeeds, then $(I g) is at least as specialized
        as $(I f).
        For example:
        
---
class A { }
class B : A { }
class C : B { }
void foo(A);
void foo(B);

void test()
{
    C c;
    /* Both foo(A) and foo(B) match with implicit conversions (level 2).
     * Applying partial ordering rules,
     * foo(B) cannot be called with an A, and foo(A) can be called
     * with a B. Therefore, foo(B) is more specialized, and is selected.
     */
    foo(c); // calls foo(B)
}

---
        A function with a variadic argument is considered less
        specialized than a function without.
        

        A static member function can be overloaded with a member
        function. The struct, class
        or union of the static member function is inferred from the
        type of the `this` argument.

---
struct S {
    void eggs(int);
    static void eggs(long);
}
S s;
s.eggs(0);  // calls void eggs(int);
S.eggs(0);  // error: need `this`
s.eggs(0L); // calls static void eggs(long);
S.eggs(0L); // calls static void eggs(long);

struct T {
    void bacon(int);
    static void bacon(int);
}
T t;
t.bacon(0);  // error: ambiguous
T.bacon(0);  // error: ambiguous

---

        Rationale:  A static member function that doesn't need
        the `this` parameter does not need to pass it.

$(H3 $(ID overload-sets) Overload Sets)

        Functions declared at the same scope overload against each
        other, and are called an $(I Overload Set).
        An example of an overload set are functions defined
        at module level:
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
module A;
void foo() { }
void foo(long i) { }

---

)

        `A.foo()` and `A.foo(long)` form an overload set.
        A different module can also define another overload set of
        functions with the same name:
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
module B;
class C { }
void foo(C) { }
void foo(int i) { }

---

)

        and A and B can be imported by a third module, C.
        Both overload sets, the `A.foo` overload set and the `B.foo`
        overload set, are found when searching for symbol `foo`.
        An instance of `foo` is selected
        based on it matching in exactly one overload set:
        

---
import A;
import B;

void bar(C c , long i)
{
    foo();    // calls A.foo()
    foo(i);  // calls A.foo(long)
    foo(c);   // calls B.foo(C)
    foo(1,2); // error, does not match any foo
    foo(1);   // error, matches A.foo(long) and B.foo(int)
    A.foo(1); // calls A.foo(long)
}

---

        Even though `B.foo(int)` is a better match than `        A.foo(long)` for `foo(1)`,
        it is an error because the two matches are in
        different overload sets.
        

        Overload sets can be merged with an alias declaration:

---
import A;
import B;

alias foo = A.foo;
alias foo = B.foo;

void bar(C c)
{
    foo();    // calls A.foo()
    foo(1L);  // calls A.foo(long)
    foo(c);   // calls B.foo(C)
    foo(1,2); // error, does not match any foo
    foo(1);   // calls B.foo(int)
    A.foo(1); // calls A.foo(long)
}

---


$(H2 $(ID parameters) Function Parameters)

$(H3 $(ID param-storage) Parameter Storage Classes)

        Parameter storage classes are `in`, `out`, `ref`, `lazy`, `return` and `scope`.
        Parameters can also take the type constructors `const`, `immutable`, `shared` and `inout`.
        

        `in`, `out`, `ref` and `lazy` are mutually exclusive. The first three are used to
        denote input, output and input/output parameters, respectively.
        For example:
        

---
int read(in char[] input, ref size_t count, out int errno);

void main()
{
    size_t a = 42;
    int b;
    int r = read("Hello World", a, b);
}

---

        `read` has three parameters. `input` will only be read and no reference to it will be retained.
        `count` may be read and written to, and `errno` will be set to a value from
        within the function.

        The argument `"Hello World"` gets bound to parameter `input`,
        `a` gets bound to `count` and `b` to `errno`.
        

        $(TABLE_ROWS
Parameter Storage Class and Type Constructor Overview
        * + Storage Class
+ Description


        * - $(I none)
- The parameter will be a mutable copy of its argument.


        * - `in`
- The parameter is an input to the function.


        * - `out`
- The argument must be an lvalue, which will be passed by reference and initialized
        upon function entry with the default value (`T.init`) of its type.
        


        * - `ref`
- The parameter is an $(I input/output) parameter, passed by reference.
        


        * - `scope`
-         The parameter must not escape the function call
        (e.g. by being assigned to a global variable).
        Ignored for any parameter that is not a reference type.
        


        * - `return`
- Parameter may be returned or copied to the first parameter,
        but otherwise does not escape from the function.
        Such copies are required not to outlive the argument(s) they were derived from.
        Ignored for parameters with no references.
        See $(LINK2 spec/memory-safe-d#scope-return-params,Scope Parameters).


        * - `lazy`
- argument is evaluated by the called function and not by the caller


        * + Type Constructor
+ Description


        * - `const`
- argument is implicitly converted to a const type

        * - `immutable`
- argument is implicitly converted to an immutable type

        * - `shared`
- argument is implicitly converted to a shared type

        * - `inout`
- argument is implicitly converted to an inout type

        
)

$(H3 $(ID in-params) In Parameters)

        $(B Note: The following requires the `-preview=in` switch, available in
        $(LINK2 changelog/2.094.0.html#preview-in, v2.094.0) or higher.
        When not in use, `in` is equivalent to `const`.)
        The parameter is an input to the function. Input parameters behave as if they have
        the `const scope` storage classes. Input parameters may also be passed by reference by the compiler.
        Unlike `ref` parameters, `in` parameters can bind to both lvalues and rvalues
        (such as literals).
        Types that would trigger a side effect if passed by value (such as types with copy constructor,
        postblit, or destructor), and types which cannot be copied
        (e.g. if their copy constructor is marked as `@disable`) will always be passed by reference.
        Dynamic arrays, classes, associative arrays, function pointers, and delegates
        will always be passed by value.
        $(WARNING If the type of the parameter does not fall in one of those categories,
        whether or not it is passed by reference is implementation defined, and the backend is free
        to choose the method that will best fit the ABI of the platform.
        )


$(H3 $(ID ref-params) Ref and Out Parameters)

        By default, parameters take rvalue arguments.
        A `ref` parameter takes an lvalue argument, so changes to its value will operate
        on the caller's argument.

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
void inc(ref int x)
{
    x += 1;
}

void seattle()
{
    int z = 3;
    inc(z);
    assert(z == 4);
}

---
        
)

        A `ref` parameter can also be returned by reference, see
        [#return-ref-parameters|Return Ref Parameters.]

        An `out` parameter is similar to a `ref` parameter, except it is initialized
        with `x.init` upon function invocation.

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
void zero(out int x)
{
    assert(x == 0);
}

void two(out int x)
{
    x = 2;
}

void tacoma()
{
    int a = 3;
    zero(a);
    assert(a == 0);

    int y = 3;
    two(y);
    assert(y == 2);
}

---
        
)

        For dynamic array and class object parameters, which are always passed
        by reference, `out` and `ref`
        apply only to the reference and not the contents.
        

$(H3 $(ID lazy-params) Lazy Parameters)

        An argument to a `lazy` parameter is not evaluated before the function is called.
        The argument is only evaluated if/when the parameter is evaluated within the function. Hence,
        a `lazy` argument can be executed 0 or more times. 

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
import std.stdio : writeln;

void main()
{
    int x;
    3.times(writeln(x++));
    writeln("-");
    writeln(x);
}

void times(int n, lazy void exp)
{
    while (n--)
        exp();
}

---

)

        prints to the console:

$(CONSOLE 0
1
2
-
3
)

        A `lazy` parameter cannot be an lvalue.

        The underlying delegate of the `lazy` parameter may be extracted
        by using the `&amp;` operator:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
void test(lazy int dg)
{
    int delegate() dg_ = &amp;dg;
    assert(dg_() == 7);
    assert(dg == dg_());
}

void main()
{
    int a = 7;
    test(a);
}

---

)

        A `lazy` parameter of type `void` can accept an argument
        of any type.

        See Also: [#lazy_variadic_functions|Lazy Variadic Functions]

$(H3 $(ID function-default-args) Default Arguments)

        Function parameter declarations can have default values:

---
void foo(int x, int y = 3)
{
    ...
}
...
foo(4);   // same as foo(4, 3);

---

        Default parameters are resolved and semantically checked in the context of the
        function declaration.
---
module m;
private immutable int b;
pure void g(int a = b) {}

---
---
import m;
int b;
pure void f()
{
    g();  // ok, uses m.b
}

---

        The attributes of the [expression#AssignExpression|expression, AssignExpression] are applied where the default expression
        is used.
---
module m;
int b;
pure void g(int a = b) {}

---
---
import m;
enum int b = 3;
pure void f()
{
    g();  // error, cannot access mutable global `m.b` in pure function
}

---

        See also: function type aliases
        $(LINK2 spec/declaration#alias-function,with default values).


$(H3 $(ID return-ref-parameters) Return Ref Parameters)

        Return ref parameters are used with
        [#ref-functions|ref functions] to ensure that the
        returned reference will not outlive the matching argument's lifetime.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
ref int identity(return ref int x) {
    return x; // pass-through function that does nothing
}

ref int fun() {
    int x;
    return identity(x); // Error: escaping reference to local variable x
}

ref int gun(return ref int x) {
    return identity(x); // OK
}

---

)
        Returning the address of a `ref` variable is also checked in `@safe` code.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
int* pluto(ref int i) @safe
{
    return &amp;i; // error: returning &amp;i escapes a reference to parameter i
}

int* mars(return ref int i) @safe
{
    return &amp;i;  // OK with -preview=dip1000
}

---

)

If a function returns `void`, and the first parameter is `ref` or `out`, then
all subsequent `return ref` parameters are considered as being assigned to
the first parameter for lifetime checking.
The `this` reference parameter to a struct non-static member function is
considered the first parameter.

---
struct S
{
    private int* p;

    void f(return ref int i) scope @safe
    {
        p = &amp;i;
    }
}

void main() @safe
{
    int i;
    S s;
    s.f(i); // OK with -preview=dip1000, lifetime of `s` is shorter than `i`
    *s.p = 2;
    assert(i == 2);
}

---

If there are multiple `return ref` parameters, the lifetime of the return
value is the smallest lifetime of the corresponding arguments.

Neither the type of the `return ref` parameter(s) nor the type of the return
value is considered when determining the lifetime of the return value.

It is not an error if the return type does not contain any indirections.

---
int mercury(return ref int i)
{
    return i; // ok
}

---

Template functions, auto functions, nested functions and $(LINK2 spec/expression#function_literals,lambdas)
 can deduce the `return` attribute.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
@safe:

ref int templateFunction()(ref int i)
{
    return i; // ok
}

ref auto autoFunction(ref int i)
{
    return i; // ok
}

void uranus()
{
    ref int nestedFunction(ref int i)
    {
        return i; // ok
    }
    auto lambdaFunction =
        (ref int i)
        {
            return &amp;i; // ok
        };
}

---

)

$(H4 $(ID struct-return-methods) Struct Return Methods)

        Struct non-static methods can be marked with the `return` attribute to ensure a returned
        reference will not outlive the struct instance.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
struct S
{
    private int x;
    ref int get() return { return x; }
}

ref int escape()
{
    S s;
    return s.get(); // Error: escaping reference to local variable s
}

---

)
        The hidden `this` ref-parameter then becomes `return ref`.

        The `return` attribute can also be used to limit
        the lifetime of the returned value, even when the method is not `ref`:
        

---
struct S
{
    private int i;
    int* get() return @safe =&gt; &amp;i;
}

void f() @safe
{
    int* p;
    {
        S s;
        int *q = s.get(); // OK, q has shorter lifetime than s
        p = s.get(); // error, p has longer lifetime
        p = (new S).get(); // OK, heap allocated S
    }
}

---

$(H3 $(ID scope-parameters) Scope Parameters)

    A `scope` parameter of reference type must not escape the function call
    (e.g. by being assigned to a global variable). It has no effect for non-reference types.
    `scope` escape analysis is only done for `@safe` functions. For other functions `scope`
    semantics must be manually enforced.

---
@safe:

int* gp;
void thorin(scope int*);
void gloin(int*);
int* balin(scope int* q, int* r)
{
     gp = q; // error, q escapes to global gp
     gp = r; // ok

     thorin(q); // ok, q does not escape thorin()
     thorin(r); // ok

     gloin(q); // error, gloin() escapes q
     gloin(r); // ok that gloin() escapes r

     return q; // error, cannot return 'scope' q
     return r; // ok
}

---

    As a `scope` parameter must not escape, the compiler can potentially avoid heap-allocating a
    unique argument to a `scope` parameter. Due to this, passing an array literal, delegate
    literal or a [expression#NewExpression|expression, NewExpression] to a scope parameter may be allowed in a
    `@nogc` context, depending on the compiler implementation.

$(H3 $(ID return-scope-parameters) Return Scope Parameters)

        Parameters marked as `return scope` that contain indirections
        can only escape those indirections via the function's return value.

---
@safe:

int* gp;
void thorin(scope int*);
void gloin(int*);
int* balin(return scope int* p)
{
     gp = p; // error, p escapes to global gp
     thorin(p); // ok, p does not escape thorin()
     gloin(p); // error, gloin() escapes p
     return p; // ok
}

---

        Class references are considered pointers that are subject to `scope`.

---
@safe:

class C { }
C gp;
void thorin(scope C);
void gloin(C);
C balin(return scope C p, scope C q, C r)
{
     gp = p; // error, p escapes to global gp
     gp = q; // error, q escapes to global gp
     gp = r; // ok

     thorin(p); // ok, p does not escape thorin()
     thorin(q); // ok
     thorin(r); // ok

     gloin(p); // error, gloin() escapes p
     gloin(q); // error, gloin() escapes q
     gloin(r); // ok that gloin() escapes r

     return p; // ok
     return q; // error, cannot return 'scope' q
     return r; // ok
}

---

        `return scope` can be applied to the `this` of class and interface member functions.

---
class C
{
    C bofur() return scope { return this; }
}

---

        Template functions, auto functions, nested functions and
        $(LINK2 spec/expression#function_literals,lambdas) can deduce
        the `return scope` attribute.

$(H3 $(ID ref-return-scope-parameters) Ref Return Scope Parameters)

        It is not possible to have both `return ref` and `return scope` semantics
        for the same parameter.
        When a parameter is passed by `ref` and has both the `return` and `scope` storage classes,
        it gets $(LINK2 #return-scope-parameters, `return scope`) semantics if and only if the `return` and `scope`
        keywords appear adjacent to each other, in that order.
        Specifying a `return ref` and `scope` parameter enables returning a reference to a scope pointer.
        In all other cases, the parameter has $(LINK2 #return-ref-parameters, `return ref`) semantics
        and regular $(LINK2 #scope-parameters, `scope`) semantics.

---
U xerxes(       ref return scope V v) // (1) ref and return scope
U sargon(return ref        scope V v) // (2) return ref and scope

struct S
{
    // note: in struct member functions, the implicit `this` parameter
    // is passed by `ref`

    U xerxes() return scope;        // return scope
    U sargon()        scope return; // return ref, `return` comes after `scope`
    U xerxes() return const scope;  // return ref, `return` and `scope` are not adjacent
}

---

Example of combinations of `return scope`, `return ref`, and `scope` semantics:
---
@safe:

int* globalPtr;

struct S
{
    int  val;
    int* ptr;

    this(return scope ref int* p) { ptr = p; }

    // note: `this` is passed by `ref` in structs

    int* retRefA() scope return // return-ref, scope
    {
        globalPtr = this.ptr; // disallowed, `this` is `scope`
        return &amp;this.val; // allowed, `return` means `return ref`
    }

    ref int retRefB() scope return // return-ref, scope
    {
        globalPtr = this.ptr; // disallowed, `this` is `scope`
        return  this.val; // allowed, `return` means `return ref`
    }

    int* retScopeA() return scope // ref, return-scope
    {
        return &amp;this.val; // disallowed, escaping a reference to `this`
        return this.ptr;  // allowed, returning a `return scope` pointer
    }

    ref int retScopeB() return scope // ref, return-scope
    {
        return this.val;  // disallowed, escaping a reference to `this`
        return *this.ptr; // allowed, returning a `return scope` pointer
    }

    ref int* retRefScopeC() scope return // return-ref, scope
    {
        return this.ptr; // allowed, returning a reference to a scope pointer
    }
}

int* retRefA(return ref scope S s)
{
    globalPtr = s.ptr; // disallowed, `s` is `scope`
    return &amp;s.val; // allowed, returning a reference to `return ref s`
}

ref int retRefB(return ref scope S s)
{
    globalPtr = s.ptr; // disallowed, `s` is `scope`
    return s.val;
}

int* retScopeA(ref return scope S s)
{
    return &amp;s.val; // disallowed, escaping a reference to `s`
    return s.ptr;  // allowed, returning a `return scope` pointer
}

ref int retScopeB(ref return scope S s)
{
    return s.val;  // disallowed, escaping a reference to `s`
    return *s.ptr; // allowed, returning a `return scope` pointer
}

ref int* retRefScopeC(return ref scope int* p)
{
    return p; // allowed, returning a reference to a scope pointer
}

---

$(H3 $(ID pure-scope-inference) Inferred `scope` parameters in `pure` functions)

    When a parameter is not marked or inferred `scope`, it may still be `@safe` to assign it a `scope` pointer in a function call.
    The following conditions need to be met:

    $(LIST
    * The function is [#pure-functions|`pure`], hence the argument cannot be assigned to a global variable
    * The function is [#nothrow-functions|`nothrow`], hence the argument cannot be assigned to a thrown `Exception` object
    * None of the other parameters have mutable indirections, hence the argument cannot be assigned to a longer-lived variable
    
)

    Then, the parameter is still treated as `scope` or `return scope` depending on the return type of the function:
    $(LIST
    * If the function returns by `ref` or has a return type that contains pointers, the argument could be returned, so it is treated as `return scope`
    * Otherwise, the argument cannot escape the function, so it is treated as `scope`
    
)

---
@safe:

int dereference(int* x) pure nothrow;
int* identity(int* x) pure nothrow;
int* identityThrow(int* x) pure;
void assignToRef(int* x, ref int* escapeHatch) pure nothrow;
void assignToPtr(int* x, int** escapeHatch) pure nothrow;
void cannotAssignTo(int* x, const ref int* noEscapeHatch) pure nothrow;

int* globalPtr;

int* test(scope int* ptr)
{
    int result = dereference(ptr); // allowed, treated as `scope`
    int* ptr2 = identity(ptr); // allowed, treated as `return scope`
    int* ptr3 = identityThrow(ptr); // not allowed, can throw an `Exception`
    assignToRef(ptr, globalPtr); // not allowed, mutable second parameter
    assignToPtr(ptr, &amp;globalPtr); // not allowed, mutable second parameter
    cannotAssignTo(ptr, globalPtr); // allowed

    return ptr2; // not allowed, ptr2 is inferred `scope` now
}

---

$(H3 $(ID udas-parameters) User-Defined Attributes for Parameters)

See also: $(GLINK2_ALTTEXT attribute, UserDefinedAttribute, User-Defined Attributes)

$(H3 $(ID variadic) Variadic Functions)

        $(I Variadic Functions) take a variable number of arguments.
        There are three forms:

        $(NUMBERED_LIST
        * [#c_style_variadic_functions|C-style variadic functions]
        * [#d_style_variadic_functions|Variadic functions with type info]
        * [#typesafe_variadic_functions|Typesafe variadic functions]
        
)


$(H4 $(ID c_style_variadic_functions) C-style Variadic Functions)

        A C-style variadic function is declared with
        a parameter `...` as the last function parameter.
        It has non-D linkage, such as `extern (C)`.

        To access the variadic arguments,
        import the standard library
        module $(LINK2 phobos/core_stdc_stdarg.html, `core.stdc.stdarg`).
        

---
import core.stdc.stdarg;

extern (C) void dry(int x, int y, ...); // C-style Variadic Function

void spin()
{
    dry(3, 4);      // ok, no variadic arguments
    dry(3, 4, 6.8); // ok, one variadic argument
    dry(2);         // error, no argument for parameter y
}

---

        There must be at least one non-variadic parameter declared.

---
extern (C) int def(...); // error, must have at least one parameter

---

                C-style variadic functions match the C calling convention for
        variadic functions, and can call C Standard library
        functions like `printf`.
        

---
extern (C) int printf(const(char)*, ...);

void main()
{
    printf("hello world\n");
}

---

        C-style variadic functions cannot be marked as `@safe`.


---
void wash()
{
    rinse(3, 4, 5);   // first variadic argument is 5
}

import core.stdc.stdarg;
extern (C) void rinse(int x, int y, ...)
{
    va_list args;
    va_start(args, y); // y is the last named parameter
    int z;
    va_arg(args, z);   // z is set to 5
    va_end(args);
}

---


$(H4 $(ID d_style_variadic_functions) D-style Variadic Functions)

        D-style variadic functions have D linkage and `...` as the last
        parameter.

        `...` can be the only parameter.

        If there are parameters preceding the `...` parameter, there
        must be a comma separating them from the `...`.

        Note: If the comma is ommitted, it is a [#variadic|TypeSafe Variadic Function].

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
int abc(char c, ...);   // one required parameter: c
int def(...);           // no required parameters
int ghi(int i ...);     // a typesafe variadic function
//int boo(, ...);       // error

---
        
)


        Two hidden arguments are passed to the function:

        $(LIST
        * `void* _argptr`
        * `TypeInfo[] _arguments`
        
)

        `_argptr` is a
        reference to the first of the variadic
        arguments. To access the variadic arguments,
        import $(LINK2 phobos/core_vararg.html, `core.vararg`).
        Use `_argptr` in conjunction with `core.va_arg`:

---
import core.vararg;

void test()
{
    foo(3, 4, 5);   // first variadic argument is 5
}

@system void foo(int x, int y, ...)
{
    int z = va_arg!int(_argptr); // z is set to 5 and _argptr is advanced
                                 // to the next argument
}

---

        `_arguments` gives the number of arguments and the `typeid`
        of each, enabling type safety to be checked at run time.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
import std.stdio;

void main()
{
    Foo f = new Foo();
    Bar b = new Bar();

    writefln("%s", f);
    printargs(1, 2, 3L, 4.5, f, b);
}

class Foo { int x = 3; }
class Bar { long y = 4; }

import core.vararg;

@system void printargs(int x, ...)
{
    writefln("%d arguments", _arguments.length);
    for (int i = 0; i &lt; _arguments.length; i++)
    {
        writeln(_arguments[i]);

        if (_arguments[i] == typeid(int))
        {
            int j = va_arg!(int)(_argptr);
            writefln("\t%d", j);
        }
        else if (_arguments[i] == typeid(long))
        {
            long j = va_arg!(long)(_argptr);
            writefln("\t%d", j);
        }
        else if (_arguments[i] == typeid(double))
        {
            double d = va_arg!(double)(_argptr);
            writefln("\t%g", d);
        }
        else if (_arguments[i] == typeid(Foo))
        {
            Foo f = va_arg!(Foo)(_argptr);
            writefln("\t%s", f);
        }
        else if (_arguments[i] == typeid(Bar))
        {
            Bar b = va_arg!(Bar)(_argptr);
            writefln("\t%s", b);
        }
        else
            assert(0);
    }
}

---

)

        which prints:

---
0x00870FE0
5 arguments
int
        2
long
        3
double
        4.5
Foo
        0x00870FE0
Bar
        0x00870FD0

---

    D-style variadic functions cannot be marked as `@safe`.


$(H4 $(ID typesafe_variadic_functions) Typesafe Variadic Functions)

        A typesafe variadic function has D linkage and a variadic
        parameter declared as either an array or a class.
        The array or class is constructed from the arguments, and
        is passed as an array or class object.
        

        For dynamic arrays:

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
int sum(int[] ar ...) // typesafe variadic function
{
    int s;
    foreach (int x; ar)
        s += x;
    return s;
}

import std.stdio;

void main()
{
    writeln(stan());  // 6
    writeln(ollie()); // 15
}

int stan()
{
    return sum(1, 2, 3) + sum(); // returns 6+0
}

int ollie()
{
    int[3] ii = [4, 5, 6];
    return sum(ii);             // returns 15
}

---
        
)

        For static arrays, the number of arguments must
        match the array dimension.

---
int sum(int[3] ar ...) // typesafe variadic function
{
    int s;
    foreach (int x; ar)
        s += x;
    return s;
}

int frank()
{
    return sum(2, 3);    // error, need 3 values for array
    return sum(1, 2, 3); // returns 6
}

int dave()
{
    int[3] ii = [4, 5, 6];
    int[] jj = ii;
    return sum(ii); // returns 15
    return sum(jj); // error, type mismatch
}

---

        For class objects:

---
int tesla(int x, C c ...)
{
    return x + c.x;
}

class C
{
    int x;
    string s;

    this(int x, string s)
    {
        this.x = x;
        this.s = s;
    }
}

void edison()
{
    C g = new C(3, "abc");
    tesla(1, c);         // ok, since c is an instance of C
    tesla(1, 4, "def");  // ok
    tesla(1, 5);         // error, no matching constructor for C
}

---

        The lifetime of the variadic class object or array
        instance ends at the end of the function.
        

---
C orville(C c ...)
{
    return c;   // error, c instance contents invalid after return
}

int[] wilbur(int[] a ...)
{
    return a;       // error, array contents invalid after return
    return a[0..1]; // error, array contents invalid after return
    return a.dup;   // ok, since copy is made
}

---

        $(WARNING the variadic object or array instance
        may be constructed on the stack.)

        For other types, the argument is passed by value.

---
int neil(int i ...)
{
    return i;
}

void buzz()
{
    neil(3);    // returns 3
    neil(3, 4); // error, too many arguments
    int[] x;
    neil(x);    // error, type mismatch
}

---

$(H4 $(ID lazy_variadic_functions) Lazy Variadic Functions)

        If the variadic parameter of a function is an array of delegates
        with no parameters,
        then each of the arguments whose type does not match that
        of the delegate is converted to a delegate of that type.
        

---
void hal(scope int delegate()[] dgs ...);

void dave()
{
    int delegate() dg;
    hal(1, 3+x, dg, cast(int delegate())null);   // (1)
    hal( { return 1; }, { return 3+x; }, dg, null ); // same as (1)
}

---

        The variadic delegate array differs from using a lazy
        variadic array. With the former each array element access
        would evaluate every array element.
        With the latter, only the element being accessed would be evaluated.

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
import std.stdio;

void main()
{
    int x;
    ming(++x, ++x);

    int y;
    flash(++y, ++y);
}

// lazy variadic array
void ming(lazy int[] arr...)
{
    writeln(arr[0]); // 1
    writeln(arr[1]); // 4
}

// variadic delegate array
void flash(scope int delegate()[] arr ...)
{
    writeln(arr[0]()); // 1
    writeln(arr[1]()); // 2
}

---
        
)

        $(TIP Use `scope` when declaring the array of delegates
        parameter. This will prevent a closure being generated for the delegate,
        as `scope` means the delegate will not escape the function.)

$(ID this-reference)this-reference
$(H3 $(ID hidden-parameters) Hidden Parameters)

        $(LIST
        *             Non-static member functions all have a hidden parameter called the
            $(LINK2 spec/expression#this,`this` reference), which refers to the object for which
            the function is called.
        
        * D-style variadic functions have
            [#d_style_variadic_functions|hidden parameters].
        *             Functions with `Objective-C` linkage have an additional hidden,
            unnamed, parameter which is the selector it was called with.
        
        
)



$(H2 $(ID refscopereturn) Ref Scope Return Cases)


$(H3 $(ID rsr_definitions) Definitions)

    $(TABLE_ROWS
Definitions
    * + Term
+ Description

    * - I
- type that contains no indirections

    * - P
- type that contains indirections

    * - X
- type that may or may not contain indirections

    * - p
- parameter of type P

    * - i
- parameter of type I

    * - ref
- `ref` or `out` parameter


    * - returned
- returned via the `return` statement

    * - escaped
- stored in a global or other memory not in the function's stack frame

    
)

$(H3 $(ID rsr_classification) Classification)

A parameter must be in one of the following states:

    $(TABLE_ROWS
Classification
    * + Term
+ Description

    * - None
-         `p` may be returned or escaped


    * - ReturnScope
-         `p` may be returned but not escaped


    * - Scope
-         `p` may be neither returned nor escaped


    * - Ref
-         `p` may be returned or escaped,
        `ref` may not be returned nor escaped


    * - ReturnRef
-         `p` may be returned or escaped,
        `ref` may be returned but not escaped


    * - RefScope
-         `p` may be neither returned nor escaped,
        `ref` may not be returned nor escaped


    * - ReturnRef-Scope
-         `p` may be neither returned nor escaped,
        `ref` may be returned but not escaped


    * - Ref-ReturnScope
-         `p` may be returned but not escaped,
        `ref` may not be returned nor escaped


    * - ReturnRef-ReturnScope
-         `p` may be returned but not escaped,
        `ref` may be returned but not escaped.
        This isn't expressible with the current syntax
        and so is not allowed.

    
)

$(H3 $(ID rsr_mapping) Mapping Syntax Onto Classification)

    The juxtaposition of `return` immediately preceding `scope` means ReturnScope.
    Otherwise, `return` and `ref` in any position means ReturnRef.

    $(TABLE_ROWS
Mapping
    * + Example
+ Classification
+ Comments

    * - `X foo(P p)`
-             None


    * - `X foo(scope P p)`
-         Scope


    * - `P foo(return scope P p)`
-         ReturnScope


    * - `I foo(return scope P p)`
-         Scope
-         The `return` is dropped because the return type `I` contains no pointers.


    * - `P foo(return P p)`
-         ReturnScope
-         Makes no sense to have `return` without `scope`.


    * - `I foo(return P p)`
-         Scope
-         The `return` is dropped because the return type `I` contains no pointers.



    * - `X foo(ref P p)`
-         Ref


    * - `X foo(ref scope P p)`
-         RefScope


    * - `P foo(ref return scope P p)`
-         Ref-ReturnScope


    * - `P foo(return ref scope P p)`
-         ReturnRef-Scope


    * - `I foo(ref return scope P p)`
-         RefScope


    * - `P foo(ref return P p)`
-         ReturnRef


    * - `I foo(ref return P p)`
-         Ref



    * - `ref X foo(P p)`
-         None


    * - `ref X foo(scope P p)`
-         Scope


    * - `ref X foo(return scope P p)`
-         ReturnScope


    * - `ref X foo(return P p)`
-         ReturnScope
-         Makes no sense to have `return` without `scope`.



    * - `ref X foo(ref P p)`
-         Ref


    * - `ref X foo(ref scope P p)`
-         RefScope


    * - `ref X foo(ref return scope P p)`
-         Ref-ReturnScope


    * - `ref X foo(return ref scope P p)`
-         ReturnRef-Scope


    * - `ref X foo(ref return P p)`
-         ReturnRef


    * - `X foo(I i)`
-         None


    * - `X foo(scope I i)`
-         None


    * - `X foo(return scope I i)`
-         None


    * - `X foo(return I i)`
-         None



    * - `X foo(ref I i)`
-         Ref


    * - `X foo(ref scope I i)`
-         Ref


    * - `X foo(ref return scope I i)`
-         Ref


    * - `P foo(ref return I i)`
-         ReturnRef


    * - `I foo(ref return I i)`
-         Ref



    * - `ref X foo(I i)`
-         None


    * - `ref X foo(scope I i)`
-         None


    * - `ref X foo(return scope I i)`
-         None


    * - `ref X foo(return I i)`
-         None




    * - `ref X foo(ref I i)`
-         Ref


    * - `ref X foo(ref scope I i)`
-         Ref


    * - `ref X foo(ref return scope I i)`
-         ReturnRef


    * - `ref X foo(ref return I i)`
-         ReturnRef


)

$(H3 $(ID rsr_memberfunctions) Member Functions)

    Member functions are rewritten as if the `this` parameter is the first
    parameter of a non-member function,
    

---
struct S {
    X foo();
}

---

    is treated as:

---
X foo(ref S);

---

    and:

---
class C {
    X foo()
}

---

    is treated as:

---
X foo(P)

---

$(H3 $(ID rsr_PandRef) P and ref)

    The rules account for switching between `ref` and P, such as:

---
int* foo(return ref int i) { return &amp;i; }
ref int foo(int* p) { return *p; }

---

$(H3 $(ID rsr_covariance) Covariance)

    Covariance means a parameter with restrictions can be converted to a parameter with
    fewer restrictions. This is deducible from the description of each state.
    

    Note: `ref` is not covariant with non-`ref`, so those entries are omitted from the
    table for simplicity.
    

    $(TABLE_ROWS
Covariance
    * + From\To
+          None
+     ReturnScope
+ Scope

    * - None
-              &#10004;
-            
-         

    * - ReturnScope
-       &#10004;
- &#10004;   
-         

    * - Scope
-             &#10004;
- &#10004;   
- &#10004;

    
)

    $(TABLE_ROWS
Ref Covariance
    * + From\To
+          Ref     
+ ReturnRef
+ RefScope
+ ReturnRef-Scope
+ Ref-ReturnScope

    * - Ref
-               &#10004;
- &#10004; 
-         
-                
-          

    * - ReturnRef
-                 
- &#10004; 
-         
-                
-          

    * - RefScope
-          &#10004;
- &#10004; 
- &#10004;
- &#10004;       
-  &#10004;

    * - ReturnRef-Scope
-           
- &#10004; 
-         
- &#10004;       
-          

    * - Ref-ReturnScope
-   &#10004;
- &#10004; 
-         
-                
-  &#10004;

    
)

    For example, `scope` matches all non-ref parameters, and `ref scope` matches all
    ref parameters.



$(H2 $(ID local-variables)Local Variables)

        Local variables are declared within the scope of a function.
        Function parameters are included.

        A local variable cannot be read without first assigning it a
        value.

        $(WARNING The implementation may not always be able
        to detect these cases.
        )

        The address of or reference to a
        local non-static variable cannot be returned from the function.
        

        A local variable and a label in the same function cannot have the same
        name.
        

        A local variable cannot hide another local
        variable in the same function.
        

        Rationale: whenever
        this is done it often is a
        bug or at least looks like a bug.
        

---
ref double func(int x)
{
    int x;       // error, hides previous definition of x
    double y;
    {
        char y;  // error, hides previous definition of y
        int z;
    }
    {
        wchar z; // Ok, previous z is out of scope
    }
  z:             // error, z is a local variable and a label
    return y;    // error, returning ref to local
}

---


$(H3 $(ID local-static-variables)Local Static Variables)

        Local variables in functions declared as `static`, `shared static`
        or `__gshared` are statically allocated
        rather than being allocated on the stack.
        The lifetime of `__gshared` and `shared static` variables begins
        when the function is first executed and ends when the program ends.
        The lifetime of `static` variables begins when the function is first
        executed within the thread and ends when that thread terminates.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
import std.stdio : writeln;

void foo()
{
    static int n;
    if (++n == 100)
        writeln("called 100 times");
}

---

)

    The initializer for a static variable must be evaluatable at
    compile time.
    There are no static constructors or static destructors
    for static local variables.
    

    Although static variable name visibility follows the usual scoping
    rules, the names of them must be unique within a particular function.
    

---
void main()
{
    { static int x; }
    { static int x; } // error
    { int i; }
    { int i; } // ok
}

---

$(H2 $(ID nested) Nested Functions)

        Functions may be nested within other functions:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
int bar(int a)
{
    int foo(int b)
    {
        int abc() { return 1; }

        return b + abc();
    }
    return foo(a);
}

void test()
{
    int i = bar(3); // i is assigned 4
}

---

)

        Nested functions can be accessed only if the name is in scope.

---
void foo()
{
    void A()
    {
        B(); // error, B() is forward referenced
        C(); // error, C undefined
    }
    void B()
    {
        A(); // ok, in scope
        void C()
        {
            void D()
            {
                A();      // ok
                B();      // ok
                C();      // ok
                D();      // ok
            }
        }
    }
    A(); // ok
    B(); // ok
    C(); // error, C undefined
}

---

        and:

---
int bar(int a)
{
    int foo(int b) { return b + 1; }
    int abc(int b) { return foo(b); }   // ok
    return foo(a);
}

void test()
{
    int i = bar(3);     // ok
    int j = bar.foo(3); // error, bar.foo not visible
}

---

        Nested functions have access to the variables and other symbols
        defined by the lexically enclosing function.
        This access includes both the ability to read and write them.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
int bar(int a)
{
    int c = 3;

    int foo(int b)
    {
        b += c;       // 4 is added to b
        c++;          // bar.c is now 5
        return b + c; // 12 is returned
    }
    c = 4;
    int i = foo(a); // i is set to 12
    return i + c;   // returns 17
}

void test()
{
    int i = bar(3); // i is assigned 17
}

---

)

        This access can span multiple nesting levels:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
int bar(int a)
{
    int c = 3;

    int foo(int b)
    {
        int abc()
        {
            return c;   // access bar.c
        }
        return b + c + abc();
    }
    return foo(3);
}

---

)

        Static nested functions cannot access any stack variables of
        any lexically enclosing function, but can access static variables.
        This is analogous to how static member functions behave.
        

---
int bar(int a)
{
    int c;
    static int d;

    static int foo(int b)
    {
        b = d;          // ok
        b = c;          // error, foo() cannot access frame of bar()
        return b + 1;
    }
    return foo(a);
}

---

        Functions can be nested within member functions:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
struct Foo
{
    int a;

    int bar()
    {
        int c;

        int foo()
        {
            return c + a;
        }
        return 0;
    }
}

---

)

        Nested functions always have the D function linkage type.
        

$(H3 $(ID nested-declaration-order) Declaration Order)

        Unlike module level declarations, declarations within function
        scope are processed in order. This means that two nested functions
        cannot mutually call each other:
        

---
void test()
{
    void foo() { bar(); } // error, bar not defined
    void bar() { foo(); } // ok
}

---

        There are several workarounds for this limitation:

$(LIST

        * Declare the functions to be static members of a nested struct:

---
void test()
{
    static struct S
    {
        static void foo() { bar(); } // ok
        static void bar() { foo(); } // ok
    }

    S.foo();  // compiles (but note the infinite runtime loop)
}

---

        * Declare one or more of the functions to be function templates
        even if they take no specific template arguments:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
void test()
{
    void foo()() { bar(); } // ok (foo is a function template)
    void bar()   { foo(); } // ok
}

---

)

        * Declare the functions inside of a mixin template:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
mixin template T()
{
    void foo() { bar(); } // ok
    void bar() { foo(); } // ok
}

void main()
{
    mixin T!();
}

---

)

        * Use a delegate:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
void test()
{
    void delegate() fp;
    void foo() { fp(); }
    void bar() { foo(); }
    fp = &amp;bar;
}

---

)

    
)

    Nested functions cannot be overloaded.

$(H2 $(ID function-pointers-delegates) Function Pointers)

$(H3 $(ID function-pointers) Function Pointers)

        A function pointer is declared with the `function` keyword:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
void f(int);
void function(int) fp = &amp;f; // fp is a pointer to a function taking an int

---

)
        A function pointer can point to a static nested function:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
int function() fp;  // fp is a pointer to a function returning an int

void test()
{
    static int a = 7;
    static int foo() { return a + 3; }

    fp = &amp;foo;
}

void main()
{
    assert(!fp);
    test();
    int i = fp();
    assert(i == 10);
}

---

)

        $(WARNING Two functions with identical bodies, or two functions
        that compile to identical assembly code, are not guaranteed to have
        distinct function pointer values. The implementation may merge
        functions bodies into one if they compile to identical code.)

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
int abc(int x)   { return x + 1; }
uint def(uint y) { return y + 1; }

int function(int)   fp1 = &amp;abc;
uint function(uint) fp2 = &amp;def;
// Do not rely on fp1 and fp2 being different values; the compiler may merge
// them.

---

)

$(H3 $(ID closures) Delegates &amp; Closures)

        A delegate can be set to a non-static nested function:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
int delegate() dg;

void test()
{
    int a = 7;
    int foo() { return a + 3; }

    dg = &amp;foo;
    int i = dg(); // i is set to 10
}

void main()
{
    test();
    int i = dg(); // ok, test.a is in a closure and still exists
    assert(i == 10);
}

---

)

        The stack variables referenced by a nested function are
        still valid even after the function exits (NOTE this is different
        from D 1.0).
        This combining of the environment and the function is called
        a $(I dynamic closure).
        

        Those referenced stack variables that make up the closure
        are allocated on the GC heap, unless:

$(LIST
* The closure is passed to a `scope` parameter.
* The closure is an initializer for a `scope` variable.
* The closure is assigned to a `scope` variable.


)
$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
@nogc:
void f(scope int delegate());
void g(int delegate());

void main()
{
    int i;
    int h() { return i; }
    h(); // OK
    scope x = &amp;h; // OK
    x(); // OK
    //auto y = &amp;h; // error, can't allocate closure in @nogc function
    f(&amp;h); // OK
    //g(&amp;h); // error

    // delegate literals
    f(() =&gt; i); // OK
    scope d = () =&gt; i; // OK
    d = () =&gt; i + 1; // OK
    f(d);
    //g(() =&gt; i); // error, can't allocate closure in @nogc function
}

---

)

        Note: Returning addresses of stack variables, however, is not
        a closure and is an error.
        

$(H4 $(ID method-delegates) Method Delegates)

        Delegates to non-static nested functions contain two pieces of
        data: the pointer to the stack frame of the lexically enclosing
        function (called the $(I context pointer)) and the address of the
        function. This is analogous to struct/class non-static member
        function delegates consisting of a $(I this) pointer and
        the address of the member function.
        Both forms of delegates are indistinguishable, and are
        the same type.
        
        A delegate can be set to a particular object and method using `&amp;obj.method`:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
struct Foo
{
    int a;
    int get() { return a; }
}

int add1(int delegate() dg)
{
    return dg() + 1;
}

void main()
{
    Foo f = {7};
    int delegate() dg = &amp;f.get; // bind to an instance of Foo and a method
    assert(dg.ptr == &amp;f);
    assert(dg.funcptr == &amp;Foo.get);

    int i = add1(dg);
    assert(i == 8);

    int x = 27;
    int abc() { return x; }

    i = add1(&amp;abc);
    assert(i == 28);
}

---

)

        The `.ptr` property of a delegate will return the
        $(I context pointer) value as a `void*`.
        

        The `.funcptr` property of a delegate will return the
        $(I function pointer) value as a function type.
        

$(H3 $(ID function-delegate-init) Initialization)

        Function pointers are zero-initialized by default.
        They can be initialized to the address of any function (including a function literal).
        Initialization with the address of a function that requires a context pointer
        is not allowed in @safe functions.
        

        $(PITFALL Calling a function pointer that was set to point to
        a function that requires a context pointer.
        )

---
struct S
{
    static int sfunc();
    int member();   // has hidden `this` reference parameter
}

@safe void sun()
{
    int function() fp = &amp;S.sfunc;
    fp(); // Ok
    fp = &amp;S.member; // error
}

@system void moon()
{
    int function() fp = &amp;S.member; // Ok because @system
    fp(); // undefined behavior
}

---

        Delegates are zero-initialized by default.
        They can be initialized by taking the address of a non-static member function,
        but a context pointer must be supplied.
        They can be initialized by taking the address of a non-static nested function
        or function literal,
        where the context pointer will be set to point to the stack frame, closure, or `null`.
        

        Delegates cannot be initialized by taking the address of a global function,
        a static member function, or a static nested function.
        

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
struct S
{
    static int sfunc();
    int member() { return 1; }
}

void main()
{
    S s;
    int delegate() dg = &amp;s.member; // Ok, s supplies context pointer
    assert(dg() == 1);

    //dg = &amp;S.sfunc;  // error
    //dg = &amp;S.member; // error

    int moon() { return 2; }
    dg = &amp;moon;     // Ok
    assert(dg() == 2);

    static int mars() { return 3; }
    //dg = &amp;mars;     // error

    dg = () { return 4; }; // Ok
    assert(dg() == 4);
}

---
        
)
        The last assignment uses a [expression#FunctionLiteral|expression, FunctionLiteral], which
        $(LINK2 spec/expression#lambda-type-inference,is inferred)
        as a delegate.

        Note: Function pointers can be passed to functions taking a delegate argument by passing
        them through the $(REF toDelegate, std,functional) template, which converts any callable
        to a delegate with a `null` context pointer.
        


$(H3 $(ID anonymous) Anonymous Functions and Anonymous Delegates)

        See [expression#FunctionLiteral|expression, FunctionLiteral]s.
        

$(H2 $(ID main) `main()` Function)

        For console programs, `main()` serves as the entry point.
        It gets called after all the $(LINK2 spec/module#staticorder,module initializers)
        are run, and after any $(LINK2 spec/unittest, Unit Tests) are run.
        After it returns, all the module destructors are run.
        `main()` must be declared as follows:
        

        $(PRE $(CLASS GRAMMAR)
        $(B $(ID MainFunction) MainFunction):
            [#MainReturnDecl|MainReturnDecl] `main()` [statement#MainFunctionBody|statement, MainFunctionBody]
            [#MainReturnDecl|MainReturnDecl] `main(string[]` $(LINK2 lex#Identifier, Identifier)`)` [statement#MainFunctionBody|statement, MainFunctionBody]

        $(B $(ID MainReturnDecl) MainReturnDecl):
            `void`
            `int`
            [type#noreturn|type, noreturn]
            [#auto-functions|`auto`]

        $(B $(ID MainFunctionBody) MainFunctionBody):
            [#ShortenedFunctionBody|ShortenedFunctionBody]
            [#SpecifiedFunctionBody|SpecifiedFunctionBody]
        
)

        $(LIST
        * If `main` returns `void`, the OS will receive a zero value on success.
        * If `main` returns `void` or `noreturn`, the OS will receive a non-zero
        value on abnormal termination, such as an uncaught exception.
        * If `main` is declared as `auto`, the inferred return type must be
        one of `void`, `int` and `noreturn`.
        
)

        If the `string[]` parameter is declared, the parameter will hold
        arguments passed to the program by the OS. The first argument is typically
        the executable name, followed by any command-line arguments.

        Note: The runtime can remove any arguments prefixed `--DRT-`.

        Note: The aforementioned return / parameter types may be annotated with `const`,
        `immutable`. They may also be replaced by `enum`'s with matching base types.

        The main function must have D linkage.

        Attributes may be added as needed, e.g. `@safe`, `@nogc`, `nothrow`, etc.

    $(H3 $(ID betterc-main) `extern(C) main()` Function)

        Programs may define an `extern(C) main` function as an alternative to the
        standard [#main|entry point]. This form is required for
        $(LINK2 spec/betterc, Better C) programs.

        A C `main` function must be declared as follows:

        $(PRE $(CLASS GRAMMAR)
        $(B $(ID CMainFunction) CMainFunction):
            `extern (C)` [#MainReturnDecl|MainReturnDecl] `main([#CmainParameters|CmainParameters]$(SUBSCRIPT opt))` [statement#BlockStatement|statement, BlockStatement]

        $(B $(ID CmainParameters) CmainParameters):
            `int` $(LINK2 lex#Identifier, Identifier), `char**` $(LINK2 lex#Identifier, Identifier)
            `int` $(LINK2 lex#Identifier, Identifier), `char**` $(LINK2 lex#Identifier, Identifier), `char**` $(LINK2 lex#Identifier, Identifier)
        
)

        When defined, the first two parameters denote a C-style array (length + pointer)
        that holds the arguments passed to the program by the OS. The third parameter is a POSIX
        extension called `environ` and holds information about the current environment variables.

        Note: The exemption for storage classes / `enum`'s defined for a D `main` function
        also applies to C `main` functions.

        This function takes the place of the C main function and is executed immediately without
        any setup or teardown associated with a D `main` function. Programs reliant on module
        constructors, module destructors, or unittests need to manually perform (de)initialization
        using the appropriate $(LINK2 phobos/core_runtime#Runtime,runtime functions).

        $(WARNING Other system-specific entry points may exist, such as
        `WinMain` and `DllMain` on Windows systems.
        )

        Note: Programs targeting platforms which require a different signature for `main` can use
        a function with $(LINK2 spec/pragma#mangle,explicit mangling):

---
pragma(mangle, "main")
int myMain(int a, int b, int c)
{
    return 0;
}

---

        


$(H2 $(ID function-templates) Function Templates)

        Functions can have compile time arguments in the form of a template.
        See $(LINK2 spec/template#function-templates,function templates).


$(H2 $(ID interpretation) Compile Time Function Execution (CTFE))

    In contexts where a compile time value is required, functions
    can be used to compute those values. This is called $(I Compile Time Function
    Execution), or $(I CTFE).

    These contexts are:

    $(LIST
    * initialization of a static variable or a
        $(LINK2 spec/enum#manifest_constants,manifest constant)
    * static initializers of struct/class members
    * dimension of a $(LINK2 spec/arrays#static-arrays,static array)
    * argument for a $(LINK2 spec/template#template_value_parameter,        template value parameter)
    * $(LINK2 spec/version#staticif,`static if`)
    * $(LINK2 spec/version#staticforeach,`static foreach`)
    * $(LINK2 spec/version#static-assert,`static assert`)
    * $(LINK2 spec/statement#mixin-statement,        `mixin` statement)
    * $(LINK2 spec/pragma, Pragmas)
    * $(LINK2 spec/traits, Traits)
    
)

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
enum eval(alias arg) = arg;

int square(int i)
{
    return i * i;
}

void main()
{
    import std.stdio;

    static j = square(3);      // CTFE
    writeln(j);
    assert(square(4) == 16);       // run time
    static assert(square(3) == 9); // CTFE
    writeln(eval!(square(5))); // CTFE
}

---

)

    The function must have a [#SpecifiedFunctionBody|SpecifiedFunctionBody].

    CTFE is subject to the following restrictions:

    $(NUMBERED_LIST
    * Expressions may not reference any global or local
        static variables.

    * $(LINK2 spec/iasm#asmstatements,AsmStatements) are not permitted

    * Non-portable casts (eg, from `int[]` to `float[]`), including
        casts which depend on endianness, are not permitted.
        Casts between signed and unsigned types are permitted.

    * Reinterpretation of overlapped fields in a union is not permitted.
    
)

    Pointers are permitted in CTFE, provided they are used safely:

    $(LIST
        *         Pointer arithmetic is permitted only on pointers which point to static
        or dynamic array elements.
        A pointer may also point to the first element past the array, although
        such pointers cannot be dereferenced.
        Pointer arithmetic on pointers which are null,
        or which point to a non-array, is not allowed.
        

        *         Ordered comparison (`&lt;`, `&lt;``=`, `&gt;`, `&gt;=`) between two pointers is permitted
        when both pointers point to the same array, or when at least one
        pointer is `null`.
        

        *         Pointer comparisons between discontiguous memory blocks are illegal,
        unless two such comparisons are combined
        using `&amp;&amp;` or || to yield a result which is independent of the
        ordering of memory blocks. Each comparison must consist of two pointer
        expressions compared with `&lt;`, `&lt;``=`, `&gt;`,
        or `&gt;``=`, and may optionally be
        negated with `!`.
        For example, the expression `(p1 &gt; q1 &amp;&amp; p2 &lt;= q2)`
        is permitted when `p1`, `p2` are expressions yielding pointers
        to memory block $(I P), and `q1`, `q2` are expressions yielding
        pointers to memory block $(I Q), even when $(I P) and $(I Q) are
        unrelated memory blocks.
        It returns true if `[p1..p2]` lies inside `[q1..q2]`, and false otherwise.
        Similarly, the expression `(p1 &lt; q1 || p2 &gt; q2)` is true if
        `[p1..p2]` lies outside `[q1..q2]`, and false otherwise.
        

        *         Equality comparisons (==, !=, is, !is) are
        permitted between all pointers, without restriction.
        

        *         Any pointer may be cast to `void*` and from `void*` back to
        its original type. Casting between pointer and non-pointer types is
        illegal.
        
    
)

    The above restrictions apply only to expressions which are
        actually executed. For example:
    
---
static int y = 0;

int countTen(int x)
{
    if (x &gt; 10)
        ++y;    // access static variable
    return x;
}

static assert(countTen(6) == 6);    // OK
static assert(countTen(12) == 12);  // invalid, modifies y.

---
    The `__ctfe` boolean pseudo-variable evaluates to true
        during CTFE but false otherwise.
    

    Note: `__ctfe` can be used to provide
        an alternative execution path to avoid operations which are forbidden
        in CTFE. Every usage of `__ctfe` is statically evaluated
        and has no run-time cost.
    

    Non-recoverable errors (such as assert failures) are illegal.
    

    $(WARNING Executing functions via CTFE can take considerably
    longer than executing it at run time.
    If the function goes into an infinite loop, it may cause the compiler to hang.
    )

    $(WARNING     Functions executed via CTFE can give different results
    from run time when implementation-defined or undefined-behavior occurs.
    )


$(H3 $(ID string-mixins) String Mixins and Compile Time Function Execution)

        All functions that execute in CTFE must also
        be executable at run time. The compile time evaluation of
        a function does the equivalent of running the function at
        run time. The semantics of a function cannot
        depend on compile time values of the function. For example:

---
int foo(string s)
{
    return mixin(s);
}

const int x = foo("1");

---

        $(COMMENT Intentionally not a ... so that it doesn't get a
        paragraph number, because this continues the paragraph above.)

        is illegal, because the runtime code for `foo` cannot be
        generated.

        $(TIP A function template, where `s` is a template argument,
        would be the appropriate
        method to implement this sort of thing.
        )


$(H2 $(ID nogc-functions) No-GC Functions)

        No-GC functions are functions marked with the `@nogc` attribute.
            Those functions do not allocate memory on the GC heap.
            These operations are not allowed in No-GC functions:
        

        $(NUMBERED_LIST
        * $(LINK2 spec/expression#ArrayLiteral,constructing an array) on the heap
        * resizing an array by writing to its `.length` property
        * $(LINK2 spec/expression#CatExpression,array concatenation)
        * $(LINK2 spec/expression#simple_assignment_expressions,array appending)
        * $(LINK2 spec/expression#AssocArrayLiteral,constructing an associative array)
        * $(LINK2 spec/expression#IndexOperation,indexing) an associative array
            Note: because it may throw `RangeError` if the specified key is not present
        * $(LINK2 spec/expression#NewExpression,allocating an object with `new`) on the heap
            Note: `new` declarations of `class types` in function scopes are compatible with
            `@nogc` if used for `scope` variables, as they result in allocations on the stack
        * calling functions that are not `@nogc`, unless the call is
            in a [version#ConditionalStatement|version, ConditionalStatement]
            controlled by a [version#DebugCondition|version, DebugCondition]
        
)

---
@nogc void foo()
{
    auto a = ['a'];    // (1) error, allocates
    a.length = 1;      // (2) error, array resizing allocates
    a = a ~ a;         // (3) error, arrays concatenation allocates
    a ~= 'c';          // (4) error, appending to arrays allocates

    auto aa = ["x":1]; // (5) error, allocates
    aa["abc"];         // (6) error, indexing may allocate and throws

    auto p = new int;  // (7) error, operator new allocates
    scope auto p = new GenericClass(); // (7) Ok
    bar();             // (8) error, bar() may allocate
    debug bar();       // (8) Ok
}
void bar() { }

---

        No-GC functions can only use a closure if it is `scope` -
            see [#closures|Delegates &amp; Closures].
        

---
@nogc int delegate() foo()
{
    int n;              // error, variable n cannot be allocated on heap
    return (){ return n; } // since `n` escapes `foo()`, a closure is required
}

---

        `@nogc` affects the type of the function. A `@nogc`
            function is covariant with a non-`@nogc` function.
        

---
void function() fp;
void function() @nogc gp;  // pointer to @nogc function

void foo();
@nogc void bar();

void test()
{
    fp = &amp;foo; // ok
    fp = &amp;bar; // ok, it's covariant
    gp = &amp;foo; // error, not contravariant
    gp = &amp;bar; // ok
}

---

        $(TIP Since a function marked `@nogc` will not do any GC allocations,
        that implies it will not cause any GC collections to run. However,
        another thread may still allocate with the GC and trigger a collection.
        The recommended way to prevent GC collections from being run is to call
        $(LINK2 https://dlang.org/phobos/core_memory.html#GC.disable, core.memory.GC.disable())
        instead. This will stop collections from being run in any thread until a corresponding
        call to `core.memory.GC.enable()` is run. GC allocations can still be performed
        when `GC.disable()` is in effect.)

$(H2 $(ID function-safety) Function Safety)

$(H3 $(ID safe-functions) Safe Functions)

        Safe functions are marked with the `@safe` attribute.
        `@safe` can be inferred,
        see [#function-attribute-inference|Function Attribute Inference].

        Safe functions have [#safe-interfaces|safe
        interfaces]. An implementation must enforce this by restricting the
        function's body to operations that are known safe.

        The following operations are not allowed in safe
        functions:

        $(LIST
        * No casting from a pointer type to any type with pointers other than `void*`.
        * No casting from any non-pointer type to a pointer type.
        * No pointer arithmetic (including pointer indexing).
        * Cannot access unions that have pointers or references overlapping
        with other types.
        * Cannot access unions that have fields with invariants overlapping
        with other types.
        * Calling any [#system-functions|System Functions].
        * No catching of exceptions that are not derived from
        $(LINK2 https://dlang.org/phobos/object.html#.Exception, `class Exception`).
        * No inline assembler.
        * No explicit casting of mutable objects to immutable.
        * No explicit casting of immutable objects to mutable.
        * No explicit casting of thread local objects to shared.
        * No explicit casting of shared objects to thread local.
        * Cannot access `__gshared` variables.
        * Cannot use `void` initializers for pointers.
        * Cannot use `void` initializers for class or interface references.
        * Cannot use `void` initializers for types that have invariants.
        
)

        When indexing or slicing an array, an out of bounds access
            will cause a runtime error.
        

        Functions nested inside safe functions default to being
        safe functions.
        

        Safe functions are covariant with trusted or system functions.

        $(TIP Mark as many functions `@safe` as practical.)

$(H4 Safe External Functions)

        External functions don't have a function body visible to the compiler:
        
---
@safe extern (C) void play();

---
        and so safety cannot be verified automatically.

        $(TIP Explicitly set an attribute for external functions rather
        than relying on default settings.)

$(H3 $(ID trusted-functions) Trusted Functions)

        Trusted functions are marked with the `@trusted` attribute.

        Like [#safe-functions|safe functions], trusted
        functions have [#safe-interfaces|safe interfaces].
        Unlike safe functions, this is not enforced by restrictions on the
        function body. Instead, it is the responsibility of the programmer to
        ensure that the interface of a trusted function is safe.

        Example:

---
immutable(int)* f(int* p) @trusted
{
    version (none) p[2] = 13;
    // Invalid. p[2] is out of bounds. This line would exhibit undefined
    // behavior.

    version (none) p[1] = 13;
    // Invalid. In this program, p[1] happens to be in-bounds, so the
    // line would not exhibit undefined behavior, but a trusted function
    // is not allowed to rely on this.

    version (none) return cast(immutable) p;
    // Invalid. @safe code still has mutable access and could trigger
    // undefined behavior by overwriting the value later on.

    int* p2 = new int;
    *p2 = 42;
    return cast(immutable) p2;
    // Valid. After f returns, no mutable aliases of p2 can exist.
}

void main() @safe
{
    int[2] a = [10, 20];
    int* mp = &amp;a[0];
    immutable(int)* ip = f(mp);
    assert(a[1] == 20); // Guaranteed. f cannot access a[1].
    assert(ip !is mp); // Guaranteed. f cannot introduce unsafe aliasing.
}

---

        Trusted functions may call safe, trusted, or system functions.
        

        Trusted functions are covariant with safe or system functions.

        $(TIP Trusted functions should be kept small so
        that they are easier to manually verify.
        )

$(H3 $(ID system-functions) System Functions)

        System functions are functions not marked with `@safe` or
        `@trusted`
        and are not nested inside `@safe` functions.
        System functions may be marked with the `@system` attribute.
        A function being system does not mean it actually is unsafe, it just
        means that its safety must be manually verified.
        

        System functions are $(B not) covariant with trusted or safe functions.
        

        System functions can call safe and trusted functions.

        $(TIP When in doubt, mark `extern (C)` and `extern (C++)` functions as
        `@system` when their implementations are not in D, as the D compiler will be
        unable to check them. Most of them are `@safe`, but will need to be manually
        checked.)

        $(TIP The number and size of system functions should be minimized.
        This minimizes the work necessary to manually check for safety.)

$(H3 $(ID safe-interfaces) Safe Interfaces)

        When it is only called with [#safe-values|safe
        values] and [#safe-aliasing|safe aliasing], a
        function has a safe interface when:
        $(NUMBERED_LIST
            * it cannot exhibit
                $(LINK2 spec/glossary#undefined_behavior,undefined behavior),
                and
            * it cannot create unsafe values that are accessible from other
                parts of the program (e.g., via return values, global variables,
                or `ref` parameters), and
            * it cannot introduce unsafe aliasing that is accessible from
                other parts of the program.
        
)

        Functions that meet these requirements may be
        [#safe-functions|`@safe`] or
        [#trusted-functions|`@trusted`]. Function that do not
        meet these requirements can only be
        [#system-functions|`@system`].

        Examples:

        $(LIST
            *                 C's `free` does not have a safe interface:
---
extern (C) @system void free(void* ptr);

---
                because `free(p)` invalidates `p`, making its value unsafe.
                `free` can only be `@system`.
            
            *                 C's `strlen` and `memcpy` do not have safe interfaces:
---
extern (C) @system size_t strlen(char* s);
extern (C) @system void* memcpy(void* dst, void* src, size_t nbytes);

---
                because they iterate pointers based on unverified assumptions
                (`strlen` assumes that `s` is zero-terminated; `memcpy` assumes
                that the memory objects pointed to by `dst` and `src` are at least `nbytes` big). Any function
                that traverses a C string passed as an argument can only be
                `@system`. Any function that trusts a separate parameter for
                array bounds can only be `@system`.
            
            *                 C's `malloc` does have a safe interface:
---
extern (C) @trusted void* malloc(size_t sz);

---
                It does not exhibit undefined behavior for any input. It returns
                either a valid pointer, which is safe, or `null` which is also
                safe. It returns a pointer to a fresh allocation, so it cannot
                introduce any unsafe aliasing.
                Note: The implementation of `malloc` is most likely @system code.
            
            *                 A D version of `memcpy` can have a safe interface:
                $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
@safe void memcpy(E)(E[] src, E[] dst)
{
    import std.math : min;
    foreach (i; 0 .. min(src.length, dst.length))
    {
        dst[i] = src[i];
    }
}

---
                
)
                because the rules for [#safe-values|safe
                values] ensure that the lengths of the arrays are correct.
            
        
)

$(H3 $(ID safe-values) Safe Values)

        For a `bool`, only 0 and 1 are safe values.

        For all other $(LINK2 spec/type#basic-data-types,basic data types), all
        possible bit patterns are safe.

        A pointer is a safe value when it is one of:
        $(NUMBERED_LIST
            * `null`
            * it points to a memory object that is live and
            the pointed to value in that memory object is safe.
        
)
        Examples:
        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
int* n = null; /* n is safe because dereferencing null is a well-defined
    crash. */
int* x = cast(int*) 0xDEADBEEF; /* x is (most likely) unsafe because it
    is not a valid pointer and cannot be dereferenced. */

import core.stdc.stdlib: malloc, free;
int* p1 = cast(int*) malloc(int.sizeof); /* p1 is safe because the
    pointer is valid and *p1 is safe regardless of its actual value. */
free(p1); /* This makes p1 unsafe. */
int** p2 = &amp;p1; /* While it can be dereferenced, p2 is unsafe because p1
    is unsafe. */
p1 = null; /* This makes p1 and p2 safe. */

---
        
)

        A dynamic array is safe when:
        $(NUMBERED_LIST
            * its pointer is safe, and
            * its length is in-bounds with the corresponding memory object,
            and
            * all its elements are safe.
        
)

        Examples:
        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
int[] f() @system
{
    bool b = true; /* b is initialized safe */
    *(cast(ubyte*) &amp;b) = 0xAA; /* b is now unsafe because it's not 0 or 1 */
    int[3] a;
    int[] d1 = a[0 .. 3]; /* d1 is safe. */
    int[] d2 = a.ptr[0 .. 4]; /* d2 is unsafe because it goes beyond a's
        bounds. */
    int*[] d3 = [cast(int*) 0xDEADBEEF]; /* d3 is unsafe because the
        element is unsafe. */
    return d1; /* Up to here, d1 was safe, but its pointer becomes
        invalid when the function returns, so the returned dynamic array
        is unsafe. */
}

---
        
)

        A static array is safe when all its elements are safe. Regardless
        of the element type, a static array with length zero is always safe.

        An associative array is safe when all its keys and elements are
        safe.

        A struct/union instance is safe when:
        $(NUMBERED_LIST
            * the values of its accessible fields are safe, and
            * it does not introduce [#safe-aliasing|unsafe
            aliasing] with unions.
        
)

        Examples:
        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---

void fun()
{
    struct S { int* p; }
    S s1 = S(new int); /* s1 is safe. */
    S s2 = S(cast(int*) 0xDEADBEEF); /* s2 is unsafe, because s2.p is
        unsafe. */

    union U { int* p; size_t x; }
    U u = U(new int); /* Even though both u.p and u.x are safe, u is unsafe
        because of unsafe aliasing. */
}

---
        
)

        A class reference is safe when it is `null` or:
        $(NUMBERED_LIST
            * it refers to a valid class instance of the class type or a
            type derived from the class type, and
            * the values of the instance's accessible fields are safe, and
            * it does not introduce unsafe aliasing with unions.
        
)

        A function pointer is safe when it is `null` or it refers to a valid
        function that has the same or a covariant signature.

        A `delegate` is safe when:
        $(NUMBERED_LIST
            * its `.funcptr` property is `null` or refers to a function that matches
            or is covariant with the delegate type, and
            * its `.ptr` property is `null` or refers to a memory object that is in a form
            expected by the function.
        
)

$(H3 $(ID safe-aliasing) Safe Aliasing)

    When one memory location is accessible with two different types, that
    aliasing is considered safe if:
    $(NUMBERED_LIST
        * both types are `const` or `immutable`; or
        * one of the types is mutable while the other is a `const`-qualified
            $(LINK2 spec/type#basic-data-types,basic data type); or
        * both types are mutable basic data types; or
        * one of the types is a static array type with length zero; or
        * one of the types is a static array type with non-zero length, and
            aliasing of the array's element type and the other type is safe; or
        * both types are pointer types, and aliasing of the target types is
            safe, and the target types have the same size.
    
)

    All other cases of aliasing are considered unsafe.

    Note: Safe aliasing may be exposed to functions with
    [#safe-interfaces|safe interfaces] without affecting their
    guaranteed safety. Unsafe aliasing does not guarantee safety.

    Note: Safe aliasing does not imply that all aliased
    views of the data have [#safe-values|safe values].
    Those must be examined separately for safety.

    Examples:

    $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
void f1(ref ubyte x, ref float y) @safe { x = 0; y = float.init; }
union U1 { ubyte x; float y; } // safe aliasing

void test1()
{
    U1 u1;
    f1(u1.x, u1.y); // Ok
}

void f2(ref int* x, ref int y) @trusted { x = new int; y = 0xDEADBEEF; }
union U2 { int* x; int y; } // unsafe aliasing

void test2()
{
    U2 u2;
    version (none) f1(u2.x, u2.y); // not safe
}

---
    
)

$(H2 $(ID function-attribute-inference) Function Attribute Inference)

        [expression#FunctionLiteral|expression, FunctionLiteral]s,
        [#auto-functions|Auto Functions],
        [#auto-ref-functions|Auto Ref Functions],
        [#nested|nested functions] and
        $(LINK2 spec/template#function-templates,function templates),
        since their function bodies are always present, infer the
        following attributes unless specifically overridden:
        
$(LIST
* [#pure-functions|`pure`]
* [#nothrow-functions|`nothrow`]
* [#safe-functions|`@safe`]
* [#nogc-functions|`@nogc`]
* [#return-ref-parameters|return ref parameters]
* [#scope-parameters|scope parameters]
* [#return-scope-parameters|return scope parameters]
* [#ref-return-scope-parameters|ref return scope parameters]


)
        Attribute inference is not done for other functions, even if the function
        body is present.
        

        The inference is done by determining if the function body follows the
        rules of the particular attribute.
        

        Cyclic functions (i.e. functions that wind up directly or indirectly
        calling themselves) are inferred as being impure, throwing, and `@system`.
        

        If a function attempts to test itself for those attributes, then
        the function is inferred as not having those attributes.
        

        Rationale: Function attribute inference greatly reduces the need for the user to add attributes
        to functions, especially for templates.

$(H2 $(ID pseudo-member) Uniform Function Call Syntax (UFCS))

        A free function can be called like a member function when both:
        $(LIST
        * The member function does not (or cannot) exist for the object expression
        * The free function's first parameter type matches the object expression
        
)
        The object expression can be any type.
        This is called a $(I UFCS function call).

---
void sun(T, int);

void moon(T t)
{
    t.sun(1);
    // If `T` does not have a member function `sun`,
    // `t.sun(1)` is interpreted as if it were written `sun(t, 1)`
}

---

        Rationale: This provides a way to add external functions to a class as if they were
        public [#final|`final`] member functions.
        This enables minimizing the number of functions in a class to only the essentials that
        are needed to take care of the object's private state, without the temptation to add
        a kitchen-sink's worth of member functions.
        It also enables
        [http://www.drdobbs.com/architecture-and-design/component-programming-in-d/240008321,
        function chaining and component programming].
        

        A more complex example:

---
stdin.byLine(KeepTerminator.yes)
    .map!(a =&gt; a.idup)
    .array
    .sort
    .copy(stdout.lockingTextWriter());

---

        is the equivalent of:

---
copy(sort(array(map!(a =&gt; a.idup)(byLine(stdin, KeepTerminator.yes)))), lockingTextWriter(stdout));

---

        UFCS works with `@property` functions:

---
@property prop(X thisObj);
@property prop(X thisObj, int value);

X obj;
obj.prop;      // if X does not have member prop, reinterpret as prop(obj);
obj.prop = 1;  // similarly, reinterpret as prop(obj, 1);

---

        Functions declared in a local scope are not found when searching for a matching
        UFCS function. Neither are other local symbols, although local imports are searched:

---
module a;

void foo(X);
alias boo = foo;

void main()
{
    void bar(X);     // bar declared in local scope
    import b : baz;  // void baz(X);

    X obj;
    obj.foo();    // OK, calls a.foo;
    //obj.bar();  // NG, UFCS does not see nested functions
    obj.baz();    // OK, calls b.baz, because it is declared at the
                  // top level scope of module b

    import b : boo = baz;
    obj.boo();    // OK, calls aliased b.baz instead of a.boo (== a.foo),
                  // because the declared alias name 'boo' in local scope
                  // overrides module scope name
}

---

        Member functions are not found when searching for a matching
        UFCS function.

---
class C
{
    void mfoo(X);           // member function
    static void sbar(X);    // static member function
    import b : ibaz = baz;  // void baz(X);

    void test()
    {
        X obj;
        //obj.mfoo();  // NG, UFCS does not see member functions
        //obj.sbar();  // NG, UFCS does not see static member functions
        obj.ibaz();    // OK, ibaz is an alias of baz which is declared at
                       //     the top level scope of module b
    }
}

---

        Otherwise, UFCS function lookup proceeds normally.

        Rationale: Local function symbols are not considered by UFCS
        to avoid unexpected name conflicts. See below for problematic examples.

---
int front(int[] arr) { return arr[0]; }

void main()
{
    int[] a = [1,2,3];
    auto x = a.front();   // call .front by UFCS

    auto front = x;       // front is now a variable
    auto y = a.front();   // Error, front is not a function
}

class C
{
    int[] arr;
    int front()
    {
        return arr.front(); // Error, C.front is not callable
                            // using argument types (int[])
    }
}

---

const3, Type Qualifiers, operatoroverloading, Operator Overloading




Link_References:
	ACC = Associated C Compiler
+/
module function.dd;