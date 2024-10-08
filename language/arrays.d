// just docs: Arrays
/++





$(H2 $(ID array-kinds) Kinds)

    There are four kinds of arrays:

    $(TABLE_ROWS
Kinds of Arrays
        * + Syntax
+ Description

        * - $(I type)[$(I integer)]
- [#static-arrays|Static arrays]

        * - $(I type)[]
-  [#dynamic-arrays|Dynamic arrays]

        * - $(I type)*
- [#pointers|Pointer arrays]

        * - $(I type)[$(I type)]
- $(LINK2 spec/hash-map, Associative Arrays)

    
)

$(H3 $(ID static-arrays) Static Arrays)

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
int[3] s;

---

)

        Static arrays have a length fixed at compile time.
        

        The total size of a static array cannot exceed 16Mb.
        

        A static array with a dimension of 0 is allowed, but no
        space is allocated for it.
        

        Static arrays are value types.
        They are passed to and returned by functions by value.
        

        $(TIP         $(NUMBERED_LIST
        * Use dynamic arrays for larger arrays.
        * Static arrays with 0 elements are useful as the last member
        of a variable length struct, or as the degenerate case of
        a template expansion.
        * Because static arrays are passed to functions by value,
        a larger array can consume a lot of stack space. Use dynamic arrays
        instead.
        
))

$(H3 $(ID dynamic-arrays) Dynamic Arrays)

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
int[] a;

---

)

        Dynamic arrays consist of a length and a pointer to the array data.
        Multiple dynamic arrays can share all or parts of the array data.
        

        $(TIP         $(NUMBERED_LIST
        * Use dynamic arrays instead of pointer arrays as much as practical.
        Indexing of dynamic arrays are bounds checked, avoiding buffer underflow and
        overflow problems.
        
))

$(H3 $(ID pointers) Pointer Arrays)

---
int* p;

---

        A $(LINK2 spec/type#pointers,pointer)
        can manipulate a block of multiple contiguous values in memory.
        Accessing more than one value cannot be
        $(LINK2 spec/memory-safe-d, Memory-Safe-D-Spec) as it
        requires [#pointer-arithmetic|pointer arithmetic].
        This is supported for interfacing with C and for
        specialized systems work.
        A pointer has no length associated with it, so there is no way for the
        compiler or runtime to do bounds checking, etc., on it.
        

        $(TIP Most conventional uses for pointers can be replaced with
        dynamic arrays, `ref` and `out` $(LINK2 spec/function#parameters,parameters),
        and reference types.
        )


$(H2 $(ID declarations) Array Declarations)

        Declarations appear before the identifier being
        declared and read right to left, so:
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
int[] a;      // dynamic array of ints
int[4][3] b;  // array of 3 arrays of 4 ints each
int[][5] c;   // array of 5 dynamic arrays of ints.
int*[]*[3] d; // array of 3 pointers to dynamic arrays of pointers to ints
int[]* e;     // pointer to dynamic array of ints

---

)

$(H2 $(ID literals) Array Literals)

---
auto a1 = [1,2,3];  // type is int[], with elements 1, 2, and 3
auto a2 = [1u,2,3]; // type is uint[], with elements 1u, 2u, and 3u
int[2] a3 = [1,2];  // type is int[2], with elements 1, and 2

---
    `[]` is an empty array literal.

    See $(LINK2 spec/expression#array_literals,Array Literals).

$(ID usage)usage
$(H2 $(ID assignment) Array Assignment)

        There are two broad kinds of operations to do on dynamic arrays and
        pointer arrays - those affecting the handle to the array,
        and those affecting the contents of the array. Assignment only affects
        the handle for these types.
        

        The `.ptr` property for static and dynamic arrays will give the address
        of the first element in the array:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
int* p;
int[3] s;
int[] a;

p = s.ptr; // p points to the first element of the array s.
p = a.ptr; // p points to the first element of the array a.

// error, since the length of the array pointed to by p is unknown
//s = p;

//a = p;   // error, length unknown
a = s;     // a points to the elements of s
assert(a.ptr == s.ptr);

int[] b;
a = b;     // a points to the same array as b does
assert(a.ptr == b.ptr);
assert(a == []);

---

)
    Note: The two error lines above can be made to copy elements
    using pointer [#slicing|slicing], so that the number of elements
    to copy is then known.

    A static array can be assigned from a dynamic array - the data is copied.
    The lengths must match:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
int[3] s;
int[] a;

//s = [1, 2]; // error
s = [1, 2, 3]; // OK
//s = [1, 2, 3, 4]; // error

a = [4, 5, 6];
s = a; // OK
assert(s.ptr != a.ptr);
a = [1, 2];
//s = a; // RangeError, length mismatch

a = s;
assert(a.ptr == s.ptr);
//s = a; // RangeError, overlap

---

)
    The dynamic array data must not [#overlapping-copying|overlap]
    with the static array memory.
    See also [#array-copying|Copying].


$(H2 $(ID indexing) Indexing)

    Indexing allows access to an element of an array:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
auto a = [1,2,3];
assert(a[0] == 1);
assert(a[2] == 3);
a[2] = 4;
assert(a[2] == 4);
assert(a == [1,2,4]);
//writeln(a[3]); // runtime error (unless bounds checks turned off)

int[2] b = [1,2];
assert(b[1] == 2);
//writeln(b[2]); // compile-time error, index out of bounds

---

)

    See also [expression#IndexOperation|expression, IndexOperation].

$(H3 $(ID pointer-arithmetic) Pointer Arithmetic)

    A pointer can also be indexed, but no bounds checks are done.
    Unlike arrays, a pointer value can also be used in certain
    arithmetic expressions to produce another pointer:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
int[] a = [1,2,3];
int* p = a.ptr;

p[2] = 4;
assert(a[2] == 4);
writeln(p[3]); // undefined behaviour

assert(p == &amp;a[0]);
p++; // point to a[1]
assert(*p == 2);

---

)

    See $(LINK2 spec/expression#pointer_arithmetic,<em>AddExpression</em>) for details.


$(H2 $(ID slicing) Slicing)

        $(I Slicing) an array means to specify a subarray of it.
        This is done by supplying two index expressions.
        The elements from the start index up until the end index are selected.
        Any item at the end index is not included.
        
                An array slice does not copy the data, it is only another
        reference to it. Slicing produces a dynamic array.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
int[3] a = [4, 5, 6]; // static array of 3 ints
int[] b;

b = a[1..3]; // a[1..3] is a 2 element dynamic array consisting of
             // a[1] and a[2]
assert(b == [5, 6]);
assert(b.ptr == a.ptr + 1);

a[2] = 3;
assert(b == [5, 3]);

b = b[1..2];
assert(b == [3]);

---

)

        $(I Expression)`[]` is shorthand for a slice of the entire array.
        

        Slicing
        is not only handy for referring to parts of other arrays,
        but for converting pointers into bounds-checked arrays:
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
int[10] a = [ 1,2,3,4,5,6,7,8,9,10 ];

int* p = &amp;a[2];
writeln(p[7]);      // 10
writeln(p[8]);      // undefined behaviour

int[] b = p[0..8];  // convert pointer elements to dynamic array
assert(b is a[2..10]);
writeln(b);
writeln(b[7]);      // 10
//writeln(b[8]);    // runtime error (unless bounds checks turned off)

---

)

    See also [expression#SliceOperation|expression, SliceOperation].


$(H2 $(ID array-length) Array Length)

        When indexing or slicing a static or dynamic array,
        the symbol `$` represents the length of the array.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
int[4] foo;
int[]  bar = foo;

// These expressions are equivalent:
bar = foo;
bar = foo[];
bar = foo[0 .. 4];
bar = foo[0 .. $];
bar = foo[0 .. foo.length];

int* p = foo.ptr;
//bar = p[0 .. $]; // error, '$' is not defined, since p is not an array

int i;
//i = foo[0]+$; // error, '$' is not defined, out of scope of [ ]
i = bar[$-1]; // retrieves last element of the array

---

)


$(H2 $(ID array-copying) Array Copying)

        When the slice operator appears as the left-hand side of an
        assignment expression, it means that the contents of the array are the
        target of the assignment rather than a reference to the array.
        Array copying happens when the left-hand side is a slice, and the
        right-hand side is an array of or pointer to the same type.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
int[3] s, t;
int[] a;

s = t;             // the 3 elements of t are copied into s
s[] = t;           // the 3 elements of t are copied into s
s[] = t[];         // the 3 elements of t are copied into s
s[1..2] = t[0..1]; // same as s[1] = t[0]
s[0..2] = t[1..3]; // same as s[0] = t[1], s[1] = t[2]
//s[0..4] = t[0..4]; // error, only 3 elements in s and t
//s[0..2] = t;       // error, operands have different lengths

a = [1, 2];
s[0..2] = a;
assert(s == [1, 2, 0]);

//a[] = s; // RangeError, lengths don't match
a[0..2] = s[1..3];
assert(a == [2, 0]);

---

)

$(H3 $(ID overlapping-copying) Overlapping Copying)

        Overlapping copies are an error:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
void main()
{
    int[3] s;

    s[0..2] = s[1..3]; // error, overlapping copy
    s[1..3] = s[0..2]; // error, overlapping copy
}

---

)

        Disallowing overlapping makes it possible for more aggressive
        parallel code optimizations than possible with the serial
        semantics of C.
        

        If overlapping is required, use
        $(REF copy, std,algorithm,mutation):
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
import std.algorithm;
int[] s = [1, 2, 3, 4];

copy(s[1..3], s[0..2]);
assert(s == [2, 3, 3, 4]);

---

)


