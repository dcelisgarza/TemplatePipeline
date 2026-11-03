use shapes::{from_name, Circle, Rectangle, Shape, ShapeError, Square, Triangle};
use std::f64::consts::PI;

fn close(a: f64, b: f64) -> bool {
    (a - b).abs() < 1e-9
}

#[test]
fn circle_values() {
    let c = Circle::new(2.0).unwrap();
    assert!(close(c.area(), 4.0 * PI));
    assert!(close(c.perimeter(), 4.0 * PI));
}

#[test]
fn rectangle_values() {
    let r = Rectangle::new(2.0, 3.0).unwrap();
    assert!(close(r.area(), 6.0));
    assert!(close(r.perimeter(), 10.0));
}

#[test]
fn square_values() {
    let s = Square::new(3.0).unwrap();
    assert!(close(s.area(), 9.0));
    assert!(close(s.perimeter(), 12.0));
}

#[test]
fn triangle_values() {
    let t = Triangle::new(3.0, 4.0, 5.0).unwrap();
    assert!(close(t.area(), 6.0));
    assert!(close(t.perimeter(), 12.0));
}

#[test]
fn rejects_bad_dimensions() {
    for bad in [0.0, -1.0, f64::INFINITY, f64::NEG_INFINITY, f64::NAN] {
        assert_eq!(Circle::new(bad).unwrap_err(), ShapeError::NotPositive);
        assert_eq!(
            Rectangle::new(bad, 1.0).unwrap_err(),
            ShapeError::NotPositive
        );
        assert_eq!(
            Rectangle::new(1.0, bad).unwrap_err(),
            ShapeError::NotPositive
        );
        assert_eq!(Square::new(bad).unwrap_err(), ShapeError::NotPositive);
        assert_eq!(
            Triangle::new(bad, 1.0, 1.0).unwrap_err(),
            ShapeError::NotPositive
        );
    }
}

#[test]
fn triangle_inequality() {
    assert_eq!(
        Triangle::new(1.0, 1.0, 5.0).unwrap_err(),
        ShapeError::NotATriangle
    );
    assert_eq!(
        Triangle::new(1.0, 2.0, 3.0).unwrap_err(),
        ShapeError::NotATriangle
    );
    assert_eq!(
        Triangle::new(5.0, 1.0, 1.0).unwrap_err(),
        ShapeError::NotATriangle
    );
}

#[test]
fn unknown_shape() {
    let e = from_name("hexagon", &[1.0]).err().unwrap();
    assert_eq!(e, ShapeError::UnknownShape("hexagon".into()));
    assert_eq!(e.to_string(), "unknown shape 'hexagon'");
}

#[test]
fn from_name_builds_shapes() {
    assert!(close(from_name("square", &[3.0]).unwrap().area(), 9.0));
    let e = from_name("rectangle", &[1.0]).err().unwrap();
    assert_eq!(
        e.to_string(),
        "rectangle needs 2 dimension(s): width height"
    );
}
