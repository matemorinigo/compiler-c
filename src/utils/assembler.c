#include "assembler.h"


void generarAssembler(tLista* symbol_table, tLista* terceto_lista){
    FILE* arch = fopen("Final.asm", "w");
    if(!arch){
            printf("No pude crear el archivo final.txt\n");
            return;
        }

    escribirInicio(arch);
    generarTabla(arch, symbol_table);
	escribirInicioCodigo(arch);

    
    int indice = 1;
    while(indice <= obtener_indice_actual()){
		tTerceto terceto;
		int tipo_terceto = get_terceto_para_asm(terceto_lista, symbol_table, indice, &terceto);
		int indice_terceto_destino;
		int indice_terceto_op1;
		int indice_terceto_op2;

		printf("Terceto: %s %s %s\n", terceto.operador, terceto.op1, terceto.op2);

		fprintf(arch, "terceto_%d:\n", indice);
		switch(tipo_terceto){
			case INT_OP:
				printf("INT_OP\n");
				fprintf(arch, "MOV EAX, %s\n", terceto.operador);
				fprintf(arch, "MOV aux_var_%d, EAX\n", indice);
				break;
			case FLOAT_OP:
				printf("FLOAT_OP\n");
				fprintf(arch, "fld dword ptr %s\n", terceto.operador);
				fprintf(arch, "fstp dword ptr aux_var_%d\n", indice);
				break;
			case ARIT_ASIG_INT:
				printf("ARIT_ASIG_INT\n");
				sscanf(terceto.op2, "[%d]", &indice_terceto_op2);
				fprintf(arch, "MOV EAX, aux_var_%d\n", indice_terceto_op2);
				fprintf(arch, "MOV %s, EAX\n", terceto.op1);
				break;
			case ARIT_ASIG_FLOAT:
				printf("ARIT_ASIG_FLOAT\n");
				sscanf(terceto.op2, "[%d]", &indice_terceto_op2);
				fprintf(arch, "fld dword ptr aux_var_%d\n", indice_terceto_op2);
				fprintf(arch, "fstp dword ptr %s\n", terceto.op1);
				break;
			case SUM_INT:
				printf("SUM\n");
				sscanf(terceto.op1, "[%d]", &indice_terceto_op1);
				sscanf(terceto.op2, "[%d]", &indice_terceto_op2);
				fprintf(arch, "MOV EAX, aux_var_%d\n", indice_terceto_op1);
				fprintf(arch, "ADD EAX, aux_var_%d\n", indice_terceto_op2);
				fprintf(arch, "MOV aux_var_%d, EAX\n", indice);
				break;
			case RES_INT:
				printf("RES\n");
				sscanf(terceto.op1, "[%d]", &indice_terceto_op1);
				sscanf(terceto.op2, "[%d]", &indice_terceto_op2);
				fprintf(arch, "MOV EAX, aux_var_%d\n", indice_terceto_op1);
				fprintf(arch, "SUB EAX, aux_var_%d\n", indice_terceto_op2);
				fprintf(arch, "MOV aux_var_%d, EAX\n", indice);
				break;
			case MUL_INT:
				printf("MUL\n");
				sscanf(terceto.op1, "[%d]", &indice_terceto_op1);
				sscanf(terceto.op2, "[%d]", &indice_terceto_op2);
				fprintf(arch, "MOV EAX, aux_var_%d\n", indice_terceto_op1);
				fprintf(arch, "IMUL aux_var_%d\n", indice_terceto_op2);
				fprintf(arch, "MOV aux_var_%d, EAX\n", indice);
				break;
			case DIV_INT:
				printf("DIV\n");
				sscanf(terceto.op1, "[%d]", &indice_terceto_op1);
				sscanf(terceto.op2, "[%d]", &indice_terceto_op2);
				fprintf(arch, "MOV EAX, aux_var_%d\n", indice_terceto_op1);
				fprintf(arch, "CDQ\n");
				fprintf(arch, "IDIV aux_var_%d\n", indice_terceto_op2);
				fprintf(arch, "MOV aux_var_%d, EAX\n", indice);
				break;
			case SUM_FLOAT:
				printf("SUM_FLOAT\n");
				sscanf(terceto.op1, "[%d]", &indice_terceto_op1);
				sscanf(terceto.op2, "[%d]", &indice_terceto_op2);
				fprintf(arch, "fld dword ptr aux_var_%d\n", indice_terceto_op1);
				fprintf(arch, "fadd dword ptr aux_var_%d\n", indice_terceto_op2);
				fprintf(arch, "fstp dword ptr aux_var_%d\n", indice);
				break;
			case RES_FLOAT:
				printf("RES_FLOAT\n");
				sscanf(terceto.op1, "[%d]", &indice_terceto_op1);
				sscanf(terceto.op2, "[%d]", &indice_terceto_op2);
				fprintf(arch, "fld dword ptr aux_var_%d\n", indice_terceto_op1);
				fprintf(arch, "fsub dword ptr aux_var_%d\n", indice_terceto_op2);
				fprintf(arch, "fstp dword ptr aux_var_%d\n", indice);
				break;
			case MUL_FLOAT:
				printf("MUL_FLOAT\n");
				sscanf(terceto.op1, "[%d]", &indice_terceto_op1);
				sscanf(terceto.op2, "[%d]", &indice_terceto_op2);
				fprintf(arch, "fld dword ptr aux_var_%d\n", indice_terceto_op1);
				fprintf(arch, "fmul dword ptr aux_var_%d\n", indice_terceto_op2);
				fprintf(arch, "fstp dword ptr aux_var_%d\n", indice);
				break;
			case DIV_FLOAT:
				printf("DIV_FLOAT\n");
				sscanf(terceto.op1, "[%d]", &indice_terceto_op1);
				sscanf(terceto.op2, "[%d]", &indice_terceto_op2);
				fprintf(arch, "fld dword ptr aux_var_%d\n", indice_terceto_op1);
				fprintf(arch, "fdiv dword ptr aux_var_%d\n", indice_terceto_op2);
				fprintf(arch, "fstp dword ptr aux_var_%d\n", indice);
				break;
			case STRING_ASIG:
				printf("STRING_ASIG\n");
				fprintf(arch, "LEA ESI, %s\n", terceto.op2);
				fprintf(arch, "LEA EDI, %s\n", terceto.op1);
				fprintf(arch, "STRCPY\n");
				break;
			case FLOAT_ASIG:
				printf("FLOAT_ASIG\n");
				fprintf(arch, "fld dword ptr %s\n", terceto.op2);
				fprintf(arch, "fstp dword ptr %s\n", terceto.op1);
				break;
			case INT_ASIG:
				printf("INT_ASIG\n");
				fprintf(arch, "MOV EAX, %s\n", terceto.op2);
				fprintf(arch, "MOV %s, EAX \n", terceto.op1);
				break;
			case CMP_INT:
				printf("CMP_INT\n");
				fprintf(arch, "MOV EAX, %s\n", terceto.op1);
				fprintf(arch, "CMP EAX, %s\n", terceto.op2);
				break;
			case CMP_FLOAT:
				printf("CMP_FLOAT\n");
				fprintf(arch, "fld dword ptr %s\n", terceto.op1);
				fprintf(arch, "fcomp dword ptr %s\n", terceto.op2);
				fprintf(arch, "fstsw ax\n");
				fprintf(arch, "sahf\n");
				break;
			case BLE_INT:
				printf("BLE\n");
				sscanf(terceto.op2, "[%d]", &indice_terceto_destino);
				fprintf(arch, "JLE terceto_%d\n", indice_terceto_destino);
				break;
			case BGT_INT:
				printf("BGT\n");
				sscanf(terceto.op2, "[%d]", &indice_terceto_destino);
				fprintf(arch, "JG terceto_%d\n", indice_terceto_destino);
				break;
			case BGE_INT:
				printf("BGE\n");
				sscanf(terceto.op2, "[%d]", &indice_terceto_destino);
				fprintf(arch, "JGE terceto_%d\n", indice_terceto_destino);
				break;
			case BLE_FLOAT:
				printf("BLE_FLOAT\n");
				sscanf(terceto.op2, "[%d]", &indice_terceto_destino);
				fprintf(arch, "JBE terceto_%d\n", indice_terceto_destino);
				break;
			case BGT_FLOAT:
				printf("BGT_FLOAT\n");
				sscanf(terceto.op2, "[%d]", &indice_terceto_destino);
				fprintf(arch, "JA terceto_%d\n", indice_terceto_destino);
				break;
			case BGE_FLOAT:
				printf("BGE_FLOAT\n");
				sscanf(terceto.op2, "[%d]", &indice_terceto_destino);
				fprintf(arch, "JAE terceto_%d\n", indice_terceto_destino);
				break;
			case BI:
				printf("BI\n");
				sscanf(terceto.op2, "[%d]", &indice_terceto_destino);
				fprintf(arch, "JMP terceto_%d\n", indice_terceto_destino);
				break;
			case PRINT_STR:
				printf("PRINT_STR\n");
				fprintf(arch, "displayString %s\n", terceto.op1);
				fprintf(arch, "displayString NEW_LINE\n");
				break;
			case PRINT_INT:
				printf("PRINT_INT\n");
				fprintf(arch, "DisplayInteger %s\n", terceto.op1);
				fprintf(arch, "displayString NEW_LINE\n");
				break;
			case PRINT_FLOAT:
				printf("PRINT_FLOAT\n");
				fprintf(arch, "DisplayFloat %s,2\n", terceto.op1);
				fprintf(arch, "displayString NEW_LINE\n");
				break;
			case READ_STRING:
				printf("READ_STRING\n");
				fprintf(arch, "getString %s\n\n", terceto.op1);
				break;
			case READ_INT:
				printf("READ_INT\n");
				fprintf(arch, "getInteger %s\n\n", terceto.op1);
				break;
			case READ_FLOAT:
				printf("READ_FLOAT\n");
				fprintf(arch, "getFloat %s\n\n", terceto.op1);
				break;
			case PRINT_STR_SIN_NEW_LINE:
				printf("PRINT_STR_SIN_NEW_LINE\n");
				fprintf(arch, "displayString %s\n", terceto.op1);
				break;
			case PRINT_INT_SIN_NEW_LINE:
				printf("PRINT_INT_SIN_NEW_LINE\n");
				fprintf(arch, "DisplayInteger %s\n", terceto.op1);
			default:
				printf("Tipo de terceto no valido\n");
				break;
		}
        
        indice++;
    }
	fprintf(arch, "terceto_%d:\n", indice);
	escribirFinal(arch);
	fclose(arch);
}

