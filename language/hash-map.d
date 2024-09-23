// just docs: Associative Arrays
/++





        Associative arrays have an index that is not necessarily an integer,
        and can be sparsely populated. The index for an associative array
        is called the $(I key), and its type is called the $(I KeyType).

        Associative arrays are declared by placing the $(I KeyType)
        within the `[ ]` of an array declaration:
        

        $(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
int[string] aa;   // Associative array of ints that are
                  // indexed by string keys.
                  // The KeyType is string.
aa["hello"] = 3;  // set value associated with key "hello" to 3
int value = aa["hello"];  // lookup value from a key
assert(value == 3);

---
        
)

        Neither the $(I KeyType)s nor the element types of an associative
        array can be function types or `void`.
        

        $(WARNING The built-in associative arrays do not preserve the order
        of the keys inserted into the array. In particular, in a `foreach` loop the
        order in which the elements are iterated is typically unspecified.)

$(H2 $(ID literals) Literals)

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
auto aa = [21u: "he", 38: "ho", 2: "hi"];
static assert(is(typeof(aa) == string[uint]));
assert(aa[2] == "hi");

---

)
    See $(LINK2 spec/expression#associative_array_literals,Associative Array Literals).

$(H2 $(ID removing_keys) Removing Keys)

        Particular keys in an associative array can be removed with the
        `remove` function:
        

---
aa./* adrdox_highlight{ */remove/* }adrdox_highlight */("hello");

---

        `remove(key)` does nothing if the given $(I key) does not exist and
        returns `false`.  If the given $(I key) does exist, it removes it
        from the AA and returns `true`.
        

        All keys can be removed by using the method `clear`.

$(H2 $(ID testing_membership) Testing Membership)

        The [expression#InExpression|expression, InExpression] yields a pointer to the value
        if the key is in the associative array, or `null` if not:
        

---
int* p;

p = "hello" /* adrdox_highlight{ */in/* }adrdox_highlight */ aa;
if (p !is null)
{
    *p = 4;  // update value associated with key
    assert(aa["hello"] == 4);
}

---

        $(PITFALL Adjusting the pointer to point before or after
        the element whose address is returned, and then dereferencing it.)

$(H2 $(ID using_classes_as_key) Using Classes as the KeyType)

        Classes can be used as the $(I KeyType). For this to work,
        the class definition must override the following member functions
        of class `Object`:

        $(LIST
        * `size_t toHash() @trusted nothrow`
        * `bool opEquals(Object)`
        
)

        Note that the parameter to `opEquals` is of type
        `Object`, not the type of the class in which it is defined.

        For example:

---
class Foo
{
    int a, b;

    override size_t /* adrdox_highlight{ */toHash/* }adrdox_highlight */() { return a + b; }

    override bool /* adrdox_highlight{ */opEquals/* }adrdox_highlight */(Object o)
    {
        Foo foo = cast(Foo) o;
        return foo &amp;&amp; a == foo.a &amp;&amp; b == foo.b;
    }
}

---

        $(WARNING         `opCmp` is not used to check for equality by the
        associative array. However, since the actual `opEquals` or
        `opCmp` called is not decided until runtime, the compiler cannot always
        detect mismatched functions. Because of legacy issues, the compiler may
        reject an associative array key type that overrides `opCmp` but not
        `opEquals`. This restriction may be removed in future versions.)

        $(PITFALL         $(NUMBERED_LIST
        * If `toHash` must consistently be the
        same value when `opEquals` returns true. In other words, two objects
        that are considered equal should always have the same hash value.
        Otherwise, undefined behavior will result.
        
))

        $(TIP         $(NUMBERED_LIST
        * Use the attributes `@safe`, `@nogc`, `pure`, `const`, and `scope` as much as possible
        on the `toHash` and `opEquals` overrides.
        
))

$(H2 $(ID using_struct_as_key) Using Structs or Unions as the KeyType)

        If the $(I KeyType) is a struct or union type,
        a default mechanism is used
        to compute the hash and comparisons of it based on the
        fields of the struct value. A custom mechanism can be used
        by providing the following functions as struct members:
        

---
size_t /* adrdox_highlight{ */toHash/* }adrdox_highlight */() const @safe pure nothrow;
bool /* adrdox_highlight{ */opEquals/* }adrdox_highlight */(ref const typeof(this) s) const @safe pure nothrow;

---

        For example:

---
import std.string;

struct MyString
{
    string str;

    size_t /* adrdox_highlight{ */toHash/* }adrdox_highlight */() const @safe pure nothrow
    {
        size_t hash;
        foreach (char c; str)
            hash = (hash * 9) + c;
        return hash;
    }

    bool /* adrdox_highlight{ */opEquals/* }adrdox_highlight */(ref const MyString s) const @safe pure nothrow
    {
        return std.string.cmp(this.str, s.str) == 0;
    }
}

---

        The functions can use `@trusted` instead of `@safe`.

        $(WARNING `opCmp` is not used to check for equality by the
        associative array.  For this reason, and for legacy reasons, an
        associative array key is not allowed to define a specialized `opCmp`,
        but omit a specialized `opEquals`. This restriction may be
        removed in future versions of D.)

        $(PITFALL         $(NUMBERED_LIST
        * If `toHash` must consistently be the
        same value when `opEquals` returns true. In other words, two structs
        that are considered equal should always have the same hash value.
        Otherwise, undefined behavior will result.
        
))

        $(TIP         $(NUMBERED_LIST
        * Use the attributes `@nogc` as much as possible
        on the `toHash` and `opEquals` overrides.
        
))

$(H2 $(ID construction_assignment_entries) Construction or Assignment on Setting AA Entries)

    When an AA indexing access appears on the left side of an assignment
    operator, it is specially handled for setting an AA entry associated with
    the key.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
string[int] aa;
string s;

//s = aa[1];        // throws RangeError in runtime
aa[1] = "hello";    // handled for setting AA entry
s = aa[1];          // succeeds to lookup
assert(s == "hello");

---

)
    If the assigned value type is equivalent with the AA element type:

      $(NUMBERED_LIST
        * If the indexing key does not yet exist in AA, a new AA entry will be
        allocated, and it will be initialized with the assigned value.
        * If the indexing key already exists in the AA, the setting runs normal
        assignment.
      
)

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
struct S
{
    int val;
    void opAssign(S rhs) { this.val = rhs.val * 2; }
}
S[int] aa;
aa[1] = S(10);  // first setting initializes the entry aa[1]
assert(aa[1].val == 10);
aa[1] = S(10);  // second setting invokes normal assignment, and
                // operator-overloading rewrites it to member opAssign function.
assert(aa[1].val == 20);

---

)

    If the assigned value type is $(B not) equivalent with the AA element
    type, the expression could invoke operator overloading with normal indexing
    access:

