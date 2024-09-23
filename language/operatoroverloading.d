// just docs: Operator Overloading
/++





        Operator overloading is accomplished by rewriting operators whose
        operands are class or struct objects into calls to specially named
        members. No additional syntax is used.
        

$(H2 $(ID unary)Unary Operator Overloading)

        $(TABLE_ROWS
Overloadable Unary Operators
        * + $(I op)
+ $(I rewrite)

        * -         `-`$(I e)
-         $(I e)`.opUnary!("-")()`
        

        * -         `+`$(I e)
-         $(I e)`.opUnary!("+")()`
        

        * -         `~`$(I e)
-         $(I e)`.opUnary!("~")()`
        


        * -         `*`$(I e)
-         $(I e)`.opUnary!("*")()`
        


        * -         `++`$(I e)
-         $(I e)`.opUnary!("++")()`
        


        * -         `--`$(I e)
-         $(I e)`.opUnary!("--")()`
        

        
)

        For example, in order to overload the `-` (negation) operator for struct S, and
        no other operator:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
struct S
{
    int m;

    int opUnary(string s)() if (s == "-")
    {
        return -m;
    }
}

void main()
{
    S s = {2};
    assert(-s == -2);
}

---

)

Note: <em>opUnary</em> above can also be declared using a template parameter specialization:
---
    int opUnary(string s : "-")()

---

$(H3 $(ID postincrement_postdecrement_operators) Postincrement $(I e)`++` and Postdecrement $(I e)`--` Operators)

        These are not directly overloadable, but instead are rewritten
        in terms of the ++$(I e) and --$(I e) prefix operators:
        

        $(TABLE_ROWS
Postfix Operator Rewrites
        * + $(I op)
+ $(I rewrite)

        * -         $(I e)`--`
-         `(auto t =` $(I e)`, `$(I e)`.opUnary!"--"``, t)`

        * -         $(I e)`++`
-         `(auto t =` $(I e)`, `$(I e)`.opUnary!"++"``, t)`

        
)

$(H3 $(ID index_unary_operators) Overloading Index Unary Operators)

        Indexing can be [#array|overloaded].
        A unary operation on an index expression can also be overloaded independently.
        This works for multidimensional indexing.

        $(TABLE_ROWS
Overloadable Index Unary Operators
        * + $(I op)
+ $(I rewrite)

        * -         `-`$(I a)`[`$(I b)$(SUBSCRIPT 1), $(I b)$(SUBSCRIPT 2), ... $(I b)$(SUBSCRIPT n)`]`
-         $(I a)`.opIndexUnary!("-")(`$(I b)$(SUBSCRIPT 1), $(I b)$(SUBSCRIPT 2), ... $(I b)$(SUBSCRIPT n)`)`

        * -         `+`$(I a)`[`$(I b)$(SUBSCRIPT 1), $(I b)$(SUBSCRIPT 2), ... $(I b)$(SUBSCRIPT n)`]`
-         $(I a)`.opIndexUnary!("+")(`$(I b)$(SUBSCRIPT 1), $(I b)$(SUBSCRIPT 2), ... $(I b)$(SUBSCRIPT n)`)`
        

        * -         `~`$(I a)`[`$(I b)$(SUBSCRIPT 1), $(I b)$(SUBSCRIPT 2), ... $(I b)$(SUBSCRIPT n)`]`
-         $(I a)`.opIndexUnary!("~")(`$(I b)$(SUBSCRIPT 1), $(I b)$(SUBSCRIPT 2), ... $(I b)$(SUBSCRIPT n)`)`
        

        * -         `*`$(I a)`[`$(I b)$(SUBSCRIPT 1), $(I b)$(SUBSCRIPT 2), ... $(I b)$(SUBSCRIPT n)`]`
-         $(I a)`.opIndexUnary!("*")(`$(I b)$(SUBSCRIPT 1), $(I b)$(SUBSCRIPT 2), ... $(I b)$(SUBSCRIPT n)`)`
        

        * -         `++`$(I a)`[`$(I b)$(SUBSCRIPT 1), $(I b)$(SUBSCRIPT 2), ... $(I b)$(SUBSCRIPT n)`]`
-         $(I a)`.opIndexUnary!("++")(`$(I b)$(SUBSCRIPT 1), $(I b)$(SUBSCRIPT 2), ... $(I b)$(SUBSCRIPT n)`)`
        

        * -         `--`$(I a)`[`$(I b)$(SUBSCRIPT 1), $(I b)$(SUBSCRIPT 2), ... $(I b)$(SUBSCRIPT n)`]`
-         $(I a)`.opIndexUnary!("--")(`$(I b)$(SUBSCRIPT 1), $(I b)$(SUBSCRIPT 2), ... $(I b)$(SUBSCRIPT n)`)`
        

        
)

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
struct S
{
    private int[] a;

    void opIndexUnary(string s: "++")(size_t i) { ++a[i]; }
}

S s = {[4]};
++s[0];
assert(s.a[0] == 5);

---

)

