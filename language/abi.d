// just docs: Application Binary Interface
/++





        A D implementation that conforms to the D ABI (Application Binary
        Interface)
        will be able to generate libraries, DLLs, etc., that can interoperate
        with
        D binaries built by other implementations.
        

$(H2 $(ID c_abi) C ABI)

        The C ABI referred to in this specification means the C Application
        Binary Interface of the target system.
        C and D code should be freely linkable together, in particular, D
        code shall have access to the entire C ABI runtime library.
        

$(H2 $(ID endianness) Endianness)

        The $(LINK2 https://en.wikipedia.org/wiki/Endianness, endianness)
        (byte order) of the layout of the data
        will conform to the endianness of the target machine.
        The Intel x86 CPUs are $(I little endian) meaning that
        the value 0x0A0B0C0D is stored in memory as:
        `0D 0C 0B 0A`.
        

$(H2 $(ID basic_types) Basic Types)

        $(TABLE         * - bool
- 8 bit byte with the values 0 for false and 1 for true

        * - byte
- 8 bit signed value

        * - ubyte
- 8 bit unsigned value

        * - short
- 16 bit signed value

        * - ushort
- 16 bit unsigned value

        * - int
- 32 bit signed value

        * - uint
- 32 bit unsigned value

        * - long
- 64 bit signed value

        * - ulong
- 64 bit unsigned value

        * - cent
- 128 bit signed value

        * - ucent
- 128 bit unsigned value

        * - float
- 32 bit IEEE 754 floating point value

        * - double
- 64 bit IEEE 754 floating point value

        * - real
- implementation defined floating point value, for x86 it is
         80 bit IEEE 754 extended real

        * - char
- 8 bit unsigned value

        * - wchar
- 16 bit unsigned value

        * - dchar
- 32 bit unsigned value

        )

$(H2 $(ID delegates) Delegates)

        Delegates are $(I fat pointers) with two parts:

        $(TABLE_ROWS
Delegate Layout
        * + offset
+ property
+ contents

        * - `0`
- `.ptr`
- context pointer

        * - $(I ptrsize)
- `.funcptr`
- pointer to function

        
)

        The $(I context pointer) can be a class $(I this)
        reference, a struct $(I this) pointer, a pointer to
        a closure (nested functions) or a pointer to an enclosing
        function's stack frame (nested functions).
        

$(H2 $(ID structs) Structs)

        Conforms to the target's C ABI struct layout.

$(H2 $(ID classes) Classes)

        An object consists of:

    $(TABLE_ROWS
Class Object Layout
    * + size
+ property
+ contents

    * - $(I ptrsize)
- `.__vptr`
- pointer to vtable

    * - $(I ptrsize)
- `.__monitor`
- monitor

    * - $(I ptrsize)...
- $(NBSP)
- vptrs for any interfaces implemented by this class in left to right, most to least derived, order

    * - `...`
- `...`
- super's non-static fields and super's interface vptrs, from least to most derived

    * - `...`
- named fields
- non-static fields

    
)

        The vtable consists of:

$(TABLE_ROWS
Virtual Function Pointer Table Layout
* + size
+ contents

* - $(I ptrsize)
- pointer to instance of TypeInfo

* - $(I ptrsize)...
- pointers to virtual member functions


)

        Casting a class object to an interface consists of adding the offset of
        the interface's corresponding vptr to the address of the base of the object.
        Casting an interface ptr back to the class type it came from involves getting
        the correct offset to subtract from it from the object.Interface entry at vtbl[0].
        Adjustor thunks are created and pointers to them stored in the method entries in the vtbl[]
        in order to set the this pointer to the start of the object instance corresponding
        to the implementing method.
        

        An adjustor thunk looks like:

```c
  ADD EAX,offset
  JMP method

```

        The leftmost side of the inheritance graph of the interfaces all share
        their vptrs, this is the single inheritance model.
        Every time the inheritance graph forks (for multiple inheritance) a new vptr is created
        and stored in the class' instance.
        Every time a virtual method is overridden, a new vtbl[] must be created with
        the updated method pointers in it.
        

        The class definition:

---
class XXXX
{
    ....
};

---

        Generates the following:

        $(LIST
        * An instance of Class called ClassXXXX.

        * A type called StaticClassXXXX which defines all the static members.

        * An instance of StaticClassXXXX called StaticXXXX for the static members.
        
)

$(H2 $(ID interfaces) Interfaces)

        An interface is a pointer to a pointer to a vtbl[].
        The vtbl[0] entry is a pointer to the corresponding
        instance of the object.Interface class.
        The rest of the `vtbl[1..$]` entries are pointers to the
        virtual functions implemented by that interface, in the
        order that they were declared.
        

        A COM interface differs from a regular interface in that
        there is no object.Interface entry in `vtbl[0]`; the entries
        `vtbl[0..$]` are all the virtual function pointers, in the order
        that they were declared.
        This matches the COM object layout used by Windows.
        
        A C++ interface differs from a regular interface in that
        it matches the layout of a C++ class using single inheritance
        on the target machine.
        

$(H2 $(ID arrays) Arrays)

        A dynamic array consists of:

$(TABLE_ROWS
Dynamic Array Layout
* + offset
+ property
+ contents

* - `0`
- `.length`
- array dimension

* - `size_t`
- `.ptr`
- pointer to array data


)

        A dynamic array is declared as:

---
type[] array;

---

        whereas a static array is declared as:

---
type[dimension] array;

---

        Thus, a static array always has the dimension statically available as part of the type, and
        so it is implemented like in C. Static arrays and Dynamic arrays can be easily converted back
        and forth to each other.
        

$(H2 $(ID associative_arrays) Associative Arrays)

        Associative arrays consist of a pointer to an opaque, implementation
        defined type.

        The current implementation is contained in and defined by
         rt/aaA.d.
        

$(H2 $(ID references_types) Reference Types)

        D has reference types, but they are implicit. For example, classes are always
        referred to by reference; this means that class instances can never reside on the stack
        or be passed as function parameters.
        


$(H2 $(ID name_mangling) Name Mangling)

        D accomplishes typesafe linking by $(I mangling) a D identifier
        to include scope and type information.
        

$(PRE $(CLASS GRAMMAR)
$(B $(ID MangledName) MangledName):
    $(B _D) [#QualifiedName|QualifiedName] [#Type|Type]
    $(B _D) [#QualifiedName|QualifiedName] $(B Z)        // Internal

)

    The [#Type|Type] above is the type of a variable or the return type of a function.
    This is never a [#TypeFunction|TypeFunction], as the latter can only be bound to a value via a pointer
    to a function or a delegate.

$(PRE $(CLASS GRAMMAR)
$(B $(ID QualifiedName) QualifiedName):
    [#SymbolFunctionName|SymbolFunctionName]
    [#SymbolFunctionName|SymbolFunctionName] QualifiedName

$(B $(ID SymbolFunctionName) SymbolFunctionName):
    [#SymbolName|SymbolName]
    [#SymbolName|SymbolName] [#TypeFunctionNoReturn|TypeFunctionNoReturn]
    [#SymbolName|SymbolName] $(B M) [#TypeModifiers|TypeModifiers]$(SUBSCRIPT opt) [#TypeFunctionNoReturn|TypeFunctionNoReturn]

)

    The $(B M) means that the symbol is a function that requires
    a `this` pointer. Class or struct fields are mangled without $(B M).
    To disambiguate $(B M) from being a [#Parameter|Parameter] with modifier `scope`, the
    following type needs to be checked for being a [#TypeFunction|TypeFunction].

$(PRE $(CLASS GRAMMAR)
$(B $(ID SymbolName) SymbolName):
    [#LName|LName]
    [#TemplateInstanceName|TemplateInstanceName]
    [#IdentifierBackRef|IdentifierBackRef]
    $(B 0)                         // anonymous symbols

)

        Template Instance Names have the types and values of its parameters
        encoded into it:
        

$(PRE $(CLASS GRAMMAR)
$(B $(ID TemplateInstanceName) TemplateInstanceName):
    [#TemplateID|TemplateID] [#LName|LName] [#TemplateArgs|TemplateArgs] $(B Z)

$(B $(ID TemplateID) TemplateID):
    $(B __T)
    $(B __U)        // for symbols declared inside template constraint

$(B $(ID TemplateArgs) TemplateArgs):
    [#TemplateArg|TemplateArg]
    [#TemplateArg|TemplateArg] TemplateArgs

$(B $(ID TemplateArg) TemplateArg):
    [#TemplateArgX|TemplateArgX]
    $(B H) [#TemplateArgX|TemplateArgX]

)

    If a template argument matches a specialized template parameter, the argument
    is mangled with prefix $(B H).

$(PRE $(CLASS GRAMMAR)
$(B $(ID TemplateArgX) TemplateArgX):
    $(B T) [#Type|Type]
    $(B V) [#Type|Type] [#Value|Value]
    $(B S) [#QualifiedName|QualifiedName]
    $(B X) [#Number|Number] $(I ExternallyMangledName)

)

    $(I ExternallyMangledName) can be any series of characters allowed on the
    current platform, e.g. generated by functions with C++ linkage or annotated
    with `pragma(mangle,...)`.

$(PRE $(CLASS GRAMMAR)
$(B $(ID Values) Values):
    [#Value|Value]
    [#Value|Value] Values

$(B $(ID Value) Value):
    $(B n)
    $(B i) [#Number|Number]
    $(B N) [#Number|Number]
    $(B e) [#HexFloat|HexFloat]
    $(B c) [#HexFloat|HexFloat] $(B c) [#HexFloat|HexFloat]
    [#CharWidth|CharWidth] [#Number|Number] $(B _) [#HexDigits|HexDigits]
    $(B A) [#Number|Number] [#Values|Values]
    $(B S) [#Number|Number] [#Values|Values]
    $(B f) [#MangledName|MangledName]

$(B $(ID HexFloat) HexFloat):
    $(B NAN)
    $(B INF)
    $(B NINF)
    $(B N) [#HexDigits|HexDigits] $(B P) [#Exponent|Exponent]
    [#HexDigits|HexDigits] $(B P) [#Exponent|Exponent]

$(B $(ID Exponent) Exponent):
    $(B N) [#Number|Number]
    [#Number|Number]

$(B $(ID HexDigits) HexDigits):
    [#HexDigit|HexDigit]
    [#HexDigit|HexDigit] [#HexDigits|HexDigits]

$(B $(ID HexDigit) HexDigit):
    [#Digit|Digit]
    $(B A)
    $(B B)
    $(B C)
    $(B D)
    $(B E)
    $(B F)

$(B $(ID CharWidth) CharWidth):
    $(B a)
    $(B w)
    $(B d)

)

    $(DL             $(DT $(B n))
            $(DD is for $(B null) arguments.)

            $(DT $(B i) [#Number|Number])
            $(DD is for positive numeric literals (including
            character literals).)

            $(DT $(B N) [#Number|Number])
            $(DD is for negative numeric literals.)

            $(DT $(B e) [#HexFloat|HexFloat])
            $(DD is for real and imaginary floating point literals.)

            $(DT $(B c) [#HexFloat|HexFloat] $(B c) [#HexFloat|HexFloat])
            $(DD is for complex floating point literals.)

            $(DT [#CharWidth|CharWidth] [#Number|Number] `_` [#HexDigits|HexDigits])
            $(DD [#CharWidth|CharWidth] is whether the characters
            are 1 byte ($(B a)), 2 bytes ($(B w)) or 4 bytes ($(B d)) in size.
            [#Number|Number] is the number of characters in the string.
            The [#HexDigits|HexDigits] are the hex data for the string.
            )

            $(DT $(B A) [#Number|Number] [#Values|Values])
            $(DD An array or asssociative array literal.
            [#Number|Number] is the length of the array.
            [#Value|Value] is repeated [#Number|Number] times for a normal array,
            and 2 * [#Number|Number] times for an associative array.
            )

            $(DT $(B S) [#Number|Number] [#Values|Values])
            $(DD A struct literal. [#Value|Value] is repeated [#Number|Number] times.
            )
    )

$(PRE $(CLASS GRAMMAR)
$(B $(ID Name) Name):
    [#Namestart|Namestart]
    [#Namestart|Namestart] [#Namechars|Namechars]

$(B $(ID Namestart) Namestart):
    $(B _)
    $(I Alpha)

$(B $(ID Namechar) Namechar):
    [#Namestart|Namestart]
    [#Digit|Digit]

$(B $(ID Namechars) Namechars):
    [#Namechar|Namechar]
    [#Namechar|Namechar] Namechars

)

        A [#Name|Name] is a standard D $(LINK2 spec/lex#identifiers,identifier).

$(PRE $(CLASS GRAMMAR)
$(B $(ID LName) LName):
    [#Number|Number] [#Name|Name]
    [#Number|Number] $(B __S) [#Number|Number]    // function-local parent symbols

$(B $(ID Number) Number):
    [#Digit|Digit]
    [#Digit|Digit] Number

$(B $(ID Digit) Digit):
    $(B 0)
    $(B 1)
    $(B 2)
    $(B 3)
    $(B 4)
    $(B 5)
    $(B 6)
    $(B 7)
    $(B 8)
    $(B 9)

)

        An [#LName|LName] is a name preceded by a [#Number|Number] giving
        the number of characters in the [#Name|Name].
        

$(H3 $(ID back_ref) Back references)

    Any [#LName|LName] or non-basic [#Type|Type] (i.e. any type
    that does not encode as a fixed one or two character sequence) that has been
    emitted to the mangled symbol before will not be emitted again, but is referenced
    by a special sequence encoding the relative position of the original occurrence in the mangled
    symbol name.

    Numbers in back references are encoded with base 26 by upper case letters $(B A) - $(B Z) for higher digits
    but lower case letters $(B a) - $(B z) for the last digit.

$(PRE $(CLASS GRAMMAR)
$(B $(ID TypeBackRef) TypeBackRef):
    $(B Q) [#NumberBackRef|NumberBackRef]

$(B $(ID IdentifierBackRef) IdentifierBackRef):
    $(B Q) [#NumberBackRef|NumberBackRef]

$(B $(ID NumberBackRef) NumberBackRef):
    $(I lower-case-letter)
    $(I upper-case-letter) [#NumberBackRef|NumberBackRef]

)

    To distinguish between the type of the back reference a look-up of the back referenced character is necessary:
    An identifier back reference always points to a digit $(B 0) to $(B 9), while a type back reference always points
    to a letter.

$(H3 $(ID type_mangling) Type Mangling)

        Types are mangled using a simple linear scheme:

$(PRE $(CLASS GRAMMAR)
$(B $(ID Type) Type):
    [#TypeModifiers|TypeModifiers]$(SUBSCRIPT opt) [#TypeX|TypeX]
    [#TypeBackRef|TypeBackRef]

$(B $(ID TypeX) TypeX):
    [#TypeArray|TypeArray]
    [#TypeStaticArray|TypeStaticArray]
    [#TypeAssocArray|TypeAssocArray]
    [#TypePointer|TypePointer]
    [#TypeFunction|TypeFunction]
    [#TypeIdent|TypeIdent]
    [#TypeClass|TypeClass]
    [#TypeStruct|TypeStruct]
    [#TypeEnum|TypeEnum]
    [#TypeTypedef|TypeTypedef]
    [#TypeDelegate|TypeDelegate]
    [#TypeVoid|TypeVoid]
    [#TypeByte|TypeByte]
    [#TypeUbyte|TypeUbyte]
    [#TypeShort|TypeShort]
    [#TypeUshort|TypeUshort]
    [#TypeInt|TypeInt]
    [#TypeUint|TypeUint]
    [#TypeLong|TypeLong]
    [#TypeUlong|TypeUlong]
    [#TypeCent|TypeCent]
    [#TypeUcent|TypeUcent]
    [#TypeFloat|TypeFloat]
    [#TypeDouble|TypeDouble]
    [#TypeReal|TypeReal]
    [#TypeIfloat|TypeIfloat]
    [#TypeIdouble|TypeIdouble]
    [#TypeIreal|TypeIreal]
    [#TypeCfloat|TypeCfloat]
    [#TypeCdouble|TypeCdouble]
    [#TypeCreal|TypeCreal]
    [#TypeBool|TypeBool]
    [#TypeChar|TypeChar]
    [#TypeWchar|TypeWchar]
    [#TypeDchar|TypeDchar]
    [#TypeNoreturn|TypeNoreturn]
    [#TypeNull|TypeNull]
    [#TypeTuple|TypeTuple]
    [#TypeVector|TypeVector]

$(B $(ID TypeModifiers) TypeModifiers):
    [#Const|Const]
    [#Wild|Wild]
    [#Wild|Wild] [#Const|Const]
    [#Shared|Shared]
    [#Shared|Shared] [#Const|Const]
    [#Shared|Shared] [#Wild|Wild]
    [#Shared|Shared] [#Wild|Wild] [#Const|Const]
    [#Immutable|Immutable]

$(B $(ID Shared) Shared):
    $(B O)

$(B $(ID Const) Const):
    $(B x)

$(B $(ID Immutable) Immutable):
    $(B y)

$(B $(ID Wild) Wild):
    $(B Ng)

$(B $(ID TypeArray) TypeArray):
    $(B A) [#Type|Type]

$(B $(ID TypeStaticArray) TypeStaticArray):
    $(B G) [#Number|Number] [#Type|Type]

$(B $(ID TypeAssocArray) TypeAssocArray):
    $(B H) [#Type|Type] [#Type|Type]

$(B $(ID TypePointer) TypePointer):
    $(B P) [#Type|Type]

$(B $(ID TypeVector) TypeVector):
    $(B Nh) [#Type|Type]

$(B $(ID TypeFunction) TypeFunction):
    [#TypeFunctionNoReturn|TypeFunctionNoReturn] [#Type|Type]

$(B $(ID TypeFunctionNoReturn) TypeFunctionNoReturn):
    [#CallConvention|CallConvention] [#FuncAttrs|FuncAttrs]$(SUBSCRIPT opt) [#Parameters|Parameters]$(SUBSCRIPT opt) [#ParamClose|ParamClose]

$(B $(ID CallConvention) CallConvention):
    $(B F)       // D
    $(B U)       // C
    $(B W)       // Windows
    $(B R)       // C++
    $(B Y)       // Objective-C

$(B $(ID FuncAttrs) FuncAttrs):
    [#FuncAttr|FuncAttr]
    [#FuncAttr|FuncAttr] FuncAttrs

$(B $(ID FuncAttr) FuncAttr):
    [#FuncAttrPure|FuncAttrPure]
    [#FuncAttrNothrow|FuncAttrNothrow]
    [#FuncAttrRef|FuncAttrRef]
    [#FuncAttrProperty|FuncAttrProperty]
    [#FuncAttrNogc|FuncAttrNogc]
    [#FuncAttrReturn|FuncAttrReturn]
    [#FuncAttrScope|FuncAttrScope]
    [#FuncAttrTrusted|FuncAttrTrusted]
    [#FuncAttrSafe|FuncAttrSafe]
    [#FuncAttrLive|FuncAttrLive]

)

    Function attributes are emitted in the order as listed above, with the exception of `return` and `scope`.
    `return` comes before `scope` when `this` is a $(LINK2 spec/function#return-scope-parameters,`return scope`) parameter,
    and after `scope` when `this` is a $(LINK2 spec/function#scope-parameters,`scope`) and $(LINK2 spec/function#return-ref-parameters,`return ref`) parameter.
    

$(PRE $(CLASS GRAMMAR)
$(B $(ID FuncAttrPure) FuncAttrPure):
    $(B Na)

$(B $(ID FuncAttrNogc) FuncAttrNogc):
    $(B Ni)

$(B $(ID FuncAttrNothrow) FuncAttrNothrow):
    $(B Nb)

$(B $(ID FuncAttrProperty) FuncAttrProperty):
    $(B Nd)

$(B $(ID FuncAttrRef) FuncAttrRef):
    $(B Nc)

$(B $(ID FuncAttrReturn) FuncAttrReturn):
    $(B Nj)

$(B $(ID FuncAttrScope) FuncAttrScope):
    $(B Nl)

$(B $(ID FuncAttrTrusted) FuncAttrTrusted):
    $(B Ne)

$(B $(ID FuncAttrSafe) FuncAttrSafe):
    $(B Nf)

$(B $(ID FuncAttrLive) FuncAttrLive):
    $(B Nm)

$(B $(ID Parameters) Parameters):
    [#Parameter|Parameter]
    [#Parameter|Parameter] Parameters

$(B $(ID Parameter) Parameter):
    [#Parameter2|Parameter2]
    $(B M) [#Parameter2|Parameter2]     // scope
    $(B Nk) [#Parameter2|Parameter2]    // return

$(B $(ID Parameter2) Parameter2):
    [#Type|Type]
    $(B I) [#Type|Type]     // in
    $(B J) [#Type|Type]     // out
    $(B K) [#Type|Type]     // ref
    $(B L) [#Type|Type]     // lazy

$(B $(ID ParamClose) ParamClose):
    $(B X)     // variadic T t...) style
    $(B Y)     // variadic T t,...) style
    $(B Z)     // not variadic

$(B $(ID TypeIdent) TypeIdent):
    $(B I) [#QualifiedName|QualifiedName]

$(B $(ID TypeClass) TypeClass):
    $(B C) [#QualifiedName|QualifiedName]

$(B $(ID TypeStruct) TypeStruct):
    $(B S) [#QualifiedName|QualifiedName]

$(B $(ID TypeEnum) TypeEnum):
    $(B E) [#QualifiedName|QualifiedName]

$(B $(ID TypeTypedef) TypeTypedef):
    $(B T) [#QualifiedName|QualifiedName]

$(B $(ID TypeDelegate) TypeDelegate):
    $(B D) [#TypeModifiers|TypeModifiers]$(SUBSCRIPT opt) [#TypeFunction|TypeFunction]

$(B $(ID TypeVoid) TypeVoid):
    $(B v)

$(B $(ID TypeByte) TypeByte):
    $(B g)

$(B $(ID TypeUbyte) TypeUbyte):
    $(B h)

$(B $(ID TypeShort) TypeShort):
    $(B s)

$(B $(ID TypeUshort) TypeUshort):
    $(B t)

$(B $(ID TypeInt) TypeInt):
    $(B i)

$(B $(ID TypeUint) TypeUint):
    $(B k)

$(B $(ID TypeLong) TypeLong):
    $(B l)

$(B $(ID TypeUlong) TypeUlong):
    $(B m)

$(B $(ID TypeCent) TypeCent):
    $(B zi)

$(B $(ID TypeUcent) TypeUcent):
    $(B zk)

$(B $(ID TypeFloat) TypeFloat):
    $(B f)

$(B $(ID TypeDouble) TypeDouble):
    $(B d)

$(B $(ID TypeReal) TypeReal):
    $(B e)

$(B $(ID TypeIfloat) TypeIfloat):
    $(B o)

$(B $(ID TypeIdouble) TypeIdouble):
    $(B p)

$(B $(ID TypeIreal) TypeIreal):
    $(B j)

$(B $(ID TypeCfloat) TypeCfloat):
    $(B q)

$(B $(ID TypeCdouble) TypeCdouble):
    $(B r)

$(B $(ID TypeCreal) TypeCreal):
    $(B c)

$(B $(ID TypeBool) TypeBool):
    $(B b)

$(B $(ID TypeChar) TypeChar):
    $(B a)

$(B $(ID TypeWchar) TypeWchar):
    $(B u)

$(B $(ID TypeDchar) TypeDchar):
    $(B w)

$(B $(ID TypeNoreturn) TypeNoreturn):
    $(B Nn)

$(B $(ID TypeNull) TypeNull):
    $(B n)

$(B $(ID TypeTuple) TypeTuple):
    $(B B) [#Parameters|Parameters] $(B Z)

)

$(H2 $(ID function_calling_conventions) Function Calling Conventions)

        The `extern (C)` and `extern (D)` calling convention matches the C
        calling convention
        used by the supported C compiler on the host system.
        Except that the extern (D) calling convention for Windows x86 is described here.
        

$(H3 $(ID register_conventions) Register Conventions)

        $(LIST

        * EAX, ECX, EDX are scratch registers and can be destroyed
        by a function.

        * EBX, ESI, EDI, EBP must be preserved across function calls.

        * EFLAGS is assumed destroyed across function calls, except
        for the direction flag which must be forward.

        * The FPU stack must be empty when calling a function.

        * The FPU control word must be preserved across function calls.

        * Floating point return values are returned on the FPU stack.
        These must be cleaned off by the caller, even if they are not used.

        
)

$(H3 $(ID return_value) Return Value)

        $(LIST

        * The types bool, byte, ubyte, short, ushort, int, uint,
        pointer, Object, and interfaces
        are returned in EAX.

        * long and ulong
        are returned in EDX,EAX, where EDX gets the most significant
        half.

        * float, double, real, ifloat, idouble, ireal are returned
        in ST0.

        * cfloat, cdouble, creal are returned in ST1,ST0 where ST1
        is the real part and ST0 is the imaginary part.

        * Dynamic arrays are returned with the pointer in EDX
        and the length in EAX.

        * Associative arrays are returned in EAX.

        * References are returned as pointers in EAX.

        * Delegates are returned with the pointer to the function
        in EDX and the context pointer in EAX.

        * 1, 2 and 4 byte structs and static arrays are returned in EAX.

        * 8 byte structs and static arrays are returned in EDX,EAX, where
        EDX gets the most significant half.

        * For other sized structs and static arrays,
        the return value is stored through a hidden pointer passed as
        an argument to the function.

        * Constructors return the this pointer in EAX.

        
)

$(H3 $(ID parameters) Parameters)

        The parameters to the non-variadic function:

---
foo(a1, a2, ..., an);

---

        are passed as follows:

        $(TABLE         <tr><td>a1</td></tr>
        <tr><td>a2</td></tr>
        <tr><td>...</td></tr>
        <tr><td>an</td></tr>
        <tr><td>hidden</td></tr>
        <tr><td>this</td></tr>
        )

        where $(I hidden) is present if needed to return a struct
        value, and $(I this) is present if needed as the this pointer
        for a member function or the context pointer for a nested
        function.

        The last parameter is passed in EAX rather than being pushed
        on the stack if the following conditions are met:

        $(LIST
        * It fits in EAX.
        * It is not a 3 byte struct.
        * It is not a floating point type.
        
)

        Parameters are always pushed as multiples of 4 bytes,
        rounding upwards,
        so the stack is always aligned on 4 byte boundaries.
        They are pushed most significant first.
        $(B out) and $(B ref) are passed as pointers.
        Static arrays are passed as pointers to their first element.
        On Windows, a real is pushed as a 10 byte quantity,
        a creal is pushed as a 20 byte quantity.
        On Linux, a real is pushed as a 12 byte quantity,
        a creal is pushed as two 12 byte quantities.
        The extra two bytes of pad occupy the 'most significant' position.
        

        The callee cleans the stack.

        The parameters to the variadic function:

---
void foo(int p1, int p2, int[] p3...)
foo(a1, a2, ..., an);

---

        are passed as follows:

        $(TABLE         <tr><td>p1</td></tr>
        <tr><td>p2</td></tr>
        <tr><td>a3</td></tr>
        <tr><td>hidden</td></tr>
        <tr><td>this</td></tr>
        )

        The variadic part is converted to a dynamic array and the
        rest is the same as for non-variadic functions.

        The parameters to the variadic function:

---
void foo(int p1, int p2, ...)
foo(a1, a2, a3, ..., an);

---

        are passed as follows:

        $(TABLE         <tr><td>an</td></tr>
        <tr><td>...</td></tr>
        <tr><td>a3</td></tr>
        <tr><td>a2</td></tr>
        <tr><td>a1</td></tr>
        <tr><td>`_`arguments</td></tr>
        <tr><td>hidden</td></tr>
        <tr><td>this</td></tr>
        )

        The caller is expected to clean the stack.
        `_argptr` is not
        passed, it is computed by the callee.

$(H2 $(ID exception_handling) Exception Handling)

    $(H3 $(ID windows_eh) Windows 32 bit)

        Conforms to the Microsoft Windows Structured Exception Handling
        conventions.
        

    $(H3 $(ID ninux_fbsd_osx_eh) Linux, FreeBSD and OS X)

    Conforms to the DWARF (debugging with attributed record
    formats) Exception Handling conventions.
        

    $(H3 $(ID win64_eh) Windows 64 bit)

        Uses static address range/handler tables.
        It is not compatible with the MSVC x64 exception handling tables.
        The stack is walked assuming it uses the EBP/RBP stack frame
        convention. The EBP/RBP convention must be used for every
        function that has an associated EH (Exception Handler) table.
        

        For each function that has exception handlers,
        an EH table entry is generated.
        

        $(TABLE_ROWS
EH Table Entry
        * + field
+ description

        * - `void*`
- pointer to start of function

        * - `DHandlerTable*`
- pointer to corresponding EH data

        * - `uint`
- size in bytes of the function

        
)

        The EH table entries are placed into the following special
        segments, which are concatenated by the linker.
        

        $(TABLE_ROWS
EH Table Segment
        * + Operating System
+ Segment Name

        * - Win32
- `FI`

        * - Win64
- `._deh$B`

        * - Linux
- `.deh_eh`

        * - FreeBSD
- `.deh_eh`

        * - OS X
- `__deh_eh`, `__DATA`

        
)
        <br>

        The rest of the EH data can be placed anywhere,
        it is immutable.

        $(TABLE_ROWS
DHandlerTable
        * + field
+ description

        * - `void*`
- pointer to start of function

        * - `uint`
- offset of ESP/RSP from EBP/RBP

        * - `uint`
- offset from start of function to return code

        * - `uint`
- number of entries in `DHandlerInfo[]`

        * - `DHandlerInfo[]`
- array of handler information

        
)
        <br>

        $(TABLE_ROWS
DHandlerInfo
        * + field
+ description

        * - `uint`
- offset from function address to start of guarded section

        * - `uint`
- offset of end of guarded section

        * - `int`
- previous table index

        * - `uint`
- if != 0 offset to DCatchInfo data from start of table

        * - `void*`
- if not null, pointer to finally code to execute

        
)
        <br>

        $(TABLE_ROWS
DCatchInfo
        * + field
+ description

        * - `uint`
- number of entries in `DCatchBlock[]`

        * - `DCatchBlock[]`
- array of catch information

        
)
        <br>

        $(TABLE_ROWS
DCatchBlock
        * + field
+ description

        * - `ClassInfo`
- catch type

        * - `uint`
- offset from EBP/RBP to catch variable

        <tr>`void*`, catch handler code</tr>
        
)

$(H2 $(ID garbage_collection) Garbage Collection)

        The interface to this is found in Druntime's core/gc/gcinterface.d.

$(H2 $(ID ModuleInfo) ModuleInfo Instance)

        An instance of $(LINK2 https://dlang.org/phobos/object.html#.ModuleInfo, `ModuleInfo`)
        is generated by the compiler and inserted into the object file for every module.
        `ModuleInfo` contains information about the module that is useful to the D runtime library:
        

        $(LIST
        * If the module has a static constructor, static destructor, shared static constructor, or shared static destructor.
        * A reference to any unit tests defined by the module.
        * An array of references to any imported modules that have one or more of:
            $(NUMBERED_LIST
            * static constructors
            * static destructors
            * shared static constructors
            * shared static destructors
            * unit tests
            * transitive imports of any module that contains one or more of 1..5
            * order independent constructors (currently needed for implementing
            $(LINK2 dmd#switch-cov,$(TT -cov)))
            
)
            This enables the runtime to run the unit tests,
            the module constructors in a depth-first order,
            and the module destructors in the reverse order.
        

        * An array of references to `ClassInfo` for each class defined in the module.
        Note: this feature may be removed.
        
)

        `ModuleInfo` is defined in Druntime's object.d, which must match the compiler's output in both the values of flags and layout of fields.

        Modules compiled with $(LINK2 dmd#switch-betterC,$(TT -betterC))
        do not have a `ModuleInfo` instance generated, because such modules must work
        without the D runtime library.
        Similarly, $(LINK2 spec/importc, ImportC) modules do not generate a `ModuleInfo`.
        

$(H3 $(ID module_init_and_fina) Module Initialization and Termination)

        All the static constructors for a module are aggregated into a
        single function, and a pointer to that function is inserted
        into the ctor member of the `ModuleInfo` instance for that
        module.
        

        All the static destructors for a module are aggregated into a
        single function, and a pointer to that function is inserted
        into the dtor member of the `ModuleInfo` instance for that
        module.
        

$(H3 $(ID unit_testing) Unit Testing)

        All the unit tests for a module are aggregated into a
        single function, and a pointer to that function is inserted
        into the unitTest member of the `ModuleInfo` instance for that
        module.
        

$(H2 $(ID runtime_helper_functions) Runtime Helper Functions)

        These are found in Druntime's rt/.

$(H2 $(ID symbolic_debugging) Symbolic Debugging)

        D has types that are not represented in existing C or C++ debuggers.
        These are dynamic arrays, associative arrays, and delegates.
        Representing these types as structs causes problems because function
        calling conventions for structs are often different than that for
        these types, which causes C/C++ debuggers to misrepresent things.
        For these debuggers, they are represented as a C type which
        does match the calling conventions for the type.
        

        $(TABLE_ROWS
Types for C Debuggers
        * + D type
+ C representation

        * - dynamic array
- `unsigned long long`

        * - associative array
- `void*`

        * - delegate
- `long long`

        * - `dchar`
- `unsigned long`

        
)

        For debuggers that can be modified to accept new types, the
        following extensions help them fully support the types.
        

$(H3 $(ID codeview) Codeview Debugger Extensions)

        The D $(B dchar) type is represented by the special
        primitive type 0x78.

        D makes use of the Codeview OEM generic type record
        indicated by `LF_OEM` (0x0015). The format is:

        $(TABLE_ROWS
Codeview OEM Extensions for D
        * - field size
- 2
- 2
- 2
- 2
- 2
- 2

        * + D Type
+ Leaf Index
+ OEM Identifier
+ recOEM
+ num indices
+         type index
+ type index

        * - dynamic array
- `LF_OEM`
- $(I OEM)
- 1
- 2
- @$(I index)
- @$(I element)

        * - associative array
- `LF_OEM`
- $(I OEM)
- 2
- 2
- @$(I key)
- @$(I element)

        * - delegate
- `LF_OEM`
- $(I OEM)
- 3
- 2
- @$(I this)
- @$(I function)

)

        where:

        $(TABLE_ROWS

        * - $(I OEM)
- 0x42

        * - $(I index)
- type index of array index

        * - $(I key)
- type index of key

        * - $(I element)
- type index of array element

        * - $(I this)
- type index of context pointer

        * - $(I function)
- type index of function

)

        These extensions can be pretty-printed
        by $(LINK2 http://www.digitalmars.com/ctg/obj2asm.html, obj2asm). The $(LINK2 http://ddbg.mainia.de/releases.html, Ddbg) debugger
        supports them.
memory-safe-d, Memory Safety, simd, Vector Extensions




Link_References:
	ACC = Associated C Compiler
+/
module abi.dd;