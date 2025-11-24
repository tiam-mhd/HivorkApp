import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../invoice/data/services/invoice_provider.dart';
import '../../../invoice/presentation/pages/invoice_list_screen.dart';
import '../../../invoice/presentation/pages/create_invoice_screen.dart';

class InvoicesTabPage extends StatefulWidget {
  final String? businessId;

  const InvoicesTabPage({
    super.key,
    this.businessId,
  });

  @override
  State<InvoicesTabPage> createState() => _InvoicesTabPageState();
}

class _InvoicesTabPageState extends State<InvoicesTabPage> {
  @override
  void initState() {
    super.initState();
    // تنظیم businessId در provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.businessId != null) {
        final provider = context.read<InvoiceProvider>();
        provider.setBusinessId(widget.businessId!);
      }
    });
  }

  @override
  void didUpdateWidget(InvoicesTabPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // اگر businessId تغییر کرد
    if (oldWidget.businessId != widget.businessId && widget.businessId != null) {
      final provider = context.read<InvoiceProvider>();
      provider.setBusinessId(widget.businessId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // اگر businessId نداریم
    if (widget.businessId == null) {
      return Container(
        color: theme.scaffoldBackgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.business_outlined,
                size: 64,
                color: theme.colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'لطفاً ابتدا کسب‌وکار را انتخاب کنید',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // نمایش InvoiceListScreen با FAB
    return Scaffold(
      body: const InvoiceListScreen(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateInvoiceScreen(
                businessId: widget.businessId!,
              ),
            ),
          ).then((_) {
            // رفرش لیست بعد از برگشت
            context.read<InvoiceProvider>().loadInvoices(refresh: true);
          });
        },
        icon: const Icon(Icons.add),
        label: const Text('فاکتور جدید'),
      ),
    );
  }
}
