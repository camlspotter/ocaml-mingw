let bindir = "C:/ocamlmgw/bin"
let ext_lib = ".a"
let ext_dll = ".dll"
let supports_shared_libraries = true
let mkdll = "flexlink -chain mingw64 -stack 33554432"
let byteccrpath = ""
let nativeccrpath = ""
let mksharedlibrpath = ""
let toolpref = "x86_64-w64-mingw32-"
let mklib out files opts = Printf.sprintf "rm -f %s && %sar rcs %s %s %s" out toolpref opts out files;;
let syslib x = "-l"^x;;
let topdir = "" and wintopdir = "";;
