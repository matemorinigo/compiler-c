args=$(getopt -o d:a:ph --l help,directorio:,archivo:,pantalla -- "$@" 2> /dev/null)
if [ "$?" != "0" ]
then
  echo "opciones incorrectas"
  exit 1
fi

eval set -- "$args"
while true
do
    case "$1" in
        -f | --filename)
            filename="$2"
            shift 2
            ;;
        -h | --help)
            echo "Usage: run_w_steroids.sh [-h|--help] (-f|--filename) <filename>"
            exit 0
            ;;
        -- )
            shift
            break
            ;;
        * )
            echo "Not recognized option"
            exit 1
            ;;
        esac
done

flex Lexico.l
bison -dyv Sintactico.y
gcc lex.yy.c y.tab.c -o compiler -lfl
./compiler "$filename"
rm lex.yy.c
rm y.tab.c
rm y.output
rm y.tab.h
rm compilador