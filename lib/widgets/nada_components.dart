import 'package:flutter/material.dart';
import '../theme/nada_theme.dart';

/// 1. Search Input dengan outline #E6DFD5 dan fokus #2D5A43 (1.5px)
class NadaSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String hintText;

  const NadaSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.hintText = 'Cari instrumen, daerah, atau nada...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(NadaRadius.md)),
        boxShadow: NadaShadows.warmAmbient,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: Theme.of(context).textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: NadaColors.textMuted,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: NadaColors.woodBrown,
            size: 22,
          ),
          filled: true,
          fillColor: NadaColors.surfaceCard,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(NadaRadius.md),
            borderSide: const BorderSide(
              color: NadaColors.surfaceOutline,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(NadaRadius.md),
            borderSide: const BorderSide(
              color: NadaColors.primary,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

/// 2. Filter Chip berbentuk stadium pill
class NadaFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const NadaFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? NadaColors.primary : NadaColors.surfaceCard,
          borderRadius: BorderRadius.circular(NadaRadius.pill),
          border: isSelected
              ? null
              : Border.all(color: NadaColors.surfaceOutline, width: 1),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: isSelected ? Colors.white : NadaColors.textBody,
          ),
        ),
      ),
    );
  }
}

/// 3. Primary & Ghost Action Buttons
class NadaPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  const NadaPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: NadaColors.primary,
        foregroundColor: Colors.white,
        overlayColor: NadaColors.primaryPressed,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NadaRadius.md),
        ),
        textStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontSize: 14,
          color: Colors.white,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: 8),
          ],
          Text(label),
        ],
      ),
    );
  }
}

class NadaGhostButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const NadaGhostButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: NadaColors.primary,
        side: const BorderSide(color: NadaColors.primary, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NadaRadius.md),
        ),
        textStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontSize: 14,
          color: NadaColors.primary,
        ),
      ),
      child: Text(label),
    );
  }
}

/// 4. Audio Playback Pill dengan slider Warm Gold (#D4A373) & waveform
class NadaAudioPlaybackPill extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isPlaying;
  final double progress;
  final VoidCallback onTogglePlay;
  final ValueChanged<double> onSeek;

  const NadaAudioPlaybackPill({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isPlaying,
    required this.progress,
    required this.onTogglePlay,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: NadaColors.surfaceTranslucent,
        borderRadius: BorderRadius.circular(NadaRadius.pill),
        border: Border.all(color: NadaColors.surfaceOutline, width: 1),
        boxShadow: NadaShadows.warmAmbient,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onTogglePlay,
            borderRadius: BorderRadius.circular(NadaRadius.pill),
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: NadaColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3.5,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 12,
                    ),
                    activeTrackColor: NadaColors.tertiaryGold,
                    inactiveTrackColor: NadaColors.surfaceOutline,
                    thumbColor: NadaColors.tertiaryGold,
                  ),
                  child: Slider(
                    value: progress.clamp(0.0, 1.0),
                    onChanged: onSeek,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.graphic_eq_rounded,
            color: NadaColors.tertiaryGold,
            size: 22,
          ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }
}

/// 5. Instrument Card dengan badge wilayah, klasifikasi, dan tombol audio cepat
class NadaInstrumentCard extends StatelessWidget {
  final String name;
  final String region;
  final String classification;
  final String imageUrl;
  final bool isPlayingPreview;
  final VoidCallback onTap;
  final VoidCallback onPlayPreview;

  const NadaInstrumentCard({
    super.key,
    required this.name,
    required this.region,
    required this.classification,
    required this.imageUrl,
    required this.isPlayingPreview,
    required this.onTap,
    required this.onPlayPreview,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: NadaColors.surfaceCard,
          borderRadius: BorderRadius.circular(NadaRadius.card),
          border: Border.all(color: NadaColors.surfaceOutline, width: 1),
          boxShadow: NadaShadows.warmAmbient,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.asset(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: NadaColors.surfaceTranslucent,
                      child: const Icon(
                        Icons.music_note_rounded,
                        color: NadaColors.tertiaryGold,
                        size: 36,
                      ),
                    ),
                  ),
                ),
                // Overlaid regional badge
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(255, 255, 255, 0.92),
                      borderRadius: BorderRadius.circular(NadaRadius.pill),
                      border: Border.all(color: NadaColors.surfaceOutline),
                    ),
                    child: Text(
                      region,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: NadaColors.primary,
                      ),
                    ),
                  ),
                ),
                // Quick-preview sound trigger
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: InkWell(
                    onTap: onPlayPreview,
                    borderRadius: BorderRadius.circular(NadaRadius.pill),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: isPlayingPreview
                            ? NadaColors.tertiaryGold
                            : NadaColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: NadaShadows.warmAmbient,
                      ),
                      child: Icon(
                        isPlayingPreview
                            ? Icons.pause_rounded
                            : Icons.volume_up_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    classification.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
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

/// Menampilkan gambar dari asset lokal, atau dari URL kalau diawali http
class NadaImage extends StatelessWidget {
  final String path;
  final BoxFit fit;

  const NadaImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      color: NadaColors.surfaceTranslucent,
      child: const Icon(
        Icons.music_note_rounded,
        color: NadaColors.tertiaryGold,
        size: 32,
      ),
    );

    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => fallback,
      );
    }
    return Image.asset(
      path,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }
}