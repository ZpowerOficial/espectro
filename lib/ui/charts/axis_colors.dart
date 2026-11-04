import 'package:flutter/material.dart';

/// Identidade dos polos, espelhada do catálogo twelve_axes.json.
abstract final class AxisColors {
  static const pairs = <String, (Color, Color)>{
    'estrutura': (Color(0xFF2F6DC0), Color(0xFFCF5A22)),
    'representacao': (Color(0xFF12907F), Color(0xFFB02556)),
    'poder': (Color(0xFF3C5A80), Color(0xFFAD7A06)),
    'imigracao': (Color(0xFFCC3456), Color(0xFF6A45C0)),
    'diplomacia': (Color(0xFF6A8425), Color(0xFF2D86C8)),
    'intervencao': (Color(0xFF3F8E5C), Color(0xFFB94A16)),
    'economia': (Color(0xFFD43A28), Color(0xFF8E6516)),
    'controle': (Color(0xFF8A3AA0), Color(0xFF1A8A56)),
    'comercio': (Color(0xFF9C5E2A), Color(0xFF0E86B0)),
    'religiao': (Color(0xFFC65E0E), Color(0xFF3B50B5)),
    'moral': (Color(0xFFD23E84), Color(0xFF74502C)),
    'tecnologia': (Color(0xFF5376B0), Color(0xFF4E9020)),
  };
}
