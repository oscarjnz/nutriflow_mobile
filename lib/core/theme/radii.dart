/// Radius scale for the mobile "Sophisticated Playful" pass.
///
/// The web app uses a single flat radius (rounded-[1.5rem] = 24px) on every
/// card regardless of size or importance. Mobile introduces a real
/// hierarchy - larger radii on the surfaces that should feel like the
/// screen's anchor (hero/summary cards), smaller on nested/list content -
/// so scale itself communicates importance. This is mobile-only for now;
/// nothing here requires a change to the web tokens.
class NutriFlowRadii {
  const NutriFlowRadii._();

  /// Hero/primary surface per screen (today's summary, the active meal plan).
  static const double hero = 32;

  /// Standard card (list container, dialog).
  static const double card = 24;

  /// Nested item inside a card (a bento metric tile, a list row).
  static const double nested = 20;

  /// Small tile (icon holder, inactive selector item).
  static const double tile = 16;

  /// Inputs, standard buttons.
  static const double control = 12;

  /// Chips, pills, the floating nav bar itself.
  static const double full = 999;
}
