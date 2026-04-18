import 'package:flutter/material.dart';

import 'vault_page.dart';
import 'vault_store.dart';

class VaultGatePage extends StatefulWidget {
  const VaultGatePage({super.key});

  @override
  State<VaultGatePage> createState() => _VaultGatePageState();
}

class _VaultGatePageState extends State<VaultGatePage> {
  final _pin = TextEditingController();
  final _pin2 = TextEditingController();
  final _store = VaultStore();

  bool _loading = true;
  bool _hasPin = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _pin.dispose();
    _pin2.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final has = await _store.hasPin();
    if (!mounted) return;
    setState(() {
      _hasPin = has;
      _loading = false;
    });
  }

  Future<void> _setPin() async {
    setState(() => _error = null);
    final p1 = _pin.text.trim();
    final p2 = _pin2.text.trim();
    if (p1.length < 4) {
      setState(() => _error = 'PIN must be at least 4 digits.');
      return;
    }
    if (p1 != p2) {
      setState(() => _error = 'PINs do not match.');
      return;
    }
    await _store.setPin(p1);
    if (!mounted) return;
    _pin.clear();
    _pin2.clear();
    setState(() => _hasPin = true);
    _openVault();
  }

  Future<void> _unlock() async {
    setState(() => _error = null);
    final p = _pin.text.trim();
    final ok = await _store.verifyPin(p);
    if (!mounted) return;
    if (!ok) {
      setState(() => _error = 'Wrong PIN.');
      return;
    }
    _pin.clear();
    _openVault();
  }

  void _openVault() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const VaultPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Vault')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _hasPin ? 'Enter PIN' : 'Create a PIN',
                style: t.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This protects sensitive sections. (MVP: local hash in prefs)',
                style: t.textTheme.bodyMedium?.copyWith(
                  color: t.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _pin,
                keyboardType: TextInputType.number,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'PIN',
                  border: OutlineInputBorder(),
                ),
              ),
              if (!_hasPin) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _pin2,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Repeat PIN',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: t.textTheme.bodySmall?.copyWith(
                    color: t.colorScheme.error,
                  ),
                ),
              ],
              const Spacer(),
              FilledButton(
                onPressed: _hasPin ? _unlock : _setPin,
                child: Text(_hasPin ? 'Unlock' : 'Save PIN'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

