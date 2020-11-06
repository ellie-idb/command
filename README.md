# command
This is a simple command-line framework that I devised while writing a "very secret" project.

## Status
This library is still in-dev.

## Design Goals:
- Lightweight
    - Minimal dependencies (only 1!!)
- Portable
    - Parser reads in from stdin, but that's easy to change & make better
- Easy to use
    - The use of UDAs here helps a *ton*
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

mixin RegisterModule!TestExample;
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
## TODO:
- Proper return types
    - Avoid using strings as a type everywhere
- Small standard library for ease of use
    - No user-defined functions however
        - By design, we're not trying to be a scripting engine
- Well-defined instantiation order
    - In the end, this won't matter (since you can't call *until* the engine has been fully initialized), but might be worth investigating
- Command history
