//! Plane shapes with area and perimeter.
//!
//! Build a shape with a constructor or with [`from_name`]. Each constructor
//! checks its dimensions and returns a [`ShapeError`] when they are bad.
//!
//! ```
//! use shapes::{Shape, Triangle};
//!
//! let t = Triangle::new(3.0, 4.0, 5.0).unwrap();
//! assert!((t.area() - 6.0).abs() < 1e-12);
//! assert_eq!(t.perimeter(), 12.0);
//! ```

use std::error::Error;
use std::f64::consts::PI;
use std::fmt;

/// Why a shape could not be built.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum ShapeError {
    /// The shape name is not known.
    UnknownShape(String),
    /// The number of dimensions is wrong.
    WrongCount {
        /// Name of the shape.
        shape: &'static str,
        /// Number of dimensions the shape needs.
        expected: usize,
        /// Names of the dimensions, joined by spaces.
        names: &'static str,
    },
    /// A dimension is zero, negative, infinite or not a number.
    NotPositive,
    /// The triangle inequality does not hold.
    NotATriangle,
}

impl fmt::Display for ShapeError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            ShapeError::UnknownShape(n) => write!(f, "unknown shape '{n}'"),
            ShapeError::WrongCount {
                shape,
                expected,
                names,
            } => write!(f, "{shape} needs {expected} dimension(s): {names}"),
            ShapeError::NotPositive => write!(f, "dimensions must be positive numbers"),
            ShapeError::NotATriangle => write!(f, "sides do not form a triangle"),
        }
    }
}

impl Error for ShapeError {}

/// A plane shape.
pub trait Shape {
    /// The area of the shape.
    fn area(&self) -> f64;
    /// The perimeter of the shape.
    fn perimeter(&self) -> f64;
}

fn check(dims: &[f64]) -> Result<(), ShapeError> {
    if dims.iter().all(|d| d.is_finite() && *d > 0.0) {
        Ok(())
    } else {
        Err(ShapeError::NotPositive)
    }
}

/// A circle.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct Circle {
    radius: f64,
}

impl Circle {
    /// Make a circle. The radius must be finite and more than zero.
    ///
    /// ```
    /// use shapes::{Circle, Shape};
    /// assert!((Circle::new(1.0).unwrap().area() - std::f64::consts::PI).abs() < 1e-12);
    /// assert!(Circle::new(-1.0).is_err());
    /// ```
    pub fn new(radius: f64) -> Result<Self, ShapeError> {
        check(&[radius])?;
        Ok(Self { radius })
    }
}

impl Shape for Circle {
    fn area(&self) -> f64 {
        PI * self.radius * self.radius
    }
    fn perimeter(&self) -> f64 {
        2.0 * PI * self.radius
    }
}

/// A rectangle.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct Rectangle {
    width: f64,
    height: f64,
}

impl Rectangle {
    /// Make a rectangle. Both sides must be finite and more than zero.
    ///
    /// ```
    /// use shapes::{Rectangle, Shape};
    /// let r = Rectangle::new(2.0, 3.0).unwrap();
    /// assert_eq!(r.area(), 6.0);
    /// assert_eq!(r.perimeter(), 10.0);
    /// ```
    pub fn new(width: f64, height: f64) -> Result<Self, ShapeError> {
        check(&[width, height])?;
        Ok(Self { width, height })
    }
}

impl Shape for Rectangle {
    fn area(&self) -> f64 {
        self.width * self.height
    }
    fn perimeter(&self) -> f64 {
        2.0 * (self.width + self.height)
    }
}

/// A square.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct Square {
    side: f64,
}

impl Square {
    /// Make a square. The side must be finite and more than zero.
    ///
    /// ```
    /// use shapes::{Square, Shape};
    /// assert_eq!(Square::new(3.0).unwrap().area(), 9.0);
    /// ```
    pub fn new(side: f64) -> Result<Self, ShapeError> {
        check(&[side])?;
        Ok(Self { side })
    }
}

impl Shape for Square {
    fn area(&self) -> f64 {
        self.side * self.side
    }
    fn perimeter(&self) -> f64 {
        4.0 * self.side
    }
}

/// A triangle, given by its three sides.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct Triangle {
    a: f64,
    b: f64,
    c: f64,
}

impl Triangle {
    /// Make a triangle. The sides must be finite, more than zero, and obey
    /// the strict triangle inequality.
    ///
    /// ```
    /// use shapes::{Triangle, ShapeError};
    /// assert_eq!(Triangle::new(1.0, 1.0, 5.0), Err(ShapeError::NotATriangle));
    /// ```
    pub fn new(a: f64, b: f64, c: f64) -> Result<Self, ShapeError> {
        check(&[a, b, c])?;
        if a + b <= c || a + c <= b || b + c <= a {
            return Err(ShapeError::NotATriangle);
        }
        Ok(Self { a, b, c })
    }
}

impl Shape for Triangle {
    fn area(&self) -> f64 {
        let p = self.perimeter() / 2.0;
        (p * (p - self.a) * (p - self.b) * (p - self.c)).sqrt()
    }
    fn perimeter(&self) -> f64 {
        self.a + self.b + self.c
    }
}

/// The names of all shapes, in the order used by the program.
pub const SHAPE_NAMES: [&str; 4] = ["circle", "rectangle", "square", "triangle"];

/// The dimension names of a shape, or `None` for an unknown shape.
///
/// ```
/// assert_eq!(shapes::dimension_names("rectangle"), Some(&["width", "height"][..]));
/// assert_eq!(shapes::dimension_names("hexagon"), None);
/// ```
pub fn dimension_names(name: &str) -> Option<&'static [&'static str]> {
    match name {
        "circle" => Some(&["radius"]),
        "rectangle" => Some(&["width", "height"]),
        "square" => Some(&["side"]),
        "triangle" => Some(&["a", "b", "c"]),
        _ => None,
    }
}

/// Build a shape from its name and its dimensions.
///
/// ```
/// let s = shapes::from_name("square", &[3.0]).unwrap();
/// assert_eq!(s.area(), 9.0);
/// assert!(shapes::from_name("hexagon", &[1.0]).is_err());
/// ```
pub fn from_name(name: &str, dims: &[f64]) -> Result<Box<dyn Shape>, ShapeError> {
    let names = dimension_names(name).ok_or_else(|| ShapeError::UnknownShape(name.to_string()))?;
    if dims.len() != names.len() {
        let (shape, joined): (&'static str, &'static str) = match name {
            "circle" => ("circle", "radius"),
            "rectangle" => ("rectangle", "width height"),
            "square" => ("square", "side"),
            _ => ("triangle", "a b c"),
        };
        return Err(ShapeError::WrongCount {
            shape,
            expected: names.len(),
            names: joined,
        });
    }
    Ok(match name {
        "circle" => Box::new(Circle::new(dims[0])?),
        "rectangle" => Box::new(Rectangle::new(dims[0], dims[1])?),
        "square" => Box::new(Square::new(dims[0])?),
        _ => Box::new(Triangle::new(dims[0], dims[1], dims[2])?),
    })
}
