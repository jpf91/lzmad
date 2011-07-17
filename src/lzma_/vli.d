/**
 * Variable-length integer handling
 *
 * In the .xz format, most integers are encoded in a variable-length
 * representation, which is sometimes called little endian base-128 encoding.
 * This saves space when smaller values are more likely than bigger values.
 *
 * The encoding scheme encodes seven bits to every byte, using minimum
 * number of bytes required to represent the given value. Encodings that use
 * non-minimum number of bytes are invalid, thus every integer has exactly
 * one encoded representation. The maximum number of bits in a VLI is 63,
 * thus the vli argument must be less than or equal to UINT64_MAX / 2. You
 * should use LZMA_VLI_MAX for clarity.
 * 
 * Source: $(BASESRC lzma_/vli.d)
 * Author: Lasse Collin (original liblzma author),
 *         Johannes Pfau (D bindings)
 * License: public domain
 */
/*
 * This file has been put into the public domain.
 * You can do whatever you want with this file.
 */

module lzma_.vli;
import lzma;

extern(C):


/**
 * Maximum supported value of a variable-length integer
 */
enum LZMA_VLI_MAX = (ulong.max / 2);

/**
 * VLI value to denote that the value is unknown
 */
enum LZMA_VLI_UNKNOWN = ulong.max;

/**
 * Maximum supported encoded length of variable length integers
 */
enum LZMA_VLI_BYTES_MAX = 9;

/**
 * VLI constant suffix
 */
//#define LZMA_VLI_C(n) UINT64_C(n)


/**
 * Variable-length integer type
 *
 * Valid VLI values are in the range [0, LZMA_VLI_MAX]. Unknown value is
 * indicated with LZMA_VLI_UNKNOWN, which is the maximum value of the
 * underlaying integer type.
 *
 * lzma_vli will be uint64_t for the foreseeable future. If a bigger size
 * is needed in the future, it is guaranteed that 2 * LZMA_VLI_MAX will
 * not overflow lzma_vli. This simplifies integer overflow detection.
 */
alias ulong lzma_vli;


/**
 * Validate a variable-length integer
 *
 * This is useful to test that application has given acceptable values
 * for example in the uncompressed_size and compressed_size variables.
 *
 * \return      True if the integer is representable as VLI or if it
 *              indicates unknown value.
 */
bool lzma_vli_is_valid(lzma_vli vli)
{
    return vli <= LZMA_VLI_MAX || (vli) == LZMA_VLI_UNKNOWN;
}


/**
 * Encode a variable-length integer
 *
 * This function has two modes: single-call and multi-call. Single-call mode
 * encodes the whole integer at once; it is an error if the output buffer is
 * too small. Multi-call mode saves the position in *vli_pos, and thus it is
 * possible to continue encoding if the buffer becomes full before the whole
 * integer has been encoded.
 *
 * Params:
 * vli     =  Integer to be encoded
 * vli_pos =  How many VLI-encoded bytes have already been written
 *                        out. When starting to encode a new integer in
 *                        multi-call mode, *vli_pos must be set to zero.
 *                        To use single-call encoding, set vli_pos to NULL.
 * out_     =  Beginning of the output buffer
 * out_pos =  The next byte will be written to out[*out_pos].
 * out_size=  Size of the out buffer; the first byte into
 *                        which no data is written to is out[out_size].
 *
 * Returns:      Slightly different return values are used in multi-call and
 *              single-call modes.
 *
 *              Single-call (vli_pos == NULL):
 *              - LZMA_OK: Integer successfully encoded.
 *              - LZMA_PROG_ERROR: Arguments are not sane. This can be due
 *                to too little output space; single-call mode doesn't use
 *                LZMA_BUF_ERROR, since the application should have checked
 *                the encoded size with lzma_vli_size().
 *
 *              Multi-call (vli_pos != NULL):
 *              - LZMA_OK: So far all OK, but the integer is not
 *                completely written out yet.
 *              - LZMA_STREAM_END: Integer successfully encoded.
 *              - LZMA_BUF_ERROR: No output space was provided.
 *              - LZMA_PROG_ERROR: Arguments are not sane.
 */
nothrow lzma_ret lzma_vli_encode(lzma_vli vli, size_t *vli_pos,
		ubyte* out_, size_t *out_pos, size_t out_size);


/**
 * Decode a variable-length integer
 *
 * Like lzma_vli_encode(), this function has single-call and multi-call modes.
 *
 * Params:
 * vli     =  Pointer to decoded integer. The decoder will
 *                        initialize it to zero when *vli_pos == 0, so
 *                        application isn't required to initialize *vli.
 * vli_pos =  How many bytes have already been decoded. When
 *                        starting to decode a new integer in multi-call
 *                        mode, *vli_pos must be initialized to zero. To
 *                        use single-call decoding, set vli_pos to NULL.
 * in_      =  Beginning of the input buffer
 * in_pos  =  The next byte will be read from in[*in_pos].
 * in_size =  Size of the input buffer; the first byte that
 *                        won't be read is in[in_size].
 *
 * Returns:      Slightly different return values are used in multi-call and
 *              single-call modes.
 *
 *              Single-call (vli_pos == NULL):
 *              - LZMA_OK: Integer successfully decoded.
 *              - LZMA_DATA_ERROR: Integer is corrupt. This includes hitting
 *                the end of the input buffer before the whole integer was
 *                decoded; providing no input at all will use LZMA_DATA_ERROR.
 *              - LZMA_PROG_ERROR: Arguments are not sane.
 *
 *              Multi-call (vli_pos != NULL):
 *              - LZMA_OK: So far all OK, but the integer is not
 *                completely decoded yet.
 *              - LZMA_STREAM_END: Integer successfully decoded.
 *              - LZMA_DATA_ERROR: Integer is corrupt.
 *              - LZMA_BUF_ERROR: No input was provided.
 *              - LZMA_PROG_ERROR: Arguments are not sane.
 */
nothrow lzma_ret lzma_vli_decode(lzma_vli *vli, size_t *vli_pos,
		const(ubyte)* in_, size_t *in_pos, size_t in_size);


/**
 * Get the number of bytes required to encode a VLI
 *
 * Returns      Number of bytes on success (1-9). If vli isn't valid,
 *              zero is returned.
 */
nothrow pure uint lzma_vli_size(lzma_vli vli);
