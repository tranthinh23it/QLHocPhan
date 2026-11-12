import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import '../../models/giangvien.dart';
import '../../services/giangvien_service.dart';
import '../../services/image_service.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late TextEditingController searchController;
  String selectedFilter = 'All';
  List<GiangVien> giangviens = [];
  List<GiangVien> filteredGiangviens = [];
  bool isLoading = true;

  // Design constants
  static const _primaryColor = Color(0xFF2563EB);
  static const _primaryDark = Color(0xFF1E40AF);
  static const _borderColor = Color(0xFFE5E7EB);
  static const _hintColor = Color(0xFFD1D5DB);
  static const _subtitleColor = Color(0xFF9CA3AF);
  static const _textColor = Color(0xFF374151);
  static const _bgLight = Color(0xFFF9FAFB);
  static const double _kWebBreakpoint = 900.0;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    _loadGiangVien();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _loadGiangVien() async {
    setState(() => isLoading = true);
    try {
      final result = await GiangVienService.getAllGiangVien();
      if (mounted) {
        setState(() {
          if (result['success']) {
            giangviens = result['data'] ?? [];
            filteredGiangviens = giangviens;
          } else {
            _showSnackBar(result['message'] ?? 'Failed to load giangvien', Colors.red);
          }
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error: $e', Colors.red);
        setState(() => isLoading = false);
      }
    }
  }

  void _filterGiangVien(String query) {
    setState(() {
      filteredGiangviens = query.isEmpty
          ? giangviens
          : giangviens
              .where((giangvien) =>
                  giangvien.fullname.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter()),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  InputDecoration _dialogInputDecoration(String hint, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: _hintColor, fontSize: 14),
      filled: true,
      fillColor: _bgLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      suffixIcon: suffix,
    );
  }

  // Helper method to build image widget for both File and XFile
  Widget _buildImageWidget(dynamic selectedImage, String? networkImageUrl) {
    if (selectedImage != null) {
      if (selectedImage is File) {
        return Image.file(selectedImage, fit: BoxFit.cover);
      } else if (selectedImage is XFile) {
        return FutureBuilder<Uint8List>(
          future: selectedImage.readAsBytes(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Image.memory(snapshot.data!, fit: BoxFit.cover);
            }
            return const Center(
              child: CircularProgressIndicator(color: _primaryColor),
            );
          },
        );
      }
    }
    
    if (networkImageUrl != null && networkImageUrl.isNotEmpty) {
      return Image.network(
        networkImageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(Icons.person_rounded, size: 50, color: _hintColor),
        ),
      );
    }
    
    return const Center(
      child: Icon(Icons.image_outlined, size: 50, color: _hintColor),
    );
  }

  // ─── Shared widgets ────────────────────────────────────────────────────────

  String get _countText =>
      '${filteredGiangviens.length} giangvien${filteredGiangviens.length != 1 ? 's' : ''} found';

  Widget _buildRefreshButton() {
    return Container(
      decoration: BoxDecoration(
        color: _primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: const Icon(Icons.refresh_rounded, color: _primaryColor, size: 22),
        onPressed: _loadGiangVien,
        tooltip: 'Refresh',
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: searchController,
      onChanged: _filterGiangVien,
      style: GoogleFonts.inter(fontSize: 14, color: _textColor),
      decoration: InputDecoration(
        hintText: 'Search by name...',
        hintStyle: GoogleFonts.inter(color: _hintColor, fontSize: 14),
        prefixIcon: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Icon(Icons.search_rounded, color: _subtitleColor, size: 20),
        ),
        suffixIcon: searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close_rounded, color: _subtitleColor, size: 18),
                onPressed: () {
                  searchController.clear();
                  _filterGiangVien('');
                },
              )
            : null,
        filled: true,
        fillColor: _bgLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('All', selectedFilter == 'All'),
          const SizedBox(width: 8),
          _buildFilterChip('Active', selectedFilter == 'Active'),
          const SizedBox(width: 8),
          _buildFilterChip('Inactive', selectedFilter == 'Inactive'),
        ],
      ),
    );
  }

  /// Loading / empty / danh sách giangvien.
  /// Mobile: ListView 1 cột. Web: GridView nhiều cột.
  Widget _buildBody({required bool isWeb}) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: _primaryColor,
          strokeWidth: 2.5,
        ),
      );
    }

    if (filteredGiangviens.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_search_rounded, size: 56, color: _hintColor),
            const SizedBox(height: 12),
            Text(
              'No giangvien found',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: _subtitleColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (isWeb) {
      return GridView.builder(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 420,
          mainAxisExtent: 116,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: filteredGiangviens.length,
        itemBuilder: (context, index) => _buildGiangVienCard(filteredGiangviens[index]),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: filteredGiangviens.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildGiangVienCard(filteredGiangviens[index]),
    );
  }

  // ─── Mobile layout ─────────────────────────────────────────────────────────

  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'GiangVien Manager',
                            style: GoogleFonts.inter(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: _primaryDark,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _countText,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: _subtitleColor,
                            ),
                          ),
                        ],
                      ),
                      _buildRefreshButton(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSearchField(),
                  const SizedBox(height: 14),
                  _buildFilterChips(),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: _borderColor),

            // Body
            Expanded(child: _buildBody(isWeb: false)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _primaryColor,
        onPressed: () => _showAddGiangVienDialog(context),
        icon: const Icon(Icons.person_add_rounded, color: Colors.white, size: 20),
        label: Text(
          'Add GiangVien',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        elevation: 3,
      ),
    );
  }

  // ─── Web layout ────────────────────────────────────────────────────────────

  Widget _buildWebLayout() {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Row(
        children: [
          // Left sidebar (cuộn được khi cửa sổ thấp)
          Expanded(flex: 3, child: _buildWebSidebar()),
          // Right content
          Expanded(flex: 9, child: _buildWebContent()),
        ],
      ),
    );
  }

  Widget _buildWebSidebar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.people_alt_rounded,
                    color: Colors.white, size: 32),
              ),
              const SizedBox(height: 32),
              Text(
                'GiangVien\nManager',
                style: GoogleFonts.inter(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.1,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'View, search and manage\nall your giangvien in one place.',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: Colors.white.withValues(alpha: 0.8),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),

              // Stat card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.groups_rounded, color: Colors.white, size: 28),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${filteredGiangviens.length}',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          filteredGiangviens.length != 1 ? 'giangvien found' : 'giangvien found',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Add user button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: _primaryDark,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => _showAddGiangVienDialog(context),
                  icon: const Icon(Icons.person_add_rounded, size: 20),
                  label: Text(
                    'Add GiangVien',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
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

  Widget _buildWebContent() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar: title + search + refresh
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'All GiangVien',
                      style: GoogleFonts.inter(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: _primaryDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _countText,
                      style: GoogleFonts.inter(fontSize: 13, color: _subtitleColor),
                    ),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360, minWidth: 200),
                child: SizedBox(width: 360, child: _buildSearchField()),
              ),
              const SizedBox(width: 12),
              _buildRefreshButton(),
            ],
          ),
          const SizedBox(height: 20),
          _buildFilterChips(),
          const SizedBox(height: 20),

          // List card
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 40,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildBody(isWeb: true),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= _kWebBreakpoint) {
          return _buildWebLayout();
        }
        return _buildMobileLayout();
      },
    );
  }

  // ─── Cards ─────────────────────────────────────────────────────────────────

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor : _bgLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _primaryColor : _borderColor,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildGiangVienCard(GiangVien giangvien) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _borderColor),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 72,
              height: 72,
              color: _bgLight,
              child: giangvien.image != null && giangvien.image!.isNotEmpty
                  ? Image.network(
                      giangvien.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.person_rounded, size: 36, color: _hintColor),
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.person_rounded, size: 36, color: _hintColor),
                    ),
            ),
          ),
          const SizedBox(width: 14),

          // GiangVien Info
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  giangvien.fullname,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _primaryDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.class_outlined, size: 13, color: _subtitleColor),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${giangvien.sumClass} class${giangvien.sumClass != 1 ? 'es' : ''}',
                        style: GoogleFonts.inter(fontSize: 12, color: _subtitleColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 32,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor.withValues(alpha: 0.08),
                      foregroundColor: _primaryColor,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onPressed: () => _showGiangVienDetailDialog(context, giangvien),
                    icon: const Icon(Icons.edit_outlined, size: 14),
                    label: Text(
                      'GiangVien Details',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Favorite Icon
          GestureDetector(
            onTap: () => _showSnackBar('Favorite feature coming soon', Colors.blue),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _bgLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.favorite_outline_rounded, color: _subtitleColor, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Dialogs ───────────────────────────────────────────────────────────────

  void _showGiangVienDetailDialog(BuildContext context, GiangVien giangvien) {
    late TextEditingController fullnameController;
    late TextEditingController sumClassController;
    dynamic selectedImage; // Can be File or XFile

    fullnameController = TextEditingController(text: giangvien.fullname);
    sumClassController = TextEditingController(text: giangvien.sumClass.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Edit GiangVien',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: _primaryDark,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: _bgLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.close_rounded, color: _textColor, size: 18),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Avatar Section
                        Center(
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  color: _bgLight,
                                  child: _buildImageWidget(selectedImage, giangvien.image),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  _showImageSourceDialog(context, (image) {
                                    if (image != null) setState(() => selectedImage = image);
                                  });
                                },
                                child: Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: _primaryColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.15),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // IDGV (Read-only)
                        Text('IDGV', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: _textColor)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _borderColor),
                          ),
                          child: Text(
                            giangvien.idgv ?? '',
                            style: GoogleFonts.inter(fontSize: 14, color: _subtitleColor),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Full Name
                        Text('Full Name', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: _textColor)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: fullnameController,
                          style: GoogleFonts.inter(fontSize: 14, color: _textColor),
                          decoration: _dialogInputDecoration('Full Name'),
                        ),
                        const SizedBox(height: 16),

                        // Sum Class
                        Text('Sum Class', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: _textColor)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: sumClassController,
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.inter(fontSize: 14, color: _textColor),
                          decoration: _dialogInputDecoration('0'),
                        ),
                        const SizedBox(height: 24),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 46,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFEE2E2),
                                    foregroundColor: const Color(0xFFDC2626),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    _showSnackBar('Deleting giangvien...', Colors.blue);
                                    final result = await GiangVienService.deleteGiangVien(giangvien.idgv ?? '');
                                    if (result['success']) {
                                      _showSnackBar('GiangVien deleted successfully', Colors.green);
                                      _loadGiangVien();
                                    } else {
                                      _showSnackBar(result['message'] ?? 'Delete failed', Colors.red);
                                    }
                                  },
                                  child: Text('Delete', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 46,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF8B5CF6),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    _showSnackBar('Saving giangvien...', Colors.blue);
                                    final result = await GiangVienService.updateGiangVien(
                                      id: giangvien.idgv ?? '',
                                      fullname: fullnameController.text,
                                      sumClass: int.tryParse(sumClassController.text) ?? 0,
                                      imageFile: selectedImage,
                                    );
                                    if (result['success']) {
                                      _showSnackBar('GiangVien updated successfully', Colors.green);
                                      _loadGiangVien();
                                    } else {
                                      _showSnackBar(result['message'] ?? 'Update failed', Colors.red);
                                    }
                                  },
                                  child: Text('Save', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddGiangVienDialog(BuildContext context) {
    late TextEditingController idgvController;
    late TextEditingController fullnameController;
    late TextEditingController sumClassController;
    dynamic selectedImage; // Can be File or XFile

    idgvController = TextEditingController();
    fullnameController = TextEditingController();
    sumClassController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Add New GiangVien',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: _primaryDark,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: _bgLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.close_rounded, color: _textColor, size: 18),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Image Picker
                        Center(
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  color: _bgLight,
                                  child: _buildImageWidget(selectedImage, null),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  _showImageSourceDialog(context, (image) {
                                    if (image != null) setState(() => selectedImage = image);
                                  });
                                },
                                child: Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: _primaryColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.15),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // IDGV
                        Text('IDGV', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: _textColor)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: idgvController,
                          style: GoogleFonts.inter(fontSize: 14, color: _textColor),
                          decoration: _dialogInputDecoration('IDGV'),
                        ),
                        const SizedBox(height: 16),

                        // Full Name
                        Text('Full Name', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: _textColor)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: fullnameController,
                          style: GoogleFonts.inter(fontSize: 14, color: _textColor),
                          decoration: _dialogInputDecoration('Full Name'),
                        ),
                        const SizedBox(height: 16),

                        // Sum Class
                        Text('Sum Class', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: _textColor)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: sumClassController,
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.inter(fontSize: 14, color: _textColor),
                          decoration: _dialogInputDecoration('0'),
                        ),
                        const SizedBox(height: 24),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 46,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _bgLight,
                                    foregroundColor: const Color(0xFF6B7280),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: const BorderSide(color: _borderColor),
                                    ),
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Cancel', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 46,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _primaryColor,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () async {
                                    if (idgvController.text.isEmpty) {
                                      _showSnackBar('Please enter IDGV', Colors.red);
                                      return;
                                    }
                                    if (fullnameController.text.isEmpty) {
                                      _showSnackBar('Please enter a name', Colors.red);
                                      return;
                                    }
                                    Navigator.pop(context);
                                    _showSnackBar('Adding giangvien...', Colors.blue);
                                    final result = await GiangVienService.createGiangVien(
                                      idgv: idgvController.text.trim(),
                                      fullname: fullnameController.text.trim(),
                                      sumClass: int.tryParse(sumClassController.text) ?? 0,
                                      imageFile: selectedImage,
                                    );
                                    if (result['success']) {
                                      _showSnackBar('GiangVien added successfully', Colors.green);
                                      _loadGiangVien();
                                    } else {
                                      _showSnackBar(result['message'] ?? 'Add failed', Colors.red);
                                    }
                                  },
                                  child: Text('Add GiangVien', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showImageSourceDialog(BuildContext context, Function(File?) onImagePicked) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Select Image', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          content: Text('Choose image source', style: GoogleFonts.inter(color: _subtitleColor)),
          actions: [
            TextButton.icon(
              onPressed: () async {
                Navigator.pop(ctx);
                final image = await ImageService.pickImageFromGallery();
                onImagePicked(image);
              },
              icon: const Icon(Icons.photo_library_outlined, size: 18),
              label: Text('Gallery', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
            TextButton.icon(
              onPressed: () async {
                Navigator.pop(ctx);
                final image = await ImageService.pickImageFromCamera();
                onImagePicked(image);
              },
              icon: const Icon(Icons.camera_alt_outlined, size: 18),
              label: Text('Camera', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }
}