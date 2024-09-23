// just docs: Floating-Point
/++





$(H2 $(ID fp_intermediate_values) Floating-Point Intermediate Values)

        For floating-point operations and expression intermediate values,
        a greater precision can be used than the type of the
        expression.
        Only the minimum precision is set by the types of the
        operands, not the maximum. $(B Implementation Note:) On Intel
        x86 machines, for example,
        it is expected (but not required) that the intermediate
        calculations be done to the full 80 bits of precision
        implemented by the hardware.
        

        Execution of floating-point expressions may yield a result of greater precision than dictated
        by the source.

$(H2 $(ID fp_const_folding) Floating-Point Constant Folding)

        Regardless of the type of the operands, floating-point
        constant folding is done in `real` or greater precision.
        It is always done following $(LINK2 https://standards.ieee.org/standard/754-2019.html, IEEE-754) rules and round-to-nearest
        is used.

        Floating-point constants are internally represented in
        the implementation in at least `real` precision, regardless
        of the constant's type. The extra precision is available for
        constant folding. Committing to the precision of the result is
        done as late as possible in the compilation process. For example:

---
const float f = 0.2f;
writeln(f - 0.2);

---
        will print 0. A non-const static variable's value cannot be
        propagated at compile time, so:

---
static float f = 0.2f;
writeln(f - 0.2);

---
        will print 2.98023e-09. Hex floating-point constants can also
        be used when specific floating-point bit patterns are needed that
        are unaffected by rounding. To find the hex value of 0.2f:

---
import std.stdio;

void main()
{
    writefln("%a", 0.2f);
}

---
        which is 0x1.99999ap-3. Using the hex constant:

---
const float f = 0x1.99999ap-3f;
writeln(f - 0.2);

---

        prints 2.98023e-09.

        Different compiler settings, optimization settings,
        and inlining settings can affect opportunities for constant
        folding, therefore the results of floating-point calculations may differ
        depending on those settings.

$(H2 $(ID rounding_control) Rounding Control)

        IEEE 754 floating-point arithmetic includes the ability to set 4
        different rounding modes.
        These are accessible via the functions in `core.stdc.fenv`.
        

        If the floating-point rounding mode is changed within a function,
        it must be restored before the function exits. If this rule is violated
        (for example, by the use of inline asm), the rounding mode used for
        subsequent calculations is undefined.
        


$(H2 $(ID exception_flags) Exception Flags)

        IEEE 754 floating-point arithmetic can set several flags based on what
        happened with a
        computation:

        $(TABLE         <tr><td>`FE_INVALID`</td></tr>
        <tr><td>`FE_DENORMAL`</td></tr>
        <tr><td>`FE_DIVBYZERO`</td></tr>
        <tr><td>`FE_OVERFLOW`</td></tr>
        <tr><td>`FE_UNDERFLOW`</td></tr>
        <tr><td>`FE_INEXACT`</td></tr>
        )

        These flags can be set/reset via the functions in `core.stdc.fenv`.

$(H2 $(ID floating-point-transformations) Floating-Point Transformations)

        An implementation may perform transformations on
        floating-point computations in order to reduce their strength.
        

        Not all transformations are valid: The following
        transformations of floating-point expressions
        are not allowed because under IEEE rules they could produce
        different results.
        

        $(TABLE_ROWS
Disallowed Floating-Point Transformations
        * + transformation
+ comments

        * -         $(I x) + 0 -> $(I x) 
- not valid if $(I x) is -0
        

        * -         $(I x) - 0 -> $(I x) 
- not valid if $(I x) is $(PLUSMN)0 and rounding is towards -infinity
        

        * -         -$(I x) <-> 0 - $(I x) 
- not valid if $(I x) is +0
        

        * -         $(I x) - $(I x) -> 0 
- not valid if $(I x) is NaN or $(PLUSMN)infinity
        

        * -         $(I x) - $(I y) <-> -($(I y) - $(I x)) 
- not valid because (1-1=+0) whereas -(1-1)=-0
        

        * -         $(I x) * 0 -> 0 
- not valid if $(I x) is NaN or $(PLUSMN)infinity
        

$(COMMENT         * -         $(I x) * 1 -> $(I x) 
- not valid if $(I x) is a signaling NaN
        

)
        * -         $(I x) / $(I c) <-> $(I x) * (1/$(I c)) 
- valid if (1/$(I c)) yields an e$(I x)act result
        

        * -         $(I x) != $(I x) -> false 
- not valid if $(I x) is a NaN
        

        * -         $(I x) == $(I x) -> true 
- not valid if $(I x) is a NaN
        

        * -         $(I x) !$(I op) $(I y) <-> !($(I x) $(I op) $(I y)) 
- not valid if $(I x) or $(I y) is a NaN
        

        
)

        Of course, transformations that would alter side effects are also
        invalid.

garbage, Garbage Collection, iasm, D x86 Inline Assembler




Link_References:
	ACC = Associated C Compiler
+/
module float.dd;