import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OneBox Alarm setter',
      theme: ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF1E88E5), // Azul principal
          onPrimary: Colors.white, // Texto sobre fondo azul
          secondary: Color(0xFF1976D2), // Azul secundario
          onSecondary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black87,
          error: Colors.red,
          onError: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: const AlarmSetterPage(),
    );
  }
}

class AlarmSetterPage extends StatefulWidget {
  const AlarmSetterPage({super.key});

  @override
  State<AlarmSetterPage> createState() => _AlarmSetterPageState();
}

class _AlarmSetterPageState extends State<AlarmSetterPage> {
  final TextEditingController _urlController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      helpText: 'Selecciona la hora de la alarma',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      hourLabelText: 'Hora',
      minuteLabelText: 'Minuto',
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormatted = _selectedTime.format(context);
    double radius =
        max(
          min(
            MediaQuery.of(context).size.width * 0.8,
            MediaQuery.of(context).size.height * 0.5,
          ),
          300,
        ) /
        2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ONE Box Alarm Setter'),
        centerTitle: true,
        foregroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'URL de tu ONE box',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              '¿A qué hora quieres que suene la próxima alarma?',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: InkWell(
                borderRadius: BorderRadius.circular(radius),
                onTap: _pickTime,
                child: Container(
                  width: max(radius, 300),
                  height: max(radius, 300),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary.withAlpha(
                      (0.1 * 255).toInt(),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    timeFormatted,
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton(
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(radius * 2, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    onPressed: () async {
                      final url = _urlController.text;
                      if (url.isNotEmpty) {
                        final hour = _selectedTime.hour.toString().padLeft(
                          2,
                          '0',
                        );
                        final min = _selectedTime.minute.toString().padLeft(
                          2,
                          '0',
                        );
                        final alarmUrl =
                            'http://$url/set_alarm?hour=$hour&min=$min';
                        try {
                          await Future.delayed(
                            const Duration(milliseconds: 100),
                          ); // For UI feedback
                          final response = await http.get(Uri.parse(alarmUrl));
                          if (!mounted)
                            return; // Guard against using context if widget is disposed
                          if (response.statusCode == 200) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  '¡Alarma establecida exitosamente!',
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Error al establecer la alarma: ${response.statusCode}',
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error de red: $e'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      } else {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Por favor, ingresa una URL válida.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: Text('Establecer Alarma'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
