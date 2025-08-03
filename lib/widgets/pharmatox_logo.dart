import 'package:flutter/material.dart';

class PharmatoxLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final bool isWhite;
  final bool showText;
  
  const PharmatoxLogo({
    Key? key,
    this.width,
    this.height,
    this.isWhite = false,
    this.showText = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo Resmi - Sadece logo, gradient yok
        SizedBox(
          width: width ?? 100,
          height: height ?? 100,
          child: Image.asset(
            isWhite 
              ? 'assets/images/logo_white.png'
              : 'assets/images/logo.png',
            width: width ?? 100,
            height: height ?? 100,
            fit: BoxFit.contain, // contain kullan ki logo bozulmasın
            // Fallback icon eğer logo bulunamazsa - sadece basit ikon
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.local_pharmacy,
                size: width ?? 100,
                color: isWhite ? Colors.white : const Color(0xFF4A90A4),
              );
            },
          ),
        ),
        
        // Logo Yazısı
        if (showText) ...[
          const SizedBox(height: 8),
          Text(
            'Pharmatox',
            style: TextStyle(
              fontSize: (width ?? 100) * 0.2,
              fontWeight: FontWeight.bold,
              color: isWhite ? Colors.white : const Color(0xFF4A90A4),
            ),
          ),
        ],
      ],
    );
  }
}

// Sadece ikon için küçük widget
class PharmatoxIcon extends StatelessWidget {
  final double size;
  final Color? color;
  
  const PharmatoxIcon({
    Key? key,
    this.size = 24,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/images/icon.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.local_pharmacy,
            size: size,
            color: color ?? const Color(0xFF4A90A4),
          );
        },
      ),
    );
  }
}
