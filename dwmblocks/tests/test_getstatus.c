#include <assert.h>
#include <string.h>

#define main dwmblocks_main
#include "../dwmblocks.c"
#undef main

int main(void) {
    char str[STATUSLENGTH];
    char last[STATUSLENGTH];

    /* initialize sample statusbar outputs with trailing delimiter */
    strcpy(statusbar[0], "one | ");
    strcpy(statusbar[1], "two | ");
    for (unsigned int i = 2; i < LENGTH(blocks); i++) {
        statusbar[i][0] = '\0';
    }

    /* first call should detect change and strip trailing delimiter */
    str[0] = '\0';
    int changed = getstatus(str, last);
    assert(changed != 0);
    assert(strcmp(str, "one | two") == 0);
    size_t len = strlen(str);
    assert(strncmp(str + len - strlen(delim), delim, strlen(delim)) != 0);

    /* second call with no changes should return 0 */
    changed = getstatus(str, last);
    assert(changed == 0);

    /* modify statusbar to trigger change */
    strcpy(statusbar[1], "three | ");
    changed = getstatus(str, last);
    assert(changed != 0);
    assert(strcmp(str, "one | three") == 0);
    len = strlen(str);
    assert(strncmp(str + len - strlen(delim), delim, strlen(delim)) != 0);

    return 0;
}