$(H3 $(ID slice_unary_operators) Overloading Slice Unary Operators)

        Slicing can be [#slice|overloaded].
        A unary operation on a slice can also be overloaded independently.
        `opIndexUnary` is defined either with no function arguments for a full slice,
        or with two arguments for the start and end indices of the slice.

        $(TABLE_ROWS
Overloadable Slice Unary Operators
        * + $(I op)
+ $(I rewrite)

        * -         `-`$(I a)`[`$(I i)..$(I j)`]`
-         $(I a)`.opIndexUnary!("-")(`$(I a)`.opSlice(`$(I i), $(I j)`))`
        


        * -         `+`$(I a)`[`$(I i)..$(I j)`]`
-         $(I a)`.opIndexUnary!("+")(`$(I a)`.opSlice(`$(I i), $(I j)`))`
        


        * -         `~`$(I a)`[`$(I i)..$(I j)`]`
-         $(I a)`.opIndexUnary!("~")(`$(I a)`.opSlice(`$(I i), $(I j)`))`
        


        * -         `*`$(I a)`[`$(I i)..$(I j)`]`
-         $(I a)`.opIndexUnary!("*")(`$(I a)`.opSlice(`$(I i), $(I j)`))`
        


        * -         `++`$(I a)`[`$(I i)..$(I j)`]`
-         $(I a)`.opIndexUnary!("++")(`$(I a)`.opSlice(`$(I i), $(I j)`))`
        


        * -         `--`$(I a)`[`$(I i)..$(I j)`]`
-         $(I a)`.opIndexUnary!("--")(`$(I a)`.opSlice(`$(I i), $(I j)`))`
        


        * -         `-`$(I a)`[ ]`
-         $(I a)`.opIndexUnary!("-")()`
        


        * -         `+`$(I a)`[ ]`
-         $(I a)`.opIndexUnary!("+")()`
        


        * -         `~`$(I a)`[ ]`
-         $(I a)`.opIndexUnary!("~")()`
        


        * -         `*`$(I a)`[ ]`
-         $(I a)`.opIndexUnary!("*")()`
        


        * -         `++`$(I a)`[ ]`
-         $(I a)`.opIndexUnary!("++")()`
        


        * -         `--`$(I a)`[ ]`
-         $(I a)`.opIndexUnary!("--")()`
        

        
)

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
struct S
{
    private int[] a;

    void opIndexUnary(string s: "--")() { --a[]; }
}

S s = {[1, 2]};
--s[];
assert(s.a == [0, 1]);

---

)

        Note: For backward compatibility, if the above rewrites fail to compile and
        `opSliceUnary` is defined, then the rewrites
        `a.opSliceUnary!(op)(i, j)` and
        `a.opSliceUnary!(op)` are tried instead, respectively.

$(H2 $(ID cast)Cast Operator Overloading)

    To define how one type can be cast to another, define the
      `opCast` template method, which is used as follows:
        $(TABLE_ROWS
Cast Operators
        * + $(I op)
+ $(I rewrite)

        * -         `cast(`$(I type)`)` $(I e)
-         $(I e)`.opCast!(`$(I type)`)()`
        

        
)

    Note that `opCast` is only ever used with an explicit `cast`
        expression, except in the case of boolean operations (see next
        section).

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
struct S
{
    void* mem;

    bool opCast(T)()
    if (is(T == bool)) =&gt; mem !is null;
}

S s = S(new int);
auto b = cast(bool) s;
assert(b);
//b = s; // error

---

)
    If the return type of `opCast` differs from the <em>type</em> parameter of
        the `cast`, then the result is implicitly converted to <em>type</em>.

$(H3 $(ID boolean_operators) Boolean Operations)

        Notably absent from the list of overloaded unary operators is the `!`
        logical negation operator. More obscurely absent is a unary operator
        to convert to a `bool` result.
        Instead, for structs these are covered by a rewrite to:
        
---
opCast!(bool)(e)

---

        So,

---
if (e)   =&gt;  if (e.opCast!(bool))
if (!e)  =&gt;  if (!e.opCast!(bool))

