import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const bg = Color(0xFF090B16), panel = Color(0xFF13172A), purple = Color(0xFF8B7CFF), muted = Color(0xFF9BA3BD);
const supabaseUrl = 'https://tolvtmuolnzhkegphevw.supabase.co';
const supabaseKey = 'sb_publishable_nj7z92WGz6tu9KcWWX97CQ_r0Yv7BD3';
final db = Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseKey);
  runApp(const DougHubApp());
}

class DougHubApp extends StatelessWidget {
  const DougHubApp({super.key});
  @override Widget build(BuildContext context) => MaterialApp(
    title: 'DougHubApp', debugShowCheckedModeBanner: false,
    theme: ThemeData(brightness: Brightness.dark, scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(seedColor: purple, brightness: Brightness.dark, surface: panel),
      useMaterial3: true, inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: panel,
        hintStyle: const TextStyle(color: muted), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))),
    home: const AuthGate());
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override Widget build(BuildContext context) => StreamBuilder<AuthState>(
    stream: db.auth.onAuthStateChange,
    builder: (_, __) => db.auth.currentUser == null ? const SignInPage() : const HomeShell());
}

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});
  @override State<SignInPage> createState() => _SignInPageState();
}
class _SignInPageState extends State<SignInPage> {
  final email = TextEditingController(), password = TextEditingController(), displayName = TextEditingController();
  bool signup = false, busy = false;
  String message = '';
  Future<void> submit() async {
    setState(() { busy = true; message = ''; });
    try {
      if (signup) {
        final result = await db.auth.signUp(email: email.text.trim(), password: password.text,
          data: {'display_name': displayName.text.trim().isEmpty ? email.text.trim().split('@').first : displayName.text.trim()});
        if (result.session == null && mounted) setState(() => message = 'Account created. Check your email if confirmation is required, then sign in.');
      } else {
        await db.auth.signInWithPassword(email: email.text.trim(), password: password.text);
      }
    } on AuthException catch (e) { if (mounted) setState(() => message = e.message); }
    catch (_) { if (mounted) setState(() => message = 'Connection failed. Check your internet and Supabase Auth settings.'); }
    finally { if (mounted) setState(() => busy = false); }
  }
  @override Widget build(BuildContext context) => Scaffold(body: Center(child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 460), child: SingleChildScrollView(padding: const EdgeInsets.all(24),
      child: Card(color: panel, child: Padding(padding: const EdgeInsets.all(26), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const BrandMark(), const SizedBox(height: 18), const Text('Welcome to DougHubApp', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8), const Text('Your tools, study space, and conversations in one place.', style: TextStyle(color: muted)),
        const SizedBox(height: 24),
        if (signup) ...[TextField(controller: displayName, decoration: const InputDecoration(labelText: 'Display name')), const SizedBox(height: 12)],
        TextField(controller: email, keyboardType: TextInputType.emailAddress, autofillHints: const [AutofillHints.email], decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline))),
        const SizedBox(height: 12), TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline))),
        if (message.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 12), child: Text(message, style: const TextStyle(color: Color(0xFFFFC18B)))),
        const SizedBox(height: 18), FilledButton(onPressed: busy ? null : submit, style: FilledButton.styleFrom(backgroundColor: purple, padding: const EdgeInsets.all(15)), child: Text(busy ? 'Please wait…' : signup ? 'Create account' : 'Sign in')),
        TextButton(onPressed: busy ? null : () => setState(() { signup = !signup; message = ''; }), child: Text(signup ? 'Already have an account? Sign in' : 'New here? Create an account'))
      ])))))));
  }
}