$(H2 $(ID array-setting) Array Setting)

        If a slice operator appears as the left-hand side of an assignment
        expression, and the type of the right-hand side is the same as the
        element type of the left-hand side, then the array contents of the
        left-hand side are set to the right-hand side.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
int[3] s;
int[] a;
int* p;

s[] = 3;
assert(s == [3, 3, 3]);

a = s;
a[] = 1;
assert(s == [1, 1, 1]);

p = s.ptr;
p[0..2] = 2;
assert(s == [2, 2, 1]);

---

)

$(H2 $(ID array-concatenation) Array Concatenation)

        The binary operator `~` is the $(I cat) operator. It is used
        to concatenate arrays:
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
int[] a = [1, 2];
assert(a ~ 3 == [1, 2, 3]); // concatenate array with a single value

int[] b = a ~ [3, 4];
assert(b == [1, 2, 3, 4]); // concatenate two arrays

---

)

        Many languages overload the `+` operator for concatenation.
        This confusingly leads to a dilemma - does:
        

---
"10" + 3 + 4

---

        produce the number `17`, the string `"1034"` or the string `"107"` as the
        result? It isn't obvious, and the language designers wind up carefully
        writing rules to disambiguate it - rules that get incorrectly
        implemented, overlooked, forgotten, and ignored. It's much better to
        have `+` mean addition, and a separate operator to be array
        concatenation.
        

        Concatenation always creates a copy of its operands, even
        if one of the operands is a 0 length array, so:
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
auto b = [7];
auto a = b;      // a refers to b
assert(a is b);

