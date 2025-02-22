/* SPDX-License-Identifier: LGPL-2.1-or-later */
#pragma once

#include <stdio.h>

int fopen_temporary(const char *path, FILE **_f, char **_temp_path);
int mkostemp_safe(char *pattern);
int fmkostemp_safe(char *pattern, const char *mode, FILE**_f);

int tempfn_xxxxxx(const char *p, const char *extra, char **ret);
#if 0 /// UNNEEDED by elogind
int tempfn_random(const char *p, const char *extra, char **ret);
int tempfn_random_child(const char *p, const char *extra, char **ret);
#endif // 0

int open_tmpfile_unlinkable(const char *directory, int flags);
#if 0 /// UNNEEDED by elogind
int open_tmpfile_linkable(const char *target, int flags, char **ret_path);

int link_tmpfile(int fd, const char *path, const char *target);
#endif // 0

int mkdtemp_malloc(const char *template, char **ret);
