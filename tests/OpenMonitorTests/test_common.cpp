#include "gtest/gtest.h"
#include <string>
#include <algorithm>
#include <cctype>

// Tests for string and data utilities isolated from MFC.

namespace
{

// Replicate CCommon::StringSplit for testing
std::vector<std::wstring> StringSplit(const std::wstring& str, wchar_t separator)
{
    std::vector<std::wstring> result;
    std::wstring token;
    for (wchar_t ch : str)
    {
        if (ch == separator)
        {
            result.push_back(token);
            token.clear();
        }
        else
        {
            token += ch;
        }
    }
    result.push_back(token);
    return result;
}

std::wstring StringTrim(std::wstring s)
{
    auto not_space = [](wchar_t c) { return !std::iswspace(c); };
    s.erase(s.begin(), std::find_if(s.begin(), s.end(), not_space));
    s.erase(std::find_if(s.rbegin(), s.rend(), not_space).base(), s.end());
    return s;
}

}  // namespace

TEST(StringSplit, EmptyString)
{
    auto parts = StringSplit(L"", L',');
    ASSERT_EQ(parts.size(), 1u);
    EXPECT_EQ(parts[0], L"");
}

TEST(StringSplit, SingleElement)
{
    auto parts = StringSplit(L"hello", L',');
    ASSERT_EQ(parts.size(), 1u);
    EXPECT_EQ(parts[0], L"hello");
}

TEST(StringSplit, MultipleElements)
{
    auto parts = StringSplit(L"a,b,c", L',');
    ASSERT_EQ(parts.size(), 3u);
    EXPECT_EQ(parts[0], L"a");
    EXPECT_EQ(parts[1], L"b");
    EXPECT_EQ(parts[2], L"c");
}

TEST(StringSplit, TrailingSeparator)
{
    auto parts = StringSplit(L"a,b,", L',');
    ASSERT_EQ(parts.size(), 3u);
    EXPECT_EQ(parts[2], L"");
}

TEST(StringTrim, LeadingSpaces)
{
    EXPECT_EQ(StringTrim(L"  hello"), L"hello");
}

TEST(StringTrim, TrailingSpaces)
{
    EXPECT_EQ(StringTrim(L"hello  "), L"hello");
}

TEST(StringTrim, BothSides)
{
    EXPECT_EQ(StringTrim(L"  hello world  "), L"hello world");
}

TEST(StringTrim, AlreadyTrimmed)
{
    EXPECT_EQ(StringTrim(L"hello"), L"hello");
}

TEST(StringTrim, OnlySpaces)
{
    EXPECT_EQ(StringTrim(L"   "), L"");
}
