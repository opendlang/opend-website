// just docs: Windows Programming
/++





This covers Windows programming with 32 bit OMF, 32 bit Mscoff,
64 bit Mscoff, console programs, GUI programs, and DLLs.


$(H2 $(ID mscoff) Windows 32 and 64 bit MSCOFF Programs)

    32 bit and 64 bit MSCOFF programs use the Microsoft Visual C/C++ compiler as the [acc],
    generate object files in the MSCOFF format, and use the Microsoft linker
    to link them.
    

$(H3 $(ID mscoff-console) Console Programs)

$(H3 $(ID mscoff-windows) Windows GUI Programs)

$(H3 $(ID mscoff-dlls) DLLs)

$(H2 $(ID omf) Windows 32 bit OMF Programs)

    32 bit OMF programs use the
    $(LINK2 https://www.digitalmars.com/download/freecompiler.html, Digital Mars C/C++ compiler)
    as the [acc], generate object files in the OMF format, and use the
    $(LINK2 https://www.digitalmars.com/ctg/optlink.html, Optlink linker)
    to link them.
    

$(H3 $(ID omf-console) Console Programs)

$(H3 $(ID omf-windows) Windows GUI Programs)

$(H3 $(ID omf-dlls) DLLs)

ob, Live Functions, glossary, Glossary




Link_References:
	ACC = Associated C Compiler
+/
module windows.dd;