a = b ~ []; // a refers to a copy of b
assert(a !is b);
assert(a == b);

---

)

        See also: $(LINK2 spec/expression#identity_expressions,`is` operator).

$(H2 $(ID array-appending) Array Appending)

        Similarly, the `~=` operator means append, as in:
        

---
a ~= b; // a becomes the concatenation of a and b

---

        Appending does not always create a copy, see [#resize|        setting dynamic array length] for details.
        

$(H2 $(ID array-operations) Vector Operations)

        Many array operations
        can be expressed at a high level rather than as a loop.
        For example, the loop:
        

---
T[] a, b;
...
for (size_t i = 0; i &lt; a.length; i++)
    a[i] = b[i] + 4;

---

        assigns to the elements of `a` the elements of `b`
        with `4` added to each. This can also be expressed in
        vector notation as:
        

---
T[] a, b;
...
a[] = b[] + 4;

---

        A vector operation is indicated by the slice operator appearing
        as the left-hand side of an assignment or an op-assignment expression.
        The right-hand side can be certain combinations of:

$(LIST
* An array [expression#SliceOperation|expression, SliceOperation] of the same length
          and type as the left-hand side
* A scalar expression of the same element type as the left-hand side


)
        The following operations are supported:

$(LIST
* Unary: `-`, `~`
* Add: `+`, `-`
* Mul: `*`, `/`, `%`,
* Bitwise: `^`, `&amp;`, `|`
* Pow: `^^`


)
$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
int[3] a = 0;
int[] b = [1, 2, 3];

a[] += 10 - (b[] ^^ 2);
assert(a == [9, 6, 1]);

---

)

        Note: In particular, an expression using
        [expression#ConditionalExpression|expression, ConditionalExpression],
        $(LINK2 spec/expression#logical_expressions,logical expressions),
        [expression#CmpExpression|expression, CmpExpression],
        concatenation `~` or a function call is <em>not</em> a vector op.

        The slice on the left and any slices on the right must not overlap.
        All operands are evaluated exactly once, even if the array slice
        has zero elements in it.
        

        If the element type defines matching overloaded operators,
        those methods must be `pure nothrow @nogc`.

        The order in which the array elements are computed
        is implementation defined, and may even occur in parallel.
        An application must not depend on this order.
        

        $(B Implementation Note:) Many vector operations are expected
        to take advantage of any vector math instructions available on
        the target computer.
        

$(H2 $(ID rectangular-arrays) Rectangular Arrays)

        Experienced FORTRAN numerics programmers know that multidimensional
        "rectangular" arrays for things like matrix operations are much faster than trying to
        access them via pointers to pointers resulting from "array of pointers to array" semantics.
        For example, the D syntax:
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
double[][] matrix;

---

)

        declares matrix as an array of pointers to arrays. (Dynamic arrays are implemented as
        pointers to the array data.) Since the arrays can have varying sizes (being dynamically
        sized), this is sometimes called "jagged" arrays. Even worse for optimizing the code, the
        array rows can sometimes point to each other! Fortunately, D static arrays, while using
        the same syntax, are implemented as a fixed rectangular layout in a contiguous block of
        memory:
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
import std.stdio : writeln;

double[6][3] matrix = 0; // Sets all elements to 0.

void main()
{
    writeln(matrix); // [[0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]]
}

---

)

        Note that dimensions and indices appear in opposite orders. Dimensions in the
        [#declarations|declaration] are read right to left whereas indices are read
        left to right:
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
import std.stdio : writeln;

void main()
{
    double[6][3] matrix = 0;
    matrix[2][5] = 3.14; // Assignment to bottom right element.
    writeln(matrix); // [[0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 3.14]]

    static assert(!__traits(compiles, matrix[5][2])); // Array index out of bounds.
}

---

)

More information can be found at $(LINK2 https://wiki.dlang.org/Dense_multidimensional_arrays, Dlang Wiki - Dense Multidimensional Arrays).

$(H2 $(ID array-properties) Array Properties)

        Static array properties are:

    $(TABLE_ROWS
Static Array Properties
        * + Property
+ Description

        * -  `.init`
- Returns an array literal with each element of the literal being the `.init` property of the array element type.

        * - `.sizeof`
- Returns the array length multiplied by
        the number of bytes per array element.

        * - `.length`
- Returns the number of elements in the array.
        This is a fixed quantity for static arrays. It is of type `size_t`.

        * - `.ptr`
- Returns a pointer to the first element of the array.

        * - `.dup`
- Create a dynamic array of the same size and copy the contents of the array into it. The copy will have any immutability or const stripped. If this conversion is invalid the call will not compile.

        * - `.idup`
- Create a dynamic array of the same size and copy the contents of the array into it. The copy is typed as being immutable. If this conversion is invalid the call will not compile.

        * - `.tupleof`
- Returns an $(LINK2 spec/template#homogeneous_sequences,lvalue sequence) of each element in the array:
            $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
void foo(int, int, int) { /* ... */ }

int[3] ia = [1, 2, 3];
foo(ia.tupleof); // same as `foo(1, 2, 3);`

float[3] fa;
//fa = ia; // error
fa.tupleof = ia.tupleof;
assert(fa == [1F, 2F, 3F]);

---
            
)
            

        
)

        Dynamic array properties are:

    $(TABLE_ROWS
Dynamic Array Properties
        * + Property
+ Description

        * - `.init`
- Returns `null`.

        * - `.sizeof`
- Returns the size of the dynamic array reference,
        which is 8 in 32-bit builds and 16 on 64-bit builds.

        * - `.length`
- Get/set number of elements in the
        array. It is of type `size_t`.

        * - `.capacity`
- Returns the length the array can grow to without reallocating.
            See [#capacity-reserve|here] for details.

        * - `.ptr`
- Returns a pointer to the first element of the array.

        * - `.dup`
- Create a dynamic array of the same size and copy the contents of the array into it. The copy will have any immutability or const stripped. If this conversion is invalid the call will not compile.

        * - `.idup`
- Create a dynamic array of the same size and copy the contents of the array into it. The copy is typed as being immutable. If this conversion is invalid the call will not compile.

                
)

    Examples:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
int* p;
int[3] s;
int[] a;

p.length; // error, length not known for pointer
s.length; // compile time constant 3
a.length; // runtime value

p.dup;    // error, length not known
s.dup;    // creates an array of 3 elements, copies
          // elements of s into it
a.dup;    // creates an array of a.length elements, copies
          // elements of a into it

---

)

$(H3 $(ID resize) Setting Dynamic Array Length)

        The `.length` property of a dynamic array can be set
        as the left-hand side of an `=` operator:
        

---
array.length = 7;

---

        This causes the array to be reallocated in place, and the existing
        contents copied over to the new array. If the new array length is
        shorter, the array is not reallocated, and no data is copied.  It is
        equivalent to slicing the array:

---
array = array[0..7];

---

        If the new array length is longer, the array is reallocated if necessary,
        preserving the existing elements. The new elements are filled out with the
        default initializer.
        

$(H4 $(ID growing) Growing an Array)

        To maximize efficiency, the runtime always tries to resize the array
        in place to avoid extra copying. It will do a copy if the new size
        is larger and either:

$(LIST
* The array was not $(LINK2 spec/garbage#op_involving_gc,allocated by the GC).
* There is no spare [#capacity-reserve|capacity] for the array.
* Resizing in place would overwrite valid data still accessible in another slice.


)
$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
char[] a = new char[20];
char[] b = a[0..10];
char[] c = a[10..20];
char[] d = a;

b.length = 15; // always reallocates because extending in place would
               // overwrite other data in a.
b[11] = 'x';   // a[11] and c[1] are not affected
assert(a[11] == char.init);

d.length = 1;
assert(d.ptr == a.ptr); // unchanged

d.length = 20; // also reallocates, because doing this will overwrite a and c
assert(d.ptr != a.ptr);

c.length = 12; // may reallocate in place if space allows, because nothing
               // was allocated after c.
c[5] = 'y';    // may affect contents of a, but not b or d because those
               // were reallocated.

a.length = 25; // This always reallocates because if c extended in place,
               // then extending a would overwrite c.  If c didn't
               // reallocate in place, it means there was not enough space,
               // which will still be true for a.
a[15] = 'z';   // does not affect c, because either a or c has reallocated.

---

)


        To guarantee copying behavior, use the `.dup` property to ensure
        a unique array that can be resized.
        

        Note: These issues also apply to
        [#array-appending|appending arrays] with the `~=` operator.
        Concatenation using the `~` operator is not affected since it always
        reallocates.
        

        Resizing a dynamic array is a relatively expensive operation.
        So, while the following method of filling an array:
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
void fun()
{
    int[] array;
    while (1)
    {
        import core.stdc.stdio : getchar;
        auto c = getchar;
        if (!c)
            break;
        ++array.length;
        array[array.length - 1] = c;
    }
}

---

)

        will work, it will be inefficient. A more practical
        approach would be to minimize the number of resizes:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
void fun()
{
    int[] array;
    array.length = 100;        // guess
    int i;
    for (i = 0; ; i++)
    {
        import core.stdc.stdio : getchar;
        auto c = getchar;
        if (!c)
            break;
        if (i == array.length)
            array.length *= 2;
        array[i] = c;
    }
    array.length = i;
}

---

)

        Base selection of the initial size on expected common
        use cases, which can be determined by instrumenting the code,
        or simply using good judgement.
        For example, when gathering user
        input from the console - it's unlikely to be longer than 80.
        

$(H3 $(ID capacity-reserve) `capacity` and `reserve`)

        The `capacity` property gives the maximum length a dynamic array
        can grow to without reallocating. If the array does not point to
        GC-allocated memory, the capacity will be zero.
        The spare capacity for an array <em>a</em> is `a.capacity - a.length`.

        By default, `capacity` will be zero if an element has been stored after the slice.

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
int[] a;
assert(a.capacity == 0);
a.length = 3; // may allocate spare capacity too
assert(a.capacity &gt;= 3);
auto b = a[1..3];
assert(b.capacity &gt;= 2); // either a or b can append into any spare capacity
b = a[0..2];
assert(b.capacity == 0);

---
        
)

        Rationale: This behaviour helps prevent accidental overwriting of
        elements in another slice. It is also necessary to protect immutable
        elements from being overwritten.

        The `reserve`
        function expands an array's capacity for use by the
        [#array-appending|append operator] or `.length` assignment.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
int[] array;
const size_t cap = array.reserve(10); // request
assert(cap &gt;= 10); // allocated may be more than request
assert(array.ptr != null);

int[] copy = array;
assert(copy.capacity == cap); // array and copy have same capacity
array ~= [1, 2, 3, 4, 5]; // grow in place
assert(cap == array.capacity); // array memory was not reallocated
assert(copy.ptr == array.ptr);
assert(copy.capacity == 0);
copy ~= 0; // new allocation
assert(copy.ptr != array.ptr);

---

)
        Above, `copy`'s length remains zero but it points to the same
        memory allocated by the `reserve` call. Because `array` is then appended
        to, `copy.ptr + 0` no longer points to unused memory - instead that
        is the address of `array[0]`. So `copy.capacity` will be zero to
        prevent any appending to `copy` from overwriting elements in `array`.

        Note: The runtime uses the number of appended elements to track the
        start of the spare capacity for the memory allocation.

        When an array with spare capacity has its length reduced, or is
        assigned a slice of itself that ends before the previous last element,
        the capacity will be zero.

        The `@system` function [object.assumeSafeAppend|assumeSafeAppend] allows the
        capacity to be regained, but care must be taken not to overwrite
        immutable elements that may exist in a longer slice.

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
int[] a = [1, 2, 3];
a.length--;
assert(a.capacity == 0);
a.assumeSafeAppend();
assert(a.capacity &gt;= 3);

---
        
)

        Note: Accessing `.capacity` may require the runtime to
        acquire a global lock and perform a cache lookup.

        $(TIP Avoid intensive use of `.capacity` in performance-sensitive code.
        Instead, track the capacity locally when building an array via a unique reference.)


$(H3 $(ID func-as-property) Functions as Array Properties)

        See $(LINK2 spec/function#pseudo-member,Uniform Function Call Syntax (UFCS)).

$(H2 $(ID bounds) Array Bounds Checking)

        It is an error to index an array with an index that is less than
        0 or greater than or equal to the array length. If an index is
        out of bounds, an `ArrayIndexError` is thrown
        if detected at runtime, and an error is raised if detected at compile
        time. A program may not rely on array bounds checking happening, for
        example, the following program is incorrect:
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
void main()
{
    import core.exception;
    try
    {
        auto array = [1, 2];
        for (auto i = 0; ; i++)
        {
            array[i] = 5;
        }
    }
    catch (ArrayIndexError)
    {
        // terminate loop
    }
}

---

)

        The loop is correctly written:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
void main()
{
    auto array = [1, 2];
    for (auto i = 0; i &lt; array.length; i++)
    {
        array[i] = 5;
    }
}

---

)

        $(B Implementation Note:) Compilers should attempt to detect
        array bounds errors at compile time, for example:
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
int[3] foo;
int x = foo[3]; // error, out of bounds

---

)

        Insertion of array bounds checking code at runtime should be
        turned on and off
        with a compile time switch.
        

        $(PITFALL An out of bounds memory access will cause undefined behavior,
            therefore array bounds check is normally enabled in `@safe` functions.
            The runtime behavior is part of the language semantics.
        )

        See also $(LINK2 spec/function#safe-functions,Safe Functions).

$(H3 $(ID disable-bounds-check) Disabling Array Bounds Checking)

        Insertion of array bounds checking code at runtime may be
            turned off with a compiler switch $(LINK2 dmd.html#switch-boundscheck, `-boundscheck`).
        

        If the bounds check in `@system` or `@trusted` code is disabled,
            the code correctness must still be guaranteed by the code author.
        

        On the other hand, disabling the bounds check in `@safe` code will
            break the guaranteed memory safety by compiler. It's not recommended
            unless motivated by speed measurements.
        

$(H2 $(ID array-initialization) Array Initialization)

$(H3 $(ID default-initialization) Default Initialization)

        $(LIST
        * Pointers are initialized to `null`.
        * Static array contents are initialized to the default
        initializer for the array element type.
        * Dynamic arrays are initialized to having 0 elements.
        * Associative arrays are initialized to having 0 elements.
        
)

$(H3 $(ID length-initialization) Length Initialization)
        The `new` expression can be used to allocate a dynamic array
        with a specified length by specifying its type and then using the
        `(size)` syntax:
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
int[] i = new int[](5); //i.length == 5
int[][] j = new int[][](10, 5); //j.length == 10, j[0].length == 5

---

)

$(H3 $(ID void-initialization) Void Initialization)

        Void initialization happens when the $(I Initializer) for
        an array is `void`. What it means is that no initialization
        is done, i.e. the contents of the array will be undefined.
        This is most useful as an efficiency optimization.
        Void initializations are an advanced technique and should only be used
        when profiling indicates that it matters.
        
        To void initialise the <em>elements</em> of a dynamic array use
        $(REF uninitializedArray, std,array).
        


$(H3 $(ID static-init-static) Static Initialization of Statically Allocated Arrays)

        Static initalizations are supplied by a list of array
        element values enclosed in `[ ]`. The values can be optionally
        preceded by an index and a `:`.
        If an index is not supplied, it is set to the previous index
        plus 1, or 0 if it is the first value.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
int[3] a = [ 1:2, 3 ]; // a[0] = 0, a[1] = 2, a[2] = 3

assert(a == [0, 2, 3]);

---

)

        This is most handy when the array indices are given by $(LINK2 spec/enum, Enums):

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
enum Color { red, blue, green }

