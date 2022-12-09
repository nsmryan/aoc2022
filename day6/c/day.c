#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <assert.h>
#include <string.h>

// The file happens to be exactly this long.
#define BUF_SIZE (1024 * 4)

// Somewhat optimzed version of day 6 in C.
// Signifcant points:
//  Uses a map of where characters where last seen to jump over intermediate indices
//  when a duplicate is found.
//
//  Uses a bitmap to track the set of currently seen characters.
//
//  Uses the builtin popcnt in gcc to get the number of characters seen.
int main(int argc, char *argv[]) {
    int numUnique = 4;
    if (argc == 2) {
        numUnique = strtol(argv[1], NULL, 10);
    }

    FILE *file = fopen("input.txt", "r");
    assert(file != NULL);

    uint8_t buffer[BUF_SIZE];
    size_t numChars = fread(buffer, sizeof(uint8_t), BUF_SIZE, file);
    assert(numChars != 0);

    uint16_t offsets[32];
    uint64_t bitmap = 0;

    uint16_t index = 0;
    while (index < numChars) {
        uint8_t chr = buffer[index] - 'a';
        if ((bitmap & (1 << chr)) != 0) {
            // Found a duplicate!
            index = offsets[chr] + 1;

            memset(offsets, 0, sizeof(offsets));

            bitmap = 0;
        } else {
            // Unique
            bitmap |= 1 << chr;
            if (__builtin_popcount(bitmap) == numUnique) {
                printf("Found %d\n", index + 1);
                break;
            }
            offsets[chr] = index;
            index++;
        }
    }
}
