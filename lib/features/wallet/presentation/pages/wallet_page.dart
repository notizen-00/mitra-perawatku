import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/json_helpers.dart';
import '../../../../shared/widgets/common/error_card.dart';
import '../../../../shared/widgets/loaders/card_skeleton.dart';
import '../../../../shared/widgets/navigation/mitra_scaffold.dart';
import '../../domain/entities/wallet_summary.dart';
import '../cubit/wallet_cubit.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WalletCubit>()..load(),
      child: BlocBuilder<WalletCubit, WalletState>(
        builder: (context, state) {
          return MitraScaffold(
            title: 'Wallet',
            activeIndex: 2,
            onRefresh: context.read<WalletCubit>().load,
            child: switch (state) {
              WalletLoading() || WalletInitial() => const _Loading(),
              WalletError(:final message) => ErrorCard(
                message: message,
                onRetry: context.read<WalletCubit>().load,
              ),
              WalletLoaded(:final summary) => _WalletContent(summary: summary),
              _ => const ErrorCard(message: 'State wallet tidak dikenali.'),
            },
          );
        },
      ),
    );
  }
}

class _WalletContent extends StatelessWidget {
  const _WalletContent({required this.summary});

  final WalletSummary summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BalanceCard(summary: summary),
        const SizedBox(height: 24),
        _QuickActions(summary: summary),
        const SizedBox(height: 26),
        _TransactionsHeader(onViewAll: () {}),
        const SizedBox(height: 12),
        if (summary.transactions.isEmpty)
          const _EmptyTransactions()
        else
          for (final transaction in summary.transactions) ...[
            _TransactionCard(transaction: transaction),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.summary});

  final WalletSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
      decoration: BoxDecoration(
        color: const Color(0xFF2FC28E),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2FC28E).withValues(alpha: 0.24),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AVAILABLE BALANCE',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              'Saldo: ${formatCurrency(summary.balance)}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _BalanceButton(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Withdraw',
                foreground: const Color(0xFF147E62),
                background: Colors.white,
                onTap: () {},
              ),
              const SizedBox(width: 12),
              _BalanceButton(
                icon: Icons.add_rounded,
                label: 'Top Up',
                foreground: Colors.white,
                background: const Color(0xFF24A979),
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceButton extends StatelessWidget {
  const _BalanceButton({
    required this.icon,
    required this.label,
    required this.foreground,
    required this.background,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color foreground;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 42,
        child: FilledButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 18),
          label: FittedBox(child: Text(label)),
          style: FilledButton.styleFrom(
            backgroundColor: background,
            foregroundColor: foreground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
            textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.summary});

  final WalletSummary summary;

  @override
  Widget build(BuildContext context) {
    final items = [
      _QuickActionData(
        icon: Icons.history_rounded,
        label: 'Riwayat',
        value: summary.transactions.length.toString(),
      ),
      _QuickActionData(
        icon: Icons.pending_actions_outlined,
        label: 'Pending',
        value: formatCurrency(summary.pendingIncome),
      ),
      _QuickActionData(
        icon: Icons.account_tree_outlined,
        label: 'Komisi',
        value: formatCurrency(summary.commissionIncome),
      ),
      _QuickActionData(
        icon: Icons.card_giftcard_outlined,
        label: 'Bonus',
        value: formatCurrency(summary.bonusIncome),
      ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final item in items) _QuickAction(item: item),
      ],
    );
  }
}

class _QuickActionData {
  const _QuickActionData({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.item});

  final _QuickActionData item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Tooltip(
        message: item.value,
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F0FF),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(item.icon, color: AppColors.secondary, size: 26),
            ),
            const SizedBox(height: 9),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: const Color(0xFF0B1C30),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionsHeader extends StatelessWidget {
  const _TransactionsHeader({required this.onViewAll});

  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Recent Transactions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFF071A33),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          child: const Text('View All'),
        ),
      ],
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.transaction});

  final WalletTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor(transaction.type);
    final amountColor = transaction.isCredit
        ? const Color(0xFF00965F)
        : const Color(0xFFE53935);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080B1C30),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(_transactionIcon(transaction.type), color: accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF071A33),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF667085),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${transaction.isCredit ? '+' : '-'}${formatCurrency(transaction.amount.abs())}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: amountColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              _StatusPill(status: transaction.status),
            ],
          ),
        ],
      ),
    );
  }

  Color _accentColor(WalletTransactionType type) {
    return switch (type) {
      WalletTransactionType.withdrawal => AppColors.secondary,
      WalletTransactionType.commission => AppColors.primary,
      WalletTransactionType.bonus => AppColors.tertiary,
      WalletTransactionType.service => AppColors.primary,
    };
  }

  IconData _transactionIcon(WalletTransactionType type) {
    return switch (type) {
      WalletTransactionType.withdrawal => Icons.account_balance_outlined,
      WalletTransactionType.commission => Icons.health_and_safety_outlined,
      WalletTransactionType.bonus => Icons.stars_outlined,
      WalletTransactionType.service => Icons.medical_services_outlined,
    };
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final WalletTransactionStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      WalletTransactionStatus.completed => ('COMPLETED', AppColors.primary),
      WalletTransactionStatus.inProgress => ('IN PROGRESS', AppColors.secondary),
      WalletTransactionStatus.pending => ('PENDING', AppColors.tertiary),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _EmptyTransactions extends StatelessWidget {
  const _EmptyTransactions();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        'Belum ada transaksi.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        CardSkeleton(height: 170),
        SizedBox(height: AppSpacing.md),
        CardSkeleton(height: 80),
        SizedBox(height: AppSpacing.md),
        CardSkeleton(height: 92),
        SizedBox(height: AppSpacing.sm),
        CardSkeleton(height: 92),
      ],
    );
  }
}
