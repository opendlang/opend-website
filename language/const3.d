// just docs: Type Qualifiers
/++


$(D_S Type Qualifiers,



        Type qualifiers modify a type by applying a [type#TypeCtor|type, TypeCtor].
        $(I TypeCtor)s are: `const`, `immutable`, `shared`, and `inout`.
        Each applies transitively to all subtypes.
        

$(H2 $(ID const_and_immutable) Const and Immutable)

        When examining a data structure or interface, it is very
        helpful to be able to easily tell which data can be expected to not
        change, which data might change, and who may change that data.
        This is done with the aid of the language typing system.
        Data can be marked as const or immutable, with the default being
        changeable (or $(I mutable)).
        

        `immutable` applies to data that cannot change.
        Immutable data values, once constructed, remain the same for
        the duration of the program's
        execution.
        Immutable data can be placed in ROM (Read Only Memory) or in
        memory pages marked by the hardware as read only.
        Since immutable data does not change, it enables many opportunities
        for program optimization, and has applications in functional
        style programming.
        

        `const` applies to data that cannot be changed by
        the const reference to that data. It may, however, be changed
        by another reference to that same data.
        Const finds applications in passing data through interfaces
        that promise not to modify them.
        

        Both immutable and const are $(I transitive), which means
        that any data reachable through an immutable reference is also
        immutable, and likewise for const.
        

$(H2 $(ID immutable_storage_class) Immutable Storage Class)

                The simplest immutable declarations use it as a storage class.
        It can be used to declare manifest constants.
        

---
immutable int x = 3;  // x is set to 3
x = 4;        // error, x is immutable
char[x] s;    // s is an array of 3 chars

---

        The type can be inferred from the initializer:
        
---
immutable y = 4; // y is of type int
y = 5;           // error, y is immutable

---

        If the initializer is not present, the immutable can
        be initialized from the corresponding constructor:
        

---
immutable int z;
void test()
{
    z = 3; // error, z is immutable
}
static this()
{
    z = 3; // ok, can set immutable that doesn't
           // have static initializer
}

---
                The initializer for a non-local immutable declaration must be
        evaluatable
        at compile time:
        

---
int foo(int f) { return f * 3; }
int i = 5;
immutable x = 3 * 4;      // ok, 12
immutable y = i + 1;      // error, cannot evaluate at compile time
immutable z = foo(2) + 1; // ok, foo(2) can be evaluated at compile time, 7

---

        The initializer for a non-static local immutable declaration
        is evaluated at run time:
        
---
int foo(int f)
{
    immutable x = f + 1;  // evaluated at run time
    x = 3;                // error, x is immutable
}

---

                Because immutable is transitive, data referred to by an immutable is
        also immutable:
        

---
immutable char[] s = "foo";
s[0] = 'a';  // error, s refers to immutable data
s = "bar";   // error, s is immutable

---

        Immutable declarations can appear as lvalues, i.e. they can
        have their address taken, and occupy storage.
        

$(H2 $(ID const_storage_class) Const Storage Class)

                A const declaration is exactly like an immutable declaration,
        with the following differences:
        

        $(LIST
        * Any data referenced by the const declaration cannot be
        changed from the const declaration, but it might be changed
        by other references to the same data.

        * The type of a const declaration is itself const.
        
)

$(COMMENT $(TABLE 
<tr><th>$(NBSP)</th> <th>AddrOf</th> <th>CTFEInit</th> <th>Static</th> <th>Field</th> <th>Stack</th> <th>Ctor</th></tr>

<tr><td>$(NBSP)</td>
 <td>Can the address be taken?</td>
 <td>Is compile time function evaluation done on the initializer?</td>
 <td>allocated as static data?</td>
 <td>allocated as a per-instance field?</td>
 <td>allocated on the stack?</td>
 <td>Can the variable be assigned to in a constructor?</td>
</tr>


<tr><th>Global data</th></tr>

<tr><td class="nobr">`const T x;`</td>          <td>Yes</td>    <td>No</td>    <td>Yes</td>    <td>No</td>    <td>No</td>    <td>Yes</td></tr>
<tr><td class="nobr">`const T x = 3;`</td>              <td>No</td>    <td>Yes</td>    <td>No</td>    <td>No</td>    <td>No</td>    <td>No</td></tr>
<tr><td class="nobr">`static const T x;`</td>   <td>Yes</td>    <td>No</td>    <td>Yes</td>    <td>No</td>    <td>No</td>    <td>Yes</td></tr>
<tr><td class="nobr">`static const T x = 3;`</td>       <td>Yes</td>    <td>Yes</td>    <td>Yes</td>    <td>No</td>    <td>No</td>    <td>No</td></tr>


<tr><th>Class Members</th></tr>

<tr><td class="nobr">`const T x;`</td>          <td>Yes</td>    <td>No</td>    <td>No</td>    <td>Yes</td>    <td>No</td>    <td>Yes</td></tr>
<tr><td class="nobr">`const T x = 3;`</td>              <td>No</td>    <td>Yes</td>    <td>No</td>    <td>No</td>    <td>No</td>    <td>No</td></tr>
<tr><td class="nobr">`static const T x;`</td>   <td>Yes</td>    <td>No</td>    <td>Yes</td>    <td>No</td>    <td>No</td>    <td>Yes</td></tr>
<tr><td class="nobr">`static const T x = 3;`</td>       <td>Yes</td>    <td>Yes</td>    <td>Yes</td>    <td>No</td>    <td>No</td>    <td>No</td></tr>


<tr><th>Local Variables</th></tr>

<tr><td class="nobr">`const T x;`</td>          <td>Yes</td>    <td>Yes</td>    <td>No</td>    <td>No</td>    <td>Yes</td>    <td>No</td></tr>
<tr><td class="nobr">`const T x = 3;`</td>              <td>Yes</td>    <td>No</td>    <td>No</td>    <td>No</td>    <td>Yes</td>    <td>No</td></tr>
<tr><td class="nobr">`static const T x;`</td>   <td>Yes</td>    <td>Yes</td>    <td>Yes</td>    <td>No</td>    <td>No</td>    <td>No</td></tr>
<tr><td class="nobr">`static const T x = 3;`</td>       <td>Yes</td>    <td>Yes</td>    <td>Yes</td>    <td>No</td>    <td>No</td>    <td>No</td></tr>

<tr><th>Function Parameters</th></tr>

<tr><td class="nobr">`const T x;`</td>          <td>Yes</td>    <td>No</td>    <td>No</td>    <td>No</td>    <td>Yes</td>    <td>No</td></tr>
)


Notes:

$(NUMBERED_LIST
* If CTFEInit is true, then the initializer can also be used for
constant folding.

)


$(TABLE <caption>Template Argument Deduced Type</caption>
<tr><th>$(NBSP)</th>               <th>mutable `T`</th> <th class="nobr">`const(T)`</th> <th class="nobr">`immutable(T)`</th></tr>
<tr><td class="nobr">`foo(U)`</td>              <td class="nobr">`T`</td> <td class="nobr">`T`</td> <td class="nobr">`T`</td></tr>
<tr><td class="nobr">`foo(U:U)`</td>            <td class="nobr">`T`</td> <td class="nobr">`const(T)`</td> <td class="nobr">`immutable(T)`</td></tr>
<tr><td class="nobr">`foo(U:const(U))`</td>     <td class="nobr">`T`</td> <td class="nobr">`T`</td> <td class="nobr">`T`</td></tr>
<tr><td class="nobr">`foo(U:immutable(U))`</td> <td>no match</td> <td>no match</td> <td class="nobr">`T`</td></tr>
)

Where:

$(TABLE <tr><td>green</td> <td>exact match</td></tr>
<tr><td>orange</td> <td>implicit conversion</td></tr>
)
)

$(H2 $(ID immutable_type) Immutable Type)

                Data that will never change its value can be typed as immutable.
        The immutable keyword can be used as a $(I type qualifier):
        

---
immutable(char)[] s = "hello";

---

                The immutable applies to the type within the following parentheses.
        So, while `s` can be assigned new values,
        the contents of `s[]` cannot be:
        

---
s[0] = 'b';  // error, s[] is immutable
s = null;    // ok, s itself is not immutable

---

                Immutability is transitive, meaning it applies to anything that
        can be referenced from the immutable type:
        

---
immutable(char*)** p = ...;
p = ...;        // ok, p is not immutable
*p = ...;       // ok, *p is not immutable
**p = ...;      // error, **p is immutable
***p = ...;     // error, ***p is immutable

---

        Immutable used as a storage class is equivalent to using
        immutable as a type qualifier for the entire type of a
        declaration:

---
immutable int x = 3;   // x is typed as immutable(int)
immutable(int) y = 3;  // y is immutable

---


$(H2 $(ID creating_immutable_data) Creating Immutable Data)

                The first way is to use a literal that is already immutable,
        such as string literals. String literals are always immutable.
        

---
auto s = "hello";   // s is immutable(char)[5]
char[] p = "world"; // error, cannot implicitly convert immutable
                    // to mutable

---

                The second way is to cast data to immutable.
        When doing so, it is up to the programmer to ensure that any mutable
        references to the same data are not used to modify the data after the
        cast.
        

---
char[] s = ['a'];
s[0] = 'b'; // ok
immutable(char)[] p = cast(immutable)s; // ok, if data is not mutated
                                        // through s anymore
s[0] = 'c'; // undefined behavior
immutable(char)[] q = cast(immutable)s.dup; // always ok, unique reference

char[][] s2 = [['a', 'b'], ['c', 'd']];
immutable(char[][]) p2 = cast(immutable)s2.dup; // dangerous, only the first
                                                // level of elements is unique
s2[0] = ['x', 'y']; // ok, doesn't affect p2
s2[1][0] = 'z'; // undefined behavior
immutable(char[][]) q2 = [s2[0].dup, s2[1].dup]; // always ok, unique references

---

                The `.idup` property is a convenient way to create an immutable
        copy of an array:
        

---
auto p = s.idup;
p[0] = ...;       // error, p[] is immutable

---

$(H2 $(ID removing_with_cast) Removing Immutable or Const with a Cast)

                An immutable or const type qualifier can be removed with a cast:
        

---
immutable int* p = ...;
int* q = cast(int*)p;

---

                This does not mean, however, that one can change the data:
        

---
*q = 3; // allowed by compiler, but result is undefined behavior

---

                The ability to cast away immutable-correctness is necessary in
        some cases where the static typing is incorrect and not fixable, such
        as when referencing code in a library one cannot change.
        Casting is, as always, a blunt and effective instrument, and
        when using it to cast away immutable-correctness, one must assume
        the responsibility to ensure the immutability of the data, as
        the compiler will no longer be able to statically do so.
        

        $(PITFALL         casting away a `const` qualifier and then mutating it,
        even when the referenced data is mutable. This is so that
        compilers and programmers can make assumptions based on `const` alone. For
        example, here it may be assumed that `f` does not alter `x`:
        )

---
void f(const int* a);
void main()
{
    int x = 1;
    f(&amp;x);
    assert(x == 1); // guaranteed to hold
}

---

$(H2 $(ID immutable_member_functions) Immutable Member Functions)

                Immutable member functions are guaranteed that the object
        and anything referred to by the $(LINK2 spec/expression#this,`this` reference)
        is immutable.
        They are declared as:
        

---
struct S
{
    int x;

    void foo() immutable
    {
        x = 4;      // error, x is immutable
        this.x = 4; // error, x is immutable
    }
}

---
    Note that using immutable on the left hand side of a method does not apply to the return type:
    

---
struct S
{
    immutable int[] bar()  // bar is still immutable, return type is not!
    {
    }
}

---
    To make the return type immutable, surround it with parentheses:
    

---
struct S
{
    immutable(int[]) bar()  // bar is now mutable, return type is immutable.
    {
    }
}

---
    To make both the return type and the method immutable, write:
    
---
struct S
{
    immutable(int[]) bar() immutable
    {
    }
}

---


$(H2 $(ID const_type) Const Type)

                Const types are like immutable types, except that const
        forms a read-only $(I view) of data. Other aliases to that
        same data may change it at any time.
        


$(H2 $(ID const_member_functions) Const Member Functions)

                Const member functions are functions that are not allowed to
        change any part of the object through the member function's
        $(LINK2 spec/expression#this,`this` reference).
        


$(H2 $(ID inout) Inout)

    Functions that differ only in whether the parameters are mutable, `const` or `immutable`,
        and have corresponding mutable, `const` or `immutable` return types, can be combined
        into one function using the `inout` type constructor. Consider the following
        overload set:
     
---
int[] slice(int[] a, int x, int y) { return a[x .. y]; }

const(int)[] slice(const(int)[] a, int x, int y) { return a[x .. y]; }

immutable(int)[] slice(immutable(int)[] a, int x, int y) { return a[x .. y]; }

---

    The code generated by each of these functions is identical.
        The inout type constructor can combine them into one function:

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
inout(int)[] slice(inout(int)[] a, int x, int y) { return a[x .. y]; }

---
        
)

    The inout keyword forms a wildcard that stands in for
        mutable, `const`, `immutable`, `inout`, or `inout const`.
        When calling the function, the `inout` state of the return type is changed to
        match that of the argument type passed to the `inout` parameter.
    

    `inout` can also be used as a type constructor inside a function that has a
        parameter declared with `inout`. The `inout` state of a type declared with
        `inout` is changed to match that of the argument type passed to the `inout`
        parameter:
    

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
inout(int)[] asymmetric(inout(int)[] input_data)
{
    inout(int)[] r = input_data;
    while (r.length &gt; 1 &amp;&amp; r[0] == r[$-1])
        r = r[1..$-1];
    return r;
}

---
        
)

    Inout types can be implicitly converted to `const` or `inout const`,
        but to nothing else. Other types cannot be implicitly converted to `inout`.
        Casting to or from `inout` is not allowed in `@safe` functions.
    

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
void f(inout int* ptr)
{
    const int* p = ptr;
    int* q = ptr; // error
    immutable int* r = ptr; // error
}

---
        
)

    $(H3 $(ID matching-an-inout-parameter) Matching an `inout` Parameter)

    A set of arguments to a function with `inout` parameters is considered
        a match if any `inout` argument types match exactly, or:

    $(NUMBERED_LIST
        * No argument types are composed of `inout` types.
        * A mutable, `const` or `immutable` argument type can be matched against each
        corresponding parameter `inout` type.
    
)

    If such a match occurs, `inout` is considered the common qualifier of
        the matched qualifiers. If more than two parameters exist, the common
        qualifier calculation is recursively applied.
    

    $(TABLE_ROWS
Common qualifier of the two type qualifiers
        * - 
- $(I mutable)
- `const`
- `immutable`
- `inout`
- `inout const`

        * - $(I mutable) (= m)
- m
- c
- c
- c
- c

        * - `const` (= c)
- c
- c
- c
- c
- c

        * - `immutable` (= i)
- c
- c
- i
- wc
- wc

        * - `inout` (= w)
- c
- c
- wc
- w
- wc

        * - `inout const` (= wc)
- c
- c
- wc
- wc
- wc

    
)

    The `inout` in the return type is then rewritten to match the `inout`
        qualifiers:

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
int[] ma;
const(int)[] ca;
immutable(int)[] ia;

inout(int)[] foo(inout(int)[] a) { return a; }
void test1()
{
    // inout matches to mutable, so inout(int)[] is
    // rewritten to int[]
    int[] x = foo(ma);

    // inout matches to const, so inout(int)[] is
    // rewritten to const(int)[]
    const(int)[] y = foo(ca);

    // inout matches to immutable, so inout(int)[] is
    // rewritten to immutable(int)[]
    immutable(int)[] z = foo(ia);
}

inout(const(int))[] bar(inout(int)[] a) { return a; }
void test2()
{
    // inout matches to mutable, so inout(const(int))[] is
    // rewritten to const(int)[]
    const(int)[] x = bar(ma);

    // inout matches to const, so inout(const(int))[] is
    // rewritten to const(int)[]
    const(int)[] y = bar(ca);

    // inout matches to immutable, so inout(int)[] is
    // rewritten to immutable(int)[]
    immutable(int)[] z = bar(ia);
}

---
        
)

    $(B Note:) Shared types cannot
        be matched with `inout`.
    


