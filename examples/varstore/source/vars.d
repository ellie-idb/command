module vars;
import commands.uda;
import std.stdio;

class VarStore {
    private {
        string[string] variables;
    }

@CommandNamespace("var"):
    @Command("get", "Get a variable from the temporary store", 1, 1) 
    string getVar(string[] args) {
        string varName = args[0];
        if (auto var = varName in variables) {
            writeln(varName, ": ", *var);
            return *var;
        }
        else {
            throw new Exception("Could not find var ", varName);
        }
    }

    @Command("set", "Set a variable in the temporary store", 2, 2) 
    string setVar(string[] args) {
        string varName = args[0];
        string varVal = args[1];
        variables[varName] = varVal;
        return varVal;
    }
}

mixin RegisterModule!VarStore;
