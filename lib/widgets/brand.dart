import 'package:material_ui/material_ui.dart';

import '../models/protocol.dart';
import '../theme.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.pine,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(Icons.add_rounded, color: Colors.white, size: size * 0.62),
    );
  }
}

class RiskBadge extends StatelessWidget {
  const RiskBadge({super.key, required this.risk, this.large = false});

  final Risk risk;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 10 : 8,
        vertical: large ? 4 : 3,
      ),
      decoration: BoxDecoration(
        color: risk.color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        risk.code,
        style: TextStyle(
          color: Colors.white,
          fontSize: large ? 12 : 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(), style: eyebrow);
  }
}