$(H2 $(ID shared) Shared)

Mutable data that is meant to be shared among multiple threads should be
declared with the `shared` qualifier. This prevents unsynchronized
reading and writing to the data, which would otherwise cause data races.
The `shared` type attribute is transitive (like `const` and `immutable`).

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
shared int x;
shared(int)* p = &amp;x;
//int* q = p; // error, q is not shared

---

)
For basic data types, reading and writing can normally be done with
atomic operations. Use [core.atomic] for portability:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
import core.atomic;

shared int x;

void fun()
{
    //x++; // error, use atomicOp instead
    x.atomicOp!"+="(1);
}

---

)
Warning: An individual read or write operation on shared
data is not an error yet by default. To detect these, use the
`-preview=nosharedaccess` compiler option. Normal initialization is
allowed without an error.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
import core.atomic;

int y;
shared int x = y; // OK

//x = 5; // write error with preview flag
x.atomicStore(5); // OK
//y = x; // read error with preview flag
y = x.atomicLoad(); // OK
assert(y == 5);

---

)

$(H3 $(ID shared_cast) Casting)

When working with larger types, manual synchronization
can be used. To do that, `shared` can be cast away for the
duration while mutual exclusion has been established:


$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
struct T;
shared T* x;

void fun()
{
    synchronized
    {
        T* p = cast(T*)x;
        // operate on `*p`
    }
}

