// just docs: Inline Assembler
/++





    $(HTMLTAG3 a,
      href="http://digitalmars.com/gift/index.html" title="Gift Shop" target="_top",
      $(HTMLTAG3V img, src="images/d5.gif" border="0" align="right" alt="Some Assembly Required" width="284" height="186")
    )

    D, being a systems programming language, provides an inline
        assembler.
        The inline assembler is standardized for D implementations across
        the same CPU family, for example, the Intel Pentium inline assembler
        for a Win32 D compiler will be syntax compatible with the inline
        assembler for Linux running on an Intel Pentium.
    

    Implementations of D on different architectures, however, are
        free to innovate upon the memory model, function call/return conventions,
        argument passing conventions, etc.
    

    This document describes the `x86` and `x86_64` implementations of
        the inline assembler. The inline assembler platform support that a compiler
        provides is indicated by the `D_InlineAsm_X86` and
        `D_InlineAsm_X86_64` version identifiers, respectively.
    

$(H2 $(ID asmstatements) Asm statement)

$(PRE $(CLASS GRAMMAR)
$(B $(ID AsmStatement) AsmStatement):
    `asm` [function#FunctionAttributes|function, FunctionAttributes]$(SUBSCRIPT opt) `{` [#AsmInstructionList|AsmInstructionList]$(SUBSCRIPT opt) `}`

$(B $(ID AsmInstructionList) AsmInstructionList):
    [#AsmInstruction|AsmInstruction] `;`
    [#AsmInstruction|AsmInstruction] `;` AsmInstructionList

)

    Assembler instructions must be located inside an `asm` block.
        Like functions, `asm` statements must be anotated with adequate function attributes to be compatible with the caller.
        Asm statements attributes must be explicitly defined, they are not infered.
    

---
void func1() pure nothrow @safe @nogc
{
    asm pure nothrow @trusted @nogc
    {}
}

void func2() @safe @nogc
{
    asm @nogc // Error: asm statement is assumed to be @system - mark it with '@trusted' if it is not
    {}
}

---

$(H2 $(ID asminstruction) Asm instruction)

$(PRE $(CLASS GRAMMAR)
$(B $(ID AsmInstruction) AsmInstruction):
    $(LINK2 lex#Identifier, Identifier) `:` AsmInstruction
    `align` [#IntegerExpression|IntegerExpression]
    `even`
    `naked`
    `db` [#Operands|Operands]
    `ds` [#Operands|Operands]
    `di` [#Operands|Operands]
    `dl` [#Operands|Operands]
    `df` [#Operands|Operands]
    `dd` [#Operands|Operands]
    `de` [#Operands|Operands]
    `db` $(LINK2 lex#StringLiteral, StringLiteral)
    `ds` $(LINK2 lex#StringLiteral, StringLiteral)
    `di` $(LINK2 lex#StringLiteral, StringLiteral)
    `dl` $(LINK2 lex#StringLiteral, StringLiteral)
    `dw` $(LINK2 lex#StringLiteral, StringLiteral)
    `dq` $(LINK2 lex#StringLiteral, StringLiteral)
    [#Opcode|Opcode]
    [#Opcode|Opcode] [#Operands|Operands]

$(B $(ID Opcode) Opcode):
    $(LINK2 lex#Identifier, Identifier)
    `int`
    `in`
    `out`

$(B $(ID Operands) Operands):
    [#Operand|Operand]
    [#Operand|Operand] `,` Operands

)

$(H2 $(ID labels) Labels)

    Assembler instructions can be labeled just like other statements.
        They can be the target of goto statements.
        For example:
    

---
void *pc;
asm
{
    call L1          ;
  L1:                ;
    pop  EBX         ;
    mov  pc[EBP],EBX ; // pc now points to code at L1
}

---

$(H2 $(ID align) align $(I IntegerExpression))

$(PRE $(CLASS GRAMMAR)
$(B $(ID IntegerExpression) IntegerExpression):
    $(LINK2 lex#IntegerLiteral, IntegerLiteral)
    $(LINK2 lex#Identifier, Identifier)

)

    Causes the assembler to emit NOP instructions to align the next
        assembler instruction on an $(I IntegerExpression) boundary.
        $(I IntegerExpression) must evaluate at compile time to an integer that is
        a power of 2.
    

    Aligning the start of a loop body can sometimes have a dramatic
        effect on the execution speed.
    

$(H2 $(ID even) even)

    Causes the assembler to emit NOP instructions to align the next
        assembler instruction on an even boundary.
    

$(H2 $(ID naked) naked)

    Causes the compiler to not generate the function prolog and epilog
        sequences. This means such is the responsibility of inline
        assembly programmer, and is normally used when the entire function
        is to be written in assembler.
    

$(H2 $(ID raw_data) db)

    These pseudo ops are for inserting raw data directly into
        the code.
        `db` is for bytes,
        `ds` is for 16 bit words,
        `di` is for 32 bit words,
        `dl` is for 64 bit words,
        `df` is for 32 bit floats,
        `dd` is for 64 bit doubles,
        and `de` is for 80 bit extended reals.
        Each can have multiple operands.
        If an operand is a string literal, it is as if there were $(I length)
        operands, where $(I length) is the number of characters in the string.
        One character is used per operand.
        For example:

---
asm
{
    db 5,6,0x83;   // insert bytes 0x05, 0x06, and 0x83 into code
    ds 0x1234;     // insert bytes 0x34, 0x12
    di 0x1234;     // insert bytes 0x34, 0x12, 0x00, 0x00
    dl 0x1234;     // insert bytes 0x34, 0x12, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    df 1.234;      // insert float 1.234
    dd 1.234;      // insert double 1.234
    de 1.234;      // insert real 1.234
    db "abc";      // insert bytes 0x61, 0x62, and 0x63
    ds "abc";      // insert bytes 0x61, 0x00, 0x62, 0x00, 0x63, 0x00
}

---

$(H2 $(ID opcodes) Opcodes)

    A list of supported opcodes is at the end.
    

    The following registers are supported. Register names
        are always in upper case.
    

$(PRE $(CLASS GRAMMAR)
$(B $(ID Register) Register):
    `AL`
    `AH`
    `AX`
    `EAX`

    `BL`
    `BH`
    `BX`
    `EBX`

    `CL`
    `CH`
    `CX`
    `ECX`

    `DL`
    `DH`
    `DX`
    `EDX`

    `BP`
    `EBP`

    `SP`
    `ESP`

    `DI`
    `EDI`

    `SI`
    `ESI`

    `ES`
    `CS`
    `SS`
    `DS`
    `GS`
    `FS`

    `CR0`
    `CR2`
    `CR3`
    `CR4`

    `DR0`
    `DR1`
    `DR2`
    `DR3`
    `DR6`
    `DR7`

    `TR3`
    `TR4`
    `TR5`
    `TR6`
    `TR7`

    `ST`

    `ST(0)`
    `ST(1)`
    `ST(2)`
    `ST(3)`
    `ST(4)`
    `ST(5)`
    `ST(6)`
    `ST(7)`

    `MM0`
    `MM1`
    `MM2`
    `MM3`
    `MM4`
    `MM5`
    `MM6`
    `MM7`

    `XMM0`
    `XMM1`
    `XMM2`
    `XMM3`
    `XMM4`
    `XMM5`
    `XMM6`
    `XMM7`

)

    `x86_64` adds these additional registers.

$(PRE $(CLASS GRAMMAR)
$(B $(ID Register64) Register64):
    `RAX`
    `RBX`
    `RCX`
    `RDX`

    `BPL`
    `RBP`

    `SPL`
    `RSP`

    `DIL`
    `RDI`

    `SIL`
    `RSI`

    `R8B`
    `R8W`
    `R8D`
    `R8`

    `R9B`
    `R9W`
    `R9D`
    `R9`

    `R10B`
    `R10W`
    `R10D`
    `R10`

    `R11B`
    `R11W`
    `R11D`
    `R11`

    `R12B`
    `R12W`
    `R12D`
    `R12`

    `R13B`
    `R13W`
    `R13D`
    `R13`

    `R14B`
    `R14W`
    `R14D`
    `R14`

    `R15B`
    `R15W`
    `R15D`
    `R15`

    `XMM8`
    `XMM9`
    `XMM10`
    `XMM11`
    `XMM12`
    `XMM13`
    `XMM14`
    `XMM15`

    `YMM0`
    `YMM1`
    `YMM2`
    `YMM3`
    `YMM4`
    `YMM5`
    `YMM6`
    `YMM7`

    `YMM8`
    `YMM9`
    `YMM10`
    `YMM11`
    `YMM12`
    `YMM13`
    `YMM14`
    `YMM15`

)

$(H3 $(ID special_cases) Special Cases)

$(DL     $(DT `lock`, `rep`, `repe`, `repne`, `repnz`, `repz`)
    $(DD These prefix instructions do not appear in the same statement
        as the instructions they prefix; they appear in their own statement.
        For example:)

---
asm
{
    rep   ;
    movsb ;
}

---

    $(DT `pause`)
    $(DD This opcode is not supported by the assembler, instead use

---
asm
{
    rep  ;
    nop  ;
}

---

        which produces the same result.
    )

    $(DT `floating point ops`)
    $(DD Use the two operand form of the instruction format;

---
fdiv ST(1);     // wrong
fmul ST;        // wrong
fdiv ST,ST(1);  // right
fmul ST,ST(0);  // right

---
    )
)

$(H2 $(ID operands) Operands)

$(PRE $(CLASS GRAMMAR)
$(B $(ID Operand) Operand):
    [#AsmExp|AsmExp]

$(B $(ID AsmExp) AsmExp):
    [#AsmLogOrExp|AsmLogOrExp]
    [#AsmLogOrExp|AsmLogOrExp] `?` AsmExp `:` AsmExp

$(B $(ID AsmLogOrExp) AsmLogOrExp):
    [#AsmLogAndExp|AsmLogAndExp]
    AsmLogOrExp `||` [#AsmLogAndExp|AsmLogAndExp]

$(B $(ID AsmLogAndExp) AsmLogAndExp):
    [#AsmOrExp|AsmOrExp]
    AsmLogAndExp `&amp;&amp;` [#AsmOrExp|AsmOrExp]

$(B $(ID AsmOrExp) AsmOrExp):
    [#AsmXorExp|AsmXorExp]
    AsmOrExp `|` [#AsmXorExp|AsmXorExp]

$(B $(ID AsmXorExp) AsmXorExp):
    [#AsmAndExp|AsmAndExp]
    AsmXorExp `^` [#AsmAndExp|AsmAndExp]

$(B $(ID AsmAndExp) AsmAndExp):
    [#AsmEqualExp|AsmEqualExp]
    AsmAndExp `&amp;` [#AsmEqualExp|AsmEqualExp]

$(B $(ID AsmEqualExp) AsmEqualExp):
    [#AsmRelExp|AsmRelExp]
    AsmEqualExp `==` [#AsmRelExp|AsmRelExp]
    AsmEqualExp `!=` [#AsmRelExp|AsmRelExp]

$(B $(ID AsmRelExp) AsmRelExp):
    [#AsmShiftExp|AsmShiftExp]
    AsmRelExp `&lt;` [#AsmShiftExp|AsmShiftExp]
    AsmRelExp `&lt;=` [#AsmShiftExp|AsmShiftExp]
    AsmRelExp `&gt;` [#AsmShiftExp|AsmShiftExp]
    AsmRelExp `&gt;=` [#AsmShiftExp|AsmShiftExp]

$(B $(ID AsmShiftExp) AsmShiftExp):
    [#AsmAddExp|AsmAddExp]
    AsmShiftExp `&lt;&lt;` [#AsmAddExp|AsmAddExp]
    AsmShiftExp `&gt;&gt;` [#AsmAddExp|AsmAddExp]
    AsmShiftExp `&gt;&gt;&gt;` [#AsmAddExp|AsmAddExp]

$(B $(ID AsmAddExp) AsmAddExp):
    [#AsmMulExp|AsmMulExp]
    AsmAddExp `+` [#AsmMulExp|AsmMulExp]
    AsmAddExp `-` [#AsmMulExp|AsmMulExp]

$(B $(ID AsmMulExp) AsmMulExp):
    [#AsmBrExp|AsmBrExp]
    AsmMulExp `*` [#AsmBrExp|AsmBrExp]
    AsmMulExp `/` [#AsmBrExp|AsmBrExp]
    AsmMulExp `%` [#AsmBrExp|AsmBrExp]

$(B $(ID AsmBrExp) AsmBrExp):
    [#AsmUnaExp|AsmUnaExp]
    AsmBrExp `[` [#AsmExp|AsmExp] `]`

$(B $(ID AsmUnaExp) AsmUnaExp):
    [#AsmTypePrefix|AsmTypePrefix] [#AsmExp|AsmExp]
    `offsetof` [#AsmExp|AsmExp]
    `seg` [#AsmExp|AsmExp]
    `+` AsmUnaExp
    `-` AsmUnaExp
    `!` AsmUnaExp
    `~` AsmUnaExp
    [#AsmPrimaryExp|AsmPrimaryExp]

$(B $(ID AsmPrimaryExp) AsmPrimaryExp):
    $(LINK2 lex#IntegerLiteral, IntegerLiteral)
    $(LINK2 lex#FloatLiteral, FloatLiteral)
    `__LOCAL_SIZE`
    `$`
    [#Register|Register]
    [#Register|Register] `:` [#AsmExp|AsmExp]
    [#Register64|Register64]
    [#Register64|Register64] `:` [#AsmExp|AsmExp]
    [#DotIdentifier|DotIdentifier]
    `this`

$(B $(ID DotIdentifier) DotIdentifier):
    $(LINK2 lex#Identifier, Identifier)
    $(LINK2 lex#Identifier, Identifier) `.` DotIdentifier
    [type#FundamentalType|type, FundamentalType] `.` $(LINK2 lex#Identifier, Identifier)

)

    The operand syntax more or less follows the Intel CPU documentation
        conventions.
        In particular, the convention is that for two operand instructions
        the source is the right operand and the destination is the left
        operand.
        The syntax differs from that of Intel's in order to be compatible
        with the D language tokenizer and to simplify parsing.
    

    The `seg` means load the segment number that the symbol is
        in. This is not relevant for flat model code.
        Instead, do a move from the relevant segment register.
    

    A dotted expression is evaluated during the compilation and then
        must either give a constant or indicate a higher level variable
        that fits in the target register or variable.
    

$(H3 $(ID operand_types) Operand Types)

$(PRE $(CLASS GRAMMAR)
$(B $(ID AsmTypePrefix) AsmTypePrefix):
    `near ptr`
    `far ptr`
    `word ptr`
    `dword ptr`
    `qword ptr`
    [type#FundamentalType|type, FundamentalType] `ptr`

)

    In cases where the operand size is ambiguous, as in:

---
add [EAX],3     ;

---

    it can be disambiguated by using an [#AsmTypePrefix|AsmTypePrefix]:

---
add  byte ptr [EAX],3 ;
add  int ptr [EAX],7  ;

---

    `far ptr` is not relevant for flat model code.
    

$(H3 $(ID agregate_member_offsets) Struct/Union/Class Member Offsets)

    To access members of an aggregate, given a pointer to the aggregate
        is in a register, use the `.offsetof` property of the qualified name
        of the member:

---
struct Foo { int a,b,c; }
int bar(Foo *f)
{
    asm
    {
        mov EBX,f                   ;
        mov EAX,Foo.b.offsetof[EBX] ;
    }
}
void main()
{
    Foo f = Foo(0, 2, 0);
    assert(bar(&amp;f) == 2);
}

---

    Alternatively, inside the scope of an aggregate, only the member name is needed:

---
struct Foo   // or class
{
    int a,b,c;
    int bar()
    {
        asm
        {
            mov EBX, this   ;
            mov EAX, b[EBX] ;
        }
    }
}
void main()
{
    Foo f = Foo(0, 2, 0);
    assert(f.bar() == 2);
}

---

$(H3 $(ID stack_variables) Stack Variables)

    Stack variables (variables local to a function and allocated
        on the stack) are accessed via the name of the variable indexed
        by EBP:

---
int foo(int x)
{
    asm
    {
        mov EAX,x[EBP] ; // loads value of parameter x into EAX
        mov EAX,x      ; // does the same thing
    }
}

---

    If the [EBP] is omitted, it is assumed for local variables.
        If `naked` is used, this no longer holds.
    

$(H3 $(ID special_symbols) Special Symbols)

$(DL     $(DT $)
    $(DD Represents the program counter of the start of the next instruction. So,

---
jmp  $  ;

---

        branches to the instruction following the jmp instruction.
        The $ can only appear as the target of a jmp or call
        instruction.
    )

    $(DT `__LOCAL_SIZE`)
    $(DD This gets replaced by the number of local bytes in the local
        stack frame. It is most handy when the `naked` is invoked
        and a custom stack frame is programmed.
    )
)

$(H2 $(ID supported_opcodes) Opcodes Supported)

    $(TABLE_ROWS
Opcodes
        * - $(TT aaa)
        
- $(TT aad)
        
- $(TT aam)
        
- $(TT aas)
        
- $(TT adc)

        * - $(TT add)
        
- $(TT addpd)
        
- $(TT addps)
        
- $(TT addsd)
        
- $(TT addss)
        
* - $(TT and)
        
- $(TT andnpd)
        
- $(TT andnps)
        
- $(TT andpd)
        
- $(TT andps)
        
* - $(TT arpl)
        
- $(TT bound)
        
- $(TT bsf)
        
- $(TT bsr)
        
- $(TT bswap)
        
* - $(TT bt)
        
- $(TT btc)
        
- $(TT btr)
        
- $(TT bts)
        
- $(TT call)
        
* - $(TT cbw)
        
- $(TT cdq)
        
- $(TT clc)
        
- $(TT cld)
        
- $(TT clflush)
        
* - $(TT cli)
        
- $(TT clts)
        
- $(TT cmc)
        
- $(TT cmova)
        
- $(TT cmovae)
        
* - $(TT cmovb)
        
- $(TT cmovbe)
        
- $(TT cmovc)
        
- $(TT cmove)
        
- $(TT cmovg)
        
* - $(TT cmovge)
        
- $(TT cmovl)
        
- $(TT cmovle)
        
- $(TT cmovna)
        
- $(TT cmovnae)
        
* - $(TT cmovnb)
        
- $(TT cmovnbe)
        
- $(TT cmovnc)
        
- $(TT cmovne)
        
- $(TT cmovng)
        
* - $(TT cmovnge)
        
- $(TT cmovnl)
        
- $(TT cmovnle)
        
- $(TT cmovno)
        
- $(TT cmovnp)
        
* - $(TT cmovns)
        
- $(TT cmovnz)
        
- $(TT cmovo)
        
- $(TT cmovp)
        
- $(TT cmovpe)
        
* - $(TT cmovpo)
        
- $(TT cmovs)
        
- $(TT cmovz)
        
- $(TT cmp)
        
- $(TT cmppd)
        
* - $(TT cmpps)
        
- $(TT cmps)
        
- $(TT cmpsb)
        
- $(TT cmpsd)
        
- $(TT cmpss)
        
* - $(TT cmpsw)
        
- $(TT cmpxchg)
        
- $(TT cmpxchg8b)
        
- $(TT cmpxchg16b)
        
- $(TT )
        
* - $(TT comisd)
        
- $(TT comiss)
        
- $(TT )
        
- $(TT )
        
- $(TT )
        
* - $(TT cpuid)
        
- $(TT cvtdq2pd)
        
- $(TT cvtdq2ps)
        
- $(TT cvtpd2dq)
        
- $(TT cvtpd2pi)
        
* - $(TT cvtpd2ps)
        
- $(TT cvtpi2pd)
        
- $(TT cvtpi2ps)
        
- $(TT cvtps2dq)
        
- $(TT cvtps2pd)
        
* - $(TT cvtps2pi)
        
- $(TT cvtsd2si)
        
- $(TT cvtsd2ss)
        
- $(TT cvtsi2sd)
        
- $(TT cvtsi2ss)
        
* - $(TT cvtss2sd)
        
- $(TT cvtss2si)
        
- $(TT cvttpd2dq)
        
- $(TT cvttpd2pi)
        
- $(TT cvttps2dq)
        
* - $(TT cvttps2pi)
        
- $(TT cvttsd2si)
        
- $(TT cvttss2si)
        
- $(TT cwd)
        
- $(TT cwde)
        
* - $(TT da)
        
- $(TT daa)
        
- $(TT das)
        
- $(TT db)
        
- $(TT dd)
        
* - $(TT de)
        
- $(TT dec)
        
- $(TT df)
        
- $(TT di)
        
- $(TT div)
        
* - $(TT divpd)
        
- $(TT divps)
        
- $(TT divsd)
        
- $(TT divss)
        
- $(TT dl)
        
* - $(TT dq)
        
- $(TT ds)
        
- $(TT dt)
        
- $(TT dw)
        
- $(TT emms)
        
* - $(TT enter)
        
- $(TT f2xm1)
        
- $(TT fabs)
        
- $(TT fadd)
        
- $(TT faddp)
        
* - $(TT fbld)
        
- $(TT fbstp)
        
- $(TT fchs)
        
- $(TT fclex)
        
- $(TT fcmovb)
        
* - $(TT fcmovbe)
        
- $(TT fcmove)
        
- $(TT fcmovnb)
        
- $(TT fcmovnbe)
        
- $(TT fcmovne)
        
* - $(TT fcmovnu)
        
- $(TT fcmovu)
        
- $(TT fcom)
        
- $(TT fcomi)
        
- $(TT fcomip)
        
* - $(TT fcomp)
        
- $(TT fcompp)
        
- $(TT fcos)
        
- $(TT fdecstp)
        
- $(TT fdisi)
        
* - $(TT fdiv)
        
- $(TT fdivp)
        
- $(TT fdivr)
        
- $(TT fdivrp)
        
- $(TT feni)
        
* - $(TT ffree)
        
- $(TT fiadd)
        
- $(TT ficom)
        
- $(TT ficomp)
        
- $(TT fidiv)
        
* - $(TT fidivr)
        
- $(TT fild)
        
- $(TT fimul)
        
- $(TT fincstp)
        
- $(TT finit)
        
* - $(TT fist)
        
- $(TT fistp)
        
- $(TT fisub)
        
- $(TT fisubr)
        
- $(TT fld)
        
* - $(TT fld1)
        
- $(TT fldcw)
        
- $(TT fldenv)
        
- $(TT fldl2e)
        
- $(TT fldl2t)
        
* - $(TT fldlg2)
        
- $(TT fldln2)
        
- $(TT fldpi)
        
- $(TT fldz)
        
- $(TT fmul)
        
* - $(TT fmulp)
        
- $(TT fnclex)
        
- $(TT fndisi)
        
- $(TT fneni)
        
- $(TT fninit)
        
* - $(TT fnop)
        
- $(TT fnsave)
        
- $(TT fnstcw)
        
- $(TT fnstenv)
        
- $(TT fnstsw)
        
* - $(TT fpatan)
        
- $(TT fprem)
        
- $(TT fprem1)
        
- $(TT fptan)
        
- $(TT frndint)
        
* - $(TT frstor)
        
- $(TT fsave)
        
- $(TT fscale)
        
- $(TT fsetpm)
        
- $(TT fsin)
        
* - $(TT fsincos)
        
- $(TT fsqrt)
        
- $(TT fst)
        
- $(TT fstcw)
        
- $(TT fstenv)
        
* - $(TT fstp)
        
- $(TT fstsw)
        
- $(TT fsub)
        
- $(TT fsubp)
        
- $(TT fsubr)
        
* - $(TT fsubrp)
        
- $(TT ftst)
        
- $(TT fucom)
        
- $(TT fucomi)
        
- $(TT fucomip)
        
* - $(TT fucomp)
        
- $(TT fucompp)
        
- $(TT fwait)
        
- $(TT fxam)
        
- $(TT fxch)
        
* - $(TT fxrstor)
        
- $(TT fxsave)
        
- $(TT fxtract)
        
- $(TT fyl2x)
        
- $(TT fyl2xp1)
        
* - $(TT hlt)
        
- $(TT idiv)
        
- $(TT imul)
        
- $(TT in)
        
- $(TT inc)
        
* - $(TT ins)
        
- $(TT insb)
        
- $(TT insd)
        
- $(TT insw)
        
- $(TT int)
        
* - $(TT into)
        
- $(TT invd)
        
- $(TT invlpg)
        
- $(TT iret)
        
- $(TT iretd)
        
* - $(TT iretq)
        
- $(TT ja)
        
- $(TT jae)
        
- $(TT jb)
        
- $(TT jbe)
        
* - $(TT jc)
        
- $(TT jcxz)
        
- $(TT je)
        
- $(TT jecxz)
        
- $(TT jg)
        
* - $(TT jge)
        
- $(TT jl)
        
- $(TT jle)
        
- $(TT jmp)
        
- $(TT jna)
        
* - $(TT jnae)
        
- $(TT jnb)
        
- $(TT jnbe)
        
- $(TT jnc)
        
- $(TT jne)
        
* - $(TT jng)
        
- $(TT jnge)
        
- $(TT jnl)
        
- $(TT jnle)
        
- $(TT jno)
        
* - $(TT jnp)
        
- $(TT jns)
        
- $(TT jnz)
        
- $(TT jo)
        
- $(TT jp)
        
* - $(TT jpe)
        
- $(TT jpo)
        
- $(TT js)
        
- $(TT jz)
        
- $(TT lahf)
        
* - $(TT lar)
        
- $(TT ldmxcsr)
        
- $(TT lds)
        
- $(TT lea)
        
- $(TT leave)
        
* - $(TT les)
        
- $(TT lfence)
        
- $(TT lfs)
        
- $(TT lgdt)
        
- $(TT lgs)
        
* - $(TT lidt)
        
- $(TT lldt)
        
- $(TT lmsw)
        
- $(TT lock)
        
- $(TT lods)
        
* - $(TT lodsb)
        
- $(TT lodsd)
        
- $(TT lodsw)
        
- $(TT loop)
        
- $(TT loope)
        
* - $(TT loopne)
        
- $(TT loopnz)
        
- $(TT loopz)
        
- $(TT lsl)
        
- $(TT lss)
        
* - $(TT ltr)
        
- $(TT maskmovdqu)
        
- $(TT maskmovq)
        
- $(TT maxpd)
        
- $(TT maxps)
        
* - $(TT maxsd)
        
- $(TT maxss)
        
- $(TT mfence)
        
- $(TT minpd)
        
- $(TT minps)
        
* - $(TT minsd)
        
- $(TT minss)
        
- $(TT mov)
        
- $(TT movapd)
        
- $(TT movaps)
        
* - $(TT movd)
        
- $(TT movdq2q)
        
- $(TT movdqa)
        
- $(TT movdqu)
        
- $(TT movhlps)
        
* - $(TT movhpd)
        
- $(TT movhps)
        
- $(TT movlhps)
        
- $(TT movlpd)
        
- $(TT movlps)
        
* - $(TT movmskpd)
        
- $(TT movmskps)
        
- $(TT movntdq)
        
- $(TT movnti)
        
- $(TT movntpd)
        
* - $(TT movntps)
        
- $(TT movntq)
        
- $(TT movq)
        
- $(TT movq2dq)
        
- $(TT movs)
        
* - $(TT movsb)
        
- $(TT movsd)
        
- $(TT movss)
        
- $(TT movsw)
        
- $(TT movsx)
        
* - $(TT movupd)
        
- $(TT movups)
        
- $(TT movzx)
        
- $(TT mul)
        
- $(TT mulpd)
        
* - $(TT mulps)
        
- $(TT mulsd)
        
- $(TT mulss)
        
- $(TT neg)
        
- $(TT nop)
        
* - $(TT not)
        
- $(TT or)
        
- $(TT orpd)
        
- $(TT orps)
        
- $(TT out)
        
* - $(TT outs)
        
- $(TT outsb)
        
- $(TT outsd)
        
- $(TT outsw)
        
- $(TT packssdw)
        
* - $(TT packsswb)
        
- $(TT packuswb)
        
- $(TT paddb)
        
- $(TT paddd)
        
- $(TT paddq)
        
* - $(TT paddsb)
        
- $(TT paddsw)
        
- $(TT paddusb)
        
- $(TT paddusw)
        
- $(TT paddw)
        
* - $(TT pand)
        
- $(TT pandn)
        
- $(TT pavgb)
        
- $(TT pavgw)
        
- $(TT pcmpeqb)
        
* - $(TT pcmpeqd)
        
- $(TT pcmpeqw)
        
- $(TT pcmpgtb)
        
- $(TT pcmpgtd)
        
- $(TT pcmpgtw)
        
* - $(TT pextrw)
        
- $(TT pinsrw)
        
- $(TT pmaddwd)
        
- $(TT pmaxsw)
        
- $(TT pmaxub)
        
* - $(TT pminsw)
        
- $(TT pminub)
        
- $(TT pmovmskb)
        
- $(TT pmulhuw)
        
- $(TT pmulhw)
        
* - $(TT pmullw)
        
- $(TT pmuludq)
        
- $(TT pop)
        
- $(TT popa)
        
- $(TT popad)
        
* - $(TT popf)
        
- $(TT popfd)
        
- $(TT por)
        
- $(TT prefetchnta)
        
- $(TT prefetcht0)
        
* - $(TT prefetcht1)
        
- $(TT prefetcht2)
        
- $(TT psadbw)
        
- $(TT pshufd)
        
- $(TT pshufhw)
        
* - $(TT pshuflw)
        
- $(TT pshufw)
        
- $(TT pslld)
        
- $(TT pslldq)
        
- $(TT psllq)
        
* - $(TT psllw)
        
- $(TT psrad)
        
- $(TT psraw)
        
- $(TT psrld)
        
- $(TT psrldq)
        
* - $(TT psrlq)
        
- $(TT psrlw)
        
- $(TT psubb)
        
- $(TT psubd)
        
- $(TT psubq)
        
* - $(TT psubsb)
        
- $(TT psubsw)
        
- $(TT psubusb)
        
- $(TT psubusw)
        
- $(TT psubw)
        
* - $(TT punpckhbw)
        
- $(TT punpckhdq)
        
- $(TT punpckhqdq)
        
- $(TT punpckhwd)
        
- $(TT punpcklbw)
        
* - $(TT punpckldq)
        
- $(TT punpcklqdq)
        
- $(TT punpcklwd)
        
- $(TT push)
        
- $(TT pusha)
        
* - $(TT pushad)
        
- $(TT pushf)
        
- $(TT pushfd)
        
- $(TT pxor)
        
- $(TT rcl)
        
* - $(TT rcpps)
        
- $(TT rcpss)
        
- $(TT rcr)
        
- $(TT rdmsr)
        
- $(TT rdpmc)
        
* - $(TT rdtsc)
        
- $(TT rep)
        
- $(TT repe)
        
- $(TT repne)
        
- $(TT repnz)
        
* - $(TT repz)
        
- $(TT ret)
        
- $(TT retf)
        
- $(TT rol)
        
- $(TT ror)
        
* - $(TT rsm)
        
- $(TT rsqrtps)
        
- $(TT rsqrtss)
        
- $(TT sahf)
        
- $(TT sal)
        
* - $(TT sar)
        
- $(TT sbb)
        
- $(TT scas)
        
- $(TT scasb)
        
- $(TT scasd)
        
* - $(TT scasw)
        
- $(TT seta)
        
- $(TT setae)
        
- $(TT setb)
        
- $(TT setbe)
        
* - $(TT setc)
        
- $(TT sete)
        
- $(TT setg)
        
- $(TT setge)
        
- $(TT setl)
        
* - $(TT setle)
        
- $(TT setna)
        
- $(TT setnae)
        
- $(TT setnb)
        
- $(TT setnbe)
        
* - $(TT setnc)
        
- $(TT setne)
        
- $(TT setng)
        
- $(TT setnge)
        
- $(TT setnl)
        
* - $(TT setnle)
        
- $(TT setno)
        
- $(TT setnp)
        
- $(TT setns)
        
- $(TT setnz)
        
* - $(TT seto)
        
- $(TT setp)
        
- $(TT setpe)
        
- $(TT setpo)
        
- $(TT sets)
        
* - $(TT setz)
        
- $(TT sfence)
        
- $(TT sgdt)
        
- $(TT shl)
        
- $(TT shld)
        
* - $(TT shr)
        
- $(TT shrd)
        
- $(TT shufpd)
        
- $(TT shufps)
        
- $(TT sidt)
        
* - $(TT sldt)
        
- $(TT smsw)
        
- $(TT sqrtpd)
        
- $(TT sqrtps)
        
- $(TT sqrtsd)
        
* - $(TT sqrtss)
        
- $(TT stc)
        
- $(TT std)
        
- $(TT sti)
        
- $(TT stmxcsr)
        
* - $(TT stos)
        
- $(TT stosb)
        
- $(TT stosd)
        
- $(TT stosw)
        
- $(TT str)
        
* - $(TT sub)
        
- $(TT subpd)
        
- $(TT subps)
        
- $(TT subsd)
        
- $(TT subss)
        
* - $(TT syscall)
        
- $(TT sysenter)
        
- $(TT sysexit)
        
- $(TT sysret)
        
- $(TT test)
        
* - $(TT ucomisd)
        
- $(TT ucomiss)
        
- $(TT ud2)
        
- $(TT unpckhpd)
        
- $(TT unpckhps)
        
* - $(TT unpcklpd)
        
- $(TT unpcklps)
        
- $(TT verr)
        
- $(TT verw)
        
- $(TT wait)
        
* - $(TT wbinvd)
        
- $(TT wrmsr)
        
- $(TT xadd)
        
- $(TT xchg)
        
- $(TT xlat)
        
* - $(TT xlatb)
        
- $(TT xor)
        
- $(TT xorpd)
        
- $(TT xorps)
        
- $(TT  )
        

    
)

$(H3 $(ID P4_opcode_support) Pentium 4 (Prescott) Opcodes Supported)

    $(TABLE_ROWS
Pentium 4 Opcodes
        * - $(TT addsubpd)
        
- $(TT addsubps)
        
- $(TT fisttp)
        
- $(TT haddpd)
        
- $(TT haddps)
        
* - $(TT hsubpd)
        
- $(TT hsubps)
        
- $(TT lddqu)
        
- $(TT monitor)
        
- $(TT movddup)
        
* - $(TT movshdup)
        
- $(TT movsldup)
        
- $(TT mwait)
        
- $(TT  )
        
- $(TT  )
        

    
)

$(H3 $(ID amd_opcode_support) AMD Opcodes Supported)

    $(TABLE_ROWS
AMD Opcodes
        * - $(TT pavgusb)
        
- $(TT pf2id)
        
- $(TT pfacc)
        
- $(TT pfadd)
        
- $(TT pfcmpeq)
        
* - $(TT pfcmpge)
        
- $(TT pfcmpgt)
        
- $(TT pfmax)
        
- $(TT pfmin)
        
- $(TT pfmul)
        
* - $(TT pfnacc)
        
- $(TT pfpnacc)
        
- $(TT pfrcp)
        
- $(TT pfrcpit1)
        
- $(TT pfrcpit2)
        
* - $(TT pfrsqit1)
        
- $(TT pfrsqrt)
        
- $(TT pfsub)
        
- $(TT pfsubr)
        
- $(TT pi2fd)
        
* - $(TT pmulhrw)
        
- $(TT pswapd)
        
- $(TT  )
        
- $(TT  )
        
- $(TT  )
        

    
)

$(H3 $(ID simd) SIMD)

    SSE, SSE2, SSE3, SSSE3, SSE4.1, SSE4.2 and AVX are supported.

$(COMMENT $(H3 $(ID other) Other)
    AES, CMUL, FSGSBASE, RDRAND, FP16C and FMA are supported.
)

$(COMMENT SSE4.1

blendpd
blendps
blendvpd
blendvps
dppd
dpps
extractps
insertps
movntdqa
mpsadbw
packusdw
pblendub
pblendw
pcmpeqq
pextrb
pextrd
pextrq
pextrw
phminposuw
pinsrb
pinsrd
pinsrq
pmaxsb
pmaxsd
pmaxud
pmaxuw
pminsb
pminsd
pminud
pminuw
pmovsxbd
pmovsxbq
pmovsxbw
pmovsxwd
pmovsxwq
pmovsxdq
pmovzxbd
pmovzxbq
pmovzxbw
pmovzxwd
pmovzxwq
pmovzxdq
pmuldq
pmulld
ptest
roundpd
roundps
roundsd
roundss

SSE4.2

crc32
pcmpestri
pcmpestrm
pcmpistri
pcmpistrm
pcmpgtq
popcnt

VMS

invept
invvpid
vmcall
vmclear
vmlaunch
vmresume
vmptrld
vmptrst
vmread
vmwrite
vmxoff
vmxon

SMX

getsec
)

$(H2 $(ID gcc) GCC syntax)

The $(LINK2 https://gdcproject.org/, GNU D Compiler) uses an alternative, GCC-based syntax for inline assembler:

$(PRE $(CLASS GRAMMAR)
$(B $(ID GccAsmStatement) GccAsmStatement):
    `asm` [function#FunctionAttributes|function, FunctionAttributes]$(SUBSCRIPT opt) `{` [#GccAsmInstructionList|GccAsmInstructionList] `}`

$(B $(ID GccAsmInstructionList) GccAsmInstructionList):
    [#GccAsmInstruction|GccAsmInstruction] `;`
    [#GccAsmInstruction|GccAsmInstruction] `;` GccAsmInstructionList

$(B $(ID GccAsmInstruction) GccAsmInstruction):
    [#GccBasicAsmInstruction|GccBasicAsmInstruction]
    [#GccExtAsmInstruction|GccExtAsmInstruction]
    [#GccGotoAsmInstruction|GccGotoAsmInstruction]

$(B $(ID GccBasicAsmInstruction) GccBasicAsmInstruction):
    [expression#AssignExpression|expression, AssignExpression]

$(B $(ID GccExtAsmInstruction) GccExtAsmInstruction):
    [expression#AssignExpression|expression, AssignExpression] `:` [#GccAsmOperands|GccAsmOperands]$(SUBSCRIPT opt)
    [expression#AssignExpression|expression, AssignExpression] `:` [#GccAsmOperands|GccAsmOperands]$(SUBSCRIPT opt) `:` [#GccAsmOperands|GccAsmOperands]$(SUBSCRIPT opt)
    [expression#AssignExpression|expression, AssignExpression] `:` [#GccAsmOperands|GccAsmOperands]$(SUBSCRIPT opt) `:` [#GccAsmOperands|GccAsmOperands]$(SUBSCRIPT opt) `:` [#GccAsmClobbers|GccAsmClobbers]$(SUBSCRIPT opt)

$(B $(ID GccGotoAsmInstruction) GccGotoAsmInstruction):
    [expression#AssignExpression|expression, AssignExpression] `:` `:` [#GccAsmOperands|GccAsmOperands]$(SUBSCRIPT opt) `:` [#GccAsmClobbers|GccAsmClobbers]$(SUBSCRIPT opt) `:` [#GccAsmGotoLabels|GccAsmGotoLabels]$(SUBSCRIPT opt)

$(B $(ID GccAsmOperands) GccAsmOperands):
    [#GccSymbolicName|GccSymbolicName]$(SUBSCRIPT opt) $(LINK2 lex#StringLiteral, StringLiteral) `(` [expression#AssignExpression|expression, AssignExpression] `)`
    [#GccSymbolicName|GccSymbolicName]$(SUBSCRIPT opt) $(LINK2 lex#StringLiteral, StringLiteral) `(` [expression#AssignExpression|expression, AssignExpression] `)` `,` GccAsmOperands

$(B $(ID GccSymbolicName) GccSymbolicName):
    `[` $(LINK2 lex#Identifier, Identifier) `]`

$(B $(ID GccAsmClobbers) GccAsmClobbers):
    $(LINK2 lex#StringLiteral, StringLiteral)
    $(LINK2 lex#StringLiteral, StringLiteral) `,` GccAsmClobbers

$(B $(ID GccAsmGotoLabels) GccAsmGotoLabels):
    $(LINK2 lex#Identifier, Identifier)
    $(LINK2 lex#Identifier, Identifier) `,` GccAsmGotoLabels

)

float, Floating Point, ddoc, Embedded Documentation




Link_References:
	ACC = Associated C Compiler
+/
module iasm.dd;