---

        and similarly for other boolean conditional expressions and
        $(LINK2 spec/expression#logical_expressions,logical operators) used
        on the struct instance.

        This only happens, however, for
        instances of structs. Class references are converted to `bool` by checking to
        see if the class reference is null or not.
        


$(H2 $(ID binary)Binary Operator Overloading)

        The following binary operators are overloadable:

        $(TABLE_ROWS
Overloadable Binary Operators
        * - `+`
- `-`
- `*`
- `/`
- %
- `^^`
- &

        * - |
- `^`
- `&lt;``&lt;`
- `&gt;``&gt;`
- `&gt;``&gt;``&gt;`
- `~`
- $(LINK2 spec/expression#InExpression,`in`)

        
)

        The expression:
---
a op b

---
        is rewritten as one of:
---
a.opBinary!("op")(b)
b.opBinaryRight!("op")(a)

---

        and the one with the 'better' match is selected.
        It is an error for both to equally match. Example:
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
struct S
{
    int[] data;

    // this ~ rhs
    int[] opBinary(string op : "~")(int rhs)
    {
        return data ~ rhs;
    }
    // lhs ~ this
    int[] opBinaryRight(string op : "~")(int lhs)
    {
        return lhs ~ data;
    }
}

void main()
{
    auto s = S([2,3]);
    assert(s ~ 4 == [2,3,4]); // opBinary
    assert(1 ~ s == [1,2,3]); // opBinaryRight
}

---

)

        Operator overloading for a number of operators can be done at the same time.
        For example, if only the + or - operators are supported:

---
T opBinary(string op)(T rhs)
{
    static if (op == "+") return data + rhs.data;
    else static if (op == "-") return data - rhs.data;
    else static assert(0, "Operator "~op~" not implemented");
}

---

        To do them all en masse:

---
T opBinary(string op)(T rhs)
{
    return mixin("data "~op~" rhs.data");
}

---

        Note that `opIn` and `opIn_r` have been deprecated in favor of
        `opBinary!"in"` and `opBinaryRight!"in"` respectively.

$(H2 $(ID eqcmp) Overloading the Comparison Operators)

        D allows overloading of the comparison operators `==`, `!=`,
        `&lt;`, `&lt;=`, `&gt;=`, `&gt;` via two functions, `opEquals` and
        `opCmp`.

        The equality and inequality operators are treated separately
        from comparison operators
        because while practically all user-defined types can be compared for
        equality, only a subset of types have a meaningful ordering. For
        example, while it makes sense to determine if two RGB color vectors are
        equal, it is not meaningful to say that one color is greater than
        another, because colors do not have an ordering. Thus, one would define
        `opEquals` for a `Color` type, but not `opCmp`.

        Furthermore, even with orderable types, the order relation may not
        be linear. For example, one may define an ordering on sets via the
        subset relation, such that `x &lt; y` is true if `x` is a (strict)
        subset of `y`. If `x` and `y` are disjoint sets, then neither
        `x &lt; y` nor `y &lt; x` holds, but that does not imply that
        `x == y`. Thus, it is insufficient to determine equality purely based on
        `opCmp` alone. For this reason, `opCmp` is only used for the
        inequality operators `&lt;`, `&lt;=`, `&gt;=`, and `&gt;`. The equality
        operators `==` and `!=` always employ `opEquals` instead.

        Therefore, it is the programmer's responsibility to ensure that
        `opCmp` and `opEquals` are consistent with each other. If
        `opEquals` is not specified, the compiler provides a default version
        that does member-wise comparison. If this suffices, one may define only
        `opCmp` to customize the behaviour of the inequality operators.  But
        if not, then a custom version of `opEquals` should be defined as
        well, in order to preserve consistent semantics between the two kinds
        of comparison operators.

        Finally, if the user-defined type is to be used as a key in the
        built-in associative arrays, then the programmer must ensure that the
        semantics of `opEquals` and `toHash` are consistent. If not, the
        associative array may not work in the expected manner.

$(H3 $(ID equals) Overloading `==` and `!=`)

        Expressions of the form `a != b` are rewritten as `!(a == b)`.

        Given `a == b` :

$(NUMBERED_LIST
        * If a and b are both class objects, then the expression is rewritten as:
---
.object.opEquals(a, b)

---
        and that function is implemented as:
---
bool opEquals(Object a, Object b)
{
    if (a is b) return true;
    if (a is null || b is null) return false;
    if (typeid(a) == typeid(b)) return a.opEquals(b);
    return a.opEquals(b) &amp;&amp; b.opEquals(a);
}

---
        
        * Otherwise the expressions `a.opEquals(b)` and
        `b.opEquals(a)` are tried. If both resolve to the same `opEquals` function, then the expression is rewritten to be `a.opEquals(b)`.
        
        * If one is a better match than the other, or one compiles and the other
        does not, the first is selected.
        * Otherwise, an error results.

)

        If overriding `Object.opEquals()` for classes, the class member
        function signature should look like:
---
class C
{
    override bool opEquals(Object o) { ... }
}

---

        If structs declare an `opEquals` member function for the
        identity comparison, it could have several forms, such as:
---
struct S
{
    // lhs should be mutable object
    bool opEquals(const S s) { ... }        // for r-values (e.g. temporaries)
    bool opEquals(ref const S s) { ... }    // for l-values (e.g. variables)

    // both hand side can be const object
    bool opEquals(const S s) const { ... }  // for r-values (e.g. temporaries)
}

---

        Alternatively, declare a single templated `opEquals`
        function with an $(LINK2 spec/template#auto-ref-parameters,auto ref)
        parameter:
---
struct S
{
    // for l-values and r-values,
    // with converting both hand side implicitly to const
    bool opEquals()(auto ref const S s) const { ... }
}

---


$(H3 $(ID compare) Overloading `&lt;`)

        Comparison operations are rewritten as follows:

        $(TABLE_ROWS
Rewriting of comparison operations
        * + comparison
+ rewrite 1
+ rewrite 2

        * - `a` `&lt;` `b`
- `a.opCmp(b)` `&lt;`
        `0`
- `b.opCmp(a)` `&gt;` `0`

        * - `a` `&lt;``= b`
- `a.opCmp(b)`
        `&lt;``= 0`
- `b.opCmp(a)` `&gt;``= 0`

        * - `a` `&gt;` `b`
- `a.opCmp(b)`
        `&gt;` `0`
- `b.opCmp(a)` `&lt;` `0`

        * - `a` `&gt;``= b`
- `a.opCmp(b)`
        `&gt;``= 0`
- `b.opCmp(a)` `&lt;``= 0`

        
)

        Both rewrites are tried. If only one compiles, that one is taken.
        If they both resolve to the same function, the first rewrite is done.
        If they resolve to different functions, the best matching one is used.
        If they both match the same, but are different functions, an ambiguity
        error results.
---
struct B
{
    int opCmp(int)         { return -1; }
    int opCmp(ref const S) { return -1; }
    int opCmp(ref const C) { return -1; }
}

struct S
{
    int opCmp(ref const S) { return 1; }
    int opCmp(ref B)       { return 0; }
}

struct C
{
    int opCmp(ref const B) { return 0; }
}

void main()
{
    S s;
    const S cs;
    B b;
    C c;
    assert(s &gt; s);      // s.opCmp(s) &gt; 0
    assert(!(s &lt; b));   // s.opCmp(b) &gt; 0  - S.opCmp(ref B) is exact match
    assert(!(b &lt; s));   // s.opCmp(b) &lt; 0  - S.opCmp(ref B) is exact match
    assert(b &lt; cs);     // b.opCmp(s) &lt; 0  - B.opCmp(ref const S) is  exact match
    static assert(!__traits(compiles, b &lt; c)); // both C.opCmp and B.opcmp match exactly
}

---
        If overriding `Object.opCmp()` for classes, the class member
        function signature should look like:
---
class C
{
    override int opCmp(Object o) { ... }
}

---

        If structs declare an `opCmp` member function, it should have
        the following form:
---
struct S
{
    int opCmp(ref const S s) const { ... }
}

---
        Note that `opCmp` is only used for the inequality operators;
        expressions like `a == b` always uses `opEquals`. If `opCmp`
        is defined but `opEquals` isn't, the compiler will supply a default
        version of `opEquals` that performs member-wise comparison. If this
        member-wise comparison is not consistent with the user-defined
        `opCmp`, then it is up to the programmer to supply an appropriate
        version of `opEquals`.  Otherwise, inequalities like `a &lt;= b`
        will behave inconsistently with equalities like `a == b`.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
struct S
{
    int i, j;
    int opCmp(ref const S s) const { return (i &gt; s.i) - (i &lt; s.i); } // ignore j
}

S a = {2, 3};
S b = {2, 1};
S c = {3, 0};
assert(a &lt; c);
assert(a &lt;= b);
assert(!(a &lt; b)); // opCmp ignores j
assert(a != b);   // generated opEquals tests both i and j members

---

)

$(TIP Using `(i &gt; s.i) - (i &lt; s.i)` instead of `i - s.i` to
compare integers avoids overflow.)


$(H2 $(ID function-call)Function Call Operator Overloading)

        The function call operator, `()`, can be overloaded by
        declaring a function named `opCall`:
        

---
struct F
{
    int /* adrdox_highlight{ */opCall/* }adrdox_highlight */();
    int /* adrdox_highlight{ */opCall/* }adrdox_highlight */(int x, int y, int z);
}

void test()
{
    F f;
    int i;

    i = f();      // same as i = f.opCall();
    i = f(3,4,5); // same as i = f.opCall(3,4,5);
}

---

        In this way a struct or class object can behave as if it
        were a function.
        

        Note that merely declaring `opCall` automatically disables
        $(LINK2 spec/struct#StructLiteral,struct literal) syntax.
        To avoid the limitation, declare a
        $(LINK2 spec/struct#Struct-Constructor,constructor)
        so that it takes priority over `opCall` in `Type(...)` syntax.
        

    $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
struct Multiplier
{
    int factor;
    this(int num) { factor = num; }
    int opCall(int value) { return value * factor; }
}

void main()
{
    Multiplier m = Multiplier(10);  // invoke constructor
    assert(m.factor == 10);
    int result = m(5);              // invoke opCall
    assert(result == 50);
}

---
    
)

$(H3 $(ID static-opcall) Static opCall)

        `static opCall` also works as expected for a function call operator with
        type names.
        

---
struct Double
{
    /* adrdox_highlight{ */static/* }adrdox_highlight */ int /* adrdox_highlight{ */opCall/* }adrdox_highlight */(int x) { return x * 2; }
}
void test()
{
    int i = Double(2);
    assert(i == 4);
}

---

        Mixing struct constructors and `static opCall` is not allowed.

---
struct S
{
    this(int i) {}
    static S opCall()  // disallowed due to constructor
    {
        return S.init;
    }
}

---

        Note: `static opCall` can be used to simulate struct
        constructors with no arguments, but this is not recommended
        practice. Instead, the preferred solution is to use a factory
        function to create struct instances.
        

$(H2 $(ID assignment)Assignment Operator Overloading)

        The assignment operator `=` can be overloaded if the
        left hand side is a struct aggregate, and `opAssign`
        is a member function of that aggregate.

        For struct types, operator overloading for the identity assignment
        is allowed.

---
struct S
{
    // identity assignment, allowed.
    void /* adrdox_highlight{ */opAssign/* }adrdox_highlight */(S rhs);

    // not identity assignment, also allowed.
    void /* adrdox_highlight{ */opAssign/* }adrdox_highlight */(int);
}
S s;
s = S();      // Rewritten to s.opAssign(S());
s = 1;        // Rewritten to s.opAssign(1);

---

        However for class types, identity assignment is not allowed. All class
        types have reference semantics, so identity assignment by default rebinds
        the left-hand-side to the argument at the right, and this is not overridable.

---
class C
{
    // If X is the same type as C or the type which is
    // implicitly convertible to C, then opAssign would
    // accept identity assignment, which is disallowed.
    // C opAssign(...);
    // C opAssign(X);
    // C opAssign(X, ...);
    // C opAssign(X ...);
    // C opAssign(X, U = defaultValue, etc.);

    // not an identity assignment - allowed
    void /* adrdox_highlight{ */opAssign/* }adrdox_highlight */(int);
}
C c = new C();
c = new C();  // Rebinding referencee
c = 1;        // Rewritten to c.opAssign(1);

---

$(H3 $(ID index_assignment_operator) Index Assignment Operator Overloading)

        If the left hand side of an assignment is an index operation
        on a struct or class instance,
        it can be overloaded by providing an `opIndexAssign` member function.
        Expressions of the form `a[`$(I b)$(SUBSCRIPT 1), $(I b)$(SUBSCRIPT 2), ... $(I b)$(SUBSCRIPT n)`] = c` are rewritten
        as `a.opIndexAssign(c,` $(I b)$(SUBSCRIPT 1), $(I b)$(SUBSCRIPT 2), ... $(I b)$(SUBSCRIPT n)`)`.
        

---
struct A
{
    int /* adrdox_highlight{ */opIndexAssign/* }adrdox_highlight */(int value, size_t i1, size_t i2);
}

void test()
{
    A a;
    a/* adrdox_highlight{ */[/* }adrdox_highlight */i,3/* adrdox_highlight{ */]/* }adrdox_highlight */ = 7;  // same as a.opIndexAssign(7,i,3);
}

---

$(H3 $(ID slice_assignment_operator) Slice Assignment Operator Overloading)

        If the left hand side of an assignment is a slice operation on a
        struct or class instance, it can be overloaded by implementing an
        `opIndexAssign` member function that takes the return value of the
        `opSlice` function as parameter(s).
        Expressions of the form `a[`$(I i)..$(I j)`] = c` are rewritten as
        `a.opIndexAssign(c,` `a.opSlice!0(`$(I i), $(I j)`))`,
        and `a[] = c` as `a.opIndexAssign(c)`.
        

        See [#array-ops|Array
        Indexing and Slicing Operators Overloading] for more details.
        

---
struct A
{
    int opIndexAssign(int v);  // overloads a[] = v
    int opIndexAssign(int v, size_t[2] slice);  // overloads a[i .. j] = v
    size_t[2] opSlice(size_t dim)(size_t i, size_t j);  // overloads i .. j
}

void test()
{
    A a;
    int v;

    a[] = v;  // same as a.opIndexAssign(v);
    a[3..4] = v;  // same as a.opIndexAssign(v, a.opSlice!0(3,4));
}

---

        For backward compatibility, if rewriting `a[`$(I i)..$(I j)`]` as
        `a.opIndexAssign(a.opSlice!0(`$(I i), $(I j)`))`
        fails to compile, the legacy rewrite
        `opSliceAssign(c,` $(I i), $(I j)`)` is used instead.
        

$(H2 $(ID op-assign)Op Assignment Operator Overloading)

        The following op assignment operators are overloadable:

        $(TABLE_ROWS
Overloadable Op Assignment Operators
        * - `+=`
- `-=`
- `*=`
- `/=`
- %`=`
- `^^=`
- &`=`

        * - |`=`
- `^=`
- `&lt;``&lt;``=`
-         `&gt;``&gt;``=`
- `&gt;``&gt;``&gt;``=`
- `~=`
- $(NBSP)

        
)

        The expression:
---
a op= b

---

        is rewritten as:

---
a.opOpAssign!("op")(b)

---

Example:
$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
struct S
{
    int i;
    void opOpAssign(string op: "+")(int rhs) { i += rhs; }
}

S s = {2};
s += 3;
assert(s.i == 5);

---

)

$(H3 $(ID index_op_assignment) Index Op Assignment Operator Overloading)

        If the left hand side of an $(I op)= is an index expression on
        a struct or class instance and `opIndexOpAssign` is a member:

---
a[$(I b)$(SUBSCRIPT 1), $(I b)$(SUBSCRIPT 2), ... $(I b)$(SUBSCRIPT n)] op= c

---

        it is rewritten as:

---
a.opIndexOpAssign!("op")(c, $(I b)$(SUBSCRIPT 1), $(I b)$(SUBSCRIPT 2), ... $(I b)$(SUBSCRIPT n))

---

$(H3 $(ID slice_op_assignment) Slice Op Assignment Operator Overloading)

        If the left hand side of an $(I op)= is a slice expression on
        a struct or class instance and `opIndexOpAssign` is a member:

---
a[$(I i)..$(I j)] op= c

---

        it is rewritten as:

---
a.opIndexOpAssign!("op")(c, a.opSlice($(I i), $(I j)))

---

        and

---
a[] op= c

---

        it is rewritten as:

---
a.opIndexOpAssign!("op")(c)

---

        For backward compatibility, if the above rewrites fail and
        `opSliceOpAssign` is defined, then the rewrites
        `a.opSliceOpAssign(c, i, j)` and `a.opSliceOpAssign(c)` are
        tried, respectively.
        


$(H2 $(ID array-ops)Array Indexing and Slicing Operators Overloading)

        The array indexing and slicing operators are overloaded by
        implementing the `opIndex`, `opSlice`, and `opDollar` methods.
        These may be combined to implement multidimensional arrays.
        

$(H3 $(ID array)Index Operator Overloading)

        Expressions of the form `arr[`$(I b)$(SUBSCRIPT 1), $(I b)$(SUBSCRIPT 2), ... $(I b)$(SUBSCRIPT n)`]` are translated
        into `arr.opIndex(`$(I b)$(SUBSCRIPT 1), $(I b)$(SUBSCRIPT 2), ... $(I b)$(SUBSCRIPT n)`)`. For example:
        

---
struct A
{
    int /* adrdox_highlight{ */opIndex/* }adrdox_highlight */(size_t i1, size_t i2, size_t i3);
}

void test()
{
    A a;
    int i;
    i = a[5,6,7];  // same as i = a.opIndex(5,6,7);
}

---

        In this way a struct or class object can behave as if it
        were an array.
        

        If an index expression can be rewritten using `opIndexAssign` or
        `opIndexOpAssign`, those are preferred over `opIndex`.
        

$(H3 $(ID slice)Slice Operator Overloading)

        Overloading the slicing operator means overloading expressions
        like `a[]` or `a[`$(I i)..$(I j)`]`, where the expressions inside
        the square brackets contain slice expressions of the form $(I i)..$(I j).
        

        To overload `a[]`, simply define `opIndex` with no parameters:
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
struct S
{
    int[] impl;
    int[] opIndex()
    {
        return impl[];
    }
}

void main()
{
    auto s = S([1,2,3]);
    int[] t = s[]; // calls s.opIndex()
    assert(t == [1,2,3]);
}

---

)

        To overload array slicing of the form `a[`$(I i)..$(I j)`]`,
        two steps are needed.  First, the expressions of the form $(I i)..$(I j) are
        translated via `opSlice!0` into objects that encapsulate
        the endpoints $(I i) and $(I j). Then these objects are
        passed to `opIndex` to perform the actual slicing.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