---

)

An unshared reference can be cast to shared only if the source data
will not be accessed for the lifetime of the cast result.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
class C {}

@trusted shared(C) create()
{
    auto c = new C;
    // work with c without it escaping
    return cast(shared)c; // OK
}

---

)

$(H3 $(ID shared_global) Shared Global Variables)

Global (or static) shared variables are stored in common storage which
is accessible across threads. Global mutable variables are stored in
thread-local storage by default.

To declare global/static data to be implicitly shared across
multiple threads without any compiler checks, see $(LINK2 spec/attribute#gshared,`__gshared`).



$(H2 $(ID combining_qualifiers) Combining Qualifiers)

More than one qualifier may apply to a type. The order of application is
irrelevant, for example given an unqualified type `T`, `const shared T` and
`shared const T` are the same type. For that reason, this document depicts
qualifier combinations without parentheses unless necessary and in alphabetic
order.

Applying a qualifier to a type that already has that qualifier is legal but
has no effect, e.g. given an unqualified type `T`, `shared(const shared T)`
yields the type `const shared T`.

$(NOTE Applying the `immutable` qualifier to any type (qualified or not) results in
`immutable T`. Applying any qualifier to `immutable T` results in
`immutable T`. This makes `immutable` a fixed point of qualifier combinations and
makes types such as `const(immutable(shared T))` impossible to create.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
alias SInt = shared int;
alias IInt = immutable int;
static assert(is(immutable(SInt) == IInt));
static assert(is(shared(IInt) == IInt));

---

)
)