---
struct S
{
    int val;
    void opAssign(int v) { this.val = v * 2; }
}
S[int] aa;
aa[1] = 10;     // is rewritten to: aa[1].opAssign(10), and
                // throws RangeError before opAssign is called

---

        However, if the AA element type is a struct which supports an
        implicit constructor call from the assigned value, implicit construction
        is used for setting the AA entry:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
struct S
{
    int val;
    this(int v) { this.val = v; }
    void opAssign(int v) { this.val = v * 2; }
}
S s = 1;    // OK, rewritten to: S s = S(1);
s = 1;      // OK, rewritten to: s.opAssign(1);

S[int] aa;
aa[1] = 10; // first setting is rewritten to: aa[1] = S(10);
assert(aa[1].val == 10);
aa[1] = 10; // second setting is rewritten to: aa[1].opAssign(10);
assert(aa[1].val == 20);

---

)
        This is designed for efficient memory reuse with some value-semantics
        structs, eg. $(REF BigInt, std,bigint).

---
import std.bigint;
BigInt[string] aa;
aa["a"] = 10;   // construct BigInt(10) and move it in AA
aa["a"] = 20;   // call aa["a"].opAssign(20)

---

$(H2 $(ID inserting_if_not_present) Inserting if not present)

    When AA access requires that there must be a value corresponding to the
        key, a value must be constructed and inserted if not present. The
        `require` function provides a means to construct a new value via a
        lazy argument. The lazy argument is evaluated when the key is not
        present. The `require` operation avoids the need to perform multiple
        key lookups.

