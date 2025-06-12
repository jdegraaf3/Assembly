#include "sim.h"

#define C_IMPL
extern void asm_do_row(Cell*, Cell*, size_t, size_t, size_t);

/**
 * gets x mod N (works for negative numbers as well! Use this instead of %)
 */
size_t mod(int x, size_t N) {
	return (x + x / N * N) % N;
}
unsigned int alive = 1;
unsigned int dead = 0;

/**
 * process one row of the board
 */
static void do_row(Cell* dest, Cell* src, size_t row, size_t rows, size_t cols) {
	for(int i = 0; i < (int)cols; i ++){
		int alvneighbor_cnt = 0;
		for(int j = -1; j < 2; j++){
			// Same row
			if(*(src + get_index(cols, row, mod(i + j, cols))) == 1){
				alvneighbor_cnt += 1;
			}
			// Row above
			if(*(src + get_index(cols, mod((int)row-1,rows), mod(i + j, cols))) == 1){
                                alvneighbor_cnt += 1;
                        }
			// Row below
			if(*(src + get_index(cols, mod((int)row+1,rows), mod(i + j, cols))) == 1){
                                alvneighbor_cnt += 1;
                        }
		}
		// Alive cell
		if(*(src + get_index(cols, row, i)) == 1){
			alvneighbor_cnt -=1;
			if(alvneighbor_cnt <= 1 || alvneighbor_cnt >= 4){
				*(dest + get_index(cols, row, i)) = dead;
			}else{
				*(dest + get_index(cols, row, i)) = alive;
			}
		}
		// Dead cell
		if(*(src + get_index(cols, row, i)) == 0){
			if(alvneighbor_cnt == 3 || alvneighbor_cnt == 6){
				*(dest + get_index(cols, row, i)) = alive;
			}else{
				*(dest + get_index(cols, row, i)) = dead;
			}
		}
	}
/*
	for(int i = 0; i < (int)cols; i++){
		int alvneighbor_cnt = 0;
		//Square to the right
		if(*(src + get_index(cols, row, mod(i + 1, cols))) == 1){
			alvneighbor_cnt += 1;
		}
		//Square to the left
		if(*(src + get_index(cols, row, mod(i - 1, cols))) == 1){
                        alvneighbor_cnt += 1;
                }
		//Square below
		if(*(src + get_index(cols, mod((int)row + 1, rows), i)) == 1){
                        alvneighbor_cnt += 1;
                }
		//Square above
		if(*(src + get_index(cols, mod((int)row - 1, rows), i)) == 1){
                        alvneighbor_cnt += 1;
                }
		//Square top left
		if(*(src + get_index(cols, mod((int)row - 1, rows), mod(i - 1, cols))) == 1){
                        alvneighbor_cnt += 1;
                }
		//Square top right
		if(*(src + get_index(cols, mod((int)row - 1, rows), mod(i + 1, cols))) == 1){
                        alvneighbor_cnt += 1;
                }
		//Square bottom left
		if(*(src + get_index(cols, mod((int)row + 1, rows), mod(i - 1, cols))) == 1){
                        alvneighbor_cnt += 1;
                }
		//Square bottom right
		if(*(src + get_index(cols, mod((int)row + 1, rows), mod(i + 1, cols))) == 1){
                        alvneighbor_cnt += 1;
                }

		//If current cell is alive
		if( ((int)*(src + get_index(cols, row, i)) == 1) && (alvneighbor_cnt <= 1 || alvneighbor_cnt >= 4)){
			*(dest + get_index(cols, row, i)) = 0;
		}
		if( ((int)*(src + get_index(cols, row, i)) == 1) && (alvneighbor_cnt > 1 && alvneighbor_cnt < 4)){
			*(dest + get_index(cols, row, i)) = 1;
		}
		//If current cell is dead
		if( ((int)*(src + get_index(cols, row, i)) == 0) && (alvneighbor_cnt == 3 || alvneighbor_cnt == 6)){
			*(dest + get_index(cols, row, i)) = 1;
		}
		if(((int)*(src + get_index(cols, row, i)) == 0) && (alvneighbor_cnt % 3 != 0 )){
			*(dest + get_index(cols, row, i)) = 0;
		}
	}
*/
}


/**
 * perform a simulation for "steps" generations
 *
 * for steps
 *   calculate the next board
 *   swap current and next
 */
void sim_loop(Board* board, unsigned int steps) {
	unsigned int x = 0;
	while(x < steps){
		for(unsigned int i = 0; i < board->num_rows; i++){
			do_row(board->next_buffer, board->current_buffer, i, board->num_rows, board->num_cols);
		}
		swap_buffers(board);
		board->gen += 1;
		x+=1;
	}
}
