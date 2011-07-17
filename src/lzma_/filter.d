/**
 * Common filter related types and functions
 *
 * Source: $(BASESRC lzma_/filter.d)
 * Author: Lasse Collin (original liblzma author),
 *         Johannes Pfau (D bindings)
 * License: public domain
 */
/*
 * This file has been put into the public domain.
 * You can do whatever you want with this file.
 */

module lzma_.filter;
import lzma;

extern(C):

/**
 * Maximum number of filters in a chain
 *
 * A filter chain can have 1-4 filters, of which three are allowed to change
 * the size of the data. Usually only one or two filters are needed.
 */
enum LZMA_FILTERS_MAX = 4;


/**
 * Filter options
 *
 * This structure is used to pass Filter ID and a pointer filter's
 * options to liblzma. A few functions work with a single lzma_filter
 * structure, while most functions expect a filter chain.
 *
 * A filter chain is indicated with an array of lzma_filter structures.
 * The array is terminated with .id = LZMA_VLI_UNKNOWN. Thus, the filter
 * array must have LZMA_FILTERS_MAX + 1 elements (that is, five) to
 * be able to hold any arbitrary filter chain. This is important when
 * using lzma_block_header_decode() from block.h, because too small
 * array would make liblzma write past the end of the filters array.
 */
struct lzma_filter
{
	/**
	 * Filter ID
	 *
	 * Use constants whose name begin with `LZMA_FILTER_' to specify
	 * different filters. In an array of lzma_filter structures, use
	 * LZMA_VLI_UNKNOWN to indicate end of filters.
	 *
	 * Note:        This is not an enum, because on some systems enums
	 *              cannot be 64-bit.
	 */
	lzma_vli id;

	/**
	 * Pointer to filter-specific options structure
	 *
	 * If the filter doesn't need options, set this to NULL. If id is
	 * set to LZMA_VLI_UNKNOWN, options is ignored, and thus
	 * doesn't need be initialized.
	 */
	void *options;

}


/**
 * Test if the given Filter ID is supported for encoding
 *
 * Return true if the give Filter ID is supported for encoding by this
 * liblzma build. Otherwise false is returned.
 *
 * There is no way to list which filters are available in this particular
 * liblzma version and build. It would be useless, because the application
 * couldn't know what kind of options the filter would need.
 */
nothrow lzma_bool lzma_filter_encoder_is_supported(lzma_vli id);


/**
 * Test if the given Filter ID is supported for decoding
 *
 * Return true if the give Filter ID is supported for decoding by this
 * liblzma build. Otherwise false is returned.
 */
nothrow lzma_bool lzma_filter_decoder_is_supported(lzma_vli id);


/**
 * Copy the filters array
 *
 * Copy the Filter IDs and filter-specific options from src to dest.
 * Up to LZMA_FILTERS_MAX filters are copied, plus the terminating
 * .id == LZMA_VLI_UNKNOWN. Thus, dest should have at least
 * LZMA_FILTERS_MAX + 1 elements space unless the caller knows that
 * src is smaller than that.
 *
 * Unless the filter-specific options is NULL, the Filter ID has to be
 * supported by liblzma, because liblzma needs to know the size of every
 * filter-specific options structure. The filter-specific options are not
 * validated. If options is NULL, any unsupported Filter IDs are copied
 * without returning an error.
 *
 * Old filter-specific options in dest are not freed, so dest doesn't
 * need to be initialized by the caller in any way.
 *
 * If an error occurs, memory possibly already allocated by this function
 * is always freed.
 *
 * Returns:      - LZMA_OK
 *              - LZMA_MEM_ERROR
 *              - LZMA_OPTIONS_ERROR: Unsupported Filter ID and its options
 *                is not NULL.
 *              - LZMA_PROG_ERROR: src or dest is NULL.
 */
nothrow lzma_ret lzma_filters_copy(const lzma_filter*src,
		lzma_filter *dest, lzma_allocator *allocator);


/**
 * Calculate approximate memory requirements for raw encoder
 *
 * This function can be used to calculate the memory requirements for
 * Block and Stream encoders too because Block and Stream encoders don't
 * need significantly more memory than raw encoder.
 *
 * Params:
 * filters  =   Array of filters terminated with
 *                          .id == LZMA_VLI_UNKNOWN.
 *
 * Returns:      Number of bytes of memory required for the given
 *              filter chain when encoding.
 */
pure nothrow ulong lzma_raw_encoder_memusage(const lzma_filter *filters);


/**
 * Calculate approximate memory requirements for raw decoder
 *
 * This function can be used to calculate the memory requirements for
 * Block and Stream decoders too because Block and Stream decoders don't
 * need significantly more memory than raw decoder.
 *
 * Params:
 * filters   =  Array of filters terminated with
 *                          .id == LZMA_VLI_UNKNOWN.
 *
 * Returns:      Number of bytes of memory required for the given
 *              filter chain when decoding.
 */
nothrow pure ulong lzma_raw_decoder_memusage(const lzma_filter *filters);


