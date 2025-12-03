import 'package:flutter/material.dart';
import '../../../customer/presentation/pages/customers_page.dart';

class CustomersTabPage extends StatelessWidget {
  final String businessId;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  
  const CustomersTabPage({
    super.key,
    required this.businessId,
    this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    return CustomersPage(businessId: businessId, scaffoldKey: scaffoldKey);
  }
}
