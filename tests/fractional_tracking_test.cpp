#include "knuthpagespacing.h"

#include <cassert>

int main() {
    // Three pixels of contraction distributed over eight gaps stays
    // fractional between separately drawn words and ends at the exact width.
    assert(knuthDistributedTrackingX64(-3, 0, 8) == 0);
    assert(knuthDistributedTrackingX64(-3, 1, 8) == -24);
    assert(knuthDistributedTrackingX64(-3, 3, 8) == -72);
    assert(knuthDistributedTrackingX64(-3, 4, 8) == -96);
    assert(knuthDistributedTrackingX64(-3, 8, 8) == -192);
    assert(knuthDistributedTrackingX64(3, 4, 8) == 96);

    // Layout stores an integer word offset. Drawing restores the omitted
    // fractional part before shaping the next word.
    int layout_offset = -3 * 3 / 8;
    int fractional_remainder = knuthDistributedTrackingX64(-3, 3, 8)
            - layout_offset * 64;
    assert(layout_offset == -1);
    assert(fractional_remainder == -8);

    assert(knuthTrackingMagnitudeCost(0) == 0);
    assert(knuthTrackingMagnitudeCost(-50) == 10000);
    return 0;
}
