/**
 * .xz Stream Header and Stream Footer encoder and decoder
 * Source: $(BASESRC lzma_/stream_flags.d)
 * Author: Lasse Collin (original liblzma author),
 *         Johannes Pfau (D bindings)
 * License: public domain
 */
/*
 * This file has been put into the public domain.
 * You can do whatever you want with this file.
 */

module lzma_.stream_flags;
import lzma;

extern(C):


/**
 * Size of Stream Header and Stream Footer
 *
 * Stream Header and Stream Footer have the same size and they are not
 * going to change even if a newer version of the .xz file format is
 * developed in future.
 */
enum LZMA_STREAM_HEADER_SIZE = 12;


/**
 * Options for encoding/decoding Stream Header and Stream Footer
 */
struct lzma_stream_flags
{
	/**
	 * Stream Flags format version
	 *
	 * To prevent API and ABI breakages if new features are needed in
	 * Stream Header or Stream Footer, a version number is used to
	 * indicate which fields in this structure are in use. For now,
	 * version must always be zero. With non-zero version, the
	 * lzma_stream_header_encode() and lzma_stream_footer_encode()
	 * will return LZMA_OPTIONS_ERROR.
	 *
	 * lzma_stream_header_decode() and lzma_stream_footer_decode()
	 * will always set this to the lowest value that supports all the
	 * features indicated by the Stream Flags field. The application
	 * must check that the version number set by the decoding functions
	 * is supported by the application. Otherwise it is possible that
	 * the application will decode the Stream incorrectly.
	 */
	uint version_;

	/**
	 * Backward Size
	 *
	 * Backward Size must be a multiple of four bytes. In this Stream
	 * format version, Backward Size is the size of the Index field.
	 *
	 * Backward Size isn't actually part of the Stream Flags field, but
	 * it is convenient to include in this structure anyway. Backward
	 * Size is present only in the Stream Footer. There is no need to
	 * initialize backward_size when encoding Stream Header.
	 *
	 * lzma_stream_header_decode() always sets backward_size to
	 * LZMA_VLI_UNKNOWN so that it is convenient to use
	 * lzma_stream_flags_compare() when both Stream Header and Stream
	 * Footer have been decoded.
	 */
	lzma_vli backward_size;
    ///
	enum LZMA_BACKWARD_SIZE_MIN = 4;
    ///
	enum LZMA_BACKWARD_SIZE_MAX = (1UL << 34);

	/**
	 * Check ID
	 *
	 * This indicates the type of the integrity check calculated from
	 * uncompressed data.
	 */
	lzma_check check;

	/*
	 * Reserved space to allow possible future extensions without
	 * breaking the ABI. You should not touch these, because the
	 * names of these variables may change.
	 *
	 * (We will never be able to use all of these since Stream Flags
	 * is just two bytes plus Backward Size of four bytes. But it's
	 * nice to have the proper types when they are needed.)
	 */
	lzma_reserved_enum reserved_enum1;
	lzma_reserved_enum reserved_enum2;
	lzma_reserved_enum reserved_enum3;
	lzma_reserved_enum reserved_enum4;
	lzma_reserved_enum reserved_enum5;
	lzma_reserved_enum reserved_enum6;
	lzma_bool reserved_bool1;
	lzma_bool reserved_bool2;
	lzma_bool reserved_bool3;
	lzma_bool reserved_bool4;
	lzma_bool reserved_bool5;
	lzma_bool reserved_bool6;
	lzma_bool reserved_bool7;
	lzma_bool reserved_bool8;
	uint reserved_int1;
	uint reserved_int2;
	uint reserved_int3;
	uint reserved_int4;

}


/**
 * Encode Stream Header
 *
 * Params:
 * options   =  Stream Header options to be encoded.
 *                          options->backward_size is ignored and doesn't
 *                          need to be initialized.
 * out_       =  Beginning of the output buffer of
 *                          LZMA_STREAM_HEADER_SIZE bytes.
 *
 * Returns:      - LZMA_OK: Encoding was successful.
 *              - LZMA_OPTIONS_ERROR: options->version is not supported by
 *                this liblzma version.
 *              - LZMA_PROG_ERROR: Invalid options.
 */
