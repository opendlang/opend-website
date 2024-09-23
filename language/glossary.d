// just docs: Glossary
/++





$(DL         $(DT $(ID acc) ACC (Associated C Compiler))
        $(DD The D compiler is matched to the Associated C Compiler.
        For example, on Win32 ImportC is matched to the Digital Mars C compiler,
        and can be matched to the Visual C compiler using the
        command line switch $(LINK2 dmd#switch-m32mscoff,$(TT -m32mscoff)).
        Win64 ImportC is matched to the Visual C compiler.
        On Posix targets, the matching C compiler is Gnu C or Clang C.
        )

        $(DT $(ID blit) BLIT (Block Transfer))
        $(DD Also known as BLT, blit refers to copying memory
        byte for byte. In C, this is referred to as a memcpy
        operation.
        The name originated with the BLT instruction on the
        DEC PDP-10 computer.
        )

        $(DT $(ID ctfe) CTFE (Compile Time Function Evaluation))
        $(DD Refers to the ability to execute regular D
        functions at compile time rather than at run time.)

        $(DT code point) $(DD In Unicode terminology, a code point
        is a logical character. The range of code points is <span class="d_inlinecode">0</span>
        through <span class="d_inlinecode">0x10FFFF</span>. Only <span class="d_inlinecode">dchar</span>s can store code points
        directly; arrays of <span class="d_inlinecode">char</span> and <span class="d_inlinecode">wchar</span> need to use the
        variable-length encodings UTF-8 and UTF-16.)

        $(DT $(ID cow) COW (Copy On Write))
        $(DD COW is a memory management strategy where (usually large) reference
        objects are copied if they are to be modified. The constant overhead of COW can be
        high, but may be preferable in applications that would otherwise do a lot of
        preemptive copying.
        )

        $(DT $(ID data-race)Data Race) $(DD Two or more threads writing to
        the same memory location. Program behavior may depend on the arbitrary
        sequencing of these memory accesses.
        )

        $(DT $(ID functor) Functor) $(DD A user-defined type (struct or
        class) that defines the function call operator (<span class="d_inlinecode">opCall</span> in D) so it
        can be used similarly to a function.
        )

        $(DT $(ID gc) GC (Garbage Collection))
        $(DD Garbage collection is the common name for the
        term automatic memory management. Memory can be allocated and used,
        and the GC will automatically free any chunks of memory no longer
        referred to. In contrast, explicit memory management
        is where the programmer must carefully match up each allocation with
        one and only one call to free().
        )

        $(DT Higher-order function) $(DD A function that either accepts another
        function as a parameter, returns a function, or both.
        )

    $(DT $(ID ifti) IFTI (Implicit Function Template Instantiation))
        $(DD Refers to the ability to instantiate a template function
    without having to explicitly pass in the types to the template.
    Instead, the types are inferred automatically from the types of the
    runtime arguments. See $(LINK2 spec/template.html#ifti, spec) for details.)

        $(DT Illegal)
        $(DD A code construct is illegal if it does not conform to the
        D language specification.
        This may be true even if the compiler or runtime fails to detect
        the error.
        )

        $(DT Input range) $(DD A type (i.e., a struct or a class) that
        defines the member functions empty, head, and next. Input ranges
        are assumed to be strictly one-pass: there is no way to save the
        state of the iteration in a copy of the range. See also $(LINK2         phobos/std_range.html,range).)

        $(DT Implementation Defined Behavior)
        $(DD This is variation in behavior of the D language in a manner
        that is up to the implementor of the language.
        An example of implementation defined behavior would be the size in
        bytes of a pointer: on a 32 bit machine it would be 4 bytes, on
        a 64 bit machine it would be 8 bytes.
        Minimizing implementation defined behavior in the language will
        maximize the portability of code.
        )

        $(DT $(ID lvalue) lvalue)
        $(DD An lvalue is an abstract term referring to a value with an accessible
        address (through e.g. the unary <span class="d_inlinecode">&amp;</span> operator). Typical examples of
        lvalues include variables, constants introduced with `const` or `immutable`
        (but not `enum`), and elements of arrays and associative arrays. Calls to
        functions that return `ref` and pointer dereference expressions are also
        lvalues. Lvalues can be passed to (or be returned from) functions by
        reference. An lvalue is the counterpart to an rvalue.
        )

        $(DT $(ID nrvo) NRVO (Named Return Value Optimization))
        $(DD         NRVO is a technique invented by Walter Bright around
        1991 (the term for it was coined later) to minimize copying of struct
        data.
        Functions normally return their function return values in
        registers. For structs, however, they often are too big to
        fit in registers. The usual solution to this is to pass to
        the function a $(I hidden pointer) to a struct instance in the
        caller's stack frame, and the return value is copied there.
        For example:
        
---
struct S { int a, b, c, d; }

S foo()
{
    S result;
    result.a = 3;
    return result;
}

void test()
{
    S s = foo();
}

---

        is rewritten as:

---
S* foo(S* hidden)
{
    S result;
    result.a = 3;
    *hidden = result;
    return hidden;
}

void test()
{
    S tmp;
    S s = *foo(&amp;tmp);
}

---
        This rewrite gives us an extra temporary object <span class="d_inlinecode">tmp</span>,
        and copies the struct contents twice.
        What NRVO does is recognize that the sole purpose of <span class="d_inlinecode">result</span>
        is to provide a return value, and so all references to <span class="d_inlinecode">result</span>
        can be replaced with <span class="d_inlinecode">*hidden</span>.
        <span class="d_inlinecode">foo</span> is then rewritten as:
        
---
S* foo(S* hidden)
{
    hidden.a = 3;
    return hidden;
}

---
        A further optimization is done on the call to <span class="d_inlinecode">foo</span> to eliminate
        the other copy, giving:
---
void test()
{
    S s;
    foo(&amp;s);
}

---
        The result is written directly into the destination <span class="d_inlinecode">s</span>,
        instead of passing through two other instances.
        )

        $(DT $(ID narrow-strings)narrow strings) $(DD All arrays
        that use <span class="d_inlinecode">char</span>, <span class="d_inlinecode">wchar</span>, and their qualified versions are
        narrow strings. (Those include <span class="d_inlinecode">string</span> and <span class="d_inlinecode">        wstring</span>). Range-oriented functions in the standard library handle
        narrow strings specially by automatically decoding the UTF-encoded
        characters.)

        $(DT $(ID op-apply)opApply)
        $(DD A special member function used to iterate over a
        collection; this is used by the
        $(LINK2 spec/statement.html#opApply, $(I ForeachStatement)).
        )

        $(DT $(ID op-apply-reverse)opApplyReverse)
        $(DD A special member function used to iterate over a
        collection in the reverse order; this is used by the
        $(LINK2 spec/statement.html#opApplyReverse, $(I ForeachStatement)).
        )

        $(DT $(ID pod) POD (Plain Old Data))
        $(DD Refers to a struct that contains no hidden members,
        has no destructor,
        and can be initialized and copied via simple bit copies.
        See $(LINK2 spec/struct#POD,Structs).
        )

        $(DT $(ID predicate) Predicate) $(DD A function or
        delegate returning a Boolean result. Predicates can be nullary
        (take no arguments), unary (take one argument), binary (take
        two arguments), or n-ary (take n arguments). Usually
        predicates are mentioned within the context of higher-order
        functions, which accept predicates as parameters.
        )

        $(DT $(ID qualifier-convertible) qualifier-convertible) $(DD A type `T` is
        qualifer-convertible to type `U` if and only if they only differ in qualifiers
        and if a reference to `T` can be implicitly converted to a reference to `U` per
        the $(LINK2 spec/const3.html, language rules).)

        $(DT $(ID raii) RAII (Resource Acquisition Is Initialization))
        $(DD RAII refers to the technique of having the
        $(LINK2 spec/struct#struct-destructor,destructor
        of a struct) or class object called when the object goes out of scope.
        The destructor then releases any resources acquired by
        that object.
        RAII is commonly used for resources that are in short supply
        or that must have a predictable point when they are released.
        RAII can be used for class variables declared with the
        $(LINK2 spec/attribute#scope-class-var,<span class="d_inlinecode">scope</span> storage class).
        )

        $(DT $(ID rvalue) rvalue)
        $(DD An rvalue is an abstract term referring to a value resulting from an
        expression that has no accessible memory address. This lack of address is
        only conceptual; the implementation has the liberty to store an rvalue in
        addressable memory. Rvalues cannot be changed and cannot be passed to (or
        be returned from) functions by reference. An rvalue is the counterpart to
        an lvalue.
        )

        $(DT $(ID sequential-consistency)Sequential Consistency)
        $(DD Data being written in one order in one thread
        being visible in the same order to another thread.
        )

        $(DT $(ID sfinae) SFINAE (Substitution Failure Is Not An Error))
        $(DD If template argument deduction results in a type
        that is not valid, that specialization of the template
        is not considered further. It is not a compile error.
        See also $(LINK2 https://en.wikipedia.org/wiki/Substitution_failure_is_not_an_error, SFINAE).
        )

        $(DT $(ID tmp) TMP (Template Metaprogramming))
        $(DD TMP is using the template features of the language to
        execute programs at compile time rather than runtime.)

        $(DT $(ID tls) TLS (Thread Local Storage))
        $(DD TLS allocates each thread its own instance of the
        global data. See also
        $(LINK2 https://en.wikipedia.org/wiki/Thread-local_storage, Wikipedia).)

        $(DT $(ID undefined-behavior)UB (Undefined Behavior))
        $(DD Undefined behavior happens when an illegal code construct is
        executed. Undefined behavior can include random, erratic results,
        crashes, faulting, etc.
        A buffer overflow is an example of undefined behavior.
        )

        $(DT $(ID uda) UDA (User-Defined Attribute))
        $(DD $(LINK2 spec/attribute.html#uda, $(I User-defined attributes)) are
        metadata attached to symbols used for compile-time reflection.)

        $(DT $(ID ufcs) UFCS (Uniform Function Call Syntax))
        $(DD $(LINK2 spec/function.html#pseudo-member, Uniform function call
        syntax) refers to the ability to call a function as if it were a method of
        its first argument. For example `funct(arg)` may be written as
        `arg.funct()`.)
)

windows, Windows Programming, legacy, Legacy Code




Link_References:
	ACC = Associated C Compiler
+/
module glossary.dd;