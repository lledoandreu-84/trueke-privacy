import 'package:trueke/shared/widgets/custom_app_bar.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/user_profile.dart';
import '../../providers/profile_provider.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/supabase/supabase_client.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final UserProfile profile;
  const EditProfileScreen({super.key, required this.profile});
  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late TextEditingController _bioController;
  File? _selectedAvatarFile;
  bool _isUploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(
      text: widget.profile.displayName,
    );
    _bioController = TextEditingController(text: widget.profile.bio ?? '');
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedAvatarFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUploadingAvatar = true;
    });
    String? finalAvatarUrl = widget.profile.avatarUrl;
    final theme = Theme.of(context);

    try {
      if (_selectedAvatarFile != null) {
        final client = ref.read(supabaseClientProvider);
        final storageService = StorageService(client: client);
        finalAvatarUrl = await storageService.uploadAvatar(
          file: _selectedAvatarFile!,
          userId: widget.profile.id,
        );
      }

      final updatedProfile = widget.profile.copyWith(
        displayName: _displayNameController.text.trim(),
        bio: _bioController.text.trim().isEmpty
            ? null
            : _bioController.text.trim(),
        avatarUrl: finalAvatarUrl,
      );

      await ref
          .read(profileMutationProvider.notifier)
          .updateProfile(profile: updatedProfile);

      if (!mounted) return;
      final mutationState = ref.read(profileMutationProvider);

      if (mutationState.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: ${mutationState.error}'),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Perfil guardado correctamente'),
            backgroundColor: theme.colorScheme.primary,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingAvatar = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutationState = ref.watch(profileMutationProvider);
    final isLoading = mutationState.isLoading || _isUploadingAvatar;

    ImageProvider? avatarImage;
    if (_selectedAvatarFile != null) {
      avatarImage = FileImage(_selectedAvatarFile!);
    } else if (widget.profile.avatarUrl != null &&
        widget.profile.avatarUrl!.isNotEmpty) {
      avatarImage = NetworkImage(widget.profile.avatarUrl!);
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: CustomAppBar(
        titleText: 'Editar Perfil',
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: theme.colorScheme.onSurface),
          onPressed: isLoading ? null : () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: isLoading ? null : _submit,
            child: isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator.adaptive(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  )
                : Text(
                    'Guardar',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: isLoading ? null : _pickAvatar,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.primary,
                              width: 2,
                            ),
                            image: avatarImage != null
                                ? DecorationImage(
                                    image: avatarImage,
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: avatarImage == null
                              ? Icon(
                                  Icons.person_outline_rounded,
                                  size: 48,
                                  color: theme.colorScheme.primary,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt_rounded,
                              size: 16,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Nombre de usuario',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _displayNameController,
                  enabled: !isLoading,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Tu nombre o apodo',
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre no puede estar vacío';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'Biografía / Descripción',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _bioController,
                  enabled: !isLoading,
                  maxLines: 4,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText:
                        'Cuéntanos un poco sobre ti y lo que sueles ofrecer para trueque...',
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      
                    ),
                    onPressed: isLoading ? null : _submit,
                    child: isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator.adaptive(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.onPrimary,
                              ),
                            ),
                          )
                        : const Text(
                            'Guardar Cambios',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
