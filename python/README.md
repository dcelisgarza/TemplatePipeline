# shapes-python

The Python version of the `shapes` program. See the [spec](../SPEC.md).

| Part          | Tool                                    |
| ------------- | --------------------------------------- |
| Project       | uv (`pyproject.toml`, `uv.lock`)        |
| Build         | `uv build` with the `uv_build` backend  |
| Test          | pytest, ruff                            |
| Documentation | Sphinx with autodoc                     |
| Package       | wheel and sdist                         |
| Install       | `uv tool install`                       |

## Use the library

```python
from shapes import Triangle, make_shape

print(Triangle(3, 4, 5).area())  # 6.0
print(make_shape("square", [2]).perimeter())  # 8.0
```

## Pipeline

```bash
./pipeline.sh            # build, test, docs, package, install
./pipeline.sh test       # one stage
```

By hand:

```bash
uv sync                          # make .venv with the dev tools
uv run pytest                    # tests
uv run shapes-python circle 2    # run the program from the source tree
uv run --group docs sphinx-build docs docs/_build/html
uv build                         # wheel and sdist in dist/
```
