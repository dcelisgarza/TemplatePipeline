#!/usr/bin/env node
/** The command-line program shapes-typescript. See SPEC.md. */
import { createInterface } from "node:readline";
import { pathToFileURL } from "node:url";
import { readFileSync, realpathSync } from "node:fs";
import {
  DIMENSION_NAMES,
  DimensionCountError,
  ShapeError,
  UnknownShapeError,
  createShape,
  isShapeName,
  type Shape,
} from "./index.js";

// The version lives in package.json only.
const VERSION: string = JSON.parse(
  readFileSync(new URL("../package.json", import.meta.url), "utf8"),
).version;

const USAGE = `Usage: shapes-typescript [SHAPE DIMENSION...]

Print the area and perimeter of a plane shape.

Shapes and their dimensions:
  circle     RADIUS
  rectangle  WIDTH HEIGHT
  square     SIDE
  triangle   A B C

Without arguments, shapes-typescript asks for the shape and its dimensions.

Options:
  -h, --help     Print this help and exit.
  -V, --version  Print the version and exit.
`;

const SHAPE_PROMPT = "shape (circle, rectangle, square, triangle; q to quit): ";

/** Parses a number like C strtod does. Returns undefined if the text is not a number. */
export function parseNumber(text: string): number | undefined {
  const t = text.trim();
  if (/^[+-]?(inf|infinity)$/i.test(t)) {
    return t.startsWith("-") ? -Infinity : Infinity;
  }
  if (/^[+-]?nan$/i.test(t)) {
    return NaN;
  }
  if (!/^[+-]?(\d+\.?\d*|\.\d+)([eE][+-]?\d+)?$/.test(t)) {
    return undefined;
  }
  return Number(t);
}

/** Makes a shape from text. Throws a ShapeError with the message to print. */
export function makeShape(name: string, args: readonly string[]): Shape {
  if (!isShapeName(name)) {
    throw new UnknownShapeError(name);
  }
  if (args.length !== DIMENSION_NAMES[name].length) {
    throw new DimensionCountError(name);
  }
  const dims = args.map((arg) => {
    const value = parseNumber(arg);
    if (value === undefined) {
      throw new ShapeError(`'${arg}' is not a number`);
    }
    return value;
  });
  return createShape(name, dims);
}

function describe(s: Shape): string {
  return `${s.name}: area = ${s.area().toFixed(6)}, perimeter = ${s.perimeter().toFixed(6)}\n`;
}

function report(e: unknown): void {
  if (e instanceof ShapeError) {
    process.stderr.write(`error: ${e.message}\n`);
  } else {
    throw e;
  }
}

async function interactive(): Promise<number> {
  const rl = createInterface({ input: process.stdin, crlfDelay: Infinity });
  const lines = rl[Symbol.asyncIterator]();
  const ask = async (prompt: string): Promise<string | undefined> => {
    process.stdout.write(prompt);
    const next = await lines.next();
    return next.done ? undefined : next.value.trim();
  };
  try {
    for (;;) {
      const name = await ask(SHAPE_PROMPT);
      if (name === undefined) {
        process.stdout.write("\n");
        return 0;
      }
      if (name === "") continue;
      if (name === "q" || name === "quit") return 0;
      if (!isShapeName(name)) {
        report(new UnknownShapeError(name));
        continue;
      }
      const answers: string[] = [];
      for (const dim of DIMENSION_NAMES[name]) {
        const answer = await ask(`  ${dim}: `);
        if (answer === undefined) {
          process.stdout.write("\n");
          return 0;
        }
        answers.push(answer);
      }
      try {
        process.stdout.write(describe(makeShape(name, answers)));
      } catch (e) {
        report(e);
      }
    }
  } finally {
    rl.close();
  }
}

/** Runs the program and returns the exit status. */
export async function main(argv: readonly string[]): Promise<number> {
  const [first, ...rest] = argv;
  if (first === undefined) return interactive();
  if (first === "-h" || first === "--help") {
    process.stdout.write(USAGE);
    return 0;
  }
  if (first === "-V" || first === "--version") {
    process.stdout.write(`shapes-typescript ${VERSION}\n`);
    return 0;
  }
  try {
    process.stdout.write(describe(makeShape(first, rest)));
    return 0;
  } catch (e) {
    report(e);
    return 1;
  }
}

// Run only when started as a program, also through a symbolic link.
const entry = process.argv[1];
if (entry !== undefined && import.meta.url === pathToFileURL(realpathSync(entry)).href) {
  process.exitCode = await main(process.argv.slice(2));
}