class ToolInfo {
  final String title, description, category;
  final IconData icon;
  const ToolInfo(this.title, this.description, this.icon, this.category);
}
const tools = [
  ToolInfo('Calculator', 'Quick arithmetic', Icons.calculate_rounded, 'Everyday'),
  ToolInfo('Unit Converter', 'Convert inches, pounds, and temperatures', Icons.swap_horiz_rounded, 'Everyday'),
  ToolInfo('Text Tools', 'Change case and clean up text', Icons.text_fields_rounded, 'Writing'),
  ToolInfo('JSON Formatter', 'Validate and format JSON', Icons.data_object_rounded, 'Developer'),
  ToolInfo('Password Generator', 'Generate a password locally', Icons.key_rounded, 'Security'),
  ToolInfo('Color Tools', 'Preview and copy a hex color', Icons.palette_rounded, 'Design'),
];
const navTitles = ['Home', 'Tools', 'Study AI', 'Chat', 'Favorites', 'Recent', 'Account', 'Settings'];
const navIcons = [Icons.home_rounded, Icons.grid_view_rounded, Icons.auto_awesome_rounded, Icons.forum_rounded, Icons.star_rounded, Icons.history_rounded, Icons.person_rounded, Icons.settings_rounded];

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override State<HomeShell> createState() => _HomeShellState();
}
class _HomeShellState extends State<HomeShell> {
  int selected = 0;
  String search = '';
  final favorites = <String>{};
  final recent = <String>[];
  void openTool(ToolInfo tool) {
    setState(() { selected = 1; recent.remove(tool.title); recent.insert(0, tool.title); if (recent.length > 12) recent.removeLast(); });
    Navigator.push(context, MaterialPageRoute(builder: (_) => ToolPage(tool: tool)));
  }
  @override Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 850;
    return Scaffold(body: SafeArea(child: Row(children: [
      if (wide) Container(width: 238, padding: const EdgeInsets.all(16), color: const Color(0xFF0D1020), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [BrandMark(), SizedBox(width: 10), Text('DougHubApp', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18))]),
        const SizedBox(height: 28), const Text('WORKSPACE', style: TextStyle(color: muted, letterSpacing: 1.5, fontSize: 11)), const SizedBox(height: 12),
        for (int i = 0; i < navTitles.length; i++) Padding(padding: const EdgeInsets.only(bottom: 5), child: NavItem(title: navTitles[i], icon: navIcons[i], active: selected == i, onTap: () => setState(() => selected = i))),
        const Spacer(), const FeatureCard(icon: Icons.devices_rounded, title: 'Fits your screen', text: 'Comfortable on phone, tablet, and desktop.')
      ])),
      Expanded(child: Column(children: [
        Padding(padding: EdgeInsets.fromLTRB(wide ? 26 : 14, 14, wide ? 26 : 14, 10), child: Row(children: [
          if (!wide) const BrandMark(), if (!wide) const SizedBox(width: 10),
          Expanded(child: Text(navTitles[selected], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800))),
          if (selected == 0 || selected == 1) SizedBox(width: wide ? 250 : 42, child: wide
            ? TextField(onChanged: (v) => setState(() => search = v), decoration: const InputDecoration(hintText: 'Search tools…', prefixIcon: Icon(Icons.search), isDense: true))
            : IconButton(onPressed: () => showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Search tools'), content: TextField(autofocus: true, onChanged: (v) => setState(() => search = v)), actions: [TextButton(onPressed: () { Navigator.pop(context); setState(() => selected = 1); }, child: const Text('Show'))])), icon: const Icon(Icons.search))),
          IconButton(onPressed: () => setState(() => selected = 6), icon: const CircleAvatar(radius: 16, child: Icon(Icons.person_outline, size: 20)))
        ])),
        Expanded(child: page(wide))
      ]))
    ])), bottomNavigationBar: wide ? null : NavigationBar(
      selectedIndex: selected == 1 ? 1 : selected == 2 ? 2 : selected == 3 ? 3 : selected == 6 ? 4 : 0,
      onDestinationSelected: (i) => setState(() => selected = [0, 1, 2, 3, 6][i]), backgroundColor: panel,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: 'Tools'),
        NavigationDestination(icon: Icon(Icons.auto_awesome_rounded), label: 'Study'),
        NavigationDestination(icon: Icon(Icons.forum_rounded), label: 'Chat'),
        NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Account')
      ]));
  }
  Widget page(bool wide) {
    if (selected == 1) {
      final q = search.toLowerCase().trim();
      final found = tools.where((t) => (t.title + t.description + t.category).toLowerCase().contains(q)).toList();
      return ListView(padding: const EdgeInsets.all(20), children: [
        const Heading('Tools that work', 'Tap any tool to open it.'), const SizedBox(height: 16),
        if (!wide) TextField(onChanged: (v) => setState(() => search = v), decoration: const InputDecoration(hintText: 'Search tools', prefixIcon: Icon(Icons.search))),
        const SizedBox(height: 12), toolGrid(found, wide)
      ]);
    }
    if (selected == 2) return const StudyPage();
    if (selected == 3) return const ChatPage();
    if (selected == 4 || selected == 5) {
      final list = selected == 4 ? favorites.toList() : recent;
      return ListView(padding: const EdgeInsets.all(22), children: [
        Heading(selected == 4 ? 'Favorites' : 'Recently used', selected == 4 ? 'Your saved shortcuts.' : 'Tools you opened recently.'),
        if (list.isEmpty) const Padding(padding: EdgeInsets.only(top: 20), child: Text('Nothing here yet. Use the star on a tool to favorite it.', style: TextStyle(color: muted))),
        for (final name in list) ListTile(title: Text(name), trailing: const Icon(Icons.chevron_right), onTap: () { final matches = tools.where((t) => t.title == name); if (matches.isNotEmpty) openTool(matches.first); })
      ]);
    }
    if (selected == 6) return const AccountPage();
    if (selected == 7) return const SettingsPage();
    return ListView(padding: const EdgeInsets.all(20), children: [
      Container(padding: const EdgeInsets.all(26), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF30275F), Color(0xFF171A32)]), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF3A3568))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('YOUR DIGITAL WORKSPACE', style: TextStyle(color: Color(0xFFD2CCFF), fontWeight: FontWeight.w800, letterSpacing: 1.2, fontSize: 11)),
        const SizedBox(height: 16), Text('Everything useful.\nNothing in the way.', style: TextStyle(fontSize: wide ? 36 : 30, fontWeight: FontWeight.w800, height: 1.12)),
        const SizedBox(height: 12), const Text('Tools, study sessions, and conversations in one calm workspace.', style: TextStyle(color: Color(0xFFC0C5DB))),
        const SizedBox(height: 20), Wrap(spacing: 10, children: [
          FilledButton.icon(onPressed: () => setState(() => selected = 1), icon: const Icon(Icons.grid_view), label: const Text('Explore tools'), style: FilledButton.styleFrom(backgroundColor: purple)),
          OutlinedButton.icon(onPressed: () => setState(() => selected = 2), icon: const Icon(Icons.auto_awesome), label: const Text('Study AI'))
        ])
      ]),
      const SizedBox(height: 24), const Heading('Quick access', 'Useful tools ready to open.'), const SizedBox(height: 12),
      toolGrid(tools.take(4).toList(), wide), const SizedBox(height: 20),
      const FeatureCard(icon: Icons.tablet_mac_rounded, title: 'iPad-friendly', text: 'Adaptive card grids and touch-sized controls.'), const SizedBox(height: 10),
      const FeatureCard(icon: Icons.desktop_windows_rounded, title: 'Windows-ready', text: 'Persistent sidebar, wide layouts, and keyboard-friendly inputs.'), const SizedBox(height: 10),
      const FeatureCard(icon: Icons.cloud_sync_rounded, title: 'Supabase account', text: 'Sign in, send chat messages, and save private study notes.')
    ]);
  }
  Widget toolGrid(List<ToolInfo> list, bool wide) => LayoutBuilder(builder: (context, box) {
    final columns = box.maxWidth >= 1050 ? 3 : box.maxWidth >= 570 ? 2 : 1;
    return GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: list.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 12, mainAxisSpacing: 12, mainAxisExtent: 135),
      itemBuilder: (_, i) => ToolCard(tool: list[i], favorite: favorites.contains(list[i].title),
        tap: () => openTool(list[i]), star: () => setState(() => favorites.contains(list[i].title) ? favorites.remove(list[i].title) : favorites.add(list[i].title))));
  });
}

