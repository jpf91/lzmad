/**
 * Validate Index by using a hash function
 *
 * Hashing makes it possible to use constant amount of memory to validate
 * Index of arbitrary size.
 * Source: $(BASESRC lzma_/index_hash.d)
 * Author: Lasse Collin (original liblzma author),
 *         Johannes Pfau (D bindings)
 * License: public domain
 */
/*
 * This file has been put into the public domain.
 * You can do whatever you want with this file.
 */

module lzma_.index_hash;
import lzma;

extern(C):

/**
 * Opaque data type to hold the Index hash
 */
struct lzma_index_hash {};


/**
 * Allocate and initialize a new lzma_index_hash structure
 *
 * If index_hash is NULL, a new lzma_index_hash structure is allocated,
 * initialized, and a pointer to it returned. If allocation fails, NULL
 * is returned.
 *
 * If index_hash is non-NULL, it is reinitialized and the same pointer
 * returned. In this case, return value cannot be NULL or a different
 * pointer than the index_hash that was given as an argument.
 */
nothrow lzma_index_hash * lzma_index_hash_init(
		lzma_index_hash *index_hash, lzma_allocator *allocator);


/**
 * Deallocate lzma_index_hash structure
 */
nothrow void lzma_index_hash_end(
		lzma_index_hash *index_hash, lzma_allocator *allocator);


/**
 * Add a new Record to an Index hash
 *
 * Params:
 * index          =   Pointer to a lzma_index_hash structure
 * unpadded_size  =   Unpadded Size of a Block
 * uncompressed_size = Uncompressed Size of a Block
 *
 * Returns:      - LZMA_OK
 *              - LZMA_DATA_ERROR: Compressed or uncompressed size of the
 *                Stream or size of the Index field would grow too big.
 *              - LZMA_PROG_ERROR: Invalid arguments or this function is being
 *                used when lzma_index_hash_decode() has already been used.
 */
nothrow lzma_ret lzma_index_hash_append(lzma_index_hash *index_hash,
		lzma_vli unpadded_size, lzma_vli uncompressed_size);


/**
 * Decode and validate the Index field
 *
 * After telling the sizes of all Blocks with lzma_index_hash_append(),
 * the actual Index field is decoded with this function. Specifically,
 * once decoding of the Index field has been started, no more Records
 * can be added using lzma_index_hash_append().
 *
 * This function doesn't use lzma_stream structure to pass the input data.
 * Instead, the input buffer is specified using three arguments. This is
 * because it matches better the internal APIs of liblzma.
 *
 * Params:
 * index_hash  =    Pointer to a lzma_index_hash structure
 * in_         =    Pointer to the beginning of the input buffer
 * in_pos      =    in[*in_pos] is the next byte to process
 * in_size     =    in[in_size] is the first byte not to process
 *
 * Returns:      - LZMA_OK: So far good, but more input is needed.
 *              - LZMA_STREAM_END: Index decoded successfully and it matches
 *                the Records given with lzma_index_hash_append().
 *              - LZMA_DATA_ERROR: Index is corrupt or doesn't match the
 *                information given with lzma_index_hash_append().
 *              - LZMA_BUF_ERROR: Cannot progress because *in_pos >= in_size.
 *              - LZMA_PROG_ERROR
 */
nothrow lzma_ret lzma_index_hash_decode(lzma_index_hash *index_hash,
		const ubyte *in_, size_t *in_pos, size_t in_size);


/**
 * Get the size of the Index field as bytes
 *
 * This is needed to verify the Backward Size field in the Stream Footer.
 */
nothrow pure lzma_vli lzma_index_hash_size(
		const lzma_index_hash *index_hash);