struct S
{
    int[] impl;

    int[] opSlice(size_t dim: 0)(size_t i, size_t j)
    {
        return impl[i..j];
    }
    int[] opIndex()(int[] slice) { return slice; }
}

void main()
{
    auto s = S([1, 2, 3]);
    int[] t = s[0..2]; // calls s.opIndex(s.opSlice(0, 2))
    assert(t == [1, 2]);
}

---

)

        This design was
        chosen in order to support mixed indexing and slicing in
        multidimensional arrays; for example, in translating expressions like
        `arr[1, 2..3, 4]`.
        More precisely, an expression of the form `arr[`$(I b)$(SUBSCRIPT 1), $(I b)$(SUBSCRIPT 2), ... $(I b)$(SUBSCRIPT n)`]`
        is translated into `arr.opIndex(`$(I c)$(SUBSCRIPT 1), $(I c)$(SUBSCRIPT 2), ... $(I c)$(SUBSCRIPT n)`)`.
        Each argument $(I b)$(SUBSCRIPT i) can be either a single expression,
        in which case it is passed directly as the corresponding argument $(I         c)$(SUBSCRIPT i) to `opIndex`; or it can be a slice expression of
        the form $(I x)$(SUBSCRIPT i)`..`$(I y)$(SUBSCRIPT i), in which case
        the corresponding argument $(I c)$(SUBSCRIPT i) to `opIndex` is
        `arr.opSlice!i(`$(I x)$(SUBSCRIPT i)`, `$(I y)$(SUBSCRIPT i)`)`. Namely:
        

        $(TABLE_ROWS

                * + $(I op)
+ $(I rewrite)

                * -                         `arr[1, 2, 3]`
-                         `arr.opIndex(1, 2, 3)`
                

                * -                         `arr[1..2, 3..4, 5..6]`
-                         `arr.opIndex(arr.opSlice!0(1,2), arr.opSlice!1(3,4), arr.opSlice!2(5,6))`
                

                * -                         `arr[1, 2..3, 4]`
-                         `arr.opIndex(1, arr.opSlice!1(2,3), 4)`
                

        
)

        Similar translations are done for assignment operators involving
        slicing, for example:
        

        $(TABLE_ROWS

                * + $(I op)
+ $(I rewrite)

                * -                         `arr[1, 2..3, 4] = c`
-                         `arr.opIndexAssign(c, 1, arr.opSlice!1(2, 3), 4)`
                

                * -                         `arr[2, 3..4] += c`
-                         `arr.opIndexOpAssign!"+"(c, 2, arr.opSlice!1(2, 3))`
                

        
)

        The intention is that `opSlice!i` should return a user-defined
        object that represents an interval of indices along the `i`'th
        dimension of the array. This object is then passed to `opIndex` to
        perform the actual slicing operation.  If only one-dimensional slicing
        is desired, `opSlice` may be declared without the compile-time
        parameter `i`.
        

        Note that in all cases, `arr` is only evaluated once. Thus, an
        expression like `getArray()[1, 2..3, $-1]=c` has the effect of:

