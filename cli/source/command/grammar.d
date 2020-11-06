/++
This module was automatically generated from the following grammar:


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
    

+/
module command.grammar;

public import pegged.peg;
import std.algorithm: startsWith;
import std.functional: toDelegate;

struct GenericCommandParser(TParseTree)
{
    import std.functional : toDelegate;
    import pegged.dynamic.grammar;
    static import pegged.peg;
    struct CommandParser
    {
    enum name = "CommandParser";
    static ParseTree delegate(ParseTree)[string] before;
    static ParseTree delegate(ParseTree)[string] after;
    static ParseTree delegate(ParseTree)[string] rules;
    import std.typecons:Tuple, tuple;
    static TParseTree[Tuple!(string, size_t)] memo;
    static this()
    {
        rules["Primary"] = toDelegate(&Primary);
        rules["FunctionCall"] = toDelegate(&FunctionCall);
        rules["FunctionIdentifier"] = toDelegate(&FunctionIdentifier);
        rules["FunctionNamespace"] = toDelegate(&FunctionNamespace);
        rules["Function"] = toDelegate(&Function);
        rules["ArgTypes"] = toDelegate(&ArgTypes);
        rules["Args"] = toDelegate(&Args);
        rules["EmptyArgs"] = toDelegate(&EmptyArgs);
        rules["String"] = toDelegate(&String);
        rules["Char"] = toDelegate(&Char);
        rules["Hex"] = toDelegate(&Hex);
        rules["HexLiteral"] = toDelegate(&HexLiteral);
        rules["Number"] = toDelegate(&Number);
        rules["Bool"] = toDelegate(&Bool);
        rules["Spacing"] = toDelegate(&Spacing);
    }

    template hooked(alias r, string name)
    {
        static ParseTree hooked(ParseTree p)
        {
            ParseTree result;

            if (name in before)
            {
                result = before[name](p);
                if (result.successful)
                    return result;
            }

            result = r(p);
            if (result.successful || name !in after)
                return result;

            result = after[name](p);
            return result;
        }

        static ParseTree hooked(string input)
        {
            return hooked!(r, name)(ParseTree("",false,[],input));
        }
    }

    static void addRuleBefore(string parentRule, string ruleSyntax)
    {
        // enum name is the current grammar name
        DynamicGrammar dg = pegged.dynamic.grammar.grammar(name ~ ": " ~ ruleSyntax, rules);
        foreach(ruleName,rule; dg.rules)
            if (ruleName != "Spacing") // Keep the local Spacing rule, do not overwrite it
                rules[ruleName] = rule;
        before[parentRule] = rules[dg.startingRule];
    }

    static void addRuleAfter(string parentRule, string ruleSyntax)
    {
        // enum name is the current grammar named
        DynamicGrammar dg = pegged.dynamic.grammar.grammar(name ~ ": " ~ ruleSyntax, rules);
        foreach(name,rule; dg.rules)
        {
            if (name != "Spacing")
                rules[name] = rule;
        }
        after[parentRule] = rules[dg.startingRule];
    }

    static bool isRule(string s)
    {
		import std.algorithm : startsWith;
        return s.startsWith("CommandParser.");
    }
    mixin decimateTree;

    alias spacing Spacing;

