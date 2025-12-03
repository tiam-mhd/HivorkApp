import 'package:flutter/material.dart';
import '../../../expense/pages/expenses_page.dart';

class ExpensesTabPage extends StatelessWidget {
  final String? businessId;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  
  const ExpensesTabPage({
    super.key,
    this.businessId,
    this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    if (businessId == null) {
      return Center(
        child: Text(
          'لطفاً کسب‌وکار را انتخاب کنید',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }
    
    return ExpensesPage(businessId: businessId!, scaffoldKey: scaffoldKey);
  }
}
