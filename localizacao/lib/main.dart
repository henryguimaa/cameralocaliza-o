
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

const Color noite = Color(0xFF080D1B);
const Color azulNoite = Color(0xFF101B32);
const Color dourado = Color(0xFFD9B66D);
const Color pergaminho = Color(0xFFF0DDB1);
const Color tinta = Color(0xFF382719);
const Color vinho = Color(0xFF740F27);
const Color prata = Color(0xFFD8F3FF);

void main() {
  runApp(const AplicativoHogwarts());
}

class AplicativoHogwarts extends StatefulWidget {
  const AplicativoHogwarts({super.key});

  @override
  State<AplicativoHogwarts> createState() => _AplicativoHogwartsState();
}

class _AplicativoHogwartsState extends State<AplicativoHogwarts> {
  bool temaEscuro = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hogwarts | Perfil Mágico',
      themeMode: temaEscuro ? ThemeMode.dark : ThemeMode.light,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: noite,
        colorScheme: ColorScheme.fromSeed(
          seedColor: dourado,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFE8D8B5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: vinho,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: TelaHogwarts(
        temaEscuro: temaEscuro,
        alternarTema: () => setState(() => temaEscuro = !temaEscuro),
      ),
    );
  }
}

class TelaHogwarts extends StatefulWidget {
  final bool temaEscuro;
  final VoidCallback alternarTema;

  const TelaHogwarts({
    super.key,
    required this.temaEscuro,
    required this.alternarTema,
  });

  @override
  State<TelaHogwarts> createState() => _TelaHogwartsState();
}

