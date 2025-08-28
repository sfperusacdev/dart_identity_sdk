part of 'default_home_page.dart';

class HomeMenuCard extends StatelessWidget {
  final String assetImage;
  final String title;
  final Color color;
  final void Function()? onTab;

  const HomeMenuCard({
    super.key,
    required this.assetImage,
    required this.title,
    this.color = const Color(0xFF1C3E1C),
    this.onTab,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTab,
      borderRadius: BorderRadius.circular(30),
      child: Ink(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
        ),
        height: 130,
        width: 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage(assetImage),
              width: 65,
              height: 65,
              fit: BoxFit.fill,
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
