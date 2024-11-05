%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define MAX_STRING_LENGTH 20
#define MAX_ATOMS 1000
#define MAX_ERROR_LENGTH 100
 /* Codigo por Nieto Rodríguez Tomás Andrés */
 /* Code by Tomás Nieto */
 /* Declaracion de contadores y arreglos de tablas pre-existentes, servirán para imprimir los tokens. */
 /*Declaration of pre-existing counters and table arrays, which will be used to print tokens.*/
int symbol_pos = 0;
int literal_real_num_pos = 0;
int literal_int_num_pos = 0;
int literal_str_pos = 0;
int literal_char_pos = 0;
int atom_index = 0; // índice actual en la cadena de átomos
char atom_chain[MAX_ATOMS]; // cadena de átomos generada en el análisis léxico
char *RelOp[] = {"^^", "^”", "==", "^^=", "^”=", "<>"};
char *ReservedWords[] = {"cadena", "caracter", "else", "entero", "for", "if", "real", "return", "void", "while"};
char *AsigOp[] = {"~", "+~", "-~", "*~", "/~", "$~"};

 /* Declaracion de tipos de datos utilizados en las tablas */
 /* Declaration of data types used in table arrays */
typedef struct {
    int pos;
    char name[100];
    int type;
} Symbol;

typedef struct {
    char message[MAX_ERROR_LENGTH];
    int position;
} SyntaxError;

SyntaxError errorsynt[MAX_ATOMS];
int error_count = 0;

typedef struct {
    int pos;
    char data[100];
} Literal;
 /* Declaracion del arreglo dinámico para guardar los mensajes de error */
 /* Declaration of the dynamic array used to store error messages */
typedef struct {
    char **messages;
    int size;
    int capacity;
} ErrorList;

// Funcion para agregar un error a la lista de errores sintácticos
void add_syntax_error(const char *message, int position) {
    snprintf(errorsynt[error_count].message, MAX_ERROR_LENGTH, "Error en atomo %d: %s", position, message);
    errorsynt[error_count].position = position;
    error_count++;
}

// Funcion auxiliar para avanzar en la cadena de átomos
int match(char expected) {
    if (atom_chain[atom_index] == expected) {
        atom_index++;
        return 1;
    } else {
        return 0;
    }
}

 /* Inicializacion del arreglo de errores léxicos */
 /* Initialization of the lexical error array */
void initErrorList(ErrorList *list, int initial_capacity) 
{
    list->messages = (char **)malloc(initial_capacity * sizeof(char *));
    list->size = 0;
    list->capacity = initial_capacity;
}


 /* Funcion para añadir elementos al arreglo de errores */
 /* Function used to add elements into the error array */
void addError(ErrorList *list, const char *message) 
{
    if (list->size >= list->capacity) 
	{
        list->capacity *= 2;
        list->messages = (char **)realloc(list->messages, list->capacity * sizeof(char *));
    }
    list->messages[list->size] = (char *)malloc(strlen(message) + 1);
    strcpy(list->messages[list->size], message);
    list->size++;
}

 /* Liberacion de la memoria usada para el arreglo de errores */
 /* Function used to free memory used by error array */
void freeErrorList(ErrorList *list) 
{
    for (int i = 0; i < list->size; i++) 
	{
        free(list->messages[i]);
    }
    free(list->messages);
}

 /* Declaracion de tablas de literales */
 /* Declaration of literal tables */

Symbol symbol_table[1000];
Literal literal_real_numbers[1000];
Literal literal_integer_numbers[1000];
Literal literal_strings[1000];
Literal literal_characters[1000];

 /* Funciones para añadir elementos a las tablas de literales */
 /* Functions used to add elements into the literal tables */
void add_literal_int_number(char *data)
{
	strcpy(literal_integer_numbers[literal_int_num_pos].data, data);
	literal_integer_numbers[literal_int_num_pos].pos = literal_int_num_pos;
	literal_int_num_pos++;
}

