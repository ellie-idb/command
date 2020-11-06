# commander
This is a simple command-line framework that I devised while writing a "very secret" project.

## Status
Currently, this package has not been published on the `dub` repository. Subject to change.

## Examples
```d
class TestExample {
@CommandNamespace("test"):
    // name, description, min args, max args
    @Command("hello", "Hello, World!", 0, 0)
    string hello(string[] args) {
        return "Hello, World!";
    }

    @Command("user", "Say hello to someone!", 1, 1)
    string hello_user(string[] args) {
        return "Hello, " ~ args[0] ~ "!";
    }
}
```
then, in the CLI:
```
> test.hello
Hello, World!
> test.hello()
Hello, World!
> test.user("Foo")
Hello, Foo!
```
