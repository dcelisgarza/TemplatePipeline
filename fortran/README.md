# shapes-fortran

The Fortran version of the `shapes` program. See the [spec](../SPEC.md).

| Part          | Tool                                  |
| ------------- | ------------------------------------- |
| Build         | fpm (Fortran Package Manager)         |
| Test          | test-drive (`fpm test`)               |
| Coverage      | gfortran `--coverage`, gcovr |
| Documentation | FORD (`uvx ford`, project `ford.md`)  |
| Package       | `fpm install` into a folder, then tar |

## Use the library

```fortran
use shapes
class(shape_t), allocatable :: s
integer :: stat

call make_shape("triangle", [3.0_dp, 4.0_dp, 5.0_dp], s, stat)
if (stat == SHAPE_OK) print *, s%area()   ! 6.0
```

`make_shape` sets `stat` to a code such as `SHAPE_ERR_NOT_POSITIVE`.
`shape_message(stat)` gives the text for a code.

In fpm, add the project to the `[dependencies]` of your `fpm.toml`.

## Pipeline

```bash
./pipeline.sh            # build, test, docs, package, install
./pipeline.sh test       # one stage
```

The program needs `gfortran` and `fpm`. The docs stage needs `uv`.
The test stage needs network access once. fpm fetches test-drive.

By hand:

```bash
fpm build --profile release
fpm test --profile release
uvx ford ford.md
fpm install --profile release --prefix /tmp/template-pipeline/fortran
```