int[Color.max + 1] value =
  [ Color.blue :6,
    Color.green:2,
    Color.red  :5 ];

assert(value == [5, 6, 2]);

---

)

        All elements of a static array can be initialized to a specific value with:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
int[4] a = 42; // set all elements of a to 42

assert(a == [42, 42, 42, 42]);

---

)

        These arrays are statically allocated when they appear in global scope.
        Otherwise, they need to be marked with `const` or `static`
        storage classes to make them statically allocated arrays.


$(H2 $(ID special-array) Special Array Types)

$(H3 $(ID strings) Strings)

        A string is an array of $(LINK2 spec/const3#immutable_type,immutable)
        (read-only) characters. String literals essentially are
        an easy way to write character array literals.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
char[] arr;
//arr = "abc";          // error, cannot implicitly convert expression `"abc"` of type `string` to `char[]`
arr = "abc".dup;        // ok, allocates mutable copy

string str1 = "abc";    // ok, same types
//str1 = arr;           // error, cannot implicitly convert expression `arr` of type `char[]` to `string`
str1 = arr.idup;        // ok, allocates an immutable copy of elements
assert(str1 == "abc");

string str2 = str1;     // ok, mutable slice of same immutable array contents

---

)

        The name `string` is aliased to `immutable(char)[]`.
        The type `immutable(char)[]` represents an array of `immutable char`s. However, the reference to the string is
        mutable.
        