class ToolPage extends StatefulWidget {
  final ToolInfo tool;
  const ToolPage({super.key, required this.tool});
  @override State<ToolPage> createState() => _ToolPageState();
}
class _ToolPageState extends State<ToolPage> {
  final input = TextEditingController();
  String output = '', hex = '#8B7CFF';
  @override void dispose() { input.dispose(); super.dispose(); }
  void copy(String value) { Clipboard.setData(ClipboardData(text: value)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied'))); }
  void runTool() {
    final text = input.text.trim();
    try {
      switch (widget.tool.title) {
        case 'Calculator':
          final m = RegExp(r'^(-?\d+(?:\.\d+)?)\s*([+\-*/])\s*(-?\d+(?:\.\d+)?)$').firstMatch(text);
          if (m == null) { setState(() => output = 'Enter a simple expression, such as 12 * 4.'); return; }
          final a = double.parse(m.group(1)!), b = double.parse(m.group(3)!); final op = m.group(2)!;
          if (op == '/' && b == 0) { setState(() => output = 'Cannot divide by zero.'); return; }
          final result = switch (op) { '+' => a + b, '-' => a - b, '*' => a * b, '/' => a / b, _ => 0.0 };
          setState(() => output = result.toString()); break;
        case 'Unit Converter':
          final n = double.parse(text);
          setState(() => output = 'Inches to cm: ' + (n * 2.54).toStringAsFixed(3) + '\nPounds to kg: ' + (n * 0.45359237).toStringAsFixed(3) + '\nFahrenheit to Celsius: ' + ((n - 32) * 5 / 9).toStringAsFixed(2)); break;
        case 'JSON Formatter':
          setState(() => output = const JsonEncoder.withIndent('  ').convert(jsonDecode(text))); break;
        case 'Password Generator':
          final length = int.tryParse(text) ?? 20;
          if (length < 8 || length > 64) { setState(() => output = 'Choose a length from 8 to 64.'); return; }
          const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#%&*+-_';
          final random = Random.secure();
          setState(() => output = List.generate(length, (_) => chars[random.nextInt(chars.length)]).join()); break;
        case 'Color Tools':
          final value = text.replaceFirst('#', '');
          if (value.length != 6 || int.tryParse(value, radix: 16) == null) { setState(() => output = 'Enter a six-digit hex value, like #8B7CFF.'); return; }
          hex = '#' + value.toUpperCase();
          setState(() => output = hex + '\nRGB: ' + int.parse(value.substring(0, 2), radix: 16).toString() + ', ' + int.parse(value.substring(2, 4), radix: 16).toString() + ', ' + int.parse(value.substring(4, 6), radix: 16).toString()); break;
      }
    } catch (_) { setState(() => output = widget.tool.title == 'JSON Formatter' ? 'Invalid JSON. Check commas, quotes, and brackets.' : 'Please check the input and try again.'); }
  }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(widget.tool.title)), body: ListView(padding: const EdgeInsets.all(22), children: [
    Text(widget.tool.description, style: const TextStyle(color: muted)), const SizedBox(height: 18),
    if (widget.tool.title == 'Text Tools') ...[
      TextField(controller: input, minLines: 5, maxLines: 10, decoration: const InputDecoration(labelText: 'Your text', alignLabelWithHint: true)),
      const SizedBox(height: 12), Wrap(spacing: 8, runSpacing: 8, children: [
        OutlinedButton(onPressed: () => setState(() => output = input.text.toUpperCase()), child: const Text('UPPERCASE')),
        OutlinedButton(onPressed: () => setState(() => output = input.text.toLowerCase()), child: const Text('lowercase')),
        OutlinedButton(onPressed: () => setState(() => output = input.text.trim().replaceAll(RegExp(r'[ \t]+'), ' ').replaceAll(RegExp(r'\n{3,}'), '\n\n')), child: const Text('Clean spaces')),
        OutlinedButton(onPressed: () => setState(() => output = input.text.split(RegExp(r'\s+')).map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1).toLowerCase()).join(' ')), child: const Text('Title Case'))
      ])
    ] else ...[
      TextField(controller: input, minLines: widget.tool.title == 'JSON Formatter' ? 5 : 1, maxLines: widget.tool.title == 'JSON Formatter' ? 12 : 3,
        decoration: InputDecoration(labelText: switch (widget.tool.title) { 'Calculator' => 'Expression, e.g. 12 * 4', 'Unit Converter' => 'Number to convert', 'JSON Formatter' => 'JSON input', 'Password Generator' => 'Length (8–64), default 20', 'Color Tools' => 'Hex color, e.g. #8B7CFF', _ => 'Input' }, alignLabelWithHint: true)),
      const SizedBox(height: 12), FilledButton.icon(onPressed: runTool, icon: const Icon(Icons.play_arrow), label: const Text('Run tool'), style: FilledButton.styleFrom(backgroundColor: purple))
    ],
    if (output.isNotEmpty) ...[
      const SizedBox(height: 20), const Text('RESULT', style: TextStyle(color: muted, letterSpacing: 1.4, fontSize: 11)),
      if (widget.tool.title == 'Color Tools' && hex.length == 7) Container(height: 70, margin: const EdgeInsets.only(top: 10), decoration: BoxDecoration(color: Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000), borderRadius: BorderRadius.circular(12))),
      Container(margin: const EdgeInsets.only(top: 10), padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(14)), child: SelectableText(output)),
      Align(alignment: Alignment.centerRight, child: TextButton.icon(onPressed: () => copy(output), icon: const Icon(Icons.copy), label: const Text('Copy result')))
    ]
  ]));
}

