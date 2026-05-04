import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomodoro_tasks/core/theme/app_colors.dart';
import 'package:pomodoro_tasks/features/quotes/presentation/bloc/quotes_bloc.dart';

class QuoteCard extends StatelessWidget {
  const QuoteCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuotesBloc, QuotesState>(
      builder: (context, state) {
        if (state is! QuotesLoaded) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.white.withValues(alpha: 0.7)
                : Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(
                color: Theme.of(context).brightness == Brightness.light
                    ? AppColors.quoteBarLight
                    : AppColors.quoteBarDark,
                width: 3,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '"${state.quote.text}"',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    state.quote.reference,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Daily Quote',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                        ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
