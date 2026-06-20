import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:juno/core/errors/app_exception.dart';
import 'package:juno/core/theme/app_radii.dart';
import 'package:juno/core/theme/app_spacing.dart';
import 'package:juno/core/theme/juno_colors.dart';
import 'package:juno/core/utils/formatting.dart';
import 'package:juno/data/data_providers.dart';
import 'package:juno/data/models/saved_connection.dart';
import 'package:juno/db/adapter/adapter_registry.dart';
import 'package:juno/db/adapter/database_adapter.dart';
import 'package:juno/db/adapter/models/connection_config.dart';
import 'package:juno/features/connections/domain/connection_kind_descriptor.dart';
import 'package:juno/features/connections/presentation/widgets/read_only_explainer_sheet.dart';
import 'package:uuid/uuid.dart';

/// Preset color tags offered in the editor (drawn from the design palette).
const List<String> _colorPresets = <String>[
  '#5B9CFF', // accent
  '#A78BFA', // keyword
  '#F2B45A', // operator
  '#33CFC9', // value
  '#7DDC8E', // schema
  '#FF6259', // danger
];

/// Create/edit form for a saved connection. Pass a [connectionId] to edit an
/// existing connection, or null to create a new one.
class ConnectionEditorScreen extends ConsumerStatefulWidget {
  /// Creates the editor.
  const ConnectionEditorScreen({this.connectionId, super.key});

  /// The connection to edit, or null when creating.
  final String? connectionId;

  @override
  ConsumerState<ConnectionEditorScreen> createState() =>
      _ConnectionEditorScreenState();
}

class _ConnectionEditorScreenState
    extends ConsumerState<ConnectionEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _host = TextEditingController();
  final _port = TextEditingController();
  final _database = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();

  DatabaseKind _kind = DatabaseKind.postgres;
  DbSslMode _sslMode = DbSslMode.require;
  bool _readOnly = true;
  String? _colorTag;
  DbEnvironment? _environment;

  bool _loading = true;
  bool _saving = false;
  _TestState _test = const _TestIdle();

  bool get _isEditing => widget.connectionId != null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in <TextEditingController>[
      _name,
      _host,
      _port,
      _database,
      _username,
      _password,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final id = widget.connectionId;
    if (id == null) {
      _port.text = '${ConnectionKindDescriptor.of(_kind).defaultPort}';
      setState(() => _loading = false);
      return;
    }
    final existing = await ref.read(connectionsRepositoryProvider).getById(id);
    if (!mounted) {
      return;
    }
    if (existing != null) {
      _name.text = existing.name;
      _host.text = existing.host;
      _port.text = '${existing.port}';
      _database.text = existing.database;
      _username.text = existing.username;
      _kind = existing.kind;
      _sslMode = existing.sslMode;
      _readOnly = existing.readOnly;
      _colorTag = existing.colorTag;
      _environment = existing.environment;
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit connection' : 'New connection'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: <Widget>[
                  _field(_name, 'Name', hint: 'My database'),
                  _field(_host, 'Host', hint: 'localhost'),
                  _field(
                    _port,
                    'Port',
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: _validatePort,
                  ),
                  _field(_database, 'Database', hint: 'postgres'),
                  _field(_username, 'Username', hint: 'postgres'),
                  _field(
                    _password,
                    'Password',
                    obscure: true,
                    required: !_isEditing,
                    hint: _isEditing ? 'Leave blank to keep current' : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _sslDropdown(),
                  const SizedBox(height: AppSpacing.lg),
                  _readOnlyToggle(),
                  const SizedBox(height: AppSpacing.xl),
                  _ColorPicker(
                    selected: _colorTag,
                    onChanged: (value) => setState(() => _colorTag = value),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _EnvironmentPicker(
                    selected: _environment,
                    onChanged: (value) => setState(() => _environment = value),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _TestResult(state: _test),
                  const SizedBox(height: AppSpacing.md),
                  _actions(),
                ],
              ),
            ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    String? hint,
    bool obscure = false,
    bool required = true,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(labelText: label, hintText: hint),
        validator:
            validator ??
            (value) {
              if (required && (value == null || value.trim().isEmpty)) {
                return '$label is required';
              }
              return null;
            },
      ),
    );
  }

  String? _validatePort(String? value) {
    final port = int.tryParse(value ?? '');
    if (port == null || port < 1 || port > 65535) {
      return 'Enter a port between 1 and 65535';
    }
    return null;
  }

  Widget _sslDropdown() {
    final descriptor = ConnectionKindDescriptor.of(_kind);
    return DropdownButtonFormField<DbSslMode>(
      initialValue: _sslMode,
      decoration: const InputDecoration(labelText: 'SSL mode'),
      items: <DropdownMenuItem<DbSslMode>>[
        for (final mode in descriptor.sslModes)
          DropdownMenuItem<DbSslMode>(value: mode, child: Text(mode.label)),
      ],
      onChanged: (mode) {
        if (mode != null) {
          setState(() => _sslMode = mode);
        }
      },
    );
  }

  Widget _readOnlyToggle() {
    final colors = Theme.of(context).juno;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.mdAll,
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.lock_outline_rounded, size: 18, color: colors.textMuted),
          const SizedBox(width: AppSpacing.sm),
          const Expanded(child: Text('Read-only')),
          IconButton(
            icon: Icon(Icons.info_outline_rounded, color: colors.textMuted),
            tooltip: 'What is read-only?',
            onPressed: () => ReadOnlyExplainerSheet.show(context),
          ),
          Switch(
            value: _readOnly,
            onChanged: (value) => setState(() => _readOnly = value),
          ),
        ],
      ),
    );
  }

  Widget _actions() {
    return Row(
      children: <Widget>[
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _test is _TestRunning ? null : _runTest,
            icon: const Icon(Icons.bolt_rounded, size: 18),
            label: const Text('Test connection'),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ),
      ],
    );
  }

  ConnectionConfig _buildConfig(String password) => ConnectionConfig(
    kind: _kind,
    host: _host.text.trim(),
    port: int.parse(_port.text),
    database: _database.text.trim(),
    username: _username.text.trim(),
    password: password,
    sslMode: _sslMode,
    readOnly: _readOnly,
  );

  Future<String> _resolvePassword() async {
    if (_password.text.isNotEmpty) {
      return _password.text;
    }
    final id = widget.connectionId;
    if (_isEditing && id != null) {
      final stored = await ref
          .read(secureCredentialsRepositoryProvider)
          .readPassword(id);
      return stored ?? '';
    }
    return '';
  }

  Future<void> _runTest() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _test = const _TestRunning());

    final DatabaseAdapter adapter = AdapterRegistry.create(_kind);
    try {
      final password = await _resolvePassword();
      await adapter.connect(_buildConfig(password));
      final latency = await adapter.ping();
      if (mounted) {
        setState(() => _test = _TestSuccess(latency));
      }
    } on AppException catch (error) {
      if (mounted) {
        setState(() => _test = _TestFailure(error.message));
      }
    } finally {
      await adapter.disconnect();
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() => _saving = true);

    final repo = ref.read(connectionsRepositoryProvider);
    final id = widget.connectionId ?? const Uuid().v4();
    final existing = _isEditing ? await repo.getById(id) : null;

    final connection = SavedConnection(
      id: id,
      name: _name.text.trim(),
      kind: _kind,
      host: _host.text.trim(),
      port: int.parse(_port.text),
      database: _database.text.trim(),
      username: _username.text.trim(),
      sslMode: _sslMode,
      readOnly: _readOnly,
      colorTag: _colorTag,
      environment: _environment,
      sortOrder: existing?.sortOrder ?? 0,
      createdAt: existing?.createdAt ?? DateTime.now(),
      lastUsedAt: existing?.lastUsedAt,
    );

    final password = _password.text.isEmpty ? null : _password.text;
    if (_isEditing) {
      await repo.update(connection, password: password);
    } else {
      await repo.create(connection, password: password ?? '');
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _ColorPicker extends StatelessWidget {
  const _ColorPicker({required this.selected, required this.onChanged});

  final String? selected;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.juno;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Color tag', style: theme.textTheme.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.md,
          children: <Widget>[
            _Swatch(
              color: colors.surfaceAlt,
              isSelected: selected == null,
              showNone: true,
              onTap: () => onChanged(null),
            ),
            for (final hex in _colorPresets)
              _Swatch(
                color: colorFromHex(hex)!,
                isSelected: selected == hex,
                onTap: () => onChanged(hex),
              ),
          ],
        ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.isSelected,
    required this.onTap,
    this.showNone = false,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showNone;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).juno;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? colors.textPrimary : colors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: showNone
            ? Icon(Icons.block_rounded, size: 16, color: colors.textFaint)
            : null,
      ),
    );
  }
}

