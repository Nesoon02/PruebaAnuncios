import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../models/cuota_compromiso_model.dart';
import '../models/pago_compromiso_model.dart';
import '../models/compromise_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_muchik/config/constants.dart';
import '../services/account_service.dart';
import '../services/compromise_service.dart';
import '../services/movement_service.dart';
import '../services/third_party_service.dart';
import '../services/pago_compromiso_service.dart';

class CompromisesScreen extends StatefulWidget {
  const CompromisesScreen({super.key});

  @override
  State<CompromisesScreen> createState() => _CompromisesScreenState();
}

class _CompromisesScreenState extends State<CompromisesScreen> {
  // --- COLORES OFICIALES ---
  final Color cAzulPetroleo = const Color(0xFF264653);
  final Color cVerdeMenta = const Color(0xFF2A9D8F);
  final Color cGrisClaro = const Color(0xFFF4F4F4);
  final Color cBlanco = const Color(0xFFFFFFFF);

  List<CompromiseModel> compromises = [];
  bool isLoading = false;
  String? errorMessage;
  String? _accessToken;
  int? _idCuenta;

  String? _profileImageUrl;
  bool _isLoadingImage = true;

  String? _selectedStatus; // Ej: 'Pendiente', 'Pagado', 'Vencido'
  int? _selectedMonth;
  int? _selectedYear;
  String? _selectedTipoCompromiso;
  int? _selectedTerceroId;

  List<Map<String, dynamic>> _terceros = [];

  @override
  void initState() {
    super.initState();
    _loadSelectedAccountAndFetchImage();
    _loadAccessTokenAndFetchCompromises();
  }

  Future<void> _fetchTerceros() async {
    if (_accessToken == null || _idCuenta == null) return;

    try {

      final data = await ThirdPartyService().getThirdParties(
        accountId: _idCuenta!,
        token: _accessToken!,
      );

      if(!mounted) return;

      setState(() {
        _terceros = data.cast<Map<String,dynamic>>();
      });

    } catch (e) {
      print('Error cargando terceros: $e');
    }
  }

