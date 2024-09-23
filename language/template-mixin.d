// just docs: Template Mixins
/++





        A $(I TemplateMixin) takes an arbitrary set of declarations from
        the body of a [template#TemplateDeclaration|template, TemplateDeclaration] and inserts them
        into the current context.

$(PRE $(CLASS GRAMMAR)
$(B $(ID TemplateMixinDeclaration) TemplateMixinDeclaration):
    `mixin` `template` $(LINK2 lex#Identifier, Identifier) [template#TemplateParameters|template, TemplateParameters] [template#Constraint|template, Constraint]$(SUBSCRIPT opt) `{` [module#DeclDefs|module, DeclDefs]$(SUBSCRIPT opt) `}`

$(B $(ID TemplateMixin) TemplateMixin):
    `mixin` [#MixinTemplateName|MixinTemplateName] [template#TemplateArguments|template, TemplateArguments]$(SUBSCRIPT opt) $(LINK2 lex#Identifier, Identifier)$(SUBSCRIPT opt) `;`

$(B $(ID MixinTemplateName) MixinTemplateName):
    `.` [#MixinQualifiedIdentifier|MixinQualifiedIdentifier]
    [#MixinQualifiedIdentifier|MixinQualifiedIdentifier]
    [type#Typeof|type, Typeof] `.` [#MixinQualifiedIdentifier|MixinQualifiedIdentifier]

$(B $(ID MixinQualifiedIdentifier) MixinQualifiedIdentifier):
    $(LINK2 lex#Identifier, Identifier)
    $(LINK2 lex#Identifier, Identifier) `.` MixinQualifiedIdentifier
    [template#TemplateInstance|template, TemplateInstance] `.` MixinQualifiedIdentifier

)

        A $(I TemplateMixin) can occur in declaration lists of modules,
        classes, structs, unions, or as a statement.
        $(I MixinTemplateName) must refer to a $(I TemplateDeclaration) or
        $(I TemplateMixinDeclaration).
        If the $(I TemplateDeclaration) requires no parameters, $(I TemplateArguments)
        can be omitted.
        

        Unlike a $(LINK2 spec/template#instantiation_scope,template instantiation),
        a template mixin's body is evaluated
        within the scope where the mixin appears, not where the template declaration
        is defined. It is analogous to cutting and pasting the body of
        the template into the location of the mixin into a $(LINK2 #mixin_scope, nested scope). It is useful for injecting
        parameterized 'boilerplate' code, as well as for creating
        templated nested functions, which is not always possible with
        template instantiations.
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
int y = 3;

mixin template Foo()
{
    int abc() { return y; }
}

void test()
{
    int y = 8;
    mixin Foo; // local y is picked up, not global y
    assert(abc() == 8);
}

---

)

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
import std.stdio : writeln;

mixin template Foo()
{
    int x = 5;
}

mixin Foo;

struct Bar
{
    mixin Foo;
}

void main()
{
    writeln("x = ", x);         // prints 5
    {
        Bar b;
        int x = 3;

        writeln("b.x = ", b.x); // prints 5
        writeln("x = ", x);     // prints 3
        {
            mixin Foo;
            writeln("x = ", x); // prints 5
            x = 4;
            writeln("x = ", x); // prints 4
        }
        writeln("x = ", x);     // prints 3
    }
    writeln("x = ", x);         // prints 5
}

---

)

$(H2 $(ID parameters) Mixin Parameters)

        Mixins can be
        $(LINK2 spec/template#parameters,parameterized):

---
mixin template Foo(T)
{
    T x = 5;
}

mixin Foo!(int);           // create x of type int

---

        Mixins can parameterize symbols using
        $(LINK2 spec/template#aliasparameters,alias parameters):

---
mixin template Foo(alias b)
{
    int abc() { return b; }
}

void test()
{
    int y = 8;
    mixin Foo!(y);
    assert(abc() == 8);
}

---

$(H3 $(ID example) Example)

        This example uses a mixin to implement a generic Duff's device
        for an arbitrary statement (in this case, the arbitrary statement
        is in bold). A nested function is generated as well as a
        delegate literal, these can be inlined by the compiler:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
import std.stdio : writeln;

mixin template duffs_device(alias low, alias high, alias fun)
{
    void duff_loop()
    {
        if (low &lt; high)
        {
            auto n = (high - low + 7) / 8;
            switch ((high - low) % 8)
            {
                case 0: do { fun(); goto case;
                case 7:      fun(); goto case;
                case 6:      fun(); goto case;
                case 5:      fun(); goto case;
                case 4:      fun(); goto case;
                case 3:      fun(); goto case;
                case 2:      fun(); goto case;
                case 1:      fun(); continue;
                default:     assert(0, "Impossible");
                        } while (--n &gt; 0);
            }
        }
    }
}

void main()
{
    int i = 1;
    int j = 11;

    mixin duffs_device!(i, j, delegate { writeln("foo"); });
    duff_loop();  // executes foo() 10 times
}

---

)

$(H2 $(ID mixin_scope) Mixin Scope)

        The declarations in a mixin are placed in a nested scope and then
        'imported' into the surrounding
        scope. If the name of a declaration in a mixin is the same
        as a declaration in the surrounding scope, the surrounding declaration
        overrides the mixin one:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
import std.stdio : writeln;

int x = 3;

mixin template Foo()
{
    int x = 5;
    int y = 5;
}

mixin Foo;
int y = 3;

void main()
{
    writeln("x = ", x);  // prints 3
    writeln("y = ", y);  // prints 3
}

---

)

        A mixin has its own scope, even if a declaration is overridden
        by the enclosing one:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
import std.stdio : writeln;

int x = 4;

mixin template Foo()
{
    int x = 5;
    int bar() { return x; }
}

mixin Foo;

void main()
{
    writeln("x = ", x);         // prints 4
    writeln("bar() = ", bar()); // prints 5
}

---

)

        If two different mixins are put in the same scope, and each
        define a declaration with the same name, there is an ambiguity
        error when the declaration is referenced:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
import std.stdio : writeln;

mixin template Foo()
{
    int x = 5;
    void func(int x) { }
}

mixin template Bar()
{
    int x = 4;
    void func(long x) { }
}

mixin Foo;
mixin Bar;

void main()
{
    writeln("x = ", x);    // error, x is ambiguous
    func(1);               // error, func is ambiguous
}

---

)
        The call to `func()` is ambiguous because
        `Foo.func` and `Bar.func` are in different scopes.
        

$(H3 $(ID resolving_ambiguities) Resolving Ambiguities)

        If a mixin has an $(I Identifier), it can be used to
        disambiguate between conflicting symbols:
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
import std.stdio : writeln;

int x = 6;

mixin template Foo()
{
    int x = 5;
    int y = 7;
    void func() { }
}

mixin template Bar()
{
    int x = 4;
    void func() { }
}

mixin Foo F;
mixin Bar B;

void main()
{
    writeln("y = ", y);     // prints 7
    writeln("x = ", x);     // prints 6
    writeln("F.x = ", F.x); // prints 5
    writeln("B.x = ", B.x); // prints 4
    F.func();                  // calls Foo.func
    B.func();                  // calls Bar.func
}

---

)
        Alias declarations can be used to form an
        $(LINK2 spec/function#overload-sets,overload set) of
        functions declared in different mixins:

---
mixin template Foo()
{
    void func(int x) {  }
}

mixin template Bar()
{
    void func(long x) {  }
}

mixin Foo!() F;
mixin Bar!() B;

alias func = F.func;
alias func = B.func;

void main()
{
    func(1);  // calls B.func
    func(1L); // calls F.func
}

---

$(H2 $(ID aggregate_types) Aggregate Type Mixins)

$(H3 $(ID virtual_functions) Mixin Virtual Functions)

        Mixins can add virtual functions to a class:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
import std.stdio : writeln;

mixin template Foo()
{
    void func() { writeln("Foo.func()"); }
}

class Bar
{
    mixin Foo;
}

class Code : Bar
{
    override void func() { writeln("Code.func()"); }
}

void main()
{
    Bar b = new Bar();
    b.func();      // calls Foo.func()

    b = new Code();
    b.func();      // calls Code.func()
}

---

)

$(H3 $(ID destructors) Mixin Destructors)

        An aggregate type can mixin additional destructors.
        Destructors are run in the opposite order to declaration order.

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
import std.stdio;

mixin template addNewDtor()
{
    ~this()
    {
        writeln("Mixin dtor");
    }
}

struct S
{
    ~this()
    {
        writeln("Struct dtor");
    }

    mixin addNewDtor;
}

void main()
{
    S s;
    // prints `Mixin dtor`
    // prints `Struct dtor`
}

---

)

template, Templates, contracts, Contract Programming




Link_References:
	ACC = Associated C Compiler
+/
module template-mixin.dd;