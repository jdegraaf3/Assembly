#include <string.h>
#include "node.h"

node *node_lookup(node *front, char *id) {
	// TODO: step through the chain pointed to by front
	// use function like strcmp to compare the id to the current node
	// if found return a pointer to the node, else return NULL
	node *itr = front;
	while(itr != NULL){
		if(strcmp(itr->id, id) == 0){
			return itr;
		}
		itr = itr->next;
	}
	return NULL;
}
