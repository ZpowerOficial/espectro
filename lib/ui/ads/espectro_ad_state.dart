/// Estado de preenchimento de um slot de publicidade Web (AdSense) ou Nativo (AdMob).
enum EspectroAdSlotStatus {
  /// Aguardando resposta assíncrona do provedor.
  loading,

  /// Anúncio efetivamente entregue e visível (`data-ad-status="filled"` / `onAdLoaded`).
  filled,

  /// Estado oficial do AdSense quando a otimização mantém controle próprio sobre o slot
  /// (`data-ad-status="unfill-optimized"`). Nunca deve receber `display: none` forçado.
  unfillOptimized,

  /// Slot sem preenchimento confirmado (`data-ad-status="unfilled"` / `onAdFailedToLoad`).
  /// Deve recolher completamente a `0 px`, inclusive o contêiner Flutter.
  unfilled,

  /// Rede indisponível, script bloqueado ou tempo limite atingido sem entrega.
  /// Recolhe a `0 px` sem exibir placeholders nem criativos próprios.
  unavailable,
}

typedef WebAdStatusCallback =
    void Function(EspectroAdSlotStatus status, double observedHeight);

/// Converte o atributo `data-ad-status` oficial do Google AdSense no estado tipado.
EspectroAdSlotStatus parseWebAdStatus(String? rawStatus) {
  switch (rawStatus?.trim().toLowerCase()) {
    case 'filled':
      return EspectroAdSlotStatus.filled;
    case 'unfilled':
      return EspectroAdSlotStatus.unfilled;
    case 'unfill-optimized':
      return EspectroAdSlotStatus.unfillOptimized;
    default:
      return EspectroAdSlotStatus.loading;
  }
}
