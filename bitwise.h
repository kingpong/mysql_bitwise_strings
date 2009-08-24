/*
 * bitwise.h
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

#ifndef BITWISE_H
#define BITWISE_H

#ifdef STANDARD
    /* STANDARD is defined, don't use any mysql functions */
#   include <stdlib.h>
#   include <stdio.h>
#   include <string.h>
#   ifdef __WIN__
        typedef unsigned __int64 ulonglong;    /* Microsofts 64 bit types */
        typedef __int64 longlong;
#   else
        typedef unsigned long long ulonglong;
        typedef long long longlong;
#   endif /*__WIN__*/
#else
#   include <my_global.h>
#   include <my_sys.h>
#   if defined(MYSQL_SERVER)
#       include <m_string.h>        /* To get strmov() */
#   else
        /* when compiled as standalone */
#       include <string.h>
#       define strmov(a,b) stpcpy(a,b)
#       define bzero(a,b) memset(a,0,b)
#       define memcpy_fixed(a,b,c) memcpy(a,b,c)
#   endif
#endif
#include <mysql.h>
#include <ctype.h>
#include <sys/types.h>

#ifndef MAX
# define MAX(i,j) (i > j ? i : j)
#endif
#ifndef MIN
# define MIN(i,j) (i < j ? i : j)
#endif

#define string_bitwise_or_result_len(i,j)  (MAX(i,j))
#define string_bitwise_xor_result_len(i,j) (MAX(i,j))
#define string_bitwise_and_result_len(i,j) (MIN(i,j))
#define string_bitwise_not_result_len(i)   (i)

void string_bitwise_or(const char *l, size_t llen, const char *r, size_t rlen, char *dest);
void string_bitwise_xor(const char *l, size_t llen, const char *r, size_t rlen, char *dest);
void string_bitwise_and(const char *l, size_t llen, const char *r, size_t rlen, char *dest);
void string_bitwise_not(const char *s, size_t slen, char *dest);

#endif /* BITWISE_H */

