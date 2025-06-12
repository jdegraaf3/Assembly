#include <stdlib.h>
#include "node.h"

void delete_table(node **htable, unsigned long table_size) {
	//walk through the chains in table
	for(unsigned long x = 0; x < table_size; x++){

		node *itr = *(htable + x);

		// TODO: free all the memory associated to each node in each chain
		while(itr != NULL){
			*(htable + x) = itr->next;
			free(itr->id);
			free(itr->purchased_item);
			free(itr);
			itr = *(htable + x);
		}
	}
	//free the entire table
	free(htable);
}
