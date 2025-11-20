import 'package:flutter/material.dart';
import '../../../customer/presentation/pages/customers_page.dart';

class CustomersTabPage extends StatelessWidget {
  final String businessId;
  
  const CustomersTabPage({
    super.key,
    required this.businessId,
  });

  @override
  Widget build(BuildContext context) {
    return CustomersPage(businessId: businessId);
  }
}
