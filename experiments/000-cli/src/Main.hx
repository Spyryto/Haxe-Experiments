class Main {
    static function main():Void {
        Sys.println("Haxe Experiments / 000 - CLI baseline");
        Sys.println("Sistema: " + Sys.systemName());
        Sys.println("Versione Haxe: " + haxe.macro.Compiler.getDefine("haxe_ver"));
        Sys.println("Il programma e' avviabile senza Haxe installato (build hxcpp).");
    }
}