nothrow lzma_ret lzma_stream_header_encode(
		const lzma_stream_flags *options, ubyte *out_);


/**
 * Encode Stream Footer
 *
 * Params:
 * options  =   Stream Footer options to be encoded.
 * out_     =    Beginning of the output buffer of
 *                          LZMA_STREAM_HEADER_SIZE bytes.
 *
 * Returns:      - LZMA_OK: Encoding was successful.
 *              - LZMA_OPTIONS_ERROR: options->version is not supported by
 *                this liblzma version.
 *              - LZMA_PROG_ERROR: Invalid options.
 */
nothrow lzma_ret lzma_stream_footer_encode(
		const lzma_stream_flags *options, ubyte *out_);


/**
 * Decode Stream Header
 *
 * Params:
 * options  =   Target for the decoded Stream Header options.
 * in_       =   Beginning of the input buffer of
 *                          LZMA_STREAM_HEADER_SIZE bytes.
 *
 * options->backward_size is always set to LZMA_VLI_UNKNOWN. This is to
 * help comparing Stream Flags from Stream Header and Stream Footer with
 * lzma_stream_flags_compare().
 *
 * Returns:      - LZMA_OK: Decoding was successful.
 *              - LZMA_FORMAT_ERROR: Magic bytes don't match, thus the given
 *                buffer cannot be Stream Header.
 *              - LZMA_DATA_ERROR: CRC32 doesn't match, thus the header
 *                is corrupt.
 *              - LZMA_OPTIONS_ERROR: Unsupported options are present
 *                in the header.
 *
 * Note:        When decoding .xz files that contain multiple Streams, it may
 *              make sense to print "file format not recognized" only if
 *              decoding of the Stream Header of the _first_ Stream gives
 *              LZMA_FORMAT_ERROR. If non-first Stream Header gives
 *              LZMA_FORMAT_ERROR, the message used for LZMA_DATA_ERROR is
 *              probably more appropriate.
 *
 *              For example, Stream decoder in liblzma uses LZMA_DATA_ERROR if
 *              LZMA_FORMAT_ERROR is returned by lzma_stream_header_decode()
 *              when decoding non-first Stream.
 */
nothrow lzma_ret lzma_stream_header_decode(
		lzma_stream_flags *options, const ubyte *in_);


/**
 * Decode Stream Footer
 *
 * Params:
 * options  =   Target for the decoded Stream Header options.
 * in_      =   Beginning of the input buffer of
 *                          LZMA_STREAM_HEADER_SIZE bytes.
 *
 * Returns:      - LZMA_OK: Decoding was successful.
 *              - LZMA_FORMAT_ERROR: Magic bytes don't match, thus the given
 *                buffer cannot be Stream Footer.
 *              - LZMA_DATA_ERROR: CRC32 doesn't match, thus the Stream Footer
 *                is corrupt.
 *              - LZMA_OPTIONS_ERROR: Unsupported options are present
 *                in Stream Footer.
 *
 * Note:        If Stream Header was already decoded successfully, but
 *              decoding Stream Footer returns LZMA_FORMAT_ERROR, the
 *              application should probably report some other error message
 *              than "file format not recognized", since the file more likely
 *              is corrupt (possibly truncated). Stream decoder in liblzma
 *              uses LZMA_DATA_ERROR in this situation.
 */
nothrow lzma_ret lzma_stream_footer_decode(
		lzma_stream_flags *options, const ubyte *in_);


/**
 * Compare two lzma_stream_flags structures
 *
 * backward_size values are compared only if both are not
 * LZMA_VLI_UNKNOWN.
 *
 * Returns:      - LZMA_OK: Both are equal. If either had backward_size set
 *                to LZMA_VLI_UNKNOWN, backward_size values were not
 *                compared or validated.
 *              - LZMA_DATA_ERROR: The structures differ.
 *              - LZMA_OPTIONS_ERROR: version in either structure is greater
 *                than the maximum supported version (currently zero).
 *              - LZMA_PROG_ERROR: Invalid value, e.g. invalid check or
 *                backward_size.
 */
nothrow pure lzma_ret lzma_stream_flags_compare(
		const lzma_stream_flags *a, const lzma_stream_flags *b);