module command.uda;

alias CommandType = string delegate(string[]);

struct CmdTableEntry {
    CommandType cmd;
    string desc;
    int minArgs;
    int maxArgs;
}

struct CommandNamespace {
    string name;
}

struct Command {
    string name;
    string desc = "";
    int minArgs = 0;
    int maxArgs = 0;
}

struct TypedCommand {
    string name;
    string desc;
    int minArgs = 0;
    int maxArgs = 0;
}

mixin template RegisterModule(T) 
if (is(T == class) || is(T == struct)) {
    mixin("__gshared T " ~ T.mangleof ~ "Singleton;");
    shared static this() {
        import command : gCommandInterpreter;
        import std.traits;
        mixin(T.mangleof ~ "Singleton = new T();");
        static foreach(m; __traits(allMembers, T)) {{
            enum _namespace = () {
                static if (hasUDA!(__traits(getMember, T, m), CommandNamespace)) {
                    return getUDAs!(__traits(getMember, T, m), CommandNamespace)[0].name;
                } else {
                    return "global";
                }
            }();
            enum cmdName = () {
                static if (hasUDA!(__traits(getMember, T, m), Command)) {
                    return getUDAs!(__traits(getMember, T, m), Command)[0].name;
                } else static if (hasUDA!(__traits(getMember, T, m), TypedCommand)) {
                    return getUDAs!(__traits(getMember, T, m), TypedCommand)[0].name;
                } else {
                    return "";
                }
            }();
            static if (hasUDA!(__traits(getMember, T, m), Command)) {
                pragma(msg, "command " ~ cmdName ~ ", namespace: " ~ _namespace);
                gCommandInterpreter.registerCommand(_namespace, getUDAs!(__traits(getMember, T, m), Command), mixin("&" ~ T.mangleof ~ "Singleton." ~ m));
            } else static if (hasUDA!(__traits(getMember, T, m), TypedCommand)) {
                pragma(msg, "typed command " ~ cmdName ~ ", namespace: " ~ _namespace);
                // a little ugly, but it works
                enum typeConversionShim = (string[] args) {
                    enum _paramCount = Parameters!(__traits(getMember, T, m)).length;
                    import std.conv : to;
                    /* 
                        XXX: this is also a hack, but it's the easiest way to generate the mixin that will automatically 
                        convert string arguments to the desired arguments

                        TODO: overhaul the parser to emit Variants so we don't have to do this
                        string conversion nightmare
                    */

                    enum _paramList = () {
                        string list = "(";
                        static foreach(i, param; Parameters!(__traits(getMember, T, m))) {
                            static assert(__traits(isPOD, param), "Cannot coerce arguments to complex types (struct, class, etc)");

                            // XXX: this is a hack
                            list ~= "to!(" ~ param.stringof ~ ")(args[" ~ to!string(i) ~ "])";
                            static if (i == (_paramCount - 1)) {
                                list ~= ")";
                            } else {
                                list ~= ", ";
                            }
                        }
                        return list;
                    }();
                    ReturnType!(__traits(getMember, T, m)) val = mixin(T.mangleof ~ "Singleton." ~ m ~ _paramList);
                    return to!string(val);
                };
                gCommandInterpreter.registerTypedCommand(_namespace, getUDAs!(__traits(getMember, T, m), TypedCommand), typeConversionShim);
            }
        }}
    }
}
