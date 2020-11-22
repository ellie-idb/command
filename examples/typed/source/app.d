import command;

class TypedExample {
    @TypedCommand("foo", "Foobar", 1, 1)
    int foo(int bar) {
        return bar;
    }
}

mixin RegisterModule!TypedExample;

void main()
{
    gCommandInterpreter.run();
}
