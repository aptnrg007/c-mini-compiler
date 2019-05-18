struct sr{
	char *name ;
	char type[10] ;
	int lineno ;
	char *val ;
	int scope;
	struct sr *next ;
};
//sr symbol record
//st symbol
extern int scope_count ;
typedef struct sr sr ;
sr *st = NULL ;
sr *putsym() ;
sr *getsym() ;
sr *putsym(char *sym_name, int sym_type){
	char type[10] ;
	switch(sym_type){
		case 1:
			strcpy(type,"void");
			break;
		case 2:
			strcpy(type,"char");
			break;
		case 3:
			strcpy(type,"int");
			break;
		case 4:
			strcpy(type,"float");
			break;
	}
	sr *ptr;
	ptr=(sr *)malloc(sizeof(sr));
	ptr->name=(char *)malloc(strlen(sym_name)+1);
	strcpy(ptr->name,sym_name);
	strcpy(ptr->type,type);
	ptr->lineno =line ;
	ptr->val = "none";
	ptr->scope = scope;
	ptr->next=(struct sr *)st;
	st=ptr;
	return ptr;

}

sr *getsym(char *sym_name)
{
	sr *ptr;
	for(ptr=st;ptr!=(sr *)0;ptr=(sr *)ptr->next)
		if(strcmp(ptr->name,sym_name)==0)
			return ptr;
	return 0;
}

sr *printsym()
{
	sr *ptr;
	for(ptr=st;ptr!=(sr *)0;ptr=(sr *)ptr->next){
		printf("%s \t\t %s \t\t %d\t\t %d\n",ptr->name,ptr->type,ptr->lineno,ptr->scope);
	}
	printf("\n\n");
	return 0;
}
