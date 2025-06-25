#include "assembler.h"


void generarAssembler(tLista* symbol_table, tLista* terceto_lista){
    FILE* arch = fopen("./final_assembler/final.asm", "w");
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

		//printf("Terceto: %s %s %s\n", terceto.operador, terceto.op1, terceto.op2);

		fprintf(arch, "terceto_%d:\n", indice);
		switch(tipo_terceto){
			case INT_OP:
				fprintf(arch, "MOV EAX, %s\n", terceto.operador);
				fprintf(arch, "MOV aux_var_%d, EAX\n", indice);
				break;
			case FLOAT_OP:
				fprintf(arch, "fld dword ptr %s\n", terceto.operador);
				fprintf(arch, "fstp dword ptr aux_var_%d\n", indice);
				break;
			case ARIT_ASIG_INT:
				sscanf(terceto.op2, "[%d]", &indice_terceto_op2);
				fprintf(arch, "MOV EAX, aux_var_%d\n", indice_terceto_op2);
				fprintf(arch, "MOV %s, EAX\n", terceto.op1);
				break;
			case ARIT_ASIG_FLOAT:
				sscanf(terceto.op2, "[%d]", &indice_terceto_op2);
				fprintf(arch, "fld dword ptr aux_var_%d\n", indice_terceto_op2);
				fprintf(arch, "fstp dword ptr %s\n", terceto.op1);
				break;
			case SUM_INT:
				sscanf(terceto.op1, "[%d]", &indice_terceto_op1);
				sscanf(terceto.op2, "[%d]", &indice_terceto_op2);
				fprintf(arch, "MOV EAX, aux_var_%d\n", indice_terceto_op1);
				fprintf(arch, "ADD EAX, aux_var_%d\n", indice_terceto_op2);
				fprintf(arch, "MOV aux_var_%d, EAX\n", indice);
				break;
			case RES_INT:
				sscanf(terceto.op1, "[%d]", &indice_terceto_op1);
				sscanf(terceto.op2, "[%d]", &indice_terceto_op2);
				fprintf(arch, "MOV EAX, aux_var_%d\n", indice_terceto_op1);
				fprintf(arch, "SUB EAX, aux_var_%d\n", indice_terceto_op2);
				fprintf(arch, "MOV aux_var_%d, EAX\n", indice);
				break;
			case MUL_INT:
				sscanf(terceto.op1, "[%d]", &indice_terceto_op1);
				sscanf(terceto.op2, "[%d]", &indice_terceto_op2);
				fprintf(arch, "MOV EAX, aux_var_%d\n", indice_terceto_op1);
				fprintf(arch, "IMUL aux_var_%d\n", indice_terceto_op2);
				fprintf(arch, "MOV aux_var_%d, EAX\n", indice);
				break;
			case DIV_INT:
				sscanf(terceto.op1, "[%d]", &indice_terceto_op1);
				sscanf(terceto.op2, "[%d]", &indice_terceto_op2);
				fprintf(arch, "MOV EAX, aux_var_%d\n", indice_terceto_op1);
				fprintf(arch, "CDQ\n");
				fprintf(arch, "IDIV aux_var_%d\n", indice_terceto_op2);
				fprintf(arch, "MOV aux_var_%d, EAX\n", indice);
				break;
			case SUM_FLOAT:
				sscanf(terceto.op1, "[%d]", &indice_terceto_op1);
				sscanf(terceto.op2, "[%d]", &indice_terceto_op2);
				fprintf(arch, "fld dword ptr aux_var_%d\n", indice_terceto_op1);
				fprintf(arch, "fadd dword ptr aux_var_%d\n", indice_terceto_op2);
				fprintf(arch, "fstp dword ptr aux_var_%d\n", indice);
				break;
			case RES_FLOAT:
				sscanf(terceto.op1, "[%d]", &indice_terceto_op1);
				sscanf(terceto.op2, "[%d]", &indice_terceto_op2);
				fprintf(arch, "fld dword ptr aux_var_%d\n", indice_terceto_op1);
				fprintf(arch, "fsub dword ptr aux_var_%d\n", indice_terceto_op2);
				fprintf(arch, "fstp dword ptr aux_var_%d\n", indice);
				break;
			case MUL_FLOAT:
				sscanf(terceto.op1, "[%d]", &indice_terceto_op1);
				sscanf(terceto.op2, "[%d]", &indice_terceto_op2);
				fprintf(arch, "fld dword ptr aux_var_%d\n", indice_terceto_op1);
				fprintf(arch, "fmul dword ptr aux_var_%d\n", indice_terceto_op2);
				fprintf(arch, "fstp dword ptr aux_var_%d\n", indice);
				break;
			case DIV_FLOAT:
				sscanf(terceto.op1, "[%d]", &indice_terceto_op1);
				sscanf(terceto.op2, "[%d]", &indice_terceto_op2);
				fprintf(arch, "fld dword ptr aux_var_%d\n", indice_terceto_op1);
				fprintf(arch, "fdiv dword ptr aux_var_%d\n", indice_terceto_op2);
				fprintf(arch, "fstp dword ptr aux_var_%d\n", indice);
				break;
			case STRING_ASIG:
				fprintf(arch, "LEA ESI, %s\n", terceto.op2);
				fprintf(arch, "LEA EDI, %s\n", terceto.op1);
				fprintf(arch, "STRCPY\n");
				break;
			case FLOAT_ASIG:
				fprintf(arch, "fld dword ptr %s\n", terceto.op2);
				fprintf(arch, "fstp dword ptr %s\n", terceto.op1);
				break;
			case INT_ASIG:
				fprintf(arch, "MOV EAX, %s\n", terceto.op2);
				fprintf(arch, "MOV %s, EAX \n", terceto.op1);
				break;
			case CMP_INT:
				fprintf(arch, "MOV EAX, %s\n", terceto.op1);
				fprintf(arch, "CMP EAX, %s\n", terceto.op2);
				break;
			case CMP_FLOAT:
				fprintf(arch, "fld dword ptr %s\n", terceto.op1);
				fprintf(arch, "fcomp dword ptr %s\n", terceto.op2);
				fprintf(arch, "fstsw ax\n");
				fprintf(arch, "sahf\n");
				break;
			case BLE_INT:
				sscanf(terceto.op2, "[%d]", &indice_terceto_destino);
				fprintf(arch, "JLE terceto_%d\n", indice_terceto_destino);
				break;
			case BGT_INT:
				sscanf(terceto.op2, "[%d]", &indice_terceto_destino);
				fprintf(arch, "JG terceto_%d\n", indice_terceto_destino);
				break;
			case BGE_INT:
				sscanf(terceto.op2, "[%d]", &indice_terceto_destino);
				fprintf(arch, "JGE terceto_%d\n", indice_terceto_destino);
				break;
			case BLE_FLOAT:
				sscanf(terceto.op2, "[%d]", &indice_terceto_destino);
				fprintf(arch, "JBE terceto_%d\n", indice_terceto_destino);
				break;
			case BGT_FLOAT:
				sscanf(terceto.op2, "[%d]", &indice_terceto_destino);
				fprintf(arch, "JA terceto_%d\n", indice_terceto_destino);
				break;
			case BGE_FLOAT:
				sscanf(terceto.op2, "[%d]", &indice_terceto_destino);
				fprintf(arch, "JAE terceto_%d\n", indice_terceto_destino);
				break;
			case BI:
				sscanf(terceto.op2, "[%d]", &indice_terceto_destino);
				fprintf(arch, "JMP terceto_%d\n", indice_terceto_destino);
				break;
			case PRINT_STR:
				fprintf(arch, "displayString %s\n", terceto.op1);
				fprintf(arch, "displayString NEW_LINE\n");
				break;
			case PRINT_INT:
				fprintf(arch, "DisplayInteger %s\n", terceto.op1);
				fprintf(arch, "displayString NEW_LINE\n");
				break;
			case PRINT_FLOAT:
				fprintf(arch, "DisplayFloat %s,2\n", terceto.op1);
				fprintf(arch, "displayString NEW_LINE\n");
				break;
			case PRINT_FLOAT_SIN_NEW_LINE:
				fprintf(arch, "DisplayFloat %s,2\n", terceto.op1);
				break;
			case READ_STRING:
				fprintf(arch, "getString %s\n\n", terceto.op1);
				break;
			case READ_INT:
				fprintf(arch, "getInteger %s\n\n", terceto.op1);
				break;
			case READ_FLOAT:
				fprintf(arch, "getFloat %s\n\n", terceto.op1);
				break;
			case PRINT_STR_SIN_NEW_LINE:
				fprintf(arch, "displayString %s\n", terceto.op1);
				break;
			case PRINT_INT_SIN_NEW_LINE:
				fprintf(arch, "DisplayInteger %s\n", terceto.op1);
				break;
			default:
				printf("Tipo de terceto no valido: %d\n", tipo_terceto);
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