---
auto __tmp = getArray();
__tmp.opIndexAssign(c, 1, __tmp.opSlice!1(2,3), __tmp.opDollar!2 - 1);

---
        where the initial function call to `getArray` is only executed
        once.
        

        Note: For backward compatibility, `a[]` and `a[`$(I i)..$(I j)`]` can
        also be overloaded by implementing `opSlice()` with no arguments and
        `opSlice(`$(I i), $(I j)`)` with two arguments,
        respectively.  This only applies for one-dimensional slicing, and dates
        from when D did not have full support for multidimensional arrays. This
        usage of `opSlice` is discouraged.
        

$(H3 $(ID dollar)Dollar Operator Overloading)

        Within the arguments to array index and slicing operators, `$`
        gets translated to `opDollar!i`, where `i` is the position of the
        expression `$` appears in. For example:
        

        $(TABLE_ROWS

                * + $(I op)
+ $(I rewrite)

                * -                         `arr[$-1, $-2, 3]`
-                         `arr.opIndex(arr.opDollar!0 - 1, arr.opDollar!1 - 2, 3)`
                

                * -                         `arr[1, 2, 3..$]`
-                         `arr.opIndex(1, 2, arr.opSlice!2(3, arr.opDollar!2))`
                

        
)

        The intention is that `opDollar!i` should return the length of
        the array along its `i`'th dimension, or a user-defined object
        representing the end of the array along that dimension, that is
        understood by `opSlice` and `opIndex`.
        