class StudyPage extends StatefulWidget {
  const StudyPage({super.key});
  @override State<StudyPage> createState() => _StudyPageState();
}
class _StudyPageState extends State<StudyPage> {
  final title = TextEditingController(), notes = TextEditingController();
  List<Map<String, dynamic>> saved = [];
  String practice = '';
  bool saving = false;
  @override void initState() { super.initState(); load(); }
  @override void dispose() { title.dispose(); notes.dispose(); super.dispose(); }
  Future<void> load() async {
    try { final rows = await db.from('app_study_notes').select().order('updated_at', ascending: false).limit(30); if (mounted) setState(() => saved = List<Map<String, dynamic>>.from(rows)); } catch (_) {}
  }
  void notify(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  void makePractice() {
    final source = notes.text.trim();
    if (source.isEmpty) { notify('Paste some notes first.'); return; }
    final lines = source.split(RegExp(r'(?<=[.!?])\s+')).where((s) => s.trim().length > 12).take(5).toList();
    setState(() => practice = lines.isEmpty
      ? 'Practice prompts\n1. What are the key ideas?\n2. Explain this topic in your own words.\n3. Give an example.'
      : lines.asMap().entries.map((e) => 'Q' + (e.key + 1).toString() + '. Explain this idea in your own words:\n' + e.value.trim()).join('\n\n'));
  }
  Future<void> save() async {
    if (title.text.trim().isEmpty) { notify('Add a note title first.'); return; }
    setState(() => saving = true);
    try {
      await db.from('app_study_notes').insert({'user_id': db.auth.currentUser!.id, 'title': title.text.trim(), 'content': notes.text.trim()});
      notify('Notes saved to your account.'); await load();
    } catch (_) { notify('Could not save notes. Try again.'); }
    finally { if (mounted) setState(() => saving = false); }
  }
  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(18), children: [
    const Heading('Study AI', 'Study notes, practice prompts, and cloud saves.'),
    const SizedBox(height: 14), const FeatureCard(icon: Icons.auto_awesome, title: 'AI provider not connected yet', text: 'The study workspace and prompt generator work now. Real AI explanations need a secure AI provider connection through a Supabase Edge Function.'),
    const SizedBox(height: 14), TextField(controller: title, decoration: const InputDecoration(labelText: 'Study topic / note title')),
    const SizedBox(height: 10), TextField(controller: notes, minLines: 5, maxLines: 12, decoration: const InputDecoration(labelText: 'Paste your notes here', alignLabelWithHint: true)),
    const SizedBox(height: 10), Wrap(spacing: 8, runSpacing: 8, children: [
      FilledButton.icon(onPressed: makePractice, icon: const Icon(Icons.quiz_outlined), label: const Text('Make practice prompts'), style: FilledButton.styleFrom(backgroundColor: purple)),
      OutlinedButton.icon(onPressed: saving ? null : save, icon: const Icon(Icons.cloud_upload_outlined), label: Text(saving ? 'Saving…' : 'Save to account'))
    ]),
    if (practice.isNotEmpty) ...[const SizedBox(height: 16), const Heading('Practice prompts', 'Use these to check your understanding.'), const SizedBox(height: 8), Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(14)), child: SelectableText(practice))],
    const SizedBox(height: 24), const Heading('Saved notes', 'Only you can read your saved notes.'),
    if (saved.isEmpty) const Padding(padding: EdgeInsets.only(top: 10), child: Text('No saved notes yet.', style: TextStyle(color: muted))),
    for (final row in saved) Card(color: panel, child: ListTile(leading: const Icon(Icons.description_outlined, color: purple), title: Text((row['title'] ?? 'Untitled').toString()), subtitle: Text((row['content'] ?? '').toString(), maxLines: 2, overflow: TextOverflow.ellipsis), onTap: () => setState(() { title.text = (row['title'] ?? '').toString(); notes.text = (row['content'] ?? '').toString(); })))
  ]);
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  @override State<ChatPage> createState() => _ChatPageState();
}
class _ChatPageState extends State<ChatPage> {
  final message = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  bool loading = false;
  String error = '';
  @override void initState() { super.initState(); load(); }
  @override void dispose() { message.dispose(); super.dispose(); }
  Future<void> load() async {
    setState(() { loading = true; error = ''; });
    try { final rows = await db.from('app_chat_messages').select().order('created_at', ascending: true).limit(100); if (mounted) setState(() => messages = List<Map<String, dynamic>>.from(rows)); }
    catch (_) { if (mounted) setState(() => error = 'Chat failed to load. Check your connection and database setup.'); }
    finally { if (mounted) setState(() => loading = false); }
  }
  Future<void> send() async {
    final text = message.text.trim(), user = db.auth.currentUser;
    if (text.isEmpty || user == null) return;
    if (text.length > 2000) { setState(() => error = 'Messages must be 2,000 characters or less.'); return; }
    final name = (user.userMetadata?['display_name'] ?? user.email?.split('@').first ?? 'Member').toString();
    try { await db.from('app_chat_messages').insert({'user_id': user.id, 'display_name': name, 'body': text}); message.clear(); await load(); }
    catch (_) { setState(() => error = 'Message was not sent. Try refreshing or signing in again.'); }
  }
  @override Widget build(BuildContext context) => Column(children: [
    Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: Row(children: [const Expanded(child: Text('Signed-in community chat', style: TextStyle(color: muted))), IconButton(onPressed: load, icon: const Icon(Icons.refresh))])),
    if (error.isNotEmpty) Padding(padding: const EdgeInsets.all(8), child: Text(error, style: const TextStyle(color: Color(0xFFFFC18B)))),
    Expanded(child: loading && messages.isEmpty ? const Center(child: CircularProgressIndicator()) : messages.isEmpty ? const Center(child: Text('No messages yet. Start the conversation!', style: TextStyle(color: muted))) : ListView(padding: const EdgeInsets.all(14), children: [
      for (final m in messages) Align(alignment: m['user_id'] == db.auth.currentUser?.id ? Alignment.centerRight : Alignment.centerLeft, child: Container(
        constraints: const BoxConstraints(maxWidth: 620), margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(color: m['user_id'] == db.auth.currentUser?.id ? const Color(0xFF29244F) : panel, borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(m['user_id'] == db.auth.currentUser?.id ? 'You' : (m['display_name'] ?? 'Member').toString(), style: const TextStyle(color: Color(0xFFD2CCFF), fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4), SelectableText((m['body'] ?? '').toString())
        ])))
    ])),
    SafeArea(top: false, child: Padding(padding: const EdgeInsets.fromLTRB(12, 8, 12, 12), child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Expanded(child: TextField(controller: message, minLines: 1, maxLines: 4, maxLength: 2000, decoration: const InputDecoration(hintText: 'Write a message…', counterText: ''))),
      const SizedBox(width: 8), IconButton.filled(onPressed: send, style: IconButton.styleFrom(backgroundColor: purple), icon: const Icon(Icons.send_rounded))
    ])))
  ]);
}

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});
  @override Widget build(BuildContext context) {
    final user = db.auth.currentUser;
    final name = (user?.userMetadata?['display_name'] ?? user?.email?.split('@').first ?? 'Member').toString();
    return ListView(padding: const EdgeInsets.all(22), children: [
      const Heading('Your account', 'Profile and cloud features.'),
      const SizedBox(height: 18), Card(color: panel, child: ListTile(leading: const CircleAvatar(child: Icon(Icons.person)), title: Text(name), subtitle: Text(user?.email ?? ''))),
      const SizedBox(height: 12), const FeatureCard(icon: Icons.cloud_done_outlined, title: 'Supabase connected', text: 'Authentication, community chat, and private study notes use Supabase.'),
      const SizedBox(height: 18), FilledButton.icon(onPressed: () => db.auth.signOut(), icon: const Icon(Icons.logout), label: const Text('Sign out'), style: FilledButton.styleFrom(backgroundColor: purple, padding: const EdgeInsets.all(14)))
    ]);
  }
}
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(22), children: const [
    Heading('Settings', 'About this app and your experience.'), SizedBox(height: 16),
    FeatureCard(icon: Icons.palette_outlined, title: 'Dark purple appearance', text: 'A calm theme across phone, tablet, and desktop.'),
    SizedBox(height: 10), FeatureCard(icon: Icons.devices_outlined, title: 'Adaptive navigation', text: 'Bottom navigation on smaller screens and a sidebar on larger screens.'),
    SizedBox(height: 10), FeatureCard(icon: Icons.security_outlined, title: 'Account privacy', text: 'Study notes are private to you; community chat is for signed-in users.')
  ]);
}