void add_literal_real_number(char *data)
{
	strcpy(literal_real_numbers[literal_real_num_pos].data, data);
	literal_real_numbers[literal_real_num_pos].pos = literal_real_num_pos;
	literal_real_num_pos++;
}

void add_literal_string(char *data)
{
	strcpy(literal_strings[literal_str_pos].data, data);
	literal_strings[literal_str_pos].pos = literal_str_pos;
	literal_str_pos++;
}

void add_literal_char(char *data)
{
	strcpy(literal_characters[literal_char_pos].data, data);
	literal_characters[literal_char_pos].pos = literal_char_pos;
	literal_char_pos++;
}

 /* Algoritmo de busqueda lineal para encontrar elementos en tablas pre-existentes */
 /* Linear search algorithm used to find elements in pre-existing table arrays */ 
int search(char *match, char *arr[], int size)
{
	for(int i = 0; i < size; i++)
	{
		if(strcmp(match, arr[i]) == 0)
		{
			return i;
		}
	}
	return -1;
}

 /* Algoritmo de busqueda lineal para encontrar elementos en la tabla de identificadores */
 /* Linear search algorithm used to find elements in the identifier table */
int find_symbol(char *name) {
    for (int i = 0; i < symbol_pos; i++) {
        if (strcmp(symbol_table[i].name, name) == 0) {
            return symbol_table[i].pos; // Devuelve la posicion si se encuentra
        }
    }
    return -1; // Devuelve -1 si no se encuentra
}
 /* Funcion para añadir simbolos a la tabla de identificadores */
 /* Function used to add symbols into the identifier table */

int add_symbol(char *name, int type)
{
	int pos = find_symbol(name);
    if (pos == -1) 
	{ // Si no se encontro, se agrega el símbolo
	  // If not found, the symbol is added
        strcpy(symbol_table[symbol_pos].name, name);
        symbol_table[symbol_pos].pos = symbol_pos;
        symbol_table[symbol_pos].type = type;
        symbol_pos++;
        pos = symbol_pos - 1;
	}
	return pos;
}

ErrorList errors;

%}

 //Expresiones regulares
 // Regular expressions