---
class C{}
C[string] aa;

auto a = aa.require("a", new C);   // lookup "a", construct if not present

---

    Sometimes it is necessary to know whether the value was constructed or
        already exists. The `require` function doesn't provide a boolean
        parameter to indicate whether the value was constructed but instead
        allows the construction via a function or delegate. This allows the use
        of any mechanism as demonstrated below.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
class C{}
C[string] aa;

bool constructed;
auto a = aa.require("a", { constructed=true; return new C;}());
assert(constructed == true);

C newc;
auto b = aa.require("b", { newc = new C; return newc;}());
assert(b is newc);

---

)

$(H2 $(ID advanced_updating) Advanced updating)

    Typically updating a value in an associative array is simply done with
        an assign statement.

---
int[string] aa;

aa["a"] = 3;  // set value associated with key "a" to 3

---

    Sometimes it is necessary to perform different operations depending on
        whether a value already exists or needs to be constructed. The
        `update` function provides a means to construct a new value via the
        `create` delegate or update an existing value via the `update`
        delegate. The `update` operation avoids the need to perform multiple
        key lookups.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
int[string] aa;

// create
aa.update("key",
    () =&gt; 1,
    (int) {} // not executed
    );
assert(aa["key"] == 1);

// update value by ref
aa.update("key",
    () =&gt; 0, // not executed
    (ref int v) {
        v += 1;
    });
assert(aa["key"] == 2);

---

)

    For details, see [object.update|update].

$(H2 $(ID runtime_initialization) Runtime Initialization of Immutable AAs)

    Immutable associative arrays are often desirable, but sometimes
        initialization must be done at runtime. This can be achieved with
        a constructor (static constructor depending on scope),
        a buffer associative array and `assumeUnique`:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
immutable long[string] aa;

shared static this()
{
    import std.exception : assumeUnique;
    import std.conv : to;

    long[string] temp; // mutable buffer
    foreach (i; 0 .. 10)
    {
        temp[to!string(i)] = i;
    }
    temp.rehash; // for faster lookups

    aa = assumeUnique(temp);
}

void main()
{
    assert(aa["1"] == 1);
    assert(aa["5"] == 5);
    assert(aa["9"] == 9);
}

---

)

$(H2 $(ID construction_and_ref_semantic) Construction and Reference Semantics)

    An Associative Array defaults to `null`, and is constructed upon assigning the first key/value
        pair. However, once constructed, an associative array has $(I reference semantics), meaning that
        assigning one array to another does not copy the data. This is especially important when attempting
        to create multiple references to the same array.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
int[int] aa;             // defaults to null
int[int] aa2 = aa;       // copies the null reference

aa[1] = 1;
assert(aa2.length == 0); // aa2 still is null
aa2 = aa;
aa2[2] = 2;
assert(aa[2] == 2);      // now both refer to the same instance

---

)

$(H2 $(ID properties) Properties)

