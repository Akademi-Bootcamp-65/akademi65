import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../models/user_profile.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';

class UserProfileFormScreen extends StatefulWidget {
  final bool isViewMode;
  final UserProfile? existingProfile;
  
  const UserProfileFormScreen({
    super.key, 
    this.isViewMode = false,
    this.existingProfile,
  });

  @override
  State<UserProfileFormScreen> createState() => _UserProfileFormScreenState();
}

class _UserProfileFormScreenState extends State<UserProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String? _gender;
  bool _isPregnant = false;
  String _infoLevel = 'Orta';
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = !widget.isViewMode;
    _loadExistingProfile();
  }

  void _loadExistingProfile() {
    UserProfile? profile;
    
    // Use provided profile or get from service
    if (widget.existingProfile != null) {
      profile = widget.existingProfile;
    } else if (widget.isViewMode) {
      profile = UserService.currentUser;
    }
    
    if (profile != null) {
      _nameController.text = profile.name;
      _ageController.text = profile.age.toString();
      _gender = profile.gender;
      _isPregnant = profile.isPregnant;
      _infoLevel = profile.infoLevel;
      setState(() {});
    }
  }

  Future<void> _saveProfileAndGoHome() async {
    // Erkek + hamile kontrolü - dalga geçer uyarı 😄
    if (_gender == 'Erkek' && _isPregnant) {
      _showFunnyWarning();
      return;
    }
    
    if (_formKey.currentState!.validate()) {
      // Create and save user profile
      final profile = UserProfile(
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text),
        gender: _gender ?? '',
        isPregnant: _isPregnant,
        infoLevel: _infoLevel,
      );
      
      await UserService.saveUserProfile(profile);
      
      if (!mounted) return;
      
      // If this is from profile screen, just go back
      if (widget.existingProfile != null) {
        Navigator.of(context).pop(true); // Return true to indicate success
      } else {
        // If this is first time setup, go to home
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    }
  }

  Future<void> _updateProfile() async {
    // Erkek + hamile kontrolü - dalga geçer uyarı 😄
    if (_gender == 'Erkek' && _isPregnant) {
      _showFunnyWarning();
      return;
    }
    
    if (_formKey.currentState!.validate()) {
      // Create and save updated user profile
      final profile = UserProfile(
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text),
        gender: _gender ?? '',
        isPregnant: _isPregnant,
        infoLevel: _infoLevel,
      );
      
      await UserService.saveUserProfile(profile);
      
      // Switch back to view mode
      setState(() {
        _isEditMode = false;
      });
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profil başarıyla güncellendi'),
          backgroundColor: Color(0xFF4FC3A1),
        ),
      );
    }
  }

  void _showFunnyWarning() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.sentiment_very_satisfied, 
                  color: Colors.orange, size: 30),
              const SizedBox(width: 10),
              const Text('Hmm... 🤔'),
            ],
          ),
          content: const Text(
            'Erkek olup aynı zamanda hamile olmak... Bu tıp bilimi için çığır açıcı olurdu! 😄\n\nBelki cinsiyeti tekrar kontrol etmek istersin?',
            style: TextStyle(fontSize: 16),
          ),
          backgroundColor: Colors.orange.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Hamilelik seçeneğini otomatik olarak kapat
                setState(() {
                  _isPregnant = false;
                });
              },
              child: const Text(
                'Tamam, düzelttim! 😅',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4FC3A1)),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const OnboardingScreen()),
            );
          },
        ),
        actions: widget.isViewMode && !_isEditMode
            ? [
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF4FC3A1)),
                  onPressed: () {
                    setState(() {
                      _isEditMode = true;
                    });
                  },
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  widget.isViewMode
                      ? (_isEditMode ? 'Profili Düzenle' : 'Profil Bilgileri')
                      : 'Profilini Oluştur',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4FC3A1),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.isViewMode
                      ? (_isEditMode
                          ? 'Bilgilerinizi güncelleyebilirsiniz.'
                          : 'Kayıtlı profil bilgileriniz.')
                      : 'Kişiselleştirilmiş öneriler için lütfen bilgilerini doldur.',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        readOnly: widget.isViewMode && !_isEditMode,
                        decoration: InputDecoration(
                          labelText: 'İsim',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          filled: widget.isViewMode && !_isEditMode,
                          fillColor: Colors.grey[100],
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Lütfen isminizi girin';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _ageController,
                        readOnly: widget.isViewMode && !_isEditMode,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Yaş',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          filled: widget.isViewMode && !_isEditMode,
                          fillColor: Colors.grey[100],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen yaşınızı girin';
                          }
                          final age = int.tryParse(value);
                          if (age == null || age < 0 || age > 120) {
                            return 'Geçerli bir yaş girin';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _gender,
                        decoration: InputDecoration(
                          labelText: 'Cinsiyet',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Kadın', child: Text('Kadın')),
                          DropdownMenuItem(value: 'Erkek', child: Text('Erkek')),
                        ],
                        onChanged: (val) => setState(() => _gender = val),
                        validator: (value) => value == null ? 'Cinsiyet seçin' : null,
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Hamile misiniz?'),
                        value: _isPregnant,
                        onChanged: (val) => setState(() => _isPregnant = val),
                        activeColor: const Color(0xFF4FC3A1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      const SizedBox(height: 8),
                      InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Bilgi Seviyesi',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _infoLevel,
                            items: const [
                              DropdownMenuItem(value: 'Sade', child: Text('Sade')),
                              DropdownMenuItem(value: 'Orta', child: Text('Orta')),
                              DropdownMenuItem(value: 'Detaylı', child: Text('Detaylı')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _infoLevel = val);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Show button only when editing or creating
                      if (!widget.isViewMode || _isEditMode) ...[
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4FC3A1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                if (widget.isViewMode) {
                                  _updateProfile();
                                } else {
                                  _saveProfileAndGoHome();
                                }
                              }
                            },
                            child: Text(
                              widget.isViewMode ? 'Güncelle' : 'Devam',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Show profile info when in view mode
                      if (widget.isViewMode && !_isEditMode) ...[
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Color(0xFF4FC3A1), width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.check_circle, color: Color(0xFF4FC3A1), size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Profil Kayıtlı',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4FC3A1),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Profiliniz başarıyla kaydedildi ve ilaç analizlerinde kişiselleştirilmiş öneriler alıyorsunuz.',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      const SizedBox(height: 24),
                    ],
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
