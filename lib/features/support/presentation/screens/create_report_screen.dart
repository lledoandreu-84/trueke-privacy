import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/auth_service.dart';
import '../../models/report_model.dart';
import '../providers/support_providers.dart';

class CreateReportScreen extends ConsumerStatefulWidget {
  final String targetId;
  final String targetType; // 'product' o 'user'

  const CreateReportScreen({
    super.key,
    required this.targetId,
    required this.targetType,
  });

  @override
  ConsumerState<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends ConsumerState<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedReason = 'Contenido inapropiado';
  final _descriptionController = TextEditingController();

  final List<String> _reasons = [
    'Contenido inapropiado',
    'Fraude o estafa',
    'Comportamiento abusivo',
    'Producto duplicado o falso',
    'Otros',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final userIdAsync = ref.read(authUserIdProvider);
    final reporterId = userIdAsync.value ?? 'anonymous';

    final report = ReportModel(
      id: UniqueKey().toString(), // ID temporal local
      reporterId: reporterId,
      targetId: widget.targetId,
      targetType: widget.targetType,
      reason: _selectedReason,
      description: _descriptionController.text,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    final success = await ref
        .read(supportMutationProvider.notifier)
        .sendReport(report);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reporte enviado con éxito.')),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al enviar el reporte. Inténtalo de nuevo.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mutationState = ref.watch(supportMutationProvider);
    final isLoading = mutationState is AsyncLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Enviar Reporte',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                '¿Cuál es el motivo de este reporte?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedReason,
                items: _reasons.map((reason) {
                  return DropdownMenuItem(value: reason, child: Text(reason));
                }).toList(),
                onChanged: isLoading
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            _selectedReason = value;
                          });
                        }
                      },
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              const Text(
                'Detalles adicionales (opcional)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                enabled: !isLoading,
                decoration: const InputDecoration(
                  hintText: 'Describe brevemente lo sucedido...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (_selectedReason == 'Otros' &&
                      (value == null || value.trim().isEmpty)) {
                    return 'Por favor, proporciona una descripción para el motivo "Otros"';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Enviar Reporte',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
