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

mixin template RegisterModule(T) {
    mixin("__gshared T " ~ T.stringof ~ "Singleton;");
    shared static this() {
        import command : gCommandInterpreter;
        import std.traits;
        mixin(T.stringof ~ "Singleton = new T();");
        static foreach(m; __traits(allMembers, T)) {{
            static if (hasUDA!(__traits(getMember, T, m), CommandNamespace)) {
                static if (hasUDA!(__traits(getMember, T, m), Command)) {
                    enum namespace = getUDAs!(__traits(getMember, T, m), CommandNamespace)[0].name;
                    enum cmdName = getUDAs!(__traits(getMember, T, m), Command)[0].name; 
                    pragma(msg, "command " ~ cmdName ~ ", namespace: " ~ namespace);
                    gCommandInterpreter.registerCommand(namespace, getUDAs!(__traits(getMember, T, m), Command), mixin("&" ~ T.stringof ~ "Singleton." ~ m));
                }
            } else {
                static if (hasUDA!(__traits(getMember, T, m), Command)) {
                    enum cmdName = getUDAs!(__traits(getMember, T, m), Command)[0].name; 
                    pragma(msg, "command " ~ cmdName ~ ", namespace: global");
                    gCommandInterpreter.registerCommand(getUDAs!(__traits(getMember, T, m), Command), mixin("&" ~ T.stringof ~ "Singleton." ~ m));
                }
            }
        }}
    }
}
