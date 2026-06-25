# OpenMonitor Tests

Unit tests for non-UI logic in OpenMonitor, using [Google Test](https://github.com/google/googletest).

## Structure

```
tests/
  OpenMonitorTests/
    OpenMonitorTests.vcxproj    Visual Studio test project
    test_main.cpp               Google Test entry point
    test_common.cpp             Tests for CCommon utilities
    test_display_item.cpp       Tests for display formatting
    test_network_adapter.cpp    Tests for adapter selection logic
    test_skin_file.cpp          Tests for skin XML/INI parsing
```

## Building

```powershell
$vs = 'C:\Program Files\Microsoft Visual Studio\18\Community\MSBuild\Current\Bin\MSBuild.exe'
& $vs tests\OpenMonitorTests\OpenMonitorTests.vcxproj /p:Configuration=Release /p:Platform=x64 /m
```

## Running

```powershell
.\tests\OpenMonitorTests\bin\x64\Release\OpenMonitorTests.exe
# With filter:
.\tests\OpenMonitorTests\bin\x64\Release\OpenMonitorTests.exe --gtest_filter=DisplayItem*
# With XML output:
.\tests\OpenMonitorTests\bin\x64\Release\OpenMonitorTests.exe --gtest_output=xml:test_results.xml
```

## Adding Tests

1. Create a new `.cpp` file in `tests/OpenMonitorTests/`
2. Add it to `OpenMonitorTests.vcxproj`
3. Write tests using Google Test macros:

```cpp
#include "gtest/gtest.h"

TEST(SuiteName, TestName)
{
    EXPECT_EQ(expected, actual);
    ASSERT_TRUE(condition);
}
```

## Google Test Setup

Google Test is fetched via vcpkg or NuGet. The test project references it via:
- `$(SolutionDir)packages\Microsoft.googletest.v140.windesktop.msvcstl.dyn.rt-dyn.1.8.1.7\`
- Or install via: `vcpkg install gtest:x64-windows`

## CI Integration

Tests run automatically on every PR via `.github/workflows/test.yml`.
