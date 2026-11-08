import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class EducationalVideosPage extends StatelessWidget {
  const EducationalVideosPage({super.key});

  // ---------------------------------------------------------------------------
  // EDUCATIONAL VIDEO LIST
  // ---------------------------------------------------------------------------
  static const List<Map<String, String>> _videos = [
    {
      "title": "Self Defense Basics for Women",
      "description":
      "Essential self-defense moves every woman should know",
      "videoId": "KVpxP3ZZtAc",
      "category": "Self Defense",
      "duration": "8:24",
      "icon": "🥋",
    },
    {
      "title": "Women's Safety Tips at Night",
      "description":
      "Practical tips to stay safe while travelling at night",
      "videoId": "pSb2y7BNFnk",
      "category": "Safety Tips",
      "duration": "5:12",
      "icon": "🌙",
    },
    {
      "title": "How to Handle Emergency Situations",
      "description":
      "Step by step guide for handling emergencies calmly",
      "videoId": "fOTJbHMhG4Q",
      "category": "Emergency",
      "duration": "6:45",
      "icon": "🚨",
    },
    {
      "title": "Women's Legal Rights in India",
      "description":
      "Know your rights — legal protection available for women",
      "videoId": "JNFWTiKpHXY",
      "category": "Legal Rights",
      "duration": "10:30",
      "icon": "⚖️",
    },
    {
      "title": "Cyber Safety for Women",
      "description":
      "Protect yourself from online harassment and threats",
      "videoId": "aO858HyFbKI",
      "category": "Cyber Safety",
      "duration": "7:15",
      "icon": "💻",
    },
    {
      "title": "Mental Health & Trauma Support",
      "description":
      "Dealing with trauma and building mental resilience",
      "videoId": "rkZl2gsLUp4",
      "category": "Mental Health",
      "duration": "9:00",
      "icon": "🧠",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2533),

      // -----------------------------------------------------------------------
      // APP BAR
      // -----------------------------------------------------------------------
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 1,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Safety Education",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Learn • Prepare • Stay Safe",
              style: TextStyle(
                color: Colors.white54,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),

      // -----------------------------------------------------------------------
      // VIDEO LIST
      // -----------------------------------------------------------------------
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _videos.length,
        itemBuilder: (context, index) {
          final video = _videos[index];

          return _VideoCard(
            video: video,
          );
        },
      ),
    );
  }
}

// =============================================================================
// VIDEO CARD
// =============================================================================

class _VideoCard extends StatelessWidget {
  final Map<String, String> video;