---
immutable(char)[] s = "foo";
s[0] = 'a';  // error, s[0] is immutable
s = "bar";   // ok, s itself is not immutable

---

        If the reference to the string needs to be immutable as well, it can be declared `immutable char[]`
        or `immutable string`:
        
---
immutable char[] s = "foo";
s[0] = 'a';  // error, s refers to immutable data
s = "bar";   // error, s is immutable

---

        Strings can be copied, compared, concatenated, and appended:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
string s1;
immutable s2 = "ello";
s1 = s2;
s1 = "h" ~ s1;
if (s1 &gt; "farro")
    s1 ~= " there";

assert(s1 == "hello there");

---

)

        with array semantics. Any generated temporaries get cleaned up
        by the garbage collector (or by using `alloca()`).
        Not only that, this works with any
        array not just a special String array.
        

$(H4 $(ID string-literal-types) String Literal Types)

        The type of a $(LINK2 spec/expression#string_literals,string literal)
        is determined by the semantic phase of compilation. The type is
        determined by implicit conversion rules.
        If there are two equally applicable implicit conversions,
        the result is an error. To
        disambiguate these cases, a cast or a postfix of `c`,
        `w` or `d` can be used:
        

---
cast(immutable(wchar)[]) "abc" // this is an array of wchar characters
"abc"w                         // so is this

---

        String literals that do not have a postfix character and that
        have not been cast can be implicitly converted between
        `string`, `wstring`, and `dstring` (see below) as necessary.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
void fun()
{
    char c;
    wchar w;
    dchar d;

    c = 'b';     // c is assigned the character 'b'
    w = 'b';     // w is assigned the wchar character 'b'
    //w = 'bc';  // error - only one wchar character at a time
    w = "b"[0];  // w is assigned the wchar character 'b'
    w = "\r"[0]; // w is assigned the carriage return wchar character
    d = 'd';     // d is assigned the character 'd'
}

---

)

