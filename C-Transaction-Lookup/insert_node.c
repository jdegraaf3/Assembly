#include <stdlib.h>
#include <string.h>
#include "node.h"

node *insert_node(node *front, char *id, char *purchased_item, double cost) {

	// create a node, copy in the parameter fields
	// make sure that you do a deep copy
	node *tmp = (node*)malloc(sizeof(struct node));
	if(tmp == NULL){
		return NULL;
	}
	char* y = (char*)malloc(sizeof(char) * strlen(id) + 1);
	char* x = (char*)malloc(sizeof(char) * strlen(purchased_item) + 1);
	if(y == NULL || x == NULL){
		return NULL;
	}
	strcpy(y, id);
	strcpy(x, purchased_item);
	tmp->cost = cost;
	tmp->id = y;
	tmp->purchased_item = x;
	tmp->next = NULL;

	//link the new node into the chain
	if(front == NULL){
		front = tmp;
	}else{
		tmp->next = front;
		front = tmp;
	}

	//return the new head of the chain if the function succeeded
	return tmp;
}