Assuming `T` is an unqualified type, the graph below illustrates how
qualifiers combine (combinations with `immutable` are omitted). For each node,
applying the qualifier labeling the edge leads to the resulting type.

$(COMMENT To generate images/qualifier-combinations.{svg,eps} refer to
images/qualifier-combinations.dot.)

$(HTMLTAG3 center, ,
  <img id="conversions" alt="Qualifier combination rules"
    src="images/qualifier-combinations.svg">
)
$(LATEX {\centering
\includegraphics{images/qualifier-combinations.eps}
}
)

$(H2 $(ID implicit_qualifier_conversions) Implicit Qualifier Conversions)

Values that have no mutable indirections (including structs that don't
contain any field with mutable indirections) can be implicitly converted across
$(I mutable), `const`, `immutable`, `const shared`, `inout` and
`inout shared`.

References to qualified objects can be implicitly converted according to the
following rules:

$(COMMENT To generate images/qualifier-conversions.{svg,eps} refer to
images/qualifier-conversions.dot.)

$(HTMLTAG3 center, ,
  <img id="conversions" alt="Qualifier conversion rules"
    src="images/qualifier-conversions.svg">
)
$(LATEX {\centering
\includegraphics{images/qualifier-conversions.eps}
}
)

In the graph above, any directed path is a legal implicit conversion. No
other qualifier combinations than the ones shown is valid. If a directed path
exists between two sets of qualifiers, the types thus qualified are called
[qualifier-convertible]. The same information is shown below in tabular
format:

    $(TABLE_ROWS
Implicit Conversion of Reference Types
    $(VERTROW from/to, $(I mutable), `const`, `shared`, `inout`, `const shared`, `const inout`, `inout shared`, `const inout shared`, `immutable`),
    * - $(I mutable)
-            yes
- yes
- no
-  no
-  no
-  no
-  no
-  no
-  no 

    * - `const`
-              no
-  yes
- no
-  no
-  no
-  no
-  no
-  no
-  no 

    * - `shared`
-             no
-  no
-  yes
- no
-  yes
- no
-  no
-  no
-  no 

    * - `inout`
-              no
-  yes
- no
-  yes
- no
-  yes
- no
-  no
-  no 

    * - `const shared`
-       no
-  no
-  no
-  no
-  yes
- no
-  no
-  no
-  no 

    * - `const inout`
-        no
-  yes
- no
-  no
-  no
-  yes
- no
-  no
-  no 

    * - `inout shared`
-       no
-  no
-  no
-  no
-  yes
- no
-  yes
- yes
- no 

    * - `const inout shared`
- no
-  no
-  no
-  no
-  yes
- no
-  no
-  yes
- no 

    * - `immutable`
-          no
-  yes
- no
-  no
-  yes
- yes
- no
-  yes
- yes

    
)