class ToolCard extends StatelessWidget {
  final ToolInfo tool; final bool favorite; final VoidCallback tap, star;
  const ToolCard({super.key, required this.tool, required this.favorite, required this.tap, required this.star});
  @override Widget build(BuildContext context) => Material(color: panel, borderRadius: BorderRadius.circular(17), child: InkWell(onTap: tap, borderRadius: BorderRadius.circular(17), child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
    Container(width: 44, height: 44, decoration: BoxDecoration(color: purple.withValues(alpha: .16), borderRadius: BorderRadius.circular(13)), child: Icon(tool.icon, color: const Color(0xFFD2CCFF))),
    const SizedBox(width: 12), Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(tool.title, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 5), Text(tool.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: muted, fontSize: 12))
    ])),
    IconButton(tooltip: 'Favorite', onPressed: star, icon: Icon(favorite ? Icons.star : Icons.star_border, color: favorite ? const Color(0xFFFFD166) : muted))
  ]))));
}
class BrandMark extends StatelessWidget {
  const BrandMark({super.key});
  @override Widget build(BuildContext context) => Container(width: 38, height: 38, decoration: BoxDecoration(gradient: const LinearGradient(colors: [purple, Color(0xFFB18CFF)]), borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.bolt, color: Colors.white));
}
class NavItem extends StatelessWidget {
  final String title; final IconData icon; final bool active; final VoidCallback onTap;
  const NavItem({super.key, required this.title, required this.icon, required this.active, required this.onTap});
  @override Widget build(BuildContext context) => Material(color: active ? purple.withValues(alpha: .17) : Colors.transparent, borderRadius: BorderRadius.circular(12), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), child: Row(children: [
    Icon(icon, size: 20, color: active ? const Color(0xFFCFC8FF) : muted), const SizedBox(width: 12), Text(title, style: TextStyle(color: active ? Colors.white : muted, fontWeight: active ? FontWeight.w700 : FontWeight.w500))
  ]))));
}
class Heading extends StatelessWidget {
  final String title, subtitle;
  const Heading(this.title, this.subtitle, {super.key});
  @override Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)), const SizedBox(height: 5), Text(subtitle, style: const TextStyle(color: muted, height: 1.4))
  ]);
}
class FeatureCard extends StatelessWidget {
  final IconData icon; final String title, text;
  const FeatureCard({super.key, required this.icon, required this.title, required this.text});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF242943))), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Icon(icon, color: purple, size: 22), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 5), Text(text, style: const TextStyle(color: muted, height: 1.4, fontSize: 13))
    ]))
  ]));
}
