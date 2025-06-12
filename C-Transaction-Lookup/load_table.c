#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "node.h"

#define MAX_LINELEN 100
#define FILE_OPEN_ERR_MSG "error in load_table while opening file %s\n"
#define DUPLICATE_ID_MSG "load_table duplicate entry: %s\n"
#define INSERTION_ERROR_MSG "load_table could not create node for %s\n"

int load_table(node **htable, unsigned long int table_size, char *filename) {

	//open the file and check that it was successful
	FILE *fp = fopen(filename, "r");
	if(fp == NULL){
		fprintf(stderr, FILE_OPEN_ERR_MSG, filename);
		return -1;
	}
	//node *test = (node*)malloc(sizeof(struct node));
	//node *new_node = (node*)malloc(sizeof(struct node));
	//if(test == NULL || new_node == NULL){
	//	return -1;
	//}
	char *id;
	char *purchased_item;
	double cost;
	// loop through the file and read one line at a time using fgets
	// see manual page for fgets for information on parameters
	char buf[MAX_LINELEN + 1]; // input buffer for fgets
	while (fgets(buf, MAX_LINELEN + 1, fp) == buf) {
		// for each line, use strtok to break it into columns
		// (convert the third column to a double)
		int x = 0;
		for (char *p = strtok(buf,","); p != NULL; p = strtok(NULL, ",")){
  			if(x == 0){id = p;}
			if(x == 1){purchased_item = p;}
			if(x == 2){cost = atof(p);}
			x+=1;
		}

		//get the corresponding chain for this entry
		unsigned long index = hash(id) % table_size;

		//test = node_lookup(*(htable + index), new_node->id);
		//check that the node doesn't already exist in table
		if(node_lookup(*(htable + index), id) != NULL){
			fprintf(stderr, DUPLICATE_ID_MSG, id);
			continue;
		}

		//add non-duplicate node to the front of its chain
		else{
			*(htable + index) = insert_node(*(htable + index), id, purchased_item, cost);
			if(*(htable + index) != NULL){
				continue;
			}
			//insertion failed
			else{
				fprintf(stderr, INSERTION_ERROR_MSG, id);
				return -1;
			}
		}
	}
	fclose(fp);
	return 0;
}
