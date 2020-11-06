module greeter;
import command.uda;

class Greeter {
@CommandNamespace("hello"):
    @Command("world", "Hello, World!", 0, 0)
    string hello_world(string[] args) {
        return "Hello, World!";
    }

    @Command("user", "Say hello to a user!", 1, 1)
    string hello_user(string[] args) {
        return "Hello, " ~ args[0] ~ "!";
    }
}

mixin RegisterModule!Greeter;
        

