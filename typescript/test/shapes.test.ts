import { test } from "node:test";
import assert from "node:assert/strict";
import {
  DimensionCountError,
  InvalidDimensionError,
  NotTriangleError,
  UnknownShapeError,
  createShape,
} from "../dist/index.js";

const close = (actual: number, expected: number) =>
  assert.ok(Math.abs(actual - expected) < 1e-9, `${actual} is not ${expected}`);

test("circle", () => {
  const s = createShape("circle", [2]);
  close(s.area(), 4 * Math.PI);
  close(s.perimeter(), 4 * Math.PI);
});

test("rectangle", () => {
  const s = createShape("rectangle", [2, 3]);
  close(s.area(), 6);
  close(s.perimeter(), 10);
});

test("square", () => {
  const s = createShape("square", [3]);
  close(s.area(), 9);
  close(s.perimeter(), 12);
});

test("triangle", () => {
  const s = createShape("triangle", [3, 4, 5]);
  close(s.area(), 6);
  close(s.perimeter(), 12);
});

test("non-positive, infinite and NaN dimensions are rejected", () => {
  for (const bad of [0, -1, Infinity, -Infinity, NaN]) {
    assert.throws(() => createShape("square", [bad]), InvalidDimensionError);
    assert.throws(() => createShape("rectangle", [1, bad]), InvalidDimensionError);
  }
});

test("triangle inequality is strict", () => {
  assert.throws(() => createShape("triangle", [1, 1, 5]), NotTriangleError);
  assert.throws(() => createShape("triangle", [1, 2, 3]), NotTriangleError);
  assert.throws(() => createShape("triangle", [5, 1, 1]), NotTriangleError);
});

test("unknown shape", () => {
  assert.throws(() => createShape("hexagon", [1]), {
    name: "UnknownShapeError",
    message: "unknown shape 'hexagon'",
  });
  assert.throws(() => createShape("hexagon", [1]), UnknownShapeError);
});

test("wrong number of dimensions", () => {
  assert.throws(() => createShape("rectangle", [1]), {
    message: "rectangle needs 2 dimension(s): width height",
  });
  assert.throws(() => createShape("circle", []), DimensionCountError);
});
