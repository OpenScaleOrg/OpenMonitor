#include "gtest/gtest.h"
#include <string>
#include <windows.h>

// Tests for display formatting logic isolated from MFC/UI dependencies.
// These test the pure logic of unit formatting, not the full DisplayItem class
// (which requires MFC initialization).

namespace
{

// Replicate the unit formatting logic from CommonData/DisplayItem for testing
std::wstring FormatSpeed(long long bytesPerSec, bool useBytes)
{
    constexpr long long KB = 1024LL;
    constexpr long long MB = 1024LL * KB;
    constexpr long long GB = 1024LL * MB;

    if (!useBytes)
    {
        bytesPerSec *= 8;  // convert to bits
        if (bytesPerSec >= GB)
            return std::to_wstring(bytesPerSec / GB) + L" Gbps";
        if (bytesPerSec >= MB)
            return std::to_wstring(bytesPerSec / MB) + L" Mbps";
        if (bytesPerSec >= KB)
            return std::to_wstring(bytesPerSec / KB) + L" Kbps";
        return std::to_wstring(bytesPerSec) + L" bps";
    }

    if (bytesPerSec >= GB)
        return std::to_wstring(bytesPerSec / GB) + L" GB/s";
    if (bytesPerSec >= MB)
        return std::to_wstring(bytesPerSec / MB) + L" MB/s";
    if (bytesPerSec >= KB)
        return std::to_wstring(bytesPerSec / KB) + L" KB/s";
    return std::to_wstring(bytesPerSec) + L" B/s";
}

}  // namespace

TEST(FormatSpeed, ZeroBytesPerSec)
{
    EXPECT_EQ(FormatSpeed(0, true), L"0 B/s");
}

TEST(FormatSpeed, Kilobytes)
{
    EXPECT_EQ(FormatSpeed(1024, true), L"1 KB/s");
    EXPECT_EQ(FormatSpeed(2048, true), L"2 KB/s");
}

TEST(FormatSpeed, Megabytes)
{
    EXPECT_EQ(FormatSpeed(1024 * 1024, true), L"1 MB/s");
}

TEST(FormatSpeed, Gigabytes)
{
    EXPECT_EQ(FormatSpeed(1024LL * 1024 * 1024, true), L"1 GB/s");
}

TEST(FormatSpeed, BitMode_Megabits)
{
    // 125000 bytes/s * 8 = 1000000 bits = ~976 Kbps
    EXPECT_EQ(FormatSpeed(125LL * 1024, false), L"1 Mbps");
}
