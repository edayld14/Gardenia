import 'package:flutter/material.dart';

class IntroScreen extends StatefulWidget {
  final VoidCallback onIntroEnd;

  const IntroScreen({super.key, required this.onIntroEnd});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _introPages = [
    {
      "title": "Gardenia'ya Hoşgeldiniz",
      "description": "En güzel çiçekler ve bitkiler parmaklarınızın ucunda.",
      "image": "assets/images/flower1.png", // Projende uygun görseller ekle
    },
    {
      "title": "Favorilerinizi Kaydedin",
      "description":
          "Sevdiğiniz çiçekleri favorilerinize ekleyin ve kolayca bulun.",
      "image": "assets/images/flower2.png",
    },
    {
      "title": "Hızlı Sipariş Verin",
      "description": "Anasayfadan seç, sepete ekle ve kapına gelsin!",
      "image": "assets/images/flower3.png",
    },
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  Widget _buildPageContent(Map<String, String> page) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(page["image"]!, height: 250),
          const SizedBox(height: 40),
          Text(
            page["title"]!,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            page["description"]!,
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDotsIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _introPages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: _currentPage == index ? 16 : 8,
          height: 8,
          decoration: BoxDecoration(
            color:
                _currentPage == index
                    ? Colors.green
                    : Colors.green.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLastPage = _currentPage == _introPages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _introPages.length,
                onPageChanged: _onPageChanged,
                itemBuilder:
                    (context, index) => _buildPageContent(_introPages[index]),
              ),
            ),
            _buildDotsIndicator(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 16,
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.green,
                ),
                onPressed: () {
                  if (isLastPage) {
                    widget.onIntroEnd();
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.ease,
                    );
                  }
                },
                child: Text(isLastPage ? "Başla" : "İleri"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
