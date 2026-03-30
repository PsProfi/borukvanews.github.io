import 'dart:convert';
import 'dart:ui';

import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SECRET COMBO — type this anywhere on a carousel screen to toggle dev mode
// ─────────────────────────────────────────────────────────────────────────────

const String kDevCombo = 'devmode';

// ─────────────────────────────────────────────────────────────────────────────
// PAGE ITEM — either an image asset or a video asset
// ─────────────────────────────────────────────────────────────────────────────

class PageItem {
  final String
  assetPath; // asset path for image, video URL, or YouTube video ID
  final bool isVideo;
  final bool isYoutube;

  const PageItem.image(this.assetPath) : isVideo = false, isYoutube = false;
  const PageItem.video(this.assetPath) : isVideo = true, isYoutube = false;
  const PageItem.youtube(this.assetPath) : isVideo = false, isYoutube = true;
}

// ─────────────────────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────────────────────

class PhotoHotspot {
  double left;
  double top;
  double width;
  double height;
  String url;

  PhotoHotspot({
    this.left = 0.20,
    this.top = 0.20,
    this.width = 0.60,
    this.height = 0.20,
    this.url = 'https://example.com',
  });

  PhotoHotspot copyWith({
    double? left,
    double? top,
    double? width,
    double? height,
    String? url,
  }) => PhotoHotspot(
    left: left ?? this.left,
    top: top ?? this.top,
    width: width ?? this.width,
    height: height ?? this.height,
    url: url ?? this.url,
  );

  Map<String, dynamic> toJson() => {
    'left': left,
    'top': top,
    'width': width,
    'height': height,
    'url': url,
  };