Properties for associative arrays are:

    $(TABLE_ROWS
Associative Array Properties
        * + Property
+ Description

        * - `.sizeof`
- Returns the size of the reference to the associative
        array; it is 4 in 32-bit builds and 8 on 64-bit builds.

        * - `.length`
- Returns number of values in the
        associative array. Unlike for dynamic arrays, it is read-only.

        * - `.dup`
- Create a new associative array of the same size
        and copy the contents of the associative array into it.

        * - `.keys`
- Returns dynamic array, the elements of which are the keys in
        the associative array.

        * - `.values`
- Returns dynamic array, the elements of which are the values in
        the associative array.

        * - `.rehash`
- Reorganizes the associative array in place so that lookups
        are more efficient. `rehash` is effective when, for example,
        the program is done loading up a symbol table and now needs
        fast lookups in it. Returns a reference to the reorganized array.

        * - `.clear`
- Removes all remaining keys and values from an associative array.
        The array is not rehashed after removal, to allow for the existing storage to be reused.
        This will affect all references to the same instance and is not equivalent to `destroy(aa)`
        which only sets the current reference to `null`

        * - `.byKey()`
- Returns a forward range suitable for use
        as a $(I ForeachAggregate) to a [statement#ForeachStatement|statement, ForeachStatement]
        which will iterate over the keys of the associative array.

        * - `.byValue()`
- Returns a forward range suitable for use
        as a $(I ForeachAggregate) to a [statement#ForeachStatement|statement, ForeachStatement]
        which will iterate over the values of the associative array.

        * - `.byKeyValue()`
- Returns a forward range suitable for
        use as a $(I ForeachAggregate) to a [statement#        ForeachStatement|statement,
        ForeachStatement] which will iterate over key-value pairs of the
        associative array. The returned pairs are represented by an opaque type
        with `.key` and `.value` properties for accessing the key and
        value of the pair, respectively.  Note that this is a low-level
        interface to iterating over the associative array and is not compatible
        with the $(LINK2 phobos/std_typecons.html#.Tuple,`Tuple`)
        type in Phobos.  For compatibility with `Tuple`, use
        $(LINK2 phobos/std_array.html#.byPair,std.array.byPair) instead.

        * - `.get(Key key, lazy Value defVal)`
-         Looks up `key`; if it exists returns corresponding value
        else evaluates and returns `defVal`.

        * - `.require(Key key, lazy Value value)`
-         Looks up `key`; if it exists returns corresponding value
        else evaluates `value`, adds it to the associative array and returns it.

        * - `.update(Key key, Value delegate() create, Value delegate(Value) update)`
-         Looks up `key`; if it exists applies the `update` delegate
        else evaluates the `create` delegate and adds it to the associative array

    
)

$(H2 $(ID examples) Examples)

$(H3 $(ID aa_example) Associative Array Example: word count)

$(DIV $(CLASS RUNNABLE_EXAMPLE)
$(DIV $(CLASS RUNNABLE_EXAMPLE_STDIN)
too many cooks
too many ingredients

)
---
import std.algorithm;
import std.stdio;

void main()
{
    ulong[string] dictionary;
    ulong wordCount, lineCount, charCount;

    foreach (line; stdin.byLine(KeepTerminator.yes))
    {
        charCount += line.length;
        foreach (word; splitter(line))
        {
            wordCount += 1;
            if (auto count = word in dictionary)
                *count += 1;
            else
                dictionary[word.idup] = 1;
        }

        lineCount += 1;
    }

    writeln("   lines   words   bytes");
    writefln("%8s%8s%8s", lineCount, wordCount, charCount);

    const char[37] hr = '-';

    writeln(hr);
    foreach (word; sort(dictionary.keys))
    {
        writefln("%3s %s", dictionary[word], word);
    }
}

---

)
    See $(LINK2 wc, wc) for the full version.

$(H3 $(ID aa_example_iteration) Associative Array Example: counting pairs)

    An Associative Array can be iterated in key/value fashion using a
        $(LINK2 spec/statement#ForeachStatement,foreach statement). As
        an example, the number of occurrences of all possible substrings of
        length 2 (aka 2-mers) in a string will be counted:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
import std.range : slide;
import std.stdio : writefln;
import std.utf : byCodeUnit; // avoids UTF-8 auto-decoding

int[string] aa;

// The string `arr` has a limited alphabet: {A, C, G, T}
// Thus, for better performance, iteration can be done _without_ decoding
auto arr = "AGATAGA".byCodeUnit;

// iterate over all pairs in the string and count each pair
// ('A', 'G'), ('G', 'A'), ('A', 'T'), ...
foreach (window; arr.slide(2))
    aa[window.source]++; // source unwraps the code unit range

// iterate over all key/value pairs of the Associative Array
foreach (key, value; aa)
{
    writefln("key: %s, value: %d", key, value);
}

---

)
$(CONSOLE > rdmd count.d
key: AT, value: 1
key: GA, value: 2
key: TA, value: 1
key: AG, value: 2
)


arrays, Arrays, struct, Structs and Unions



Link_References:
	ACC = Associated C Compiler
+/
module hash-map.dd;