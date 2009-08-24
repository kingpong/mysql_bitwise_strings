/*
 * str_not.c
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

#include "bitwise.h"

/* These must be right or mysqld will not find the symbol! */

my_bool str_not_init(UDF_INIT *initid, UDF_ARGS *args, char *message);
void    str_not_deinit(UDF_INIT *initid);
char   *str_not(UDF_INIT *initid, UDF_ARGS *args, char *result,
                unsigned long *length, char *is_null, char *error);

/*************************************************************************
** Example of init function
** Arguments:
**
**  initid  Points to a structure that the init function should fill.
**          This argument is given to all other functions.
**
**      my_bool maybe_null
**          1 if function can return NULL
**          Default value is 1 if any of the arguments
**          is declared maybe_null.
**
**      unsigned int decimals
**          Number of decimals.
**          Default value is max decimals in any of the arguments.
**
**      unsigned int max_length
**          Length of string result.
**          The default value for integer functions is 21
**          The default value for real functions is 13+
**          default number of decimals.
**          The default value for string functions is
**          the longest string argument.
**
**      char *ptr
**          A pointer that the function can use.
**
**  args    Points to a structure which contains:
**
**      unsigned int arg_count
**          Number of arguments
**
**      enum Item_result *arg_type
**          Types for each argument.
**          Types are STRING_RESULT, REAL_RESULT and INT_RESULT.
**
**      char **args
**          Pointer to constant arguments.
**          Contains 0 for not constant argument.
**
**      unsigned long *lengths
**          max string length for each argument
**
**      char *maybe_null
**          Information of which arguments may be NULL
**
**  message Error message that should be passed to the user on fail.
**      The message buffer is MYSQL_ERRMSG_SIZE big, but one should
**      try to keep the error message less than 80 bytes long!
**
** This function should return 1 if something goes wrong. In this case
** message should contain something useful!
**
**************************************************************************/

my_bool str_not_init(UDF_INIT *initid, UDF_ARGS *args, char *message)
{
    if (args->arg_count < 1) {
        sprintf(message, "STR_NOT() accepts exactly 1 argument (got %d)",
                args->arg_count);
        return 1;
    }
    if (args->arg_type[0] != STRING_RESULT) {
        sprintf(message, "All arguments to STR_NOT() must be "
                "strings. Argument %d isn't.", 0);
        return 1;
    }
    initid->max_length = string_bitwise_not_result_len(args->lengths[0]);

    if (initid->max_length <= 255) {
        initid->ptr = 0;
    }
    else {
        initid->ptr = malloc(initid->max_length);
        if (!initid->ptr) {
            strcpy(message, "out of memory");
            return 1;
        }
    }

    return 0;
}

/****************************************************************************
** Deinit function.
** This should free all resources allocated by this function.
**
** Arguments:
** initid    Return value from xxxx_init
****************************************************************************/

void str_not_deinit(UDF_INIT *initid __attribute__((unused)))
{
    if (initid->ptr)
        free(initid->ptr);
}

/***************************************************************************
** UDF string function.
**
** Arguments:
** initid   Structure filled by xxx_init
** args     The same structure as to xxx_init. This structure
**          contains values for all parameters.
**          Note that the functions MUST check and convert all
**          to the type it wants!  Null values are represented by
**          a NULL pointer
**
** result   Possible buffer to save result. At least 255 byte long.
** length   Pointer to length of the above buffer.
**          The function should save the result length in here.
**
** is_null  If the result is null, one should store 1 here.
** error    If something goes fatally wrong one should store 1 here.
**
** This function should return a pointer to the result string.
** Normally this is 'result' but may also be an alloced string.
***************************************************************************/

char *str_not(UDF_INIT *initid __attribute__((unused)),
              UDF_ARGS *args, char *result, unsigned long *length,
              char *is_null, char *error __attribute__((unused)))
{
    char *actual_res;
    size_t len;

    if (args->args[0] == (char *)0) {
        *is_null = 1;
        return 0;
    }

    len = string_bitwise_not_result_len(args->lengths[0]);
    actual_res = initid->ptr ? initid->ptr : result;
    *length = len;

    string_bitwise_not(args->args[0], len, actual_res);

    return actual_res;
}
