import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../invoice/data/services/invoice_provider.dart';
import '../../../invoice/presentation/pages/invoice_list_screen.dart';
import '../../../invoice/presentation/pages/create_invoice_screen.dart';

class InvoicesTabPage extends StatefulWidget {
  final String? businessId;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const InvoicesTabPage({
    super.key,
    this.businessId,
    this.scaffoldKey,
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
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.menu_rounded,
              color: theme.colorScheme.primary,
            ),
          ),
          onPressed: () {
            widget.scaffoldKey?.currentState?.openDrawer();
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.receipt_long,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'فاکتورها',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: const [
          SizedBox(width: 8),
        ],
      ),
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
