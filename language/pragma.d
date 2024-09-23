// just docs: Pragmas
/++





$(PRE $(CLASS GRAMMAR)
$(B $(ID PragmaDeclaration) PragmaDeclaration):
    [#Pragma|Pragma] `;`
    [#Pragma|Pragma] [attribute#DeclarationBlock|attribute, DeclarationBlock]

$(B $(ID PragmaStatement) PragmaStatement):
    [#Pragma|Pragma] `;`
    [#Pragma|Pragma] [statement#NoScopeStatement|statement, NoScopeStatement]

$(B $(ID Pragma) Pragma):
    `pragma` `(` $(LINK2 lex#Identifier, Identifier) `)`
    `pragma` `(` $(LINK2 lex#Identifier, Identifier) `,` [expression#ArgumentList|expression, ArgumentList] `)`

)


        Pragmas pass special information to the implementation
        and can add vendor specific extensions.
        Pragmas can be used by themselves terminated with a $(TT ;),
        and can apply to a statement, a block of statements, a declaration, or
        a block of declarations.
        

        Pragmas can be either a [#PragmaDeclaration|PragmaDeclaration]
        or a [#PragmaStatement|PragmaStatement].
        

---
pragma(ident);        // just by itself

pragma(ident) declaration; // influence one declaration

pragma(ident): // influence subsequent declarations
    declaration;
    declaration;

pragma(ident)   // influence block of declarations
{
    declaration;
    declaration;
}

pragma(ident) statement; // influence one statement

pragma(ident)   // influence block of statements
{
    statement;
    statement;
}

---

        The kind of pragma it is determined by the $(I Identifier).
        [expression#ArgumentList|expression, ArgumentList] is a comma-separated list of
        AssignExpressions. The AssignExpressions must be
        parsable as expressions, but their meaning
        is up to the individual pragma semantics.
        

$(H2 $(ID predefined-pragmas)Predefined Pragmas)

All implementations must support these, even if by just ignoring them:

$(LIST
    * $(LINK2 #crtctor, pragma crt_constructor)
    * $(LINK2 #crtdtor, pragma crt_destructor)
    * $(LINK2 #inline, pragma inline)
    * $(LINK2 #lib, pragma lib)
    * $(LINK2 #linkerDirective, pragma linkerDirective)
    * $(LINK2 #mangle, pragma mangle)
    * $(LINK2 #msg, pragma msg)
    * $(LINK2 #printf, pragma printf)
    * $(LINK2 #scanf, pragma scanf)
    * $(LINK2 #startaddress, pragma startaddress)

)

    $(WARNING An implementation may ignore these pragmas.)

$(H3 $(ID crtctor) `pragma crt_constructor`)

    Annotates a function so it is run after the C runtime library is initialized
        and before the D runtime library is initialized.
    

    The function must:

    $(NUMBERED_LIST
        * be `extern (C)`
        * not have any parameters
        * not be a non-static member function
        * be a function definition, not a declaration (i.e. it must have a function body)
        * not return a type that has a destructor
        * not be a nested function
    
)

---
__gshared int initCount;

pragma(crt_constructor)
extern(C) void initializer() { initCount += 1; }

---

    No arguments to the pragma are allowed.

    A function may be annotated with both `pragma(crt_constructor)`
        and `pragma(crt_destructor)`.
    

    Annotating declarations other than function definitions has no effect.

    Annotating a struct or class definition does not affect the members of
    the aggregate.

    A function that is annotated with `pragma(crt_constructor)` may initialize
    `const` or `immutable` variables.

    $(TIP Use for system programming and interfacing with C/C++,
        for example to allow for initialization of the runtime when loading a DSO,
        or as a simple replacement for `shared static this` in
        $(LINK2 spec/betterc, betterC mode).
    )

    $(WARNING The order in which functions annotated with `pragma(crt_constructor)`
        are run is implementation defined.
    )

    $(TIP to control the order in which the functions are called within one module, write
        a single function that calls them in the desired order, and only annotate that function.
    )

    $(WARNING This uses the mechanism C compilers use to run
        code before `main()` is called. C++ compilers use it to run static
        constructors and destructors.
        For example, GCC's $(LINK2 https://gcc.gnu.org/onlinedocs/gcc-4.7.0/gcc/Function-Attributes.html, `__attribute__((constructor))`)
        is equivalent.
        Digital Mars C uses $(TT _STI) and $(TT _STD) identifier prefixes to mark crt_constructor and crt_destructor functions.
    )

    $(WARNING         A reference to the annotated function will be inserted in
        the $(TT .init_array) section for Elf systems,
        the $(TT XI) section for Win32 OMF systems,
        the $(TT .CRT$XCU) section for Windows MSCOFF systems,
        and the $(TT __mod_init_func) section for OSX systems.
    )

    Note: `crt_constructor` and `crt_destructor` were implemented in
        $(LINK2 changelog/2.078.0.html, v2.078.0 (2018-01-01)).
        Some compilers exposed non-standard, compiler-specific mechanism before.
    

$(H3 $(ID crtdtor) `pragma crt_destructor`)

    `pragma(crt_destructor)` works the same as `pragma(crt_constructor)` except:

    $(NUMBERED_LIST
        * Annotates a function so it is run after the D runtime library is terminated
             and before the C runtime library is terminated.
             Calling C's `exit()` function also causes the annotated functions to run.
        * The order in which the annotated functions are run is the reverse of those functions
             annotated with `pragma(crt_constructor)`.
    
)

    $(WARNING This uses the mechanism C compilers use to run
        code after `main()` returns or `exit()` is called. C++ compilers use it to run static
        destructors.
        For example, GCC's $(LINK2 https://gcc.gnu.org/onlinedocs/gcc-4.7.0/gcc/Function-Attributes.html, `__attribute__((destructor))`)
        is equivalent.
        Digital Mars C uses $(TT _STI) and $(TT _STD) identifier prefixes to mark crt_constructor and crt_destructor functions.
    )

    $(WARNING         A reference to the annotated function will be inserted in
        the $(TT .fini_array) section for Elf systems,
        the $(TT XC) section for Win32 OMF systems,
        the $(TT .CRT$XPU) section for Windows MSCOFF systems,
        and the $(TT __mod_term_func) section for OSX systems.
    )

---
__gshared int initCount;

pragma(crt_constructor)
extern(C) void initialize() { initCount += 1; }

pragma(crt_destructor)
extern(C) void deinitialize() { initCount -= 1; }

pragma(crt_constructor)
pragma(crt_destructor)
extern(C) void innuendo() { printf("Inside a constructor... Or destructor?\n"); }

---


$(H3 $(ID inline) `pragma inline`)

    Affects whether functions are inlined or not. If at the declaration level, it
     affects the functions declared in the block it controls. If inside a function, it
     affects the function it is enclosed by.

     It takes two forms:
     $(NUMBERED_LIST
        * ---
pragma(inline)

---
        Sets the behavior to match the implementation's default behavior.
        
        * ---
pragma(inline, AssignExpression)

---
        The [expression#AssignExpression|expression, AssignExpression] is evaluated and must have a type that can be converted
        to a boolean.
        If the result is false the functions are never inlined, otherwise they are always inlined.
        
      
)

    More than one $(I AssignExpression) is not allowed.

    If there are multiple pragma inlines in a function,
    the lexically last one takes effect.
---
pragma(inline):
int foo(int x) // foo() is never inlined
{
    pragma(inline, true);
    ++x;
    pragma(inline, false); // supercedes the others
    return x + 3;
}

---

    $(WARNING     $(NUMBERED_LIST
    * The default inline behavior is typically selectable with a compiler switch
    such as $(LINK2 dmd#switch-inline,$(TT -inline).)
    * Whether a particular function can be inlined or not is implementation defined.
    * What happens for `pragma(inline, true)` if the function cannot be inlined.
    An error message is typical.
    
))

$(H3 $(ID lib) `pragma lib`)

    There must be one AssignExpression and it must evaluate at compile time to a string literal.
    
---
pragma(lib, "foo.lib");

---

    $(WARNING     The string literal specifies the file name of a library file. This name
    is inserted into the generated object file, or otherwise passed to the linker,
    so the linker automatically links in that library.
    )

$(H3 $(ID linkerDirective) `pragma linkerDirective`)

    There must be one AssignExpression and it must evaluate at compile time to a string literal.
    
---
pragma(linkerDirective, "/FAILIFMISMATCH:_ITERATOR_DEBUG_LEVEL=2");

---

    $(WARNING     The string literal specifies a linker directive to be embedded in the generated object file.
    Linker directives are only supported for MS-COFF output.
    )

$(H3 $(ID mangle) `pragma mangle`)

    Overrides the default mangling for a symbol.

    For variables and functions there must be one AssignExpression and it must evaluate at compile time to a string literal.
        For aggregates there may be one or two AssignExpressions, one of which must evaluate at compile time to a string literal and
        one which must evaluate to a symbol. If that symbol is a $(I TemplateInstance), the aggregate is treated as a template
        that has the signature and arguments of the $(I TemplateInstance). The identifier of the symbol is used when no string is supplied.
        Both arguments may be used used when an aggregate's name is a D keyword.
    

    It only applies to function and variable symbols. Other symbols are ignored.

    $(WARNING On macOS and Win32, an extra underscore (`_`) is prepended to the string
        since 2.079, as is done by the C/C++ toolchain. This allows using the same `pragma(mangle)`
        for all compatible (POSIX in one case, win64 in another) platforms instead of having to special-case.
    )

    Rationale:         $(LIST
        * Enables linking to symbol names that D cannot represent.
        * Enables linking to a symbol which is a D keyword, since an $(LINK2 lex#Identifier, Identifier)
        cannot be a keyword.
        
)
---
pragma(mangle, "body")
extern(C) void body_func();
pragma(mangle, "function")
extern(C++) struct _function {}
template ScopeClass(C)
{
    pragma(mangle, C.stringof, C)
    struct ScopeClass { align(__traits(classInstanceAlignment, C)) void[__traits(classInstanceSize, C)] buffer; }
}
extern(C++)
{
    class MyClassA(T) {}
    void func(ref ScopeClass!(MyClassA!int)); // mangles as MyClass&lt;int&gt;&amp;
}

---
    


$(H3 $(ID msg) `pragma msg`)

    Each AssignExpression is evaluated at compile time and then all are combined into a message.

---
pragma(msg, "compiling...", 6, 1.0); // prints "compiling...61.0" at compile time

---

    $(WARNING The form the message takes and how it is presented to the user.
    One way is by printing them to the standard error stream.)

    Rationale: Analogously to how `writeln()` performs a role of writing informational messages during runtime,
        `pragma(msg)` performs the equivalent role at compile time.
        For example,
---
static if (kilroy)
    pragma(msg, "Kilroy was here");
else
    pragma(msg, "Kilroy got lost");

---
    

$(H3 $(ID printf) `pragma printf`)

    `pragma(printf)` specifies that a function declaration is a printf-like function, meaning
    it is an `extern (C)` or `extern (C++)` function with a `format` parameter accepting a
    pointer to a 0-terminated `char` string conforming to the C99 Standard 7.19.6.1, immediately followed
    by either a `...` variadic argument list or a parameter of type `va_list` as the last parameter.
    

    If the `format` argument is a string literal, it is verified to be a valid format string
    per the C99 Standard. If the `format` parameter is followed by `...`, the number and types
    of the variadic arguments are checked against the format string.

    Diagnosed incompatibilities are:

    $(LIST
    * incompatible sizes which may cause argument misalignment
    * deferencing arguments that are not pointers
    * insufficient number of arguments
    * struct arguments
    * array and slice arguments
    * non-pointer arguments to `s` specifier
    * non-standard formats
    * undefined behavior per C99
    
)

    Per the C99 Standard, extra arguments are ignored.

    Ignored mismatches are:

    $(LIST
    * sign mismatches, such as printing an `int` with a `%u` format
    * integral promotion mismatches, where the format specifies a smaller integral
    type than `int` or `uint`, such as printing a `short` with the `%d` format rather than `%hd`
    
)

---
printf("%k\n", value); // error: non-Standard format k
printf("%d\n");        // error: not enough arguments
printf("%d\n", 1, 2);  // ok, extra arguments ignored

---

    $(TIP     In order to use non-Standard printf/scanf formats, an easy workaround is:
---
const format = "%k\n";
printf(format.ptr, value);  // no error

---
    )

    $(TIP     Most of the errors detected are portability issues. For instance,

---
string s;
printf("%.*s\n", s.length, s.ptr);
printf("%d\n", s.sizeof);
ulong u;
scanf("%lld%*c\n", &amp;u);

---
    should be replaced with:
---
string s;
printf("%.*s\n", cast(int) s.length, s.ptr);
printf("%zd\n", s.sizeof);
ulong u;
scanf("%llu%*c\n", &amp;u);

---
    )

    `pragma(printf)` applied to declarations that are not functions are ignored.
    In particular, it has no effect on the declaration of a pointer to function type.
    


$(H3 $(ID scanf) `pragma scanf`)

    `pragma(scanf)` specifies that a function declaration is a scanf-like function, meaning
    it is an `extern (C)` or `extern (C++)` function with a `format` parameter accepting a
    pointer to a 0-terminated `char` string conforming to the C99 Standard 7.19.6.2, immediately followed
    by either a `...` variadic argument list or a parameter of type `va_list` as the last parameter.
    

    If the `format` argument is a string literal, it is verified to be a valid format string
    per the C99 Standard. If the `format` parameter is followed by `...`, the number and types
    of the variadic arguments are checked against the format string.

    Diagnosed incompatibilities are:

    $(LIST
    * argument is not a pointer to the format specified type
    * insufficient number of arguments
    * non-standard formats
    * undefined behavior per C99
    
)

    Per the C99 Standard, extra arguments are ignored.

    `pragma(scanf)` applied to declarations that are not functions are ignored.
    In particular, it has no effect on the declaration of a pointer to function type.
    




$(H3 $(ID startaddress) `pragma startaddress`)

    There must be one AssignExpression and it must evaluate at compile time to a function symbol.

    $(WARNING The function symbol specifies the start address for the program.
    The symbol is inserted into the object file or is otherwise presented to the linker to
    set the start address.
    This is not normally used for application level programming,
    but is for specialized systems work.
    For applications code, the start address is taken care of
    by the runtime library.

---
void foo() { ... }
pragma(startaddress, foo);

---

    )

$(H2 $(ID vendor_specific_pragmas) Vendor Specific Pragmas)

        Vendor specific pragma $(I Identifier)s can be defined if they
        are prefixed by the vendor's trademarked name, in a similar manner
        to version identifiers:
        

---
pragma(DigitalMars_extension) { ... }

---

    Implementations must diagnose an error for unrecognized $(I Pragma)s,
    even if they are vendor specific ones.
    

    $(WARNING Vendor specific pragmas.)


    $(TIP vendor
        specific pragmas should be wrapped in version statements

---
version (DigitalMars)
{
    pragma(DigitalMars_extension)
    {   ... }
}

---
    )

attribute, Attributes, expression, Expressions




Link_References:
	ACC = Associated C Compiler
+/
module pragma.dd;