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

    // Without tracking, integer gap rounding may leave only a bounded edge
    // remainder. With contraction available, equal gaps round upward and the
    // continuous pen absorbs the one-pixel overshoot.
    assert(knuthCommonSpaceTarget(43, 4, 8, 12, false, 0) == 10);
    assert(knuthCommonSpaceTarget(43, 4, 8, 12, false, 1) == 11);

    // Emergency stretch is real stretch, not unrendered optical slack: the
    // target may exceed the normal configured maximum.
    assert(knuthCommonSpaceTarget(61, 4, 8, 12, true, 0) == 15);
    assert(knuthCommonSpaceTarget(61, 4, 8, 12, true, 3) == 16);
    assert(knuthCommonSpaceTarget(49, 4, 8, 12, true, 3) == 13);

    // A normal pass still obeys the configured maximum.
    assert(knuthCommonSpaceTarget(61, 4, 8, 12, false, 20) == 12);

    // Mixed-font rasterisation can produce disjoint nominal gap intervals;
    // preserve the nearest common natural target instead of clamping through
    // an invalid interval.
    assert(knuthCommonSpaceTarget(44, 4, 12, 10, false, 0) == 11);
    return 0;
}
