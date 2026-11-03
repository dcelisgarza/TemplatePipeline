# shapes-cpp

The C++ version of the `shapes` program. See the [spec](../SPEC.md).

| Part          | Tool                           |
| ------------- | ------------------------------ |
| Build         | CMake (C++17)                  |
| Test          | GoogleTest, CTest              |
| Documentation | Doxygen (`docs` target)        |
| Package       | CPack (`.tar.gz`)              |

## Use the library

```cpp
#include <shapes/shapes.hpp>

shapes::Triangle t(3.0, 4.0, 5.0);
std::cout << t.area() << '\n';  // 6

auto s = shapes::make_shape("rectangle", {2.0, 3.0});  // std::unique_ptr<shapes::Shape>
std::cout << s->perimeter() << '\n';  // 10
```

Bad input throws `std::invalid_argument`. An unknown name throws
`shapes::UnknownShapeError`, which is a kind of `std::invalid_argument`.

In CMake, after install: `find_package(shapes)` and link to `shapes::shapes`.

## Pipeline

```bash
./pipeline.sh            # build, test, docs, package, install
./pipeline.sh test       # one stage
```

The test stage needs network access once. CMake fetches GoogleTest.

By hand:

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build
ctest --test-dir build --output-on-failure
cmake --install build --prefix /tmp/template-pipeline/cpp
```
