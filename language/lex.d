// just docs: Lexical
/++





The lexical analysis is independent of the syntax parsing and the semantic
analysis. The lexical analyzer splits the source text into tokens. The
lexical grammar describes the syntax of these tokens. The grammar is designed to
be suitable for high-speed scanning and to facilitate the implementation of a correct
scanner. It has a minimum of special case rules and there is only one
phase of translation.

$(H2 $(ID source_text) Source Text)

$(PRE $(CLASS GRAMMAR)
$(B $(ID SourceFile) SourceFile):
    [#ByteOrderMark|ByteOrderMark] [module#Module|module, Module]$(SUBSCRIPT opt)
    [#Shebang|Shebang] [module#Module|module, Module]$(SUBSCRIPT opt)
    [module#Module|module, Module]$(SUBSCRIPT opt)

)
$(PRE $(CLASS GRAMMAR)
$(B $(ID ByteOrderMark) ByteOrderMark):
    $(B \uFEFF)

$(B $(ID Shebang) Shebang):
    $(B #!) [#Characters|Characters]$(SUBSCRIPT opt) [#EndOfShebang|EndOfShebang]

$(B $(ID EndOfShebang) EndOfShebang):
    $(B \u000A)
    [#EndOfFile|EndOfFile]

)

Source text can be encoded as any one of the following:

        $(LIST
*         ASCII (strictly, 7-bit ASCII)
*         UTF-8
*         UTF-16BE
*         UTF-16LE
*         UTF-32BE
*         UTF-32LE
        

)

One of the following UTF
BOMs (Byte Order Marks) can be present at the beginning of the source text:

$(TABLE_ROWS
UTF Byte Order Marks
    * + Format
+ BOM

        * - UTF-8
- EF BB BF

        * - UTF-16BE
- FE FF

        * - UTF-16LE
- FF FE

    * - UTF-32BE
- 00 00 FE FF

        * - UTF-32LE
- FF FE 00 00

        * - ASCII
- no BOM


)

If the source file does not begin with a BOM, then the first character must
be less than or equal to U+0000007F.

The source text is decoded from its source representation into Unicode
[#Character|Character]s. The [#Character|Character]s are further divided into: [#WhiteSpace|WhiteSpace], [#EndOfLine|EndOfLine], [#Comment|Comment]s, [#SpecialTokenSequence|SpecialTokenSequence]s, and [#Token|Token]s, with the source terminated by an [#EndOfFile|EndOfFile].

The source text is split into tokens using the maximal munch algorithm,
i.e., the lexical analyzer assumes the longest possible token. For example,
`&gt;&gt;` is a right-shift token rather than two greater-than tokens. There are two
exceptions to this rule:

$(LIST
        * A `..` embedded between what appear to be two floating point
                literals, as in `1..2`, is interpreted as if the `..` were
                separated by a space from the first integer.
        * A `1.a` is interpreted as the three tokens `1`, `.`, and `a`,
                whereas `1. a` is interpreted as the two tokens `1.` and `a`.

)

$(H2 $(ID character_set) Character Set)

$(PRE $(CLASS GRAMMAR)
$(B $(ID Character) Character):
    $(I any Unicode character)

)

$(H2 $(ID end_of_file) End of File)

$(PRE $(CLASS GRAMMAR)
$(B $(ID EndOfFile) EndOfFile):
    $(I physical end of the file)
    $(B \u0000)
    $(B \u001A)

)

The source text is terminated by whichever comes first.

$(H2 $(ID end_of_line) End of Line)

$(PRE $(CLASS GRAMMAR)
$(B $(ID EndOfLine) EndOfLine):
    $(B \u000D)
    $(B \u000A)
    $(B \u000D) $(B \u000A)
    $(B \u2028)
    $(B \u2029)
    [#EndOfFile|EndOfFile]

)


$(H2 $(ID white_space) White Space)

$(PRE $(CLASS GRAMMAR)
$(B $(ID WhiteSpace) WhiteSpace):
    [#Space|Space]
    [#Space|Space] WhiteSpace

$(B $(ID Space) Space):
    $(B \u0020)
    $(B \u0009)
    $(B \u000B)
    $(B \u000C)

)


$(H2 $(ID comment) Comments)

$(PRE $(CLASS GRAMMAR)
$(B $(ID Comment) Comment):
    [#BlockComment|BlockComment]
    [#LineComment|LineComment]
    [#NestingBlockComment|NestingBlockComment]

$(B $(ID BlockComment) BlockComment):
    $(B /*) [#Characters|Characters]$(SUBSCRIPT opt) $(B */)

$(B $(ID LineComment) LineComment):
    $(B //) [#Characters|Characters]$(SUBSCRIPT opt) [#EndOfLine|EndOfLine]

$(B $(ID NestingBlockComment) NestingBlockComment):
    $(B /+) [#NestingBlockCommentCharacters|NestingBlockCommentCharacters]$(SUBSCRIPT opt) $(B +/)

$(B $(ID NestingBlockCommentCharacters) NestingBlockCommentCharacters):
    [#NestingBlockCommentCharacter|NestingBlockCommentCharacter]
    [#NestingBlockCommentCharacter|NestingBlockCommentCharacter] NestingBlockCommentCharacters

$(B $(ID NestingBlockCommentCharacter) NestingBlockCommentCharacter):
    [#Character|Character]
    [#NestingBlockComment|NestingBlockComment]

$(B $(ID Characters) Characters):
    [#Character|Character]
    [#Character|Character] Characters

)

    There are three kinds of comments:

        $(NUMBERED_LIST
        * Block comments can span multiple lines, but do not nest.
        * Line comments terminate at the end of the line.
        * Nesting block comments can span multiple lines and can nest.
        
)

                The contents of strings and comments are not tokenized.  Consequently,
        comment openings occurring within a string do not begin a comment, and
        string delimiters within a comment do not affect the recognition of
        comment closings and nested `/+` comment openings.  With the exception
        of `/+` occurring within a `/+` comment, comment openings within a
        comment are ignored.
        

---
a = /+ // +/ 1;    // parses as if 'a = 1;'
a = /+ "+/" +/ 1"; // parses as if 'a = " +/ 1";'
a = /+ /* +/ */ 3; // parses as if 'a = */ 3;'

---

Comments cannot be used as token concatenators, for example, `abc/**/def`
is two tokens, `abc` and `def`, not one `abcdef` token.

$(H2 $(ID tokens) Tokens)

$(PRE $(CLASS GRAMMAR)
$(B $(ID Tokens) Tokens):
    [#Token|Token]
    [#Token|Token] Tokens

$(B $(ID Token) Token):
    `{`
    `}`
    [#TokenNoBraces|TokenNoBraces]

$(B $(ID TokenNoBraces) TokenNoBraces):
    [#Identifier|Identifier]
    [#StringLiteral|StringLiteral]
    [istring#InterpolationExpressionSequence|istring, InterpolationExpressionSequence]
    [#CharacterLiteral|CharacterLiteral]
    [#IntegerLiteral|IntegerLiteral]
    [#FloatLiteral|FloatLiteral]
    [#Keyword|Keyword]
    `/`
    `/=`
    `.`
    `..`
    `...`
    `&`
    `&=`
    `&&`
    `|`
    `|=`
    `||`
    `-`
    `-=`
    `--`
    `+`
    `+=`
    `++`
    `&lt;`
    `&lt;=`
    `&lt;&lt;`
    `&lt;&lt;=`
    `&gt;`
    `&gt;=`
    `&gt;&gt;=`
    `&gt;&gt;&gt;=`
    `&gt;&gt;`
    `&gt;&gt;&gt;`
    `!`
    `!=`
    `(`
    `)`
    `[`
    `]`
    `?`
    `,`
    `;`
    `:`
    `$`
    `=`
    `==`
    `*`
    `*=`
    `%`
    `%=`
    `^`
    `^=`
    `^^`
    `^^=`
    `~`
    `~=`
    `@`
    `=&gt;`


)

$(H2 $(ID identifiers) Identifiers)

$(PRE $(CLASS GRAMMAR)
$(B $(ID Identifier) Identifier):
    [#IdentifierStart|IdentifierStart]
    [#IdentifierStart|IdentifierStart] [#IdentifierChars|IdentifierChars]

$(B $(ID IdentifierChars) IdentifierChars):
    [#IdentifierChar|IdentifierChar]
    [#IdentifierChar|IdentifierChar] IdentifierChars

$(B $(ID IdentifierStart) IdentifierStart):
    $(B _)
    $(I Letter)
    $(I UniversalAlpha)

$(B $(ID IdentifierChar) IdentifierChar):
    [#IdentifierStart|IdentifierStart]
    $(B 0)
    [#NonZeroDigit|NonZeroDigit]

)


Identifiers start with a letter, `_`, or universal alpha, and are
followed by any number of letters, `_`, digits, or universal alphas.
Universal alphas are as defined in ISO/IEC 9899:1999(E) Appendix D of the C99 Standard.
Identifiers can be arbitrarily long, and are case sensitive.

$(WARNING Identifiers starting with `__` (two underscores) are reserved.)

$(H2 $(ID string_literals) String Literals)

$(PRE $(CLASS GRAMMAR)
$(B $(ID StringLiteral) StringLiteral):
    [#WysiwygString|WysiwygString]
    [#AlternateWysiwygString|AlternateWysiwygString]
    [#DoubleQuotedString|DoubleQuotedString]
    [#DelimitedString|DelimitedString]
    [#TokenString|TokenString]
    [#HexString|HexString]

)
A string literal is either a wysiwyg quoted string, a double quoted
string, a delimited string, a token string, or a hex string.


In all string literal forms, an [#EndOfLine|EndOfLine] is regarded as a single
`\n` character.

$(H3 $(ID wysiwyg) Wysiwyg Strings)
$(PRE $(CLASS GRAMMAR)
$(B $(ID WysiwygString) WysiwygString):
    $(B r") [#WysiwygCharacters|WysiwygCharacters]$(SUBSCRIPT opt) $(B ") [#StringPostfix|StringPostfix]$(SUBSCRIPT opt)

$(B $(ID AlternateWysiwygString) AlternateWysiwygString):
    $(B `) [#WysiwygCharacters|WysiwygCharacters]$(SUBSCRIPT opt) $(B `) [#StringPostfix|StringPostfix]$(SUBSCRIPT opt)

$(B $(ID WysiwygCharacters) WysiwygCharacters):
    [#WysiwygCharacter|WysiwygCharacter]
    [#WysiwygCharacter|WysiwygCharacter] WysiwygCharacters

$(B $(ID WysiwygCharacter) WysiwygCharacter):
    [#Character|Character]
    [#EndOfLine|EndOfLine]

)
                Wysiwyg ("what you see is what you get") quoted strings can be defined
        using either of two syntaxes.
        

                In the first form, they are enclosed between `r"` and `"`.
        All characters between
        the `r"` and `"` are part of the string.
        There are no escape sequences inside wysiwyg strings.
        

---
r"I am Oz"
r"c:\games\Sudoku.exe"
r"ab\n" // string is 4 characters,
        // 'a', 'b', '\', 'n'

---

                Alternatively, wysiwyg strings can be enclosed by backquotes,
        using the ` character.
        

---
`the Great and Powerful.`
`c:\games\Empire.exe`
`The "lazy" dog`
`a"b\n`  // string is 5 characters,
         // 'a', '"', 'b', '\', 'n'

---

See also [istring#InterpolatedWysiwygLiteral|istring, InterpolatedWysiwygLiteral]

$(H3 $(ID double_quoted_strings) Double Quoted Strings)
$(PRE $(CLASS GRAMMAR)
$(B $(ID DoubleQuotedString) DoubleQuotedString):
    $(B ") [#DoubleQuotedCharacters|DoubleQuotedCharacters]$(SUBSCRIPT opt) $(B ") [#StringPostfix|StringPostfix]$(SUBSCRIPT opt)

$(B $(ID DoubleQuotedCharacters) DoubleQuotedCharacters):
    [#DoubleQuotedCharacter|DoubleQuotedCharacter]
    [#DoubleQuotedCharacter|DoubleQuotedCharacter] DoubleQuotedCharacters

$(B $(ID DoubleQuotedCharacter) DoubleQuotedCharacter):
    [#Character|Character]
    [#EscapeSequence|EscapeSequence]
    [#EndOfLine|EndOfLine]

)

        Double quoted strings are enclosed by "". [#EscapeSequence|EscapeSequence]s can be
        embedded in them.

---
"Who are you?"
"c:\\games\\Doom.exe"
"ab\n"   // string is 3 characters,
         // 'a', 'b', and a linefeed
"ab
"        // string is 3 characters,
         // 'a', 'b', and a linefeed

---

See also [istring#InterpolatedDoubleQuotedLiteral|istring, InterpolatedDoubleQuotedLiteral]

$(H3 $(ID delimited_strings) Delimited Strings)
$(PRE $(CLASS GRAMMAR)
$(B $(ID DelimitedString) DelimitedString):
    $(B q") [#Delimiter|Delimiter] [#WysiwygCharacters|WysiwygCharacters]$(SUBSCRIPT opt) [#MatchingDelimiter|MatchingDelimiter] $(B ") [#StringPostfix|StringPostfix]$(SUBSCRIPT opt)
    $(B q"() [#ParenDelimitedCharacters|ParenDelimitedCharacters]$(SUBSCRIPT opt) $(B )") [#StringPostfix|StringPostfix]$(SUBSCRIPT opt)
    $(B q"[) [#BracketDelimitedCharacters|BracketDelimitedCharacters]$(SUBSCRIPT opt) $(B ]") [#StringPostfix|StringPostfix]$(SUBSCRIPT opt)
    $(B q"{) [#BraceDelimitedCharacters|BraceDelimitedCharacters]$(SUBSCRIPT opt) $(B }") [#StringPostfix|StringPostfix]$(SUBSCRIPT opt)
    $(B q"&lt;) [#AngleDelimitedCharacters|AngleDelimitedCharacters]$(SUBSCRIPT opt) $(B &gt;") [#StringPostfix|StringPostfix]$(SUBSCRIPT opt)

$(B $(ID Delimiter) Delimiter):
    [#Identifier|Identifier]

$(B $(ID MatchingDelimiter) MatchingDelimiter):
    [#Identifier|Identifier]

$(B $(ID ParenDelimitedCharacters) ParenDelimitedCharacters):
    [#WysiwygCharacter|WysiwygCharacter]
    [#WysiwygCharacter|WysiwygCharacter] ParenDelimitedCharacters
    $(B () ParenDelimitedCharacters$(SUBSCRIPT opt) $(B ))

$(B $(ID BracketDelimitedCharacters) BracketDelimitedCharacters):
    [#WysiwygCharacter|WysiwygCharacter]
    [#WysiwygCharacter|WysiwygCharacter] BracketDelimitedCharacters
    $(B [) BracketDelimitedCharacters$(SUBSCRIPT opt) $(B ])

$(B $(ID BraceDelimitedCharacters) BraceDelimitedCharacters):
    [#WysiwygCharacter|WysiwygCharacter]
    [#WysiwygCharacter|WysiwygCharacter] BraceDelimitedCharacters
    $(B {) BraceDelimitedCharacters$(SUBSCRIPT opt) $(B })

$(B $(ID AngleDelimitedCharacters) AngleDelimitedCharacters):
    [#WysiwygCharacter|WysiwygCharacter]
    [#WysiwygCharacter|WysiwygCharacter] AngleDelimitedCharacters
    $(B &lt;) AngleDelimitedCharacters$(SUBSCRIPT opt) $(B &gt;)

)

        Delimited strings use various forms of delimiters.
        The delimiter, whether a character or identifier,
        must immediately follow the " without any intervening whitespace.
        The terminating delimiter must immediately precede the closing "
        without any intervening whitespace.
        A $(I nesting delimiter) nests, and is one of the
        following characters:
        

        $(TABLE_ROWS
Nesting Delimiters
        * + Delimiter
+ Matching Delimiter

        * - `[`
- `]`

        * - (
- )

        * - `&lt;`
- `&gt;`

        * - {
- }

        
)

---
q"(foo(xxx))"   // "foo(xxx)"
q"[foo{]"       // "foo{"

---

        If the delimiter is an identifier, the identifier must
        be immediately followed by a newline, and the matching
        delimiter must be the same identifier starting at the beginning
        of the line:
        
---
writeln(q"EOS
This
is a multi-line
heredoc string
EOS"
);

---
        The newline following the opening identifier is not part
        of the string, but the last newline before the closing
        identifier is part of the string. The closing identifier
    must be placed on its own line at the leftmost column.
        

        Otherwise, the matching delimiter is the same as
        the delimiter character:

---
q"/foo]/"          // "foo]"
// q"/abc/def/"    // error

---

$(H3 $(ID token_strings) Token Strings)
$(PRE $(CLASS GRAMMAR)
$(B $(ID TokenString) TokenString):
    `q{` [#TokenStringTokens|TokenStringTokens]$(SUBSCRIPT opt) `}` [#StringPostfix|StringPostfix]$(SUBSCRIPT opt)

$(B $(ID TokenStringTokens) TokenStringTokens):
    [#TokenStringToken|TokenStringToken]
    [#TokenStringToken|TokenStringToken] TokenStringTokens

$(B $(ID TokenStringToken) TokenStringToken):
    [#TokenNoBraces|TokenNoBraces]
    `{` [#TokenStringTokens|TokenStringTokens]$(SUBSCRIPT opt) `}`

)

        Token strings open with the characters `q`{ and close with
        the token }. In between must be valid D tokens.
        The { and } tokens nest.
        The string is formed of all the characters between the opening
        and closing of the token string, including comments.
        

---
q{this is the voice of} // "this is the voice of"
q{/*}*/ }               // "/*}*/ "
q{ world(q{control}); } // " world(q{control}); "
q{ __TIME__ }           // " __TIME__ "
                        // i.e. it is not replaced with the time
// q{ __EOF__ }         // error
                        // __EOF__ is not a token, it's end of file

---

See also [istring#InterpolatedTokenLiteral|istring, InterpolatedTokenLiteral]

$(H3 $(ID hex_strings) Hex Strings)
$(PRE $(CLASS GRAMMAR)
$(B $(ID HexString) HexString):
    $(B x") [#HexStringChars|HexStringChars]$(SUBSCRIPT opt) $(B ") [#StringPostfix|StringPostfix]$(SUBSCRIPT opt)

$(B $(ID HexStringChars) HexStringChars):
    [#HexStringChar|HexStringChar]
    [#HexStringChar|HexStringChar] HexStringChars

$(B $(ID HexStringChar) HexStringChar):
    [#HexDigit|HexDigit]
    [#WhiteSpace|WhiteSpace]
    [#EndOfLine|EndOfLine]

)

        Hex strings allow string literals to be created using hex data.
        The hex data need not form valid UTF characters.
        

---
x"0A"              // same as "\x0A"
x"00 FBCD 32FD 0A" // same as "\x00\xFB\xCD\x32\xFD\x0A"

---

        Whitespace and newlines are ignored, so the hex data can be easily
        formatted. The number of hex characters must be a multiple of 2.

$(H3 $(ID string_postfix) String Postfix)

$(PRE $(CLASS GRAMMAR)
$(B $(ID StringPostfix) StringPostfix):
    $(B c)
    $(B w)
    $(B d)

)

        The optional $(I StringPostfix) character gives a specific type
        to the string, rather than it being inferred from the context.
        The types corresponding to the postfix characters are:
        


        $(TABLE_ROWS
String Literal Postfix Characters
        * + Postfix
+ Type
+ Alias

        * - $(B c)
- `immutable(char)[]`
- `string`

        * - $(B w)
- `immutable(wchar)[]`
- `wstring`

        * - $(B d)
- `immutable(dchar)[]`
- `dstring`

        
)

---
"hello"c  // string
"hello"w  // wstring
"hello"d  // dstring

---

        The string literals are assembled as UTF-8 char arrays,
        and the postfix is applied
        to convert to wchar or dchar as necessary as a final step.

$(H2 $(ID escape_sequences) Escape Sequences)

$(PRE $(CLASS GRAMMAR)
$(B $(ID EscapeSequence) EscapeSequence):
    $(B \')
    $(B \")
    $(B \?)
    $(B \\)
    $(B \0)
    $(B \a)
    $(B \b)
    $(B \f)
    $(B \n)
    $(B \r)
    $(B \t)
    $(B \v)
    $(B \x) [#HexDigit|HexDigit] [#HexDigit|HexDigit]
    $(B \) [#OctalDigit|OctalDigit]
    $(B \) [#OctalDigit|OctalDigit] [#OctalDigit|OctalDigit]
    $(B \) [#OctalDigit|OctalDigit] [#OctalDigit|OctalDigit] [#OctalDigit|OctalDigit]
    $(B \u) [#HexDigit|HexDigit] [#HexDigit|HexDigit] [#HexDigit|HexDigit] [#HexDigit|HexDigit]
    $(B \U) [#HexDigit|HexDigit] [#HexDigit|HexDigit] [#HexDigit|HexDigit] [#HexDigit|HexDigit] [#HexDigit|HexDigit] [#HexDigit|HexDigit] [#HexDigit|HexDigit] [#HexDigit|HexDigit]
    $(B \) [entity#NamedCharacterEntity|entity, NamedCharacterEntity]

$(B $(ID OctalDigit) OctalDigit):
    $(B 0)
    $(B 1)
    $(B 2)
    $(B 3)
    $(B 4)
    $(B 5)
    $(B 6)
    $(B 7)

)

    $(TABLE_ROWS
Escape Sequences
    * + Sequence
+ Meaning
     * - `\'`
- Literal single-quote: `'`

    * - `\"`
- Literal double-quote: `"`

    * - `\?`
- Literal question mark: `?`

    * - `\\`
- Literal backslash: `\`

    * - `\0`
- Binary zero (NUL, U+0000).

    * - `\a`
- BEL (alarm) character (U+0007).

    * - `\b`
- Backspace (U+0008).

    * - `\f`
- Form feed (FF) (U+000C).

    * - `\n`
- End-of-line (U+000A).

    * - `\r`
- Carriage return (U+000D).

    * - `\t`
- Horizontal tab (U+0009).

    * - `\v`
- Vertical tab (U+000B).

    * - `\x`$(I nn)
- Byte value in hexadecimal, where $(I nn) is
        specified as two hexadecimal digits.<br>For example: `\xFF`
        represents the character with the value 255.<br>
        See also: $(REF hexString, std,conv).

    * - `\`$(I n)<br>`\`$(I nn)<br>`\`$(I nnn)
- Byte value in
        octal.<br>For example: `\101` represents the character with the
        value 65 (`'A'`). Analogous to hexadecimal characters,
        the largest byte value is `\377` (= `\xFF` in hexadecimal
        or `255` in decimal)<br>
        See also: $(REF octal, std,conv).

    * - `\u`$(I nnnn)
- Unicode character U+$(I nnnn), where
        $(I nnnn) are four hexadecimal digits.<br>For example,
        `\u03B3` represents the Unicode character &x03b3; (U+03B3 - GREEK SMALL LETTER GAMMA).

    * - `\U`$(I nnnnnnnn)
- Unicode character U+$(I nnnnnnnn),
        where $(I nnnnnnnn) are 8 hexadecimal digits.<br>For example,
        `\U0001F603` represents the Unicode character U+1F603 (SMILING FACE
        WITH OPEN MOUTH).

    * - `\`$(I name)
- Named character entity from the HTML5
        specification. <br>
        These names begin with & and end with `;`, e.g., `&euro;`.
        See [entity#NamedCharacterEntity|entity, NamedCharacterEntity].

    
)

$(H2 $(ID characterliteral) Character Literals)

$(PRE $(CLASS GRAMMAR)
$(B $(ID CharacterLiteral) CharacterLiteral):
    $(B ') [#SingleQuotedCharacter|SingleQuotedCharacter] $(B ')

$(B $(ID SingleQuotedCharacter) SingleQuotedCharacter):
    [#Character|Character]
    [#EscapeSequence|EscapeSequence]

)

Character literals are a single character or escape sequence enclosed by
single quotes.

---
'h'   // the letter h
'\n'  // newline
'\\'  // the backslash character

---

A character literal resolves to one
    of type `char`, `wchar`, or `dchar`
    (see $(LINK2 spec/type#basic-data-types,Basic Data Types)).

$(LIST
    * If the literal is a `\u` escape sequence, it resolves to type `wchar`.
    * If the literal is a `\U` escape sequence, it resolves to type `dchar`.

)
Otherwise, it resolves to the type with the smallest size it
    will fit into.

$(H2 $(ID integerliteral) Integer Literals)

$(PRE $(CLASS GRAMMAR)
$(B $(ID IntegerLiteral) IntegerLiteral):
    [#Integer|Integer]
    [#Integer|Integer] [#IntegerSuffix|IntegerSuffix]

$(B $(ID Integer) Integer):
    [#DecimalInteger|DecimalInteger]
    [#BinaryInteger|BinaryInteger]
    [#HexadecimalInteger|HexadecimalInteger]

$(B $(ID IntegerSuffix) IntegerSuffix):
    $(B L)
    $(B u)
    $(B U)
    $(B Lu)
    $(B LU)
    $(B uL)
    $(B UL)

)

$(PRE $(CLASS GRAMMAR)
$(B $(ID DecimalInteger) DecimalInteger):
    $(B 0) [#Underscores|Underscores]$(SUBSCRIPT opt)
    [#NonZeroDigit|NonZeroDigit]
    [#NonZeroDigit|NonZeroDigit] [#DecimalDigitsUS|DecimalDigitsUS]

$(B $(ID Underscores) Underscores):
    $(B _)
    [#Underscores|Underscores] $(B _)

$(B $(ID NonZeroDigit) NonZeroDigit):
    $(B 1)
    $(B 2)
    $(B 3)
    $(B 4)
    $(B 5)
    $(B 6)
    $(B 7)
    $(B 8)
    $(B 9)

$(B $(ID DecimalDigits) DecimalDigits):
    [#DecimalDigit|DecimalDigit]
    [#DecimalDigit|DecimalDigit] DecimalDigits

$(B $(ID DecimalDigitsUS) DecimalDigitsUS):
    [#DecimalDigitUS|DecimalDigitUS]
    [#DecimalDigitUS|DecimalDigitUS] DecimalDigitsUS

$(B $(ID DecimalDigitsNoSingleUS) DecimalDigitsNoSingleUS):
    [#DecimalDigitsUS|DecimalDigitsUS]$(SUBSCRIPT opt) [#DecimalDigit|DecimalDigit] [#DecimalDigitsUS|DecimalDigitsUS]$(SUBSCRIPT opt)

$(B $(ID DecimalDigitsNoStartingUS) DecimalDigitsNoStartingUS):
    [#DecimalDigit|DecimalDigit]
    [#DecimalDigit|DecimalDigit] [#DecimalDigitsUS|DecimalDigitsUS]

$(B $(ID DecimalDigit) DecimalDigit):
    $(B 0)
    [#NonZeroDigit|NonZeroDigit]

$(B $(ID DecimalDigitUS) DecimalDigitUS):
    [#DecimalDigit|DecimalDigit]
    $(B _)

)

$(PRE $(CLASS GRAMMAR)
$(B $(ID BinaryInteger) BinaryInteger):
    [#BinPrefix|BinPrefix] [#BinaryDigitsNoSingleUS|BinaryDigitsNoSingleUS]

$(B $(ID BinPrefix) BinPrefix):
    $(B 0b)
    $(B 0B)

$(B $(ID BinaryDigitsNoSingleUS) BinaryDigitsNoSingleUS):
    [#BinaryDigitsUS|BinaryDigitsUS]$(SUBSCRIPT opt) [#BinaryDigit|BinaryDigit] [#BinaryDigitsUS|BinaryDigitsUS]$(SUBSCRIPT opt)

$(B $(ID BinaryDigitsUS) BinaryDigitsUS):
    [#BinaryDigitUS|BinaryDigitUS]
    [#BinaryDigitUS|BinaryDigitUS] BinaryDigitsUS

$(B $(ID BinaryDigit) BinaryDigit):
    $(B 0)
    $(B 1)

$(B $(ID BinaryDigitUS) BinaryDigitUS):
    [#BinaryDigit|BinaryDigit]
    $(B _)

)

$(PRE $(CLASS GRAMMAR)
$(B $(ID HexadecimalInteger) HexadecimalInteger):
    [#HexPrefix|HexPrefix] [#HexDigitsNoSingleUS|HexDigitsNoSingleUS]

$(B $(ID HexDigits) HexDigits):
    [#HexDigit|HexDigit]
    [#HexDigit|HexDigit] HexDigits

$(B $(ID HexDigitsUS) HexDigitsUS):
    [#HexDigitUS|HexDigitUS]
    [#HexDigitUS|HexDigitUS] HexDigitsUS

$(B $(ID HexDigitsNoSingleUS) HexDigitsNoSingleUS):
    [#HexDigitsUS|HexDigitsUS]$(SUBSCRIPT opt) [#HexDigit|HexDigit] [#HexDigitsUS|HexDigitsUS]$(SUBSCRIPT opt)

$(B $(ID HexDigitsNoStartingUS) HexDigitsNoStartingUS):
    [#HexDigit|HexDigit]
    [#HexDigit|HexDigit] [#HexDigitsUS|HexDigitsUS]

$(B $(ID HexDigit) HexDigit):
    [#DecimalDigit|DecimalDigit]
    [#HexLetter|HexLetter]

$(B $(ID HexDigitUS) HexDigitUS):
    [#HexDigit|HexDigit]
    $(B _)

$(B $(ID HexLetter) HexLetter):
    $(B a)
    $(B b)
    $(B c)
    $(B d)
    $(B e)
    $(B f)
    $(B A)
    $(B B)
    $(B C)
    $(B D)
    $(B E)
    $(B F)

)

        Integers can be specified in decimal, binary, or hexadecimal.

        $(LIST
        * Decimal integers are a sequence of decimal digits.

        * $(ID binary-literals) Binary integers are a sequence of binary digits preceded
        by a '0b' or '0B'.
        

        * C-style octal integer notation (e.g. `0167`) was deemed too easy to mix up with decimal notation;
        it is only fully supported in string literals.
        D still supports octal integer literals interpreted at compile time through the $(REF octal, std,conv)
        template, as in `octal!167`.

        * Hexadecimal integers are a sequence of hexadecimal digits preceded
        by a '0x' or '0X'.
        
        
)

---
10      // decimal
0b1010  // binary
0xA     // hex

---

        Integers can have embedded '_' characters after a digit to improve readability, which are ignored.
        

---
20_000        // leagues under the sea
867_5309      // number on the wall
1_522_000     // thrust of F1 engine (lbf sea level)
0xBAAD_F00D   // magic number for debugging

---

        Integers can be immediately followed by one 'L' or one of
        'u' or 'U' or both.
        Note that there is no 'l' suffix.
        

        The type of the integer is resolved as follows:

        $(TABLE_ROWS
Decimal Literal Types
        * + Literal
+ Type

    $(RAW_HTML <td colspan="10">$(I Usual decimal notation)</td>)
        * - `0 .. 2_147_483_647`
- `int`

        * - `2_147_483_648 .. 9_223_372_036_854_775_807`
- `long`

        * - `9_223_372_036_854_775_808 .. 18_446_744_073_709_551_615`
- `ulong`

    ---------
    $(RAW_HTML <td colspan="10">$(I Explicit suffixes)</td>)
        * - `0L .. 9_223_372_036_854_775_807L`
- `long`

        * - `0U .. 4_294_967_295U`
- `uint`

        * - `4_294_967_296U .. 18_446_744_073_709_551_615U`
- `ulong`

        * - `0UL .. 18_446_744_073_709_551_615UL`
- `ulong`

    ---------
    $(RAW_HTML <td colspan="10">$(I Hexadecimal notation)</td>)
        * - `0x0 .. 0x7FFF_FFFF`
- `int`

        * - `0x8000_0000 .. 0xFFFF_FFFF`
- `uint`

        * - `0x1_0000_0000 .. 0x7FFF_FFFF_FFFF_FFFF`
- `long`

        * - `0x8000_0000_0000_0000 .. 0xFFFF_FFFF_FFFF_FFFF`
- `ulong`

    ---------
    $(RAW_HTML <td colspan="10">$(I Hexadecimal notation with explicit suffixes)</td>)
        * - `0x0L .. 0x7FFF_FFFF_FFFF_FFFFL`
- `long`

        * - `0x8000_0000_0000_0000L .. 0xFFFF_FFFF_FFFF_FFFFL`
- `ulong`

        * - `0x0U .. 0xFFFF_FFFFU`
- `uint`

        * - `0x1_0000_0000U .. 0xFFFF_FFFF_FFFF_FFFFU`
- `ulong`

        * - `0x0UL .. 0xFFFF_FFFF_FFFF_FFFFUL`
- `ulong`

        
)

        An integer literal may not exceed these values.

        $(TIP Octal integer notation is not supported for integer literals.
        However, octal integer literals can be interpreted at compile time through
        the $(REF octal, std,conv) template, as in `octal!167`.)



$(H2 $(ID floatliteral) Floating Point Literals)

$(PRE $(CLASS GRAMMAR)
$(B $(ID FloatLiteral) FloatLiteral):
    [#Float|Float] [#Suffix|Suffix]$(SUBSCRIPT opt)
    [#Integer|Integer] [#FloatSuffix|FloatSuffix] [#ImaginarySuffix|ImaginarySuffix]$(SUBSCRIPT opt)
    [#Integer|Integer] [#RealSuffix|RealSuffix]$(SUBSCRIPT opt) [#ImaginarySuffix|ImaginarySuffix]

$(B $(ID Float) Float):
    [#DecimalFloat|DecimalFloat]
    [#HexFloat|HexFloat]

$(B $(ID DecimalFloat) DecimalFloat):
    [#LeadingDecimal|LeadingDecimal] $(B .) [#DecimalDigitsNoStartingUS|DecimalDigitsNoStartingUS]$(SUBSCRIPT opt)
    [#LeadingDecimal|LeadingDecimal] $(B .) [#DecimalDigitsNoStartingUS|DecimalDigitsNoStartingUS] [#DecimalExponent|DecimalExponent]
    $(B .) [#DecimalDigitsNoStartingUS|DecimalDigitsNoStartingUS] [#DecimalExponent|DecimalExponent]$(SUBSCRIPT opt)
    [#LeadingDecimal|LeadingDecimal] [#DecimalExponent|DecimalExponent]

$(B $(ID DecimalExponent) DecimalExponent):
    [#DecimalExponentStart|DecimalExponentStart] [#DecimalDigitsNoSingleUS|DecimalDigitsNoSingleUS]

$(B $(ID DecimalExponentStart) DecimalExponentStart):
    $(B e)
    $(B E)
    $(B e+)
    $(B E+)
    $(B e-)
    $(B E-)

$(B $(ID HexFloat) HexFloat):
    [#HexPrefix|HexPrefix] [#HexDigitsNoSingleUS|HexDigitsNoSingleUS] $(B .) [#HexDigitsNoStartingUS|HexDigitsNoStartingUS] [#HexExponent|HexExponent]
    [#HexPrefix|HexPrefix] $(B .) [#HexDigitsNoStartingUS|HexDigitsNoStartingUS] [#HexExponent|HexExponent]
    [#HexPrefix|HexPrefix] [#HexDigitsNoSingleUS|HexDigitsNoSingleUS] [#HexExponent|HexExponent]

$(B $(ID HexPrefix) HexPrefix):
    $(B 0x)
    $(B 0X)

$(B $(ID HexExponent) HexExponent):
    [#HexExponentStart|HexExponentStart] [#DecimalDigitsNoSingleUS|DecimalDigitsNoSingleUS]

$(B $(ID HexExponentStart) HexExponentStart):
    $(B p)
    $(B P)
    $(B p+)
    $(B P+)
    $(B p-)
    $(B P-)


$(B $(ID Suffix) Suffix):
    [#FloatSuffix|FloatSuffix] [#ImaginarySuffix|ImaginarySuffix]$(SUBSCRIPT opt)
    [#RealSuffix|RealSuffix] [#ImaginarySuffix|ImaginarySuffix]$(SUBSCRIPT opt)
    [#ImaginarySuffix|ImaginarySuffix]

$(B $(ID FloatSuffix) FloatSuffix):
    $(B f)
    $(B F)

$(B $(ID RealSuffix) RealSuffix):
    $(B L)

DEPRECATED: {$(B $(ID ImaginarySuffix) ImaginarySuffix)}:
    $(B i)

$(B $(ID LeadingDecimal) LeadingDecimal):
    [#DecimalInteger|DecimalInteger]
    $(B 0) [#DecimalDigitsNoSingleUS|DecimalDigitsNoSingleUS]

)

        Floats can be in decimal or hexadecimal format, and must have
        at least one digit and either a decimal point, an exponent, or
        a <em>FloatSuffix</em>.

        Decimal floats can have an exponent which is `e` or `E` followed
        by a decimal number serving as the exponent of 10.

---
-1.0
1e2               // 100.0
1e-2              // 0.01
-1.175494351e-38F // float.min

---

        Hexadecimal floats are preceded by a $(B 0x) or $(B 0X) and the
        exponent is a $(B p) or $(B P) followed by a decimal number serving as
        the exponent of 2.
        

---
0xAp0                  // 10.0
0x1p2                  // 4.0
0x1.FFFFFFFFFFFFFp1023 // double.max
0x1p-52                // double.epsilon

---

        Floating literals can have embedded `_` characters
        after a digit to improve readability, which are ignored.
        

---
2.645_751
6.022140857E+23
6_022.140857E+20
6_022_.140_857E+20_

---

$(LIST
* Floating literals with no suffix are of type `double`.
* Floating literals followed by $(B f) or $(B F) are of type `float`.
* Floating literals followed by $(B L) are of type `real`.


)
---
0.0                    // double
0F                     // float
0.0L                   // real

---

        The literal may not exceed the range of the type.
        The literal is rounded to fit into
        the significant digits of the type.
        
        If a floating literal has a `.` and a type suffix, at least one
            digit must be in-between:

---
1f;  // OK, float
1.f; // error
1.;  // OK, double

---

        Note: Floating literals followed by $(B i) to denote imaginary
        floating point values have been deprecated.


$(H2 $(ID keywords) Keywords)

        Keywords are reserved identifiers.


$(PRE $(CLASS GRAMMAR)
$(B $(ID Keyword) Keyword):
    $(LINK2 attribute.html#abstract, `abstract`)
    $(LINK2 declaration.html#alias, `alias`)
    $(LINK2 attribute.html#align, `align`)
    $(LINK2 statement.html#AsmStatement, `asm`)
    $(LINK2 expression.html#AssertExpression, `assert`)
    $(LINK2 attribute.html#auto, `auto`)

    DEPRECATED: {$(LINK2 function.html#BodyStatement, `body`)}
    $(LINK2 type.html, `bool`)
    $(LINK2 statement.html#BreakStatement, `break`)
    $(LINK2 type.html, `byte`)

    $(LINK2 statement.html#SwitchStatement, `case`)
    $(LINK2 expression.html#CastExpression, `cast`)
    $(LINK2 statement.html#TryStatement, `catch`)
    DEPRECATED: {$(LINK2 type.html, `cdouble`)}
    DEPRECATED: {$(LINK2 type.html, `cent`)}
    DEPRECATED: {$(LINK2 type.html, `cfloat`)}
    $(LINK2 type.html, `char`)
    $(LINK2 class.html, `class`)
    $(LINK2 attribute.html#const, `const`)
    $(LINK2 statement.html#ContinueStatement, `continue`)
    DEPRECATED: {$(LINK2 type.html, `creal`)}

    $(LINK2 type.html, `dchar`)
    $(LINK2 version.html#debug, `debug`)
    $(LINK2 statement.html#SwitchStatement, `default`)
    $(LINK2 type.html#delegates, `delegate`)
    DEPRECATED: {$(LINK2 expression.html#DeleteExpression, `delete`)}
    $(LINK2 attribute.html#deprecated, `deprecated`)
    $(LINK2 statement.html#DoStatement, `do`)
    $(LINK2 type.html, `double`)

    $(LINK2 statement.html#IfStatement, `else`)
    $(LINK2 enum.html, `enum`)
    $(LINK2 attribute.html#visibility_attributes, `export`)
    $(LINK2 attribute.html#linkage, `extern`)

    $(LINK2 type.html, `false`)
    $(LINK2 class.html#final, `final`)
    $(LINK2 statement.html#TryStatement, `finally`)
    $(LINK2 type.html, `float`)
    $(LINK2 statement.html#ForStatement, `for`)
    $(LINK2 statement.html#ForeachStatement, `foreach`)
    $(LINK2 statement.html#ForeachStatement, `foreach_reverse`)
    $(LINK2 expression.html#FunctionLiteral, `function`)

    $(LINK2 statement.html#GotoStatement, `goto`)

    DEPRECATED: {$(LINK2 type.html, `idouble`)}
    $(LINK2 statement.html#IfStatement, `if`)
    DEPRECATED: {$(LINK2 type.html, `ifloat`)}
    $(LINK2 attribute.html#immutable, `immutable`)
    $(LINK2 expression.html#ImportExpression, `import`)
    $(LINK2 expression.html#InExpression, `in`)
    $(LINK2 function.html#inout-functions, `inout`)
    $(LINK2 type.html, `int`)
    $(LINK2 interface.html, `interface`)
    $(LINK2 contracts.html, `invariant`)
    DEPRECATED: {$(LINK2 type.html, `ireal`)}
    $(LINK2 expression.html#IsExpression, `is`)

    $(LINK2 function.html#overload-sets, `lazy`)
    $(LINK2 type.html, `long`)

    RESERVED: {`macro`}
    $(LINK2 expression.html#MixinExpression, `mixin`)
    $(LINK2 module.html#ModuleDeclaration, `module`)

    $(LINK2 expression.html#NewExpression, `new`)
    $(LINK2 function.html#nothrow-functions, `nothrow`)
    $(LINK2 expression.html#null, `null`)

    $(LINK2 function.html#OutStatement, `out`)
    $(LINK2 attribute.html#override, `override`)

    $(LINK2 attribute.html#visibility_attributes, `package`)
    $(LINK2 pragma.html, `pragma`)
    $(LINK2 attribute.html#visibility_attributes, `private`)
    $(LINK2 attribute.html#visibility_attributes, `protected`)
    $(LINK2 attribute.html#visibility_attributes, `public`)
    $(LINK2 function.html#pure-functions, `pure`)

    $(LINK2 type.html, `real`)
    $(LINK2 function.html#ref-functions, `ref`)
    $(LINK2 statement.html#ReturnStatement, `return`)

    $(LINK2 statement.html#ScopeGuardStatement, `scope`)
    $(LINK2 attribute.html#shared, `shared`)
    $(LINK2 type.html, `short`)
    $(LINK2 version.html#staticif, `static`)
    $(LINK2 struct.html, `struct`)
    $(LINK2 expression.html#super, `super`)
    $(LINK2 statement.html#SwitchStatement, `switch`)
    $(LINK2 statement.html#SynchronizedStatement, `synchronized`)

    $(LINK2 template.html, `template`)
    $(LINK2 expression.html#this, `this`)
    $(LINK2 statement.html#ThrowStatement, `throw`)
    $(LINK2 type.html, `true`)
    $(LINK2 statement.html#TryStatement, `try`)
    $(LINK2 expression.html#TypeidExpression, `typeid`)
    $(LINK2 type.html#Typeof, `typeof`)

    $(LINK2 type.html, `ubyte`)
    DEPRECATED: {$(LINK2 type.html, `ucent`)}
    $(LINK2 type.html, `uint`)
    $(LINK2 type.html, `ulong`)
    $(LINK2 struct.html, `union`)
    $(LINK2 unittest.html, `unittest`)
    $(LINK2 type.html, `ushort`)

    $(LINK2 version.html#version, `version`)
    $(LINK2 declaration.html#VoidInitializer, `void`)

    $(LINK2 type.html, `wchar`)
    $(LINK2 statement.html#WhileStatement, `while`)
    $(LINK2 statement.html#WithStatement, `with`)

    $(LINK2 expression.html#specialkeywords, `__FILE__`)
    $(LINK2 expression.html#specialkeywords, `__FILE_FULL_PATH__`)
    $(LINK2 expression.html#specialkeywords, `__MODULE__`)
    $(LINK2 expression.html#specialkeywords, `__LINE__`)
    $(LINK2 expression.html#specialkeywords, `__FUNCTION__`)
    $(LINK2 expression.html#specialkeywords, `__PRETTY_FUNCTION__`)

    $(LINK2 attribute.html#gshared, `__gshared`)
    $(LINK2 traits.html, `__traits`)
    $(LINK2 phobos/core_simd.html#.Vector, `__vector`)
    $(LINK2 expression.html#IsExpression, `__parameters`)


)


$(H2 $(ID specialtokens) Special Tokens)

                These tokens are replaced with other tokens according to the following
        table:
        

        $(TABLE_ROWS
Special Tokens
        * + Special Token
+ Replaced with


        * - `__DATE__`
- string literal of the date of compilation "$(I mmm dd yyyy)"

        * - `__EOF__`
- tells the scanner to ignore everything after this token


        * - `__TIME__`
- string literal of the time of compilation "$(I hh:mm:ss)"

        * - `__TIMESTAMP__`
- string literal of the date and time of compilation "$(I www mmm dd hh:mm:ss yyyy)"

        * - `__VENDOR__`
- Compiler vendor string

        * - `__VERSION__`
- Compiler version as an integer

        
)

        $(WARNING         The replacement string literal for `__VENDOR__` and the replacement integer value for `__VERSION__`.
        )

$(H2 $(ID special-token-sequence)Special Token Sequences)

$(PRE $(CLASS GRAMMAR)
$(B $(ID SpecialTokenSequence) SpecialTokenSequence):
    `# line` [#IntegerLiteral|IntegerLiteral] [#Filespec|Filespec]$(SUBSCRIPT opt) [#EndOfLine|EndOfLine]
    `# line` `__LINE__` [#Filespec|Filespec]$(SUBSCRIPT opt) [#EndOfLine|EndOfLine]

)
$(PRE $(CLASS GRAMMAR)
$(B $(ID Filespec) Filespec):
    $(B ") [#DoubleQuotedCharacters|DoubleQuotedCharacters]$(SUBSCRIPT opt) $(B ")

)

        Special token sequences are processed by the lexical analyzer, may
        appear between any other tokens, and do not affect the syntax
        parsing.
        

        Special token sequences are terminated by the first newline that
            follows the first `#` token at the beginning of the sequence.
        

        There is currently only one special token sequence, `#line`.
        

        This sets the line number of the next source line to [#IntegerLiteral|IntegerLiteral],
        and optionally the current source file name to [#Filespec|Filespec],
        beginning with the next line of source text.
        

        For example:
        

---
int #line 6 "pkg/mod.d"
x;  // this is now line 6 of file pkg/mod.d

---

        $(WARNING         The source file and line number is typically used for printing error messages
        and for mapping generated code back to the source for the symbolic
        debugging output.
        )

intro, Introduction, istring, Interpolation Expression Sequence




Link_References:
	ACC = Associated C Compiler
+/
module lex.dd;