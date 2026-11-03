# shapes-rust

The Rust version of the `shapes` program. See the [spec](../SPEC.md).

| Part          | Tool                                      |
| ------------- | ----------------------------------------- |
| Build         | Cargo (`cargo build --release`)           |
| Test          | `cargo test`, rustfmt, Clippy             |
| Coverage      | cargo-llvm-cov |
| Documentation | rustdoc (`cargo doc`)                     |
| Package       | `.tar.gz` of the binary and a `.crate`    |

## Use the library

```rust
use shapes::{from_name, Shape, Triangle};

let t = Triangle::new(3.0, 4.0, 5.0)?;
println!("{:.6}", t.area()); // 6.000000

let s = from_name("square", &[3.0])?;
println!("{:.6}", s.perimeter()); // 12.000000
```

Bad input gives a `ShapeError`. It implements `Display` and `std::error::Error`.

## Pipeline

```bash
./pipeline.sh            # build, test, docs, package, install
./pipeline.sh test       # one stage
```

By hand:

```bash
cargo build --release --locked
cargo test
cargo doc --no-deps
cargo install --path . --root /tmp/template-pipeline/rust --locked
```