$(H3 $(ID unique-expressions) Unique Expressions)

        If an implicit conversion is disallowed by the table, an [expression#Expression|expression, Expression]
        may be implicitly converted as follows:
        
        $(LIST
        * From mutable or shared to immutable if the expression
        is unique and all expressions it transitively refers to are either unique or immutable.
        
        * From mutable to shared if the expression
        is unique and all expressions it transitively refers to are either unique, immutable,
        or shared.
        
        * From immutable to mutable if the expression is unique.
        
        * From shared to mutable if the expression is unique.
        
        
)

        A $(I Unique Expression) is one for which there are no other references to the
        value of the expression and all expressions it transitively refers to are either
        also unique or are immutable. For example:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
void main()
{
    immutable int** p = new int*(null); // ok, unique

    int x;
    //immutable int** q = new int*(&amp;x); // error, there may be other references to x

    immutable int y;
    immutable int** r = new immutable(int)*(&amp;y); // ok, y is immutable
}

---

)
        See also: $(LINK2 spec/function#pure-factory-functions,Pure Factory Functions).

        Otherwise, a [expression#CastExpression|expression, CastExpression] can be used to force a conversion
        when an implicit version is disallowed, but this cannot be done in `@safe` code,
        and the correctness of it must be verified by the user.
        

enum, Enums, function, Functions
)



Link_References:
	ACC = Associated C Compiler
+/
module const3.dd;