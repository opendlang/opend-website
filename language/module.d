// just docs: Modules
/++





$(PRE $(CLASS GRAMMAR)
$(B $(ID Module) Module):
    [#ModuleDeclaration|ModuleDeclaration]
    [#ModuleDeclaration|ModuleDeclaration] [#DeclDefs|DeclDefs]
    [#DeclDefs|DeclDefs]

$(B $(ID DeclDefs) DeclDefs):
    [#DeclDef|DeclDef]
    [#DeclDef|DeclDef] DeclDefs

$(B $(ID DeclDef) DeclDef):
    [attribute#AttributeSpecifier|attribute, AttributeSpecifier]
    [declaration#Declaration|declaration, Declaration]
    [class#Constructor|class, Constructor]
    [class#Destructor|class, Destructor]
    [struct#Postblit|struct, Postblit]
    [class#Invariant|class, Invariant]
    [unittest#UnitTest|unittest, UnitTest]
    [class#AliasThis|class, AliasThis]
    [class#StaticConstructor|class, StaticConstructor]
    [class#StaticDestructor|class, StaticDestructor]
    [class#SharedStaticConstructor|class, SharedStaticConstructor]
    [class#SharedStaticDestructor|class, SharedStaticDestructor]
    [version#ConditionalDeclaration|version, ConditionalDeclaration]
    [version#DebugSpecification|version, DebugSpecification]
    [version#VersionSpecification|version, VersionSpecification]
    [#MixinDeclaration|MixinDeclaration]
    [#EmptyDeclaration|EmptyDeclaration]

$(B $(ID EmptyDeclaration) EmptyDeclaration):
    `;`

)

Modules have a one-to-one correspondence with source files. When not
explicitly set via a [#ModuleDeclaration|ModuleDeclaration], a module's name defaults
to the name of the file stripped of its path and extension.

A module's name automatically acts as a namespace scope for its contents. Modules
superficially resemble classes, but differ in that:

$(LIST
        * Only one instance of a module exists, and it is
        statically allocated.

        * Modules do not have virtual tables.

        * Modules do not inherit, do not have super modules, etc.

        * A source file may contain only one module.

        * Symbols in a module can be imported.

        * Modules are always compiled at global scope and are unaffected
        by surrounding attributes or other modifiers.

)

Modules can be grouped into hierarchies called $(I packages).

Modules offer several guarantees:

$(LIST

        * The order in which modules are imported does not affect their
        semantics.

        * The semantics of a module are not affected by the scope in which
        it is imported.

        * If a module `C` imports modules `A` and `B`, any modifications
        to `B` will not silently change code in `C` that is dependent on `A`.

)

$(H2 $(ID module_declaration) Module Declaration)

The $(I ModuleDeclaration) sets the name of the module and what package it
belongs to. If absent, the module name is taken to be the same name (stripped of
path and extension) of the source file name.

$(PRE $(CLASS GRAMMAR)
$(B $(ID ModuleDeclaration) ModuleDeclaration):
    [#ModuleAttributes|ModuleAttributes]$(SUBSCRIPT opt) `module` [#ModuleFullyQualifiedName|ModuleFullyQualifiedName] `;`

$(B $(ID ModuleAttributes) ModuleAttributes):
    [#ModuleAttribute|ModuleAttribute]
    [#ModuleAttribute|ModuleAttribute] ModuleAttributes

$(B $(ID ModuleAttribute) ModuleAttribute):
    [attribute#DeprecatedAttribute|attribute, DeprecatedAttribute]
    [attribute#UserDefinedAttribute|attribute, UserDefinedAttribute]

$(B $(ID ModuleFullyQualifiedName) ModuleFullyQualifiedName):
    [#ModuleName|ModuleName]
    [#Packages|Packages] `.` [#ModuleName|ModuleName]

$(B $(ID ModuleName) ModuleName):
    $(LINK2 lex#Identifier, Identifier)

)
$(PRE $(CLASS GRAMMAR)
$(B $(ID Packages) Packages):
    [#PackageName|PackageName]
    Packages `.` [#PackageName|PackageName]

$(B $(ID PackageName) PackageName):
    $(LINK2 lex#Identifier, Identifier)

)

The $(I Identifier)s preceding the rightmost $(I Identifier) are the $(I Packages) that the
module is in. The packages correspond to directory names in the source file
path. Package and module names cannot be $(LINK2 lex#Keyword, Keyword)s.

If present, the $(I ModuleDeclaration) must be the first and only such declaration
in the source file, and may be preceded only by comments and `#line` directives.

Example:

---
module c.stdio; // module stdio in the c package

---

By convention, package and module names are all lower case. This is because
these names have a one-to-one correspondence with the operating system's
directory and file names, and many file systems are not case sensitive. Using all
lower case package and module names will avoid or minimize problems when moving projects
between dissimilar file systems.

If the file name of a module is an invalid module name (e.g.
`foo-bar.d`), use a module declaration to set a valid module name:

---
module foo_bar;

---

    $(WARNING     $(NUMBERED_LIST
    * The mapping of package and module identifiers to directory and file names.
    
))

    $(TIP     $(NUMBERED_LIST
    * [#PackageName|PackageName]s and [#ModuleName|ModuleName]s should be composed of the ASCII
    characters lower case letters, digits or `_` to ensure maximum portability and compatibility with
    various file systems.
    * The file names for packages and modules should be composed only of
    the ASCII lower case letters, digits, and `_`s, and should not be a $(LINK2 lex#Keyword, Keyword).
    
))

$(H3 $(ID deprecated_modules) Deprecated modules)

A $(I ModuleDeclaration) can have an optional [attribute#DeprecatedAttribute|attribute,
DeprecatedAttribute]. The compiler will produce a message when the deprecated
module is imported.

---
deprecated module foo;

---

---
module bar;
import foo;  // Deprecated: module foo is deprecated

---

A $(I DeprecatedAttribute) can have an optional AssignExpression argument to provide a
more informative message. The $(I AssignExpression) must evaluate to a string at compile time.


---
deprecated("Please use foo2 instead.")
module foo;

---

---
module bar;
import foo;  // Deprecated: module foo is deprecated - Please use foo2 instead.

---

    $(WARNING     $(NUMBERED_LIST
    * How the deprecation messages are presented to the user.
    
))


$(H2 $(ID import-declaration)Import Declaration)

Symbols from one module are made available in another module by using the
$(I ImportDeclaration):

$(PRE $(CLASS GRAMMAR)
$(B $(ID ImportDeclaration) ImportDeclaration):
    `import` [#ImportList|ImportList] `;`
    `static import` [#ImportList|ImportList] `;`

$(B $(ID ImportList) ImportList):
    [#Import|Import]
    [#ImportBindings|ImportBindings]
    [#Import|Import] `,` ImportList

$(B $(ID Import) Import):
    [#ModuleFullyQualifiedName|ModuleFullyQualifiedName]
    [#ModuleAliasIdentifier|ModuleAliasIdentifier] `=` [#ModuleFullyQualifiedName|ModuleFullyQualifiedName]

$(B $(ID ImportBindings) ImportBindings):
    [#Import|Import] `:` [#ImportBindList|ImportBindList]

$(B $(ID ImportBindList) ImportBindList):
    [#ImportBind|ImportBind]
    [#ImportBind|ImportBind] `,` ImportBindList

$(B $(ID ImportBind) ImportBind):
    $(LINK2 lex#Identifier, Identifier)
    $(LINK2 lex#Identifier, Identifier) `=` $(LINK2 lex#Identifier, Identifier)

$(B $(ID ModuleAliasIdentifier) ModuleAliasIdentifier):
    $(LINK2 lex#Identifier, Identifier)

)

There are several forms of the $(I ImportDeclaration), from generalized to
fine-grained importing.

The order in which $(I ImportDeclaration)s occur has no significance.

$(I ModuleFullyQualifiedName)s in the $(I ImportDeclaration) must be fully
qualified with whatever packages they are in. They are not considered to be
relative to the module that imports them.

$(H3 $(ID name_lookup) Symbol Name Lookup)

The simplest form of importing is to just list the modules being imported:

---
module myapp.main;

import std.stdio; // import module stdio from package std

class Foo : BaseClass
{
    import myapp.foo;  // import module myapp.foo in this class' scope
    void bar ()
    {
        import myapp.bar;  // import module myapp.bar in this function' scope
        writeln("hello!");  // calls std.stdio.writeln
    }
}

---

When a symbol name is used unqualified, a two-phase lookup is used.
First, the module scope is searched, starting from the innermost scope.
For example, in the previous example, while looking for `writeln`,
the order will be:

$(LIST
    * Declarations inside `bar`.
    * Declarations inside `Foo`.
    * Declarations inside `BaseClass`.
    * Declarations at module scope.

)

If the first lookup isn't successful, a second one is performed on imports.
In the second lookup phase inherited scopes are ignored.  This includes the scope of
base classes and interfaces (in this example, `BaseClass`'s imports
would be ignored), as well as imports in mixed-in `template`.

Symbol lookup stops as soon as a matching symbol is found. If two symbols with the
same name are found at the same lookup phase, this ambiguity will result in a
compilation error.

---
module A;
void foo();
void bar();

---

---
module B;
void foo();
void bar();

---

---
module C;
import A;
void foo();
void test()
{
    foo(); // C.foo() is called, it is found before imports are searched
    bar(); // A.bar() is called, since imports are searched
}

---

---
module D;
import A;
import B;
void test()
{
    foo();   // error, A.foo() or B.foo() ?
    A.foo(); // ok, call A.foo()
    B.foo(); // ok, call B.foo()
}

---

---
module E;
import A;
import B;
alias foo = B.foo;
void test()
{
    foo();   // call B.foo()
    A.foo(); // call A.foo()
    B.foo(); // call B.foo()
}

---

$(H3 $(ID public_imports) Public Imports)

By default, imports are $(I private). This means that if module A imports
module B, and module B imports module C, then names inside C are visible only inside
B and not inside A.

An import can be explicitly declared $(I public), which will cause
names from the imported module to be visible to further imports. So in the above
example where module A imports module B, if module B $(I publicly) imports
module C, names from C will be visible in A as well.

All symbols from a publicly imported module are also aliased in the
importing module. Thus in the above example if C contains the name foo, it will
be accessible in A as `foo`, `B.foo` and `C.foo`.

For another example:

---
module W;
void foo() { }

---

---
module X;
void bar() { }

---

---
module Y;
import W;
public import X;
...
foo();  // calls W.foo()
bar();  // calls X.bar()

---

---
module Z;
import Y;
...
foo();   // error, foo() is undefined
bar();   // ok, calls X.bar()
X.bar(); // ditto
Y.bar(); // ok, Y.bar() is an alias to X.bar()

---

$(H3 $(ID static_imports) Static Imports)

A static import requires the use of a fully qualified name
to reference the module's names:

---
static import std.stdio;

void main()
{
    writeln("hello!");           // error, writeln is undefined
    std.stdio.writeln("hello!"); // ok, writeln is fully qualified
}

---

$(H3 $(ID renamed_imports) Renamed Imports)

A local name for an import can be given, through which all references to the
module's symbols must be qualified with:

$(DIV $(CLASS RUNNABLE_EXAMPLE)
---
import io = std.stdio;

void main()
{
    io.writeln("hello!");        // ok, calls std.stdio.writeln
    std.stdio.writeln("hello!"); // error, std is undefined
    writeln("hello!");           // error, writeln is undefined
}

---

)

    $(TIP Renamed imports are handy when dealing with very long import names.)

$(H3 $(ID selective_imports) Selective Imports)

Specific symbols can be exclusively imported from a module and bound into
the current namespace:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
import std.stdio : writeln, foo = write;

void main()
{
    std.stdio.writeln("hello!"); // error, std is undefined
    writeln("hello!");           // ok, writeln bound into current namespace
    write("world");              // error, write is undefined
    foo("world");                // ok, calls std.stdio.write()
    fwritefln(stdout, "abc");    // error, fwritefln undefined
}

---

)

`static` cannot be used with selective imports.

$(H3 $(ID renamed_selective_imports) Renamed and Selective Imports)

When renaming and selective importing are combined:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
import io = std.stdio : foo = writeln;

void main()
{
    writeln("bar");           // error, writeln is undefined
    std.stdio.foo("bar");     // error, foo is bound into current namespace
    std.stdio.writeln("bar"); // error, std is undefined
    foo("bar");               // ok, foo is bound into current namespace,
                              // FQN not required
    io.writeln("bar");        // ok, io=std.stdio bound the name io in
                              // the current namespace to refer to the entire
                              //   module
    io.foo("bar");            // error, foo is bound into current namespace,
                              // foo is not a member of io
}

---

)

$(H3 $(ID scoped_imports) Scoped Imports)

Import declarations may be used at any scope. For example:

$(DIV $(CLASS RUNNABLE_EXAMPLE)
---
void main()
{
    import std.stdio;
    writeln("bar");
}

---

)

The imports are looked up to satisfy any unresolved symbols at that scope.
Imported symbols may hide symbols from outer scopes.

In function scopes, imported symbols only become visible after the import
declaration lexically appears in the function body. In other words, imported
symbols at function scope cannot be forward referenced.

$(DIV $(CLASS RUNNABLE_EXAMPLE)
---
void main()
{
    void writeln(string) {}
    void foo()
    {
        writeln("bar"); // calls main.writeln
        import std.stdio;
        writeln("bar"); // calls std.stdio.writeln
        void writeln(string) {}
        writeln("bar"); // calls main.foo.writeln
    }
    writeln("bar"); // calls main.writeln
    std.stdio.writeln("bar");  // error, std is undefined
}

---

)

$(H2 $(ID module_scope_operators) Module Scope Operator)

    A leading dot (`.`) causes the
    identifier to be looked up in the module scope.

---
int x;

int foo(int x)
{
    if (y)
        return x;  // returns foo.x, not global x
    else
        return .x; // returns global x
}

---


$(H2 $(ID staticorder) Static Construction and Destruction)

    Static constructors are executed to initialize a module's state.
    Static destructors terminate a module's state.
    

    A module may have multiple static constructors and static destructors.
    The static constructors are run in lexical order, the static destructors
    are run in reverse lexical order.

    Non-shared static constructors and destructors are
    run whenever threads are created or destroyed, including the main thread.

    Shared static constructors are run once before `main()` is called.
    Shared static destructors are run after the `main()` function returns.
    

---
import resource;

Resource x;
shared Resource y;
__gshared Resource z;

static this()  // non-shared static constructor
{
    x = acquireResource();
}

shared static this()  // shared static constructor
{
    y = acquireSharedResource();
    z = acquireSharedResource();
}

static ~this()  // non-shared static destructor
{
    releaseResource(x);
}

shared static ~this()   // shared static destructor
{
    releaseSharedResource(y);
    releaseSharedResource(z);
}

---

    $(TIP     $(NUMBERED_LIST
    * Shared static constructors and destructors are used to initialize and terminate
    shared global data.
    * Non-shared static constructors and destructors are used to initialize and terminate
    thread local data.
    
))

$(H3 $(ID order_of_static_ctor) Order of Static Construction)

Shared static constructors on all modules are run before any non-shared static
constructors.

The order of static initialization is implicitly determined by the $(I import) declarations in each module. Each module is assumed to depend on any
imported modules being statically constructed first.
There is no other order imposed on the execution of module static constructors.

Cycles (circular dependencies) in the import declarations are allowed so
long as neither, or one, but not both, of the modules, contains static constructors or static
destructors. Violation of this rule will result in a runtime exception.

    $(WARNING     $(NUMBERED_LIST
    * An implementation may provide a means of overriding the cycle detection abort.
    A typical method uses the D Runtime switch
    `--DRT-oncycle=...` where the following behaviors are supported:
    $(NUMBERED_LIST
    * `abort` The default behavior. The normal behavior as described
            in the previous section.
    * `print` Print all cycles detected, but do not abort execution.
            When cycles are present, the order of static construction is
            implementation defined, and not guaranteed to be valid.
    * `ignore` Do not abort execution or print any cycles. When
            cycles are present, the order of static construction is implementation
            defined, and not guaranteed to be valid.
    
)
    
)
    )

    $(TIP     $(NUMBERED_LIST
    * Avoid cyclical imports where practical. They can be an indication of poor
    decomposition of a program's structure into independent modules. Two modules
    that import each other can often be reorganized into three modules without
    cycles, where the third contains the declarations needed by the other two.
    
)
    )

$(H3 $(ID order_of_static_ctors) Order of Static Construction within a Module)

Within a module, static construction occurs in the lexical order in
which they appear.

$(H3 $(ID order_static_dtor) Order of Static Destruction)

This is defined to be in exactly the reverse order of static construction.
Static destructors for individual modules will only be run if the
corresponding static constructor successfully completed.

Shared static destructors are executed after static destructors.

$(H2 $(ID order_of_unittests) Order of Unit tests)

Unit tests are run in the lexical order in which they appear within a
module.

$(H2 $(ID mixin-declaration)Mixin Declaration)

$(PRE $(CLASS GRAMMAR)
$(B $(ID MixinDeclaration) MixinDeclaration):
    `mixin` `(` [expression#ArgumentList|expression, ArgumentList] `)` `;`

)

Each [expression#AssignExpression|expression, AssignExpression] in the $(I ArgumentList) is
    evaluated at compile time, and the result must be representable
    as a string.
    The resulting strings are concatenated to form a string.
    The text contents of the string must be compilable as valid
    [#DeclDefs|DeclDefs], and is compiled as such.

The content of a mixin cannot be forward referenced by other <em>DeclDefs</em> of
    the same scope because it is not yet pulled into the AST.

---
class B : A {}      // Error: undefined identifier `A`
mixin ("class A {}");

---

Forward references may only work in function bodies because they
    are processed after the declarations:

---
void v()
{
    class B : A {}
}
mixin ("class A {}");

---

$(H2 $(ID package-module)Package Module)

A package module can be used to publicly import other modules, while
providing a simpler import syntax. This enables the conversion of a module into a package
of modules, without breaking existing code which uses that module. Example of a
set of library modules:

$(B libweb/client.d:)

---
module libweb.client;

void runClient() { }

---

$(B libweb/server.d:)

---
module libweb.server;

void runServer() { }

---

$(B libweb/package.d:)

---
module libweb;

public import libweb.client;
public import libweb.server;

---

The package module's file name must be `package.d`. The module name
is declared to be the fully qualified name of the package. Package modules can
be imported just like any other modules:

$(B test.d:)

---
module test;

// import the package module
import libweb;

void main()
{
    runClient();
    runServer();
}

---

A package module can be nested inside of a sub-package:

$(B libweb/utils/package.d:)

---
// must be declared as the fully qualified name of the package, not just 'utils'
module libweb.utils;

// publicly import modules from within the 'libweb.utils' package.
public import libweb.utils.conv;
public import libweb.utils.text;

---

The package module can then be imported with the standard module import
declaration:

$(B test.d:)

---
module test;

// import the package module
import libweb.utils;

void main() { }

---

grammar, Grammar, declaration, Declarations




Link_References:
	ACC = Associated C Compiler
+/
module module.dd;