class _EnvironmentPicker extends StatelessWidget {
  const _EnvironmentPicker({required this.selected, required this.onChanged});

  final DbEnvironment? selected;
  final ValueChanged<DbEnvironment?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Environment', style: theme.textTheme.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          children: <Widget>[
            ChoiceChip(
              label: const Text('None'),
              selected: selected == null,
              onSelected: (_) => onChanged(null),
            ),
            for (final env in DbEnvironment.values)
              ChoiceChip(
                label: Text(env.name),
                selected: selected == env,
                onSelected: (_) => onChanged(env),
              ),
          ],
        ),
      ],
    );
  }
}

class _TestResult extends StatelessWidget {
  const _TestResult({required this.state});

  final _TestState state;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).juno;
    final theme = Theme.of(context);
    return switch (state) {
      _TestIdle() => const SizedBox.shrink(),
      _TestRunning() => Row(
        children: <Widget>[
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text('Testing…', style: theme.textTheme.bodyMedium),
        ],
      ),
      _TestSuccess(:final latency) => _banner(
        context,
        color: colors.success,
        icon: Icons.check_circle_outline_rounded,
        text: 'Connected in ${latency.inMilliseconds} ms',
      ),
      _TestFailure(:final message) => _banner(
        context,
        color: colors.danger,
        icon: Icons.error_outline_rounded,
        text: message,
      ),
    };
  }

  Widget _banner(
    BuildContext context, {
    required Color color,
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadii.mdAll,
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 18, color: color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

/// Local state for the inline "Test connection" result.
sealed class _TestState {
  const _TestState();
}

class _TestIdle extends _TestState {
  const _TestIdle();
}

class _TestRunning extends _TestState {
  const _TestRunning();
}

class _TestSuccess extends _TestState {
  const _TestSuccess(this.latency);
  final Duration latency;
}

class _TestFailure extends _TestState {
  const _TestFailure(this.message);
  final String message;
}
