class BananaFns {
    public static function banana(x:Int):Int return x * 3 + 7;
    public static function gorilla():String return Jungle.payload();
}
class Main {
    static function main():Void {
        var checksum = 0;
        for (i in 0...10000) checksum += BananaFns.banana(i % 97);
        Sys.println("checksum=" + checksum);
        #if keep_gorilla
        if (Sys.args().indexOf("--gorilla") >= 0) Sys.println(BananaFns.gorilla());
        #end
    }
}