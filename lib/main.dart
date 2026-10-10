import 'package:flutter/material.dart';

void main() => runApp(const DougHubApp());

const _background = Color(0xFF090B16);
const _panel = Color(0xFF13172A);
const _purple = Color(0xFF8B7CFF);
const _muted = Color(0xFF9BA3BD);

class DougHubApp extends StatelessWidget {
  const DougHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DougHubApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: _background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _purple,
          brightness: Brightness.dark,
          surface: _panel,
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _panel,
          hintStyle: const TextStyle(color: _muted),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selected = 0;
  String _query = '';

  static const _sections = [
    ('Home', Icons.home_rounded),
    ('Tools', Icons.grid_view_rounded),
    ('Favorites', Icons.star_rounded),
    ('Recent', Icons.history_rounded),
    ('Settings', Icons.settings_rounded),
  ];

  static const _tools = [
    _Tool('Text Tools', 'Format, clean up, and transform text.', Icons.text_fields_rounded, 'Writing'),
    _Tool('Calculator', 'Quick calculations without the clutter.', Icons.calculate_rounded, 'Everyday'),
    _Tool('Unit Converter', 'Convert common units in a few taps.', Icons.swap_horiz_rounded, 'Everyday'),
    _Tool('Color Tools', 'Explore colors and copy color values.', Icons.palette_rounded, 'Design'),
    _Tool('JSON Formatter', 'Make structured text easier to read.', Icons.data_object_rounded, 'Developer'),
    _Tool('Password Generator', 'Create a random password locally.', Icons.key_rounded, 'Security'),
    _Tool('QR Tools', 'A home for useful QR utilities.', Icons.qr_code_rounded, 'Everyday'),
    _Tool('File Helpers', 'Shortcuts for common file tasks.', Icons.folder_open_rounded, 'Files'),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= 760;
    final tools = _tools.where((tool) {
      final q = _query.trim().toLowerCase();
      return q.isEmpty || tool.title.toLowerCase().contains(q) ||
          tool.description.toLowerCase().contains(q) ||
          tool.category.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            if (wide) _buildSidebar(),
            Expanded(
              child: Column(
                children: [
                  _buildTopBar(wide),
                  Expanded(
                    child: _selected == 4
                        ? _buildSettings()
                        : _buildContent(tools, wide),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _selected,
              onDestinationSelected: (index) => setState(() => _selected = index),
              backgroundColor: _panel,
              indicatorColor: _purple.withValues(alpha: .20),
              destinations: _sections.map((item) => NavigationDestination(
                icon: Icon(item.$2),
                label: item.$1,
              )).toList(),
            ),
    );
  }

  Widget _buildSidebar() => Container(
    width: 236,
    decoration: const BoxDecoration(
      color: Color(0xFF0D1020),
      border: Border(right: BorderSide(color: Color(0xFF222741))),
    ),
    padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(children: [
          _BrandMark(),
          SizedBox(width: 10),
          Expanded(child: Text('DougHubApp', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
        ]),
        const SizedBox(height: 32),
        const Text('WORKSPACE', style: TextStyle(color: _muted, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        for (var i = 0; i < _sections.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _NavItem(
              icon: _sections[i].$2,
              label: _sections[i].$1,
              selected: _selected == i,
              onTap: () => setState(() => _selected = i),
            ),
          ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF282D49)),
          ),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.auto_awesome_rounded, color: _purple),
            SizedBox(height: 10),
            Text('Less searching. More doing.', style: TextStyle(fontWeight: FontWeight.w700)),
            SizedBox(height: 5),
            Text('Your handy tools, all in one place.', style: TextStyle(color: _muted, fontSize: 12, height: 1.4)),
          ]),
        ),
      ],
    ),
  );