---
struct Rectangle
{
    int width, height;
    int[][] impl;
    this(int w, int h)
    {
        width = w;
        height = h;
        impl = new int[w][h];
    }
    int opIndex(size_t i1, size_t i2)
    {
        return impl[i1][i2];
    }
    int opDollar(size_t pos)()
    {
        static if (pos==0)
            return width;
        else
            return height;
    }
}

void test()
{
    auto r = Rectangle(10,20);
    int i = r[$-1, 0];    // same as: r.opIndex(r.opDollar!0, 0),
                          // which is r.opIndex(r.width-1, 0)
    int j = r[0, $-1];    // same as: r.opIndex(0, r.opDollar!1)
                          // which is r.opIndex(0, r.height-1)
}

---

        As the above example shows, a different compile-time argument is
        passed to `opDollar` depending on which argument it appears in. A
        `$` appearing in the first argument gets translated to `opDollar!0`,
    a `$` appearing in the second argument gets translated
        to `opDollar!1`, and so on. Thus, the appropriate value for `$`
        can be returned to implement multidimensional arrays.
        

        Note that `opDollar!i` is only evaluated once for each `i`
        where `$` occurs in the corresponding position in the indexing
        operation.  Thus, an expression like `arr[$-sqrt($), 0, $-1]` has
        the effect of:
        