/**
 * Initialize raw encoder
 *
 * This function may be useful when implementing custom file formats.
 *
 * Params:
 * strm    Pointer to properly prepared lzma_stream
 * filters Array of lzma_filter structures. The end of the
 *                      array must be marked with .id = LZMA_VLI_UNKNOWN.
 *
 * The `action' with lzma_code() can be LZMA_RUN, LZMA_SYNC_FLUSH (if the
 * filter chain supports it), or LZMA_FINISH.
 *
 * Returns:      - LZMA_OK
 *              - LZMA_MEM_ERROR
 *              - LZMA_OPTIONS_ERROR
 *              - LZMA_PROG_ERROR
 */
nothrow lzma_ret lzma_raw_encoder(
		lzma_stream *strm, const lzma_filter *filters);


/**
 * Initialize raw decoder
 *
 * The initialization of raw decoder goes similarly to raw encoder.
 *
 * The `action' with lzma_code() can be LZMA_RUN or LZMA_FINISH. Using
 * LZMA_FINISH is not required, it is supported just for convenience.
 *
 * Returns:      - LZMA_OK
 *              - LZMA_MEM_ERROR
 *              - LZMA_OPTIONS_ERROR
 *              - LZMA_PROG_ERROR
 */
nothrow lzma_ret lzma_raw_decoder(
		lzma_stream *strm, const lzma_filter *filters);


/**
 * Update the filter chain in the encoder
 *
 * This function is for advanced users only. This function has two slightly
 * different purposes:
 *
 *  - After LZMA_FULL_FLUSH when using Stream encoder: Set a new filter
 *    chain, which will be used starting from the next Block.
 *
 *  - After LZMA_SYNC_FLUSH using Raw, Block, or Stream encoder: Change
 *    the filter-specific options in the middle of encoding. The actual
 *    filters in the chain (Filter IDs) cannot be changed. In the future,
 *    it might become possible to change the filter options without
 *    using LZMA_SYNC_FLUSH.
 *
 * While rarely useful, this function may be called also when no data has
 * been compressed yet. In that case, this function will behave as if
 * LZMA_FULL_FLUSH (Stream encoder) or LZMA_SYNC_FLUSH (Raw or Block
 * encoder) had been used right before calling this function.
 *
 * Returns:      - LZMA_OK
 *              - LZMA_MEM_ERROR
 *              - LZMA_MEMLIMIT_ERROR
 *              - LZMA_OPTIONS_ERROR
 *              - LZMA_PROG_ERROR
 */
nothrow lzma_ret lzma_filters_update(
		lzma_stream *strm, const lzma_filter *filters);


/**
 * Single-call raw encoder
 *
 * Params:
 * filters  =   Array of lzma_filter structures. The end of the
 *                          array must be marked with .id = LZMA_VLI_UNKNOWN.
 * allocator =  lzma_allocator for custom allocator functions.
 *                          Set to NULL to use malloc() and free().
 * in_        =  Beginning of the input buffer
 * in_size   =  Size of the input buffer
 * out_       =  Beginning of the output buffer
 * out_pos   =  The next byte will be written to out[*out_pos].
 *                          *out_pos is updated only if encoding succeeds.
 * out_size  =  Size of the out buffer; the first byte into
 *                          which no data is written to is out[out_size].
 *
 * Returns:      - LZMA_OK: Encoding was successful.
 *              - LZMA_BUF_ERROR: Not enough output buffer space.
 *              - LZMA_OPTIONS_ERROR
 *              - LZMA_MEM_ERROR
 *              - LZMA_DATA_ERROR
 *              - LZMA_PROG_ERROR
 *
 * Note:        There is no function to calculate how big output buffer
 *              would surely be big enough. (lzma_stream_buffer_bound()
 *              works only for lzma_stream_buffer_encode(); raw encoder
 *              won't necessarily meet that bound.)
 */
nothrow lzma_ret lzma_raw_buffer_encode(
		const lzma_filter *filters, lzma_allocator *allocator,
		const(ubyte) *in_, size_t in_size, ubyte *out_,
		size_t *out_pos, size_t out_size);


/**
 * Single-call raw decoder
 *
 * Params:
 * filters   =  Array of lzma_filter structures. The end of the
 *                          array must be marked with .id = LZMA_VLI_UNKNOWN.
 * allocator =  lzma_allocator for custom allocator functions.
 *                          Set to NULL to use malloc() and free().
 * in_        =  Beginning of the input buffer
 * in_pos    =  The next byte will be read from in[*in_pos].
 *                          *in_pos is updated only if decoding succeeds.
 * in_size   =  Size of the input buffer; the first byte that
 *                          won't be read is in[in_size].
 * out_       =  Beginning of the output buffer
 * out_pos   =  The next byte will be written to out[*out_pos].
 *                          *out_pos is updated only if encoding succeeds.
 * out_size  =  Size of the out buffer; the first byte into
 *                          which no data is written to is out[out_size].
 */
nothrow lzma_ret lzma_raw_buffer_decode(const lzma_filter *filters,
        lzma_allocator *allocator,
		const(ubyte) *in_, size_t *in_pos, size_t in_size,
		ubyte *out_, size_t *out_pos, size_t out_size);


