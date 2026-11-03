---
project: shapes-fortran
version: 0.1.0
summary: Area and perimeter of plane shapes
src_dir: ./src
output_dir: ./build/ford
display: public
         protected
source: true
graph: false
search: false
author: TemplatePipeline
---

The Fortran version of the `shapes` program.

The module [[shapes]] has the abstract type [[shape_t]] and four shapes that
extend it. Call [[make_shape]] to make a shape from its name and dimensions.
