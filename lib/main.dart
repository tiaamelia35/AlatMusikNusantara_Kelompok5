import 'package:flutter/material.dart';
import 'theme/nada_theme.dart';
import 'widgets/nada_components.dart';

void main() {
  runApp(const NadaNusantaraApp());
}

class NadaNusantaraApp extends StatelessWidget {
  const NadaNusantaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nada Nusantara',
      debugShowCheckedModeBanner: false,
      theme: NadaTheme.light(),
      home: const NadaMainScaffold(),
    );
  }
}

class InstrumentItem {
  final String name;
  final String region;
  final String originDetail;
  final String classification;
  final String description;
  final String imageUrl;

  const InstrumentItem({
    required this.name,
    required this.region,
    required this.originDetail,
    required this.classification,
    required this.description,
    required this.imageUrl,
  });
}

class NadaMainScaffold extends StatefulWidget {
  const NadaMainScaffold({super.key});

  @override
  State<NadaMainScaffold> createState() => _NadaMainScaffoldState();
}

class _NadaMainScaffoldState extends State<NadaMainScaffold> {
  int _navIndex = 0;
  int _selectedFilterIndex = 0;
  String? _playingInstrumentName;
  bool _isMainAudioPlaying = false;
  double _audioProgress = 0.35;

  final List<String> _filters = const [
    'Semua',
    'Idiofon',
    'Kordofon',
    'Membranofon',
    'Aerofon',
  ];

  final List<InstrumentItem> _instruments = const [
    InstrumentItem(
      name: 'Angklung',
      region: 'Sunda',
      originDetail: 'KABUPATEN GARUT • JAWA BARAT',
      classification: 'Idiofon',
      description:
      'Instrumen bambu bernada ganda yang beresonansi melalui getaran tabung ketika digoyangkan secara ritmis.',
      imageUrl: 'https://picsum.photos/seed/angklung/600/450',
    ),
    InstrumentItem(
      name: 'Sasando',
      region: 'Rote',
      originDetail: 'KABUPATEN ROTE NDAO • NTT',
      classification: 'Kordofon',
      description:
      'Harpa petik tradisional dengan resonator daun lontar yang menghasilkan gema akustik lembut dan jernih.',
      imageUrl: 'https://picsum.photos/seed/sasando/600/450',
    ),
    InstrumentItem(
      name: 'Gamelan Gong',
      region: 'Jawa',
      originDetail: 'SURAKARTA • JAWA TENGAH',
      classification: 'Idiofon',
      description:
      'Perunggu tempaan tangan yang menyelaraskan laras pelog dan slendro dalam ansambel keraton.',
      imageUrl: 'https://picsum.photos/seed/gamelan/600/450',
    ),
    InstrumentItem(
      name: 'Tifa',
      region: 'Papua',
      originDetail: 'ASMAT • PAPUA SELATAN',
      classification: 'Membranofon',
      description:
      'Tabuh kayu berukir dengan membran kulit biawak yang menjadi penanda ritme upacara adat.',
      imageUrl: 'https://picsum.photos/seed/tifa/600/450',
    ),
  ];

