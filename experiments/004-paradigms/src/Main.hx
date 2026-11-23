/**
 * Identical workload and arithmetic for three implementations.
 * Compile with exactly one style_* define. Haxe DCE may remove unused code.
 */
interface Operation {
    public function apply(x:Int):Int;
}

#if style_inheritance
class InheritedOperation implements Operation {
    public function new() {}
    public function apply(x:Int):Int return x;
}
class InheritedPlus extends InheritedOperation {
    override public function apply(x:Int):Int return ((x * 1 + 11) ^ 0) & 1023;
}
class InheritedTriple extends InheritedOperation {
    override public function apply(x:Int):Int return ((x * 3 + 0) ^ 0) & 1023;
}
class InheritedXor extends InheritedOperation {
    override public function apply(x:Int):Int return ((x * 1 + 0) ^ 85) & 1023;
}
#end

#if style_composition
/** No inheritance: data-oriented composition with a single reusable operation. */
class ComposedOperation implements Operation {
    final multiplier:Int;
    final offset:Int;
    final mask:Int;
    public function new(multiplier:Int, offset:Int, mask:Int) {
        this.multiplier = multiplier;
        this.offset = offset;
        this.mask = mask;
    }
    public function apply(x:Int):Int return ((x * multiplier + offset) ^ mask) & 1023;
}
#end

class Main {
    static function main():Void {
        var iterations = Std.parseInt(Sys.args().length > 0 ? Sys.args()[0] : "3000000");
        if (iterations == null || iterations < 1) throw "Provide a positive iteration count";

        #if style_inheritance
        var operations:Array<Operation> = [new InheritedPlus(), new InheritedTriple(), new InheritedXor()];
        #elseif style_composition
        var operations:Array<Operation> = [
            new ComposedOperation(1, 11, 0),
            new ComposedOperation(3, 0, 0),
            new ComposedOperation(1, 0, 85)
        ];
        #elseif style_fp
        // First-class functions: three independent closures with captured values.
        var makeOp = function(multiplier:Int, offset:Int, mask:Int):Int->Int {
            return function(x:Int):Int return ((x * multiplier + offset) ^ mask) & 1023;
        };
        var operations:Array<Int->Int> = [
            makeOp(1, 11, 0), makeOp(3, 0, 0), makeOp(1, 0, 85)
        ];
        #else
        #error "Select exactly one style_inheritance, style_composition or style_fp"
        #end

        var checksum:Int = 0;
        var start = haxe.Timer.stamp();
        for (i in 0...iterations) {
            var value = (i * 13 + 5) & 1023;
            #if style_fp
            var result = operations[i % 3](value);
            #else
            var result = operations[i % 3].apply(value);
            #end
            checksum = (checksum + result) & 0x7fffffff;
        }
        var elapsed = (haxe.Timer.stamp() - start) * 1000;
        Sys.println("iterations=" + iterations);
        Sys.println("checksum=" + checksum);
        Sys.println("runtime_ms=" + elapsed);
    }
}
