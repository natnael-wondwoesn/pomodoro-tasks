import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomodoro_tasks/core/theme/app_gradients.dart';
import 'package:pomodoro_tasks/features/auth/presentation/bloc/auth_bloc.dart';

class PairSetupPage extends StatefulWidget {
  const PairSetupPage({super.key});

  @override
  State<PairSetupPage> createState() => _PairSetupPageState();
}

class _PairSetupPageState extends State<PairSetupPage> {
  final _codeController = TextEditingController();
  String? _generatedCode;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.backgroundLight),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthPairCreated) {
                    setState(() => _generatedCode = state.pairCode);
                  }
                  if (state is AuthError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
                builder: (context, state) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Connect with Partner',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pair up for accountability',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 48),

                      // Generate code section
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: AppGradients.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Create a pair code',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Share this code with your partner',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 16),
                            if (_generatedCode != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  gradient: AppGradients.focusLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _generatedCode!,
                                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                        letterSpacing: 8,
                                      ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Waiting for partner to join...',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ] else
                              ElevatedButton(
                                onPressed: state is AuthLoading
                                    ? null
                                    : () => context.read<AuthBloc>().add(AuthCreatePairRequested()),
                                child: const Text('Generate Code'),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      Text('OR', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 24),

                      // Join with code section
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: AppGradients.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Join with a code',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Enter the code from your partner',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _codeController,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                letterSpacing: 8,
                              ),
                              decoration: const InputDecoration(
                                hintText: '000000',
                              ),
                              maxLength: 6,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: state is AuthLoading
                                  ? null
                                  : () {
                                      if (_codeController.text.length == 6) {
                                        context.read<AuthBloc>().add(
                                              AuthJoinPairRequested(
                                                pairCode: _codeController.text,
                                              ),
                                            );
                                      }
                                    },
                              child: const Text('Join Partner'),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () {
                          // Skip pairing for now
                          context.read<AuthBloc>().add(AuthCheckRequested());
                        },
                        child: const Text('Skip for now'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
