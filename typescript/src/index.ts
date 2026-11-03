/**
 * The shapes library: four plane shapes with area and perimeter.
 *
 * @example
 * ```ts
 * import { createShape } from "shapes-typescript";
 *
 * const t = createShape("triangle", [3, 4, 5]);
 * t.area(); // 6
 * ```
 *
 * @packageDocumentation
 */

/** A plane shape. */
export interface Shape {
  /** The name of the shape, for example `"circle"`. */
  readonly name: ShapeName;
  /** The area of the shape. */
  area(): number;
  /** The perimeter of the shape. */
  perimeter(): number;
}

/** The names of the shapes that the library knows. */
export const SHAPE_NAMES = ["circle", "rectangle", "square", "triangle"] as const;

/** The name of one shape. */
export type ShapeName = (typeof SHAPE_NAMES)[number];

/** The names of the dimensions of each shape, in order. */
export const DIMENSION_NAMES: Readonly<Record<ShapeName, readonly string[]>> = {
  circle: ["radius"],
  rectangle: ["width", "height"],
  square: ["side"],
  triangle: ["a", "b", "c"],
};

/** The base class of all errors that the library throws. */
export class ShapeError extends Error {
  constructor(message: string) {
    super(message);
    this.name = new.target.name;
  }
}

/** The shape name is not known. */
export class UnknownShapeError extends ShapeError {
  constructor(readonly shape: string) {
    super(`unknown shape '${shape}'`);
  }
}

/** The shape got the wrong number of dimensions. */
export class DimensionCountError extends ShapeError {
  constructor(shape: ShapeName) {
    super(
      `${shape} needs ${DIMENSION_NAMES[shape].length} dimension(s): ${DIMENSION_NAMES[shape].join(" ")}`,
    );
  }
}

/** A dimension is not a finite number above zero. */
export class InvalidDimensionError extends ShapeError {
  constructor() {
    super("dimensions must be positive numbers");
  }
}

/** The three sides do not obey the strict triangle inequality. */
export class NotTriangleError extends ShapeError {
  constructor() {
    super("sides do not form a triangle");
  }
}

/** A circle with a radius. */
export class Circle implements Shape {
  readonly name = "circle";
  constructor(readonly radius: number) {}
  area(): number {
    return Math.PI * this.radius * this.radius;
  }
  perimeter(): number {
    return 2 * Math.PI * this.radius;
  }
}

/** A rectangle with a width and a height. */
export class Rectangle implements Shape {
  readonly name = "rectangle";
  constructor(
    readonly width: number,
    readonly height: number,
  ) {}
  area(): number {
    return this.width * this.height;
  }
  perimeter(): number {
    return 2 * (this.width + this.height);
  }
}

/** A square with a side. */
export class Square implements Shape {
  readonly name = "square";
  constructor(readonly side: number) {}
  area(): number {
    return this.side * this.side;
  }
  perimeter(): number {
    return 4 * this.side;
  }
}

/** A triangle with three sides. */
export class Triangle implements Shape {
  readonly name = "triangle";
  constructor(
    readonly a: number,
    readonly b: number,
    readonly c: number,
  ) {}
  area(): number {
    const p = (this.a + this.b + this.c) / 2;
    return Math.sqrt(p * (p - this.a) * (p - this.b) * (p - this.c));
  }
  perimeter(): number {
    return this.a + this.b + this.c;
  }
}

/** Tells if `name` is the name of a known shape. */
export function isShapeName(name: string): name is ShapeName {
  return (SHAPE_NAMES as readonly string[]).includes(name);
}

/**
 * Makes a shape from its name and its dimensions.
 *
 * @param name - One of {@link SHAPE_NAMES}.
 * @param dims - The dimensions, in the order of {@link DIMENSION_NAMES}.
 * @throws {@link UnknownShapeError} if the name is not known.
 * @throws {@link DimensionCountError} if the count of dimensions is wrong.
 * @throws {@link InvalidDimensionError} if a dimension is not finite and above zero.
 * @throws {@link NotTriangleError} if the sides of a triangle are not valid.
 */
export function createShape(name: string, dims: readonly number[]): Shape {
  if (!isShapeName(name)) {
    throw new UnknownShapeError(name);
  }
  if (dims.length !== DIMENSION_NAMES[name].length) {
    throw new DimensionCountError(name);
  }
  if (!dims.every((d) => Number.isFinite(d) && d > 0)) {
    throw new InvalidDimensionError();
  }
  const [a = 0, b = 0, c = 0] = dims;
  switch (name) {
    case "circle":
      return new Circle(a);
    case "rectangle":
      return new Rectangle(a, b);
    case "square":
      return new Square(a);
    case "triangle":
      if (a + b <= c || a + c <= b || b + c <= a) {
        throw new NotTriangleError();
      }
      return new Triangle(a, b, c);
  }
}