$(H4 $(ID strings-unicode)Strings and Unicode)

        String data is encoded as follows:

        $(TABLE_ROWS

        * + Alias
+ Type
+ Encoding

        * - `string`
- ` immutable(char)[]`
- UTF-8

        * - `wstring`
- `immutable(wchar)[]`
- UTF-16

        * - `dstring`
- `immutable(dchar)[]`
- UTF-32

        
)

        Note that built-in comparison operators operate on a
        $(LINK2 http://www.unicode.org/glossary/#code_unit, code unit) basis.
        The end result for valid strings is the same as that of
        $(LINK2 http://www.unicode.org/glossary/#code_point, code point)
        for $(LINK2 http://www.unicode.org/glossary/#code_point, code point)
        comparison as long as both strings are in the same
        $(LINK2 http://www.unicode.org/glossary/#normalization_form, normalization form).
        Since normalization is a costly operation not suitable for language
        primitives it's assumed to be enforced by the user.
        
        The standard library lends a hand for comparing strings with mixed encodings
        (by transparently decoding, see $(REF cmp, std,algorithm)),
        $(REF_ALTTEXT case-insensitive comparison, icmp, std,uni) and $(REF_ALTTEXT normalization, normalize, std,uni).
        
        Last but not least, a desired string sorting order differs
        by culture and language and is usually nothing like code point
        for code point comparison. The natural order of strings is obtained by applying
        [http://www.unicode.org/reports/tr10/, the Unicode collation algorithm]
        that should be implemented in the standard library.
        

$(H4 $(ID char-pointers) Character Pointers and C strings)

        A pointer to a character can be generated:
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
string str = "abcd";
immutable(char)* p = &amp;str[3]; // pointer to 4th element
assert(*p == 'd');
p = str.ptr; // pointer to 1st element
assert(*p == 'a');

---

)

        Only string <em>literals</em> are zero-terminated in D.
        In general, when transferring a pointer
        to string data to C, append a terminating `'\0'`:
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
string str = "ab";
assert(str.ptr[2] == '\0'); // OK
str ~= "cd";
// str is no longer zero-terminated
str ~= "\0";
assert(str[4] == '\0'); // OK
str.length = 2;
// str is no longer correctly zero-terminated
assert(str.ptr[2] != '\0');

---

)

        The function $(REF toStringz, std,string) can also be used.

$(H4 $(ID printf) Example: `printf`)

        $(REF printf, core,stdc,stdio) is a C function and is not part of D. `printf()`
        will print C strings, which are 0 terminated. There are two ways
        to use `printf()` with D strings. The first is to add a
        terminating 0:
        

---
str ~= "\0";
printf("the string is '%s'\n", str.ptr);

---

        or:

---
import std.string;
printf("the string is '%s'\n", std.string.toStringz(str));

---

        String literals already have a 0 appended to them, so
        can be used directly:

---
printf("the string is '%s'\n", "string literal".ptr);

---

        So, why does the first string literal to `printf` not need
        the `.ptr`? The first parameter is prototyped as a `const(char)*`, and
        a string literal can be implicitly converted to a `const(char)*`.
        The rest of the arguments to `printf`, however, are variadic
        (specified by `...`),
        and a string literal typed `immutable(char)[]` cannot be passed
        to variadic parameters.

        The second way is to use the precision specifier.
        The length comes first, followed by the pointer:

---
printf("the string is '%.*s'\n", cast(int)str.length, str.ptr);

---

        The best way is to use $(REF writefln, std,stdio), which can handle
        D strings:

---
import std.stdio;
writefln("the string is '%s'", str);

---

$(H3 $(ID void_arrays) Void Arrays)

    There is a special type of array which acts as a wildcard that can hold
    arrays of any kind, declared as `void[]`. Void arrays are used for
    low-level operations where some kind of array data is being handled, but
    the exact type of the array elements are unimportant. The `.length` of a
    void array is the length of the data in bytes, rather than the number of
    elements in its original type. Array indices in indexing and slicing
    operations are interpreted as byte indices.

    Arrays of any type can be implicitly converted to a void array; the
    compiler inserts the appropriate calculations so that the `.length` of
    the resulting array's size is in bytes rather than number of elements. Void
    arrays cannot be converted back to the original type without using a cast,
    and it is an error to convert to an array type whose element size does not
    evenly divide the length of the void array.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
void main()
{
    int[] data1 = [1,2,3];
    long[] data2;

    void[] arr = data1;            // OK, int[] implicit converts to void[].
    assert(data1.length == 3);
    assert(arr.length == 12);      // length is implicitly converted to bytes.

    //data1 = arr;                 // Illegal: void[] does not implicitly
                                   // convert to int[].
    int[] data3 = cast(int[]) arr; // OK, can convert with explicit cast.
    data2 = cast(long[]) arr;      // Runtime error: long.sizeof == 8, which
                                   // does not divide arr.length, which is 12
                                   // bytes.
}

---

)

    Void arrays can also be static if their length is known at
    compile-time. The length is specified in bytes:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
void main()
{
    byte[2] x;
    int[2] y;

    void[2] a = x; // OK, lengths match
    void[2] b = y; // Error: int[2] is 8 bytes long, doesn't fit in 2 bytes.
}

---

)

    While it may seem that void arrays are just fancy syntax for
    `ubyte[]`, there is a subtle distinction. The garbage collector
    generally will not scan `ubyte[]` arrays for pointers, `ubyte[]`
    being presumed to contain only pure byte data, not pointers. However, it
    $(I will) scan `void[]` arrays for pointers, since such an array may
    have been implicitly converted from an array of pointers or an array of
    elements that contain pointers.  Allocating an array that contains pointers
    as `ubyte[]` may run the risk of the GC collecting live memory if these
    pointers are the only remaining references to their targets.

$(H2 $(ID implicit-conversions) Implicit Conversions)

        A pointer `T*` can be implicitly converted to
        one of the following:

        $(LIST
        * `void*`
        
)

        A static array `T[dim]` can be implicitly
        converted to
        one of the following (`U` is a base class of `T`):
        

        $(LIST
        * `T[]`

        * `const(U)[]`
        * `const(U[])`
        * `void[]`
        
)

        A dynamic array `T[]` can be implicitly converted to one of the
        following (`U` is a base class of `T`):

        $(LIST
        * `const(U)[]`
        * `const(U[])`
        * `void[]`
        
)

        Array literals can also be implicitly converted to static array
        types. See $(LINK2 spec/expression#array_literals,Array Literals)
        for details.

        String literals can also be implicitly converted to static array
        types and character pointer types. See $(LINK2 spec/expression#string_literals,        String Literals) for details.

statement, Statements, hash-map, Associative Arrays




Link_References:
	ACC = Associated C Compiler
+/
module arrays.dd;
