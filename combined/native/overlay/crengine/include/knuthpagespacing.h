/** \file knuthpagespacing.h
    \brief Small, testable page-level word-spacing objective helpers.
*/

#ifndef __KNUTH_PAGE_SPACING_H_INCLUDED__
#define __KNUTH_PAGE_SPACING_H_INCLUDED__

class KnuthPageSpacingAccumulator {
    long long _weighted_sum;
    int _gap_count;
public:
    KnuthPageSpacingAccumulator() : _weighted_sum(0), _gap_count(0) {}

    void add(int visible_space_x64, int gaps) {
        if ( visible_space_x64 <= 0 || gaps <= 0 )
            return;
        _weighted_sum += (long long)visible_space_x64 * gaps;
        _gap_count += gaps;
    }

    int targetX64() const {
        if ( _gap_count <= 0 )
            return -1;
        return (int)((_weighted_sum + _gap_count / 2) / _gap_count);
    }

    int gapCount() const { return _gap_count; }
};

inline int knuthOpticalLineAdjustment(int target_width, int natural_width,
                                      int hanging_width) {
    return target_width - (natural_width - hanging_width);
}

inline long long knuthPageSpacingDeviationCost(int visible_space_x64,
                                               int page_target_x64,
                                               int gaps) {
    if ( visible_space_x64 <= 0 || page_target_x64 <= 0 || gaps <= 0 )
        return 0;
    long long deviation = visible_space_x64 - page_target_x64;
    return (long long)gaps * deviation * deviation;
}

// Return the cumulative line-wide tracking offset at a glyph gap in the same
// 26.6 coordinate system used by HarfBuzz and FreeType. Keeping this as one
// accumulator for the complete line avoids restarting integer-pixel tracking
// at every separately drawn word.
inline int knuthDistributedTrackingX64(int total_width, int gap,
                                       int gap_count) {
    if ( gap_count <= 0 || gap <= 0 || total_width == 0 )
        return 0;
    if ( gap >= gap_count )
        return total_width * 64;
    return (int)((long long)total_width * 64 * gap / gap_count);
}

inline long long knuthTrackingMagnitudeCost(int tracking_basis_points) {
    long long magnitude = tracking_basis_points;
    // Tracking remains available as an emergency contraction mechanism, but
    // a break that fits through word spacing alone should normally win.
    return 4 * magnitude * magnitude;
}

#endif
