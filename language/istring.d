// just docs: Interpolation Expression Sequence
/++





Interpolation Expression Sequences (IES) are expressions that intersperse
string literal data and values. An interpolation expression is written like a
string, but can contain values that are passed directly to a function that is
able to accept them. It is transformed into a $(I Sequence) of expressions that
can be overloaded or handled by template functions.

$(H2 $(ID ies) IES Literals)

$(PRE $(CLASS GRAMMAR)
$(B $(ID InterpolationExpressionSequence) InterpolationExpressionSequence):
    [#InterpolatedDoubleQuotedLiteral|InterpolatedDoubleQuotedLiteral]
    [#InterpolatedWysiwygLiteral|InterpolatedWysiwygLiteral]
    [#InterpolatedTokenLiteral|InterpolatedTokenLiteral]

)

An Interpolation Expression sequence can be either wysiwyg quoted, double
quoted, or a token literal. Only double quoted literals can have escapes in
them.

Unlike string literals, IES literals cannot have a suffix defining the
width of the character type for the string expressions.

$(H3 $(ID ies_doublequoted) Double Quoted IES Literals)

$(PRE $(CLASS GRAMMAR)
$(B $(ID InterpolatedDoubleQuotedLiteral) InterpolatedDoubleQuotedLiteral):
    $(B i") [#InterpolatedDoubleQuotedCharacters|InterpolatedDoubleQuotedCharacters]$(SUBSCRIPT opt) $(B ")

$(B $(ID InterpolatedDoubleQuotedCharacters) InterpolatedDoubleQuotedCharacters):
    [#InterpolatedDoubleQuotedCharacter|InterpolatedDoubleQuotedCharacter]
    [#InterpolatedDoubleQuotedCharacter|InterpolatedDoubleQuotedCharacter] InterpolatedDoubleQuotedCharacters

$(B $(ID InterpolatedDoubleQuotedCharacter) InterpolatedDoubleQuotedCharacter):
    [lex#DoubleQuotedCharacter|lex, DoubleQuotedCharacter]
    [#InterpolationEscapeSequence|InterpolationEscapeSequence]
    [#InterpolationExpression|InterpolationExpression]

$(B $(ID InterpolationEscapeSequence) InterpolationEscapeSequence):
    [#EscapeSequence|EscapeSequence]
    $(B \$)

$(B $(ID InterpolationExpression) InterpolationExpression):
    $(B $() [#AssignExpression|AssignExpression] $(B ))

)

Like [lex#DoubleQuotedString|lex, DoubleQuotedString], double-quoted IES literals can
have escape characters in them. Added to the normal escapes is the ability to
escape a literal $

A $ followed by any character other than a left parenthesis is treated as a
literal $ in the expression, there is no need to escape it.

The expression inside an [#InterpolationExpression|InterpolationExpression] is a full D
expression, and escapes are not needed inside that part of the expression.

$(H3 $(ID ies_wysiwyg) Wysiwyg IES Literals)

$(PRE $(CLASS GRAMMAR)
$(B $(ID InterpolatedWysiwygLiteral) InterpolatedWysiwygLiteral):
    $(B i`) [#InterpolatedWysiwygCharacters|InterpolatedWysiwygCharacters]$(SUBSCRIPT opt) $(B `)

$(B $(ID InterpolatedWysiwygCharacters) InterpolatedWysiwygCharacters):
    [#InterpolatedWysiwygCharacter|InterpolatedWysiwygCharacter]
    [#InterpolatedWysiwygCharacter|InterpolatedWysiwygCharacter] InterpolatedWysiwygCharacters

$(B $(ID InterpolatedWysiwygCharacter) InterpolatedWysiwygCharacter):
    [lex#WysiwygCharacter|lex, WysiwygCharacter]
    [#InterpolationExpression|InterpolationExpression]

)

Wysiwyg ("what you see is what you get") IES literals are defined like
[lex#WysiwygString|lex, WysiwygString] strings, but only support backquote syntax. No
escapes are recognized inside these literals.

$(H3 $(ID ies_token) Token IES Literals)

$(PRE $(CLASS GRAMMAR)
$(B $(ID InterpolatedTokenLiteral) InterpolatedTokenLiteral):
    `iq{` [#InterpolatedTokenStringTokens|InterpolatedTokenStringTokens]$(SUBSCRIPT opt) `}`

$(B $(ID InterpolatedTokenStringTokens) InterpolatedTokenStringTokens):
    [#InterpolatedTokenStringToken|InterpolatedTokenStringToken]
    [#InterpolatedTokenStringToken|InterpolatedTokenStringToken] InterpolatedTokenStringTokens

$(B $(ID InterpolatedTokenStringToken) InterpolatedTokenStringToken):
    [#InterpolatedTokenNoBraces|InterpolatedTokenNoBraces]
    $(B {) InterpolatedTokenStringTokens$(SUBSCRIPT opt) $(B })

$(B $(ID InterpolatedTokenNoBraces) InterpolatedTokenNoBraces):
    [lex#TokenNoBraces|lex, TokenNoBraces]
    [#InterpolationExpression|InterpolationExpression]

)

Like [lex#TokenString|lex, TokenString], IES Token literals must contain only
valid D tokens, with the exception of [#InterpolationExpression|InterpolationExpression]. No
escapes are recognized.

$(H2 $(ID expression_translation) Expression Translation)

When the lexer encounters an Interpolation Expression Sequence, the token
is translated into a sequence of expressions, which replaces the single token.
The sequence always starts with the expression
`core.interpolation.InterpolationHeader()` and always ends with
`core.interpolation.InterpolationFooter()`

Each part `str` of the token which is literal string data is translated
into the expression `core.interpolation.InterpolatedLiteral!(str)`

Each part `$(expr)` of the token which is an [#InterpolationExpression|InterpolationExpression] is translated into the sequence `core.interpolation.InterpolatedExpression!(expr), expr`.

---
// simple version of std.typecons.Tuple
struct Tuple(T...) { T value; }
Tuple!T tuple(T...)(T value) { return Tuple!T(value); }

import core.interpolation;
string name = "John Doe";
auto items = tuple(i"Hello, $(name), how are you?");
assert(items == tuple(
    InterpolationHeader(),                       // denotes the start of an IES
    InterpolatedLiteral!("Hello, ")(),           // literal string data
    InterpolatedExpression!("name")(),           // expression literal data
    name,                                        // expression passed directly
    InterpolatedLiteral!(", how are you?")(),    // literal string data
    InterpolationFooter()));                     // denotes the end of an IES

---

$(H2 $(ID core_interpolation) core.interpolation Types)

Types defined in `core.interpolation` need not be imported to use IES.
These are automatically imported when an IES is used. The types are defined so
as to make it easy to introspect the IES for processing at compile-time.

$(H3 $(ID interp_header) InterpolationHeader and InterpolationFooter)

The `InterpolationHeader` and `InterpolationFooter` type are empty
structs that allow easy overloading of functions to handle IES. They also can
be used to understand which parts of a expression list were passed via IES.

These types have a `toString` definition that returns an empty string,
to allow for processing by functions which intend to convert IES to text, such
as $(REF writeln, std,stdio) or $(REF text, std,conv).

$(H3 $(ID interp_literal) InterpolatedLiteral)

The `InterpolatedLiteral` type is an empty struct that provides
compile-time access to the string literal portion of an IES. This type also
provides a `toString` member function which returns the part of the
sequence that this value replaced.

$(H3 $(ID interp_literal) InterpolatedExpression)

The `InterpolatedExpression` type is an empty struct that provides
compile-time access to the literal that was used to form the following
expression. It provides a `toString` member function which returns the empty
string. It also has an `enum expression` member, which is equal to the
template parameter used to construct the type.

---
string name = "John Doe";
auto ies = i"Hello, $(name)";
static assert(is(typeof(ies[0]) == InterpolationHeader));
static assert(ies[1].toString() == "Hello, ");
static assert(ies[2].expression == "name");
assert(ies[3] == name);
static assert(is(typeof(ies[4]) == InterpolationFooter));

---

$(H2 $(ID accepting) Accepting and Processing IES)

The recommended mechanism to accept IES is to provide a variadic template
function to match the various parameters inside the sequence, surrounded by
explicit `InterpolationHeader` and `InterpolationFooter` parameters.

---
void processIES(Sequence...)(InterpolationHeader, Sequence data, InterpolationFooter)
{
    // process `data` here
}

---

An IES can also contain types as interpolation expressions. This can be
used by passing to a variadic template parameter.

---
template processIESAtCompileTime(InterpolationHeader header, Sequence...)
{
    static assert(Sequence[$-1] == InterpolationFooter());
}

alias result = processIES!i"Here is a type: $(int)";

---

$(H2 $(ID tostring) Converting to a String)

In many cases, it is desirable to convert an IES to a `string`. The
Phobos function $(REF text, std,conv) can convert the IES to a `string` for use
in any context where a string is needed, for instance to assign to a string
variable, or call a function that accepts a string.

---
import std.conv : text;
string name = "John Doe";

string badgreeting = i"Hello, $(name)"; // Error
string greeting = i"Hello, $(name)".text; // OK
assert(greeting == "Hello, John Doe");

---

It is highly recommended for library authors who wish to accept IES to
provide an overload that accepts them, rather than rely on `std.conv`, as
this incurs unnecessary allocations. This is especially important where certain
types of injection attacks are possible from malicious user-provided data.

lex, Lexical, grammar, Grammar




Link_References:
	ACC = Associated C Compiler
+/
module istring.dd;