# shapes-typescript

The TypeScript version of the `shapes` program. See the [spec](../SPEC.md).

| Part          | Tool                                  |
| ------------- | ------------------------------------- |
| Build         | npm, `tsc` (ESM, output in `dist/`)   |
| Test          | `node:test` (the built-in runner)     |
| Documentation | TypeDoc                               |
| Package       | `npm pack` (`.tgz`)                   |

The version lives in `package.json`. The command-line program reads it from there.

## Use the library

```ts
import { createShape } from "shapes-typescript";

const t = createShape("triangle", [3, 4, 5]);
console.log(t.area()); // 6
```

`createShape` throws a `ShapeError` for bad input. Its subclasses are `UnknownShapeError`,
`DimensionCountError`, `InvalidDimensionError` and `NotTriangleError`.

## Pipeline

```bash
./pipeline.sh            # build, test, docs, package, install
./pipeline.sh test       # one stage
```

The install stage uses `npm install --global --prefix "$PREFIX/typescript"`.
It does not touch your home directory.

By hand:

```bash
npm ci
npm run build
npm test
npm run docs
npm pack
npm install --global --prefix /tmp/template-pipeline/typescript ./shapes-typescript-0.1.0.tgz
```
