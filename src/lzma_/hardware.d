/**
 * Hardware information
 *
 * Since liblzma can consume a lot of system resources, it also provides
 * ways to limit the resource usage. Applications linking against liblzma
 * need to do the actual decisions how much resources to let liblzma to use.
 * To ease making these decisions, liblzma provides functions to find out
 * the relevant capabilities of the underlaying hardware. Currently there
 * is only a function to find out the amount of RAM, but in the future there
 * will be also a function to detect how many concurrent threads the system
 * can run.
 *
 * Note:        On some operating systems, these function may temporarily
 *              load a shared library or open file descriptor(s) to find out
 *              the requested hardware information. Unless the application
 *              assumes that specific file descriptors are not touched by
 *              other threads, this should have no effect on thread safety.
 *              Possible operations involving file descriptors will restart
 *              the syscalls if they return EINTR.
  *
 * Source: $(BASESRC lzma_/hardware.d)
 * Author: Lasse Collin (original liblzma author),
 *         Johannes Pfau (D bindings)
 * License: public domain
 */
/*
 * This file has been put into the public domain.
 * You can do whatever you want with this file.
 */

module lzma_.hardware;
import lzma;

extern(C):

/**
 * Get the total amount of physical memory (RAM) in bytes
 *
 * This function may be useful when determining a reasonable memory
 * usage limit for decompressing or how much memory it is OK to use
 * for compressing.
 *
 * Returns:      On success, the total amount of physical memory in bytes
 *              is returned. If the amount of RAM cannot be determined,
 *              zero is returned. This can happen if an error occurs
 *              or if there is no code in liblzma to detect the amount
 *              of RAM on the specific operating system.
 */
nothrow ulong lzma_physmem();
