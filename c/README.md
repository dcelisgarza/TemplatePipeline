# shapes-c

The C version of the `shapes` program. See the [spec](../SPEC.md).

| Part          | Tool                    |
| ------------- | ----------------------- |
| Build         | CMake                   |
| Test          | CTest                   |
| Coverage      | gcc `--coverage`, gcovr |
| Documentation | Doxygen (`docs` target) |
| Package       | CPack (`.tar.gz`)       |

## Use the library

```c
#include <shapes.h>

shape s;
const double dims[] = {3.0, 4.0, 5.0};
if (shape_init(&s, SHAPE_TRIANGLE, dims, 3) == SHAPE_OK) {
    printf("%f\n", shape_area(&s)); /* 6.000000 */
}
```

In CMake, after install: `find_package(shapes)` and link to `shapes::shapes`.

## Pipeline

```bash
./pipeline.sh            # build, test, docs, package, install
./pipeline.sh test       # one stage
```

By hand:

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build
ctest --test-dir build --output-on-failure
cmake --install build --prefix /tmp/template-pipeline/c
```
