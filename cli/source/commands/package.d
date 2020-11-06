module commands;
import pegged.grammar;
import commands.grammar;
import commands.uda;
import core.thread;
import core.sync.mutex;
import std.stdio, std.string;
import std.format;
import std.traits;

__gshared CommandInterpreter gCommandInterpreter;

class CommandReaderThread : Thread {
    __gshared bool terminate;
    this() {
        super(&run);
    }

private:
    void cls() {
        writeln("\033[2J");
    }

    void run() {
        string line;
        while (!terminate) {
            stdout.writef("> ");
            line = stdin.readln().strip();
            if (line is null) {
                writeln("Caught EOF");
                terminate = true;
            } else {
                gCommandInterpreter.interpret(line);
            }
        }
    }
}

class CommandInterpreter {
    private {
        CommandReaderThread reader;
        CmdTableEntry[string][string] commandTable;
    }


    void interpret(string line) {
        auto tree = CommandParser(line); 

        if (!tree.successful) {
            writeln("unable to parse");
            return;
        }

        bool caughtException = false;

        string parseToChild(ParseTree c) {
            switch (c.name) {
                case "CommandParser":
                case "CommandParser.Primary":
                case "CommandParser.ArgTypes":
                    return parseToChild(c.children[0]);
                case "CommandParser.FunctionCall":
                    import std.string : split;
                    string[] args;
                    string ns = "global", func;
                    auto id = c.children[0];
                    if (id.children[0].name == "CommandParser.FunctionNamespace") {
                        ns = parseToChild(id.children[0]);
                        func = parseToChild(id.children[1]);
                    } else {
                        func = parseToChild(id.children[0]);
                    }
                    if (c.children.length == 2) {
                        args = parseToChild(c.children[1]).split(',');
                    }

                    // bailout, avoid execution
                    if (caughtException) {
                        return "";
                    }

//                    writeln("Hit func in namespace ", ns, " called ", func, " with args ", args);
                    try {
                        return eval(ns, func, args);
                    } catch (Exception e) {
                        writeln("Caught exception: ", e.msg);
                        caughtException = true;
                        return "";
                    }

                case "CommandParser.Function":
                case "CommandParser.FunctionNamespace":
                case "CommandParser.Number":
                case "CommandParser.String":
                    return c.matches[0];
                case "CommandParser.HexLiteral":
                    return c.matches[0] ~ c.matches[1];
                case "CommandParser.EmptyArgs":
                    return "";
                case "CommandParser.Args":
                    // ugh, I hate this, but I have to join them
                    import std.conv : text;
                    import std.algorithm.iteration : joiner, each;

                    auto list = c.children[0].children;
                    string[] vals;
                    list.each!((p) => vals ~= parseToChild(p));
                    return vals.joiner(",").text;
                default:
                    assert(0, "Unhandled " ~ c.name);
            }
        }

//        writeln(tree);

        parseToChild(tree);
    }

    string eval(string func, string[] args) {
        return eval("global", func, args);
    }

    string eval(string ns, string func, string[] args) {
        if (auto possible = ns in commandTable) {
            // safe deref since assignment checks if it's null or not
            if (auto _f = func in *possible) {
                // ditto
                auto f = *_f;
                if (args.length < f.minArgs) { 
                    throw new Exception(format!"Expected at least %d arguments, got %d\n"(f.minArgs, args.length));
                }
                if (args.length > f.maxArgs) {
                    throw new Exception(format!"Expected at most %d arguments, got %d\n"(f.maxArgs, args.length));
                }

                return f.cmd(args);
            }
            throw new Exception(format!"Could not find command %s\n"(func));
        }
        throw new Exception(format!"Could not find namespace %s\n"(ns));
    }


    void registerCommand(Command info, CommandType cmd) {
        registerCommand("global", info, cmd);
    }

    void registerCommand(string ns, Command info, CommandType cmd) {
        synchronized {
            commandTable[ns][info.name] = CmdTableEntry(cmd, info.desc, info.minArgs, info.maxArgs);
        }
    }

    /+ built-in functions +/
    string help(string[] args) {
        foreach(ns; commandTable.keys) {
            writeln("namespace ", ns, ":");
            foreach(entryName; commandTable[ns].keys) {
                auto entry = commandTable[ns][entryName];
                writef("\t%s:\n", entryName);
                if (entry.desc != "")
                    writef("\t\t%s\n", entry.desc);
                writef("\t\tmin args: %d, max args: %d\n", entry.minArgs, entry.maxArgs);
            }
        }
        return "";
    }

    string quit(string[] args) {
        reader.terminate = true;
        stdin.close();
        return "";
    }

    void run() {
        reader.run();
    }

    void fork() {
        reader.start();
    }

    this() {
        reader = new CommandReaderThread();
    }

    ~this() {
        reader.terminate = true;
    }
        
    shared static this() {
        import std.stdio;
        gCommandInterpreter = new CommandInterpreter();
        gCommandInterpreter.registerCommand(Command("help", "Display a listing of every registered function"), &gCommandInterpreter.help);
        gCommandInterpreter.registerCommand(Command("quit", "Quit the REPL."), &gCommandInterpreter.quit);
    }

}



