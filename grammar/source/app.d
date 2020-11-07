module command.grammar;
import pegged.grammar;

void main() {
    asModule("command.grammar", "../lib/source/command/grammar", `
CommandParser:
    Primary < FunctionCall
    # Parens are optional if there's no args
    FunctionCall < FunctionIdentifier (Args / EmptyArgs)?
    FunctionIdentifier < FunctionNamespace? Function
    FunctionNamespace < identifier :'.'
    Function < identifier
    # TO-DO: Expand this further
    ArgTypes < String / HexLiteral / Number / Bool / FunctionCall
    Args <- :'(' Line(ArgTypes, ',') :')'
    EmptyArgs <- :'(' :')'

    # Base types taken from the PEGGED examples
    String <~ :doublequote (!doublequote Char)* :doublequote
    Char   <~ backslash ( doublequote  # '\' Escapes
                        / quote
                        / backslash
                        / [bfnrt]
                        / [0-2][0-7][0-7]
                        / [0-7][0-7]?
                        / 'x' Hex Hex
                        / 'u' Hex Hex Hex Hex
                        / 'U' Hex Hex Hex Hex Hex Hex Hex Hex
                        )
             / . # Or any char, really
    Hex      < ~([0-9a-fA-F]+)
    HexLiteral < '0x' Hex*
    Number   < ~([0-9]+)
    Bool     < ('true' / 'false')

    Line(Elem, Sep = ' ') < Elem (:Sep Elem)*
    `);
}
