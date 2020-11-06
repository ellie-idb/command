module command;
import pegged.grammar;
public import command.grammar;
public import command.uda;
import core.thread;
import core.sync.mutex;
import deimos.linenoise;
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
        char* line;
        import core.stdc.string, core.stdc.stdlib;
        while (!terminate && (line = linenoise("> ")) !is null) {
            if (line[0] != '\0') {
                linenoiseHistoryAdd(line);
                gCommandInterpreter.interpret(line.fromStringz.idup);
            }
            free(line);
        }
    }
}

class CommandInterpreter {
    private {
        bool debug_ = false;
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
                        // TODO: Optimize
                        args = parseToChild(c.children[1]).split('\0');
                    }

                    // bailout, avoid execution
                    if (caughtException) {
                        return "";
                    }

                    if (debug_) writeln("Hit func in namespace ", ns, " called ", func, " with args ", args);

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
                case "CommandParser.Bool":
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
                    // TODO: Optimize
                    list.each!((p) => vals ~= parseToChild(p));
                    return vals.joiner("\0").text;
                default:
                    assert(0, "Unhandled " ~ c.name);
            }
        }

        if (debug_) writeln(tree);

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
                    throw new Exception(format!"Expected at least %d arguments, got %d"(f.minArgs, args.length));
                }
                if (args.length > f.maxArgs) {
                    throw new Exception(format!"Expected at most %d arguments, got %d"(f.maxArgs, args.length));
                }

                return f.cmd(args);
            }
            throw new Exception(format!"Could not find command %s"(func));
        }
        throw new Exception(format!"Could not find namespace %s"(ns));
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
        import std.algorithm.sorting;
        void printEntry(string name, CmdTableEntry cmd) {
            writef("\t%s:\n", name);
            if (cmd.desc != "")
                writef("\t\t%s\n", cmd.desc);
            writef("\t\tmin args: %d, max args: %d\n", cmd.minArgs, cmd.maxArgs);
        }

        void printNamespace(string ns) {
            writeln("namespace ", ns, ":");
            foreach(entryName; commandTable[ns].keys.sort!("a < b")) {
                auto entry = commandTable[ns][entryName];
                printEntry(entryName, entry);
            }
        }

        // global is always first
        printNamespace("global");
        foreach(ns; commandTable.keys.sort!("a < b")) {
            if (ns == "global") continue;
            printNamespace(ns);
        }
        return "";
    }

    string enableDebug(string[] args) {
        if (args[0] == "true") {
            debug_ = true;
        } else if (args[0] == "false") {
            debug_ = false;
        }
        return "";
    }

    string quit(string[] args) {
        reader.terminate = true;
        stdin.close();
        return "";
    }

    string print(string[] args) {
        import std.algorithm.iteration : each;
        args.each!((a) => writeln(a));
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
        debug gCommandInterpreter.registerCommand(Command("debug", "Enable increased verbosity of the interpreter", 1, 1), &gCommandInterpreter.enableDebug);
        gCommandInterpreter.registerCommand(Command("help", "Display a listing of every registered function"), &gCommandInterpreter.help);
        gCommandInterpreter.registerCommand(Command("quit", "Quit the REPL."), &gCommandInterpreter.quit);
        gCommandInterpreter.registerCommand(Command("print", "Write something to the console.", 0, 99), &gCommandInterpreter.print);
    }
}



