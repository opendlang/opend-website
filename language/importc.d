// just docs: ImportC
/++





    ImportC is a C compiler embedded into the D implementation.
    It enables direct importation of C files, without
    needing to manually prepare a D file corresponding to the declarations
    in the C file. It directly compiles C files into modules that can be
    linked in with D code to form an executable. It can be used
    as a C compiler to compile and link 100% C programs.
    

    Note: ImportC and $(LINK2 https://dlang.org/spec/betterc.html, BetterC) are very different.
    ImportC is an actual C compiler. BetterC is a subset of D that relies only on the
    existence of the C Standard library. BetterC code can be linked with ImportC code, too.

$(H2 $(ID examples) Quick Examples)

    C code in file $(TT hello.c):

    ```c
    #include &lt;stdio.h&gt;
    int main()
    {
        printf("hello world\n");
        return 0;
    }
```

    Compile and run:

    $(CONSOLE     dmd hello.c
    ./hello
    hello world)

    C function in file $(TT functions.c):

    ```c
    int square(int i)
    {
        return i * i;
    }
    
```

    D program in file $(TT demo.d):

---
import std.stdio;
import functions;
void main()
{
    int i = 7;
    writefln("The square of %s is %s", i, square(i));
}

---

    Compile and run:

    $(CONSOLE     dmd demo.d functions.c
    ./demo
    The square of 7 is 49
    )


$(H2 $(ID dialect) ImportC Dialect)

    There are many versions of C. ImportC is an
    implementation of $(LINK2 https://en.wikipedia.org/wiki/C11_(C_standard_revision), ISO/IEC 9899:2011),
    which will be referred to as $(B C11).
    References to the C11 Standard will be C11 followed by the paragraph number.
    Prior versions, such as C99, C89, and K+R C, are not supported.
    

    $(WARNING Adjustment to the ImportC dialect is made to match the
    behavior of the C compiler that the D compiler is matched to,
    i.e. the [acc].
    )

    Further adjustment is made to take advantage of some of the D
    implementation's capabilities.

    Note: This is not a C reference manual nor programming tutorial.
    It describes the specifics of the dialect of C that
    ImportC is, and how to use it effectively.


$(H2 $(ID command-line) Invoking ImportC)

    The ImportC compiler can be invoked:

    $(LIST
    * directly via the command line
    * indirectly via importing a C file
    
)

    $(H3 $(ID command-line) ImportC Files on the Command Line)

    ImportC files have one of the extensions `.i`, or `.c`. If no
    extension is given, `.i` is tried first, then `.c`.
    

    $(CONSOLE     dmd hello.c
    )

    will compile `hello.c` with ImportC and link it to create the executable
    file `hello` (`hello.exe` on Windows)
    

    $(TIP explicitly use a `.i` or `.c` extension when
    specifying C files on the command line.)

    $(H3 $(ID importing) Importing C Files from D Code)

    Use the D [module#ImportDeclaration|module, ImportDeclaration]:

---
import hello;

---

    which will, if `hello` is not a D file, and has an extension `.i` or `.c`,
    compile `hello` with ImportC.
    

$(H2 $(ID preprocessor) Preprocessor)

    ImportC does not have a preprocessor. It is designed to compile C
    files after they have been first run through the C preprocessor.
    ImportC can automatically run the C preprocessor associated with the
    [acc], or a preprocessor can be run manually.
    

    $(H3 $(ID auto-cpp) Running the Preprocessor Automatically)

    If the C file has a $(TT .c) extension, ImportC will run the preprocessor
    for it automatically.

    $(NUMBERED_LIST
    * When compiling for Windows with the $(LINK2 dmd#switch-m32omf,$(TT -m32omf)) switch,
    $(TT sppn.exe) will be used as the preprocessor.
    * When compiling for Windows with the $(LINK2 dmd#switch-m32mscoff,$(TT -m32mscoff))
    or the $(LINK2 dmd#switch-m64,$(TT -m64)) switch, $(TT cl.exe /P /Zc:preprocessor) will be used
    as the preprocessor.
    * When compiling for OSX, the $(TT clang -E) preprocessor will be used.
    * Otherwise the $(TT cpp) preprocessor will be used.
    
)

    The $(LINK2 dmd#switch-v,$(TT -v)) switch can be used to observe the command
    that invokes the preprocessor.
    

    The $(LINK2 dmd#switch-P,$(TT -P$(I preprocessorflag))) switch passes $(TT $(I preprocessorflag))
    to the preprocessor.
    

    $(H4 $(ID importc-h) $(TT importc.h))

    The druntime file $(LINK2 https://github.com/dlang/dmd/blob/master/druntime/src/importc.h, $(TT src/importc.h))
    will automatically be $(TT #include)d first. $(TT importc.h) provides adjustments to the source code to
    account for various C compiler extensions not supported by ImportC.

    $(H4 $(ID no-builtin-macro-redefined) no-builtin-macro-redefined)

    On Posix systems, ImportC will pass the switch $(TT -Wno-builtin-macro-redefined) to the C preprocessor
    used by $(TT gcc) and $(TT clang).
    This $(LINK2 https://gcc.gnu.org/legacy-ml/gcc-patches/2008-07/msg02321.html, switch)
    does not exist in $(TT gcc) preprocessors made before 2008.
    The workaround is to run the preprocessor manually.

    $(H3 $(ID manual-cpp) Running the Preprocessor Manually)

    If the C file has a $(TT .i) extension, the file
    is presumed to be already preprocessed.
    Preprocessing can be run manually:
    

    $(H4 $(ID spp) Digital Mars C Preprocessor sppn.exe)

    $(LINK2 https://www.digitalmars.com/ctg/sc.html, $(TT sppn.exe)) runs on Win32 and is invoked as:

    $(CONSOLE     sppn file.c
    )

    and the preprocessed output is written to $(TT file.i).

    $(H4 $(ID gcc-preprocessor) Gnu C Preprocessor)

    The $(LINK2 https://gcc.gnu.org/onlinedocs/gcc/Preprocessor-Options.html, Gnu C Preprocessor) can be invoked as:

    $(CONSOLE     gcc -E file.c &gt; file.i
    )

    $(H4 $(ID clang-preprocessor) Clang C Preprocessor)

    The Clang Preprocessor can be invoked as:

    $(CONSOLE     clang -E file.c -o file.i
    )

    $(H4 $(ID vc-preprocessor) Microsoft VC Preprocessor)

    The $(LINK2 https://docs.microsoft.com/en-us/cpp/preprocessor/c-cpp-preprocessor-reference?view=msvc-170,
    VC Preprocessor) can be invoked as:

    $(CONSOLE     cl /P /Zc:preprocessor file.c -Fifile.i
    )

    and the preprocessed output is written to $(TT file.i).

    $(H4 $(ID dmpp) dmpp C Preprocessor)

    The $(LINK2 https://github.com/DigitalMars/dmpp, dmpp C Preprocessor) can be invoked as:

    $(CONSOLE     dmpp file.c
    )

    and the preprocessed output is written to $(TT file.i).

    $(H3 $(ID defines) Preprocessor Macros)

    ImportC collects all the $(TT #define) macros from the preprocessor run when it is run automatically.
    Some can be made available to D code by interpreting them as declarations.
    The variety of macros that can be interpreted as D declarations may be expanded,
    but will never encompass all the metaprogramming uses of C macros.
    

    $(H4 Manifest Constants)

    Macros that look like manifest constants, such as:

```c
#define COLOR 0x123456
#define HELLO "hello"
```

    are interpreted as D manifest constant declarations of the form:

---
enum COLOR = 0x123456;
enum HELLO = "hello";

---

    $(H4 Function-Like Macros)

    Many macros look like functions, and can be treated as template functions:

```c
#define ABC a + b
#define DEF(a) (a + x)
```

---
auto ABC() { return a + b; }
auto DEF(T)(T a) { return a + x; }

---

    Some macro formulations, however, will not produce the same result:

```c
#define ADD(a, b) a + b
int x = ADD(1, 2) * 4; // sets x to 9
```

---
auto ADD(U, V)(U a, V b) { return a + b; }
int x = ADD(1, 2) * 4; // sets x to 12

---

    $(TIP Always use parentheses around arguments and entire expressions:)

```c
#define ADD(a, b) ((a) + (b))
```

    Another area of trouble is side effects in the arguments:

```c
#define DOUBLE(x) ((x) + (x))
```

---
int i = 0;
DOUBLE(i++);
assert(i == 2);  // D result will be 1, C result will be 2

---

    and treating arguments as references:

```c
#define INC(x) (++x)
```

---
int i = 0;
INC(i);
assert(i == 1); // D result will be 0, C result will be 1

---

$(H2 $(ID predefined-macros) Predefined Macros)

    ImportC does not predefine any macros.

    To distinguish an ImportC compile vs some other C compiler, use:

```c
#if __IMPORTC__

```

    $(TT __IMPORTC__) is defined in
    $(LINK2 https://github.com/dlang/dmd/blob/master/druntime/src/importc.h, $(TT src/importc.h))
    which is automatically
    included when the preprocessor is run. $(TT importc.h) contains many macro
    definitions that are used to adapt various C source code vagaries to ImportC.

$(H2 $(ID preprocessor-directives) Preprocessor Directives)

    ImportC supports these preprocessor directives:

    $(H3 $(ID line-control) Line control)

    C11 6.10.4

    $(H3 $(ID linemarker) Linemarker)

    $(LINK2 https://gcc.gnu.org/onlinedocs/gcc-11.1.0/cpp/Preprocessor-Output.html, linemarker)
    directives are normally embedded in the output of C preprocessors.

    $(H3 $(ID pragma) pragma)

    The following pragmas are supported:

    $(LIST
    * $(TT #pragma pack ( ))
    * $(TT #pragma pack ( show ))
    * $(TT #pragma pack ( push ))
    * $(TT #pragma pack ( push , identifier ))
    * $(TT #pragma pack ( push , integer ))
    * $(TT #pragma pack ( push , identifier , integer ))
    * $(TT #pragma pack ( pop ))
    * $(TT #pragma pack ( pop PopList ))
    
)

$(H2 $(ID _builtins) $(TT src/__builtins.di))

    The first thing the compiler does when preprocessing is complete is to import
    $(LINK2 https://github.com/dlang/dmd/blob/master/druntime/src/__builtins.di, $(TT src/__builtins.di)).
    It provides support for various builtins provided by other C compilers.
    $(TT __builtins.di) is a D file.

$(H2 $(ID implementation) Implementation)

    The implementation defined characteristics of ImportC are:

    $(H3 $(ID enums) Enums)

    $(I enumeration-constants) are always typed as `int`.

    The expression that defines the value of an $(I enumeration-constant) must
    be an integral type and evaluate to an integer value that fits in an `int`.

---
enum E { -10, 0x81231234 }; // ok
enum F {  0x812312345678 }; // error, doesn't fit in int
enum G { 1.0 };             // error, not integral type

---

    The enumerated type is `int`.


    $(H3 $(ID bitfields) Bit Fields)

    There are many implementation defined aspects of C11 bit fields.
    ImportC's behavior adjusts to match the behavior of the $(I associated
    C compiler) on the target platform.
    

    $(H3 $(ID implicit-function-declaration) Implicit Function Declarations)

    Implicit function declarations:

    ```c
    int main()
    {
        func();  // implicit declaration of func()
    }
    
```

    were allowed in K+R C and C89, but were invalidated in C99 and C11. Although many
    C compilers still support them, ImportC does not.
    

    Rationale: Implicit function declarations are very error-prone and cause hard
    to find bugs.

    $(H3 $(ID pragma-STDC-FENV_ACCESS) #pragma STDC FENV_ACCESS)

    This is described in C11 7.6.1

$(PRE $(CLASS GRAMMAR_INFORMATIVE)#pragma STDC FENV_ACCESS on-off-switch

on-off-switch:
    ON
    OFF
    DEFAULT
)

    It is completely ignored.


$(H2 $(ID limitations) Limitations)

    $(H3 $(ID exceptions) Exception Handling)

    ImportC is assumed to never throw exceptions. `setjmp` and `longjmp` are not supported.

    $(H3 $(ID const) Const)

    C11 specifies that `const` only applies locally. `const` in ImportC applies transitively,
    meaning that although ```c
int *const p;
``` means in C11 that p is a const pointer to int,
    in ImportC it means p is a const pointer to a const int.

    $(H3 $(ID volatile) Volatile)

    The `volatile` type-qualifier (C11 6.7.3) is ignored. Use of `volatile` to implement shared
    memory access is unlikely to work anyway, $(LINK2 #_atomic, _Atomic) is for that.
    To use `volatile` as a device register, call a function to do it that is compiled separately,
    or use inline assembler.
    

    $(H3 $(ID restrict) Restrict)

    The `restrict` type-qualifier (C11 6.7.3) is ignored.

    $(H3 $(ID _atomic) _Atomic)

    The `_Atomic` type-qualifier (C11 6.7.3) is ignored.
    To do atomic operations, use an externally compiled function for that, or the inline assembler.

    $(H3 $(ID compatible_types) Compatible Types)

    $(I Compatible Types) (C11 6.7.2) are identical types in ImportC.


$(H2 $(ID impedance-mismatch) Impedance Mismatch)

    While every effort is made to match up C and D so it "just works", the languages have some
    fundamental differences that appear now and then.
    

    $(H3 $(ID keyword-mismatch) Keyword Mismatch)

    D and C use mostly the same keywords, C has keywords that D doesn't have, and vice versa. This
    does not affect compilation of C code, but it can cause difficulty when accessing C variables and types
    from D. For example, the D `version` keyword is not uncommonly used as a struct member in C:

    C code in file $(TT defs.c):
```c
struct S { int version; };
```

    Accessing it from D:
---
import defs;
int tech(S* s) {
    return s.version; // fails because version is a D keyword
}

---

    A workaround is available:
---
import defs;
int tech(S* s) {
    return __traits(getMember, *s, "version");
}

---



    $(H3 $(ID same_only_different) Same only Different Types)

    On some platforms, C `long` and `unsigned long` are the same size as `int` and `unsigned int`, respectively.
    On other platforms, C `long` and `unsigned long` are the same size as `long long` and `unsigned long long`.
    `long double` and `long  double _Complex` can be same size as `double` and `double _Complex`.
    In ImportC, these types that are the same size and signed-ness are treated as the same types.
    

    $(H3 $(ID _generic) _Generic)

    $(B Generic selection) expressions (C11 6.5.1.1) differ from ImportC.
    The types in $(LINK2 #same_only_different, Same only Different Types) are
    indistinguishable in the $(I type-name) parts of $(I generic-association).
    Instead of giving an error for duplicate types per C11 6.5.1.1-2, ImportC
    will select the first compatible $(I type-name) in the $(I generic-assoc-list).
    


$(H2 $(ID extensions) Extensions)

    $(H3 $(ID asmstatements) Asm statement)

    For the D language, `asm` is a standard keyword, and its construct is
    shared with ImportC. For the C language, `asm` is an extension (J.5.10),
    and the recommendation is to instead use `__asm__`. All alternative
    keywords for `asm` are translated by the druntime file $(TT src/importc.h)
    during the preprocessing stage.

    The `asm` keyword may be used to embed assembler instructions, its
    syntax is implementation defined. The Digital Mars D compiler only supports
    the dialect of inline assembly as described in the documentation of the
    $(LINK2 https://dlang.org/spec/iasm.html, D x86 Inline Assembler).

    `asm` in a function or variable declaration may be used to specify the
    mangle name for a symbol. Its use is analogous to
    $(LINK2 https://dlang.org/spec/pragma.html#mangle, pragma mangle).

```c
char **myenviron asm("environ") = 0;

int myprintf(char *, ...) asm("printf");

```

    Using `asm` to associate registers with variables is ignored.

    $(H3 $(ID forward-references) Forward References)

    Any declarations in scope can be accessed, not just
    declarations that lexically precede a reference.

```c
Ta *p;  // Ta is forward referenced
struct Sa { int x; };
typedef struct Sa Ta; // Ta is defined

```

```c
struct S s;
int* p = &s.t.x;  // struct S definition is forward referenced
struct S { int a; struct T t; }; // T still forward referenced
struct T { int b; int x; }; // definition of struct T

```

    $(H3 $(ID cpp-tag-symbols) C++ Style Tag Symbols)

    In C++, `struct`, `union` or `enum` tag symbols can be accessed without needing
    to be prefixed with the `struct`, `union` or `enum` keywords, as long
    as there is no other declaration with the same name at the same scope.
    ImportC behaves the same way.

    For example, the following code is accepted by both C++ and ImportC:

```c
struct s { int a; };

void g(int s)
{
    struct s* p = (struct s*)malloc(sizeof(struct s));
    p-&gt;a = s;
}

```

    Whereas this is rejected by both C++ and ImportC, for the same reason.

```c
struct s { int a; };

void g(int s)
{
    s* p = (s*)malloc(sizeof(s));
    p-&gt;a = s;
}

```

    $(H3 $(ID ctfe) Compile Time Function Execution)

    Evaluating constant expressions includes executing functions in the
    same manner as D's CTFE can.
    A $(I constant-expression) invokes CTFE.

    Examples:

```c
_Static_assert("\x1"[0] == 1, "failed");

int mint1() { return -1; }
_Static_assert(mint1() == -1, "failed");

const int a = 7;
int b = a; // sets b to 7

```

    $(H3 $(ID inlining) Function Inlining)

    Functions for which the function body is present can
    be inlined by ImportC as well as by the D code that calls them.

    $(H3 $(ID enumbasetype) Enum Base Types)

    Enums are extended with an optional $(I EnumBaseType):

$(PRE $(CLASS GRAMMAR)
$(B $(ID EnumDeclaration) EnumDeclaration):
    `enum` [#Identifier|Identifier] `:` [#EnumBaseType|EnumBaseType] [#EnumBody|EnumBody]

$(B $(ID EnumBaseType) EnumBaseType):
    [#Type|Type]

)

    which, when supplied, causes the enum members to be implicitly cast to the
    $(I EnumBaseType).
    

```c
enum S : byte { A };
_Static_assert(sizeof(A) == 1, "A should be size 1");

```


    $(H3 $(ID register) Register Storage Class)

    Objects with `register` storage class are treated as `auto` declarations.

    Objects with `register` storage class may have their address taken. C11 6.3.2.1-2

    Arrays can have `register` storage class, and may be enregistered by the compiler. C11 6.3.2.1-3


    $(H3 $(ID typeof) typeof Operator)

    The `typeof` operator may be used as a type specifier:
$(PRE $(CLASS GRAMMAR)
$(B $(ID type-specifier) type-specifier):
    $(B $(ID typeof-specifier) typeof-specifier)

$(B $(ID typeof-specifier) typeof-specifier):
    `typeof (` $(B $(ID expression) expression) `)`
    `typeof (` $(B $(ID type-name) type-name) `)`

)

    $(H3 $(ID __import) Import Declarations)

    Modules can be imported with a $(I CImportDeclaration):

$(PRE $(CLASS GRAMMAR)
$(B $(ID CImportDeclaration) CImportDeclaration):
    `__import` [module#ImportList|module, ImportList] `;`

)

    Imports enable ImportC code to directly access D declarations and functions
    without the necessity of creating a $(TT .h) file representing those declarations.
    The tedium and brittleness of keeping the $(TT .h) file up-to-date with the D
    declarations is eliminated.
    D functions are available to be inlined.
    

    Imports also enable ImportC code to directly import other C files without
    needing to create a .h file for them, either.
    Imported C functions become available to be inlined.
    

    The $(I ImportList) works the same as it does for D.

    The ordering of $(I CImportDeclaration)s has no significance.

    An ImportC file can be imported, the name of the C file to be
    imported is derived from the module name.

    All the global symbols in the ImportC file become available to the
    importing module.

    If a name is referred to in the importing file is not found,
    the global symbols in each imported file are searched for the name.
    If it is found in exactly one module, that becomes the resolution of the
    name. If it is found in multiple modules, it is an error.

    Note: Since ImportC has no scope resolution operator, only global symbols
    can be found, and a qualification cannot be added to specifiy which module
    a symbols is in.

    Preprocessor symbols in the imported module are not available to the
    importing module, and preprocessing symbols in the importing file are not
    available to the imported module.

    A D module can be imported, in the same manner as that
    of a [module#ImportDeclaration|module, ImportDeclaration].

    Imports can be circular.

```c
__import core.stdc.stdarg; // get D declaration of va_list
__import mycode;           // import mycode.c

int foo()
{
    va_list x;    // picks up va_list from core.stdc.stdarg
    return 1 + A; // returns 4
}
```

    $(TT mycode.c) looks like:

```c
enum E { A = 3; }

```

    $(TIP Avoid using preprocessor $(TT #define)s like $(TT #define A 3).
    Use the enum form shown in the above example.
    Prefer $(TT const) declarations over $(TT #define)s.
    Rewrite function-style preprocessor macros as inline functions.
    )

    $(H3 $(ID controlZ) Control Z is End Of File)

    A control-Z character `\x1A` in the source text means End Of File.

    $(H3 $(ID largeDecimal) Signed Integer Literal Larger Than long long)

    A signed integer constant with no suffix that is larger than a `long long` type,
    but will fit into an `unsigned long long` type, is accepted and typed as `unsigned long long`.
    This matches D behavior, and that of some C compilers.

    $(H3 $(ID dotArrow) Dot and Arror Operators)

    The `.` operator is used to designate a member of a struct or union value.
        The `-&gt;` operator is used to designate a member of a struct or union value pointed to
        by a pointer. The extension is that `.` and `-&gt;` can be used interchangeably on
        values and pointers. This matches D's behavior for `.`.

$(H2 $(ID gnu-clang-extensions) Gnu and Clang Extensions)

    `gcc` and `clang` are presumed to have the same behavior w.r.t. extensions,
    so `gcc` as used here refers to both.


    $(H3 $(ID __attribute__) `__attribute__` Extensions)

    The following $(LINK2 https://gcc.gnu.org/onlinedocs/gcc/Function-Attributes.html, `__attribute__` extensions):

    $(NUMBERED_LIST
    * `__attribute__((aligned(N)))`
    * `__attribute__((always_inline))`
    * `__attribute__((deprecated))`
    * `__attribute__((dllexport))`
    * `__attribute__((dllimport))`
    * `__attribute__((naked))`
    * `__attribute__((noinline))`
    * [#noreturn|`__attribute__((noreturn))`]
    * `__attribute__((nothrow))`
    * `__attribute__((pure))`
    * `__attribute__((vector_size(N)))`
    * others are ignored
    
)

    $(H3 $(ID noreturn) `__attribute__((noreturn))`)

    `__attribute__((noreturn))` marks a function as never returning.
    `gcc` set this as an attribute of the function, it is
    not part of the function's type. In D, a function that never returns
    has the return type [type#noreturn|type, noreturn]. The difference can be
    seen with the code:
    ```c
    attribute((noreturn)) int foo();
    size_t x = sizeof(foo());
    
```
    This code is accepted by `gcc`, but makes no sense for D. Hence,
    although it works in ImportC, it is not representable as D code,
    meaning one must use judgement in creating a .di file to interface
    with C `noreturn` functions.

    Furthermore, the D compiler takes advantage of `noreturn` functions
    by issuing compile time errors for unreachable code. Such unreachable
    code, however, is valid C11, and the ImportC compiler will accept it.

    $(TIP C code that uses the `noreturn` attribute should at the
    very least set the return type to `void`.)


$(H2 $(ID visualc-extensions) Visual C Extensions)

    All the [#digital-mars-extensions|Digital Mars C Extensions].

    $(H3 $(ID __stdcall) `__stdcall` Function Calling Convention)

    `__stdcall` sets the calling convention for a function to the Windows API calling convention.

---
int __stdcall foo(int x);

---

    $(H3 $(ID __declspec) `__declspec` Attribute Extensions)

    The following $(LINK2 https://learn.microsoft.com/en-us/cpp/cpp/declspec?view=msvc-170, `__declspec` extensions):

    $(NUMBERED_LIST
    * `__declspec()`
    * `__declspec(align(N))`
    * `__declspec(deprecated)`
    * `__declspec(dllexport)`
    * `__declspec(dllimport)`
    * `__declspec(naked)`
    * `__declspec(noinline)`
    * `__declspec(noreturn)`
    * `__declspec(nothrow)`
    * `__declspec(thread)`
    * others are ignored
    
)

    $(H3 $(ID __pragma) `__pragma` Attribute Extensions)

    The following
        <a href="@ https://learn.microsoft.com/en-us/cpp/preprocessor/pragma-directives-and-the-pragma-keyword?view=msvc-170, `__pragma` extensions">@ https://learn.microsoft.com/en-us/cpp/preprocessor/pragma-directives-and-the-pragma-keyword?view=msvc-170, `__pragma` extensions</a>:

    $(NUMBERED_LIST
    * `__pragma(pack(N))`
    * others are ignored
    
)

$(H2 $(ID digital-mars-extensions) Digital Mars C Extensions)

    $(H3 $(ID __stdcall) `__stdcall` Function Calling Convention)

    $(H3 $(ID __declspec) `__declspec` Attribute Extensions)

    The following $(LINK2 https://digitalmars.com/ctg/ctgLanguageImplementation.html#declspec, `__declspec` extensions):

    $(NUMBERED_LIST
    * `__declspec(dllexport)`
    * `__declspec(dllimport)`
    * `__declspec(naked)`
    * `__declspec(thread)`
    
)


$(H2 $(ID d-side) ImportC from D's Point of View)

    There is no one-to-one mapping of C constructs to D constructs, although
    it is very close. What follows is a description of how the D side views
    the C declarations that are imported.

    $(H3 $(ID module-name) Module Name)

    The module name assigned to the ImportC file is the filename stripped
    of its path and extension. This is just like the default module name assigned
    to a D module that does not have a module declaration.

    $(H3 $(ID extern-C) `extern (C)`)

    All C symbols are `extern (C)`.

    $(H3 $(ID enums) Enums)

    The C enum:

    ```c
enum E { A, B = 2 };
```

    appears to D code as:

---
enum E : int { A, B = 2 }
alias A = E.A;
alias B = E.B;

---

    The `.min` and `.max` properties are available:

---
static assert(E.min == 0 &amp;&amp; E.max == 2);

---

    $(H3 $(ID tag-symbols) Tag Symbols)

    Tag symbols are the identifiers that appear after the `struct`, `union`, and `enum`
    keywords, (C11 6.7.2.3). In C, they are placed in a different symbol table from other
    identifiers. This means two different symbols can use the same name:

    ```c
    int S;
    struct S { int a, b; };
    S = 3;
    struct S *ps;
    
```

    D does not make this distinction. Given a tag symbol that is the only declaration of an
    identifier, that's what the D compiler recognizes. Given a tag symbol and a non-tag symbol
    that share an identifier, the D compiler recognizes the non-tag symbol. This is normally
    not a problem due to the common C practice of applying `typedef`, as in:

    ```c
    typedef struct S { int a, b; } S;
    
```

    The D compiler recognizes the `typedef` applied to `S`, and the code compiles as expected. But when `typedef` is absent, as in:

    ```c
    int S;
    struct S { int a, b; };
    
```

    the most pragmatic workaround is to add a `typedef` to the C code:

    ```c
    int S;
    struct S { int a, b; };
    typedef struct S S_t;    // add this typedef
    
```

    Then the D compiler can access the struct tag symbol via `S_t`.


$(H2 $(ID wrapping) Wrapping C Code)

    Many difficulties with adapting C code to ImportC can be done without
    editing the C code itself. Wrap the C code in another C file and then
    ```c
#include
``` it. Consider the following problematic C file $(TT file.c):

    ```c
    void func(int *__restrict p);
    int S;
    struct S { int a, b; };
    
```

    The problems are that ```c
__restrict
``` is not a type qualifier recognized by ImportC
    (or C11),
    and the struct `S` is hidden from D by the declaration ```c
int S;
```.
    To wrap $(TT file.c) with a fix, create the file $(TT file_ic.c) with the contents:

    ```c
    #define __restrict restrict
    #include "file.c"
    typedef struct S S_t;
    
```

    Then, `import file_ic;` instead of `import file;`, and use `S_t` when ```c
struct S
``` is desired.


$(H2 $(ID ctod) Converting C Code to D Code)

    Sometimes its desirable to go further than importing C code, to actually do a C source to
    D source conversion. Reasons include:

    $(LIST
    * Migrating a C project to a D project.
    * Equivalent D code can compile much faster, due to not needing a preprocessor, etc.
    * Tweaking the D code to add attributes for memory safety, purity, etc.
    * Eliminating the need for C-isms in the D part of the project.
    
)

    This can be done with the D compiler by using the $(TT -Hf) switch:

$(CONSOLE dmd -c mycode.c -Hf=mycode.di
)

    which will convert the C source code in $(TT mycode.c) to D source code in $(TT mycode.di).
    If the $(TT -inline) switch is also used, it will emit the C function bodies as well, instead
    of just the function prototypes.

$(H3 Impedance Mismatch)

    A precise mapping of C semantics, with all its oddities, to D source code is not
    always practical. ImportC uses C semantics in its semantic analysis to get much closer
    to exact C semantics than is expressible in D source code. Hence, the translation to
    D source code will be less than perfect. For example:

    ```c
    int S;
    struct S { int a, b; };
    int foo(struct S s)
    {
        return S + s.a;
    }
    
```

    will work fine in ImportC, because the `int S` and the `struct S` are in different
    symbol tables. But in the generated D code, both symbols would be in the same symbol table, and will collide.
    Such D source code translated from C will need to be adjusted by the user.

    Nevertheless, reports from the field are that this conversion capability is a huge
    timesaver for users who need to deal with existing C code.

$(H2 $(ID warnings) Warnings)

    Many suspicious C constructs normally cause warnings to be emitted by default by
    typical compilers, such as:

    ```c
int *p = 3; // Warning: integer implicitly converted to pointer
```

    ImportC does not emit warnings. The presumption is the user will be importing existing C
    code developed using another C compiler, and it is written as intended.
    If C11 says it is legal, ImportC accepts it.


$(H2 $(ID builtins) $(TT __builtins.di))

    ImportC uses D to implement several features. These are implemented in the file
    $(LINK2 https://github.com/dlang/dmd/blob/master/druntime/src/__builtins.di, $(TT __builtins.di))
    which is automatically imported for every ImportC compilation.

$(H2 $(ID importcpp) ImportC++)

    ImportC will not compile C++ code. For that, use $(TT dpp).


$(H2 $(ID other-solutions) Other Solutions)

    $(H3 $(ID dpp) dpp by Atila Neves)

    $(LINK2 https://code.dlang.org/packages/dpp/0.2.1, dpp code)

    $(LINK2 https://dlang.org/blog/2019/04/08/project-highlight-dpp/, dpp Article)

    From the Article:

    <blockquote>dpp is a compiler wrapper that will parse a D source
    file with the .dpp extension and expand in place any #include directives
    it encounters, translating all of the C or C++ symbols to D, and then
    pass the result to a D compiler (DMD by default).</blockquote>

    Like DStep, dpp relies on libclang.


    $(H3 $(ID dstep) DStep by Jacob Carlborg)

    $(LINK2 https://code.dlang.org/packages/dstep, DStep code)

    $(LINK2 https://dlang.org/blog/2019/04/22/dstep-1-0-0/, DStep Article)

    From the Article:

    <blockquote>DStep is a tool for automatically generating D
    bindings for C and Objective-C libraries. This is implemented by
    processing C or Objective-C header files and outputting D modules.
    DStep uses the Clang compiler as a library (libclang) to process the header files.</blockquote>


    $(H3 $(ID htod) htod by Walter Bright)

    $(LINK2 https://dlang.org/htod.html, htod) converts a C $(TT .h) file
    to a D source file, suitable for importing into D code.
    $(B htod) is built from the front end of the Digital Mars C and C++ compiler.
    It works just like a C or C++ compiler except that its output is source
    code for a D module rather than object code.


$(H2 $(ID internals) How ImportC Works)

    ImportC's implementation is based on the idea that D's semantics are very similar
    to C's. ImportC gets its own parser, which converts the C syntax into the same AST
    (Abstract Syntax Tree) that D uses. The lexer for ImportC is the same as for D, but with
    some modifications here and there, such as the keywords and integer literals being different.
    Where the semantics of C differ from D, there are adjustments in the semantic analysis
    code in the D compiler.

    This co-opting of the D semantic implementation allows ImportC to be able to do things
    like handle forward references, CTFE (Compile Time Function Execution), and inlining of C functions
    into D code. Being able to handle forward references means it is not necessary to even
    write a .h file to be able to import C declarations into D. Being able to perform CTFE is
    very handy for testing that ImportC is working without needing to generate an executable.
    But, in general, the strong temptation to add D features to ImportC has been resisted.

    The optimizer and code generator are, of course, the same as D uses.

betterc, Better C, ob, Live Functions




Link_References:
	ACC = Associated C Compiler
+/
module importc.dd;