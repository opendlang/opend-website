// just docs: Expressions
/++





$(H2 $(ID expression)Expressions)

$(PRE $(CLASS GRAMMAR)
$(B $(ID Expression) Expression):
    [#CommaExpression|CommaExpression]

)

An expression is a sequence of operators and operands that specifies an evaluation.
The syntax, order of evaluation, and semantics of expressions are as follows.

    Expressions are used to compute values with a resulting type.
        These values can then be assigned,
        tested, or ignored. Expressions can also have side effects.
    

$(H2 $(ID definitions-and-terms) Definitions and Terms)

$(H3 $(ID .define-full-expression) Full Expression)

For any expression
$(I expr), the full expression of $(I expr) is defined as follows. If $(I expr) parses as a
subexpression of another expression $(I expr$(SUBSCRIPT 1)), then the full expression of $(I expr) is the
full expression of $(I expr$(SUBSCRIPT 1)). Otherwise, $(I expr) is its own full expression.

Each expression has a unique full expression. Example:

---
return f() + g() * 2;

---

The full expression of `g() * 2` above is `f() + g() * 2`, but not the
full expression of `f() + g()` because the latter is not parsed as a subexpression.

Note: Although the definition is straightforward, a few subtleties exist related to function literals:

---
return (() =&gt; x + f())() * g();

---

The full expression of `f()` above is `x + f()`, not the expression passed
to `return`. This is because the parent of `x + f()` has function literal type, not expression type.

$(H3 $(ID .define-lvalue) Lvalue)

The following expressions, and no others, are called <em>lvalue expressions</em> or <em>lvalues</em>:
$(NUMBERED_LIST
* [#this|`this`] inside `struct` and `union` member functions;
* a variable, function name, or invocation of a function that returns by reference;
* the result of the `.` [#PostfixExpression|PostfixExpression] or
$(LINK2 spec/module#module_scope_operators,Module Scope Operator)
when the rightmost side of the dot is a variable,
field (direct or `static`), function name, or invocation of a function that returns by reference;
* the result of the following expressions:
$(LIST
* built-in unary operators `+` (when applied to an lvalue), `*`, `++` (prefix only), `--` (prefix only);
* built-in indexing operator `[]` (but not the slicing operator);
* built-in assignment binary operators, i.e. `=`, `+=`, `*=`, `/=`, `%=`, `&amp;=`, `|=`, `^=`, `~=`,
`&lt;&lt;=`, `&gt;&gt;=`, `&gt;&gt;&gt;=`, and `^^=`;
* the [#ConditionalExpression|ConditionalExpression] operator $(I e) `?` $(I e$(SUBSCRIPT 1)) `:` $(I e$(SUBSCRIPT 2)) under the following
circumstances:
$(NUMBERED_LIST
    * $(I e$(SUBSCRIPT 1)) and $(I e$(SUBSCRIPT 2)) are lvalues of the same type; OR
    * One of $(I e$(SUBSCRIPT 1)) and $(I e$(SUBSCRIPT 2)) is an lvalue of type `T` and the other has
    and `alias this` converting it to `ref T`;
)
* $(LINK2 spec/operatoroverloading, Operator Overloading)
if and only if the function called as a result of lowering returns
by reference;
* [#mixin_expressions|`mixin` expressions] if and only if the
compilation of the expression resulting from compiling
the argument(s) to `mixin` is an lvalue;
* `cast(U)` expressions applied to lvalues of type `T` when `T*` is implicitly convertible to `U*`;
* `cast()` and `cast(`$(I qualifier list)`)` when applied to an lvalue.

)
)

$(H3 $(ID .define-rvalue) Rvalue)

Expressions that are not lvalues are <em>rvalues</em>. Rvalues include all literals, special value keywords such as `__FILE__` and `__LINE__`,
`enum` values, and the result of expressions not defined as lvalues above.

The built-in address-of operator (unary `&amp;`) may only be applied to lvalues.

$(H3 $(ID .define-smallest-short-circuit) Smallest Short-Circuit Expression)

Given an expression $(I expr) that is a subexpression of a full
expression $(I fullexpr), the <em>smallest short-circuit expression</em>, if any, is the shortest
subexpression $(I scexpr) of $(I fullexpr) that is an [#AndAndExpression|AndAndExpression] (`&amp;&amp;`) or an
[#OrOrExpression|OrOrExpression] (`||`), such that $(I expr) is a subexpression of $(I scexpr). Example:
---
((f() * 2 &amp;&amp; g()) + 1) || h()

---
The smallest short-circuit expression
of the subexpression `f() * 2` above is `f() * 2 &amp;&amp; g()`. Example:
---
(f() &amp;&amp; g()) + h()

---
The subexpression `h()` above has no smallest short-circuit expression.

$(H2 $(ID order-of-evaluation) Order Of Evaluation)

Built-in prefix unary expressions `++` and `--` are evaluated as if lowered (rewritten) to
[#assignment_operator_expressions|assignments] as follows:

$(TABLE     * + Expression
+ Equivalent

    * - `++expr`
- `((expr) += 1)`

    * - `--expr`
- `((expr) -= 1)`

)
Therefore, the result of prefix `++` and `--` is the lvalue after the side effect has been
effected.

Built-in postfix unary expressions `++` and `--` are evaluated as if lowered (rewritten) to
$(LINK2 spec/expression#function_literals,lambda)
invocations as follows:

$(TABLE     * + Expression
+ Equivalent

    * - `expr++`
- `(ref x){auto t = x; ++x; return t;}(expr)`

    * - `expr--`
- `(ref x){auto t = x; --x; return t;}(expr)`

)
Therefore, the result of postfix
`++` and `--` is an rvalue just before the side effect has been effected.

Binary expressions except for [#AssignExpression|AssignExpression], [#OrOrExpression|OrOrExpression], and
[#AndAndExpression|AndAndExpression] are evaluated in lexical order (left-to-right). Example:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
int i = 2;
i = ++i * i++ + i;
assert(i == 3 * 3 + 4);

---

)

[#OrOrExpression|OrOrExpression] and [#AndAndExpression|AndAndExpression] evaluate their left-hand side argument
first. Then, [#OrOrExpression|OrOrExpression] evaluates its right-hand side if and only if its left-hand
side does not evaluate to nonzero. [#AndAndExpression|AndAndExpression] evaluates its right-hand side if and
only if its left-hand side evaluates to nonzero.

[#ConditionalExpression|ConditionalExpression] evaluates its left-hand side argument
first. Then, if the result is nonzero, the second operand is evaluated. Otherwise, the third operand
is evaluated.

Calls to functions  with `extern(D)` $(LINK2 spec/attribute#linkage,linkage) (which is
the default linkage) are evaluated in the following order: first, if necessary, the address of the
function to call is evaluated (e.g. in the case of a computed function pointer or delegate). Then,
arguments are evaluated left to right. Finally, transfer is passed to the function. Example:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
void function(int a, int b, int c) fun()
{
    writeln("fun() called");
    static void r(int a, int b, int c) { writeln("callee called"); }
    return &amp;r;
}
int f1() { writeln("f1() called"); return 1; }
int f2() { writeln("f2() called"); return 2; }
int f3(int x) { writeln("f3() called"); return x + 3; }
int f4() { writeln("f4() called"); return 4; }

// evaluates fun() then f1() then f2() then f3() then f4()
// after which control is transferred to the callee
fun()(f1(), f3(f2()), f4());

---

)

    $(WARNING     $(NUMBERED_LIST
    * The order of evaluation of the operands of [#AssignExpression|AssignExpression].
    * The order of evaluation of function arguments for functions with linkage other than `extern (D)`.
    
))

    $(TIP Even though the order of evaluation is well-defined, writing code that
    depends on it is rarely recommended.)

$(H2 $(ID temporary-lifetime) Lifetime of Temporaries)

Expressions and statements may create and/or consume rvalues. Such values are called
$(I temporaries) and do not have a name or a visible scope. Their lifetime is managed automatically
as defined in this section.

For each evaluation that yields a temporary value, the lifetime of that temporary begins at the
evaluation point, similarly to creation of a usual named value initialized with an expression.

Termination of lifetime of temporaries does not obey the customary scoping rules and is defined
as follows:

$(LIST
* If:
$(NUMBERED_LIST
* the full expression has a smallest short-circuit expression $(I expr); and
* the temporary is created on the right-hand side of the `&amp;&amp;` or `||` operator; and
* the right-hand side is evaluated,
)
then temporary destructors are evaluated right after the right-hand side
expression has been evaluated and converted to `bool`. Evaluation of destructors proceeds in
reverse order of construction.

* For all other cases, the temporaries generated for the purpose of invoking functions are
deferred to the end of the full expression. The order of destruction is inverse to the order of
construction.
)

If a subexpression of an expression throws an exception, all temporaries created up to the
evaluation of that subexpression will be destroyed per the rules above. No destructor calls will
be issued for temporaries not yet constructed.

Note: An intuition behind these rules is that destructors of temporaries are deferred to the end of full
expression and in reverse order of construction, with the exception that the right-hand side of
`&amp;&amp;` and `||` are considered their own full expressions even when part of larger expressions.

Note: The [#ConditionalExpression|ConditionalExpression] $(I e$(SUBSCRIPT 1) ? e$(SUBSCRIPT 2) : e$(SUBSCRIPT 3)) is not
a special case although it evaluates expressions conditionally: $(I e$(SUBSCRIPT 1)) and one of
$(I e$(SUBSCRIPT 2)) and $(I e$(SUBSCRIPT 3)) may create temporaries. Their destructors are inserted
to the end of the full expression in the reverse order of creation.

Example:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
import std.stdio;

struct S
{
    int x;
    this(int n) { x = n; writefln("S(%s)", x); }
    ~this() { writefln("~S(%s)", x); }
}

void main()
{
    bool b = (S(1) == S(2) || S(3) != S(4)) &amp;&amp; S(5) == S(6);
}

---

)

The output of the code above is:

$(CONSOLE S(1)
S(2)
S(3)
S(4)
~S(4)
~S(3)
S(5)
S(6)
~S(6)
~S(5)
~S(2)
~S(1)
)

First, `S(1)` and `S(2)` are evaluated in lexical order. Per the rules, they will be destroyed at
the end of the full expression and in reverse order. The comparison `S(1) == S(2)` yields
`false`, so the right-hand side of the `||` is evaluated causing `S(3)` and `S(4)` to be evaluated,
also in lexical order. However, their destruction is not deferred to the end of the full
expression. Instead, `S(4)` and then `S(3)` are destroyed at the end of the `||` expression.
Following their destruction, `S(5)` and `S(6)` are constructed in lexical order. Again they are not
destroyed at the end of the full expression, but right at the end of the `&amp;&amp;` expression.
Consequently, the destruction of `S(6)` and `S(5)` is carried before that of `S(2)` and `S(1)`.

$(H2 $(ID comma_expression) Comma Expression)

$(PRE $(CLASS GRAMMAR)
$(B $(ID CommaExpression) CommaExpression):
    [#AssignExpression|AssignExpression]
    CommaExpression `,` [#AssignExpression|AssignExpression]

)

    The left operand of the `,` is evaluated, then the right operand
        is evaluated. The type of the expression is the type of the right
        operand, and the result is the result of the right operand.
        Using the result of comma expressions isn't allowed.
    

$(H2 $(ID assign_expressions) Assign Expressions)

$(PRE $(CLASS GRAMMAR)
$(B $(ID AssignExpression) AssignExpression):
    [#ConditionalExpression|ConditionalExpression]
    [#ConditionalExpression|ConditionalExpression] `=` AssignExpression
    [#ConditionalExpression|ConditionalExpression] `+=` AssignExpression
    [#ConditionalExpression|ConditionalExpression] `-=` AssignExpression
    [#ConditionalExpression|ConditionalExpression] `*=` AssignExpression
    [#ConditionalExpression|ConditionalExpression] `/=` AssignExpression
    [#ConditionalExpression|ConditionalExpression] `%=` AssignExpression
    [#ConditionalExpression|ConditionalExpression] `&amp;=` AssignExpression
    [#ConditionalExpression|ConditionalExpression] `|=` AssignExpression
    [#ConditionalExpression|ConditionalExpression] `^=` AssignExpression
    [#ConditionalExpression|ConditionalExpression] `~=` AssignExpression
    [#ConditionalExpression|ConditionalExpression] `&lt;&lt;=` AssignExpression
    [#ConditionalExpression|ConditionalExpression] `&gt;&gt;=` AssignExpression
    [#ConditionalExpression|ConditionalExpression] `&gt;&gt;&gt;=` AssignExpression
    [#ConditionalExpression|ConditionalExpression] `^^=` AssignExpression

)

    For all assign expressions, the left operand must be a modifiable
    lvalue. The type of the assign expression is the type of the left
    operand, and the result is the value of the left operand after assignment
    occurs. The resulting expression is a modifiable lvalue.
    

    $(PITFALL     If either operand is a reference type and one of the following:
    $(NUMBERED_LIST
    * the operands have partially overlapping storage
    * the operands' storage overlaps exactly but the types are different
    
))

    $(WARNING     If neither operand is a reference type and one of the following:
    $(NUMBERED_LIST
    * the operands have partially overlapping storage
    * the operands' storage overlaps exactly but the types are different
    
))

$(H3 $(ID simple_assignment_expressions) Simple Assignment Expression)

    If the operator is `=` then it is simple assignment.
    

    $(LIST
    * If the left operand is a struct that
    $(LINK2 spec/operatoroverloading#assignment,defines `opAssign`),
    the behaviour is defined by the overloaded function.
    

    * If the left and right operands are of the same struct type, and the struct
    type has a [struct#Postblit|struct, Postblit], then the copy operation is
    as described in $(LINK2 spec/struct#struct-postblit,Struct Postblit).
    

    * If the lvalue is the `.length` property of a dynamic array, the behavior is
    as described in $(LINK2 spec/arrays#resize,Setting Dynamic Array Length).
    

    * If the lvalue is a static array or a slice, the behavior is as
    described in $(LINK2 spec/arrays#array-copying,Array Copying) and
    $(LINK2 spec/arrays#array-setting,Array Setting).
    

    * If the lvalue is a user-defined property, the behavior is as
    described in $(LINK2 spec/function#property-functions,Property Functions).
    
    
)

    Otherwise, the right operand is implicitly converted to the type of the
    left operand, and assigned to it.

$(H3 $(ID assignment_operator_expressions) Assignment Operator Expressions)

    For arguments of built-in types, assignment operator expressions such as

---
a op= b

---

        are semantically equivalent to:

---
a = cast(typeof(a))(a op b)

---

    except that:

    $(LIST
        * operand `a` is only evaluated once,
        * overloading $(I op) uses a different function than overloading $(I op)`=` does, and
        * the left operand of `&gt;&gt;&gt;=` does not undergo $(LINK2 spec/type#integer-promotions,Integer Promotions) before shifting.
    
)

    For user-defined types, assignment operator expressions are
        $(LINK2 spec/operatoroverloading#op-assign,overloaded separately) from
        the binary operators. Still the left operand must be an lvalue.
    

$(H2 $(ID conditional_expressions) Conditional Expressions)

$(PRE $(CLASS GRAMMAR)
$(B $(ID ConditionalExpression) ConditionalExpression):
    [#OrOrExpression|OrOrExpression]
    [#OrOrExpression|OrOrExpression] `?` [#Expression|Expression] `:` ConditionalExpression

)

    The first expression is converted to `bool`, and is evaluated.
    

    If it is `true`, then the second expression is evaluated, and
        its result is the result of the conditional expression.
    

    If it is `false`, then the third expression is evaluated, and
        its result is the result of the conditional expression.
    

    If either the second or third expressions are of type `void`,
        then the resulting type is `void`. Otherwise, the second and third
        expressions are implicitly converted to a common type which becomes
        the result type of the conditional expression.
    

    $(NOTE     Note:         When a conditional expression is the left operand of
        an [#assign_expressions|assign expression],
        parentheses are required for disambiguation:
    
---
bool test;
int a, b, c;
...
test ? a = b : c = 2;   // error
(test ? a = b : c) = 2; // OK

---

    This makes the intent clearer, because the first statement can
        easily be misread as the following code:
    
---
test ? a = b : (c = 2);

---
    )

$(H2 $(ID logical_expressions) Logical Expressions)

<div class="ddoc_see_also">
  <h4>See Also</h4>
  <p class="para">
    [#UnaryExpression|UnaryExpression] for `!expr`.
  </p>
</div>


$(H3 $(ID oror_expressions) OrOr Expressions)

$(PRE $(CLASS GRAMMAR)
$(B $(ID OrOrExpression) OrOrExpression):
    [#AndAndExpression|AndAndExpression]
    OrOrExpression `||` [#AndAndExpression|AndAndExpression]

)

    The result type of an $(I OrOrExpression) is `bool`, unless the right operand
        has type `void`, when the result is type `void`.
    

    The $(I OrOrExpression) evaluates its left operand.
    

    If the left operand, converted to type `bool`, evaluates to
        `true`, then the right operand is not evaluated. If the result type of
        the $(I OrOrExpression) is `bool` then the result of the
        expression is `true`.
    

    If the left operand is `false`, then the right
        operand is evaluated.
        If the result type of
        the $(I OrOrExpression) is `bool` then the result of the
        expression is the right operand converted to type `bool`.
    

$(H3 $(ID andand_expressions) AndAnd Expressions)

$(PRE $(CLASS GRAMMAR)
$(B $(ID AndAndExpression) AndAndExpression):
    [#OrExpression|OrExpression]
    AndAndExpression `&&` [#OrExpression|OrExpression]

)

    The result type of an $(I AndAndExpression) is `bool`, unless the right operand
        has type `void`, when the result is type `void`.
    

    The $(I AndAndExpression) evaluates its left operand.
    

    If the left operand, converted to type `bool`, evaluates to
        `false`, then the right operand is not evaluated. If the result type of
        the $(I AndAndExpression) is `bool` then the result of the
        expression is `false`.
    

    If the left operand is `true`, then the right
        operand is evaluated.
        If the result type of
        the $(I AndAndExpression) is `bool` then the result of the
        expression is the right operand converted to type `bool`.
    

$(H2 $(ID bitwise_expressions) Bitwise Expressions)

    Bit wise expressions perform a
    $(LINK2 https://en.wikipedia.org/wiki/Bitwise_operation, bitwise operation) on their operands.
        Their operands must be integral types.
        First, the $(LINK2 spec/type#usual-arithmetic-conversions,Usual Arithmetic Conversions) are done. Then, the bitwise
        operation is done.
    
    <div class="ddoc_see_also">
  <h4>See Also</h4>
  <p class="para">
    [#ShiftExpression|ShiftExpression], [#ComplementExpression|ComplementExpression]
  </p>
</div>


    $(NOTE     Note: If an <em>OrExpression</em>, <em>XorExpression</em> or <em>AndExpression</em> appears on
        either side of an <em>EqualExpression</em>, <em>IdentityExpression</em> or <em>RelExpression</em>,
        it is a compile error. Instead, disambiguate by using parentheses.
    

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
int x, a, b;
x = a &amp; 5 == b; // error
x = a &amp; 5 is b; // error
x = a &amp; 5 &lt;= b; // error

x = (a &amp; 5) == b; // OK
x = a &amp; (5 == b); // OK

---

)
)

$(H3 $(ID or_expressions) Or Expressions)

$(PRE $(CLASS GRAMMAR)
$(B $(ID OrExpression) OrExpression):
    [#XorExpression|XorExpression]
    OrExpression `|` [#XorExpression|XorExpression]

)

    The operands are OR'd together.

$(H3 $(ID xor_expressions) Xor Expressions)

$(PRE $(CLASS GRAMMAR)
$(B $(ID XorExpression) XorExpression):
    [#AndExpression|AndExpression]
    XorExpression `^` [#AndExpression|AndExpression]

)

    The operands are XOR'd together.

$(H3 $(ID and_expressions) And Expressions)

$(PRE $(CLASS GRAMMAR)
$(B $(ID AndExpression) AndExpression):
    [#CmpExpression|CmpExpression]
    AndExpression `&amp;` [#CmpExpression|CmpExpression]

)

    The operands are AND'd together.

$(H2 $(ID compare_expressions) Compare Expressions)

$(PRE $(CLASS GRAMMAR)
$(B $(ID CmpExpression) CmpExpression):
    [#EqualExpression|EqualExpression]
    [#IdentityExpression|IdentityExpression]
    [#RelExpression|RelExpression]
    [#InExpression|InExpression]
    [#ShiftExpression|ShiftExpression]

)

$(H3 $(ID equality_expressions) Equality Expressions)

$(PRE $(CLASS GRAMMAR)
$(B $(ID EqualExpression) EqualExpression):
    [#ShiftExpression|ShiftExpression] `==` [#ShiftExpression|ShiftExpression]
    [#ShiftExpression|ShiftExpression] `!=` [#ShiftExpression|ShiftExpression]

)

    Equality expressions compare the two operands for equality (`==`)
        or inequality (`!=`).
        The type of the result is `bool`.
    

    Inequality is defined as the logical negation of equality.

    If the operands are integral values, the $(LINK2 spec/type#usual-arithmetic-conversions,Usual Arithmetic Conversions) are applied
        to bring them to a common type before comparison. Equality is defined as the bit patterns
        of the common type match exactly.
    

    If the operands are pointers, equality is defined as the bit patterns of the operands
        match exactly.
    

    For float, double, and real values, the $(LINK2 spec/type#usual-arithmetic-conversions,Usual Arithmetic Conversions) are applied
        to bring them to a common type before comparison.
        The values `-0` and `+0` are considered equal.
        If either or both operands are NaN, then `==` returns false and `!=` returns `true`.
        Otherwise, the bit patterns of the common type are compared for equality.
    

    For static and dynamic arrays, equality is defined as the
        lengths of the arrays
        matching, and all the elements are equal.
    

    <div class="ddoc_deprecated">
  <h4>Deprecated</h4>
  <p class="para">
    For complex numbers, equality is defined as equivalent to:
  </p>
</div>


---
x.re == y.re &amp;&amp; x.im == y.im

---

    $(H4 $(ID class_struct_equality) Class &amp; Struct Equality)

    For struct objects, equality means the result of the
        $(LINK2 https://dlang.org/spec/operatoroverloading.html#equals, `opEquals()` member function).
        If an `opEquals()` is not provided, equality is defined as
        the logical product of all equality
        results of the corresponding object fields.
    

        $(WARNING The contents of any alignment gaps in the struct object.)

        $(TIP If there are overlapping fields, which happens with unions, the default
        equality will compare each of the overlapping fields.
        An `opEquals()` can account for which of the overlapping fields contains valid data.
        An `opEquals()` can override the default behavior of floating point NaN values
        always comparing as unequal.
        Be careful using `memcmp()` to implement `opEquals()` if:)

        $(LIST
        * there are any alignment gaps
        * any fields have an `opEquals()`
        * there are any floating point fields that may contain NaN or `-0` values
        
)

    For class and struct objects, the expression `(a == b)`
        is rewritten as
        `a.opEquals(b)`, and `(a != b)` is rewritten as
        `!a.opEquals(b)`.
    

    For class objects, the `==` and `!=`
        operators are intended to compare the contents of the objects,
        however an appropriate `opEquals` override must be defined for this to work.
        The default `opEquals` provided by the root `Object` class is
        equivalent to the `is` operator (see below).
        Comparing against `null` is invalid, as `null` has no contents.
        Use the `is` and `!is` operators instead.

---
class C;
C c;
if (c == null)  // error
    ...
if (c is null)  // ok
    ...

---

$(H3 $(ID identity_expressions) Identity Expressions)

$(PRE $(CLASS GRAMMAR)
$(B $(ID IdentityExpression) IdentityExpression):
    [#ShiftExpression|ShiftExpression] `is` [#ShiftExpression|ShiftExpression]
    [#ShiftExpression|ShiftExpression] `! is` [#ShiftExpression|ShiftExpression]

)

    The `is` operator compares for identity of expression values.
        To compare for nonidentity, use `e1 !is e2`.
        The type of the result is `bool`. The operands
        undergo the $(LINK2 spec/type#usual-arithmetic-conversions,Usual Arithmetic Conversions) to bring them to a common type before
        comparison.
    

    For class / interface objects, identity is defined as the object references being identical.
        Null class objects can be compared with `is`.
        Note that interface objects need not have the same reference of the class they were cast from.
        To test whether an `interface` shares a class instance with another `interface` / `class` value, cast both operands to `Object` before comparing with `is`.
    

    $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
interface I { void g(); }
interface I1 : I { void g1(); }
interface I2 : I { void g2(); }
interface J : I1, I2 { void h(); }

class C : J
{
    override void g() { }
    override void g1() { }
    override void g2() { }
    override void h() { }
}

void main() @safe
{
    C c = new C;
    I i1 = cast(I1) c;
    I i2 = cast(I2) c;
    assert(i1 !is i2); // not identical
    assert(c !is i2); // not identical
    assert(cast(Object) i1 is cast(Object) i2); // identical
}

---
    
)

    For struct objects and floating point values, identity is defined as the
        bits in the operands being identical.
    

    For static and dynamic arrays, identity of two arrays is given when
    both arrays refer to the same memory location and contain the same number
    of elements.
    

    $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
Object o;
assert(o is null);

auto a = [1, 2];
assert(a is a[0..$]);
assert(a !is a[0..1]);

auto b = [1, 2];
assert(a !is b);

---
    
)

    <div class="ddoc_deprecated">
  <h4>Deprecated</h4>
  <p class="para">
    Use of `is` to compare static arrays by address and
    length is deprecated. To do so, use the slice operator and compare slices
    of the arrays instead; for example, `a1[] is a2[]`.
  </p>
</div>


    For other operand types, identity is defined as being the same
        as equality.
    

    The identity operator `is` cannot be overloaded.
    

$(H3 $(ID relation_expressions) Relational Expressions)

$(PRE $(CLASS GRAMMAR)
$(B $(ID RelExpression) RelExpression):
    [#ShiftExpression|ShiftExpression] `&lt;` [#ShiftExpression|ShiftExpression]
    [#ShiftExpression|ShiftExpression] `&lt;=` [#ShiftExpression|ShiftExpression]
    [#ShiftExpression|ShiftExpression] `&gt;` [#ShiftExpression|ShiftExpression]
    [#ShiftExpression|ShiftExpression] `&gt;=` [#ShiftExpression|ShiftExpression]

)

    First, the $(LINK2 spec/type#usual-arithmetic-conversions,Usual Arithmetic Conversions) are done on the operands.
        The result type of a relational expression is `bool`.
    

$(H3 $(ID array_comparisons) Array Comparisons)

    For static and dynamic arrays, the result of a <em>CmpExpression</em>
        is the result of the operator applied to the first non-equal
        element of the array. If two arrays compare equal, but are of
        different lengths, the shorter array compares as "less" than the
        longer array.
    

$(H3 $(ID integer_comparisons) Integer Comparisons)

    Integer comparisons happen when both operands are integral
        types.
    

    $(TABLE_ROWS
Integer comparison operators
        * + Operator
+ Relation

        * - `&lt;`
- less

        * - `&gt;`
- greater

        * - `&lt;``=`
- less or equal

        * - `&gt;=`
- greater or equal

        * - `==`
- equal

        * - `!=`
- not equal

    
)

    It is an error to have one operand be signed and the other
        unsigned for a `&lt;`, `&lt;``=`, `&gt;` or
        `&gt;``=` expression.
        Use [#cast_integers|casts] to make both operands signed or both operands unsigned.
    

$(H3 $(ID floating-point-comparisons)Floating Point Comparisons)

    If one or both operands are floating point, then a floating
        point comparison is performed.
    

    A <em>CmpExpression</em> can have `NaN` operands.
        If either or both operands is `NaN`, the floating point
        comparison operation returns as follows:

        $(TABLE_ROWS
Floating point comparison operators
        * + Operator
+ Relation
+ Returns

        * - `&lt;`
- less
- `false`

        * - `&gt;`
- greater
- `false`

        * - `&lt;``=`
- less or equal
- `false`

        * - `&gt;=`
- greater or equal
- `false`

        * - `==`
- equal
- `false`

        * - `!=`
- unordered, less, or greater
- `true`

        
)

    $(TIP Although <em>IdentityExpression</em> can be used to check for `T.nan`,
    there are other floating-point values for NaN produced at runtime.
    Use $(REF isNaN, std,math,traits) to handle all of them.)

$(H3 $(ID class-comparisons)Class Comparisons)

    For class objects, <em>EqualExpression</em> and <em>RelExpression</em> compare the
        <em>contents</em> of the objects. Therefore, comparing against
        a `null` class reference is invalid, as `null` has no contents.

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
class C {}

void fun()
{
    C c;
    //if (c &lt; null) {}  // compile-time error
    assert(c is null);
    if (c &gt; new C) {}  // runtime error
}

---
        
)

    For class objects, the result of `Object.opCmp()` forms the left
        operand, and `0` forms the right operand. The result of an
        <em>EqualExpression</em> or <em>RelExpression</em> `(o1 op o2)` is:

---
(o1.opCmp(o2) op 0)

---


$(H2 $(ID in_expressions) In Expressions)

$(PRE $(CLASS GRAMMAR)
$(B $(ID InExpression) InExpression):
    [#ShiftExpression|ShiftExpression] `in` [#ShiftExpression|ShiftExpression]
    [#ShiftExpression|ShiftExpression] `! in` [#ShiftExpression|ShiftExpression]

)

A container such as an associative array
    $(LINK2 spec/hash-map#testing_membership,can be tested) to see if it contains a certain key:

---
int foo[string];
...
if ("hello" in foo)
{
    // the string was found
}

---

    The result of an $(I InExpression) is a pointer for associative
        arrays.
        The pointer is `null` if the container has no matching key.
        If there is a match, the pointer points to a value associated
        with the key.
    

    The `!in` expression is the logical negation of the `in`
        operation.
    

    The `in` expression has the same precedence as the
        relational expressions `&lt;`, `&lt;``=`, etc.

    Note: When $(LINK2 spec/operatoroverloading#binary,overloading)
        `in`, normally only $(TT opBinaryRight) would be defined. This is
        because the operation is usually not defined by the key type but by
        the container, which appears on the right hand side of the `in`
        operator.

$(H2 $(ID shift_expressions) Shift Expressions)

$(PRE $(CLASS GRAMMAR)
$(B $(ID ShiftExpression) ShiftExpression):
    [#AddExpression|AddExpression]
    ShiftExpression `&lt;&lt;` [#AddExpression|AddExpression]
    ShiftExpression `&gt;&gt;` [#AddExpression|AddExpression]
    ShiftExpression `&gt;&gt;&gt;` [#AddExpression|AddExpression]

)

    The operands must be integral types, and undergo the $(LINK2 spec/type#integer-promotions,Integer Promotions).
        The result type is the type of the left operand after
        the promotions. The result value is the result of shifting the bits
        by the right operand's value.
    

    $(LIST
        * `&lt;``&lt;` is a left shift.
        * `&gt;``&gt;` is a signed right shift.
        * `&gt;``&gt;``&gt;` is an unsigned right shift.
    
)

    $(WARNING     The result of a shift by a negative value or by the same or more bits
    than the size of the quantity being shifted is undefined.
    When the shift amount is known at compile time, doing this results in
    a compile error.

---
int c;

int s = -3;
auto y = c &lt;&lt; s; // implementation defined value

auto x = c &lt;&lt; 33;  // error, max shift count allowed is 31

---
    )

$(H2 $(ID additive_expressions) Additive Expressions)

$(PRE $(CLASS GRAMMAR)
$(B $(ID AddExpression) AddExpression):
    [#MulExpression|MulExpression]
    AddExpression `+` [#MulExpression|MulExpression]
    AddExpression `-` [#MulExpression|MulExpression]
    AddExpression `~` [#MulExpression|MulExpression]

)

$(H3 $(ID add_expressions) Add Expressions)
    In the cases of the Additive operations `+` and `-`:
    

    If the operands are of integral types, they undergo the $(LINK2 spec/type#usual-arithmetic-conversions,Usual Arithmetic Conversions),
        and then are brought to a common type using the
        $(LINK2 spec/type#usual-arithmetic-conversions,Usual Arithmetic Conversions).
    

    If both operands are of integral types and an overflow or underflow
        occurs in the computation, wrapping will happen. For example:
    $(LIST
        * `uint.max + 1 == uint.min`
        * `uint.min - 1 == uint.max`
        * `int.max + 1 == int.min`
        * `int.min - 1 == int.max`
    
)

    If either operand is a floating point type, the other is implicitly
        converted to floating point and they are brought to a common type
        via the $(LINK2 spec/type#usual-arithmetic-conversions,Usual Arithmetic Conversions).
    

    Add expressions for floating point operands are not associative.
    

    $(H4 $(ID pointer_arithmetic) Pointer Arithmetic)

    If the first operand is a pointer, and the second is an integral type,
        the resulting type is the type of the first operand, and the resulting
        value is the pointer plus (or minus) the second operand multiplied by
        the size of the type pointed to by the first operand.
    

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
int[] a = [1,2,3];
int* p = a.ptr;
assert(*p == 1);

*(p + 2) = 4; // same as `p[2] = 4`
assert(a[2] == 4);

---

)

    [#IndexOperation|IndexOperation] can also be used with a pointer and has
    the same behaviour as adding an integer, then dereferencing the result.

    If the second operand is a pointer, and the first is an integral type,
        and the operator is `+`,
        the operands are reversed and the pointer arithmetic just described
        is applied.
    

    Producing a pointer through pointer arithmetic is not allowed in
        $(LINK2 spec/memory-safe-d, Memory-Safe-D-Spec) code.

    If both operands are pointers, and the operator is `+`,
        then it is illegal.
    

    If both operands are pointers, and the operator is `-`,
        the pointers are subtracted and the
        result is divided by the size of the type pointed to by the
        operands. In this calculation the assumed size of `void` is one byte.
        It is an error if the pointers point to different types.
        The type of the result is `ptrdiff_t`.
    

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
int[] a = [1,2,3];
ptrdiff_t d = &amp;a[2] - a.ptr;
assert(d == 2);

---

)


$(H3 $(ID cat_expressions) Cat Expressions)
    In the case of the Additive operation `~`:
    

    A $(I CatExpression) concatenates a container's data with other data, producing
        a new container.

    For a dynamic array, the other operand must either be another array or a
        single value that implicitly converts to the element type of the array.
        See $(LINK2 spec/arrays#array-concatenation,Array Concatenation).

$(H2 $(ID mul_expressions) Mul Expressions)

$(PRE $(CLASS GRAMMAR)
$(B $(ID MulExpression) MulExpression):
    [#UnaryExpression|UnaryExpression]
    MulExpression `*` [#UnaryExpression|UnaryExpression]
    MulExpression `/` [#UnaryExpression|UnaryExpression]
    MulExpression `%` [#UnaryExpression|UnaryExpression]

)

    The operands must be arithmetic types.
        They undergo the $(LINK2 spec/type#usual-arithmetic-conversions,Usual Arithmetic Conversions).
    

    For integral operands, the `*`, `/`, and `%`
        correspond to multiply, divide, and modulus operations.
        For multiply, overflows are ignored and simply chopped to fit
        into the integral type.
    

$(H3 $(ID division) Division)

    For integral operands of the `/` and `%` operators,
        the quotient rounds towards zero and the remainder has the
        same sign as the dividend.
    

    The following divide or modulus integral operands:

    $(LIST
    * denominator is 0
    * signed `int.min` is the numerator and `-1` is the denominator
    * signed `long.min` is the numerator and `-1L` is the denominator
    
)

    are illegal if encountered during Compile Time Execution.

    $(PITFALL is exhibited if they are encountered during run time.
        $(LINK2 https://dlang.org/phobos/core_checkedint.html, `core.checkedint`)
        can be used to check for them and select a defined behavior.
    )

$(H3 $(ID mul_floating) Floating Point)

    For floating point operands, the `*` and `/` operations correspond
        to the IEEE 754 floating point equivalents. `%` is not the same as
        the IEEE 754 remainder. For example, `15.0 % 10.0 == 5.0`, whereas
        for IEEE 754, `remainder(15.0,10.0) == -5.0`.
    

    Mul expressions for floating point operands are not associative.
    

$(H2 $(ID unary-expression)Unary Expressions)

$(PRE $(CLASS GRAMMAR)
$(B $(ID UnaryExpression) UnaryExpression):
    `&` UnaryExpression
    `++` UnaryExpression
    `--` UnaryExpression
    `*` UnaryExpression
    `-` UnaryExpression
    `+` UnaryExpression
    `!` UnaryExpression
    [#ComplementExpression|ComplementExpression]
    [#DeleteExpression|DeleteExpression]
    [#CastExpression|CastExpression]
    [#ThrowExpression|ThrowExpression]
    [#PowExpression|PowExpression]

)

$(TABLE     * + Operator
+ Description

    * - `&amp;`
- Take memory address of an [#.define-lvalue|lvalue] - see $(LINK2 spec/type#pointers,pointers)

    * - `++`
- Increment before use - see [#order-of-evaluation|order of evaluation]

    * - `--`
- Decrement before use

    * - `*`
- Dereference/indirection - typically for pointers

    * - `-`
- Negative

    * - `+`
- Positive

    * - `!`
- Logical NOT

)

    The usual $(LINK2 spec/type#integer-promotions,Integer Promotions) are performed prior to unary
    `-` and `+` operations.

$(H3 $(ID complement_expressions) Complement Expressions)

$(PRE $(CLASS GRAMMAR)
$(B $(ID ComplementExpression) ComplementExpression):
    `~` [#UnaryExpression|UnaryExpression]

)

    $(I ComplementExpression)s work on integral types (except `bool`).
        All the bits in the value are complemented.
        The usual $(LINK2 spec/type#integer-promotions,Integer Promotions) are performed
        prior to the complement operation.
    

$(H3 $(ID delete_expressions) Delete Expressions)

$(PRE $(CLASS GRAMMAR)
$(B $(ID DeleteExpression) DeleteExpression):
    `delete` [#UnaryExpression|UnaryExpression]

)
    <div class="ddoc_deprecated">
  <h4>Deprecated</h4>
  <p class="para">
    `delete` has been deprecated.  Instead, please use [object.destroy|destroy]
    if feasible, or $(REF __delete, core, memory) as a last resort.
  </p>
</div>


    If the $(I UnaryExpression) is a class object reference, and
        there is a destructor for that class, the destructor
        is called for that object instance.
    

    Next, if the $(I UnaryExpression) is a class object reference, or
        a pointer to a struct instance, and the class or struct
        has overloaded operator delete, then that operator delete is called
        for that class object instance or struct instance.
    

    Otherwise, the garbage collector is called to immediately free the
        memory allocated for the class instance or struct instance.
    

    If the $(I UnaryExpression) is a pointer or a dynamic array,
        the garbage collector is called to immediately release the
        memory.
    

    The pointer, dynamic array, or reference is set to `null`
        after the delete is performed.
        Any attempt to reference the data after the deletion via another
        reference to it will result in undefined behavior.
    

    If $(I UnaryExpression) is a variable allocated
        on the stack, the class destructor (if any) is called for that
        instance. The garbage collector is not called.
    

    $(PITFALL     $(NUMBERED_LIST
    * Using `delete` to free memory not allocated by the garbage collector.
    * Referring to data that has been the operand of `delete`.
    
))

$(H3 $(ID cast_expressions) Cast Expressions)

$(PRE $(CLASS GRAMMAR)
$(B $(ID CastExpression) CastExpression):
    `cast (` [type#Type|type, Type] `)` [#UnaryExpression|UnaryExpression]
    [#CastQual|CastQual]

)

    A $(I CastExpression) converts the $(I UnaryExpression)
        to $(I Type).

---
cast(foo) -p; // cast (-p) to type foo
(foo) - p;      // subtract p from foo

---

$(H4 $(ID cast_basic_data_types) Basic Data Types)
    For situations where $(LINK2 spec/type#implicit-conversions,implicit conversions)
        on basic types cannot be performed, the type system may be forced to accept the
        reinterpretation of a memory region by using a cast.
    

    An example of such a scenario is represented by trying to store a wider type
        into a narrower one:
    

---
int a;
byte b = a; // cannot implicitly convert expression a of type int to byte

---

    When casting a source type that is wider than the destination type,
        the value is truncated to the destination size.
    

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
int a = 64389; // 00000000 00000000 11111011 10000101
byte b = cast(byte) a;       // 10000101
ubyte c = cast(ubyte) a;     // 10000101
short d = cast(short) a;     // 11111011 10000101
ushort e = cast(ushort) a;   // 11111011 10000101

writeln(b);
writeln(c);
writeln(d);
writeln(e);

---
        
)

    For integral types casting from a narrower type to a wider type
        is done by performing sign extension.
    

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
ubyte a = 133;  // 10000101
byte b = a;     // 10000101

writeln(a);
writeln(b);

ushort c = a;   // 00000000 10000101
short d = b;    // 11111111 10000101

writeln(c);
writeln(d);

---
        
)

$(H4 $(ID cast_class) Class References)

    Any casting of a class reference to a
        derived class reference is done with a runtime check to make sure it
        really is a downcast. `null` is the result if it isn't.
    

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
class A {}
class B : A {}

void main()
{
    A a = new A;
    //B b = a;         // error, need cast
    B b = cast(B) a; // b is null if a is not a B
    assert(b is null);

    a = b;         // no cast needed
    a = cast(A) b; // no runtime check needed for upcast
    assert(a is b);
}

---
        
)

    In order to determine if an object `o` is an instance of
        a class `B` use a cast:

---
if (cast(B) o)
{
    // o is an instance of B
}
else
{
    // o is not an instance of B
}

---

    Casting a pointer type to and from a class type is done as a type paint
        (i.e. a reinterpret cast).
    

$(H4 $(ID cast_pointers) Pointers)
    Casting a pointer variable to another pointer type modifies the value that
        will be obtained as a result of dereferencing, along with the number of bytes
        on which pointer arithmetic is performed.
    

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
int val = 25185; // 00000000 00000000 01100010 01100001
char *ch = cast(char*)(&amp;val);

writeln(*ch);    // a
writeln(cast(int)(*ch)); // 97
writeln(*(ch + 1));  // b
writeln(cast(int)(*(ch + 1)));   // 98

---
        
)

    Similarly, when casting a dynamically allocated array to a type of smaller size,
        the bytes of the initial array will be divided and regrouped according to the new
        dimension.
    

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
import core.stdc.stdlib;

int *p = cast(int*) malloc(5 * int.sizeof);
for (int i = 0; i &lt; 5; i++) {
    p[i] = i + 'a';
}
// p = [97, 98, 99, 100, 101]

char* c = cast(char*) p;     // c = [97, 0, 0, 0, 98, 0, 0, 0, 99 ...]
for (int i = 0; i &lt; 5 * int.sizeof; i++) {
    writeln(c[i]);
}

---
        
)

    When casting a pointer of type A to a pointer of type B and type B is wider than type A,
        attempts at accessing the memory exceeding the size of A will result in undefined behaviour.
    

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
char c = 'a';
int *p = cast(int*) (&amp;c);
writeln(*p);

---
        
)

    It is also possible to cast pointers to basic data types.
        A common practice could be to cast the pointer to an int value
        and then print its address:
    

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
import core.stdc.stdlib;

int *p = cast(int*) malloc(int.sizeof);
int a = cast(int) p;
writeln(a);

---
        
)


$(H4 $(ID cast_array) Arrays)

    Casting a dynamic array to another dynamic array is done only if the
        array lengths multiplied by the element sizes match. The cast is done
        as a type paint, with the array length adjusted to match any change in
        element size. If there's not a match, a runtime error is generated.

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
byte[] a = [1,2,3];
//auto b = cast(int[])a; // runtime error: array cast misalignment

int[] c = [1, 2, 3];
auto d = cast(byte[])c; // ok
// prints:
// [1, 0, 0, 0, 2, 0, 0, 0, 3, 0, 0, 0]
writeln(d);

---
        
)

    <div class="ddoc_see_also">
  <h4>See Also</h4>
  <p class="para">
    [#cast_array_literal|Casting array literals].
  </p>
</div>


$(H4 $(ID cast_static_array) Static Arrays)

    Casting a static array to another static array is done only if the
        array lengths multiplied by the element sizes match; a mismatch
        is illegal.
        The cast is done as a type paint (aka a reinterpret cast).
        The contents of the array are not changed.

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
byte[16] b = 3; // set each element to 3
assert(b[0] == 0x03);
int[4] ia = cast(int[4]) b;
// print elements as hex
foreach (i; ia)
    writefln("%x", i);
/* prints:
   3030303
   3030303
   3030303
   3030303
 */

---
        
)

$(H4 $(ID cast_integers) Integers)

    Casting an integer to a smaller integral will truncate the
        value towards the least significant bits.
        If the target type is signed and the most significant bit is set
        after truncation, that bit will be lost from the value and
        the sign bit will be set.

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
uint a = 260;
auto b = cast(ubyte) a;
assert(b == 4); // truncated like 260 &amp; 0xff

int c = 128;
assert(cast(byte)c == -128); // reinterpreted

---
        
)

    Converting between signed and unsigned types will reinterpret the
        value if the destination type cannot represent the source
        value.

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
short c = -1;
ushort d = c;
assert(d == ushort.max);
assert(uint(c) == uint.max);

ubyte e = 255;
byte f = e;
assert(f == -1); // reinterpreted
assert(short(e) == 255); // no change

---
        
)

$(H4 $(ID cast_floating) Floating Point)

    Casting a floating point literal from one type to another
        changes its type, but internally it is retained at full
        precision for the purposes of constant folding.

---
void test()
{
    real a = 3.40483L;
    real b;
    b = 3.40483;     // literal is not truncated to double precision
    assert(a == b);
    assert(a == 3.40483);
    assert(a == 3.40483L);
    assert(a == 3.40483F);
    double d = 3.40483; // truncate literal when assigned to variable
    assert(d != a);     // so it is no longer the same
    const double x = 3.40483; // assignment to const is not
    assert(x == a);     // truncated if the initializer is visible
}

---

    Casting a floating point value to an integral type is the equivalent
        of converting to an integer using truncation. If the floating point
        value is outside the range of the integral type, the cast will produce
        an invalid result (this is also the case in C, C++).

---
void main()
{
    int a = cast(int) 0.8f;
    assert(a == 0);
    long b = cast(long) 1.5;
    assert(b == 1L);
    long c = cast(long) -1.5;
    assert(c == -1);

    // if the float overflows, the cast returns the integer value of
    // 80000000_00000000H (64-bit operand) or 80000000H (32-bit operand)
    long d = cast(long) float.max;
    assert(d == long.min);
    int e = cast(int) (1234.5 + int.max);
    assert(e == int.min);

    // for types represented on 16 or 8 bits, the result is the same as
    // 32-bit types, but the most significant bits are ignored
    short f = cast(short) float.max;
    assert(f == 0);
}

---

$(H4 $(ID cast_struct) Structs)

    Casting a value $(I v) to a struct $(I S), when value is not a struct
        of the same type, is equivalent to:

---
S(v)

---

$(H4 $(ID cast_qualifier) Qualifier Cast)

$(PRE $(CLASS GRAMMAR)
$(B $(ID CastQual) CastQual):
    `cast (` [type#TypeCtors|type, TypeCtors]$(SUBSCRIPT opt) `)` [#UnaryExpression|UnaryExpression]

)

    A $(I CastQual) replaces the qualifiers in the type of
        the $(I UnaryExpression):

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
shared int x;
static assert(is(typeof(cast(const)x) == const int));

---
        
)

    Casting with no type or qualifiers removes
        any top level `const`, `immutable`, `shared` or `inout`
        type modifiers from the type
        of the $(I UnaryExpression).

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
shared int x;
static assert(is(typeof(cast()x) == int));

---
        
)

$(H4 $(ID cast_void) Casting to `void`)

    Casting an expression to `void` type is allowed to mark that
        the result is unused. On [statement#ExpressionStatement|statement, ExpressionStatement],
        it could be used properly to avoid a "has no effect" error.

---
void foo(lazy void exp) {}
void main()
{
    foo(10);            // NG - expression '10' has no effect
    foo(cast(void)10);  // OK
}

---

$(H2 $(ID throw_expression) Throw Expression)

$(PRE $(CLASS GRAMMAR)
$(B $(ID ThrowExpression) ThrowExpression):
    `throw` [#AssignExpression|AssignExpression]

)

    $(I AssignExpression) is evaluated and must yield a reference to a `Throwable`
    or a class derived from `Throwable`. The reference is thrown as an exception,
    interrupting the current control flow to continue at a suitable `catch` clause
    of a [statement#try-statement|statement, try-statement]. This process will execute any applicable
    $(LINK2 statement.html#ScopeGuardStatement, `scope (exit)` / `scope (failure)`)
    passed since entering the corresponding `try` block.


---
throw new Exception("message");

---

    The `Throwable` must not be a qualified as `immutable`, `const`, `inout` or
    `shared`. The runtime may modify a thrown object (e.g. to contain a stack
    trace) which would violate `const` or `immutable` objects.

    A $(I ThrowExpression) may be nested in another expression:

---
void foo(int function() f) {}

void main() {
    foo(() =&gt; throw new Exception());
}

---

    The type of a <em>ThrowExpression</em> is $(LINK2 spec/type#noreturn,`noreturn`).

$(TIP Use $(LINK2 spec/expression#assert_expressions,Assert Expressions)
rather than $(LINK2 library/object#.Error, Error) to report program bugs
and abort the program.
)

$(H2 $(ID pow_expressions) Pow Expressions)

$(PRE $(CLASS GRAMMAR)
$(B $(ID PowExpression) PowExpression):
    [#PostfixExpression|PostfixExpression]
    [#PostfixExpression|PostfixExpression] `^^` [#UnaryExpression|UnaryExpression]

)

    $(I PowExpression) raises its left operand to the power of its
        right operand.
    

$(H2 $(ID postfix_expressions) Postfix Expressions)

$(PRE $(CLASS GRAMMAR)
$(B $(ID PostfixExpression) PostfixExpression):
    [#PrimaryExpression|PrimaryExpression]
    PostfixExpression `.` $(LINK2 lex#Identifier, Identifier)
    PostfixExpression `.` [template#TemplateInstance|template, TemplateInstance]
    PostfixExpression `.` [#NewExpression|NewExpression]
    PostfixExpression `++`
    PostfixExpression `--`
    PostfixExpression `(` [#NamedArgumentList|NamedArgumentList]$(SUBSCRIPT opt) `)`
    [type#TypeCtors|type, TypeCtors]$(SUBSCRIPT opt) [type#BasicType|type, BasicType] `(` [#NamedArgumentList|NamedArgumentList]$(SUBSCRIPT opt) `)`
    PostfixExpression [#IndexOperation|IndexOperation]
    PostfixExpression [#SliceOperation|SliceOperation]

)

$(TABLE     * + Operator
+ Description

    * - `.`
-         Either:
$(LIST
* Access a $(LINK2 spec/property, Properties) of a type or expression.
* Access a member of a module, package, aggregate type or instance, enum
          or template instance.
* Call a free function using $(LINK2 spec/function#pseudo-member,UFCS).

)
    

    * - `++`
- Increment after use - see [#order-of-evaluation|order of evaluation]

    * - `--`
- Decrement after use

    * - <em>IndexOperation</em>
- Select a single element

    * - <em>SliceOperation</em>
- Select a series of elements

)

$(H3 $(ID argument-list) Postfix Argument Lists)

$(PRE $(CLASS GRAMMAR)
$(B $(ID ArgumentList) ArgumentList):
    [#AssignExpression|AssignExpression]
    [#AssignExpression|AssignExpression] `,`
    [#AssignExpression|AssignExpression] `,` ArgumentList

$(B $(ID NamedArgumentList) NamedArgumentList):
    [#NamedArgument|NamedArgument]
    [#NamedArgument|NamedArgument] `,`
    [#NamedArgument|NamedArgument] `,` $(I NamedArgumentList)

$(B $(ID NamedArgument) NamedArgument):
    $(LINK2 lex#Identifier, Identifier) `:` [#AssignExpression|AssignExpression]
    [#AssignExpression|AssignExpression]

)

    A callable expression can precede a list of named arguments in parentheses.

---
void f(int, int);

f(5, 6);
(&amp;f)(5, 6);

---

$(H4 $(ID argument-parameter-matching) Matching Arguments to Parameters)

            Arguments in a `NamedArgumentList` are matched to function parameters as follows:
    

$(NUMBERED_LIST
* If the first argument has no name, it will be assigned to the first function parameter.
* A named argument is assigned to a function parameter with the same name.
        It is an error if no such parameter exists.
* Any unnamed argument is assigned to the next parameter relative to the preceding argument's parameter.
        It is an error if no such parameter exists, i.e. when the preceding argument assigns to the last parameter.
* Assigning a parameter more than once is an error.
* Not assigning a parameter an argument is also an error,
        unless the parameter has a $(LINK2 spec/function#function-default-args,Default Argument).


)
$(H4 $(ID type-constructor-arguments) Constructing a Type with an Argument List)

    A type can precede a list of arguments. See:

$(LIST
* $(LINK2 spec/struct#struct-literal,Struct Literals)
* [#uniform_construction_syntax|Uniform construction syntax for built-in scalar types]


)
$(H3 $(ID index_expressions)Index Operations)

$(PRE $(CLASS GRAMMAR)
$(B $(ID IndexOperation) IndexOperation):
    `[` [#ArgumentList|ArgumentList] `]`

)

    The base $(I PostfixExpression) is evaluated.
        The special variable `$` is declared and set to be the number
        of elements in the base $(I PostfixExpression) (when available).
        A new declaration scope is created for the evaluation of the
        $(I ArgumentList) and `$` appears in that scope only.
    

    If the $(I PostfixExpression) is an expression of static or
        dynamic array type, the result of the indexing is an lvalue
        of the <em>i</em>th element in the array, where `i` is an integer
        evaluated from $(I ArgumentList).
        If $(I PostfixExpression) is a pointer `p`, the result is
        `*(p + i)` (see [#pointer_arithmetic|Pointer Arithmetic]).
    

    If the base $(I PostfixExpression) is a $(LINK2 spec/template#variadic-templates,$(I ValueSeq))
        then the $(I ArgumentList) must consist of only one argument,
        and that must be statically evaluatable to an integral constant.
        That integral constant $(I n) then selects the $(I n)th
        expression in the $(I ValueSeq), which is the result
        of the $(I IndexOperation).
        It is an error if $(I n) is out of bounds of the $(I ValueSeq).
    

    The index operator can be $(LINK2 spec/operatoroverloading#array,overloaded).
        Using multiple indices in <em>ArgumentList</em> is only supported for operator
        overloading.

$(H3 $(ID slice_expressions)Slice Operations)

$(PRE $(CLASS GRAMMAR)
$(B $(ID SliceOperation) SliceOperation):
    `[ ]`
    `[` [#Slice|Slice] `,`$(SUBSCRIPT opt) `]`

$(B $(ID Slice) Slice):
    [#AssignExpression|AssignExpression]
    [#AssignExpression|AssignExpression] `,` Slice
    [#AssignExpression|AssignExpression] `..` [#AssignExpression|AssignExpression]
    [#AssignExpression|AssignExpression] `..` [#AssignExpression|AssignExpression] `,` Slice

)

    The base $(I PostfixExpression) is evaluated.
        The special variable `$` is declared and set to be the number
        of elements in the $(I PostfixExpression) (when available).
        A new declaration scope is created for the evaluation of the
        $(I AssignExpression)`..`$(I AssignExpression) and `$` appears in
        that scope only.
    

    If the base $(I PostfixExpression) is a static or dynamic
        array `a`, the result of the slice is a dynamic array
        referencing elements `a[i]` to `a[j-1]` inclusive, where `i`
        and `j` are integers evaluated from the first and second $(I         AssignExpression) respectively.
    

    If the base $(I PostfixExpression) is a pointer `p`, the result
        will be a dynamic array referencing elements from `p[i]` to `p[j-1]`
        inclusive, where `i` and `j` are integers evaluated from the
        first and second $(I AssignExpression) respectively.
    

    If the base $(I PostfixExpression) is a $(LINK2 spec/template#variadic-templates,$(I ValueSeq)), then
        the result of the slice is a new $(I ValueSeq) formed
        from the upper and lower bounds, which must statically evaluate
        to integral constants.
        It is an error if those bounds are out of range.
    

    The first $(I AssignExpression) is taken to be the inclusive
        lower bound
        of the slice, and the second $(I AssignExpression) is the
        exclusive upper bound.
        The result of the expression is a slice of the elements in $(I PostfixExpression).
    

    If the `[ ]` form is used, the slice is of all the elements in the base $(I PostfixExpression).
        The base expression cannot be a pointer.
    

    The slice operator can be $(LINK2 spec/operatoroverloading#slice,overloaded).
        Using more than one <em>Slice</em> is only supported for operator
        overloading.

    A $(I SliceOperation) is not a modifiable lvalue.

$(H4 $(ID slice_to_static_array) Slice Conversion to Static Array)

    If the slice bounds can be known at compile time, the slice expression
    may be implicitly convertible to a static array lvalue. For example:

---
arr[a .. b]     // typed T[]

---

                If both `a` and `b` are integers (which may be constant-folded),
        the slice expression can be converted to a static array of type
        `T[b - a]`.
        
        Note: a static array can also be $(LINK2 spec/arrays#assignment,        assigned from a slice), performing a runtime check that the lengths match.

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
void f(int[2] sa) {}

int[] arr = [1, 2, 3];

void test()
{
    //f(arr); // error, can't convert
    f(arr[1 .. 3]); // OK
    //f(arr[0 .. 3]); // error

    int[2] g() { return arr[0 .. 2]; }
}

---
        
)

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
void bar(ref int[2] a)
{
    assert(a == [2, 3]);
    a = [4, 5];
}

void main()
{
    int[] arr = [1, 2, 3];

    // slicing an lvalue gives an lvalue
    bar(arr[1 .. 3]);
    assert(arr == [1, 4, 5]);
}

---
        
)

    $(COMMENT Not implemented yet - https://issues.dlang.org/show_bug.cgi?id=13700
    Certain other forms of slice expression can be implicitly converted to a static array
        when the slice length can be known at compile-time.

        $(COMMENT SPEC_RUNNABLE_EXAMPLE_RUN
---
int[] da = [1, 2, 3];
int i = da[0]; // runtime variable

int[2] f() { return da[i .. i + 2]; }
assert(f() == [2, 3]);

---
        )

    The table below shows all the forms recognized:

        $(DL         $(DT `e`) $(DD An expression that contains no side effects.)
        $(DT `a`, `b`) $(DD Integers (that may be constant-folded).)
        )

        $(TABLE_ROWS

        * + Form
+ The length calculated at compile time

        * - `arr[]`
- The compile time length of `arr` if it's known.

        * - `arr[a .. b]`
-               `b - a`

        * - `arr[e-a .. e]`
-   `a`

        * - `arr[e .. e+b]`
-   `b`

        * - `arr[e-a .. e+b]`
- `a + b`

        * - `arr[e+a .. e+b]`
- `b - a` $(I if) `a &lt;= b`

        * - `arr[e-a .. e-b]`
- `a - b` $(I if) `a &gt;= b`

        
)
    )

$(H2 $(ID primary_expressions) Primary Expressions)

$(PRE $(CLASS GRAMMAR)
$(B $(ID PrimaryExpression) PrimaryExpression):
    $(LINK2 lex#Identifier, Identifier)
    `.` $(LINK2 lex#Identifier, Identifier)
    [template#TemplateInstance|template, TemplateInstance]
    `.` [template#TemplateInstance|template, TemplateInstance]
    [#this|`this`]
    [#super|`super`]
    [#null|`null`]
    $(ID true_false)true_false$(LINK2 spec/type#bool,`true`)
    $(LINK2 spec/type#bool,`false`)
    [#IndexOperation|`$`]
    $(LINK2 lex#IntegerLiteral, IntegerLiteral)
    $(LINK2 lex#FloatLiteral, FloatLiteral)
    $(ID CharacterLiteral)CharacterLiteral$(ID character-literal)character-literal$(LINK2 lex#CharacterLiteral, CharacterLiteral)
    [#string_literals|<em>StringLiteral</em>]
    [istring#InterpolationExpressionSequence|istring, InterpolationExpressionSequence]
    [#ArrayLiteral|ArrayLiteral]
    [#AssocArrayLiteral|AssocArrayLiteral]
    [#FunctionLiteral|FunctionLiteral]
    [#AssertExpression|AssertExpression]
    [#MixinExpression|MixinExpression]
    [#ImportExpression|ImportExpression]
    [#NewExpression|NewExpression]
    [type#FundamentalType|type, FundamentalType] `.` $(LINK2 lex#Identifier, Identifier)
    `(` [type#Type|type, Type] `) .` $(LINK2 lex#Identifier, Identifier)
    `(` [type#Type|type, Type] `) .` [template#TemplateInstance|template, TemplateInstance]
    [type#FundamentalType|type, FundamentalType] `(` [#NamedArgumentList|NamedArgumentList]$(SUBSCRIPT opt) `)`
    [type#TypeCtor|type, TypeCtor] `(` [type#Type|type, Type] `)` `.` $(LINK2 lex#Identifier, Identifier)
    [type#TypeCtor|type, TypeCtor] `(` [type#Type|type, Type] `)` `(` [#NamedArgumentList|NamedArgumentList]$(SUBSCRIPT opt) `)`
    [type#Typeof|type, Typeof]
    [#TypeidExpression|TypeidExpression]
    [#IsExpression|IsExpression]
    `(` [#Expression|Expression] `)`
    [#SpecialKeyword|SpecialKeyword]
    [traits#TraitsExpression|traits, TraitsExpression]

)

$(H3 $(ID identifier) .Identifier)

    See $(LINK2 spec/module#module_scope_operators,Module Scope
        Operator).

$(H3 $(ID this) this)

    Within a constructor or non-static member function, `this` resolves to
        a reference to the object for which the function was called.
    
    $(LINK2 spec/type#typeof-this,`typeof(this)`) is valid anywhere
        inside an aggregate type definition.
        If a class member function is called with an explicit reference
        to `typeof(this)`, a non-virtual call is made:

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
class A
{
    char get() { return 'A'; }

    char foo() { return typeof(this).get(); } // calls `A.get`
    char bar() { return this.get(); } // dynamic, same as just `get()`
}

class B : A
{
    override char get() { return 'B'; }
}

void main()
{
    B b = new B();

    assert(b.foo() == 'A');
    assert(b.bar() == 'B');
}

---
        
)

    Assignment to `this` is not allowed for classes.
    See also:
$(LIST
* $(LINK2 spec/class#delegating-constructors,Delegating Constructors)
* $(LINK2 spec/template#template_this_parameter,template `this` parameters)


)
$(H3 $(ID super) super)

    `super` is identical to `this`, except that it is
        cast to `this`'s base class.
        It is an error if there is no base class.
        (The only `extern(D)` class without a base class is `Object`,
        however, note that `extern(C++)` classes have no base class unless specified.)
        If a member function is called with an explicit reference
        to `super`, a non-virtual call is made.
    

    Assignment to `super` is not allowed.
    See also: $(LINK2 spec/class#base-construction,Base Class Construction).

$(H3 $(ID null) null)

    `null` represents the null value for
        pointers, pointers to functions, delegates,
        dynamic arrays, associative arrays,
        and class objects.
        If it has not already been cast to a type,
        it is given the singular type `typeof(null)` and it is an exact conversion
        to convert it to the null value for pointers, pointers to
        functions, delegates, etc.
        After it is cast to a type, such conversions are implicit,
        but no longer exact.
    

$(H3 $(ID string_literals)String Literals)

    See $(LINK2 lex#StringLiteral, StringLiteral) grammar.

    String literals are read-only.
        A string literal without a $(LINK2 spec/lex#string_postfix,StringPostfix)
        can implicitly convert to any
        of the following types, which have equal weight:
    

    $(TABLE         * - `immutable(char)*`

        * - `immutable(wchar)*`

        * - `immutable(dchar)*`

        * - `immutable(char)[]`

        * - `immutable(wchar)[]`

        * - `immutable(dchar)[]`

    )

    $(PITFALL writing to a string literal. This is not allowed in `@safe` code.)

    By default, a string literal is typed as a dynamic array, but the element
        count is known at compile time. So all string literals can be
        implicitly converted to an immutable static array:

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
void foo(char[2] a)
{
    assert(a[0] == 'b');
}
void bar(ref const char[2] a)
{
    assert(a == "bc");
}

void main()
{
    foo("bc");
    foo("b"); // OK
    //foo("bcd"); // error, too many chars
    bar("bc"); // OK, same length
    //bar("b"); // error, lengths must match
}

---
        
)
    A string literal converts to a static array rvalue of the same or longer length.
        Any extra elements are padded with zeros. A string literal
        can also convert to a static array lvalue of the same length.

    String literals have a `'\0'` appended to them, which makes
        them easy to pass to C or C++ functions expecting a null-terminated
        `const char*` string.
        The `'\0'` is not included in the `.length` property of the
        string literal.
    

    Concatenation of string literals requires the use of
        [#cat_expressions|the `~` operator], and is resolved at compile time.
        C style implicit concatenation without an intervening operator is
        error prone and not supported in D.


$(H3 $(ID hex_string_literals) Hex String Literals)
    Because hex string literals contain binary data not limited to textual data, they allow additional conversions over other string literals.

    A hex string literal implicitly converts to a constant `byte[]` or `ubyte[]`.
        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
immutable ubyte[] b = x"3F 80 00 00";
const byte[] c = x"3F 80 00 00";

---
        
)

    A hex string literal can be explicitly cast to an array of integers with a larger size than 1.
        A big endian byte order in the hex string will be assumed.

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
static immutable uint[] data = cast(immutable uint[]) x"AABBCCDD";
static assert(data[0] == 0xAABBCCDD);

---
        
)

    This requires the length of the hex string to be a multiple of the array element's size in bytes.
        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
static e = cast(immutable ushort[]) x"AA BB CC";
// Error, length of 3 bytes is not a multiple of 2, the size of a `ushort`

---
        
)

    When a hex string literal gets constant folded, the result is no longer considered a hex string literal
        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
static immutable byte[] b = x"AA" ~ "G"; // Error: cannot convert `string` to `immutable byte[]`

---
        
)

$(H3 $(ID array_literals) Array Literals)

$(PRE $(CLASS GRAMMAR)
$(B $(ID ArrayLiteral) ArrayLiteral):
    `[` $(I ArrayMemberInitializations)$(SUBSCRIPT opt) `]`

$(B $(ID ArrayMemberInitializations) ArrayMemberInitializations):
    $(I ArrayMemberInitialization)
    $(I ArrayMemberInitialization) `,`
    $(I ArrayMemberInitialization) `,` ArrayMemberInitializations

$(B $(ID ArrayMemberInitialization) ArrayMemberInitialization):
    [declaration#NonVoidInitializer|declaration, NonVoidInitializer]
    [#AssignExpression|AssignExpression] `:` [declaration#NonVoidInitializer|declaration, NonVoidInitializer]

)

    An array literal is a comma-separated list of expressions
        between square brackets `[` and `]`.
        The expressions form the elements of a dynamic array.
        The length of the array is the number of elements.
    
            The element type of the array is inferred as the common type of all the
        elements, and each expression is implicitly converted to that type.
        When there is an expected array type, the elements of the
        literal will be implicitly converted to the expected element
        type.

---
auto a1 = [1, 2, 3];   // type is int[], with elements 1, 2 and 3
auto a2 = [1u, 2, 3];  // type is uint[], with elements 1u, 2u, and 3u
byte[] a3 = [1, 2, 3]; // OK
byte[] a4 = [128];     // error

---

    $(NOTE         By default, an array literal is typed as a dynamic array, but the element
        count is known at compile time. Therefore, an array literal can be
        implicitly converted to a static array of the same length.

---
int[2] sa = [1, 2]; // OK
int[2] sb = [1];    // error

---

    Note: Slicing a dynamic array with a statically known slice length also
        [#slice_to_static_array|allows conversion] to a static array.
    )

    If any $(I ArrayMemberInitialization) is a
        $(LINK2 spec/template#TemplateParameterSequence,ValueSeq),
        then the elements of the $(I ValueSeq)
        are inserted as expressions in place of the sequence.
    

    Escaping array literals are allocated on the memory managed heap.
        Thus, they can be returned safely from functions:

---
int[] foo()
{
    return [1, 2, 3];
}

---

    To initialize an element at a particular index, use the
        <em>AssignExpression</em> `:` <em>NonVoidInitializer</em> syntax.
        The <em>AssignExpression</em> must be known at compile-time.
        Any missing elements will be initialized to the default value
        of the element type.
        Note that if the array type is not specified, the literal will
        be parsed as an
        [#associative_array_literals|associative array].

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
int n = 4;
auto aa = [0:1, 3:n]; // associative array `int[int]`

int[] a = [1, 3:n, 5];
assert(a == [1, 0, 0, n, 5]);

//int[] e = [n:2]; // error, n not known at compile-time

---
        
)

$(H4 $(ID cast_array_literal) Casting)

    When array literals are cast to another array type, each
        element of the array is cast to the new element type.
        When arrays that are not literals [#cast_array|are cast], the array is
        reinterpreted as the new type, and the length is recomputed:

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
// cast array literal
const ubyte[] ct = cast(ubyte[]) [257, 257];
// this is equivalent to:
// const ubyte[] ct = [cast(ubyte) 257, cast(ubyte) 257];
writeln(ct);  // writes [1, 1]

// cast other array expression
// --&gt; normal behavior of CastExpression
byte[] arr = [1, 1];
short[] rt = cast(short[]) arr;
writeln(rt);  // writes [257]

---
        
)

        In other words, casting an array literal will change the type of each initializer element.

        $(TIP Avoid casting an array literal when the elements could
        implicitly convert to an expected type. Instead, declare a variable of that type
        and initialize it with the array literal.
        Casting is more bug-prone than implicit conversions.)


$(H3 $(ID associative_array_literals) Associative Array Literals)

$(PRE $(CLASS GRAMMAR)
$(B $(ID AssocArrayLiteral) AssocArrayLiteral):
    `[` [#KeyValuePairs|KeyValuePairs] `]`

$(B $(ID KeyValuePairs) KeyValuePairs):
    [#KeyValuePair|KeyValuePair]
    [#KeyValuePair|KeyValuePair] `,` KeyValuePairs

$(B $(ID KeyValuePair) KeyValuePair):
    [#KeyExpression|KeyExpression] `:` [#ValueExpression|ValueExpression]

$(B $(ID KeyExpression) KeyExpression):
    [#AssignExpression|AssignExpression]

$(B $(ID ValueExpression) ValueExpression):
    [#AssignExpression|AssignExpression]

)

    Associative array literals are a comma-separated list of
        $(I key)`:`$(I value) pairs
        between square brackets `[` and `]`.
        The list cannot be empty.
        The common type of the all keys is taken to be the key type of
        the associative array, and all keys are implicitly converted
        to that type.
        The common type of the all values is taken to be the value type of
        the associative array, and all values are implicitly converted
        to that type.
        An $(I AssocArrayLiteral) cannot be used to statically initialize
        anything.

---
[21u: "he", 38: "ho", 2: "hi"]; // type is string[uint],
                              // with keys 21u, 38u and 2u
                              // and values "he", "ho", and "hi"

---

    If any of the keys or values in the $(I KeyValuePairs) are
        a $(I ValueSeq), then the elements of the $(I ValueSeq)
        are inserted as arguments in place of the sequence.
    

    Associative array initializers may contain duplicate keys,
        however, in that case, the last $(I KeyValuePair) lexicographically
        encountered is stored.
    

---
auto aa = [21: "he", 38: "ho", 2: "hi", 2:"bye"];
assert(aa[2] == "bye")

---

$(H3 $(ID function_literals) Function Literals)

$(PRE $(CLASS GRAMMAR)
$(B $(ID FunctionLiteral) FunctionLiteral):
    `function` [#RefOrAutoRef|RefOrAutoRef]$(SUBSCRIPT opt) [type#Type|type, Type]$(SUBSCRIPT opt) [#ParameterWithAttributes|ParameterWithAttributes]$(SUBSCRIPT opt) [#FunctionLiteralBody2|FunctionLiteralBody2]
    `delegate` [#RefOrAutoRef|RefOrAutoRef]$(SUBSCRIPT opt) [type#Type|type, Type]$(SUBSCRIPT opt) [#ParameterWithMemberAttributes|ParameterWithMemberAttributes]$(SUBSCRIPT opt) [#FunctionLiteralBody2|FunctionLiteralBody2]
    [#RefOrAutoRef|RefOrAutoRef]$(SUBSCRIPT opt) [#ParameterWithMemberAttributes|ParameterWithMemberAttributes] [#FunctionLiteralBody2|FunctionLiteralBody2]
    [statement#BlockStatement|statement, BlockStatement]
    $(LINK2 lex#Identifier, Identifier) `=&gt;` [#AssignExpression|AssignExpression]

$(B $(ID ParameterWithAttributes) ParameterWithAttributes):
    [function#Parameters|function, Parameters] [function#FunctionAttributes|function, FunctionAttributes]$(SUBSCRIPT opt)

$(B $(ID ParameterWithMemberAttributes) ParameterWithMemberAttributes):
    [function#Parameters|function, Parameters] [function#MemberFunctionAttributes|function, MemberFunctionAttributes]$(SUBSCRIPT opt)

$(B $(ID FunctionLiteralBody2) FunctionLiteralBody2):
    `=&gt;` [#AssignExpression|AssignExpression]
    [function#SpecifiedFunctionBody|function, SpecifiedFunctionBody]

$(B $(ID RefOrAutoRef) RefOrAutoRef):
    `ref`
    `auto ref`

)

    $(I FunctionLiteral)s enable embedding anonymous functions
        and anonymous delegates directly into expressions.
        Short function literals are known as $(ID lambdas) $(I lambdas).
    
$(LIST
* $(I Type) is the return type of the function or delegate -
        if omitted it is [#lambda-return-type|inferred].
* $(I ParameterWithAttributes) or $(I ParameterWithMemberAttributes)
        can be used to specify the parameters for the function. If these are
        omitted, the function defaults to the empty parameter list `( )`.
* Parameter types can be [#lambda-parameter-inference|omitted].
* The type of a function literal is a
        $(LINK2 spec/function#closures,delegate or a pointer to function).


)
    For example:

---
int function(char c) fp; // declare pointer to a function

void test()
{
    static int foo(char c) { return 6; }

    fp = &amp;foo;
}

---

        is exactly equivalent to:

---
int function(char c) fp;

void test()
{
    fp = function int(char c) { return 6; };
}

---

    A delegate is necessary if the $(I FunctionLiteralBody2) accesses any non-static
        local variables in enclosing functions.

---
int abc(int delegate(int i));

void test()
{
    int b = 3;
    int foo(int c) { return 6 + b; }

    abc(&amp;foo);
}

---

        is exactly equivalent to:

---
int abc(int delegate(int i));

void test()
{
    int b = 3;

    abc( delegate int(int c) { return 6 + b; } );
}

---

    The use of `ref` declares that the return value is returned by reference:

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
void main()
{
    int x;
    auto dg = delegate ref int() { return x; };
    dg() = 3;
    assert(x == 3);
}

---
        
)

    Note: When comparing function literals with $(LINK2 spec/function#nested,nested functions),
        the `function` form is analogous to static
        or non-nested functions, and the `delegate` form is
        analogous to non-static nested functions. I.e.
        a delegate literal can access non-static local variables in an enclosing
        function, a function literal cannot.
    

$(H4 $(ID lambda-type-inference) Delegate Inference)

    If a literal omits `function` or `delegate` and there's no
        expected type from the context, then
        it is inferred to be a delegate if it accesses a
        variable in an enclosing function, otherwise it is a function pointer.
        

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
void test()
{
    int b = 3;

    auto fp = (uint c) { return c * 2; }; // inferred as function pointer
    auto dg = (int c) { return 6 + b; }; // inferred as delegate

    static assert(!is(typeof(fp) == delegate));
    static assert(is(typeof(dg) == delegate));
}

---
        
)
    If a delegate is expected, the literal will be inferred as a delegate
        even if it accesses no variables from an enclosing function:

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
void abc(int delegate(int i)) {}
void def(uint function(uint s)) {}

void test()
{
    int b = 3;

    abc( (int c) { return 6 + b; } );  // inferred as delegate
    abc( (int c) { return c * 2; } );  // inferred as delegate

    def( (uint c) { return c * 2; } ); // inferred as function
    //def( (uint c) { return c * b; } );  // error!
    // Because the FunctionLiteral accesses b, its type
    // is inferred as delegate. But def cannot accept a delegate argument.
}

---
        
)

$(H4 $(ID lambda-parameter-inference) Parameter Type Inference)

    If the type of a function literal can be uniquely determined from its context,
        parameter type inference is possible.

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
void foo(int function(int) fp);

void test()
{
    int function(int) fp = (n) { return n * 2; };
    // The type of parameter n is inferred as int.

    foo((n) { return n * 2; });
    // The type of parameter n is inferred as int.
}

---
        
)
---
auto fp = (i) { return 1; }; // error, cannot infer type of `i`

---

$(H4 $(ID function-literal-alias) Function Literal Aliasing)

    Function literals can be $(LINK2 spec/declaration#alias,aliased).
        Aliasing a function literal with unspecified parameter types produces a
        $(LINK2 spec/template#function-template,function template)
        with type parameters for each unspecified parameter type of the literal.
        Type inference for the literal is then done when the template is instantiated.

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
alias fpt = (i) { return i; }; // ok, infer type of `i` when used
//auto fpt(T)(T i) { return i; } // equivalent

auto v = fpt(4);    // `i` is inferred as int
auto d = fpt(10.3); // `i` is inferred as double

alias fp = fpt!float;
auto f = fp(0); // f is a float

---
        
)

$(H4 $(ID lambda-return-type) Return Type Inference)

    The return type of the [#FunctionLiteral|FunctionLiteral] can be
        inferred from either the <em>AssignExpression</em>, or
        any [statement#ReturnStatement|statement, ReturnStatement]s in the $(I BlockStatement).
        If there is a different expected type from the context, and the
        initial inferred return type implicitly converts to the expected type,
        then the return type is inferred as the expected type.

    $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
auto fi = (int i) { return i; };
static assert(is(typeof(fi(5)) == int));

long function(int) fl = (int i) { return i; };
static assert(is(typeof(fl(5)) == long));

---
    
)

$(H4 $(ID lambda-short-syntax) Nullary Short Syntax)

    <em>Parameters</em> can be omitted completely for a function literal
        when there is a <em>BlockStatement</em> function body.

    Note: This form is not allowed to be immediately called as an <em>ExpressionStatement</em>,
        because it would require arbitrary lookahead to distinguish it from a <em>BlockStatement</em>.

---
auto f = { writeln("hi"); }; // OK, f has type `void function()`
f();
{ writeln("hi"); }(); // error
() { writeln("hi"); }(); // OK

---

    $(NOTE Anonymous delegates can behave like arbitrary statement literals.
        For example, here an arbitrary statement is executed by a loop:

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
void loop(int n, void delegate() statement)
{
    foreach (_; 0 .. n)
    {
        statement();
    }
}

void main()
{
    int n = 0;

    loop(5, { n += 1; });
    assert(n == 5);
}

---
        
)
    )

$(H4 $(ID lambda-short-body) Shortened Body Syntax)

    The syntax `=&gt; AssignExpression` is equivalent to `{ return AssignExpression; }`.

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
void main()
{
    auto i = 3;
    auto twice = function (int x) =&gt; x * 2;
    assert(twice(i) == 6);

    auto square = delegate () =&gt; i * i;
    assert(square() == 9);

    auto n = 5;
    auto mul_n = (int x) =&gt; x * n;
    assert(mul_n(i) == 15);
}

---
        
)

    The syntax `Identifier =&gt; AssignExpression` is equivalent to `(Identifier) { return AssignExpression; }`.

---
// the following two declarations are equivalent
alias fp = i =&gt; 1;
alias fp = (i) { return 1; };

---

    $(TIP The minimal form of the function literal is most useful as
        an argument to a template alias parameter:
---
int motor(alias fp)(int i)
{
    return fp(i) + 1;
}

int engine()
{
    return motor!(i =&gt; i * 2)(6); // returns 13
}

---
        )

    Note: The syntax `Identifier { statement; }` is not supported because it is
        easily confused with statements `x = Identifier; { statement; };`
        if the semicolons were accidentally omitted.
        


$(H3 $(ID uniform_construction_syntax) Uniform construction syntax for built-in scalar types)

    The implicit conversions of built-in scalar types can be explicitly
        represented by using function call syntax. For example:

---
auto a = short(1);  // implicitly convert an integer literal '1' to short
auto b = double(a); // implicitly convert a short variable 'a' to double
auto c = byte(128); // error, 128 cannot be represented in a byte

---

    If the argument is omitted, it means default construction of the
        scalar type:

---
auto a = ushort();  // same as: ushort.init
auto b = wchar();   // same as: wchar.init

---

    The argument may not be given a name:

---
auto a = short(x: 1); // Error

---

    See also: $(LINK2 spec/type#usual-arithmetic-conversions,Usual Arithmetic Conversions).


$(H3 $(ID assert_expressions) Assert Expressions)

$(PRE $(CLASS GRAMMAR)
$(B $(ID AssertExpression) AssertExpression):
    `assert (` [#AssertArguments|AssertArguments] `)`

$(B $(ID AssertArguments) AssertArguments):
    [#AssignExpression|AssignExpression] `,`$(SUBSCRIPT opt)
    [#AssignExpression|AssignExpression] `,` [#AssignExpression|AssignExpression] `,`$(SUBSCRIPT opt)

)

    The first $(I AssignExpression) is evaluated and converted to a boolean value.
    If the value is not `true`, an $(I Assert Failure)
    has occurred and the program enters an $(I Invalid State).
    

---
int i = fun();
assert(i &gt; 0);

---

    $(I AssertExpression) has different semantics if it is in a
    $(LINK2 spec/unittest, Unit Tests) or
    $(LINK2 spec/function#preconditions,`in` contract).
    

    If the first $(I AssignExpression) is a reference to a class instance for
    which a $(LINK2 spec/class#invariants,class <em>Invariant</em>) exists, the class $(I Invariant) must hold.
    

    If the first $(I AssignExpression) is a pointer to a struct instance for
    which a $(LINK2 spec/struct#Invariant,struct $(I Invariant)) exists, the struct $(I Invariant) must hold.
    

    The type of an $(I AssertExpression) is `void`.
    

    $(PITFALL Once in an $(I Invalid State) the behavior of the continuing execution
    of the program is undefined.)

    $(NOTE     $(WARNING Whether the first $(I AssertExpression) is evaluated
    or not (at runtime) is typically set with a compiler switch. If it is not evaluated,
    any side effects specified by the $(I AssertExpression) may not occur.
    The behavior when the first $(I AssertExpression) evaluates to `false`
    is also typically set with a compiler switch, and may include these options:
    $(NUMBERED_LIST
        * Immediately halting via execution of a special CPU instruction
        * Aborting the program
        * Calling the assert failure function in the corresponding C
        runtime library
        * Throwing the `AssertError` exception in the D runtime library
    
)
    )

    Note: Throwing `AssertError` is the default for $(B dmd), with an optional
    $(LINK2 dmd#switch-checkaction,$(B -checkaction=context))
    switch to show certain sub-expressions used in the first <em>AssertExpression</em>
    in the error message:

---
auto x = 4;
assert(x &lt; 3);

---
    When in use, the above will throw an `AssertError` with a message `4 &gt;= 3`.
    )

    $(TIP     $(NUMBERED_LIST
        * Do not have side effects in either $(I AssignExpression) that subsequent code
        depends on.
        * $(I AssertExpression)s are intended to detect bugs in the program.
        Do not use them for detecting input or environmental errors.
        * Do not attempt to resume normal execution after an $(I Assert Failure).
    
)
    )

$(H4 $(ID assert-ct) Compile-time Evaluation)

    If the first $(I AssignExpression) consists entirely of compile time constants,
    and evaluates to `false`, it is a special case - it
    signifies that subsequent statements are unreachable code.
    Compile Time Function Execution (CTFE) is not attempted.
    

    The implementation may handle the case of the first $(I AssignExpression) evaluating to `false`
    at compile time differently - even when other `assert`s are ignored,
    it may still generate a `HLT` instruction or equivalent.
    

    See also: $(LINK2 spec/version#static-assert,`static assert`).

$(H4 $(ID assert-message) Assert Message)

    The second $(I AssignExpression), if present, must be implicitly
        convertible to type `const(char)[]`.
        When present, the implementation may evaluate it and print the
        resulting message upon assert failure:
    
---
void main()
{
    assert(0, "an" ~ " error message");
}

---

    When compiled and run, it will produce the message:

    $(CONSOLE core.exception.AssertError@test.d(3) an error message)


$(H3 $(ID mixin_expressions) Mixin Expressions)

$(PRE $(CLASS GRAMMAR)
$(B $(ID MixinExpression) MixinExpression):
    `mixin (` [#ArgumentList|ArgumentList] `)`

)

    Each [#AssignExpression|AssignExpression] in the $(I ArgumentList) is
        evaluated at compile time, and the result must be representable
        as a string.
        The resulting strings are concatenated to form a string.
        The text contents of the string must be compilable as a valid
        [#Expression|Expression], and is compiled as such.

---
int foo(int x)
{
    return mixin("x +", 1) * 7;  // same as ((x + 1) * 7)
}

---

$(H3 $(ID import_expressions) Import Expressions)

$(PRE $(CLASS GRAMMAR)
$(B $(ID ImportExpression) ImportExpression):
    `import (` [#AssignExpression|AssignExpression] `)`

)

    The $(I AssignExpression) must evaluate at compile time
        to a constant string.
        The text contents of the string are interpreted as a file
        name. The file is read, and the exact contents of the file
        become a string literal.
    

    Implementations may restrict the file name in order to avoid
        directory traversal security vulnerabilities.
        A possible restriction might be to disallow any path components
        in the file name.
    

    Note that by default an import expression will not compile unless
        one or more paths are passed via the $(B -J) switch. This tells the compiler
        where it should look for the files to import. This is a security feature.

---
void foo()
{
    // Prints contents of file foo.txt
    writeln(import("foo.txt"));
}

---

$(H3 $(ID new_expressions) New Expressions)

$(PRE $(CLASS GRAMMAR)
$(B $(ID NewExpression) NewExpression):
    `new` [type#Type|type, Type]
    `new` [type#Type|type, Type] `[` [#AssignExpression|AssignExpression] `]`
    `new` [type#Type|type, Type] `(` [#NamedArgumentList|NamedArgumentList]$(SUBSCRIPT opt) `)`
    [class#NewAnonClassExpression|class, NewAnonClassExpression]

)

    $(I NewExpression)s allocate memory on the
        $(LINK2 spec/garbage, Garbage Collection) heap by default.
    

    The `new` <em>Type</em> form constructs an instance of a type and default-initializes it.
    The <em>Type(NamedArgumentList)</em> form allows passing either a single initializer
        of the same type, or multiple arguments for more complex types.
        For class types, <em>NamedArgumentList</em> is passed to the class constructor.
        For a dynamic array, the argument sets the initial array length.
        For multidimensional dynamic arrays, each argument corresponds to
        an initial length (see [#new_multidimensional|below]).

    $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
int* i = new int;
assert(*i == 0);
i = new int(5);
assert(*i == 5);

Object o = new Object;
Exception e = new Exception("info");

auto a = new int[](2);
assert(a.length == 2);

---
    
)

    The <em>Type[AssignExpression]</em> form allocates a dynamic array with
        length equal to <em>AssignExpression</em>.
        It is preferred to use the <em>Type(NamedArgumentList)</em> form when allocating
        dynamic arrays instead, as it is more general.

    Note: It is not possible to allocate a static array directly with
        `new` (only by using a type alias).

    The result is a $(LINK2 const3#unique-expressions,unique expression)
    which can implicitly convert to other qualifiers:

---
immutable o = new Object;

---

$(H4 $(ID new_class) Class Instantiation)

    If a $(I NewExpression) is used with a class type as an initializer for
        a function local variable with $(LINK2 spec/attribute#scope,`scope`) storage class,
        then the instance is $(LINK2 spec/attribute#scope-class-var,allocated on the stack).
    

    `new` can also be used to allocate a
        $(LINK2 spec/class#nested-explicit,nested class).

$(H4 $(ID new_multidimensional) Multidimensional Arrays)

    To allocate multidimensional arrays, the declaration reads
        in the same order as the prefix array declaration order.

---
char[][] foo;   // dynamic array of strings
...
foo = new char[][30]; // allocate array of 30 strings

---

    The above allocation can also be written as:

---
foo = new char[][](30); // allocate array of 30 strings

---

    To allocate the nested arrays, multiple arguments can be used:

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
int[][][] bar;
bar = new int[][][](5, 20, 30);

assert(bar.length == 5);
assert(bar[0].length == 20);
assert(bar[0][0].length == 30);

---
        
)

    The assignment above is equivalent to:

---
bar = new int[][][5];
foreach (ref a; bar)
{
    a = new int[][20];
    foreach (ref b; a)
    {
        b = new int[30];
    }
}

---

$(H3 $(ID typeid_expressions) Typeid Expressions)

$(PRE $(CLASS GRAMMAR)
$(B $(ID TypeidExpression) TypeidExpression):
    `typeid (` [type#Type|type, Type] `)`
    `typeid (` [#Expression|Expression] `)`

)

    If $(I Type), returns an instance of class
        [phobos/object.html, `TypeInfo`]
        corresponding
        to $(I Type).
    

    If $(I Expression), returns an instance of class
        [phobos/object.html, `TypeInfo`]
        corresponding
        to the type of the $(I Expression).
        If the type is a class, it returns the `TypeInfo`
        of the dynamic type (i.e. the most derived type).
        The $(I Expression) is always executed.

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
class A { }
class B : A { }

void main()
{
    import std.stdio;

    writeln(typeid(int));        // int
    uint i;
    writeln(typeid(i++));        // uint
    writeln(i);                  // 1
    A a = new B();
    writeln(typeid(a));          // B
    writeln(typeid(typeof(a)));  // A
}

---
        
)

$(H3 $(ID is_expression) Is Expressions)

$(PRE $(CLASS GRAMMAR)
$(B $(ID IsExpression) IsExpression):
    `is (` [type#Type|type, Type] `)`
    `is (` [type#Type|type, Type] `:` [#TypeSpecialization|TypeSpecialization] `)`
    `is (` [type#Type|type, Type] `==` [#TypeSpecialization|TypeSpecialization] `)`
    `is (` [type#Type|type, Type] `:` [#TypeSpecialization|TypeSpecialization] `,` [template#TemplateParameterList|template, TemplateParameterList] `)`
    `is (` [type#Type|type, Type] `==` [#TypeSpecialization|TypeSpecialization] `,` [template#TemplateParameterList|template, TemplateParameterList] `)`
    `is (` [type#Type|type, Type] $(LINK2 lex#Identifier, Identifier) `)`
    `is (` [type#Type|type, Type] $(LINK2 lex#Identifier, Identifier) `:` [#TypeSpecialization|TypeSpecialization] `)`
    `is (` [type#Type|type, Type] $(LINK2 lex#Identifier, Identifier) `==` [#TypeSpecialization|TypeSpecialization] `)`
    `is (` [type#Type|type, Type] $(LINK2 lex#Identifier, Identifier) `:` [#TypeSpecialization|TypeSpecialization] `,` [template#TemplateParameterList|template, TemplateParameterList] `)`
    `is (` [type#Type|type, Type] $(LINK2 lex#Identifier, Identifier) `==` [#TypeSpecialization|TypeSpecialization] `,` [template#TemplateParameterList|template, TemplateParameterList] `)`


$(B $(ID TypeSpecialization) TypeSpecialization):
    [type#Type|type, Type]
    [type#TypeCtor|type, TypeCtor]
    `struct`
    `union`
    `class`
    `interface`
    `enum`
    `__vector`
    `function`
    `delegate`
    `super`
    `return`
    `__parameters`
    `module`
    `package`

)

    An $(I IsExpression) is evaluated at compile time and is
        used to check if an expression is a valid type. In addition,
        there are forms which can also:
    $(LIST
    * compare types for equivalence
    * determine if one type can be implicitly converted to another
    * deduce the subtypes of a type using
        [#is-parameter-list|pattern matching]
    * deduce the template arguments of a type template instance
    
)
            The result of an $(I IsExpression) is a boolean which is `true`
        if the condition is satisfied and `false` if not.
    

    $(I Type) is the type being tested. It must be syntactically
        correct, but it need not be semantically correct.
        If it is not semantically correct, the condition is not satisfied.
    

    $(I TypeSpecialization) is the type that $(I Type) is being
        pattern matched against.
    

    $(I IsExpression)s may be used in conjunction with
    $(LINK2 spec/type#typeof,`typeof`) to check
    whether an expression type checks correctly. For example, `is(typeof(foo))`
    will return `true` if `foo` has a valid type.
    

$(H4 $(ID basic-forms) Basic Forms)

        $(H5 $(ID is-type) `is (` $(I Type) `)`)

                The condition is satisfied if $(I Type) is semantically
        correct. <em>Type</em> must be syntactically correct regardless.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
pragma(msg, is(5)); // error
pragma(msg, is([][])); // error

---

)
$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
int i;
static assert(is(int));
static assert(is(typeof(i))); // same

static assert(!is(Undefined));
static assert(!is(typeof(int))); // int is not an expression
static assert(!is(i)); // i is a value

alias Func = int(int); // function type
static assert(is(Func));
static assert(!is(Func[])); // fails as an array of functions is not allowed

---

)
        $(H5 $(ID is-type-convert) `is (` $(I Type) `:` $(I TypeSpecialization) `)`)

                The condition is satisfied if $(I Type) is semantically
        correct and it is the same as
        or can be implicitly converted to $(I TypeSpecialization).
        $(I TypeSpecialization) is only allowed to be a $(I Type).
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
alias Bar = short;
static assert(is(Bar : int)); // short implicitly converts to int
static assert(!is(Bar : string));

---

)
        $(H5 $(ID is-type-equal) `is (` $(I Type) `==` $(I TypeSpecialization) `)`)

                If <em>TypeSpecialization</em> is a type,
        the condition is satisfied if $(I Type) is semantically correct and is
        the same type as $(I TypeSpecialization).
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
alias Bar = short;
static assert(is(Bar == short));
static assert(!is(Bar == int));

---

)
                If <em>TypeSpecialization</em> is a [type#TypeCtor|type, TypeCtor]
        then the condition is satisfied if <em>Type</em> is of that <em>TypeCtor</em>:
        
$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
static assert(is(const int == const));
static assert(is(const int[] == const));
static assert(!is(const(int)[] == const)); // head is mutable
static assert(!is(immutable int == const));

---

)
                If $(I TypeSpecialization) is one of
                `struct`
                `union`
                `class`
                `interface`
                `enum`
                `__vector`
                `function`
                `delegate`
                `module`
                `package`
        then the condition is satisfied if $(I Type) is one of those.
        
$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
static assert(is(Object == class));
static assert(is(ModuleInfo == struct));
static assert(!is(int == class));

---

)
        The `module` and `package` forms are satisfied when <em>Type</em> is a symbol, not a <em>type</em>,
        unlike the other forms. The $(LINK2 spec/traits#isModule,isModule)
        and $(LINK2 spec/traits#isPackage,isPackage) `__traits` should be used instead.
        $(LINK2 spec/module#package-module,Package modules) are considered to be both
        packages and modules.
        
                <em>TypeSpecialization</em> can also be one of these keywords:
        
        $(TABLE         * + keyword
+ condition

        * - `super`
- `true` if <em>Type</em> is a class or interface

        * - `return`
-             `true` if <em>Type</em> is a function, delegate or function pointer

        * - `__parameters`
-             `true` if <em>Type</em> is a function, delegate or function pointer

        )
        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
class C {}
static assert(is(C == super));

void foo(int i);
static assert(!is(foo == return));
static assert(is(typeof(foo) == return));
static assert(is(typeof(foo) == __parameters));

---
        
)
        $(B See also:) $(LINK2 spec/traits, Traits).


$(H4 $(ID is-identifier) Identifier Forms)

    <em>Identifier</em> is declared to be an alias of the resulting
        type if the condition is satisfied. The <em>Identifier</em> forms
        can only be used if the $(I IsExpression) appears in a
        [version#StaticIfCondition|version, StaticIfCondition] or the first argument of a
        [version#StaticAssert|version, StaticAssert].
    

        $(H5 $(ID is-type-identifier) `is (` $(I Type) $(I Identifier) `)`)

                The condition is satisfied if $(I Type) is semantically
        correct. If so, $(I Identifier)
        is declared to be an alias of $(I Type).
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
struct S
{
    int i, j;
}
static assert(is(typeof(S.i) T) &amp;&amp; T.sizeof == 4);

---

)
$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
alias Bar = short;

void foo()
{
    static if (is(Bar T))
        alias S = T;
    else
        alias S = long;

    pragma(msg, S); // short

    // if T was defined, it remains in scope
    if (is(T))
        pragma(msg, T); // short

    //if (is(Bar U)) {} // error, cannot declare U here
}

---

)

        $(H5 $(ID is-identifier-convert) `is (` $(I Type) $(I Identifier) `:` $(I TypeSpecialization) `)`
        

                If <em>TypeSpecialization</em> is a type,
        the condition is satisfied if $(I Type) is semantically
        correct and it is the same as
        or can be implicitly converted to $(I TypeSpecialization).
        $(I Identifier) is declared to be an alias of the
        $(I TypeSpecialization).
        

    $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
alias Bar = int;

static if (is(Bar T : int))
    alias S = T;
else
    alias S = long;

static assert(is(S == int));

---
    
)
                If $(I TypeSpecialization) is a type pattern involving
        $(I Identifier), type deduction of $(I Identifier) is attempted
        based on either <em>Type</em> or a type that it implicitly converts to.
        The condition is only satisfied if the type pattern is matched.
        

    $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
struct S
{
    long* i;
    alias i this; // S converts to long*
}

static if (is(S U : U*)) // S is matched against the pattern U*
{
    U u;
}
static assert(is(U == long));

---
    
)

                The way the type of $(I Identifier) is determined is analogous
        to the way template parameter types are determined by
        [template#TemplateTypeParameterSpecialization|template, TemplateTypeParameterSpecialization].
        

        $(H5 $(ID is-identifier-equal) `is (` $(I Type) $(I Identifier) `==` $(I TypeSpecialization) `)`)

                If <em>TypeSpecialization</em> is a type,
        the condition is satisfied if $(I Type) is semantically correct and is
        the same type as $(I TypeSpecialization).
        $(I Identifier) is declared to be an alias of the
        $(I TypeSpecialization).
        
    $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
const x = 5;

static if (is(typeof(x) T == const int))   // satisfied, T is now defined
    alias S = T;

static assert(is(T)); // T is in scope
pragma(msg, T); // const int

---
    
)

                If $(I TypeSpecialization) is a type pattern involving
        $(I Identifier), type deduction of $(I Identifier) is attempted
        based on <em>Type</em>.
        The condition is only satisfied if the type pattern is matched.
        
    $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
alias Foo = long*;

static if (is(Foo U == U*)) // Foo is matched against the pattern U*
{
    U u;
}
static assert(is(U == long));

---
    
)
                If <em>TypeSpecialization</em> is a valid keyword for the
        [#is-type-equal|`is(Type == Keyword)` form],
        the condition is satisfied in the same manner.
        $(I Identifier) is set as follows:
        

        $(TABLE_ROWS

        * + keyword
+ alias type for $(I Identifier)


        * - `struct`
- $(I Type)

        * - `union`
- $(I Type)

        * - `class`
- $(I Type)

        * - `interface`
- $(I Type)

        * - `super`
- $(I TypeSeq) of base classes and interfaces

        * - `enum`
- the base type of the enum

        * - `__vector`
- the static array type of the vector

        * - `function`
- $(I TypeSeq) of the function parameter types.
             For C- and D-style variadic functions,
             only the non-variadic parameters are included.
             For typesafe variadic functions, the `...` is ignored.

        * - `delegate`
- the function type of the delegate

        * - `return`
- the return type of the function, delegate, or function pointer

        * - `__parameters`
- the parameter sequence of a function, delegate, or function pointer.
         This includes the parameter types, names, and default values.

        * - `const`
- $(I Type)

        * - `immutable`
- $(I Type)

        * - `inout`
- $(I Type)

        * - `shared`
- $(I Type)

        * - `module`
- the module

        * - `package`
- the package

        
)

    $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
enum E : byte { Emember }

static if (is(E V == enum))    // satisfied, E is an enum
    V v;                       // v is declared to be a byte

static assert(is(V == byte));

---
    
)

$(H4 $(ID is-parameter-list) Parameter List Forms)

$(PRE $(CLASS GRAMMAR_INFORMATIVE)`is (` $(I Type) `:` $(I TypeSpecialization) `,` [template#TemplateParameterList|template, TemplateParameterList] `)`
`is (` $(I Type) `==` $(I TypeSpecialization) `,` [template#TemplateParameterList|template, TemplateParameterList] `)`
`is (` $(I Type) $(I Identifier) `:` $(I TypeSpecialization) `,` [template#TemplateParameterList|template, TemplateParameterList] `)`
`is (` $(I Type) $(I Identifier) `==` $(I TypeSpecialization) `,` [template#TemplateParameterList|template, TemplateParameterList] `)`
)

                More complex types can be pattern matched. The
        $(I TemplateParameterList) declares symbols based on the
        parts of the pattern that are matched, analogously to the
        way $(LINK2 spec/template#parameters_specialization,        implied template parameters) are matched.
        

$(B Example:) Matching a Template Instantiation)

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
struct Tuple(T...)
{
    // ...
}
alias Tup2 = Tuple!(int, string);

static if (is(Tup2 : Template!Args, alias Template, Args...))
{
    static assert(__traits(isSame, Template, Tuple));
    static assert(is(Template!(int, string) == Tup2)); // same struct
}
static assert(is(Args[0] == int));
static assert(is(Args[1] == string));

---

)

        <em>Type</em> cannot be matched when <em>TypeSpecialization</em> is an
        $(LINK2 spec/template#alias-template,alias template) instance:
        

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
struct S(T) {}
alias A(T) = S!T;

static assert(is(A!int : S!T, T));
//static assert(!is(A!int : A!T, T));

---
        
)

$(B Example:) Matching an Associative Array

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
alias AA = long[string];

static if (is(AA T : T[U], U : string)) // T[U] is the pattern
{
    pragma(msg, T);  // long
    pragma(msg, U);  // string
}

// no match, B is not an int
static assert(!is(AA A : A[B], B : int));

---

)

$(B Example:) Matching a Static Array

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
static if (is(int[10] W : W[len], int len)) // W[len] is the pattern
{
    static assert(len == 10);
}
static assert(is(W == int));

// no match, len should be 10
static assert(!is(int[10] X : X[len], int len : 5));

---

)


$(H3 $(ID specialkeywords) Special Keywords)

$(PRE $(CLASS GRAMMAR)
$(B $(ID SpecialKeyword) SpecialKeyword):
    [#specialkeywords|`__FILE__`]
    [#specialkeywords|`__FILE_FULL_PATH__`]
    [#specialkeywords|`__MODULE__`]
    [#specialkeywords|`__LINE__`]
    [#specialkeywords|`__FUNCTION__`]
    [#specialkeywords|`__PRETTY_FUNCTION__`]

)


    `__FILE__` and `__LINE__` expand to the source
    file name and line number at the point of instantiation. The path of
    the source file is left up to the compiler. 

    `__FILE_FULL_PATH__` expands to the absolute source
    file name at the point of instantiation.

    `__MODULE__` expands to the module name at the point of
    instantiation.

    `__FUNCTION__` expands to the fully qualified name of the
    function at the point of instantiation.

    `__PRETTY_FUNCTION__` is similar to `__FUNCTION__`,
    but also expands the function return type, its parameter types,
    and its attributes.

    Example:

    $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
module test;
import std.stdio;

void test(string file = __FILE__, size_t line = __LINE__,
        string mod = __MODULE__, string func = __FUNCTION__,
        string pretty = __PRETTY_FUNCTION__,
        string fileFullPath = __FILE_FULL_PATH__)
{
    writefln("file: '%s', line: '%s', module: '%s',\nfunction: '%s', " ~
        "pretty function: '%s',\nfile full path: '%s'",
        file, line, mod, func, pretty, fileFullPath);
}

int main(string[] args)
{
    test();
    return 0;
}

---
    
)

    Assuming the file was at /example/test.d, this will output:

$(CONSOLE file: 'test.d', line: '13', module: 'test',
function: 'test.main', pretty function: 'int test.main(string[] args)',
file full path: '/example/test.d'
)

$(H2 $(ID associativity) Associativity and Commutativity)

    An implementation may rearrange the evaluation of expressions
        according to arithmetic associativity and commutativity rules
        as long as, within that thread of execution, no observable
        difference is possible.
    

    This rule precludes any associative or commutative reordering of
        floating point expressions.
    
pragma, Pragmas, statement, Statements




Link_References:
	ACC = Associated C Compiler
+/
module expression.dd;