class _TelaHogwartsState extends State<TelaHogwarts>
    with SingleTickerProviderStateMixin {
  final ImagePicker seletorImagem = ImagePicker();
  final TextEditingController nomeController =
      TextEditingController(text: 'Aprendiz de Hogwarts');

  File? foto;
  Position? posicao;
  bool carregandoLocalizacao = false;
  String mensagem = 'Sua localização mágica ainda não foi revelada.';
  String casa = 'Grifinória';

  late final AnimationController animacao;

  final Map<String, Map<String, dynamic>> casas = {
    'Grifinória': {
      'sigla': 'G',
      'cor': const Color(0xFF9E2338),
      'animal': 'Leão',
      'lema': 'Coragem e determinação',
      'icone': Icons.local_fire_department_rounded,
    },
    'Sonserina': {
      'sigla': 'S',
      'cor': const Color(0xFF26765A),
      'animal': 'Serpente',
      'lema': 'Ambição e engenhosidade',
      'icone': Icons.water_rounded,
    },
    'Corvinal': {
      'sigla': 'C',
      'cor': const Color(0xFF315D98),
      'animal': 'Águia',
      'lema': 'Sabedoria e criatividade',
      'icone': Icons.auto_awesome_rounded,
    },
    'Lufa-Lufa': {
      'sigla': 'L',
      'cor': const Color(0xFFAD8428),
      'animal': 'Texugo',
      'lema': 'Lealdade e paciência',
      'icone': Icons.wb_sunny_rounded,
    },
  };

  Color get corCasa => casas[casa]!['cor'] as Color;

  @override
  void initState() {
    super.initState();
    animacao = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    animacao.dispose();
    nomeController.dispose();
    super.dispose();
  }

  void mostrarMensagem(String texto) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: const Color(0xFF27243A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> selecionarFoto(ImageSource origem) async {
    try {
      final XFile? imagem = await seletorImagem.pickImage(
        source: origem,
        imageQuality: 88,
        maxWidth: 1400,
      );

      if (imagem != null && mounted) {
        setState(() => foto = File(imagem.path));
      }
    } catch (_) {
      mostrarMensagem('Não foi possível abrir a imagem. Tente novamente.');
    }
  }

  void abrirOpcoesFoto() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF171E30),
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'ESCOLHA SEU RETRATO',
                style: TextStyle(
                  color: dourado,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_rounded,
                  color: dourado,
                ),
                title: const Text('Tirar uma foto'),
                subtitle: const Text('Use a câmera do dispositivo'),
                onTap: () {
                  Navigator.pop(context);
                  selecionarFoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_rounded,
                  color: dourado,
                ),
                title: const Text('Escolher da galeria'),
                subtitle: const Text('Selecione uma imagem existente'),
                onTap: () {
                  Navigator.pop(context);
                  selecionarFoto(ImageSource.gallery);
                },
              ),
              if (foto != null)
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  title: const Text('Remover retrato'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => foto = null);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> revelarLocalizacao() async {
    setState(() {
      carregandoLocalizacao = true;
      mensagem = 'O Patrono está procurando sua localização...';
    });

    try {
      final bool servicoAtivo =
          await Geolocator.isLocationServiceEnabled();

      if (!servicoAtivo) {
        if (mounted) {
          setState(() {
            mensagem =
                'Ative a localização do dispositivo e tente novamente.';
          });
        }
        return;
      }

      LocationPermission permissao = await Geolocator.checkPermission();

      if (permissao == LocationPermission.denied) {
        permissao = await Geolocator.requestPermission();
      }

      if (permissao == LocationPermission.denied) {
        if (mounted) {
          setState(() {
            mensagem =
                'Permita o acesso à localização para revelar as coordenadas.';
          });
        }
        return;
      }

      if (permissao == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            mensagem =
                'A permissão está bloqueada. Libere a localização nas configurações do aplicativo.';
          });
        }
        return;
      }

      final Position resultado = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 25),
        ),
      );

      if (!mounted) return;

      setState(() {
        posicao = resultado;
        mensagem = 'Expecto Patronum! Sua localização foi revelada.';
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          mensagem =
              'A magia falhou desta vez. Verifique o GPS e tente novamente.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => carregandoLocalizacao = false);
      }
    }
  }

  Future<void> copiarLinkMapa() async {
    if (posicao == null) return;

    final String link =
        'https://www.google.com/maps/search/?api=1&query=${posicao!.latitude},${posicao!.longitude}';

    await Clipboard.setData(ClipboardData(text: link));

    if (mounted) {
      mostrarMensagem(
        'Link do Google Maps copiado! Cole-o no navegador para abrir o mapa.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool escuro = widget.temaEscuro;
    final Color textoPrincipal =
        escuro ? const Color(0xFFF7EBD0) : tinta;
    final Color textoSecundario =
        escuro ? const Color(0xFFB8C1D4) : const Color(0xFF71604B);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: escuro
                ? const [
                    Color(0xFF070B17),
                    Color(0xFF121D35),
                    Color(0xFF080D1B),
                  ]
                : const [
                    Color(0xFFF2E4C4),
                    Color(0xFFD9C39A),
                    Color(0xFFF3E8D1),
                  ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 15, 16, 4),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF9C263B),
                              Color(0xFF4D1021),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: dourado.withOpacity(0.9),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: vinho.withOpacity(0.35),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: dourado,
                          size: 25,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'HOGWARTS',
                              style: TextStyle(
                                color: textoPrincipal,
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 3.2,
                              ),
                            ),
                            Text(
                              'ARQUIVO DE ALUNOS',
                              style: TextStyle(
                                color: textoSecundario,
                                fontSize: 9,
                                letterSpacing: 2.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: escuro
                              ? Colors.white.withOpacity(0.045)
                              : Colors.black.withOpacity(0.04),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: dourado.withOpacity(0.25),
                          ),
                        ),
                        child: IconButton(
                          tooltip: 'Alternar tema',
                          onPressed: widget.alternarTema,
                          icon: Icon(
                            escuro
                                ? Icons.wb_sunny_outlined
                                : Icons.nightlight_round,
                            color: dourado,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Container(
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: dourado.withOpacity(0.75),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.28),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CustomPaint(
                          painter: CasteloHogwartsPainter(),
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.08),
                                Colors.transparent,
                                Colors.black.withOpacity(0.72),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 18,
                          left: 18,
                          right: 18,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: dourado.withOpacity(0.55),
                                  ),
                                ),
                                child: const Text(
                                  '✦  A ESCOLA DE MAGIA  ✦',
                                  style: TextStyle(
                                    color: Color(0xFFFFE7AD),
                                    fontSize: 9,
                                    letterSpacing: 1.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Hogwarts',
                                style: TextStyle(
                                  color: Color(0xFFFFE7AD),
                                  fontSize: 38,
                                  height: 1,
                                  fontWeight: FontWeight.w900,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black87,
                                      blurRadius: 14,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Seu próximo capítulo começa aqui.',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 11,
                                  shadows: const [
                                    Shadow(
                                      color: Colors.black,
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 18,
                          right: 18,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.nights_stay_rounded,
                                color: dourado,
                                size: 17,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'ONDE A MAGIA GANHA VIDA',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.95),
                                    fontSize: 9,
                                    letterSpacing: 1.8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.auto_awesome,
                                color: dourado,
                                size: 17,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 27, 20, 13),
                  child: Row(
                    children: [
                      Container(
                        width: 70,
                        height: 82,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF8C1C31),
                              Color(0xFF4C1020),
                            ],
                          ),
                          border: Border.all(
                            color: dourado,
                            width: 1.7,
                          ),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(34),
                            bottom: Radius.circular(9),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: vinho.withOpacity(0.25),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shield_rounded,
                              size: 35,
                              color: dourado,
                            ),
                            Text(
                              'H',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'BEM-VINDO A HOGWARTS',
                              style: TextStyle(
                                color: dourado,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.7,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Seu legado mágico começa aqui.',
                              style: TextStyle(
                                color: textoPrincipal,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Escolha sua casa e registre seu retrato.',
                              style: TextStyle(
                                color: textoSecundario,
                                fontSize: 11,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                  child: _TituloSecao(
                    titulo: 'AS QUATRO CASAS',
                    subtitulo: 'Onde você pertence?',
                    claro: textoPrincipal,
                    secundario: textoSecundario,
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final double largura =
                          (constraints.maxWidth - 10) / 2;

                      return Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: casas.entries.map((entry) {
                          return SizedBox(
                            width: largura,
                            child: _CasaCartao(
                              nome: entry.key,
                              sigla: entry.value['sigla'] as String,
                              cor: entry.value['cor'] as Color,
                              animal: entry.value['animal'] as String,
                              lema: entry.value['lema'] as String,
                              selecionada: casa == entry.key,
                              aoTocar: () {
                                setState(() => casa = entry.key);
                              },
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 27, 18, 0),
                  child: _TituloSecao(
                    titulo: 'REGISTRO OFICIAL',
                    subtitulo: 'Sua ficha pessoal de Hogwarts',
                    claro: textoPrincipal,
                    secundario: textoSecundario,
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: pergaminho,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: dourado,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.22),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: 13,
                          top: 13,
                          child: Icon(
                            Icons.auto_awesome,
                            color: tinta.withOpacity(0.12),
                            size: 32,
                          ),
                        ),
                        Positioned(
                          left: 12,
                          bottom: 12,
                          child: Icon(
                            Icons.auto_awesome,
                            color: tinta.withOpacity(0.1),
                            size: 22,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'MINISTÉRIO DA MAGIA',
                                          style: TextStyle(
                                            color: tinta,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1.8,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          'Ficha de aluno',
                                          style: TextStyle(
                                            color: vinho,
                                            fontSize: 26,
                                            fontWeight: FontWeight.w900,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 47,
                                    height: 47,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: vinho.withOpacity(0.55),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.workspace_premium_outlined,
                                      color: vinho,
                                      size: 28,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 13),
                              Container(
                                height: 1,
                                color: tinta.withOpacity(0.25),
                              ),
                              const SizedBox(height: 20),
                              GestureDetector(
                                onTap: abrirOpcoesFoto,
                                child: Container(
                                  width: 126,
                                  height: 145,
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDAC394),
                                    border: Border.all(
                                      color: vinho,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: tinta.withOpacity(0.18),
                                        blurRadius: 9,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: foto != null
                                      ? Image.file(
                                          foto!,
                                          fit: BoxFit.cover,
                                          width: 114,
                                          height: 133,
                                        )
                                      : Container(
                                          color: const Color(0xFFE6D3A9),
                                          child: const Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.person_outline_rounded,
                                                color: vinho,
                                                size: 58,
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'SEU RETRATO',
                                                style: TextStyle(
                                                  color: tinta,
                                                  fontSize: 9,
                                                  letterSpacing: 1,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              TextButton.icon(
                                onPressed: abrirOpcoesFoto,
                                icon: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: vinho,
                                  size: 16,
                                ),
                                label: const Text(
                                  'ALTERAR RETRATO',
                                  style: TextStyle(
                                    color: vinho,
                                    fontSize: 10,
                                    letterSpacing: 1,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'NOME DO BRUXO OU DA BRUXA',
                                  style: TextStyle(
                                    color: tinta,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              TextField(
                                controller: nomeController,
                                style: const TextStyle(
                                  color: tinta,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Digite seu nome',
                                  hintStyle: TextStyle(
                                    color: tinta.withOpacity(0.5),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: tinta.withOpacity(0.35),
                                    ),
                                  ),
                                  focusedBorder:
                                      const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: vinho,
                                      width: 2,
                                    ),
                                  ),
                                  suffixIcon: const Icon(
                                    Icons.edit_rounded,
                                    color: vinho,
                                    size: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: corCasa.withOpacity(0.09),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: corCasa.withOpacity(0.4),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      casas[casa]!['icone'] as IconData,
                                      color: corCasa,
                                      size: 25,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'CASA DESIGNADA',
                                            style: TextStyle(
                                              color: tinta,
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            casa.toUpperCase(),
                                            style: TextStyle(
                                              color: corCasa,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 1.1,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            casas[casa]!['lema'] as String,
                                            style: TextStyle(
                                              color: tinta.withOpacity(0.75),
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 19),
                              Container(
                                width: double.infinity,
                                height: 1,
                                color: tinta.withOpacity(0.2),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'Draco dormiens nunquam titillandus',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: tinta,
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Nunca faça cócegas em um dragão adormecido.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: tinta.withOpacity(0.7),
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 43,
                            height: 43,
                            decoration: BoxDecoration(
                              color: dourado.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(
                                color: dourado.withOpacity(0.3),
                              ),
                            ),
                            child: const Icon(
                              Icons.explore_rounded,
                              color: dourado,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'O MAPA MÁGICO',
                                  style: TextStyle(
                                    color: textoPrincipal,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Revele sua posição no mundo dos trouxas.',
                                  style: TextStyle(
                                    color: textoSecundario,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(17),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: escuro
                                ? const [
                                    Color(0xFF121F36),
                                    Color(0xFF0B1324),
                                  ]
                                : const [
                                    Color(0xFF493C32),
                                    Color(0xFF302820),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: prata.withOpacity(0.35),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 185,
                              width: double.infinity,
                              child: AnimatedBuilder(
                                animation: animacao,
                                builder: (context, child) {
                                  return CustomPaint(
                                    painter: PatronoPainter(
                                      progresso: animacao.value,
                                      ativo: posicao != null ||
                                          carregandoLocalizacao,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'EXPECTO PATRONUM',
                              style: TextStyle(
                                color: prata,
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Um feitiço para revelar as coordenadas do seu dispositivo.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.72),
                                fontSize: 11,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: FilledButton.icon(
                                onPressed: carregandoLocalizacao
                                    ? null
                                    : revelarLocalizacao,
                                style: FilledButton.styleFrom(
                                  backgroundColor: vinho,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor:
                                      vinho.withOpacity(0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13),
                                    side: const BorderSide(
                                      color: dourado,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                icon: carregandoLocalizacao
                                    ? const SizedBox(
                                        width: 19,
                                        height: 19,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.auto_awesome),
                                label: Text(
                                  carregandoLocalizacao
                                      ? 'CONSULTANDO AS ESTRELAS...'
                                      : 'REVELAR LOCALIZAÇÃO',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.045),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    posicao != null
                                        ? Icons.check_circle_outline
                                        : Icons.info_outline,
                                    color: posicao != null
                                        ? const Color(0xFFB9F3D1)
                                        : prata.withOpacity(0.8),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 9),
                                  Expanded(
                                    child: Text(
                                      mensagem,
                                      style: TextStyle(
                                        color: posicao != null
                                            ? const Color(0xFFB9F3D1)
                                            : Colors.white70,
                                        fontSize: 11,
                                        height: 1.45,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (posicao != null) ...[
                              const SizedBox(height: 15),
                              _CoordenadaLinha(
                                icone: Icons.navigation_rounded,
                                titulo: 'LATITUDE',
                                valor: posicao!.latitude.toStringAsFixed(6),
                              ),
                              const SizedBox(height: 9),
                              _CoordenadaLinha(
                                icone: Icons.explore_rounded,
                                titulo: 'LONGITUDE',
                                valor: posicao!.longitude.toStringAsFixed(6),
                              ),
                              const SizedBox(height: 9),
                              _CoordenadaLinha(
                                icone: Icons.gps_fixed_rounded,
                                titulo: 'PRECISÃO',
                                valor:
                                    '${posicao!.accuracy.toStringAsFixed(1)} metros',
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: copiarLinkMapa,
                                  icon: const Icon(Icons.copy_rounded),
                                  label: const Text('COPIAR LINK DO GOOGLE MAPS'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: prata,
                                    side: BorderSide(
                                      color: prata.withOpacity(0.6),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 32),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: dourado,
                        size: 24,
                      ),
                      const SizedBox(height: 9),
                      Text(
                        'A MAGIA ESTÁ EM VOCÊ',
                        style: TextStyle(
                          color: textoPrincipal,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Hogwarts  •  Perfil mágico  •  Localização',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textoSecundario,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 13),
                      Container(
                        width: 65,
                        height: 1,
                        color: dourado.withOpacity(0.55),
                      ),
                    ],
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

class _TituloSecao extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final Color claro;
  final Color secundario;

  const _TituloSecao({
    required this.titulo,
    required this.subtitulo,
    required this.claro,
    required this.secundario,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: TextStyle(
            color: claro,
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.7,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitulo,
          style: TextStyle(
            color: secundario,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _CasaCartao extends StatelessWidget {
  final String nome;
  final String sigla;
  final Color cor;
  final String animal;
  final String lema;
  final bool selecionada;
  final VoidCallback aoTocar;

  const _CasaCartao({
    required this.nome,
    required this.sigla,
    required this.cor,
    required this.animal,
    required this.lema,
    required this.selecionada,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selecionada,
      label: '$nome, casa de $animal',
      child: GestureDetector(
        onTap: aoTocar,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: selecionada
                  ? [cor.withOpacity(0.95), cor.withOpacity(0.65)]
                  : [cor.withOpacity(0.19), cor.withOpacity(0.08)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selecionada ? dourado : cor.withOpacity(0.55),
              width: selecionada ? 1.8 : 1,
            ),
            boxShadow: selecionada
                ? [
                    BoxShadow(
                      color: cor.withOpacity(0.24),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 37,
                    height: 37,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.16),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: dourado.withOpacity(
                          selecionada ? 0.8 : 0.35,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        sigla,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (selecionada)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFFFFE7AD),
                      size: 19,
                    )
                  else
                    Icon(
                      Icons.shield_outlined,
                      color: Colors.white.withOpacity(0.65),
                      size: 19,
                    ),
                ],
              ),
              const SizedBox(height: 11),
              Text(
                nome,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                animal.toUpperCase(),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 8,
                  letterSpacing: 1.3,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                lema,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.82),
                  fontSize: 10,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoordenadaLinha extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String valor;

  const _CoordenadaLinha({
    required this.icone,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.055),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: prata.withOpacity(0.18),
        ),
      ),
      child: Row(
        children: [
          Icon(icone, color: prata, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
          ),
          Flexible(
            child: Text(
              valor,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: prata,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CasteloHogwartsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Rect area = Offset.zero & size;

    canvas.drawRect(
      area,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF060B20),
            Color(0xFF142344),
            Color(0xFF3C4664),
          ],
        ).createShader(area),
    );

    final math.Random aleatorio = math.Random(19);

    for (int i = 0; i < 130; i++) {
      final double x = aleatorio.nextDouble() * size.width;
      final double y = aleatorio.nextDouble() * size.height * 0.76;
      final double raio = aleatorio.nextDouble() * 1.35 + 0.3;

      canvas.drawCircle(
        Offset(x, y),
        raio,
        Paint()
          ..color = Colors.white.withOpacity(
            aleatorio.nextDouble() * 0.65 + 0.2,
          ),
      );
    }

    final Offset lua = Offset(size.width * 0.8, size.height * 0.2);

    canvas.drawCircle(
      lua,
      27,
      Paint()
        ..color = const Color(0xFFFFDFA0).withOpacity(0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

    canvas.drawCircle(
      lua,
      19,
      Paint()..color = const Color(0xFFFFE9BC),
    );

    canvas.drawCircle(
      Offset(lua.dx + 8, lua.dy - 5),
      18,
      Paint()..color = const Color(0xFF101B36),
    );

    final Paint montanhaDistante =
        Paint()..color = const Color(0xFF263453);

    final Path montanhasDistantes = Path()
      ..moveTo(0, size.height * 0.66)
      ..lineTo(size.width * 0.13, size.height * 0.42)
      ..lineTo(size.width * 0.22, size.height * 0.57)
      ..lineTo(size.width * 0.39, size.height * 0.37)
      ..lineTo(size.width * 0.55, size.height * 0.64)
      ..lineTo(size.width * 0.74, size.height * 0.43)
      ..lineTo(size.width, size.height * 0.63)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(montanhasDistantes, montanhaDistante);

    final Path montanhasProximas = Path()
      ..moveTo(0, size.height * 0.78)
      ..quadraticBezierTo(
        size.width * 0.22,
        size.height * 0.62,
        size.width * 0.4,
        size.height * 0.78,
      )
      ..quadraticBezierTo(
        size.width * 0.7,
        size.height * 0.58,
        size.width,
        size.height * 0.76,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      montanhasProximas,
      Paint()..color = const Color(0xFF17233B),
    );

    final Paint pedra = Paint()..color = const Color(0xFF0B1328);
    final Paint pedraIluminada = Paint()..color = const Color(0xFF17213A);
    final double base = size.height * 0.87;

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.12,
        size.height * 0.51,
        size.width * 0.76,
        base - size.height * 0.51,
      ),
      pedra,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.18,
        size.height * 0.58,
        size.width * 0.64,
        base - size.height * 0.58,
      ),
      pedraIluminada,
    );

    void torre(double x, double largura, double topo) {
      canvas.drawRect(
        Rect.fromLTRB(x, topo, x + largura, base),
        pedra,
      );

      final Path telhado = Path()
        ..moveTo(x - 5, topo)
        ..lineTo(x + largura / 2, topo - largura * 0.9)
        ..lineTo(x + largura + 5, topo)
        ..close();

      canvas.drawPath(telhado, pedra);

      canvas.drawRect(
        Rect.fromLTWH(
          x + largura * 0.42,
          topo - largura * 0.94,
          largura * 0.16,
          largura * 0.22,
        ),
        pedra,
      );

      for (double wy = topo + 13; wy < base - 10; wy += 18) {
        final Rect janela = Rect.fromLTWH(
          x + largura * 0.29,
          wy,
          largura * 0.18,
          7,
        );

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            janela,
            const Radius.circular(3),
          ),
          Paint()
            ..color = const Color(0xFFFFD47C)
            ..maskFilter = const MaskFilter.blur(
              BlurStyle.normal,
              1.5,
            ),
        );
      }

      canvas.drawRect(
        Rect.fromLTWH(
          x + largura * 0.12,
          topo + 5,
          largura * 0.08,
          base - topo - 5,
        ),
        Paint()..color = Colors.white.withOpacity(0.035),
      );
    }

    torre(size.width * 0.12, size.width * 0.12, size.height * 0.43);
    torre(size.width * 0.27, size.width * 0.11, size.height * 0.34);
    torre(size.width * 0.43, size.width * 0.14, size.height * 0.25);
    torre(size.width * 0.62, size.width * 0.11, size.height * 0.35);
    torre(size.width * 0.76, size.width * 0.12, size.height * 0.44);

    final Path torreCentral = Path()
      ..moveTo(size.width * 0.38, size.height * 0.43)
      ..lineTo(size.width * 0.5, size.height * 0.14)
      ..lineTo(size.width * 0.62, size.height * 0.43)
      ..close();

    canvas.drawPath(torreCentral, pedra);

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.47,
        size.height * 0.29,
        size.width * 0.06,
        size.height * 0.19,
      ),
      pedraIluminada,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.35,
        size.height * 0.65,
        size.width * 0.3,
        size.height * 0.22,
      ),
      pedra,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.4,
        size.height * 0.67,
        size.width * 0.2,
        size.height * 0.19,
      ),
      pedraIluminada,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.46,
          size.height * 0.72,
          size.width * 0.08,
          size.height * 0.15,
        ),
        const Radius.circular(22),
      ),
      Paint()
        ..color = const Color(0xFFFFC76A)
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          2,
        ),
    );

    final Path colina = Path()
      ..moveTo(0, size.height * 0.9)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.77,
        size.width * 0.53,
        size.height * 0.91,
      )
      ..quadraticBezierTo(
        size.width * 0.82,
        size.height * 0.78,
        size.width,
        size.height * 0.88,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      colina,
      Paint()..color = const Color(0xFF070D1B),
    );

    for (int i = 0; i < 7; i++) {
      final double x = size.width * (0.08 + i * 0.14);
      final double y = size.height * (0.3 + (i % 3) * 0.065);

      canvas.drawRect(
        Rect.fromLTWH(x, y, 3, 15),
        Paint()..color = const Color(0xFFE9D8AE),
      );

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x + 1.5, y - 2),
          width: 5,
          height: 8,
        ),
        Paint()..color = const Color(0xFFFFD27A),
      );

      canvas.drawCircle(
        Offset(x + 1.5, y - 2),
        8,
        Paint()
          ..color = const Color(0xFFFFD27A).withOpacity(0.13)
          ..maskFilter = const MaskFilter.blur(
            BlurStyle.normal,
            5,
          ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PatronoPainter extends CustomPainter {
  final double progresso;
  final bool ativo;

  PatronoPainter({
    required this.progresso,
    required this.ativo,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double pulso = math.sin(progresso * math.pi) * 5;
    final Offset centro = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < 6; i++) {
      final double raio = 25 + i * 12 + pulso;

      canvas.drawCircle(
        centro,
        raio,
        Paint()
          ..color = const Color(0xFF9CEAFF).withOpacity(
            (ativo ? 0.045 : 0.02) + i * 0.003,
          )
          ..maskFilter = const MaskFilter.blur(
            BlurStyle.normal,
            13,
          ),
      );
    }

    final math.Random aleatorio = math.Random(23);

    for (int i = 0; i < 42; i++) {
      final double angulo = aleatorio.nextDouble() * math.pi * 2;
      final double distancia =
          aleatorio.nextDouble() * (ativo ? 100 : 65);

      final Offset ponto = Offset(
        centro.dx + math.cos(angulo) * distancia,
        centro.dy + math.sin(angulo) * distancia * 0.72,
      );

      canvas.drawCircle(
        ponto,
        aleatorio.nextDouble() * 2 + 0.5,
        Paint()
          ..color = const Color(0xFFBDEFFF).withOpacity(
            0.3 + aleatorio.nextDouble() * 0.65,
          ),
      );
    }

    final double escala = size.width < 300 ? 0.75 : 1.0;

    canvas.save();
    canvas.translate(centro.dx, centro.dy + pulso * 0.3);
    canvas.scale(escala);

    final Paint brilho = Paint()
      ..color = const Color(0xFFBDEFFF).withOpacity(0.24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        7,
      );

    final Paint linhas = Paint()
      ..color = const Color(0xFFE2F8FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Path corpo = Path()
      ..moveTo(-43, 1)
      ..quadraticBezierTo(-27, -15, 1, -8)
      ..quadraticBezierTo(15, -6, 23, -20)
      ..lineTo(32, -38)
      ..lineTo(40, -34)
      ..lineTo(37, -19)
      ..lineTo(49, -14)
      ..lineTo(61, -20)
      ..lineTo(67, -14)
      ..lineTo(56, -5)
      ..lineTo(45, -2)
      ..lineTo(36, 8)
      ..lineTo(25, 8)
      ..lineTo(17, 0)
      ..lineTo(11, 25)
      ..lineTo(22, 44)
      ..moveTo(7, 5)
      ..lineTo(0, 29)
      ..lineTo(-10, 44)
      ..moveTo(-29, 2)
      ..lineTo(-37, 23)
      ..lineTo(-32, 43)
      ..moveTo(-18, 0)
      ..lineTo(-21, 25)
      ..lineTo(-18, 43)
      ..moveTo(-43, 1)
      ..quadraticBezierTo(-56, -9, -51, -23);

    final Path galhadas = Path()
      ..moveTo(37, -37)
      ..lineTo(34, -52)
      ..lineTo(24, -62)
      ..moveTo(34, -52)
      ..lineTo(43, -61)
      ..lineTo(45, -69)
      ..moveTo(41, -49)
      ..lineTo(53, -54)
      ..lineTo(58, -63)
      ..moveTo(47, -18)
      ..lineTo(57, -30)
      ..lineTo(69, -34)
      ..moveTo(57, -30)
      ..lineTo(57, -42);

    canvas.drawPath(corpo, brilho);
    canvas.drawPath(galhadas, brilho);
    canvas.drawPath(corpo, linhas);
    canvas.drawPath(galhadas, linhas);

    canvas.drawCircle(
      const Offset(50, -13),
      2.5,
      Paint()..color = Colors.white,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(0, 0),
        width: 145,
        height: 112,
      ),
      Paint()
        ..color = const Color(0xFF9CEAFF).withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant PatronoPainter oldDelegate) {
    return oldDelegate.progresso != progresso ||
        oldDelegate.ativo != ativo;
  }
}