    static TParseTree Primary(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, FunctionCall, Spacing), "CommandParser.Primary")(p);
        }
        else
        {
            if (auto m = tuple(`Primary`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, FunctionCall, Spacing), "CommandParser.Primary"), "Primary")(p);
                memo[tuple(`Primary`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Primary(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, FunctionCall, Spacing), "CommandParser.Primary")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, FunctionCall, Spacing), "CommandParser.Primary"), "Primary")(TParseTree("", false,[], s));
        }
    }
    static string Primary(GetName g)
    {
        return "CommandParser.Primary";
    }

    static TParseTree FunctionCall(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, FunctionIdentifier, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Args, Spacing), pegged.peg.wrapAround!(Spacing, EmptyArgs, Spacing)), Spacing))), "CommandParser.FunctionCall")(p);
        }
        else
        {
            if (auto m = tuple(`FunctionCall`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, FunctionIdentifier, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Args, Spacing), pegged.peg.wrapAround!(Spacing, EmptyArgs, Spacing)), Spacing))), "CommandParser.FunctionCall"), "FunctionCall")(p);
                memo[tuple(`FunctionCall`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree FunctionCall(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, FunctionIdentifier, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Args, Spacing), pegged.peg.wrapAround!(Spacing, EmptyArgs, Spacing)), Spacing))), "CommandParser.FunctionCall")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, FunctionIdentifier, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Args, Spacing), pegged.peg.wrapAround!(Spacing, EmptyArgs, Spacing)), Spacing))), "CommandParser.FunctionCall"), "FunctionCall")(TParseTree("", false,[], s));
        }
    }
    static string FunctionCall(GetName g)
    {
        return "CommandParser.FunctionCall";
    }

    static TParseTree FunctionIdentifier(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, FunctionNamespace, Spacing)), pegged.peg.wrapAround!(Spacing, Function, Spacing)), "CommandParser.FunctionIdentifier")(p);
        }
        else
        {
            if (auto m = tuple(`FunctionIdentifier`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, FunctionNamespace, Spacing)), pegged.peg.wrapAround!(Spacing, Function, Spacing)), "CommandParser.FunctionIdentifier"), "FunctionIdentifier")(p);
                memo[tuple(`FunctionIdentifier`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree FunctionIdentifier(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, FunctionNamespace, Spacing)), pegged.peg.wrapAround!(Spacing, Function, Spacing)), "CommandParser.FunctionIdentifier")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, FunctionNamespace, Spacing)), pegged.peg.wrapAround!(Spacing, Function, Spacing)), "CommandParser.FunctionIdentifier"), "FunctionIdentifier")(TParseTree("", false,[], s));
        }
    }
    static string FunctionIdentifier(GetName g)
    {
        return "CommandParser.FunctionIdentifier";
    }

    static TParseTree FunctionNamespace(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("."), Spacing))), "CommandParser.FunctionNamespace")(p);
        }
        else
        {
            if (auto m = tuple(`FunctionNamespace`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("."), Spacing))), "CommandParser.FunctionNamespace"), "FunctionNamespace")(p);
                memo[tuple(`FunctionNamespace`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree FunctionNamespace(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("."), Spacing))), "CommandParser.FunctionNamespace")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, identifier, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("."), Spacing))), "CommandParser.FunctionNamespace"), "FunctionNamespace")(TParseTree("", false,[], s));
        }
    }
    static string FunctionNamespace(GetName g)
    {
        return "CommandParser.FunctionNamespace";
    }

    static TParseTree Function(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, identifier, Spacing), "CommandParser.Function")(p);
        }
        else
        {
            if (auto m = tuple(`Function`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, identifier, Spacing), "CommandParser.Function"), "Function")(p);
                memo[tuple(`Function`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Function(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, identifier, Spacing), "CommandParser.Function")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, identifier, Spacing), "CommandParser.Function"), "Function")(TParseTree("", false,[], s));
        }
    }
    static string Function(GetName g)
    {
        return "CommandParser.Function";
    }

    static TParseTree ArgTypes(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, String, Spacing), pegged.peg.wrapAround!(Spacing, HexLiteral, Spacing), pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, Bool, Spacing), pegged.peg.wrapAround!(Spacing, FunctionCall, Spacing)), "CommandParser.ArgTypes")(p);
        }
        else
        {
            if (auto m = tuple(`ArgTypes`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, String, Spacing), pegged.peg.wrapAround!(Spacing, HexLiteral, Spacing), pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, Bool, Spacing), pegged.peg.wrapAround!(Spacing, FunctionCall, Spacing)), "CommandParser.ArgTypes"), "ArgTypes")(p);
                memo[tuple(`ArgTypes`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree ArgTypes(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, String, Spacing), pegged.peg.wrapAround!(Spacing, HexLiteral, Spacing), pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, Bool, Spacing), pegged.peg.wrapAround!(Spacing, FunctionCall, Spacing)), "CommandParser.ArgTypes")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, String, Spacing), pegged.peg.wrapAround!(Spacing, HexLiteral, Spacing), pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, Bool, Spacing), pegged.peg.wrapAround!(Spacing, FunctionCall, Spacing)), "CommandParser.ArgTypes"), "ArgTypes")(TParseTree("", false,[], s));
        }
    }
    static string ArgTypes(GetName g)
    {
        return "CommandParser.ArgTypes";
    }

    static TParseTree Args(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.literal!("(")), Line!(ArgTypes, pegged.peg.literal!(",")), pegged.peg.discard!(pegged.peg.literal!(")"))), "CommandParser.Args")(p);
        }
        else
        {
            if (auto m = tuple(`Args`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.literal!("(")), Line!(ArgTypes, pegged.peg.literal!(",")), pegged.peg.discard!(pegged.peg.literal!(")"))), "CommandParser.Args"), "Args")(p);
                memo[tuple(`Args`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Args(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.literal!("(")), Line!(ArgTypes, pegged.peg.literal!(",")), pegged.peg.discard!(pegged.peg.literal!(")"))), "CommandParser.Args")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.literal!("(")), Line!(ArgTypes, pegged.peg.literal!(",")), pegged.peg.discard!(pegged.peg.literal!(")"))), "CommandParser.Args"), "Args")(TParseTree("", false,[], s));
        }
    }
    static string Args(GetName g)
    {
        return "CommandParser.Args";
    }

    static TParseTree EmptyArgs(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.literal!("(")), pegged.peg.discard!(pegged.peg.literal!(")"))), "CommandParser.EmptyArgs")(p);
        }
        else
        {
            if (auto m = tuple(`EmptyArgs`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.literal!("(")), pegged.peg.discard!(pegged.peg.literal!(")"))), "CommandParser.EmptyArgs"), "EmptyArgs")(p);
                memo[tuple(`EmptyArgs`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree EmptyArgs(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.literal!("(")), pegged.peg.discard!(pegged.peg.literal!(")"))), "CommandParser.EmptyArgs")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.literal!("(")), pegged.peg.discard!(pegged.peg.literal!(")"))), "CommandParser.EmptyArgs"), "EmptyArgs")(TParseTree("", false,[], s));
        }
    }
    static string EmptyArgs(GetName g)
    {
        return "CommandParser.EmptyArgs";
    }

    static TParseTree String(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.discard!(doublequote), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(doublequote), Char)), pegged.peg.discard!(doublequote))), "CommandParser.String")(p);
        }
        else
        {
            if (auto m = tuple(`String`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.discard!(doublequote), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(doublequote), Char)), pegged.peg.discard!(doublequote))), "CommandParser.String"), "String")(p);
                memo[tuple(`String`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree String(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.discard!(doublequote), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(doublequote), Char)), pegged.peg.discard!(doublequote))), "CommandParser.String")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.discard!(doublequote), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(doublequote), Char)), pegged.peg.discard!(doublequote))), "CommandParser.String"), "String")(TParseTree("", false,[], s));
        }
    }
    static string String(GetName g)
    {
        return "CommandParser.String";
    }

    static TParseTree Char(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.or!(pegged.peg.and!(backslash, pegged.peg.or!(doublequote, quote, backslash, pegged.peg.or!(pegged.peg.literal!("b"), pegged.peg.literal!("f"), pegged.peg.literal!("n"), pegged.peg.literal!("r"), pegged.peg.literal!("t")), pegged.peg.and!(pegged.peg.charRange!('0', '2'), pegged.peg.charRange!('0', '7'), pegged.peg.charRange!('0', '7')), pegged.peg.and!(pegged.peg.charRange!('0', '7'), pegged.peg.option!(pegged.peg.charRange!('0', '7'))), pegged.peg.and!(pegged.peg.literal!("x"), Hex, Hex), pegged.peg.and!(pegged.peg.literal!("u"), Hex, Hex, Hex, Hex), pegged.peg.and!(pegged.peg.literal!("U"), Hex, Hex, Hex, Hex, Hex, Hex, Hex, Hex))), pegged.peg.any)), "CommandParser.Char")(p);
        }
        else
        {
            if (auto m = tuple(`Char`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.or!(pegged.peg.and!(backslash, pegged.peg.or!(doublequote, quote, backslash, pegged.peg.or!(pegged.peg.literal!("b"), pegged.peg.literal!("f"), pegged.peg.literal!("n"), pegged.peg.literal!("r"), pegged.peg.literal!("t")), pegged.peg.and!(pegged.peg.charRange!('0', '2'), pegged.peg.charRange!('0', '7'), pegged.peg.charRange!('0', '7')), pegged.peg.and!(pegged.peg.charRange!('0', '7'), pegged.peg.option!(pegged.peg.charRange!('0', '7'))), pegged.peg.and!(pegged.peg.literal!("x"), Hex, Hex), pegged.peg.and!(pegged.peg.literal!("u"), Hex, Hex, Hex, Hex), pegged.peg.and!(pegged.peg.literal!("U"), Hex, Hex, Hex, Hex, Hex, Hex, Hex, Hex))), pegged.peg.any)), "CommandParser.Char"), "Char")(p);
                memo[tuple(`Char`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Char(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.or!(pegged.peg.and!(backslash, pegged.peg.or!(doublequote, quote, backslash, pegged.peg.or!(pegged.peg.literal!("b"), pegged.peg.literal!("f"), pegged.peg.literal!("n"), pegged.peg.literal!("r"), pegged.peg.literal!("t")), pegged.peg.and!(pegged.peg.charRange!('0', '2'), pegged.peg.charRange!('0', '7'), pegged.peg.charRange!('0', '7')), pegged.peg.and!(pegged.peg.charRange!('0', '7'), pegged.peg.option!(pegged.peg.charRange!('0', '7'))), pegged.peg.and!(pegged.peg.literal!("x"), Hex, Hex), pegged.peg.and!(pegged.peg.literal!("u"), Hex, Hex, Hex, Hex), pegged.peg.and!(pegged.peg.literal!("U"), Hex, Hex, Hex, Hex, Hex, Hex, Hex, Hex))), pegged.peg.any)), "CommandParser.Char")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.or!(pegged.peg.and!(backslash, pegged.peg.or!(doublequote, quote, backslash, pegged.peg.or!(pegged.peg.literal!("b"), pegged.peg.literal!("f"), pegged.peg.literal!("n"), pegged.peg.literal!("r"), pegged.peg.literal!("t")), pegged.peg.and!(pegged.peg.charRange!('0', '2'), pegged.peg.charRange!('0', '7'), pegged.peg.charRange!('0', '7')), pegged.peg.and!(pegged.peg.charRange!('0', '7'), pegged.peg.option!(pegged.peg.charRange!('0', '7'))), pegged.peg.and!(pegged.peg.literal!("x"), Hex, Hex), pegged.peg.and!(pegged.peg.literal!("u"), Hex, Hex, Hex, Hex), pegged.peg.and!(pegged.peg.literal!("U"), Hex, Hex, Hex, Hex, Hex, Hex, Hex, Hex))), pegged.peg.any)), "CommandParser.Char"), "Char")(TParseTree("", false,[], s));
        }
    }
    static string Char(GetName g)
    {
        return "CommandParser.Char";
    }

    static TParseTree Hex(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.wrapAround!(Spacing, pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.charRange!('0', '9'), pegged.peg.charRange!('a', 'f'), pegged.peg.charRange!('A', 'F')), Spacing)), Spacing)), "CommandParser.Hex")(p);
        }
        else
        {
            if (auto m = tuple(`Hex`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.wrapAround!(Spacing, pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.charRange!('0', '9'), pegged.peg.charRange!('a', 'f'), pegged.peg.charRange!('A', 'F')), Spacing)), Spacing)), "CommandParser.Hex"), "Hex")(p);
                memo[tuple(`Hex`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Hex(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.wrapAround!(Spacing, pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.charRange!('0', '9'), pegged.peg.charRange!('a', 'f'), pegged.peg.charRange!('A', 'F')), Spacing)), Spacing)), "CommandParser.Hex")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.wrapAround!(Spacing, pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.charRange!('0', '9'), pegged.peg.charRange!('a', 'f'), pegged.peg.charRange!('A', 'F')), Spacing)), Spacing)), "CommandParser.Hex"), "Hex")(TParseTree("", false,[], s));
        }
    }
    static string Hex(GetName g)
    {
        return "CommandParser.Hex";
    }

    static TParseTree HexLiteral(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("0x"), Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, Hex, Spacing))), "CommandParser.HexLiteral")(p);
        }
        else
        {
            if (auto m = tuple(`HexLiteral`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("0x"), Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, Hex, Spacing))), "CommandParser.HexLiteral"), "HexLiteral")(p);
                memo[tuple(`HexLiteral`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree HexLiteral(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("0x"), Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, Hex, Spacing))), "CommandParser.HexLiteral")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("0x"), Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, Hex, Spacing))), "CommandParser.HexLiteral"), "HexLiteral")(TParseTree("", false,[], s));
        }
    }
    static string HexLiteral(GetName g)
    {
        return "CommandParser.HexLiteral";
    }

    static TParseTree Number(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.wrapAround!(Spacing, pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.charRange!('0', '9'), Spacing)), Spacing)), "CommandParser.Number")(p);
        }
        else
        {
            if (auto m = tuple(`Number`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.wrapAround!(Spacing, pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.charRange!('0', '9'), Spacing)), Spacing)), "CommandParser.Number"), "Number")(p);
                memo[tuple(`Number`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Number(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.wrapAround!(Spacing, pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.charRange!('0', '9'), Spacing)), Spacing)), "CommandParser.Number")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.wrapAround!(Spacing, pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.charRange!('0', '9'), Spacing)), Spacing)), "CommandParser.Number"), "Number")(TParseTree("", false,[], s));
        }
    }
    static string Number(GetName g)
    {
        return "CommandParser.Number";
    }

    static TParseTree Bool(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("true"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("false"), Spacing)), Spacing), "CommandParser.Bool")(p);
        }
        else
        {
            if (auto m = tuple(`Bool`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("true"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("false"), Spacing)), Spacing), "CommandParser.Bool"), "Bool")(p);
                memo[tuple(`Bool`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Bool(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("true"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("false"), Spacing)), Spacing), "CommandParser.Bool")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("true"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("false"), Spacing)), Spacing), "CommandParser.Bool"), "Bool")(TParseTree("", false,[], s));
        }
    }
    static string Bool(GetName g)
    {
        return "CommandParser.Bool";
    }

    template Line(alias Elem, alias Sep = pegged.peg.literal!(" "))
    {
    static TParseTree Line(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Elem, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Sep, Spacing)), pegged.peg.wrapAround!(Spacing, Elem, Spacing)), Spacing))), "CommandParser.Line!(" ~ pegged.peg.getName!(Elem)() ~ ", " ~ pegged.peg.getName!(Sep) ~ ")")(p);
        }
        else
        {
            if (auto m = tuple("Line!(" ~ pegged.peg.getName!(Elem)() ~ ", " ~ pegged.peg.getName!(Sep) ~ ")", p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Elem, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Sep, Spacing)), pegged.peg.wrapAround!(Spacing, Elem, Spacing)), Spacing))), "CommandParser.Line!(" ~ pegged.peg.getName!(Elem)() ~ ", " ~ pegged.peg.getName!(Sep) ~ ")"), "Line_2")(p);
                memo[tuple("Line!(" ~ pegged.peg.getName!(Elem)() ~ ", " ~ pegged.peg.getName!(Sep) ~ ")", p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Line(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Elem, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Sep, Spacing)), pegged.peg.wrapAround!(Spacing, Elem, Spacing)), Spacing))), "CommandParser.Line!(" ~ pegged.peg.getName!(Elem)() ~ ", " ~ pegged.peg.getName!(Sep) ~ ")")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Elem, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, Sep, Spacing)), pegged.peg.wrapAround!(Spacing, Elem, Spacing)), Spacing))), "CommandParser.Line!(" ~ pegged.peg.getName!(Elem)() ~ ", " ~ pegged.peg.getName!(Sep) ~ ")"), "Line_2")(TParseTree("", false,[], s));
        }
    }
    static string Line(GetName g)
    {
        return "CommandParser.Line!(" ~ pegged.peg.getName!(Elem)() ~ ", " ~ pegged.peg.getName!(Sep) ~ ")";
    }

    }
    static TParseTree opCall(TParseTree p)
    {
        TParseTree result = decimateTree(Primary(p));
        result.children = [result];
        result.name = "CommandParser";
        return result;
    }

    static TParseTree opCall(string input)
    {
        if(__ctfe)
        {
            return CommandParser(TParseTree(``, false, [], input, 0, 0));
        }
        else
        {
            forgetMemo();
            return CommandParser(TParseTree(``, false, [], input, 0, 0));
        }
    }
    static string opCall(GetName g)
    {
        return "CommandParser";
    }


    static void forgetMemo()
    {
        memo = null;
    }
    }
}

alias GenericCommandParser!(ParseTree).CommandParser CommandParser;