  factory PhotoHotspot.fromJson(Map<String, dynamic> j) => PhotoHotspot(
    left: (j['left'] as num).toDouble(),
    top: (j['top'] as num).toDouble(),
    width: (j['width'] as num).toDouble(),
    height: (j['height'] as num).toDouble(),
    url: j['url'] as String,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// PERSISTENT STORAGE
//
// Each screen passes its own [gistFile] and [cacheKey] so they stay isolated.
// Reads and writes go through the Cloudflare Worker — no token in this file.
// ─────────────────────────────────────────────────────────────────────────────

class HotspotStorage {
  final String workerUrl; // full URL including ?file= param
  final String cacheKey; // e.g. 'kchbnk_hotspots_cache'

  HotspotStorage({required this.workerUrl, required this.cacheKey});

  String? _lastKnownSha;

  Uri get _apiUri => Uri.parse(workerUrl);

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=utf-8',
  };

  // ── Parse helpers ──────────────────────────────────────────────────────────

  List<List<PhotoHotspot>> _decode(String raw, int count) {
    try {
      final outer = jsonDecode(raw) as List<dynamic>;
      return List.generate(count, (i) {
        if (i >= outer.length) return <PhotoHotspot>[];
        return (outer[i] as List<dynamic>)
            .map((e) => PhotoHotspot.fromJson(e as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      debugPrint('[Storage] decode error: $e');
      return List.generate(count, (_) => []);
    }
  }

  static String _encode(List<List<PhotoHotspot>> hotspots) => jsonEncode(
    hotspots.map((l) => l.map((h) => h.toJson()).toList()).toList(),
  );

  // ── Cache ──────────────────────────────────────────────────────────────────

  Future<void> _writeCache(String raw) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(cacheKey, raw);
  }

  Future<String?> _readCache() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(cacheKey);
  }

  // ── Worker API ─────────────────────────────────────────────────────────────

  Future<(String, String)?> _fetchFromWorker() async {
    try {
      final response = await http.get(_apiUri, headers: _headers);
      debugPrint('[Storage] GET ${response.statusCode}');
      if (response.statusCode != 200) {
        debugPrint('[Storage] GET failed: ${response.body}');
        return null;
      }
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final sha = decoded['sha'] as String;
      final b64 = (decoded['content'] as String).replaceAll('\n', '');
      final content = utf8.decode(base64.decode(b64));
      _lastKnownSha = sha;
      debugPrint('[Storage] GET ok sha=$sha');
      return (content.trim(), sha);
    } catch (e, st) {
      debugPrint('[Storage] GET exception: $e\n$st');
      return null;
    }
  }

  Future<bool> _pushToWorker(String raw, String sha) async {
    try {
      debugPrint('[Storage] PUT start sha=$sha');
      final response = await http.put(
        _apiUri,
        headers: _headers,
        body: jsonEncode({
          'content': base64.encode(utf8.encode(raw)),
          'sha': sha,
        }),
      );
      debugPrint('[Storage] PUT ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final r = jsonDecode(response.body) as Map<String, dynamic>;
          _lastKnownSha =
              (r['content'] as Map<String, dynamic>)['sha'] as String?;
        } catch (_) {}
        return true;
      }
      return false;
    } catch (e, st) {
      debugPrint('[Storage] PUT exception: $e\n$st');
      return false;
    }
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  Future<List<List<PhotoHotspot>>> load(int count) async {
    final result = await _fetchFromWorker();
    if (result != null) {
      final (content, _) = result;
      await _writeCache(content);
      return _decode(content, count);
    }
    final cached = await _readCache();
    if (cached != null) return _decode(cached, count);
    return List.generate(count, (_) => []);
  }

  Future<void> save(List<List<PhotoHotspot>> hotspots) async {
    final raw = _encode(hotspots);
    await _writeCache(raw);
    if (_lastKnownSha == null) await _fetchFromWorker();
    final sha = _lastKnownSha;
    if (sha == null) return;
    await _pushToWorker(raw, sha);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// IMAGE RECT HELPER
// ─────────────────────────────────────────────────────────────────────────────

Rect imageRect(Size container, Size intrinsicSize) {
  final cA = container.width / container.height;
  final iA = intrinsicSize.width / intrinsicSize.height;
  double imgW, imgH;
  if (iA > cA) {
    imgW = container.width;
    imgH = container.width / iA;
  } else {
    imgH = container.height;
    imgW = container.height * iA;
  }
  return Rect.fromLTWH(
    (container.width - imgW) / 2,
    (container.height - imgH) / 2,
    imgW,
    imgH,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class OutlinedIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const OutlinedIconBtn({
    super.key,
    required this.icon,
    required this.onTap,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onTap,
    style: OutlinedButton.styleFrom(
      overlayColor: Colors.white,
      side: BorderSide(color: color, width: 2),
      shape: const CircleBorder(),
      minimumSize: const Size(50, 50),
    ),
    child: Icon(icon, color: color, size: 24),
  );
}

class TextBtn extends StatelessWidget {
  final Text text;
  final VoidCallback onTap;
  final Color color;

  const TextBtn({
    super.key,
    required this.text,
    required this.onTap,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onTap,
    style: OutlinedButton.styleFrom(
      overlayColor: Colors.white,
      side: BorderSide(color: color, width: 2),
      shape: const CircleBorder(),
      minimumSize: const Size(50, 50),
    ),
    child: text,
  );
}

class AssetImageWithLoader extends StatelessWidget {
  final String assetPath;
  final BoxFit fit;

  const AssetImageWithLoader({
    super.key,
    required this.assetPath,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) => Image.asset(
    assetPath,
    fit: fit,
    width: double.infinity,
    height: double.infinity,
    frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
      if (wasSynchronouslyLoaded || frame != null) {
        return AnimatedOpacity(
          opacity: 1,
          duration: const Duration(milliseconds: 250),
          child: child,
        );
      }
      return Stack(
        alignment: Alignment.center,
        children: [
          child,
          const CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
          ),
        ],
      );
    },
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// YOUTUBE VIDEO SCREEN
//
// Standalone screen with AppBar + YouTube player.
// Pass the YouTube video ID (e.g. 'dQw4w9WgXcQ').
// ─────────────────────────────────────────────────────────────────────────────

class YoutubeVideoScreen extends StatefulWidget {
  final String videoId;
  final Widget titleWidget;
  final String bgAsset;

  const YoutubeVideoScreen({
    super.key,
    required this.videoId,
    required this.titleWidget,
    this.bgAsset = 'assets/pictures/bg/bg_borukva.png',
  });

  @override
  State<YoutubeVideoScreen> createState() => _YoutubeVideoScreenState();
}

class _YoutubeVideoScreenState extends State<YoutubeVideoScreen> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: widget.titleWidget,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(widget.bgAsset, fit: BoxFit.cover),
          Column(
            children: [
              SizedBox(
                height: kToolbarHeight + MediaQuery.of(context).padding.top,
              ),
              Expanded(
                child: Center(
                  child: YoutubePlayer(
                    controller: _controller,
                    aspectRatio: 16 / 9,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// YOUTUBE PAGE WIDGET — used inside the carousel PageView
//
// Shows a thumbnail with a play button. Tapping opens YoutubeVideoScreen.
// ─────────────────────────────────────────────────────────────────────────────

class YoutubePageWidget extends StatelessWidget {
  final String videoId;
  final Widget titleWidget;
  final String bgAsset;

  const YoutubePageWidget({
    super.key,
    required this.videoId,
    required this.titleWidget,
    this.bgAsset = 'assets/pictures/bg/bg_borukva.png',
  });

  @override
  Widget build(BuildContext context) {
    final thumb = 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => YoutubeVideoScreen(
            videoId: videoId,
            titleWidget: titleWidget,
            bgAsset: bgAsset,
          ),
        ),
      ),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          // Thumbnail
          Image.network(
            thumb,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const ColoredBox(color: Colors.black),
          ),
          // Play button overlay
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 44,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOTSPOT VIEW LAYER
// ─────────────────────────────────────────────────────────────────────────────

Future<void> launchHotspot(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return;
  if (await canLaunchUrl(uri))
    await launchUrl(uri, mode: LaunchMode.externalApplication);
}

class HotspotViewLayer extends StatelessWidget {
  final List<PhotoHotspot> hotspots;
  final Size imageSize;

  const HotspotViewLayer({
    super.key,
    required this.hotspots,
    required this.imageSize,
  });

  @override
  Widget build(BuildContext context) {
    if (hotspots.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final img = imageRect(
          Size(constraints.maxWidth, constraints.maxHeight),
          imageSize,
        );
        return Stack(
          children: [
            for (final spot in hotspots)
              Positioned(
                left: img.left + spot.left * img.width,
                top: img.top + spot.top * img.height,
                width: spot.width * img.width,
                height: spot.height * img.height,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => launchHotspot(spot.url),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOTSPOT DEV LAYER
// ─────────────────────────────────────────────────────────────────────────────

class HotspotDevLayer extends StatefulWidget {
  final List<PhotoHotspot> hotspots;
  final ValueChanged<List<PhotoHotspot>> onChanged;
  final Size imageSize;

  const HotspotDevLayer({
    super.key,
    required this.hotspots,
    required this.onChanged,
    required this.imageSize,
  });

  @override
  State<HotspotDevLayer> createState() => _HotspotDevLayerState();
}

class _HotspotDevLayerState extends State<HotspotDevLayer> {
  static const double _handle = 22.0;
  late List<PhotoHotspot> _spots;

  @override
  void initState() {
    super.initState();
    _spots = widget.hotspots.map((s) => s.copyWith()).toList();
  }

  void _emit() => widget.onChanged(_spots);

  void _clamp(PhotoHotspot s) {
    s.width = s.width.clamp(0.04, 1.0);
    s.height = s.height.clamp(0.04, 1.0);
    s.left = s.left.clamp(0.0, 1.0 - s.width);
    s.top = s.top.clamp(0.0, 1.0 - s.height);
  }

  Future<void> _editUrl(int index) async {
    final ctrl = TextEditingController(text: _spots[index].url);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hotspot URL'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            hintText: 'https://example.com',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (v) => Navigator.of(ctx).pop(v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (result != null && result.isNotEmpty) {
      setState(() => _spots[index].url = result);
      _emit();
    }
  }

  Future<void> _addSpot(double fx, double fy) async {
    final ctrl = TextEditingController(text: 'https://');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New hotspot URL'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            hintText: 'https://example.com',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (v) => Navigator.of(ctx).pop(v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (result != null && result.isNotEmpty) {
      setState(() {
        _spots.add(
          PhotoHotspot(
            left: (fx - 0.15).clamp(0.0, 0.70),
            top: (fy - 0.07).clamp(0.0, 0.86),
            width: 0.30,
            height: 0.14,
            url: result,
          ),
        );
      });
      _emit();
    }
  }

  void _removeSpot(int index) {
    setState(() => _spots.removeAt(index));
    _emit();
  }

  Widget _resizeHandle({
    required double left,
    required double top,
    required void Function(DragUpdateDetails, double cw, double ch) onUpdate,
    required double cw,
    required double ch,
  }) => Positioned(
    left: left - _handle / 2,
    top: top - _handle / 2,
    width: _handle,
    height: _handle,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanUpdate: (d) => onUpdate(d, cw, ch),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.blueAccent,
          shape: BoxShape.circle,
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final img = imageRect(
          Size(constraints.maxWidth, constraints.maxHeight),
          widget.imageSize,
        );
        final cw = img.width;
        final ch = img.height;

        return GestureDetector(
          onTapUp: (d) {
            final fx = (d.localPosition.dx - img.left) / img.width;
            final fy = (d.localPosition.dy - img.top) / img.height;
            if (fx < 0 || fx > 1 || fy < 0 || fy > 1) return;
            final hit = _spots.any(
              (s) =>
                  fx >= s.left &&
                  fx <= s.left + s.width &&
                  fy >= s.top &&
                  fy <= s.top + s.height,
            );
            if (!hit) _addSpot(fx, fy);
          },
          behavior: HitTestBehavior.translucent,
          child: Stack(
            children: [
              for (int i = 0; i < _spots.length; i++)
                ...() {
                  final s = _spots[i];
                  final l = img.left + s.left * cw;
                  final t = img.top + s.top * ch;
                  final w = s.width * cw;
                  final h = s.height * ch;
                  return [
                    Positioned(
                      left: l,
                      top: t,
                      width: w,
                      height: h,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onPanUpdate: (d) {
                          setState(() {
                            s.left += d.delta.dx / cw;
                            s.top += d.delta.dy / ch;
                            _clamp(s);
                          });
                          _emit();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.18),
                            border: Border.all(
                              color: Colors.blueAccent,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                left: 4,
                                right: 28,
                                bottom: 4,
                                child: Text(
                                  s.url,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 4,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 2,
                                right: 24,
                                child: GestureDetector(
                                  onTap: () => _editUrl(i),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 2,
                                right: 2,
                                child: GestureDetector(
                                  onTap: () => _removeSpot(i),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.redAccent,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _resizeHandle(
                      left: l,
                      top: t,
                      cw: cw,
                      ch: ch,
                      onUpdate: (d, cw, ch) {
                        setState(() {
                          s.left += d.delta.dx / cw;
                          s.width -= d.delta.dx / cw;
                          s.top += d.delta.dy / ch;
                          s.height -= d.delta.dy / ch;
                          _clamp(s);
                        });
                        _emit();
                      },
                    ),
                    _resizeHandle(
                      left: l + w,
                      top: t,
                      cw: cw,
                      ch: ch,
                      onUpdate: (d, cw, ch) {
                        setState(() {
                          s.top += d.delta.dy / ch;
                          s.height -= d.delta.dy / ch;
                          s.width += d.delta.dx / cw;
                          _clamp(s);
                        });
                        _emit();
                      },
                    ),
                    _resizeHandle(
                      left: l,
                      top: t + h,
                      cw: cw,
                      ch: ch,
                      onUpdate: (d, cw, ch) {
                        setState(() {
                          s.left += d.delta.dx / cw;
                          s.width -= d.delta.dx / cw;
                          s.height += d.delta.dy / ch;
                          _clamp(s);
                        });
                        _emit();
                      },
                    ),
                    _resizeHandle(
                      left: l + w,
                      top: t + h,
                      cw: cw,
                      ch: ch,
                      onUpdate: (d, cw, ch) {
                        setState(() {
                          s.width += d.delta.dx / cw;
                          s.height += d.delta.dy / ch;
                          _clamp(s);
                        });
                        _emit();
                      },
                    ),
                  ];
                }(),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FULL-SCREEN VIEWER  (shared across all screens)
// ─────────────────────────────────────────────────────────────────────────────

class FullScreenViewer extends StatefulWidget {
  final List<PageItem> pages;
  final int initialIndex;
  final List<List<PhotoHotspot>> hotspots;
  final List<Size> imageSizes;

  const FullScreenViewer({
    super.key,
    required this.pages,
    required this.initialIndex,
    required this.hotspots,
    required this.imageSizes,
  });

  @override
  State<FullScreenViewer> createState() => _FullScreenViewerState();
}

class _FullScreenViewerState extends State<FullScreenViewer> {
  late final PageController _pageController;
  late int _currentIndex;

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
  bool get _hasNext => _currentIndex < widget.pages.length - 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.pages.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, index) {
              final page = widget.pages[index];
              if (page.isYoutube) {
                return YoutubePageWidget(
                  videoId: page.assetPath,
                  titleWidget: const SizedBox.shrink(),
                );
              }
              return InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Center(
                  child: Stack(
                    children: [
                      AssetImageWithLoader(assetPath: page.assetPath),
                      Positioned.fill(
                        child: HotspotViewLayer(
                          hotspots: widget.hotspots[index],
                          imageSize: widget.imageSizes[index],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: OutlinedIconBtn(
              icon: Icons.close,
              onTap: () => Navigator.of(context).pop(_currentIndex),
            ),
          ),
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
// BASE CAROUSEL STATE — extend this in each screen, override config getters
// ─────────────────────────────────────────────────────────────────────────────

abstract class CarouselScreenState<T extends StatefulWidget> extends State<T> {
  // ── Subclass must override these ──
  List<PageItem> get pages;
  HotspotStorage get storage;
  Widget get appBarTitleWidget;
  String get bgAsset => 'assets/pictures/bg/bg_borukva.png';

  // ── Internal state ──
  final PageController pageController = PageController();
  int currentIndex = 0;
  List<List<PhotoHotspot>> hotspots = [];
  bool hotspotsLoaded = false;
  List<Size> imageSizes = [];
  bool devMode = false;
  String comboBuffer = '';
  late final FocusNode keyFocus;

  @override
  void initState() {
    super.initState();
    keyFocus = FocusNode();
    _loadHotspots();
    _loadImageSizes();
  }

  @override
  void dispose() {
    keyFocus.dispose();
    pageController.dispose();
    super.dispose();
  }

  Future<void> _loadHotspots() async {
    final loaded = await storage.load(pages.length);
    setState(() {
      hotspots = loaded;
      hotspotsLoaded = true;
    });
  }

  Future<void> saveHotspots() => storage.save(hotspots);

  Future<void> _loadImageSizes() async {
    final sizes = <Size>[];
    for (final page in pages) {
      if (page.isVideo || page.isYoutube) {
        sizes.add(const Size(1920, 1080)); // 16:9 fallback
        continue;
      }
      try {
        final data = await rootBundle.load(page.assetPath);
        final codec = await instantiateImageCodec(data.buffer.asUint8List());
        final frame = await codec.getNextFrame();
        sizes.add(
          Size(frame.image.width.toDouble(), frame.image.height.toDouble()),
        );
        frame.image.dispose();
      } catch (_) {
        sizes.add(const Size(1000, 1000));
      }
    }
    setState(() => imageSizes = sizes);
  }

  void handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final char = event.character;
    if (char == null || char.isEmpty) {
      comboBuffer = '';
      return;
    }
    comboBuffer += char.toLowerCase();
    if (comboBuffer.length > kDevCombo.length) {
      comboBuffer = comboBuffer.substring(
        comboBuffer.length - kDevCombo.length,
      );
    }
    if (comboBuffer == kDevCombo) {
      comboBuffer = '';
      setState(() => devMode = !devMode);
      _showDevToast();
    }
  }

  void _showDevToast() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        backgroundColor: devMode
            ? Colors.blueAccent.withOpacity(0.9)
            : Colors.black87,
        content: Text(
          devMode ? '🛠  Developer mode ON' : '🔒  Developer mode OFF',
          style: const TextStyle(fontFamily: 'Minecraft', color: Colors.white),
        ),
      ),
    );
  }

  bool get hasPrev => currentIndex > 0;
  bool get hasNext => currentIndex < pages.length - 1;

  void nextPhoto() {
    if (hasNext) {
      currentIndex++;
      pageController.animateToPage(
        currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void prevPhoto() {
    if (hasPrev) {
      currentIndex--;
      pageController.animateToPage(
        currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> openFullScreen() async {
    final result = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (_) => FullScreenViewer(
          pages: pages,
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
                      PageView.builder(
                        controller: pageController,
                        physics: devMode
                            ? const NeverScrollableScrollPhysics()
                            : const ScrollPhysics(),
                        onPageChanged: (i) => setState(() => currentIndex = i),
                        itemCount: pages.length,
                        itemBuilder: (context, index) {
                          final page = pages[index];
                          if (page.isYoutube) {
                            return YoutubePageWidget(
                              videoId: page.assetPath,
                              titleWidget: appBarTitleWidget,
                              bgAsset: bgAsset,
                            );
                          }
                          return AssetImageWithLoader(
                            assetPath: page.assetPath,
                            fit: BoxFit.contain,
                          );
                        },
                      ),

                      if (hotspotsLoaded && imageSizes.length == pages.length)
                        Positioned.fill(
                          child: devMode
                              ? HotspotDevLayer(
                                  hotspots: hotspots[currentIndex],
                                  imageSize: imageSizes[currentIndex],
                                  onChanged: (updated) {
                                    setState(
                                      () => hotspots[currentIndex] = updated,
                                    );
                                    saveHotspots();
                                  },
                                )
                              : HotspotViewLayer(
                                  hotspots: hotspots[currentIndex],
                                  imageSize: imageSizes[currentIndex],
                                ),
                        ),

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

                      Positioned(
                        top: 10,
                        right: 10,
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
                    ],
                  ),
                ),

                if (!devMode) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedOpacity(
                        opacity: hasPrev ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: IgnorePointer(
                          ignoring: !hasPrev,
                          child: TextBtn(
                            text: const Text(
                              '<',
                              style: TextStyle(
                                fontFamily: 'Minecraft',
                                color: Colors.black,
                              ),
                            ),
                            color: Colors.black87,
                            onTap: prevPhoto,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${currentIndex + 1} / ${pages.length}',
                        style: const TextStyle(
                          fontFamily: 'Minecraft',
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 16),
                      AnimatedOpacity(
                        opacity: hasNext ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: IgnorePointer(
                          ignoring: !hasNext,
                          child: TextBtn(
                            text: const Text(
                              ' >',
                              style: TextStyle(
                                fontFamily: 'Minecraft',
                                color: Colors.black,
                              ),
                            ),
                            color: Colors.black87,
                            onTap: nextPhoto,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