/**
 * Get the size of the Filter Properties field
 *
 * This function may be useful when implementing custom file formats
 * using the raw encoder and decoder.
 *
 * Params:
 * size   = Pointer to uint to hold the size of the properties
 * filter = Filter ID and options (the size of the properties may
 *                      vary depending on the options)
 *
 * Returns:      - LZMA_OK
 *              - LZMA_OPTIONS_ERROR
 *              - LZMA_PROG_ERROR
 *
 * Note:        This function validates the Filter ID, but does not
 *              necessarily validate the options. Thus, it is possible
 *              that this returns LZMA_OK while the following call to
 *              lzma_properties_encode() returns LZMA_OPTIONS_ERROR.
 */
nothrow lzma_ret lzma_properties_size(
		uint *size, const lzma_filter *filter);


/**
 * Encode the Filter Properties field
 *
 * Params:
 * filter = Filter ID and options
 * props  = Buffer to hold the encoded options. The size of
 *                      buffer must have been already determined with
 *                      lzma_properties_size().
 *
 * Returns:      - LZMA_OK
 *              - LZMA_OPTIONS_ERROR
 *              - LZMA_PROG_ERROR
 *
 * Note:        Even this function won't validate more options than actually
 *              necessary. Thus, it is possible that encoding the properties
 *              succeeds but using the same options to initialize the encoder
 *              will fail.
 *
 * Note:        If lzma_properties_size() indicated that the size
 *              of the Filter Properties field is zero, calling
 *              lzma_properties_encode() is not required, but it
 *              won't do any harm either.
 */
nothrow lzma_ret lzma_properties_encode(
		const lzma_filter *filter, ubyte *props);


/**
 * Decode the Filter Properties field
 *
 * Params:
 * filter    =  filter->id must have been set to the correct
 *                          Filter ID. filter->options doesn't need to be
 *                          initialized (it's not freed by this function). The
 *                          decoded options will be stored to filter->options.
 *                          filter->options is set to NULL if there are no
 *                          properties or if an error occurs.
 * allocator =  Custom memory allocator used to allocate the
 *                          options. Set to NULL to use the default malloc(),
 *                          and in case of an error, also free().
 * props      = Input buffer containing the properties.
 * props_size = Size of the properties. This must be the exact
 *                          size; giving too much or too little input will
 *                          return LZMA_OPTIONS_ERROR.
 *
 * Returns:      - LZMA_OK
 *              - LZMA_OPTIONS_ERROR
 *              - LZMA_MEM_ERROR
 */
nothrow lzma_ret lzma_properties_decode(
		lzma_filter *filter, lzma_allocator *allocator,
		const ubyte *props, size_t props_size);


/**
 * Calculate encoded size of a Filter Flags field
 *
 * Knowing the size of Filter Flags is useful to know when allocating
 * memory to hold the encoded Filter Flags.
 *
 * Params:
 * size   = Pointer to integer to hold the calculated size
 * filter = Filter ID and associated options whose encoded
 *                      size is to be calculated
 *
 * Returns:      - LZMA_OK: *size set successfully. Note that this doesn't
 *                guarantee that filter->options is valid, thus
 *                lzma_filter_flags_encode() may still fail.
 *              - LZMA_OPTIONS_ERROR: Unknown Filter ID or unsupported options.
 *              - LZMA_PROG_ERROR: Invalid options
 *
 * Note:        If you need to calculate size of List of Filter Flags,
 *              you need to loop over every lzma_filter entry.
 */
nothrow lzma_ret lzma_filter_flags_size(
		uint *size, const lzma_filter *filter);


/**
 * Encode Filter Flags into given buffer
 *
 * In contrast to some functions, this doesn't allocate the needed buffer.
 * This is due to how this function is used internally by liblzma.
 *
 * Params:
 * filter   =   Filter ID and options to be encoded
 * out_      =   Beginning of the output buffer
 * out_pos  =   out[*out_pos] is the next write position. This
 *                       =   is updated by the encoder.
 * out_size =   out[out_size] is the first byte to not write.
 *
 * Returns:      - LZMA_OK: Encoding was successful.
 *              - LZMA_OPTIONS_ERROR: Invalid or unsupported options.
 *              - LZMA_PROG_ERROR: Invalid options or not enough output
 *                buffer space (you should have checked it with
 *                lzma_filter_flags_size()).
 */
nothrow lzma_ret lzma_filter_flags_encode(const lzma_filter *filter,
		ubyte *out_, size_t *out_pos, size_t out_size);


/**
 * Decode Filter Flags from given buffer
 *
 * The decoded result is stored into *filter. The old value of
 * filter->options is not free()d.
 *
 * Returns:      - LZMA_OK
 *              - LZMA_OPTIONS_ERROR
 *              - LZMA_MEM_ERROR
 *              - LZMA_PROG_ERROR
 */
nothrow lzma_ret lzma_filter_flags_decode(
		lzma_filter *filter, lzma_allocator *allocator,
		const ubyte *in_, size_t *in_pos, size_t in_size);
