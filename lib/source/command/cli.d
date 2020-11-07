module command.cli;

version(cli) {
    import command : gCommandInterpreter;
    import deimos.linenoise;
    import std.string;
    import std.stdio;
    import core.thread;

    /+ default parser +/
    class CommandReaderThread : Thread {
        __gshared bool terminate;
        this() {
            super(&run);
        }

    package:
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
}
