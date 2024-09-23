// just docs: Conditional Compilation
/++





        $(I Conditional compilation) is the process of selecting which
        code to compile and which code to not compile.
        

$(PRE $(CLASS GRAMMAR)
$(B $(ID ConditionalDeclaration) ConditionalDeclaration):
    [#Condition|Condition] [attribute#DeclarationBlock|attribute, DeclarationBlock]
    [#Condition|Condition] [attribute#DeclarationBlock|attribute, DeclarationBlock] `else` [attribute#DeclarationBlock|attribute, DeclarationBlock]
    [#Condition|Condition] `:` [module#DeclDefs|module, DeclDefs]$(SUBSCRIPT opt)
    [#Condition|Condition] [attribute#DeclarationBlock|attribute, DeclarationBlock] `else` `:` [module#DeclDefs|module, DeclDefs]$(SUBSCRIPT opt)

$(B $(ID ConditionalStatement) ConditionalStatement):
    [#Condition|Condition] [statement#NoScopeNonEmptyStatement|statement, NoScopeNonEmptyStatement]
    [#Condition|Condition] [statement#NoScopeNonEmptyStatement|statement, NoScopeNonEmptyStatement] `else` [statement#NoScopeNonEmptyStatement|statement, NoScopeNonEmptyStatement]

)

        If the [#Condition|Condition] is satisfied, then the following
        $(I DeclarationBlock) or $(I Statement) is compiled in.
        If it is not satisfied, the $(I DeclarationBlock) or $(I Statement)
        after the optional `else` is compiled in.
        

        Any $(I DeclarationBlock) or $(I Statement) that is not
        compiled in still must be syntactically correct.
        

        No new scope is introduced, even if the
        $(I DeclarationBlock) or $(I Statement)
        is enclosed by `{ }`.
        

        $(I ConditionalDeclaration)s and $(I ConditionalStatement)s
        can be nested.
        

        The [#StaticAssert|StaticAssert] can be used
        to issue errors at compilation time for branches of the conditional
        compilation that are errors.
        

        $(I Condition) comes in the following forms:
        

$(PRE $(CLASS GRAMMAR)
$(B $(ID Condition) Condition):
    [#VersionCondition|VersionCondition]
    [#DebugCondition|DebugCondition]
    [#StaticIfCondition|StaticIfCondition]

)

$(H2 $(ID version) Version Condition)

$(PRE $(CLASS GRAMMAR)
$(B $(ID VersionCondition) VersionCondition):
    `version (` $(LINK2 lex#Identifier, Identifier) `)`
    `version (` `unittest` `)`
    `version (` `assert` `)`

)

        Versions enable multiple versions of a module to be implemented
        with a single source file.
        

        The $(I VersionCondition) is satisfied if $(I Identifier)
        matches a $(I version identifier).
        

        The $(I version identifier) can be set on the command line
        by the `-version` switch or in the module itself with a
        [#VersionSpecification|VersionSpecification], or they can be predefined
        by the compiler.
        

        Version identifiers are in their own unique name space, they do
        not conflict with debug identifiers or other symbols in the module.
        Version identifiers defined in one module have no influence
        over other imported modules.
        

---
int k;
version (Demo) // compile in this code block for the demo version
{
    int i;
    int k;    // error, k already defined

    i = 3;
}
x = i;      // uses the i declared above

---

---
version (X86)
{
    ... // implement custom inline assembler version
}
else
{
    ... // use default, but slow, version
}

---

        The `version(unittest)` is satisfied if and only if the code is
        compiled with unit tests enabled (the $(LINK2 dmd#switch-unittest,$(TT -unittest)) option on $(TT dmd)).
        


$(H2 $(ID version-specification)Version Specification)

$(PRE $(CLASS GRAMMAR)
$(B $(ID VersionSpecification) VersionSpecification):
    `version =` $(LINK2 lex#Identifier, Identifier) `;`

)

        The version specification makes it straightforward to group
        a set of features under one major version, for example:
        

---
version (ProfessionalEdition)
{
    version = FeatureA;
    version = FeatureB;
    version = FeatureC;
}
version (HomeEdition)
{
    version = FeatureA;
}
...
version (FeatureB)
{
    ... implement Feature B ...
}

---

        Version identifiers or levels may not be forward referenced:
        

---
version (Foo)
{
    int x;
}
version = Foo;  // error, Foo already used

---
        $(I VersionSpecification)s may only appear at module scope.

        While the debug and version conditions superficially behave the
        same,
        they are intended for very different purposes. Debug statements
        are for adding debug code that is removed for the release version.
        Version statements are to aid in portability and multiple release
        versions.
        

        Here's an example of a $(I full) version as opposed to
        a $(I demo) version:

---
class Foo
{
    int a, b;

    version(full)
    {
        int extrafunctionality()
        {
            ...
            return 1;  // extra functionality is supported
        }
    }
    else // demo
    {
        int extrafunctionality()
        {
            return 0;  // extra functionality is not supported
        }
    }
}

---

        Various different version builds can be built with a parameter
        to version:
        

---

version(/* adrdox_highlight{ */identifier/* }adrdox_highlight */) // add in version code if version
                         // keyword is identifier
{
    ... version code ...
}

---

        This is presumably set by the command line as
        `-version=identifier`.
        


$(H3 $(ID predefined-versions)Predefined Versions)

        Several environmental version identifiers and identifier
        name spaces are predefined for consistent usage.
        Version identifiers do not conflict
        with other identifiers in the code, they are in a separate name space.
        Predefined version identifiers are global, i.e. they apply to
        all modules being compiled and imported.
        

        $(TABLE_ROWS
Predefined Version Identifiers
        * + Version Identifier
+ Description
         * - `DigitalMars` 
- DMD (Digital Mars D) is the compiler

        * - `GNU` 
- GDC (GNU D Compiler) is the compiler

        * - `LDC` 
- LDC (LLVM D Compiler) is the compiler

        * - `SDC` 
- SDC (Stupid D Compiler) is the compiler

        * - `Windows` 
- Microsoft Windows systems

        * - `Win32` 
- Microsoft 32-bit Windows systems

        * - `Win64` 
- Microsoft 64-bit Windows systems

        * - `linux` 
- All Linux systems

        * - `OSX` 
- macOS

        * - `iOS` 
- iOS

        * - `TVOS` 
- tvOS

        * - `WatchOS` 
- watchOS

        * - `VisionOS` 
- visionOS

        * - `FreeBSD` 
- FreeBSD

        * - `OpenBSD` 
- OpenBSD

        * - `NetBSD` 
- NetBSD

        * - `DragonFlyBSD` 
- DragonFlyBSD

        * - `BSD` 
- All other BSDs

        * - `Solaris` 
- Solaris

        * - `Posix` 
- All POSIX systems (includes Linux, FreeBSD, OS X, Solaris, etc.)

        * - `AIX` 
- IBM Advanced Interactive eXecutive OS

        * - `Haiku` 
- The Haiku operating system

        * - `SkyOS` 
- The SkyOS operating system

        * - `SysV3` 
- System V Release 3

        * - `SysV4` 
- System V Release 4

        * - `Hurd` 
- GNU Hurd

        * - `Android` 
- The Android platform

        * - `Emscripten` 
- The Emscripten platform

        * - `PlayStation` 
- The PlayStation platform

        * - `PlayStation4` 
- The PlayStation 4 platform

        * - `Cygwin` 
- The Cygwin environment

        * - `MinGW` 
- The MinGW environment

        * - `FreeStanding` 
- An environment without an operating system (such as Bare-metal targets)

        * - `CRuntime_Bionic` 
- Bionic C runtime

        * - `CRuntime_DigitalMars` 
- DigitalMars C runtime

        * - `CRuntime_Glibc` 
- Glibc C runtime

        * - `CRuntime_Microsoft` 
- Microsoft C runtime

        * - `CRuntime_Musl` 
- musl C runtime

        * - `CRuntime_Newlib` 
- newlib C runtime

        * - `CRuntime_UClibc` 
- uClibc C runtime

        * - `CRuntime_WASI` 
- WASI C runtime

        * - `CppRuntime_Clang` 
- Clang Cpp runtime

        * - `CppRuntime_DigitalMars` 
- DigitalMars Cpp runtime

        * - `CppRuntime_Gcc` 
- Gcc Cpp runtime

        * - `CppRuntime_Microsoft` 
- Microsoft Cpp runtime

        * - `CppRuntime_Sun` 
- Sun Cpp runtime

        * - `X86` 
- Intel and AMD 32-bit processors

        * - `X86_64` 
- Intel and AMD 64-bit processors

        * - `ARM` 
- The ARM architecture (32-bit) (AArch32 et al)

        * - `ARM_Thumb` 
- ARM in any Thumb mode

        * - `ARM_SoftFloat` 
- The ARM `soft` floating point ABI

        * - `ARM_SoftFP` 
- The ARM `softfp` floating point ABI

        * - `ARM_HardFloat` 
- The ARM `hardfp` floating point ABI

        * - `AArch64` 
- The Advanced RISC Machine architecture (64-bit)

        * - `AsmJS` 
- The asm.js intermediate programming language

        * - `AVR` 
- 8-bit Atmel AVR Microcontrollers

        * - `Epiphany` 
- The Epiphany architecture

        * - `PPC` 
- The PowerPC architecture, 32-bit

        * - `PPC_SoftFloat` 
- The PowerPC soft float ABI

        * - `PPC_HardFloat` 
- The PowerPC hard float ABI

        * - `PPC64` 
- The PowerPC architecture, 64-bit

        * - `IA64` 
- The Itanium architecture (64-bit)

        * - `MIPS32` 
- The MIPS architecture, 32-bit

        * - `MIPS64` 
- The MIPS architecture, 64-bit

        * - `MIPS_O32` 
- The MIPS O32 ABI

        * - `MIPS_N32` 
- The MIPS N32 ABI

        * - `MIPS_O64` 
- The MIPS O64 ABI

        * - `MIPS_N64` 
- The MIPS N64 ABI

        * - `MIPS_EABI` 
- The MIPS EABI

        * - `MIPS_SoftFloat` 
- The MIPS `soft-float` ABI

        * - `MIPS_HardFloat` 
- The MIPS `hard-float` ABI

        * - `MSP430` 
- The MSP430 architecture

        * - `NVPTX` 
- The Nvidia Parallel Thread Execution (PTX) architecture, 32-bit

        * - `NVPTX64` 
- The Nvidia Parallel Thread Execution (PTX) architecture, 64-bit

        * - `RISCV32` 
- The RISC-V architecture, 32-bit

        * - `RISCV64` 
- The RISC-V architecture, 64-bit

        * - `SPARC` 
- The SPARC architecture, 32-bit

        * - `SPARC_V8Plus` 
- The SPARC v8+ ABI

        * - `SPARC_SoftFloat` 
- The SPARC soft float ABI

        * - `SPARC_HardFloat` 
- The SPARC hard float ABI

        * - `SPARC64` 
- The SPARC architecture, 64-bit

        * - `S390` 
- The System/390 architecture, 32-bit

        * - `SystemZ` 
- The System Z architecture, 64-bit

        * - `HPPA` 
- The HP PA-RISC architecture, 32-bit

        * - `HPPA64` 
- The HP PA-RISC architecture, 64-bit

        * - `SH` 
- The SuperH architecture, 32-bit

        * - `WebAssembly` 
- The WebAssembly virtual ISA (instruction set architecture), 32-bit

        * - `WASI` 
- The WebAssembly System Interface

        * - `Alpha` 
- The Alpha architecture

        * - `Alpha_SoftFloat` 
- The Alpha soft float ABI

        * - `Alpha_HardFloat` 
- The Alpha hard float ABI

        * - `LittleEndian` 
- Byte order, least significant first

        * - `BigEndian` 
- Byte order, most significant first

        * - `ELFv1` 
- The Executable and Linkable Format v1

        * - `ELFv2` 
- The Executable and Linkable Format v2

        * - `D_BetterC` 
- $(LINK2 spec/betterc, D as Better C) code
                (command line switch $(LINK2 dmd#switch-betterC,$(TT -betterC))) is being generated

        * - `D_Exceptions` 
- Exception handling is supported.  Evaluates to `false` when compiling with
                command line switch $(LINK2 dmd#switch-betterC,$(TT -betterC))

        * - `D_ModuleInfo` 
- $(LINK2 abi#ModuleInfo,$(TT ModuleInfo)) is supported.  Evaluates to `false` when compiling with
                command line switch $(LINK2 dmd#switch-betterC,$(TT -betterC))

        * - `D_TypeInfo` 
- Runtime type information (a.k.a `TypeInfo`) is supported.  Evaluates to `false` when compiling with
                command line switch $(LINK2 dmd#switch-betterC,$(TT -betterC))

        * - `D_Coverage` 
- $(LINK2 articles/code_coverage, Code coverage analysis) instrumentation
                (command line switch $(LINK2 dmd#switch-cov,$(TT -cov))) is being generated

        * - `D_Ddoc` 
- $(LINK2 spec/ddoc, Embedded Documentation) documentation
                (command line switch $(LINK2 dmd#switch-D,$(TT -D))) is being generated

        * - `D_InlineAsm_X86` 
- $(LINK2 spec/iasm, Inline Assembler) for X86 is implemented

        * - `D_InlineAsm_X86_64` 
- $(LINK2 spec/iasm, Inline Assembler) for X86-64 is implemented

        * - `D_LP64` 
- $(B Pointers) are 64 bits
                (command line switch $(LINK2 dmd#switch-m64,$(TT -m64))). (Do not confuse this with C's LP64 model)

        * - `D_X32` 
- Pointers are 32 bits, but words are still 64 bits (x32 ABI) (This can be defined in parallel to `X86_64`)

        * - `D_HardFloat` 
- The target hardware has a floating-point unit

        * - `D_SoftFloat` 
- The target hardware does not have a floating-point unit

        * - `D_PIC` 
- Position Independent Code
                (command line switch $(LINK2 dmd-linux#switch-fPIC,$(TT -fPIC))) is being generated

        * - `D_PIE` 
- Position Independent Executable
                (command line switch $(LINK2 dmd-linux#switch-fPIE,$(TT -fPIE))) is being generated

        * - `D_SIMD` 
- $(LINK2 spec/simd, simd) (via `__simd`) are supported

        * - `D_AVX` 
- AVX Vector instructions are supported

        * - `D_AVX2` 
- AVX2 Vector instructions are supported

        * - `D_Version2` 
- This is a D version 2 compiler

        * - `D_NoBoundsChecks` 
- Array bounds checks are disabled
                (command line switch $(LINK2 dmd#switch-boundscheck,$(TT -boundscheck=off)))

        * - `D_ObjectiveC` 
- The target supports interfacing with Objective-C

        * - `D_ProfileGC` 
- GC allocations being profiled
                (command line switch $(LINK2 dmd#switch-profile,$(TT -profile=gc)))

        * - `D_Optimized` 
- Compiling with enabled optimizations
                (command line switch $(LINK2 dmd#switch-O,$(TT -O)))

        * - `Core` 
- Defined when building the standard runtime

        * - `Std` 
- Defined when building the standard library

        * - `unittest` 
- $(LINK2 spec/unittest, Unit Tests) are enabled
                (command line switch $(LINK2 dmd#switch-unittest,$(TT -unittest)))

        * - `assert` 
- Checks are being emitted for [expression#AssertExpression|expression, AssertExpression]s

        * - `D_PreConditions` 
- Checks are being emitted for $(LINK2 spec/function#contracts,in contracts)

        * - `D_PostConditions` 
- Checks are being emitted for $(LINK2 spec/function#contracts,out contracts)

        * - `D_Invariants` 
- Checks are being emitted for $(LINK2 spec/class#invariants,class invariants) and $(LINK2 spec/struct#Invariant,struct invariants)

        * - `none` 
- Never defined; used to just disable a section of code

        * - `all` 
- Always defined; used as the opposite of `none`

        
)

        The following identifiers are defined, but are deprecated:
        

        $(TABLE_ROWS
Predefined Version Identifiers (deprecated)
        * + Version Identifier
+ Description

        * - `darwin`
- The Darwin operating system; use `OSX` instead

        * - `Thumb`
- ARM in Thumb mode; use `ARM_Thumb` instead

        * - `S390X`
- The System/390X architecture, 64-bit; use `SystemZ` instead

        
)

        Others will be added as they make sense and new implementations appear.
        

        To allow for future growth of the language,
        the version identifier namespace beginning with "D_"
        is reserved for identifiers indicating D language specification
        or new feature conformance. Further, all identifiers derived from
        the ones listed above by appending any character(s) are reserved. This
        means that e.g. `ARM_foo` and `Windows_bar` are reserved while
        `foo_ARM` and `bar_Windows` are not.
        

        Furthermore, predefined version identifiers from this list cannot
        be set from the command line or from version statements.
        (This prevents things like both `Windows` and `linux`
        being simultaneously set.)
        

        Compiler vendor specific versions can be predefined if the
        trademarked vendor identifier prefixes it, as in:
        

---
version(DigitalMars_funky_extension)
{
    ...
}

---

        It is important to use the right version identifier for the right
        purpose. For example, use the vendor identifier when using a vendor
        specific feature. Use the operating system identifier when using
        an operating system specific feature, etc.
        


$(H2 $(ID debug) Debug Condition)

$(PRE $(CLASS GRAMMAR)
$(B $(ID DebugCondition) DebugCondition):
    `debug`
    `debug (` $(LINK2 lex#Identifier, Identifier) `)`

)

        Two versions of programs are commonly built,
        a release build and a debug build.
        The debug build includes extra error checking code,
        test harnesses, pretty-printing code, etc.
        The debug statement conditionally compiles in its
        statement body.
        It is D's way of what in C is done
        with `#ifdef DEBUG` / `#endif` pairs.
        

        The `debug` condition is satisfied when the `-debug` switch is
        passed to the compiler.
        

        The `debug (` $(I Identifier) `)` condition is satisfied
        when the debug identifier matches $(I Identifier).
        

---
class Foo
{
    int a, b;
debug:
    int flag;
}

---

$(H3 $(ID DebugStatement) Debug Statement)

        A [#ConditionalStatement|ConditionalStatement] that has a [#DebugCondition|DebugCondition] is called
        a $(I DebugStatement). $(I DebugStatements) have relaxed semantic checks in that
        `pure`, `@nogc`, `nothrow` and `@safe` checks are not done.
        Neither do $(I DebugStatements) influence the inference of `pure`, `@nogc`, `nothrow`
        and `@safe` attributes.

        $(PITFALL Since these checks are bypassed, it is up to the programmer
        to ensure the code is correct. For example, throwing an exception in a `nothrow`
        function is undefined behavior.
        )

        $(TIP This enables the easy insertion of code to provide debugging help,
        by bypassing the otherwise stringent attribute checks.
        Never ship release code that has $(I DebugStatements) enabled.
        )

$(H2 $(ID debug_specification) Debug Specification)

$(PRE $(CLASS GRAMMAR)
$(B $(ID DebugSpecification) DebugSpecification):
    `debug =` $(LINK2 lex#Identifier, Identifier) `;`

)

        Debug identifiers are set either by the command line switch
        `-debug` or by a $(I DebugSpecification).
        

        Debug specifications only affect the module they appear in, they
        do not affect any imported modules. Debug identifiers are in their
        own namespace, independent from version identifiers and other
        symbols.
        

        It is illegal to forward reference a debug specification:
        

---
debug(foo) writeln("Foo");
debug = foo;    // error, foo used before set

---

        $(I DebugSpecification)s may only appear at module scope.

        Various different debug builds can be built with a parameter to
        debug:
        

---
debug(identifier) { } // add in debug code if debug keyword is identifier

---

        These are presumably set by the command line as
        and `-debug=`$(I identifier).
        

$(H2 $(ID staticif) Static If Condition)

$(PRE $(CLASS GRAMMAR)
$(B $(ID StaticIfCondition) StaticIfCondition):
    `static if (` AssignExpression `)`

)

        AssignExpression is implicitly converted to a boolean type,
        and is evaluated at compile time.
        The condition is satisfied if it evaluates to `true`.
        It is not satisfied if it evaluates to `false`.
        

        It is an error if AssignExpression cannot be implicitly converted
        to a boolean type or if it cannot be evaluated at compile time.
        

        $(I StaticIfCondition)s
        can appear in module, class, template, struct, union, or function scope.
        In function scope, the symbols referred to in the
        AssignExpression can be any that can normally be referenced
        by an expression at that point.
        

---
const int i = 3;
int j = 4;

/* adrdox_highlight{ */static if/* }adrdox_highlight */ (i == 3)    // ok, at module scope
    int x;

class C
{
    const int k = 5;

    /* adrdox_highlight{ */static if/* }adrdox_highlight */ (i == 3) // ok
        int x;
    else
        long x;

    /* adrdox_highlight{ */static if/* }adrdox_highlight */ (j == 3) // error, j is not a constant
        int y;

    /* adrdox_highlight{ */static if/* }adrdox_highlight */ (k == 5) // ok, k is in current scope
        int z;
}

---
$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_FAIL)
---
template Int(int i)
{
    static if (i == 32)
        alias Int = int;
    else static if (i == 16)
        alias Int = short;
    else
        static assert(0); // not supported
}

Int!(32) a;  // a is an int
Int!(16) b;  // b is a short
Int!(17) c;  // error, static assert trips

---

)

        A $(I StaticIfCondition) differs from an
        $(I IfStatement) in the following ways:
        

        $(NUMBERED_LIST
        * It can be used to conditionally compile declarations,
        not just statements.
        
        * It does not introduce a new scope even if `{ }`
        are used for conditionally compiled statements.
        
        * For unsatisfied conditions, the conditionally compiled code
        need only be syntactically correct. It does not have to be
        semantically correct.
        
        * It must be evaluatable at compile time.
        
        
)

$(H2 $(ID staticforeach) Static Foreach)

$(PRE $(CLASS GRAMMAR)
$(B $(ID StaticForeach) StaticForeach):
    `static` [statement#AggregateForeach|statement, AggregateForeach]
    `static` [statement#RangeForeach|statement, RangeForeach]

$(B $(ID StaticForeachDeclaration) StaticForeachDeclaration):
    [#StaticForeach|StaticForeach] [attribute#DeclarationBlock|attribute, DeclarationBlock]
    [#StaticForeach|StaticForeach] `:` [module#DeclDefs|module, DeclDefs]$(SUBSCRIPT opt)

$(B $(ID StaticForeachStatement) StaticForeachStatement):
    [#StaticForeach|StaticForeach] [statement#NoScopeNonEmptyStatement|statement, NoScopeNonEmptyStatement]

)

        The aggregate/range bounds are evaluated at compile time and
        turned into a sequence of compile-time entities by evaluating
        corresponding code with a [statement#ForeachStatement|statement, ForeachStatement]/[statement#ForeachRangeStatement|statement, ForeachRangeStatement]
        at compile time. The body of the `static foreach` is then copied a
        number of times that corresponds to the number of elements of the
        sequence. Within the i-th copy, the name of the `static foreach`
        variable is bound to the i-th entry of the sequence, either as an `enum`
        variable declaration (for constants) or an `alias`
        declaration (for symbols). (In particular, `static foreach`
        variables are never runtime variables.)
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
static foreach(i; [0, 1, 2, 3])
{
    pragma(msg, i);
}

---

)

        `static foreach` supports multiple variables in cases where the
        corresponding `foreach` statement supports them. (In this case,
        `static foreach` generates a compile-time sequence of tuples, and the
        tuples are subsequently unpacked during iteration).
        

---
static foreach(i, v; ['a', 'b', 'c', 'd'])
{
    static assert(i + 'a' == v);
}

---

        Like bodies of [#ConditionalDeclaration|ConditionalDeclaration]s, a `static foreach`
        body does not introduce a new scope. Therefore, it can be
        used to generate declarations:
        

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
import std.range : iota;

static foreach(i; iota(0, 3))
{
    mixin(`enum x`, i, ` = i;`);
}

pragma(msg, x0, " ", x1," ", x2); // 0 1 2

---

)

        Inside a function, if a new scope is desired for each expansion,
        use another set of braces:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_COMPILE)
---
void fun()
{
    static foreach(s; ["hi", "hey", "hello"])
    {{
        enum len = s.length;    // local to each iteration
        static assert(len &lt;= 5);
    }}

    static assert(!is(typeof(len)));
}

---

)

$(H3 $(ID break-continue) `break` and `continue`)

        As `static foreach` is a code generation construct and not a
        loop, `break` and `continue` cannot be used to change control
        flow within it. Instead of breaking or continuing a suitable enclosing
        statement, such an usage yields an error (this is to prevent
        misunderstandings).
        

---
int test(int x)
{
    int r = -1;
    switch(x)
    {
        static foreach(i; 0 .. 100)
        {
            case i:
                r = i;
                break; // error
        }
        default: break;
    }
    return r;
}

static foreach(i; 0 .. 200)
{
    static assert(test(i) == (i &lt; 100 ? i : -1));
}

---

        An explicit `break`/`continue` label can be used to
        avoid this limitation. (Note that `static foreach` itself
        cannot be broken nor continued even if it is explicitly
        labeled.)
        

---
int test(int x)
{
    int r = -1;
    Lswitch: switch(x)
    {
        static foreach(i; 0 .. 100)
        {
            case i:
                r = i;
                break Lswitch;
        }
        default: break;
    }
    return r;
}

static foreach(i; 0 .. 200)
{
    static assert(test(i) == (i&lt;100 ? i : -1));
}

---


$(H2 $(ID static-assert)Static Assert)

$(PRE $(CLASS GRAMMAR)
$(B $(ID StaticAssert) StaticAssert):
    `static assert (` [expression#ArgumentList|expression, ArgumentList] `) ;`

)

        The first AssignExpression is evaluated at compile time, and converted
        to a boolean value. If the value is true, the static assert
        is ignored. If the value is false, an error diagnostic is issued
        and the compile fails.
        

        On failure, any subsequent $(I AssignExpression)s will each be
        converted to string and then concatenated. The resulting string will
        be printed out along with the error diagnostic.
        

        Unlike [expression#AssertExpression|expression, AssertExpression]s, $(I StaticAssert)s are always
        checked and evaluated by the compiler unless they appear in an
        unsatisfied conditional.
        

---
void foo()
{
    if (0)
    {
        assert(0);  // never trips
        static assert(0); // always trips
    }
    version (BAR)
    {
    }
    else
    {
        static assert(0); // trips when version BAR is not defined
    }
}

---

        $(I StaticAssert) is useful tool for drawing attention to conditional
        configurations not supported in the code.
        

contracts, Contract Programming, traits, Traits




Link_References:
	ACC = Associated C Compiler
+/
module version.dd;