void escribirInicio(FILE *arch){
  fprintf(arch, "include macros2.asm\ninclude number.asm\ninclude macros.asm\n\n.MODEL SMALL\n.386\n.STACK 200h\n\n");
}

void generarTabla(FILE *arch, tLista* symbol_table){
    symbol sym;
    fprintf(arch, ".DATA\n");
    fprintf(arch, "NEW_LINE DB 0AH,0DH,'$'\n");
	fprintf(arch, "CWprevio DW ?\n");

    int i = 0;
    while(get_symbol_by_index(i, &sym, symbol_table)){
        fprintf(arch, "%s ", sym.name);

        if(strcmp(sym.data_type, "int") == 0){
			if(strcmp(sym.value, "") == 0){
				fprintf(arch, "dd ?\n");
			}
			else{
				fprintf(arch, "dd %s\n", sym.value);
			}
        }
        else if(strcmp(sym.data_type, "float") == 0){
			if(strcmp(sym.value, "") == 0){
				fprintf(arch, "dd ?\n");
			}
			else{
				fprintf(arch, "dd %s\n", sym.value);
			}
        }
        else if(strcmp(sym.data_type, "string") == 0){
			if(strcmp(sym.value, "") == 0){
				fprintf(arch, "db 50 dup(?)\n");
			}
			else{
				fprintf(arch, "db %s, '$'\n", sym.value);
			}
        }
        else{
            fprintf(arch, "dd ?\n");
        }
        i++;
    }
    fprintf(arch, "\n");
}


void escribirInicioCodigo(FILE* arch){
	fprintf(arch, ".CODE\n\nMOV AX, @DATA\nMOV DS, AX\nMOV ES, AX\nFINIT\n\nstart:\n");
}


void escribirFinal(FILE *arch){
    fprintf(arch, "\nMOV AH, 1\nINT 21h\nMOV AX, 4C00h\nINT 21h\n\nEND\n");
}