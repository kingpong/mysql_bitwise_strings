/*
 * bitwise.c
 *
 * Copyright (c) 2009 Philip Garrett.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#include <sys/types.h>
#include "bitwise.h"

void string_bitwise_or(const char *left, size_t llen,
                       const char *right, size_t rlen,
                       char *dest)
{
    const char *s = llen < rlen ? left : right;   /* smaller */
    const char *b = llen < rlen ? right : left;   /* bigger  */
    size_t len = MIN(llen,rlen);
    size_t ext = MAX(llen,rlen) - len;
    while (len--)
        *(dest++) = *(s++) | *(b++);
    while (ext--)
        *(dest++) = *(b++);
}

void string_bitwise_xor(const char *left, size_t llen,
                        const char *right, size_t rlen,
                        char *dest)
{
    const char *s = llen < rlen ? left : right;   /* smaller */
    const char *b = llen < rlen ? right : left;   /* bigger  */
    size_t len = MIN(llen,rlen);
    size_t ext = MAX(llen,rlen) - len;
    while (len--)
        *(dest++) = *(s++) ^ *(b++);
    while (ext--)
        *(dest++) = *(b++);
}

void string_bitwise_and(const char *l, size_t llen,
                        const char *r, size_t rlen,
                        char *dest)
{
    size_t len = MIN(llen,rlen);
    while (len--)
        *(dest++) = *(l++) & *(r++);
}

void string_bitwise_not(const char *s, size_t slen,
                        char *dest)
{
    while (slen--)
        *(dest++) = ~(*s++);
}
