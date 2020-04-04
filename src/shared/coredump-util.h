/* SPDX-License-Identifier: LGPL-2.1+ */
#pragma once

#include "macro.h"

typedef enum CoredumpFilter {
        COREDUMP_FILTER_PRIVATE_ANONYMOUS = 0,
        COREDUMP_FILTER_SHARED_ANONYMOUS,
        COREDUMP_FILTER_PRIVATE_FILE_BACKED,
        COREDUMP_FILTER_SHARED_FILE_BACKED,
        COREDUMP_FILTER_ELF_HEADERS,
        COREDUMP_FILTER_PRIVATE_HUGE,
        COREDUMP_FILTER_SHARED_HUGE,
        COREDUMP_FILTER_PRIVATE_DAX,
        COREDUMP_FILTER_SHARED_DAX,
        _COREDUMP_FILTER_MAX,
        _COREDUMP_FILTER_INVALID = -1,
} CoredumpFilter;

#define COREDUMP_FILTER_MASK_DEFAULT (1u << COREDUMP_FILTER_PRIVATE_ANONYMOUS | \
                                      1u << COREDUMP_FILTER_SHARED_ANONYMOUS | \
                                      1u << COREDUMP_FILTER_ELF_HEADERS | \
                                      1u << COREDUMP_FILTER_PRIVATE_HUGE)

const char* coredump_filter_to_string(CoredumpFilter i) _const_;
CoredumpFilter coredump_filter_from_string(const char *s) _pure_;
int coredump_filter_mask_from_string(const char *s, uint64_t *ret);
