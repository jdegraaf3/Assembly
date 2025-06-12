#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "node.h"

#define MAX_QUERY_LEN 100
#define MIN_TABLE_SIZE 3
#define DEFAULT_TABLE_SIZE 1873
#define QUERY_SUCCESS_FORMAT "found sale id=%s, purchased_item=%s, cost=%.5f\n"
#define QUERY_FAILURE_FORMAT "could not find sale with id=%s\n"
#define USAGE_STRING "%s [-s] [-t table_size] <filename>\n"

int main(int argc, char **argv) {
	int s_flag;
	unsigned long table_size = 0;

	int c;
    	while ((c = getopt(argc, argv, "st:")) != -1) {
        	switch (c) {
        	case 's':
            		s_flag = 1;
            		break;
		case 't':
			if(atoi(optarg) > MIN_TABLE_SIZE){
				char *eptr;
				table_size = strtoul(optarg,&eptr,10);
			}
			break;
        	default:
            		fprintf(stderr, USAGE_STRING, argv[0]);
            		return EXIT_FAILURE;
        	}
    	}
	if(table_size == 0){
		table_size = DEFAULT_TABLE_SIZE;
	}

	// TODO: initialze htable
	// using calloc so all buckets are initialized to NULL
	node **htable = calloc(table_size, sizeof(*htable));
	if (htable == NULL) {
		return EXIT_FAILURE;
	}

	//get filename and call load_table;
	char *filename =  *(argv + optind);

	if (load_table(htable, table_size, filename) == -1) {
		fprintf(stderr, "error in load_table\n");
		delete_table(htable, table_size);
		return EXIT_FAILURE;
	}

	char query[MAX_QUERY_LEN + 1];
	char *end;
	int q_success = 0;
	// read one line at a time from stdin, do a lookup for that id
	//node *qnode = (node*)malloc(sizeof(struct node));
	while (fgets(query, MAX_QUERY_LEN + 1, stdin) == query) {
		// replace the \n, if it exists (for hashing)
		if ((end = strchr(query, '\n'))) *end = '\0'; // don't change this line

		// read a line from stdin and perform a lookup
		// if the sale is found, print its contents to stdout
		// using QUERY_SUCCESS_FORMAT
		// if the sale is not found, print a message to **stdout**
                // using QUERY_FAILURE_FORMAT
                // keep track of the number of successful queries
		//qnode = node_lookup(*(htable + (hash(query) % table_size)), query);
		if(node_lookup(*(htable + (hash(query) % table_size)), query) != NULL){
			q_success +=1;
			printf(QUERY_SUCCESS_FORMAT, (node_lookup(*(htable + (hash(query) % table_size)), query))->id, 
(node_lookup(*(htable + (hash(query) % table_size)), query))->purchased_item, 
(node_lookup(*(htable + (hash(query) % table_size)), query))->cost);
		}else{
			printf(QUERY_FAILURE_FORMAT, query);
		}
	}
	printf("%d successful queries\n", q_success);

	// if -s called then print stats
	if (s_flag == 1) {
		print_info(htable, table_size);
	}

	//free all allocated memory associated with the table
	delete_table(htable, table_size);
	//free(qnode);
	return EXIT_SUCCESS;
}



