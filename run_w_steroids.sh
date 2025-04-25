args=$(getopt -o f:hk --l help,filename:,keep -- "$@" 2> /dev/null)
if [ "$?" != "0" ]
then
  echo "opciones incorrectas"
  exit 1
fi

keep_symbol_table=false

eval set -- "$args"
while true
do
    case "$1" in
        -f | --filename)
            filename="$2"
            shift 2
            ;;
        -k | --keep)
            keep_symbol_table=true
            shift 1
            ;;
        -h | --help)
            echo "Usage: run_w_steroids.sh [-h|--help] (-f|--filename) <filename> [-k | --keep]"
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

flex ./src/core/Lexico.l
bison -dyv ./src/core/Sintactico.y -Wcounterexamples
gcc -Isrc/utils lex.yy.c y.tab.c src/utils/symbol.c src/utils/list.c -o compiler
./compiler tests/"$filename"
rm lex.yy.c
rm y.tab.c
rm y.output
rm y.tab.h
rm compiler

if [[ "$keep_symbol_table" = false ]]; then
    rm tabla_simbolos.txt
fi