---
auto __tmp1 = arr.opDollar!0;
auto __tmp2 = arr.opDollar!2;
arr.opIndex(__tmp1 - sqrt(__tmp1), 0, __tmp2 - 1);

---

        If `opIndex` is declared with only one argument, the
        compile-time argument to `opDollar` may be omitted. In this case, it
        is illegal to use `$` inside an array indexing expression with more
        than one argument.
        

$(H3 $(ID index-slicing-example) Complete Example)

        The code example below shows a simple implementation of a
        2-dimensional array with overloaded indexing and slicing operators. The
        explanations of the various constructs employed are given in the
        sections following.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
struct Array2D(E)
{
    E[] impl;
    int stride;
    int width, height;

    this(int width, int height, E[] initialData = [])
    {
        impl = initialData;
        this.stride = this.width = width;
        this.height = height;
        impl.length = width * height;
    }

    // Index a single element, e.g., arr[0, 1]
    ref E opIndex(int i, int j) { return impl[i + stride*j]; }

    // Array slicing, e.g., arr[1..2, 1..2], arr[2, 0..$], arr[0..$, 1].
    Array2D opIndex(int[2] r1, int[2] r2)
    {
        Array2D result;

        auto startOffset = r1[0] + r2[0]*stride;
        auto endOffset = r1[1] + (r2[1] - 1)*stride;
        result.impl = this.impl[startOffset .. endOffset];

        result.stride = this.stride;
        result.width = r1[1] - r1[0];
        result.height = r2[1] - r2[0];

        return result;
    }
    auto opIndex(int[2] r1, int j) { return opIndex(r1, [j, j+1]); }
    auto opIndex(int i, int[2] r2) { return opIndex([i, i+1], r2); }

