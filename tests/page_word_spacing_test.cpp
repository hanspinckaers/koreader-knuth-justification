#include "knuthpagespacing.h"

#include <cassert>

int main() {
    KnuthPageSpacingAccumulator page;
    page.add(6 * 64, 6);
    page.add(8 * 64, 2);
    assert(page.gapCount() == 8);
    assert(page.targetX64() == (6 * 6 + 8 * 2) * 64 / 8);

    assert(knuthPageSpacingDeviationCost(7 * 64, 7 * 64, 5) == 0);
    assert(knuthPageSpacingDeviationCost(8 * 64, 7 * 64, 5) ==
            5LL * 64 * 64);

    const int target_width = 500;
    const int natural_width = 480;
    assert(knuthOpticalLineAdjustment(target_width, natural_width, 0) == 20);
    assert(knuthOpticalLineAdjustment(target_width, natural_width, 8) == 28);
    return 0;
}
