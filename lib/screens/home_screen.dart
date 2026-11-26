import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../models/instrument_model.dart';
import '../theme/nada_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  String _selectedFilter = 'Semua';
  bool _isSortedAlphabetically = false;

  // Audio Player instance & state
  final AudioPlayer _audioPlayer = AudioPlayer();
  InstrumentModel? _playingInstrument;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Timer? _fallbackTimer;

  late List<InstrumentModel> _allInstruments;

  @override
  void initState() {
    super.initState();
    _allInstruments = List.from(DummyData.instruments);
    _initAudioListeners();
  }

  void _initAudioListeners() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((pos) {
      if (mounted) {
        setState(() {
          _position = pos;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((dur) {
      if (mounted) {
        setState(() {
          _duration = dur;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
        _fallbackTimer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playOrPauseInstrument(InstrumentModel instrument) async {
    if (_playingInstrument?.id == instrument.id) {
      if (_isPlaying) {
        await _audioPlayer.pause();
        setState(() {
          _isPlaying = false;
        });
        _fallbackTimer?.cancel();
      } else {
        await _audioPlayer.resume();
        setState(() {
          _isPlaying = true;
        });
        _startFallbackTimer();
      }
    } else {
      await _audioPlayer.stop();
      _fallbackTimer?.cancel();

      setState(() {
        _playingInstrument = instrument;
        _isPlaying = true;
        _position = Duration.zero;
        _duration = const Duration(seconds: 30);
      });

      _startFallbackTimer();

      try {
        final url = instrument.audioUrl;
        if (url.startsWith('http')) {
          await _audioPlayer.play(UrlSource(url));
        } else if (url.startsWith('assets/')) {
          await _audioPlayer.play(AssetSource(url.replaceFirst('assets/', '')));
        } else {
          await _audioPlayer.play(UrlSource(url));
        }
      } catch (e) {
        debugPrint('Audio stream notice: $e');
      }
    }
  }

  void _startFallbackTimer() {
    _fallbackTimer?.cancel();
    _fallbackTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || !_isPlaying) {
        timer.cancel();
        return;
      }
      setState(() {
        final nextSec = _position.inSeconds + 1;
        if (nextSec >= _duration.inSeconds) {
          _position = Duration.zero;
          _isPlaying = false;
          timer.cancel();
        } else {
          _position = Duration(seconds: nextSec);
        }
      });
    });
  }

  Future<void> _stopAudio() async {
    _fallbackTimer?.cancel();
    await _audioPlayer.stop();
    setState(() {
      _playingInstrument = null;
      _isPlaying = false;
      _position = Duration.zero;
    });
  }

  List<InstrumentModel> get _filteredInstruments {
    List<InstrumentModel> result = _allInstruments.where((item) {
      if (_selectedFilter == 'Semua') return true;
      return item.organologyType.toLowerCase() == _selectedFilter.toLowerCase() ||
          item.category.toLowerCase().contains(_selectedFilter.toLowerCase());
    }).toList();

    if (_isSortedAlphabetically) {
      result.sort((a, b) => a.name.compareTo(b.name));
    }

    return result;
  }

  void _toggleFavorite(InstrumentModel item) {
    setState(() {
      item.isFavorite = !item.isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NadaColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    // 1. Top App Header
                    _buildTopHeader(context),

                    const SizedBox(height: 16),
                    // 2. User Greeting Section
                    _buildUserGreeting(context),

                    const SizedBox(height: 16),
                    // 3. Etnomusikologi Banner Card
                    _buildEtnomusikologiBanner(context),

                    const SizedBox(height: 24),
                    // 4. Instrumen Unggulan Minggu Ini (Featured Sasando)
                    _buildFeaturedSection(context),

                    const SizedBox(height: 28),
                    // 5. Klasifikasi Organologi (2x2 Grid)
                    _buildOrganologySection(context),

                    const SizedBox(height: 28),
                    // 6. Katalog Nusantara List
                    _buildKatalogNusantaraSection(context),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            // Floating Mini Audio Player Bar (if playing an instrument)
            if (_playingInstrument != null) _buildMiniAudioPlayerBar(context),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  /// 1. Top App Header: Logo + App Name + Notification Bell + Profile Avatar
  Widget _buildTopHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: NadaSpacing.pageMargin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo + Title
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: NadaColors.primary,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: NadaColors.primary.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.graphic_eq_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nada Nusantara',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          height: 1.1,
                          color: NadaColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Utama',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 11,
                          color: NadaColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ],
          ),
          // Actions: Notification + Avatar
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: NadaColors.surfaceOutline, width: 1),
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      color: NadaColors.textPrimary,
                      size: 22,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: NadaColors.tertiaryGold, width: 2),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 2. User Greeting + 15 Koleksi Badge
  Widget _buildUserGreeting(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: NadaSpacing.pageMargin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Halo, Arga Pradipta',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: NadaColors.textPrimary,
                          ),
                    ),
                    const SizedBox(width: 6),
                    const Text('👋', style: TextStyle(fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Jelajah Warisan Budaya Indonesia',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: NadaColors.textMuted,
                        fontSize: 13,
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: NadaColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(NadaRadius.pill),
              border: Border.all(
                color: NadaColors.primary.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.library_music_rounded,
                  size: 13,
                  color: NadaColors.primary,
                ),
                const SizedBox(width: 5),
                Text(
                  '15 KOLEKSI',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: NadaColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Etnomusikologi Banner Card
  Widget _buildEtnomusikologiBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: NadaSpacing.pageMargin),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF1E3F30),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E3F30).withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -25,
              bottom: -25,
              child: Icon(
                Icons.star_outline_rounded,
                size: 180,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
            Positioned(
              right: 15,
              bottom: 15,
              child: Icon(
                Icons.star_rounded,
                size: 70,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(NadaRadius.pill),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.grid_view_rounded,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'ARSIP ETNOMUSIKOLOGI',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Kenali Kekayaan Musik\nNusantara',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Eksplorasi ragam instrumen musik tradisional dari Sabang sampai Merauke lengkap dengan rekaman audio, sejarah, dan karakteristik unik.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFFD0E1D4),
                          fontSize: 12.5,
                          height: 1.45,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      SizedBox(
                        width: 76,
                        height: 28,
                        child: Stack(
                          children: [
                            _buildMiniAvatarCircle('NT', const Color(0xFFD4A373), 0),
                            _buildMiniAvatarCircle('JA', const Color(0xFF2D5A43), 20),
                            _buildMiniAvatarCircle('WA', const Color(0xFF3B82F6), 40),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '38 Provinsi Terpetakan',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniAvatarCircle(String label, Color bg, double leftOffset) {
    return Positioned(
      left: leftOffset,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF1E3F30), width: 2),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  /// 4. Instrumen Unggulan Minggu Ini (Featured Sasando Card)
  Widget _buildFeaturedSection(BuildContext context) {
    final sasando = _allInstruments.firstWhere(
      (item) => item.id == '2',
      orElse: () => _allInstruments.first,
    );

    final isSasandoActive = _playingInstrument?.id == sasando.id;
    final isSasandoPlayingNow = isSasandoActive && _isPlaying;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: NadaSpacing.pageMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.stars_rounded,
                    color: NadaColors.woodBrown,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Instrumen Unggulan Minggu Ini',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: NadaColors.textPrimary,
                        ),
                  ),
                ],
              ),
              Text(
                'Sorotan Utama',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: NadaColors.woodBrown,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: NadaColors.surfaceOutline, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: InstrumentImageView(
                          imageUrl: sasando.imageUrl,
                          instrumentName: sasando.name,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.3),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.6),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD48B38),
                              borderRadius:
                                  BorderRadius.circular(NadaRadius.pill),
                            ),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.local_fire_department_rounded,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Populer',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius:
                                  BorderRadius.circular(NadaRadius.pill),
                            ),
                            child: const Text(
                              'Kordofon',
                              style: TextStyle(
                                color: NadaColors.textPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => _toggleFavorite(sasando),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            sasando.isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: sasando.isFavorite
                                ? Colors.redAccent
                                : NadaColors.textMuted,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Row(
                        children: const [
                          Icon(
                            Icons.location_on_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Rote Ndao, Nusa Tenggara Timur',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sasando.name,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: NadaColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        sasando.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 13,
                              color: NadaColors.textBody,
                              height: 1.45,
                            ),
                      ),
                      const SizedBox(height: 16),
                      // Audio Player Pill
                      GestureDetector(
                        onTap: () => _playOrPauseInstrument(sasando),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSasandoPlayingNow
                                ? const Color(0xFFEBF5EE)
                                : const Color(0xFFF7F5F0),
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: isSasandoPlayingNow
                                  ? NadaColors.primary
                                  : NadaColors.surfaceOutline,
                              width: isSasandoPlayingNow ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: const BoxDecoration(
                                  color: NadaColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isSasandoPlayingNow
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sasando.audioTitle,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: NadaColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      isSasandoActive && _duration.inSeconds > 0
                                          ? '${_formatDuration(_position)} / ${_formatDuration(_duration)} • ${sasando.province}'
                                          : sasando.audioSubtitle,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isSasandoPlayingNow
                                            ? NadaColors.primary
                                            : NadaColors.textMuted,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.graphic_eq_rounded,
                                color: isSasandoPlayingNow
                                    ? NadaColors.primary
                                    : NadaColors.tertiaryGold,
                                size: 24,
                              ),
                              const SizedBox(width: 4),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 5. Klasifikasi Organologi (2x2 Grid)
  Widget _buildOrganologySection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: NadaSpacing.pageMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Klasifikasi Organologi',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: NadaColors.textPrimary,
                    ),
              ),
              Text(
                '4 Kategori',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: NadaColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: DummyData.organologyCategories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.35,
            ),
            itemBuilder: (context, index) {
              final item = DummyData.organologyCategories[index];
              return _buildOrganologyCard(context, item);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrganologyCard(BuildContext context, OrganologyCategory category) {
    IconData getIcon() {
      switch (category.iconType) {
        case 'idiofon':
          return Icons.graphic_eq_rounded;
        case 'membranofon':
          return Icons.adjust_rounded;
        case 'kordofon':
          return Icons.music_note_rounded;
        case 'aerofon':
          return Icons.air_rounded;
        default:
          return Icons.music_note_rounded;
      }
    }

    final isSelected = _selectedFilter == category.title;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (_selectedFilter == category.title) {
            _selectedFilter = 'Semua';
          } else {
            _selectedFilter = category.title;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF3FAF5) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? NadaColors.primary : NadaColors.surfaceOutline,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Color(category.bgHex),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                getIcon(),
                color: Color(category.colorHex),
                size: 18,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.title,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? NadaColors.primary : NadaColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  category.subtitle,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: NadaColors.textMuted,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    category.examples,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: NadaColors.textMuted,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 14,
                  color: isSelected ? NadaColors.primary : NadaColors.textMuted,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 6. Katalog Nusantara Section
  Widget _buildKatalogNusantaraSection(BuildContext context) {
    final list = _filteredInstruments;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: NadaSpacing.pageMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Katalog Nusantara',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: NadaColors.textPrimary,
                            ),
                      ),
                      if (_selectedFilter != 'Semua') ...[
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedFilter = 'Semua';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: NadaColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  _selectedFilter,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: NadaColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                const Icon(
                                  Icons.close_rounded,
                                  size: 10,
                                  color: NadaColors.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Menampilkan ${list.length} instrumen terpilih',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: NadaColors.textMuted,
                          fontSize: 11.5,
                        ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isSortedAlphabetically = !_isSortedAlphabetically;
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(NadaRadius.pill),
                    border: Border.all(
                      color: _isSortedAlphabetically
                          ? NadaColors.primary
                          : NadaColors.surfaceOutline,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.swap_vert_rounded,
                        size: 14,
                        color: _isSortedAlphabetically
                            ? NadaColors.primary
                            : NadaColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Urut Abjad',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _isSortedAlphabetically
                              ? NadaColors.primary
                              : NadaColors.textBody,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final instrument = list[index];
              return _buildKatalogItemCard(context, instrument);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildKatalogItemCard(BuildContext context, InstrumentModel item) {
    final isPlayingThis = _playingInstrument?.id == item.id && _isPlaying;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPlayingThis ? NadaColors.primary : NadaColors.surfaceOutline,
          width: isPlayingThis ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 82,
                  height: 82,
                  child: InstrumentImageView(
                    imageUrl: item.imageUrl,
                    instrumentName: item.name,
                    width: 82,
                    height: 82,
                  ),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.remove_red_eye_rounded,
                        size: 9,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${item.viewCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.category.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: NadaColors.textMuted,
                        letterSpacing: 0.4,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: NadaColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 12,
                      color: NadaColors.woodBrown,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        item.province,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: NadaColors.woodBrown,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: NadaColors.textBody,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => _toggleFavorite(item),
                child: Padding(
                  padding: const EdgeInsets.only(top: 2, right: 2),
                  child: Icon(
                    item.isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: item.isFavorite
                        ? Colors.redAccent
                        : NadaColors.textMuted.withValues(alpha: 0.6),
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              // Tombol Dengar / Putar Musik
              GestureDetector(
                onTap: () => _playOrPauseInstrument(item),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isPlayingThis
                        ? NadaColors.primary
                        : const Color(0xFFD1E7DD),
                    borderRadius: BorderRadius.circular(NadaRadius.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPlayingThis
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 13,
                        color: isPlayingThis
                            ? Colors.white
                            : NadaColors.primaryDeep,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        isPlayingThis ? 'Jeda' : 'Dengar',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isPlayingThis
                              ? Colors.white
                              : NadaColors.primaryDeep,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Floating Mini Audio Player Bar (Pemutar Musik Melayang Saat Lagu Diputar)
  Widget _buildMiniAudioPlayerBar(BuildContext context) {
    final instrument = _playingInstrument!;
    final double progressRatio = (_duration.inSeconds > 0)
        ? (_position.inSeconds / _duration.inSeconds).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: NadaColors.primaryDeep,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: InstrumentImageView(
                    imageUrl: instrument.imageUrl,
                    instrumentName: instrument.name,
                    width: 40,
                    height: 40,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      instrument.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_formatDuration(_position)} / ${_formatDuration(_duration)} • ${instrument.province}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFD0E1D4),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              // Play/Pause button
              GestureDetector(
                onTap: () => _playOrPauseInstrument(instrument),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: NadaColors.tertiaryGold,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Close button
              GestureDetector(
                onTap: _stopAudio,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.white70,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Live progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressRatio,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(NadaColors.tertiaryGold),
              minHeight: 3,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  /// 7. Bottom Navigation Bar
  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: NadaColors.surfaceOutline, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: NadaColors.primary,
        unselectedItemColor: NadaColors.textMuted,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Utama',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            activeIcon: Icon(Icons.search_rounded),
            label: 'Cari',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_outline_rounded),
            activeIcon: Icon(Icons.bookmark_rounded),
            label: 'Favorit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

/// Helper Widget untuk Menampilkan Gambar (Support URL & Asset Lokal)
class InstrumentImageView extends StatelessWidget {
  final String imageUrl;
  final String instrumentName;
  final double? width;
  final double? height;
  final BoxFit fit;

  const InstrumentImageView({
    super.key,
    required this.imageUrl,
    required this.instrumentName,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (!imageUrl.startsWith('http')) {
      return Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildFallback(context),
      );
    }

    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _buildFallback(context),
    );
  }

  Widget _buildFallback(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF4EFE6),
            Color(0xFFE5D5C0),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.music_note_rounded,
              color: NadaColors.tertiaryGold,
              size: 26,
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                instrumentName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: NadaColors.primaryDeep,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