DIGIT [0-9]
REAL {DIGIT}+\.{DIGIT}+|\.{DIGIT}+
IDENT [a-zA-Z]([a-zA-Z]|[0-9]){0,5}_
INT_CONST [+-]?{DIGIT}{1,6}
STRING_LITERAL \"[^\"]{1,38}\"
CHAR_LITERAL \'[^\'']\'
ARITH_OP [+\-*/$]
REL_OP (\^\^|\^\"|==|\^\^=|\^\"=|<>)
ASSIGN_OP ("~"|"+~"|"-~"|"*~"|"~"|"$~")
SPECIAL [(){}[\]&,:]
RES_WORD ("cadena"|"caracter"|"else"|"entero"|"for"|"if"|"real"|"return"|"void"|"while")
ILLEGAL_ID [a-zA-Z]{DIGIT}

%%
 /* Clase 0: Palabras reservadas */
 /* Class 0: Reserved words */
{RES_WORD} {
    int index = search(yytext, ReservedWords, sizeof(ReservedWords)/sizeof(ReservedWords[0]));
    printf("(0, %d)\n", index); /* Palabra reservada */
	// Asignar el átomo correspondiente según la palabra reservada
    switch (index) {
        case 0: strcat(atom_chain, "h"); break;  // "cadena"
        case 1: strcat(atom_chain, "g"); break;  // "caracter"
        case 2: strcat(atom_chain, "e"); break;  // "else"
        case 3: strcat(atom_chain, "n"); break;  // "entero"
        case 4: strcat(atom_chain, "f"); break;  // "for"
        case 5: strcat(atom_chain, "i"); break;  // "if"
        case 6: strcat(atom_chain, "d"); break;  // "real"
        case 7: strcat(atom_chain, "b"); break;  // "return"
        case 8: strcat(atom_chain, "v"); break;  // "void"
        case 9: strcat(atom_chain, "w"); break;  // "while"
    }
}

 /* Clase 1: Operadores aritméticos */
 /* Class 1: Arithmetic operators */
{ARITH_OP} { 
	printf("(1, %s)\n", yytext);
	strcat(atom_chain, yytext);  // Agregar átomo correspondiente
}

 /* Clase 2: Operadores de asignacion */
 /* Class 2: Assignment operators */
{ASSIGN_OP} { 
	int value = search(yytext, AsigOp, sizeof(AsigOp)/sizeof(AsigOp[0]));
	printf("(2, %s)\n", yytext);
	switch (value) {
        case 0: strcat(atom_chain, "="); break;  // "~"
        case 1: strcat(atom_chain, "m"); break;  // "+~"
        case 2: strcat(atom_chain, "k"); break;  // "-~"
        case 3: strcat(atom_chain, "p"); break;  // "*~"
        case 4: strcat(atom_chain, "t"); break;  // "/~"
        case 5: strcat(atom_chain, "u"); break;  // "$~"
	 }
}

 /* Clase 3: Símbolos especiales */
 /* Clase 3: Special symbols */
{SPECIAL} { 
	printf("(3, %s)\n", yytext); 
	strcat(atom_chain, yytext);  // Agregar átomo correspondiente
}

 /* Clase 4: Operadores relacionales */
 /* Clase 4: Relational operators */
{REL_OP} { 
    int value = search(yytext, RelOp, sizeof(RelOp)/sizeof(RelOp[0])); 
    printf("(4, %d)\n", value);
	switch (value) {
        case 0: strcat(atom_chain, ">"); break;  // "^^"
        case 1: strcat(atom_chain, "<"); break;  // "^""
        case 2: strcat(atom_chain, "?"); break;  // "=="
        case 3: strcat(atom_chain, "y"); break;  // "^^="
        case 4: strcat(atom_chain, "l"); break;  // "^"="
        case 5: strcat(atom_chain, "!"); break;  // "<>"
	 }
}

 /* Clase 5: Identificadores */
 /* Clase 5: Identifiers */
{IDENT} { 
	// Se obtiene la posicion al añadir el símbolo o al buscar en la tabla
	// The position is retrieved when adding a symbol and searching in the table
    int pos = add_symbol(yytext, -2);
	printf("(5, %d)\n", pos);
	strcat(atom_chain, "a");  // Agregar átomo correspondiente
}

 /* Clase 6: Constantes numéricas enteras */
 /* Clase 6: Integer numeric constants */
{INT_CONST} { 
	printf("(6, %d)\n", literal_int_num_pos); 
	add_literal_int_number(yytext);
	strcat(atom_chain, "z");  // Agregar átomo correspondiente
}

 /* Clase 7: Constantes numéricas reales */
 /* Class 7: Numeric real constants */
{REAL} { 
	printf("(7, %d)\n", literal_real_num_pos); 
	add_literal_real_number(yytext);
	strcat(atom_chain, "r");  // Agregar átomo correspondiente
}

 /* Clase 8: Constantes cadenas */
 /* Class 8: String constants */
{STRING_LITERAL} { 
	printf("(8, %d)\n", literal_str_pos); 
	add_literal_string(yytext);
	strcat(atom_chain, "s");  // Agregar átomo correspondiente
}

 /* Clase 9: Constantes carácter */
 /* Class 9: Character constants */
{CHAR_LITERAL} { 
	printf("(9, %d)\n", literal_char_pos); 
	add_literal_char(yytext);
	strcat(atom_chain, "c");  // Agregar átomo correspondiente
}

 /* Espacios y saltos de línea */
 /* Spacing and line breaks */
[ \t\n]+ { /* Ignorar / Ignore */ }

 /* Manejo de errores */
 /* Error handling */
. {
    char error_message[100];
    sprintf(error_message, "Lexical error: %s", yytext);
    addError(&errors, error_message);
}

{ILLEGAL_ID} {
	// Ejemplos de ID's ilegales: b2, c4, a8
	// Examples of illegal ID's: b2, c4, a8
    char error_message[100];
    sprintf(error_message, "Lexical error: %s", yytext);
    addError(&errors, error_message);
}


%%

// Prototipos de funciones para cada no terminal
void Programa();
void ListaD();
void SerieF();
void otraF();
void D();
void Tipo();
void L();
void I_prima();
void Valor();
void V();
void A();
void A_prima();
void I();
void F_prima();
void B();
void W();
void For();
void Return();
void Z();
void E();
void E_prima();
void T();
void T_prima();
void F();
void R();
void R_prima();
void S();
void S_prima();
void otraS();
void Func();
void TipoFun();

// Implementacion de las reglas de la gramática
void Programa() {
    ListaD();
    if (match('[')) {
        SerieF();
        if (!match(']')) {
            add_syntax_error("Se espero ']'", atom_index);
        }
    } else {
        add_syntax_error("Se espero '['", atom_index);
    }
}

void ListaD() {
    if (atom_chain[atom_index] == 'g' || atom_chain[atom_index] == 'n' || atom_chain[atom_index] == 'd' || atom_chain[atom_index] == 'h') {
        D();
        ListaD();
    }
}

void SerieF() {
    Func();
    otraF();
}

void otraF() {
    if (atom_chain[atom_index] == 'g' || atom_chain[atom_index] == 'n' || atom_chain[atom_index] == 'd' || atom_chain[atom_index] == 'h' || atom_chain[atom_index] == 'v') {
        Func();
        otraF();
    }
}

void D() {
    Tipo();
    L();
    if (!match(':')) {
        add_syntax_error("Se espero ':'", atom_index);
    }
}

void Tipo() {
    if (!match('g') && !match('n') && !match('d') && !match('h')) {
        add_syntax_error("Se espero 'g', 'n', 'd', o 'h'", atom_index);
    }
}

void L() {
    if (match('a')) {
        Valor();
        I_prima();
    } else {
        add_syntax_error("Se espero identificador 'a'", atom_index);
    }
}

void I_prima() {
    if (match(',')) {
        if (match('a')) {
            Valor();
            I_prima();
        } else {
            add_syntax_error("Se espero identificador 'a'", atom_index);
        }
    }
}

void Valor() {
    if (match('=')) {
        V();
    }
}

void V() {
    if (!match('c') && !match('s') && !match('z') && !match('r')) {
        add_syntax_error("Se espero 'c', 's', 'z', or 'r'", atom_index);
    }
}

void A() {
    if (match('a')) {
        A_prima();
        if (!match(':')) {
            add_syntax_error("Se espero ':'", atom_index);
        }
    } else {
        add_syntax_error("Se espero identificador 'a'", atom_index);
    }
}

void A_prima() {
    if (match('=')) {
        E();
    } else if (match('m') || match('k') || match('p') || match('t') || match('u')) {
        E();
    } else {
        add_syntax_error("Se espero '=', 'm', 'k', 'p', 't', or 'u'", atom_index);
    }
}

void I() {
    if (match('i')) {
        if (!match('[')) {
            add_syntax_error("Se espero '['", atom_index);
        }
        R();
        if (!match(']')) {
            add_syntax_error("Se espero ']'", atom_index);
        }
        F_prima();
    } else {
        add_syntax_error("Se espero 'i'", atom_index);
    }
}

void F_prima() {
    if (match('(')) {
        S();
        if (!match(')')) {
            add_syntax_error("Se espero ')'", atom_index);
        }
        B();
    } else {
        add_syntax_error("Se espero '('", atom_index);
    }
}

void B() {
    if (match('e')) {
        if (!match('(')) {
            add_syntax_error("Se espero '(' despues de 'e'", atom_index);
        }
        S();
        if (!match(')')) {
            add_syntax_error("Se espero ')' despues de 'e'", atom_index);
        }
    }
}

void W() {
    if (match('w')) {
        if (!match('[')) {
            add_syntax_error("Se espero '[' despues de 'w'", atom_index);
        }
        R();
        if (!match(']')) {
            add_syntax_error("Se espero ']' despues de condicion en 'while'", atom_index);
        }
        if (!match('(')) {
            add_syntax_error("Se espero '(' por bloque 'while'", atom_index);
        }
        S();
        if (!match(')')) {
            add_syntax_error("se espero ')' despues de bloque 'while'", atom_index);
        }
    } else {
        add_syntax_error("Se espero 'w'", atom_index);
    }
}

void For() {
    if (match('f')) {
        if (!match('[')) {
            add_syntax_error("Se espero '[' despues de 'f'", atom_index);
        }
        E();
        if (!match(']')) {
            add_syntax_error("Se espero ']' despues de condition in 'for'", atom_index);
        }
        if (!match('(')) {
            add_syntax_error("Se espero '(' por bloque 'for'", atom_index);
        }
        S();
        if (!match(')')) {
            add_syntax_error("Se espero ')' despues de bloque 'for'", atom_index);
        }
    } else {
        add_syntax_error("Se espero 'f' por 'for'", atom_index);
    }
}

void Return() {
    if (match('b')) {
        Z();
    } else {
        add_syntax_error("Se espero 'b' por 'return'", atom_index);
    }
}

void Z() {
    if (match('[')) {
        E();
        if (!match(':')) {
            add_syntax_error("Se espero ':' despues de expresion 'return'", atom_index);
        }
    } else if (!match(':')) {
        add_syntax_error("Se espero ':' despues de 'return'", atom_index);
    }
}

void E() {
    T();
    E_prima();
}

void E_prima() {
    if (match('+') || match('-')) {
        T();
        E_prima();
    }
}

void T() {
    F();
    T_prima();
}

void T_prima() {
    if (match('*') || match('/') || match('$')) {
        F();
        T_prima();
    }
}

void F() {
    if (match('(')) {
        E();
        if (!match(')')) {
            add_syntax_error("Se espero ')' despues de expresion", atom_index);
        }
    } else if (!match('a') && !match('z') && !match('r') && !match('[')) {
        add_syntax_error("Se espero 'a', 'z', 'r', or '[' en expresion", atom_index);
    }
}

void R() {
    E();
    R_prima();
}

void R_prima() {
    if (match('>') || match('<') || match('?') || match('y') || match('|') || match('!')) {
        E();
    }
}

void S() {
    S_prima();
    otraS();
}

void S_prima() {
    if (atom_chain[atom_index] == 'a') {
        A();
    } else if (atom_chain[atom_index] == 'i') {
        I();
    } else if (atom_chain[atom_index] == 'w') {
        W();
    } else if (atom_chain[atom_index] == 'f') {
        For();
    } else if (atom_chain[atom_index] == 'b') {
        Return();
    } else if (match('[')) {
        if (!match('a')) {
            add_syntax_error("Se espero 'a' despues de '[' en declaracion", atom_index);
        }
        if (!match(':')) {
            add_syntax_error("Se espero ':' despues de 'a' en declaracion", atom_index);
        }
    } else {
        add_syntax_error("Declaracion invalida", atom_index);
    }
}

void otraS() {
    if (atom_chain[atom_index] == 'a' || atom_chain[atom_index] == 'i' || atom_chain[atom_index] == 'w' || atom_chain[atom_index] == 'f' || atom_chain[atom_index] == 'b' || atom_chain[atom_index] == '[') {
        S_prima();
        otraS();
    }
}

void Func() {
    TipoFun();
    if (!match('a')) {
        add_syntax_error("Se espero nombre de funcion 'a'", atom_index);
    }
    if (!match('(')) {
        add_syntax_error("Se espero '(' despues del nombre de la funcion", atom_index);
    }
    ListaD();
	S();
    if (!match(')')) {
        add_syntax_error("Se espero ')' despues de los parametros", atom_index);
    }
}

void TipoFun() {
    if (atom_chain[atom_index] == 'g' || atom_chain[atom_index] == 'n' || atom_chain[atom_index] == 'd' || atom_chain[atom_index] == 'h' || atom_chain[atom_index] == 'v') {
        atom_index++;
    } else {
        add_syntax_error("Se espero tipo en definicion de funcion", atom_index);
    }
}


// Funcion principal de análisis sintáctico
void parse() {
    Programa();
    if (atom_chain[atom_index] != '\0') {
        add_syntax_error("Caracteres inesperados al final de la entrada\n", atom_index);
    }
    if (error_count == 0) {
        printf("El programa es sintacticamente correcto.\n");
    } else {
        printf("Errores sintacticos encontrados:\n");
        for (int i = 0; i < error_count; i++) {
            printf("%s\n", errorsynt[i].message);
        }
    }
}

int yywrap()
{
    return 1;
}

int main(int argc, char **argv)
{
 /* Inicializacion del arreglo de errores */
 /* Initialization of error array */
	initErrorList(&errors, 10);
	if (argc < 2)
	{
		printf("Usage: %s <source-file>\n", argv[0]);
		exit(1);
	}
 /* Manejo de archivo */
 /* File handling */
	FILE *source_file = fopen(argv[1], "r");
	
	if (!source_file)
	{
		printf("Error: No se puede abrir el archivo fuente: %s\n", argv[1]);
		exit(1);
	}
 
 /* Impresion de tokens */
 /* Token printing */
	printf("Tokens\n");
	
	yyin = source_file;
	yylex();
 /* Impresion de tablas */
 /*Table printing */
	printf("\n Symbol Table:\n");
	for(int i = 0; i < symbol_pos; i++)
	{
		printf("Pos: %d, Name: %s\n", symbol_table[i].pos, symbol_table[i].name);
	}
	
	printf("\n Literal Real Table:\n");
	for(int i = 0; i < literal_real_num_pos; i++)
	{
		printf("Pos: %d, Data: %s\n", literal_real_numbers[i].pos, literal_real_numbers[i].data);
	}

	printf("\n Literal Integer Table:\n");
	for(int i = 0; i < literal_int_num_pos; i++)
	{
		printf("Pos: %d, Data: %s\n", literal_integer_numbers[i].pos, literal_integer_numbers[i].data);
	}
	
	
	printf("\n String Literal Table\n");
	for(int i = 0; i < literal_str_pos; i++)
	{
		printf("Pos: %d, Data: %s\n", literal_strings[i].pos, literal_strings[i].data);
	}

	printf("\n Character Literal Table\n");
	for(int i = 0; i < literal_char_pos; i++)
	{
		printf("Pos: %d, Data: %s\n", literal_characters[i].pos, literal_characters[i].data);
	}

	 printf("Cadena de atomos: %s\n", atom_chain); // Imprimir cadena de átomos
 /* Impresion de errores */
 /* Error printing */
    atom_index = 0;
    error_count = 0;
    parse(); // Comienza el análisis sintáctico
	printf("\nErrores lexicos\n");
	if (errors.size > 0) {
        printf("Errores lexicos encontrados:\n");
        for (int i = 0; i < errors.size; i++) 
		{
            printf("%s\n", errors.messages[i]);
        }
    }
 /* Liberacion de memoria del arreglo dinámico de errores */
 /* Dynamic error array memory release */
	freeErrorList(&errors);
	fclose(source_file);
	return 0;
}

			

