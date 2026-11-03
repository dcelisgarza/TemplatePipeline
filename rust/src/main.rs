//! The `shapes-rust` command-line program.

use std::io::{self, BufRead, Write};
use std::process::ExitCode;

use shapes::{dimension_names, from_name, SHAPE_NAMES};

const NAME: &str = "shapes-rust";
const VERSION: &str = env!("CARGO_PKG_VERSION");

fn help() -> String {
    format!(
        "Usage: {NAME} [SHAPE DIMENSION...]

Print the area and perimeter of a plane shape.

Shapes and their dimensions:
  circle     RADIUS
  rectangle  WIDTH HEIGHT
  square     SIDE
  triangle   A B C

Without arguments, {NAME} asks for the shape and its dimensions.

Options:
  -h, --help     Print this help and exit.
  -V, --version  Print the version and exit.
"
    )
}

fn parse_number(s: &str) -> Result<f64, String> {
    s.trim()
        .parse::<f64>()
        .map_err(|_| format!("'{s}' is not a number"))
}

/// Compute the output line for a shape name and dimension texts.
fn compute(name: &str, args: &[String]) -> Result<String, String> {
    // Check the name and the count before the numbers, as the spec orders it.
    let names = dimension_names(name).ok_or_else(|| format!("unknown shape '{name}'"))?;
    if args.len() != names.len() {
        return Err(format!(
            "{name} needs {} dimension(s): {}",
            names.len(),
            names.join(" ")
        ));
    }
    let dims = args
        .iter()
        .map(|a| parse_number(a))
        .collect::<Result<Vec<_>, _>>()?;
    let shape = from_name(name, &dims).map_err(|e| e.to_string())?;
    Ok(format!(
        "{name}: area = {:.6}, perimeter = {:.6}",
        shape.area(),
        shape.perimeter()
    ))
}

fn interactive() -> ExitCode {
    let stdin = io::stdin();
    let mut input = stdin.lock();
    let mut out = io::stdout();
    loop {
        let prompt = format!("shape ({}; q to quit): ", SHAPE_NAMES.join(", "));
        let name = match ask(&mut input, &mut out, &prompt) {
            Some(s) => s,
            None => return ExitCode::SUCCESS,
        };
        if name.is_empty() {
            continue;
        }
        if name == "q" || name == "quit" {
            return ExitCode::SUCCESS;
        }
        let Some(names) = dimension_names(&name) else {
            eprintln!("error: unknown shape '{name}'");
            continue;
        };
        let mut dims = Vec::new();
        for d in names {
            match ask(&mut input, &mut out, &format!("  {d}: ")) {
                Some(s) => dims.push(s),
                None => return ExitCode::SUCCESS,
            }
        }
        match compute(&name, &dims) {
            Ok(line) => println!("{line}"),
            Err(e) => eprintln!("error: {e}"),
        }
    }
}

/// Print a prompt and read one trimmed line. Returns `None` at end of input.
fn ask(input: &mut impl BufRead, out: &mut impl Write, prompt: &str) -> Option<String> {
    let _ = write!(out, "{prompt}");
    let _ = out.flush();
    let mut line = String::new();
    match input.read_line(&mut line) {
        Ok(0) | Err(_) => None,
        Ok(_) => Some(line.trim().to_string()),
    }
}

fn main() -> ExitCode {
    let args: Vec<String> = std::env::args().skip(1).collect();
    match args.first().map(String::as_str) {
        None => interactive(),
        Some("-h" | "--help") => {
            print!("{}", help());
            ExitCode::SUCCESS
        }
        Some("-V" | "--version") => {
            println!("{NAME} {VERSION}");
            ExitCode::SUCCESS
        }
        Some(name) => match compute(name, &args[1..]) {
            Ok(line) => {
                println!("{line}");
                ExitCode::SUCCESS
            }
            Err(e) => {
                eprintln!("error: {e}");
                ExitCode::FAILURE
            }
        },
    }
}
