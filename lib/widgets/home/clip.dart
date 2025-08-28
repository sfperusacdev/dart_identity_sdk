part of 'default_home_page.dart';

class CustomClip extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path
      ..moveTo(0, size.height * 0.8)
      ..arcToPoint(
        Offset(size.width, size.height * 0.8),
        radius: Radius.circular(size.width),
        clockwise: false,
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
