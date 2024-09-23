// just docs: Vector Extensions
/++





        CPUs often support specialized vector types and vector
        operations (a.k.a. $(I media instructions)).
        Vector types are a fixed array of floating or integer types, and
        vector operations operate simultaneously on them.

        Specialized [type#Vector|type, Vector] types provide access to them.

        The [type#VectorBaseType|type, VectorBaseType] must be a $(LINK2 spec/arrays#static-arrays,Static Array).
        The $(B $(ID VectorElementType) VectorElementType) is the unqualified element type of the
        static array.
        The dimension of the static array is the number
        of elements in the vector.
        

        $(WARNING Which vector types are supported depends
        on the target. The implementation is expected to only support
        the vector types and operations that are implemented in the target's hardware.
        )

        Rationale: Emulating unsupported vector types and operations can exhibit
        such poor performance that the user is likely better off selecting a different
        algorithm than relying on emulation.

        $(TIP Use the declarations in $(LINK2 phobos/core_simd.html, `core.simd`) instead of
        the language [type#Vector|type, Vector] grammar.
        )

$(H2 $(ID core_simd) `core.simd`)

        Vector types and operations are introduced by importing
        $(LINK2 phobos/core_simd.html, `core.simd`):

---
import core.simd;

---

        $(WARNING         These types and operations will be the ones defined for the architecture
        the compiler is targeting. If a particular CPU family has varying
        support for vector types, an additional runtime check may be necessary.
        The compiler does not emit runtime checks; those must be done by the
        programmer.
        )

        $(WARNING Depending on the target architecture, compiler flags
        may be required to
        activate support for SIMD types.
        )

        The types defined will all follow the naming convention:

$(PRE $(CLASS GRAMMAR_INFORMATIVE)$(I typeNN)
)
        where $(I type) is the vector element type and $(I NN) is the number
        of those elements in the vector type.
        The type names will not be keywords.

$(H3 $(ID properties) Properties)

        Vector types have the property:

        $(TABLE_ROWS
Vector Type Properties
        * + Property
+ Description

        * - .array
- Returns static array representation

        
)

        Vectors support the following properties based
        on the vector element type.
        The value produced is that of a
        vector of the same type with each element set to the
        value corresponding to the property value for the element
        type.

        $(TABLE_ROWS
Integral Vector Type Properties
        * + Property
+ Description

        * - .min
- minimum value

        * - .max
- maximum value

        
)

        $(TABLE_ROWS
Floating Point Vector Type Properties
        * + Property
+ Description

        * - .epsilon
- smallest increment to the value 1

        * - .infinity
- infinity value

        * - .max
- largest representable value that is not infinity

        * - .min_normal
- smallest representable value that is not 0

        * - .nan
- NaN value

        
)

$(H3 $(ID conversions) Conversions)

        Vector types of the same size (number_of_elements * size_of_element)
        can be implicitly converted among
        each other, this is done as a reinterpret cast (a type paint).
        Vector types can be cast to their [type#VectorBaseType|type, VectorBaseType].

        Integers and floating point values can be implicitly converted
        to their vector equivalents:

---
int4 v = 7;
v = 3 + v;   // add 3 to each element in v

---

$(H3 $(ID accessing_individual_elems) Accessing Individual Vector Elements)

        They cannot be accessed directly, but can be when converted to
        an array type:

---
int4 v;
(cast(int*)&amp;v)[3] = 2;   // set 3rd element of the 4 int vector
(cast(int[4])v)[3] = 2;  // set 3rd element of the 4 int vector
v.array[3] = 2;          // set 3rd element of the 4 int vector
v.ptr[3] = 2;            // set 3rd element of the 4 int vector

---


$(H3 $(ID conditional_compilation) Conditional Compilation)

        If vector extensions are implemented, the
        $(LINK2 spec/version#PredefinedVersions,version identifier)
        `D_SIMD` is set.

        Whether a type exists or not can be tested at compile time with
        an $(LINK2 spec/expression#IsExpression,$(I IsExpression)):
        

---
static if (is(typeNN))
    ... yes, it is supported ...
else
    ... nope, use workaround ...

---

        Whether a particular operation on a type is supported can be tested
        at compile time with:
        

---
float4 a,b;
static if (__traits(compiles, a+b))
    ... yes, add is supported for float4 ...
else
    ... nope, use workaround ...

---

        For runtime testing to see if certain vector instructions are
        available, see the functions in
        $(LINK2 phobos/core_cpuid.html, core.cpuid).
        

        A typical workaround for unsupported vector operations would be to
        use array operations instead:

---
float4 a,b;
static if (__traits(compiles, a/b))
    c = a / b;
else
    c[] = a[] / b[];

---

$(H2 $(ID x86_64_vec) X86 And X86_64 Vector Extension Implementation)

    $(WARNING 
        The following describes the specific implementation of the
        vector types for the X86 and X86_64 architectures.
        

        The vector extensions are currently implemented for the OS X 32
        bit target, and all 64 bit targets.

        $(LINK2 phobos/core_simd.html, `core.simd`) defines the following types: 

        $(TABLE_ROWS
Vector Types
        * + Type Name
+ Description
+ gcc Equivalent

        * - void16
- 16 bytes of untyped data
- $(I no equivalent)

        * - byte16
- 16 `byte`s
- `signed char __attribute__((vector_size(16)))`

        * - ubyte16
- 16 `ubyte`s
- `unsigned char __attribute__((vector_size(16)))`

        * - short8
- 8 `short`s
- `short __attribute__((vector_size(16)))`

        * - ushort8
- 8 `ushort`s
- `ushort __attribute__((vector_size(16)))`

        * - int4
- 4 `int`s
- `int __attribute__((vector_size(16)))`

        * - uint4
- 4 `uint`s
- `unsigned __attribute__((vector_size(16)))`

        * - long2
- 2 `long`s
- `long __attribute__((vector_size(16)))`

        * - ulong2
- 2 `ulong`s
- `unsigned long __attribute__((vector_size(16)))`

        * - float4
- 4 `float`s
- `float __attribute__((vector_size(16)))`

        * - double2
- 2 `double`s
- `double __attribute__((vector_size(16)))`

        * - void32
- 32 bytes of untyped data
- $(I no equivalent)

        * - byte32
- 32 `byte`s
- `signed char __attribute__((vector_size(32)))`

        * - ubyte32
- 32 `ubyte`s
- `unsigned char __attribute__((vector_size(32)))`

        * - short16
- 16 `short`s
- `short __attribute__((vector_size(32)))`

        * - ushort16
- 16 `ushort`s
- `ushort __attribute__((vector_size(32)))`

        * - int8
- 8 `int`s
- `int __attribute__((vector_size(32)))`

        * - uint8
- 8 `uint`s
- `unsigned __attribute__((vector_size(32)))`

        * - long4
- 4 `long`s
- `long __attribute__((vector_size(32)))`

        * - ulong4
- 4 `ulong`s
- `unsigned long __attribute__((vector_size(32)))`

        * - float8
- 8 `float`s
- `float __attribute__((vector_size(32)))`

        * - double4
- 4 `double`s
- `double __attribute__((vector_size(32)))`

        
)

        Note: for 32 bit gcc and clang, it's `long long` instead of `long`.

        $(TABLE_ROWS
Supported 128-bit Vector Operators
        * + Operator
+ void16
+ byte16
+ ubyte16
+ short8
+ ushort8
+ int4
+ uint4
+ long2
+ ulong2
+ float4
+ double2

        * - =
- X
- X
- X
- X
- X
- X
- X
- X
- X
- X
- X

        * - +
- -
- X
- X
- X
- X
- X
- X
- X
- X
- X
- X

        * - -
- -
- X
- X
- X
- X
- X
- X
- X
- X
- X
- X

        * - *
- -
- -
- -
- X
- X
- -
- -
- -
- -
- X
- X

        * - /
- -
- -
- -
- -
- -
- -
- -
- -
- -
- X
- X

        * - &
- -
- X
- X
- X
- X
- X
- X
- X
- X
- -
- -

        * - |
- -
- X
- X
- X
- X
- X
- X
- X
- X
- -
- -

        * - `^`
- -
- X
- X
- X
- X
- X
- X
- X
- X
- -
- -

        * - +=
- -
- X
- X
- X
- X
- X
- X
- X
- X
- X
- X

        * - -=
- -
- X
- X
- X
- X
- X
- X
- X
- X
- X
- X

        * - *=
- -
- -
- -
- X
- X
- -
- -
- -
- -
- X
- X

        * - /=
- -
- -
- -
- -
- -
- -
- -
- -
- -
- X
- X

        * - &=
- -
- X
- X
- X
- X
- X
- X
- X
- X
- -
- -

        * - |=
- -
- X
- X
- X
- X
- X
- X
- X
- X
- -
- -

        * - `^=`
- -
- X
- X
- X
- X
- X
- X
- X
- X
- -
- -

        * - ==
- -
- X
- X
- X
- X
- X
- X
- X
- X
- X
- X

        * - !=
- -
- X
- X
- X
- X
- X
- X
- X
- X
- X
- X

        * - &lt;
- -
- X
- X
- X
- X
- X
- X
- X
- X
- X
- X

        * - &lt;=
- -
- X
- X
- X
- X
- X
- X
- X
- X
- X
- X

        * - &gt;=
- -
- X
- X
- X
- X
- X
- X
- X
- X
- X
- X

        * - &gt;
- -
- X
- X
- X
- X
- X
- X
- X
- X
- X
- X

        * - $(I unary)`~`
- -
- X
- X
- X
- X
- X
- X
- X
- X
- -
- -

        * - $(I unary)+
- -
- X
- X
- X
- X
- X
- X
- X
- X
- X
- X

        * - $(I unary)-
- -
- X
- X
- X
- X
- X
- X
- X
- X
- X
- X

        
)

        $(TABLE_ROWS
Supported 256-bit Vector Operators
        * + Operator
+ void32
+ byte32
+ ubyte32
+ short16
+ ushort16
+ int8
+ uint8
+ long4
+ ulong4
+ float8
+ double4

        * - =
- X
- X
- X
- X
- X
- X
- X
- X
- X
- X
- X

        * - +
- -
- X
- X
- X
- X
- X
- X
- X
- X
- X
- X

        * - -
- -
- X
- X
- X
- X
- X
- X
- X
- X
- X
- X

        * - *
- -
- -
- -
- -
- -
- -
- -
- -
- -
- X
- X

        * - /
- -
- -
- -
- -
- -
- -
- -
- -
- -
- X
- X

        * - &
- -
- X
- X
- X
- X
- X
- X
- X
- X
- -
- -

        * - |
- -
- X
- X
- X
- X
- X
- X
- X
- X
- -
- -

        * - `^`
- -
- X
- X
- X
- X
- X
- X
- X
- X
- -
- -

        * - +=
- -
- X
- X
- X
- X
- X
- X
- X
- X
- X
- X

        * - -=
- -
- X
- X
- X
- X
- X
- X
- X
- X
- X
- X

        * - *=
- -
- -
- -
- -
- -
- -
- -
- -
- -
- X
- X

        * - /=
- -
- -
- -
- -
- -
- -
- -
- -
- -
- X
- X

        * - &=
- -
- X
- X
- X
- X
- X
- X
- X
- X
- -
- -

        * - |=
- -
- X
- X
- X
- X
- X
- X
- X
- X
- -
- -

        * - `^=`
- -
- X
- X
- X
- X
- X
- X
- X
- X
- -
- -

        * - ==
- -
- X
- X
- X
- X
- X
- X
- X
- X
- X
- X

        * - !=
- -
- X
- X
- X
- X
- X
- X
- X
- X
- X
- X

        * - &lt;
- -
- X
- X
- X
- X
- X
- X
- X
- X
- X
- X

        * - &lt;=
- -
- X
- X
- X
- X
- X
- X
- X
- X
- X
- X

        * - &gt;=
- -
- X
- X
- X
- X
- X
- X
- X
- X
- X
- X

        * - &gt;
- -
- X
- X
- X
- X
- X
- X
- X
- X
- X
- X

        * - $(I unary)`~`
- -
- X
- X
- X
- X
- X
- X
- X
- X
- -
- -

        * - $(I unary)+
- -
- X
- X
- X
- X
- X
- X
- X
- X
- X
- X

        * - $(I unary)-
- -
- X
- X
- X
- X
- X
- X
- X
- X
- X
- X

        
)

        Operators not listed are not supported at all.

    )

$(H3 $(ID vector_op_intrinsics) Vector Operation Intrinsics)

        See $(LINK2 phobos/core_simd.html, `core.simd`) for the supported intrinsics.
abi, Application Binary Interface, betterc, Better C




Link_References:
	ACC = Associated C Compiler
+/
module simd.dd;