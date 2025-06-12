#include <stdio.h>
#include <limits.h>
#include "node.h"

#define TABLESIZE_MSG "Table size: %lu\n"
#define TOTAL_ENTRIES_MSG "Total entries: %lu\n"
#define LONGEST_MSG "Longest chain: %lu\n"
#define SHORTEST_MSG "Shortest chain: %lu\n"
#define EMPTY_MSG "Empty buckets: %lu\n"

void print_info(node **htable, unsigned long table_size) {
	// walk down the indices of the htable
	// iterate through each chain and update statistics
	// print out statistics at end
	// NOTE: all your statistics variables should be of type
	// unsigned long
	// NOTE: you may use ULONG_MAX if you want
	// (maximum value for unsigned long int)

	unsigned long total_entries = 0;
	unsigned long longest_chain = 0;
	unsigned long shortest_chain = 0;
	unsigned long empty_buckets = 0;
	unsigned long chain_counter = 0;
	for(unsigned long i = 0; i < table_size; i++){
		// filled bucket
		if(*(htable + i) != NULL){
			chain_counter = 0;
			node* itr = *(htable + i);
			while(itr != NULL){
				total_entries +=1;
				chain_counter +=1;
				itr = itr->next;
			}
			if(chain_counter > longest_chain){
				longest_chain = chain_counter;
			}
			if(i == 0){
				shortest_chain = chain_counter;
			}
			if(chain_counter < shortest_chain && i != 1){
				shortest_chain = chain_counter;
			}
		}
		//null bucket
		else{
			if(shortest_chain != 0){
				shortest_chain = 0;
			}
			empty_buckets += 1;
			continue;
		}
	}
	printf(TABLESIZE_MSG, table_size);
	printf(TOTAL_ENTRIES_MSG, total_entries);
	printf(LONGEST_MSG, longest_chain);
	printf(SHORTEST_MSG, shortest_chain);
	printf(EMPTY_MSG, empty_buckets);
}