  Widget _buildTopBar(bool wide) => Padding(
    padding: EdgeInsets.fromLTRB(wide ? 30 : 18, 18, wide ? 30 : 18, 10),
    child: Row(children: [
      if (!wide) const _BrandMark(),
      if (!wide) const SizedBox(width: 10),
      Expanded(child: Text(
        _sections[_selected].$1,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
      )),
      if (wide)
        SizedBox(
          width: 270,
          child: TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: const InputDecoration(
              hintText: 'Search tools…',
              prefixIcon: Icon(Icons.search_rounded),
              isDense: true,
            ),
          ),
        )
      else
        IconButton(
          tooltip: 'Search tools',
          onPressed: _showSearch,
          icon: const Icon(Icons.search_rounded),
        ),
      const SizedBox(width: 8),
      Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: _purple.withValues(alpha: .17),
          borderRadius: BorderRadius.circular(13),
        ),
        child: const Icon(Icons.person_outline_rounded, color: _purple),
      ),
    ]),
  );

  Widget _buildContent(List<_Tool> tools, bool wide) {
    final isTools = _selected == 1;
    final shown = isTools ? tools : tools.take(4).toList();
    return ListView(
      padding: EdgeInsets.fromLTRB(wide ? 30 : 18, 16, wide ? 30 : 18, 30),
      children: [
        if (_selected == 0) ...[
          Container(
            padding: EdgeInsets.all(wide ? 28 : 22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF27234D), Color(0xFF171A32), Color(0xFF14182B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF3A3568)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: _purple.withValues(alpha: .16), borderRadius: BorderRadius.circular(30)),
                child: const Text('YOUR EVERYDAY TOOLKIT', style: TextStyle(color: Color(0xFFD2CCFF), fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 18),
              Text('Everything useful.\nNothing in the way.', style: TextStyle(fontSize: wide ? 34 : 29, height: 1.12, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              const Text('A simpler home for the tools you use most.', style: TextStyle(color: Color(0xFFC0C5DB), height: 1.5)),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => setState(() => _selected = 1),
                icon: const Icon(Icons.grid_view_rounded),
                label: const Text('Explore all tools'),
                style: FilledButton.styleFrom(backgroundColor: _purple, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14)),
              ),
            ]),
          ),
          const SizedBox(height: 28),
          const _SectionHeading(title: 'Quick access', subtitle: 'Jump straight into a useful tool.'),
        ] else if (_selected == 2) ...[
          const _SectionHeading(title: 'Your favorites', subtitle: 'Pin tools here when favorites are implemented.'),
        ] else if (_selected == 3) ...[
          const _SectionHeading(title: 'Recently used', subtitle: 'Your recent tools will appear here as you use the app.'),
        ] else ...[
          const _SectionHeading(title: 'All tools', subtitle: 'Search by name or category. More DougHub tools can be added here.'),
        ],
        if (!wide) ...[
          const SizedBox(height: 14),
          TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: const InputDecoration(
              hintText: 'Search tools…',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
        ],
        const SizedBox(height: 16),
        if (shown.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 35),
            child: Center(child: Text('No tools match that search.', style: TextStyle(color: _muted))),
          )
        else
          LayoutBuilder(builder: (context, constraints) {
            final columns = constraints.maxWidth >= 1000 ? 3 : constraints.maxWidth >= 570 ? 2 : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: shown.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 142,
              ),
              itemBuilder: (context, index) => _ToolCard(tool: shown[index]),
            );
          }),
        if (_selected == 0) ...[
          const SizedBox(height: 28),
          const _SectionHeading(title: 'Designed for your devices', subtitle: 'A layout that adapts instead of squeezing everything together.'),
          const SizedBox(height: 14),
          const _FeatureRow(icon: Icons.touch_app_rounded, title: 'Comfortable on mobile', description: 'Big touch targets and bottom navigation on phones.'),
          const SizedBox(height: 10),
          const _FeatureRow(icon: Icons.tablet_mac_rounded, title: 'Room to breathe on iPad', description: 'More space for tools when the screen is larger.'),
          const SizedBox(height: 10),
          const _FeatureRow(icon: Icons.desktop_windows_rounded, title: 'Made for Windows too', description: 'A desktop sidebar and efficient keyboard-friendly layout.'),
        ],
      ],
    );
  }

  Widget _buildSettings() => ListView(
    padding: const EdgeInsets.all(24),
    children: const [
      _SectionHeading(title: 'Settings', subtitle: 'Personalize your DougHubApp experience.'),
      SizedBox(height: 18),
      _FeatureRow(icon: Icons.palette_outlined, title: 'Appearance', description: 'Dark purple theme is enabled for this starter version.'),
      SizedBox(height: 10),
      _FeatureRow(icon: Icons.devices_outlined, title: 'Device layout', description: 'Navigation adapts automatically to screen width.'),
      SizedBox(height: 10),
      _FeatureRow(icon: Icons.info_outline_rounded, title: 'About DougHubApp', description: 'An independent app project inspired by DougHub tools.'),
    ],
  );

  void _showSearch() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search tools'),
        content: TextField(
          autofocus: true,
          onChanged: (value) => setState(() => _query = value),
          decoration: const InputDecoration(hintText: 'Name or category'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _selected = 1);
            },
            child: const Text('Show tools'),
          ),
        ],
      ),
    );
  }
}

class _Tool {
  final String title;
  final String description;
  final IconData icon;
  final String category;
  const _Tool(this.title, this.description, this.icon, this.category);
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) => Container(
    width: 38,
    height: 38,
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [_purple, Color(0xFFB18CFF)]),
      borderRadius: BorderRadius.circular(13),
    ),
    child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 24),
  );
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _NavItem({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? _purple.withValues(alpha: .17) : Colors.transparent,
    borderRadius: BorderRadius.circular(13),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        child: Row(children: [
          Icon(icon, size: 20, color: selected ? const Color(0xFFCFC8FF) : _muted),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: selected ? Colors.white : _muted, fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
        ]),
      ),
    ),
  );
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionHeading({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
      const SizedBox(height: 5),
      Text(subtitle, style: const TextStyle(color: _muted, height: 1.4)),
    ],
  );
}

class _ToolCard extends StatelessWidget {
  final _Tool tool;
  const _ToolCard({required this.tool});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _panel,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFF252A43)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: _purple.withValues(alpha: .14), borderRadius: BorderRadius.circular(12)),
            child: Icon(tool.icon, color: const Color(0xFFC8C0FF), size: 21),
          ),
          const Spacer(),
          const Icon(Icons.arrow_outward_rounded, color: _muted, size: 17),
        ]),
        const Spacer(),
        Text(tool.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        const SizedBox(height: 4),
        Text(tool.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _muted, fontSize: 12, height: 1.35)),
      ],
    ),
  );
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  const _FeatureRow({required this.icon, required this.title, required this.description});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF252A43))),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: _purple, size: 23),
      const SizedBox(width: 13),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(description, style: const TextStyle(color: _muted, height: 1.4, fontSize: 13)),
      ])),
    ]),
  );
}