  /// Función para enviar la actualización a la API
  Future<void> _updateCompromise(String id, String newName) async {
    if (_accessToken == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse('$API_BASE_URL/compromisos/$id');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: json.encode({
          'nombre': newName,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        CompromiseService().clearCache();
        MovementService().clearCache();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Compromiso actualizado'), backgroundColor: cVerdeMenta),
        );
        _fetchCompromises();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: ${response.body}'), backgroundColor: Colors.red),
        );
        setState(() { isLoading = false; });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e'), backgroundColor: Colors.red),
      );
      setState(() { isLoading = false; });
    }
  }

  /// Función para mostrar el diálogo de edición
  void _showEditDialog(CompromiseModel compromise) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: compromise.name);
    // Nota: amountController no se usa para editar el monto en este ejemplo, solo visualización si quisieras

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Editar "${compromise.name}"', style: TextStyle(color: cAzulPetroleo, fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nuevo Nombre',
                      labelStyle: TextStyle(color: cAzulPetroleo.withOpacity(0.6)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: cVerdeMenta)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El nombre no puede estar vacío';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final newName = nameController.text;
                  Navigator.pop(context);
                  _updateCompromise(compromise.id, newName);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: cVerdeMenta),
              child: Text('Guardar', style: TextStyle(color: cBlanco)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadSelectedAccountAndFetchImage() async {
    setState(() {
      _isLoadingImage = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      final int? selectedAccountId = prefs.getInt('idCuenta');

      if (token == null || selectedAccountId == null) {
        if (mounted) {
          setState(() {
            _profileImageUrl = null;
            _isLoadingImage = false;
          });
        }
        return;
      }

      final data = await AccountService().getAccount(
        accountId: selectedAccountId,
        token: token,
      );

      final accountData = data['cuenta'];
      final relativePath = accountData['ruta_imagen'] as String?;

      setState(() {
        if (relativePath != null) {
          _profileImageUrl = '$STORAGE_BASE_URL/$relativePath';
        } else {
          _profileImageUrl = null;
        }
        _isLoadingImage = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingImage = false;
        });
      }
    }
  }

  Future<void> _loadAccessTokenAndFetchCompromises() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('accessToken');
    _idCuenta = prefs.getInt('idCuenta');

    if (_accessToken != null && _idCuenta != null) {
      _fetchTerceros();
      _fetchCompromises();
    } else {
      if (!mounted) return;
      setState(() {
        errorMessage = 'No se encontró un token o una cuenta seleccionada.';
        isLoading = false;
      });
    }
  }

  Future<void> _fetchCompromises() async {
    if (!mounted || _accessToken == null || _idCuenta == null) return;
    setState(() { isLoading = true; errorMessage = null; });

    try {

      Map<String,String> filters = {};

      if (_selectedStatus != null && _selectedStatus != 'Todos') {
        filters['estado'] = _selectedStatus!;
      }

      if (_selectedMonth != null) {
        filters['mes'] = _selectedMonth.toString();
      }

      if (_selectedYear != null) {
        filters['anio'] = _selectedYear.toString();
      }

      if (_selectedTipoCompromiso != null) {
        filters['tipo_compromiso'] = _selectedTipoCompromiso!;
      }

      if (_selectedTerceroId != null) {
        filters['idtercero'] = _selectedTerceroId.toString();
      }

      final data = await CompromiseService().getCompromises(
        accountId: _idCuenta!,
        token: _accessToken!,
        filters: filters.isEmpty ? null : filters,
      );

      if(!mounted) return;

      setState(() {
        compromises = data;
      });

    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'No se pudo conectar al servidor. Revise su conexión.';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteCompromise(String compromiseId) async {
    if (_accessToken == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No se encontró el token de acceso.'), backgroundColor: Colors.red),
      );
      return;
    }

    final url = Uri.parse('$API_BASE_URL/compromisos/$compromiseId');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Accept': 'application/json',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 204) {
        CompromiseService().clearCache();
        MovementService().clearCache();
        PagoCompromisoService().clearAllCache();
        setState(() {
          compromises.removeWhere((compromise) => compromise.id == compromiseId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Compromiso eliminado con éxito.'), backgroundColor: cVerdeMenta),
        );
      } else if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: El compromiso no fue encontrado.'), backgroundColor: Colors.orange),
        );
      } else if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('accessToken');
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: ${response.statusCode}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo conectar al servidor.'), backgroundColor: Colors.red),
      );
    }
  }

  void _showDeleteConfirmation(CompromiseModel compromise) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cBlanco,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Eliminar Compromiso',
          style: TextStyle(
            color: cAzulPetroleo,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar el compromiso "${compromise.name}"?',
          style: TextStyle(color: cAzulPetroleo.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCompromise(compromise.id);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(CompromiseModel compromise) {
    Navigator.pushNamed(
      context,
      '/compromises_detail',
      arguments: compromise.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ DEFINIMOS EL FORMATO DE MONEDA AQUÍ
    final currencyFormat = NumberFormat.currency(
        locale: 'en_US',
        symbol: 'S/ ',
        decimalDigits: 2
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, true);
      },
      child: Scaffold(
        backgroundColor: cGrisClaro, // Fondo oficial #F4F4F4
        appBar: AppBar(
          backgroundColor: cBlanco,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: cAzulPetroleo),
            onPressed: () => Navigator.pop(context,true),
          ),
          title: Text(
            'Compromisos',
            style: TextStyle(
              color: cAzulPetroleo,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.notifications_outlined, color: cAzulPetroleo),
              onPressed: () {
                Navigator.pushNamed(context, '/notifications');
              },
            ),
            InkWell(
              onTap: () async {
                final result = await Navigator.pushNamed(context, '/accounts');

                if (result == true) {
                  print('Perfil compromisos');
                  await _loadSelectedAccountAndFetchImage();
                }

              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: cVerdeMenta.withOpacity(0.2), // Fondo suave Mint
                  shape: BoxShape.circle,
                ),
                child: _isLoadingImage
                    ? Center(
                    child: CircularProgressIndicator(
                      color: cVerdeMenta,
                      strokeWidth: 2,
                    ))
                    : _profileImageUrl != null
                    ? ClipOval(
                  child: Image.network(
                    _profileImageUrl!,
                    fit: BoxFit.cover,
                    width: 32,
                    height: 32,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.person, size: 20, color: cAzulPetroleo);
                    },
                  ),
                )
                    : Icon(Icons.person, size: 20, color: cAzulPetroleo),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.pushNamed(context, '/compromises_tiers');

                    if (result == true) {
                      print('Perfil compromisos regreso desde terceros');
                      await _loadSelectedAccountAndFetchImage();
                      _fetchCompromises();
                    }

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cAzulPetroleo, // Botón oficial Azul Petróleo
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    shadowColor: cAzulPetroleo.withOpacity(0.3),
                  ),
                  icon: Icon(Icons.people_alt, color: cBlanco),
                  label: Text(
                    'Ver mis terceros',
                    style: TextStyle(
                      color: cBlanco,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Mis compromisos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: cAzulPetroleo,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle_rounded, color: cVerdeMenta, size: 30),
                    tooltip: 'Registrar Nuevo Compromiso',
                    onPressed: () async {
                      await Navigator.pushNamed(context, '/compromises_create')
                          .then((_) => _fetchCompromises());
                      await _loadSelectedAccountAndFetchImage();

                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),
              _buildFiltersSection(),
              const SizedBox(height: 24),
              if (isLoading)
                Center(child: CircularProgressIndicator(color: cVerdeMenta))
              else if (errorMessage != null)
                Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red)))
              else if (compromises.isEmpty)
                  Center(child: Text('No hay compromisos registrados.', style: TextStyle(color: cAzulPetroleo.withOpacity(0.6))))
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: compromises.length,
                    itemBuilder: (context, index) {
                      final compromise = compromises[index];
                      // ✅ PASAMOS EL FORMATTER
                      return _buildCompromiseItem(compromise, currencyFormat);
                    },
                  ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildFiltersSection() {
    final List<String> statusOptions = ['Todos', 'Pendiente', 'Pagado'];
    final Map<int, String> monthOptions = {
      0: 'Todos',
      for (var i = 1; i <= 12; i++) i: DateFormat('MMMM', 'es').format(DateTime(0, i))
    };
    final currentYear = DateTime.now().year;
    final List<int> yearOptions = [0] + List<int>.generate(7, (i) => currentYear - 5 + i);

    final Map<int, String> tercerosOptions = {
      0: 'Todos',
      for (var t in _terceros)
        t['id']: t['nombre'],
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cBlanco,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: statusOptions.map((status) {
              final bool isSelected = (_selectedStatus == null && status == 'Todos') || (_selectedStatus == status);
              return ChoiceChip(
                label: Text(status),
                selected: isSelected,
                onSelected: (bool selected) {
                  if (selected) {
                    setState(() {
                      _selectedStatus = (status == 'Todos') ? null : status;
                      _fetchCompromises();
                    });
                  }
                },
                backgroundColor: cGrisClaro,
                selectedColor: cVerdeMenta.withOpacity(0.2), // Fondo seleccionado
                labelStyle: TextStyle(
                  color: isSelected ? cAzulPetroleo : cAzulPetroleo.withOpacity(0.6),
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? cVerdeMenta : Colors.transparent,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                showCheckmark: false,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // --- Fila para Mes y Año ---
          Row(
            children: [
              // --- Dropdown Mes ---
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _selectedMonth ?? 0,
                  decoration: InputDecoration(
                    labelText: 'Mes Creación',
                    labelStyle: TextStyle(color: cAzulPetroleo.withOpacity(0.6)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: cGrisClaro,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                  items: monthOptions.entries.map((entry) {
                    String monthName = entry.value;
                    if (monthName != 'Todos') {
                      monthName = monthName[0].toUpperCase() + monthName.substring(1);
                    }
                    return DropdownMenuItem<int>(
                      value: entry.key,
                      child: Text(monthName, overflow: TextOverflow.ellipsis, style: TextStyle(color: cAzulPetroleo)),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      _selectedMonth = (newValue == 0) ? null : newValue;
                      _fetchCompromises();
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),

              // --- Dropdown Año ---
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _selectedYear ?? 0,
                  decoration: InputDecoration(
                    labelText: 'Año Creación',
                    labelStyle: TextStyle(color: cAzulPetroleo.withOpacity(0.6)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: cGrisClaro,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                  items: yearOptions.map((year) {
                    return DropdownMenuItem<int>(
                      value: year,
                      child: Text(year == 0 ? 'Todos' : year.toString(), style: TextStyle(color: cAzulPetroleo)),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      _selectedYear = (newValue == 0) ? null : newValue;
                      _fetchCompromises();
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // --- Fila Tipo y Tercero ---
          Row(
            children: [

              // --- Tipo Compromiso ---
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedTipoCompromiso,
                  decoration: InputDecoration(
                    labelText: 'Tipo',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: cGrisClaro,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                  items: ['Todos', 'Deuda', 'Préstamo']
                      .map((tipo) => DropdownMenuItem<String>(
                    value: tipo == 'Todos' ? null : tipo,
                    child: Text(tipo),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTipoCompromiso = value;
                      _fetchCompromises();
                    });
                  },
                ),
              ),

              const SizedBox(width: 16),

              // --- Tercero ---
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _selectedTerceroId ?? 0,
                  decoration: InputDecoration(
                    labelText: 'Tercero',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: cGrisClaro,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                  items: tercerosOptions.entries.map((entry) {
                    return DropdownMenuItem<int>(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTerceroId = (value == 0) ? null : value;
                      _fetchCompromises();
                    });
                  },
                ),
              ),
            ],
          ),

          if (_selectedStatus != null || _selectedMonth != null || _selectedYear != null || _selectedTipoCompromiso != null || _selectedTerceroId != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _selectedStatus = null;
                    _selectedMonth = null;
                    _selectedYear = null;
                    _selectedTipoCompromiso = null;
                    _selectedTerceroId = null;
                    _fetchCompromises();
                  });
                },
                child: Text('Limpiar Filtros', style: TextStyle(color: cVerdeMenta, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCompromiseItem(CompromiseModel compromise, NumberFormat currencyFormat) {
    final formattedDate = compromise.date.isNotEmpty
        ? DateFormat('dd/MM/yyyy').format(DateTime.parse(compromise.date))
        : 'Sin fecha';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: cBlanco,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  compromise.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: cAzulPetroleo,
                  ),
                ),
                const SizedBox(height: 4),
                if (compromise.tipoCompromiso != null) ...[
                  Row(
                    children: [
                      Icon(
                        compromise.tipoCompromiso!.toLowerCase() == 'deuda'
                            ? Icons.south_west
                            : Icons.north_east,
                        size: 16,
                        color: compromise.tipoCompromiso!.toLowerCase() == 'deuda'
                            ? Colors.green[600]
                            : Colors.red[400],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        compromise.tipoCompromiso!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: compromise.tipoCompromiso!.toLowerCase() == 'deuda'
                              ? Colors.green[600]
                              : Colors.red[400],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
                if (compromise.nombreTercero != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 14,
                        color: cAzulPetroleo.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          compromise.nombreTercero!,
                          style: TextStyle(
                            fontSize: 13,
                            color: cAzulPetroleo.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 13,
                      color: cAzulPetroleo.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: cAzulPetroleo.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.payments_outlined,
                      size: 15,
                      color: cAzulPetroleo.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      currencyFormat.format(compromise.montoTotal ?? compromise.amount),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: cAzulPetroleo.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.info_outline, color: cAzulPetroleo),
            onPressed: () => _navigateToDetail(compromise),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.edit_outlined, color: cVerdeMenta),
            onPressed: () {
              _showEditDialog(compromise);
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          IconButton(
            icon: Icon(Icons.delete_outlined, color: Colors.red[400]),
            onPressed: () => _showDeleteConfirmation(compromise),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: cBlanco,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: cBlanco,
        selectedItemColor: cAzulPetroleo, // Color activo oficial
        unselectedItemColor: Colors.grey[400],
        selectedFontSize: 12,
        unselectedFontSize: 12,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Reportes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Presupuestos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            activeIcon: Icon(Icons.category),
            label: 'Categorías',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/dashboard');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/reports');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/budgets');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/categories');
              break;
            case 4:
              Navigator.pushReplacementNamed(context, '/settings');
              break;
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