  const _VideoCard({
    required this.video,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VideoPlayerPage(
              videoId: video['videoId']!,
              title: video['title']!,
            ),
          ),
        );
      },

      child: Container(
        margin: const EdgeInsets.only(bottom: 16),

        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white10,
          ),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // -----------------------------------------------------------------
            // THUMBNAIL
            // -----------------------------------------------------------------

            Stack(
              children: [

                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),

                  child: Image.network(
                    'https://img.youtube.com/vi/${video['videoId']}/hqdefault.jpg',

                    width: double.infinity,
                    height: 180,

                    fit: BoxFit.cover,

                    errorBuilder: (
                        context,
                        error,
                        stackTrace,
                        ) {
                      return Container(
                        width: double.infinity,
                        height: 180,
                        color: const Color(0xFF334155),

                        child: Center(
                          child: Text(
                            video['icon']!,
                            style: const TextStyle(
                              fontSize: 50,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // -------------------------------------------------------------
                // DARK OVERLAY + PLAY BUTTON
                // -------------------------------------------------------------

                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(14),
                      ),
                      color: Colors.black.withOpacity(0.3),
                    ),

                    child: const Center(
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.redAccent,

                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                ),

                // -------------------------------------------------------------
                // DURATION
                // -------------------------------------------------------------

                Positioned(
                  bottom: 8,
                  right: 8,

                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(6),
                    ),

                    child: Text(
                      video['duration']!,

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // -------------------------------------------------------------
                // CATEGORY
                // -------------------------------------------------------------

                Positioned(
                  top: 8,
                  left: 8,

                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Text(
                      video['category']!,

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // -----------------------------------------------------------------
            // VIDEO INFORMATION
            // -----------------------------------------------------------------

            Padding(
              padding: const EdgeInsets.all(14),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Row(
                    children: [

                      Text(
                        video['icon']!,
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: Text(
                          video['title']!,

                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    video['description']!,

                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// VIDEO PLAYER PAGE
// =============================================================================

class VideoPlayerPage extends StatefulWidget {
  final String videoId;
  final String title;

  const VideoPlayerPage({
    super.key,
    required this.videoId,
    required this.title,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

// =============================================================================
// VIDEO PLAYER STATE
// =============================================================================

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late final WebViewController _controller;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // -------------------------------------------------------------------------
    // WEBVIEW CONTROLLER
    // -------------------------------------------------------------------------

    _controller = WebViewController()

    // Enable JavaScript because YouTube player requires it.
      ..setJavaScriptMode(
        JavaScriptMode.unrestricted,
      )

    // -----------------------------------------------------------------------
    // NAVIGATION DELEGATE
    // -----------------------------------------------------------------------

      ..setNavigationDelegate(
        NavigationDelegate(

          onPageStarted: (_) {
            if (mounted) {
              setState(() {
                _isLoading = true;
              });
            }
          },

          onPageFinished: (_) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },

          onWebResourceError: (error) {
            debugPrint(
              '====================================',
            );

            debugPrint(
              'WEBVIEW ERROR',
            );

            debugPrint(
              'Error Code: ${error.errorCode}',
            );

            debugPrint(
              'Description: ${error.description}',
            );

            debugPrint(
              'Error Type: ${error.errorType}',
            );

            debugPrint(
              '====================================',
            );
          },
        ),
      )

    // -----------------------------------------------------------------------
    // LOAD YOUTUBE HTML
    // -----------------------------------------------------------------------

      ..loadHtmlString(
        _buildYouTubeHtml(widget.videoId),

        // IMPORTANT:
        // This baseUrl helps YouTube identify the WebView request.
        //
        // If your applicationId is different, change this value.
        baseUrl: 'https://com.example.nexora',
      );
  }

  // ===========================================================================
  // BUILD YOUTUBE HTML
  // ===========================================================================

  String _buildYouTubeHtml(String videoId) {
    return '''
<!DOCTYPE html>

<html>

<head>

  <meta
    name="viewport"
    content="width=device-width, initial-scale=1.0"
  >

  <meta
    name="referrer"
    content="strict-origin-when-cross-origin"
  >

  <style>

    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }

    html,
    body {
      width: 100%;
      height: 100%;
      background-color: #000000;
      overflow: hidden;
    }

    .video-container {
      position: relative;
      width: 100%;
      height: 100%;
      background-color: #000000;
    }

    iframe {
      position: absolute;

      top: 0;
      left: 0;

      width: 100%;
      height: 100%;

      border: none;
    }

  </style>

</head>

<body>

  <div class="video-container">

    <iframe

      src="https://www.youtube.com/embed/$videoId?autoplay=1&playsinline=1&rel=0&origin=https://com.example.nexora"

      title="YouTube video player"

      frameborder="0"

      allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"

      referrerpolicy="strict-origin-when-cross-origin"

      allowfullscreen>

    </iframe>

  </div>

</body>

</html>
''';
  }

  // ===========================================================================
  // BUILD VIDEO PLAYER SCREEN
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      // -----------------------------------------------------------------------
      // APP BAR
      // -----------------------------------------------------------------------

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,

        title: Text(
          widget.title,

          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),

          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      // -----------------------------------------------------------------------
      // WEBVIEW
      // -----------------------------------------------------------------------

      body: Stack(
        children: [

          WebViewWidget(
            controller: _controller,
          ),

          // ---------------------------------------------------------------
          // LOADING INDICATOR
          // ---------------------------------------------------------------

          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Colors.redAccent,
              ),
            ),
        ],
      ),
    );
  }
}
