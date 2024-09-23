// just docs: Unit Tests
/++





$(PRE $(CLASS GRAMMAR)
$(B $(ID UnitTest) UnitTest):
    `unittest` [statement#BlockStatement|statement, BlockStatement]

)
    Unit tests are a builtin framework of test cases
    applied to a module to determine if it is working properly.
    A D program can be run with unit tests enabled or disabled.
    

    Unit tests are a special function defined like:

---
unittest
{
    ...test code...
}

---

    Individual tests are specified in the unit test using $(LINK2 spec/expression#AssertExpression,AssertExpressions).
    Unlike $(I AssertExpression)s used elsewhere, the assert is not assumed to hold, and upon assert
    failure the program is still in a defined state.
    

    There can be any number of unit test functions in a module,
    including within struct, union and class declarations.
    They are executed in lexical order.
    

    Unit tests, when enabled, are run after all static initialization is
    complete and before the `main()` function is called.
    

    For example, given a class `Sum` that is used to add two values, a unit
    test can be given:

---
class Sum
{
    int add(int x, int y) { return x + y; }

    unittest
    {
        Sum sum = new Sum;
        assert(sum.add(3,4) == 7);
        assert(sum.add(-2,0) == -2);
    }
}

---

    When unit tests are enabled, the $(LINK2 spec/version#PredefinedVersions,version identifier)
    `unittest` is predefined.
    


$(H2 $(ID attributes_unittest) Attributed Unittests)

    A unittest may be attributed with any of the global function attributes.
    Such unittests are useful in verifying the given attribute(s) on a template
    function:

---
void myFunc(T)(T[] data)
{
    if (data.length &gt; 2)
        data[0] = data[1];
}

@safe nothrow unittest
{
    auto arr = [1,2,3];
    myFunc(arr);
    assert(arr == [2,2,3]);
}

---

    This unittest verifies that `myFunc` contains only `@safe`,
    `nothrow` code. Although this can also be accomplished by attaching these
    attributes to `myFunc` itself, that would prevent `myFunc` from being
    instantiated with types `T` that have `@system` or throwing code in their
    `opAssign` method, or other methods that `myFunc` may call. The above
    idiom allows `myFunc` to be instantiated with such types, yet at the same
    time verify that the `@system` and throwing behavior is not introduced by
    the code within `myFunc` itself.

    $(WARNING     $(NUMBERED_LIST
    * If unit tests are not enabled, the implementation is not required to
    check the [#UnitTest|UnitTest] for syntactic or semantic correctness.
    This is to reduce the compile time impact of larger unit test sections.
    The tokens must still be valid, and the implementation can merely count
    `{` and `}` tokens to find the end of the [#UnitTest|UnitTest]'s [statement#BlockStatement|statement, BlockStatement].
    
    * The presentation of unit test results to the user.
    * The method used to enable or disable the unit tests. Use of a compiler
    switch such as $(LINK2 dmd#switch-unittest,$(B -unittest)) to enable
    them is suggested.
    * The order in which modules are called to run their unit tests.
    * Whether the program stops on the first unit test failure, or continues running the unit tests.
    
)
    )

    $(TIP     $(NUMBERED_LIST
    * Using unit tests in conjunction with coverage testing
    (such as $(LINK2 dmd#switch-cov,$(B -cov)))
    is effective.
    * A unit test for a function should appear immediately
    following it.
    
)
    )


$(H2 $(ID documented-unittests) Documented Unittests)

Documented unittests allow the developer to deliver code examples to the user,
    while at the same time automatically verifying that the examples are valid. This
    avoids the frequent problem of having outdated documentation for some piece of code.

If a declaration is followed by a documented unittest, the code in
    the unittest will be inserted in the $(B example) section of the declaration:

---
/// Math class
class Math
{
    /// add function
    static int add(int x, int y) { return x + y; }

    ///
    unittest
    {
        assert(add(2, 2) == 4);
    }
}

///
unittest
{
    auto math = new Math();
    auto result = math.add(2, 2);
}

---

The above will generate the following documentation:

$(RAW_HTML <dl><dt><big><a name="Math"></a>class <u>Math</u>;
</big></dt>
<dd><u>Math</u> class<br><br>
<b>Example:</b><pre class="d_code"><font color="blue">auto</font> math = <font color="blue">new</font> <u>Math</u>;
<font color="blue">auto</font> result = math.add(2, 2);
</pre><br>
<dl><dt><big><a name="Math.add"></a>int <u>add</u>(int <i>x</i>, int <i>y</i>);
</big></dt>
<dd><u>add</u> function<br><br>
<b>Example:</b><pre class="d_code"><font color="blue">assert</font>(<u>add</u>(2, 2) == 4);
</pre>
</dd>
</dl>
</dd>
</dl>
)

A unittest which is not documented, or is marked as private will not be
    used to generate code samples.

There can be multiple documented unittests and they can appear
    in any order. They will be attached to the last non-unittest declaration:

---
/// add function
int add(int x, int y) { return x + y; }

/// code sample generated
unittest
{
    assert(add(1, 1) == 2);
}

/// code sample not generated because the unittest is private
private unittest
{
    assert(add(2, 2) == 4);
}

unittest
{
    /// code sample not generated because the unittest isn't documented
    assert(add(3, 3) == 6);
}

/// code sample generated, even if it only includes comments (or is empty)
unittest
{
    /** assert(add(4, 4) == 8); */
}

---

The above will generate the following documentation:

$(RAW_HTML <dl><dt><big><a name="add"></a>int <u>add</u>(int <i>x</i>, int <i>y</i>);
</big></dt>
<dd><u>add</u> function<br><br>
<b>Examples:</b><br>
code sample generated
<pre class="d_code">
<font color="blue">assert</font>(<u>add</u>(1, 1) == 2);
</pre>
<br><br><b>Examples:</b><br>
code sample generated, even if it is empty or only includes comments
<pre class="d_code">
<font color="green">/** assert(add(4, 4) == 8); */</font>
</pre>
<br><br>
</dd>
</dl>
)


errors, Error Handling, garbage, Garbage Collection




Link_References:
	ACC = Associated C Compiler
+/
module unittest.dd;