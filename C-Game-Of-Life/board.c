#include "cse30life.h"
#include "board.h"

/**
 * create a new board
 *
 * - malloc a Board structure
 * - set the generation to 0
 * - open the file (if it doesn't exist, return a NULL pointer
 * - read the first line which is the number of rows
 * - read the second line which is the number of cols
 * - set the # of rows and # of cols in the boards structure
 * - malloc bufferA and bufferB
 * - Set currentBuffer and nextBuffer
 * - clear both board buffers
 * - read the file until done.  each row contains a row and a columns separted by
 *   white space
 *     for each line, set the cell in the current buffer
 * - close the file
 * - return the boards pointer if successfull or NULL ptr otherwise
 */
Board* create_board(const char* filename) {
	Board* new_board = malloc(sizeof(Board));

	FILE *fp;
	if((fp = fopen(filename, "r")) == NULL) {
		return NULL;
	}
	unsigned int zero = 0;
	new_board->gen = zero;

	size_t rows;
	size_t cols;
	size_t ad_col;
	size_t ad_row;

	if(fscanf(fp, "%zu", &rows) == 0){
		return NULL;
	}
	new_board->num_rows = rows;

	if(fscanf(fp, "%zu", &cols) == 0){
                return NULL;
        }
	new_board->num_cols = cols;

	new_board->buffer_a = (Cell*)calloc(new_board->num_rows * new_board-> num_cols, sizeof(Cell));
        new_board->buffer_b = (Cell*)calloc(new_board->num_rows * new_board-> num_cols, sizeof(Cell));

	new_board->current_buffer = new_board->buffer_a;
	new_board->buffer_a = NULL;
	new_board->next_buffer = new_board->buffer_b;
	new_board->buffer_b = NULL;

	unsigned int alive = 1;
	while(fscanf(fp, "%zu %zu", &ad_row, &ad_col) > 0){
		size_t index = get_index(cols, ad_row, ad_col);
		*(new_board->current_buffer + index) = alive;
	}

	if(fclose(fp) == EOF){
		fprintf(stderr, "File did not close properly!");
	}

	return new_board;
}

/**
 * delete a board
 */
void delete_board(Board** bpp) {
	free((*bpp)->current_buffer);
	free((*bpp)->next_buffer);
	//free((*bpp)->buffer_a);
	//free((*bpp)->buffer_b);
	free(*bpp);
	*bpp = NULL;
}

/**
 * set all the belems in both buffers to 0
 */
void clear_board(Board* board) {
	memset(board->current_buffer, 0, board->num_rows * board->num_cols);
	memset(board->next_buffer, 0, board->num_rows * board->num_cols);
}

/**
 * swap the current and next buffers
 */
void swap_buffers(Board* board) {
	Cell* tmp_buffer = board->current_buffer;
	board->current_buffer = board->next_buffer;
	board->next_buffer = tmp_buffer;
	//free(tmp_buffer);
}

/**
 * get a cell index
 */
size_t get_index(size_t num_cols, size_t row, size_t col) {
	size_t index = (row * num_cols) + col;
	return index;
}
