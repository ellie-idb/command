module typed;
import command.uda;

class TypedExample {
@CommandNamespace("typed"):
    @TypedCommand("foo", "Foobar", 1, 1)
    int foo(int bar) {
        return bar;
    }

    @TypedCommand("hello", "Say hello to someone!", 1, 1)
    string hello(string name) {
        return "Hello, " ~ name ~ "!";
    }
}

mixin RegisterModule!TypedExample;