    // Support for `x..y` notation in slicing operator for the given dimension.
    int[2] opSlice(size_t dim)(int start, int end)
        if (dim &gt;= 0 &amp;&amp; dim &lt; 2)
    in { assert(start &gt;= 0 &amp;&amp; end &lt;= this.opDollar!dim); }
    do
    {
        return [start, end];
    }

    // Support `$` in slicing notation, e.g., arr[1..$, 0..$-1].
    @property int opDollar(size_t dim : 0)() { return width; }
    @property int opDollar(size_t dim : 1)() { return height; }
}

void main()
{
    auto arr = Array2D!int(4, 3, [
        0, 1, 2,  3,
        4, 5, 6,  7,
        8, 9, 10, 11
    ]);

    // Basic indexing
    assert(arr[0, 0] == 0);
    assert(arr[1, 0] == 1);
    assert(arr[0, 1] == 4);

    // Use of opDollar
    assert(arr[$-1, 0] == 3);
    assert(arr[0, $-1] == 8);   // Note the value of $ differs by dimension
    assert(arr[$-1, $-1] == 11);

    // Slicing
    auto slice1 = arr[1..$, 0..$];
    assert(slice1[0, 0] == 1 &amp;&amp; slice1[1, 0] == 2  &amp;&amp; slice1[2, 0] == 3 &amp;&amp;
           slice1[0, 1] == 5 &amp;&amp; slice1[1, 1] == 6  &amp;&amp; slice1[2, 1] == 7 &amp;&amp;
           slice1[0, 2] == 9 &amp;&amp; slice1[1, 2] == 10 &amp;&amp; slice1[2, 2] == 11);

    auto slice2 = slice1[0..2, 1..$];
    assert(slice2[0, 0] == 5 &amp;&amp; slice2[1, 0] == 6 &amp;&amp;
           slice2[0, 1] == 9 &amp;&amp; slice2[1, 1] == 10);

    // Thin slices
    auto slice3 = arr[2, 0..$];
    assert(slice3[0, 0] == 2 &amp;&amp;
           slice3[0, 1] == 6 &amp;&amp;
           slice3[0, 2] == 10);

    auto slice4 = arr[0..3, 2];
    assert(slice4[0, 0] == 8 &amp;&amp; slice4[1, 0] == 9 &amp;&amp; slice4[2, 0] == 10);
}

---

)


$(H2 $(ID dispatch)Forwarding)

        Member names not found in a class or struct can be forwarded
        to a template function named `opDispatch` for resolution.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
import std.stdio;

struct S
{
    void opDispatch(string s, T)(T i)
    {
        writefln("S.opDispatch('%s', %s)", s, i);
    }
}

class C
{
    void opDispatch(string s)(int i)
    {
        writefln("C.opDispatch('%s', %s)", s, i);
    }
}

struct D
{
    template opDispatch(string s)
    {
        enum int opDispatch = 8;
    }
}

void main()
{
    S s;
    s.opDispatch!("hello")(7);
    s.foo(7);

    auto c = new C();
    c.foo(8);

    D d;
    writefln("d.foo = %s", d.foo);
    assert(d.foo == 8);
}

---

)

$(H2 $(ID old-style)D1 style operator overloading)

                The $(LINK2 http://digitalmars.com/d/1.0/operatoroverloading.html, D1 operator overload mechanisms)
        are deprecated.
        
function, Functions, template, Templates




Link_References:
	ACC = Associated C Compiler
+/
module operatoroverloading.dd;