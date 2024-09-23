// just docs: Legacy Code
/++





    To maintain compatibility with older D code, many legacy features remain supported.
$(COMMENT     If the $(TT -wo) compiler command line switch is used, the compiler will give warning messages
    for each use of a legacy feature.
)
    This page describes each legacy feature that is supported, with a suggestion of how to
    modernize the code.
    

    $(TABLE_ROWS
Legacy Features
        * + Feature
+ Summary

        * - [#body|`body` keyword]
- `body` after a contract statement -
            use `do` instead

        * - `alias` target first syntax
- use `alias name = target` instead.

        * - Struct/union postblit
- use a $(LINK2 spec/struct#struct-copy-constructor,            copy constructor) instead.

    
)

$(H2 $(ID body) `body` keyword)
    `body` was a keyword used to specify a function/method's body after a contract statement:
---
class Foo
{
    void bar(int i)
    in { assert(i &gt;= 42); }
    body { /* Do something interesting */ }

    string method(string s)
    out(v) { assert(v.length == s.length); }
    body { /* Do something even more interesting */ }

    void noBody() { /* No contracts, no body */ }
}

---

$(H3 Corrective Action)

    Use the `do` keyword instead (introduced in v2.075.0):
---
void bar(int i)
in { assert(i &gt;= 42); }
do { /* Look ma, no body! */ }

---

    Rationale: The `body` keyword was only used for this single purpose.
        Since D grammar aims to be context free, this common word was reserved,
        which led to frequent trouble for people interfacing with other languages
        (e.g. javascript) or auto-generating code.
    


glossary, Glossary




Link_References:
	ACC = Associated C Compiler
+/
module legacy.dd;