/**
 * The public API of liblzma data compression library
 *
 * liblzma is a public domain general-purpose data compression library with
 * a zlib-like API. The native file format is .xz, but also the old .lzma
 * format and raw (no headers) streams are supported. Multiple compression
 * algorithms (filters) are supported. Currently LZMA2 is the primary filter.
 *
 * liblzma is part of $(LINK2 http://tukaani.org/xz/, XZ Utils). XZ Utils includes
 * a gzip-like command line tool named xz and some other tools. XZ Utils
 * is developed and maintained by Lasse Collin.
 *
 * Major parts of liblzma are based on Igor Pavlov's public domain $(LINK2 http://7-zip.org/sdk.html, LZMA SDK).
 *
 * The SHA-256 implementation is based on the public domain code found from
 * $(LINK2 http://7-zip.org, 7-Zip), which has a modified version of the public
 * domain SHA-256 code found from $(LINK2 http://www.cryptopp.com/, Crypto++).
 * The SHA-256 code in Crypto++ was written by Kevin Springle and Wei Dai.
 *
 * Source: $(BASESRC lzma.d)
 * Author: Lasse Collin (original liblzma author),
 *         Johannes Pfau (D bindings)
 * License: public domain
 */
/*
 * This file has been put into the public domain.
 * You can do whatever you want with this file.
 */
module lzma;

/***********
 * nothrow *
 ***********/

/*
 * None of the functions in liblzma may throw an exception. Even
 * the functions that use callback functions won't throw exceptions,
 * because liblzma would break if a callback function threw an exception.
 */
//lzma_nothrow --> nothrow

/********************
 * GNU C extensions *
 ********************/

/*
 * GNU C extensions are used conditionally in the public API. It doesn't
 * break anything if these are sometimes enabled and sometimes not, only
 * affects warnings and optimizations.
 */

//lzma_attr_pure --> pure
//lzma_attr_const --> const
//lzma_attr_warn_unused_result --> n/a


/*.************
 * Subheaders *
 **************/
public import lzma_.version_;
public import lzma_.base;
public import lzma_.vli;
public import lzma_.check;

/* Filters */
public import lzma_.filter;
public import lzma_.bcj;
public import lzma_.delta;
public import lzma_.lzma;

/* Container formats */
public import lzma_.container;

/* Advanced features */
public import lzma_.stream_flags;
public import lzma_.block;
public import lzma_.index;
public import lzma_.index_hash;

/* Hardware information */
public import lzma_.hardware;
