class BananaBase {
    public function new() {}
    public function banana(x:Int):Int return x * 3 + 7;
    // Not called in the standard scenario: a "gorilla" inherited from the base.
    public function gorilla():String return Jungle.payload();
}
class Banana extends BananaBase {
    public function new() super();
    override public function banana(x:Int):Int return super.banana(x);
}
class Main {
    static function main():Void {
        var processor:BananaBase = new Banana();
        var checksum = 0;
        for (i in 0...10000) checksum += processor.banana(i % 97);
        Sys.println("checksum=" + checksum);
        #if keep_gorilla
        if (Sys.args().indexOf("--gorilla") >= 0) Sys.println(processor.gorilla());
        #end
    }
}