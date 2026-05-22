import 'package:flutter/material.dart';
import 'hotspot_shared.dart';

// ─────────────────────────────────────────────────────────────────────────────
// UV PAINTER — torch ring glow
// ─────────────────────────────────────────────────────────────────────────────

class UvRevealPainter extends CustomPainter {
  final Offset? cursorPos;
  final double radius;

  UvRevealPainter({this.cursorPos, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    if (cursorPos == null) return;
    canvas.drawCircle(
      cursorPos!,
      radius,
      Paint()
        ..color = Colors.purpleAccent.withOpacity(0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    canvas.drawCircle(
      cursorPos!,
      radius,
      Paint()
        ..color = Colors.deepPurple.withOpacity(0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
  }

  @override
  bool shouldRepaint(UvRevealPainter old) =>
      old.cursorPos != cursorPos || old.radius != radius;
}

// ─────────────────────────────────────────────────────────────────────────────
// UV CIRCLE CLIPPER
// ─────────────────────────────────────────────────────────────────────────────

class _CircleClipper extends CustomClipper<Path> {
  final Offset center;
  final double radius;
  const _CircleClipper({required this.center, required this.radius});

  @override
  Path getClip(Size size) =>
      Path()..addOval(Rect.fromCircle(center: center, radius: radius));

  @override
  bool shouldReclip(_CircleClipper old) =>
      old.center != center || old.radius != radius;
}

// ─────────────────────────────────────────────────────────────────────────────
// UV IMAGE PAGE — single page with base image + optional UV reveal
//                 + optional sticky bottom photo that slides up from below
//
// The sticky photo overlaps the bottom ~30% of the main image, like a page
// tucked underneath and pulled out. It lives OUTSIDE the InteractiveViewer so
// it always stays pinned to the screen edge regardless of zoom/pan.
// ─────────────────────────────────────────────────────────────────────────────

class UvImagePage extends StatefulWidget {
  final String assetPath;
  final String? uvOverlayAsset;
  final String? stickyBottomAsset; // optional attached sub-photo
  final bool uvActive;
  final double uvRadius;
  final List<PhotoHotspot> hotspots;
  final Size imageSize;

  const UvImagePage({
    super.key,
    required this.assetPath,
    this.uvOverlayAsset,
    this.stickyBottomAsset,
    required this.uvActive,
    required this.uvRadius,
    required this.hotspots,
    required this.imageSize,
  });

  @override
  State<UvImagePage> createState() => _UvImagePageState();
}

class _UvImagePageState extends State<UvImagePage> {
  Offset? _cursor;

  @override
  Widget build(BuildContext context) {
    final showUv = widget.uvActive && widget.uvOverlayAsset != null;
    final hasSticky = widget.stickyBottomAsset != null;

    // The core image widget — reused in both branches
    Widget mainImage = InteractiveViewer(
      minScale: 1,
      maxScale: 4,
      child: Center(
        child: MouseRegion(
          cursor: showUv ? SystemMouseCursors.none : MouseCursor.defer,
          onHover: showUv
              ? (e) => setState(() => _cursor = e.localPosition)
              : null,
          child: Listener(
            onPointerMove: showUv
                ? (e) => setState(() => _cursor = e.localPosition)
                : null,
            onPointerDown: showUv
                ? (e) => setState(() => _cursor = e.localPosition)
                : null,
            child: Stack(
              children: [
                AssetImageWithLoader(assetPath: widget.assetPath),
                if (showUv) ...[
                  Positioned.fill(
                    child: Container(color: Colors.black.withOpacity(0.45)),
                  ),
                  if (_cursor != null)
                    Positioned.fill(
                      child: ClipPath(
                        clipper: _CircleClipper(
                          center: _cursor!,
                          radius: widget.uvRadius,
                        ),
                        child: Image.asset(
                          widget.uvOverlayAsset!,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: UvRevealPainter(
                        cursorPos: _cursor,
                        radius: widget.uvRadius,
                      ),
                    ),
                  ),
                ],
                if (!showUv)
                  Positioned.fill(
                    child: HotspotViewLayer(
                      hotspots: widget.hotspots,
                      imageSize: widget.imageSize,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    // ── With sticky: scrollable column, lower photo overlaps upper by 48px
    if (hasSticky) {
      return SizedBox.expand(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: mainImage,
              ),
              Transform.translate(
                offset: const Offset(0, -200),
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.transparent,
                          blurRadius: 0,
                          offset: Offset(0, -10),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      widget.stickyBottomAsset!,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ── Without sticky: just the image filling the space
    return SizedBox.expand(child: mainImage);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UV PAGE ITEM
// ─────────────────────────────────────────────────────────────────────────────

class UvPageItem {
  final PageItem page;
  final String? uvOverlayAsset;
  final String? stickyBottomAsset;

  const UvPageItem(this.page) : uvOverlayAsset = null, stickyBottomAsset = null;

  const UvPageItem.withUv(this.page, this.uvOverlayAsset)
    : stickyBottomAsset = null;

  const UvPageItem.withSticky(this.page, this.stickyBottomAsset)
    : uvOverlayAsset = null;

  // Both UV overlay and sticky bottom photo
  const UvPageItem.full(this.page, this.uvOverlayAsset, this.stickyBottomAsset);
}

// ─────────────────────────────────────────────────────────────────────────────
// UV CONTROLS — button + radius slider
// ─────────────────────────────────────────────────────────────────────────────

class UvControls extends StatelessWidget {
  final bool uvActive;
  final bool hasUvOnPage;
  final double uvRadius;
  final VoidCallback onToggle;
  final ValueChanged<double> onRadiusChanged;

  const UvControls({
    super.key,
    required this.uvActive,
    required this.hasUvOnPage,
    required this.uvRadius,
    required this.onToggle,
    required this.onRadiusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = uvActive
        ? Colors.white
        : (hasUvOnPage ? Colors.black54 : Colors.black26);
    final borderColor = uvActive
        ? Colors.deepPurple
        : (hasUvOnPage ? Colors.black54 : Colors.black26);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedOpacity(
          opacity: uvActive ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: IgnorePointer(
            ignoring: !uvActive,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.circle_outlined,
                    color: Colors.white70,
                    size: 13,
                  ),
                  SizedBox(
                    width: 100,
                    child: Slider(
                      value: uvRadius,
                      min: 30,
                      max: 200,
                      activeColor: Colors.purpleAccent,
                      inactiveColor: Colors.white24,
                      onChanged: onRadiusChanged,
                    ),
                  ),
                  const Icon(Icons.circle, color: Colors.white70, size: 17),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: uvActive ? Colors.deepPurple : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: hasUvOnPage ? onToggle : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.flashlight_on, color: activeColor, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Ультрафіолет',
                    style: TextStyle(
                      fontFamily: 'Minecraft',
                      fontSize: 11,
                      color: activeColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UV FULL SCREEN VIEWER
// ─────────────────────────────────────────────────────────────────────────────

class UvFullScreenViewer extends StatefulWidget {
  final List<UvPageItem> uvPages;
  final int initialIndex;
  final List<List<PhotoHotspot>> hotspots;
  final List<Size> imageSizes;

  const UvFullScreenViewer({
    super.key,
    required this.uvPages,
    required this.initialIndex,
    required this.hotspots,
    required this.imageSizes,
  });

  @override
  State<UvFullScreenViewer> createState() => _UvFullScreenViewerState();
}

class _UvFullScreenViewerState extends State<UvFullScreenViewer> {
  late final PageController _pageController;
  late int _currentIndex;
  bool _uvActive = false;
  double _uvRadius = 80.0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _go(int i) => _pageController.animateToPage(
    i,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
  );

  bool get _hasPrev => _currentIndex > 0;
  bool get _hasNext => _currentIndex < widget.uvPages.length - 1;
  String? get _currentUvOverlay => widget.uvPages[_currentIndex].uvOverlayAsset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── PageView ──────────────────────────────────────────────────
          PageView.builder(
            controller: _pageController,
            // Disable swipe while UV is active (finger is used to move torch)
            physics: _uvActive
                ? const NeverScrollableScrollPhysics()
                : const ScrollPhysics(),
            itemCount: widget.uvPages.length,
            onPageChanged: (i) => setState(() {
              _currentIndex = i;
              _uvActive = false;
            }),
            itemBuilder: (context, index) {
              final item = widget.uvPages[index];
              if (item.page.isYoutube) {
                return YoutubePageWidget(
                  videoId: item.page.assetPath,
                  titleWidget: const SizedBox.shrink(),
                );
              }
              return UvImagePage(
                assetPath: item.page.assetPath,
                uvOverlayAsset: item.uvOverlayAsset,
                stickyBottomAsset: item.stickyBottomAsset,
                uvActive: _uvActive && index == _currentIndex,
                uvRadius: _uvRadius,
                hotspots: widget.hotspots[index],
                imageSize: widget.imageSizes[index],
              );
            },
          ),

          // ── Close ─────────────────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: OutlinedIconBtn(
              icon: Icons.close,
              onTap: () => Navigator.of(context).pop(_currentIndex),
            ),
          ),

          // ── UV controls (bottom center) ───────────────────────────────
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: UvControls(
                uvActive: _uvActive,
                hasUvOnPage: _currentUvOverlay != null,
                uvRadius: _uvRadius,
                onToggle: () => setState(() => _uvActive = !_uvActive),
                onRadiusChanged: (v) => setState(() => _uvRadius = v),
              ),
            ),
          ),

          // ── Left arrow ────────────────────────────────────────────────
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: AnimatedOpacity(
                opacity: _hasPrev ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: !_hasPrev,
                  child: OutlinedIconBtn(
                    icon: Icons.arrow_back_ios,
                    onTap: () => _go(_currentIndex - 1),
                  ),
                ),
              ),
            ),
          ),

          // ── Right arrow ───────────────────────────────────────────────
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: AnimatedOpacity(
                opacity: _hasNext ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: !_hasNext,
                  child: OutlinedIconBtn(
                    icon: Icons.arrow_forward_ios,
                    onTap: () => _go(_currentIndex + 1),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UV CAROUSEL SCREEN BASE
// ─────────────────────────────────────────────────────────────────────────────

abstract class UvCarouselScreenState<T extends StatefulWidget>
    extends CarouselScreenState<T> {
  @override
  List<PageItem> get pages => uvPages.map((e) => e.page).toList();

  List<UvPageItem> get uvPages;

  bool _uvActive = false;
  double _uvRadius = 80.0;

  String? get _currentUvOverlay => currentIndex < uvPages.length
      ? uvPages[currentIndex].uvOverlayAsset
      : null;

  @override
  Future<void> openFullScreen() async {
    final result = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (_) => UvFullScreenViewer(
          uvPages: uvPages,
          initialIndex: currentIndex,
          hotspots: hotspots,
          imageSizes: imageSizes,
        ),
      ),
    );
    if (result != null && result != currentIndex) {
      setState(() => currentIndex = result);
      pageController.jumpToPage(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasUv = _currentUvOverlay != null;

    return KeyboardListener(
      focusNode: keyFocus,
      autofocus: true,
      onKeyEvent: handleKey,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: appBarTitleWidget,
          actions: [
            if (devMode)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'DEV',
                      style: TextStyle(
                        fontFamily: 'Minecraft',
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(bgAsset, fit: BoxFit.cover),
            Column(
              children: [
                SizedBox(
                  height: kToolbarHeight + MediaQuery.of(context).padding.top,
                ),
                Expanded(
                  child: Stack(
                    children: [
                      // ── PageView ──────────────────────────────────────
                      PageView.builder(
                        controller: pageController,
                        physics: devMode || _uvActive
                            ? const NeverScrollableScrollPhysics()
                            : const ScrollPhysics(),
                        onPageChanged: (i) => setState(() {
                          currentIndex = i;
                          _uvActive = false;
                        }),
                        itemCount: pages.length,
                        itemBuilder: (context, index) {
                          final item = uvPages[index];
                          if (item.page.isYoutube) {
                            return YoutubePageWidget(
                              videoId: item.page.assetPath,
                              titleWidget: appBarTitleWidget,
                              bgAsset: bgAsset,
                            );
                          }
                          // In dev mode: plain image + hotspot dev layer (no UV)
                          if (devMode) {
                            return Stack(
                              children: [
                                AssetImageWithLoader(
                                  assetPath: item.page.assetPath,
                                  fit: BoxFit.contain,
                                ),
                                if (hotspotsLoaded &&
                                    imageSizes.length == pages.length)
                                  Positioned.fill(
                                    child: HotspotDevLayer(
                                      hotspots: hotspots[index],
                                      imageSize: imageSizes[index],
                                      onChanged: (updated) {
                                        setState(
                                          () => hotspots[index] = updated,
                                        );
                                        saveHotspots();
                                      },
                                    ),
                                  ),
                              ],
                            );
                          }
                          // Normal mode: UvImagePage handles both UV and hotspots
                          return UvImagePage(
                            assetPath: item.page.assetPath,
                            uvOverlayAsset: item.uvOverlayAsset,
                            stickyBottomAsset: item.stickyBottomAsset,
                            uvActive: _uvActive && index == currentIndex,
                            uvRadius: _uvRadius,
                            hotspots:
                                hotspotsLoaded &&
                                    imageSizes.length == pages.length
                                ? hotspots[index]
                                : [],
                            imageSize: imageSizes.length == pages.length
                                ? imageSizes[index]
                                : const Size(1000, 1000),
                          );
                        },
                      ),

                      // ── Dev hint bar ──────────────────────────────────
                      if (devMode)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            color: Colors.black54,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: const Text(
                              'Tap empty area to add hotspot  ·  drag to move  ·  corner handles to resize',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontFamily: 'Minecraft',
                              ),
                            ),
                          ),
                        ),

                      // ── LEFT arrow ────────────────────────────────────
                      Positioned(
                        left: 8,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: AnimatedOpacity(
                            opacity: hasPrev ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: IgnorePointer(
                              ignoring: !hasPrev,
                              child: OutlinedIconBtn(
                                icon: Icons.arrow_back_ios,
                                color: Colors.black87,
                                onTap: prevPhoto,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ── RIGHT arrow ───────────────────────────────────
                      Positioned(
                        right: 8,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: AnimatedOpacity(
                            opacity: hasNext ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: IgnorePointer(
                              ignoring: !hasNext,
                              child: OutlinedIconBtn(
                                icon: Icons.arrow_forward_ios,
                                color: Colors.black87,
                                onTap: nextPhoto,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ── Top-right: fullscreen + dev arrows ────────────
                      Positioned(
                        top: 10,
                        right: 60,
                        child: Row(
                          children: [
                            if (devMode) ...[
                              OutlinedIconBtn(
                                icon: Icons.arrow_back_ios,
                                color: hasPrev
                                    ? Colors.blueAccent
                                    : Colors.grey,
                                onTap: prevPhoto,
                              ),
                              const SizedBox(width: 8),
                              OutlinedIconBtn(
                                icon: Icons.arrow_forward_ios,
                                color: hasNext
                                    ? Colors.blueAccent
                                    : Colors.grey,
                                onTap: nextPhoto,
                              ),
                              const SizedBox(width: 8),
                            ],
                            OutlinedIconBtn(
                              icon: Icons.fullscreen,
                              color: Colors.black87,
                              onTap: openFullScreen,
                            ),
                          ],
                        ),
                      ),

                      // ── Bottom bar: counter + UV controls ─────────────
                      Positioned(
                        bottom: 12,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${currentIndex + 1} / ${pages.length}',
                                style: const TextStyle(
                                  fontFamily: 'Minecraft',
                                  color: Colors.black87,
                                  fontSize: 13,
                                ),
                              ),
                              UvControls(
                                uvActive: _uvActive,
                                hasUvOnPage: hasUv,
                                uvRadius: _uvRadius,
                                onToggle: () =>
                                    setState(() => _uvActive = !_uvActive),
                                onRadiusChanged: (v) =>
                                    setState(() => _uvRadius = v),
                              ),
                              const SizedBox(width: 80),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 64),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EXAMPLE SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class UvFirstScreen extends StatefulWidget {
  const UvFirstScreen({super.key});

  @override
  State<UvFirstScreen> createState() => _UvFirstScreenState();
}

class _UvFirstScreenState extends UvCarouselScreenState<UvFirstScreen> {
  @override
  Widget get appBarTitleWidget => const Text(
    'Borukva News',
    style: TextStyle(
      fontFamily: 'Tapestry',
      fontWeight: FontWeight.w600,
      fontSize: 40,
    ),
  );

  @override
  HotspotStorage get storage =>
      HotspotStorage(workerUrl: '', cacheKey: '09_02-14_02_hotspots_cache');

  @override
  List<UvPageItem> get uvPages => [
    const UvPageItem(PageItem.image('assets/pictures/09_02-14_02/title_1.png')),
    // UV overlay
    UvPageItem.withUv(
      const PageItem.image('assets/pictures/09_02-14_02/page_1.png'),
      'assets/pictures/09_02-14_02/page_1_uv.png',
    ),
    // Sticky bottom photo
    UvPageItem.withSticky(
      const PageItem.image('assets/pictures/09_02-14_02/page_2.png'),
      'assets/pictures/09_02-14_02/page_2_sticky.png',
    ),
    // Both UV and sticky
    UvPageItem.full(
      const PageItem.image('assets/pictures/09_02-14_02/page_3.png'),
      'assets/pictures/09_02-14_02/page_3_uv.png',
      'assets/pictures/09_02-14_02/page_3_sticky.png',
    ),
    const UvPageItem(PageItem.image('assets/pictures/09_02-14_02/page_4.png')),
    const UvPageItem(PageItem.image('assets/pictures/09_02-14_02/last_1.png')),
  ];
}