  void _openInstrumentDetail(InstrumentItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: NadaColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(NadaRadius.sheetTop),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              NadaSpacing.pageMargin,
              14,
              NadaSpacing.pageMargin,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: NadaColors.surfaceOutline,
                      borderRadius: BorderRadius.circular(NadaRadius.pill),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  item.originDetail,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  item.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: NadaPrimaryButton(
                        label: 'Putar Rekaman',
                        icon: Icons.play_arrow_rounded,
                        onPressed: () {
                          setState(() {
                            _playingInstrumentName = item.name;
                            _isMainAudioPlaying = true;
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    NadaGhostButton(
                      label: 'Simpan',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = _filters[_selectedFilterIndex];
    final filteredInstruments = selectedCategory == 'Semua'
        ? _instruments
        : _instruments
        .where((item) => item.classification == selectedCategory)
        .toList();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header & Editorial Title
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                NadaSpacing.pageMargin,
                NadaSpacing.lg,
                NadaSpacing.pageMargin,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ARSIP ETNOMUSIKOLOGI NUSANTARA',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Nada Nusantara',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    const SizedBox(height: 20),
                    const NadaSearchBar(),
                  ],
                ),
              ),
            ),

            // Filter Chips
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: NadaSpacing.md),
                child: SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: NadaSpacing.pageMargin,
                    ),
                    itemCount: _filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      return NadaFilterChip(
                        label: _filters[index],
                        isSelected: _selectedFilterIndex == index,
                        onTap: () =>
                            setState(() => _selectedFilterIndex = index),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Section Break (36px) + Audio Playback Hub
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                NadaSpacing.pageMargin,
                NadaSpacing.sectionBreak,
                NadaSpacing.pageMargin,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sorotan Akustik',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    NadaAudioPlaybackPill(
                      title: _playingInstrumentName ?? 'Sasando — Laras Lontar',
                      subtitle: '01:24 / 03:45',
                      isPlaying: _isMainAudioPlaying,
                      progress: _audioProgress,
                      onTogglePlay: () => setState(
                            () => _isMainAudioPlaying = !_isMainAudioPlaying,
                      ),
                      onSeek: (val) => setState(() => _audioProgress = val),
                    ),
                  ],
                ),
              ),
            ),

            // Section Break (36px) + 2-Column Instrument Grid
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                NadaSpacing.pageMargin,
                NadaSpacing.sectionBreak,
                NadaSpacing.pageMargin,
                16,
              ),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Katalog Instrumen',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      '${filteredInstruments.length} Koleksi',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: NadaColors.woodBrown,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                NadaSpacing.pageMargin,
                0,
                NadaSpacing.pageMargin,
                NadaSpacing.sectionBreak,
              ),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: NadaSpacing.md,
                  crossAxisSpacing: NadaSpacing.md,
                  childAspectRatio: 0.80,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final item = filteredInstruments[index];
                    final isPreviewing = _playingInstrumentName == item.name &&
                        _isMainAudioPlaying;
                    return NadaInstrumentCard(
                      name: item.name,
                      region: item.region,
                      classification: item.classification,
                      imageUrl: item.imageUrl,
                      isPlayingPreview: isPreviewing,
                      onTap: () => _openInstrumentDetail(item),
                      onPlayPreview: () {
                        setState(() {
                          if (isPreviewing) {
                            _isMainAudioPlaying = false;
                          } else {
                            _playingInstrumentName = item.name;
                            _isMainAudioPlaying = true;
                          }
                        });
                      },
                    );
                  },
                  childCount: filteredInstruments.length,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: NadaColors.surfaceOutline, width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _navIndex,
          backgroundColor: NadaColors.surfaceCard,
          indicatorColor: NadaColors.primarySoft,
          elevation: 0,
          onDestinationSelected: (index) => setState(() => _navIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: NadaColors.textBody),
              selectedIcon: Icon(Icons.home_rounded, color: NadaColors.primary),
              label: 'Beranda',
            ),
            NavigationDestination(
              icon: Icon(Icons.grid_view_outlined, color: NadaColors.textBody),
              selectedIcon:
              Icon(Icons.grid_view_rounded, color: NadaColors.primary),
              label: 'Katalog',
            ),
            NavigationDestination(
              icon: Icon(Icons.map_outlined, color: NadaColors.textBody),
              selectedIcon: Icon(Icons.map_rounded, color: NadaColors.primary),
              label: 'Peta Suara',
            ),
            NavigationDestination(
              icon: Icon(Icons.bookmark_border_rounded,
                  color: NadaColors.textBody),
              selectedIcon:
              Icon(Icons.bookmark_rounded, color: NadaColors.primary),
              label: 'Koleksi',
            ),
          ],
        ),
      ),
    );
  }
}