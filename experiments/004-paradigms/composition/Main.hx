class BananaCore {
    public function new() {}
    public function banana(x:Int):Int return x * 3 + 7;
    public function gorilla():String return Jungle.payload();
}
class BananaService {
    var core:BananaCore;
    public function new(core:BananaCore) this.core = core;
    public function banana(x:Int):Int return core.banana(x);
    public function gorilla():String return core.gorilla();
}
class Main {
    static function main():Void {
        var processor = new BananaService(new BananaCore());
        var checksum = 0;
        for (i in 0...10000) checksum += processor.banana(i % 97);
        Sys.println("checksum=" + checksum);
        #if keep_gorilla
        if (Sys.args().indexOf("--gorilla") >= 0) Sys.println(processor.gorilla());
        #end
    }
}