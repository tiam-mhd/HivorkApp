import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../business/data/models/business_model.dart';
import '../../../customer/presentation/pages/customer_form_page.dart';
import '../../../customer/presentation/bloc/customer_bloc.dart';
import '../../../customer/data/repositories/customer_repository.dart';
import '../../../customer/data/services/customer_api_service.dart';
import '../../../product/presentation/pages/product_form_page.dart';
import '../../../invoice/presentation/pages/create_invoice_screen.dart';
import '../../../expense/pages/expense_form_page.dart';
import '../../../../core/di/service_locator.dart';

class AnimatedSpeedDialFAB extends StatefulWidget {
  final Business? activeBusiness;
  
  const AnimatedSpeedDialFAB({
    super.key,
    required this.activeBusiness,
  });

  @override
  State<AnimatedSpeedDialFAB> createState() => _AnimatedSpeedDialFABState();
}

class _AnimatedSpeedDialFABState extends State<AnimatedSpeedDialFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  bool _isOpen = false;

  final List<SpeedDialAction> _actions = [];

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.625, // 225 degrees = 0.625 turns
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));
  }

  @override
  void didUpdateWidget(AnimatedSpeedDialFAB oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateActions();
  }

  void _updateActions() {
    _actions.clear();
    
    if (widget.activeBusiness != null) {
      _actions.addAll([
        SpeedDialAction(
          icon: Icons.person_add,
          label: 'مشتری',
          color: Colors.green,
          onTap: () => _navigateToAddCustomer(),
        ),
        SpeedDialAction(
          icon: Icons.inventory,
          label: 'محصول',
          color: Colors.orange,
          onTap: () => _navigateToAddProduct(),
        ),
        SpeedDialAction(
          icon: Icons.receipt_long,
          label: 'فاکتور',
          color: Colors.blue,
          onTap: () => _navigateToAddInvoice(),
        ),
        SpeedDialAction(
          icon: Icons.payment,
          label: 'هزینه',
          color: Colors.red,
          onTap: () => _navigateToAddExpense(),
        ),
      ]);
    }
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _close() {
    if (_isOpen) {
      setState(() {
        _isOpen = false;
        _controller.reverse();
      });
    }
  }

  void _navigateToAddBusiness() {
    _close();
    context.push('/add-business');
  }

  void _navigateToAddCustomer() {
    _close();
    if (widget.activeBusiness != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => CustomerBloc(
              CustomerRepository(
                CustomerApiService(ServiceLocator().dio),
              ),
            ),
            child: CustomerFormPage(
              businessId: widget.activeBusiness!.id,
            ),
          ),
        ),
      );
    }
  }

  void _navigateToAddProduct() {
    _close();
    if (widget.activeBusiness != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductFormPage(
            businessId: widget.activeBusiness!.id,
          ),
        ),
      );
    }
  }

  void _navigateToAddInvoice() {
    _close();
    if (widget.activeBusiness != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateInvoiceScreen(
            businessId: widget.activeBusiness!.id,
          ),
        ),
      );
    }
  }

  void _navigateToAddExpense() {
    _close();
    if (widget.activeBusiness != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ExpenseFormPage(
            businessId: widget.activeBusiness!.id,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    _updateActions();

    return Stack(
      children: [
        // Backdrop overlay
        if (_isOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _close,
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Container(
                    color: Colors.black.withOpacity(0.5 * _scaleAnimation.value),
                  );
                },
              ),
            ),
          ),

        // Action buttons in pentagon formation (centered)
        ..._buildActionButtons(),

        // Main FAB (bottom left)
        Positioned(
          left: 16,
          bottom: 16,
          child: FloatingActionButton(
            heroTag: 'main_fab',
            onPressed: _toggle,
            backgroundColor: theme.colorScheme.primary,
            elevation: 6,
            child: AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value * 2 * math.pi,
                  child: Icon(
                    _isOpen ? Icons.close : Icons.add,
                    color: theme.colorScheme.onPrimary,
                    size: 28,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildActionButtons() {
    final buttons = <Widget>[];
    final actionCount = _actions.length;

    for (var i = 0; i < actionCount; i++) {
      buttons.add(_buildActionButton(_actions[i], i, actionCount));
    }

    return buttons;
  }

  Widget _buildActionButton(SpeedDialAction action, int index, int total) {
    // Square formation for 4 items
    final double angleStep = (2 * math.pi) / total;
    final double startAngle = -math.pi / 4; // Start from top-right (-45 degrees)
    final double angle = startAngle + (angleStep * index);
    
    // Distance from center
    final double radius = 110;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        // محدود کردن opacity به بازه 0-1
        final opacity = _scaleAnimation.value.clamp(0.0, 1.0);
        
        // Calculate position relative to screen center
        final screenSize = MediaQuery.of(context).size;
        final centerX = screenSize.width / 2;
        final centerY = screenSize.height / 2;
        
        final double dx = radius * math.cos(angle) * _scaleAnimation.value;
        final double dy = radius * math.sin(angle) * _scaleAnimation.value;
        
        return Positioned(
          left: centerX + dx - 40, // 40 = circle radius
          top: centerY + dy - 40,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: opacity,
              child: child,
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: action.onTap,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: action.color,
            shape: BoxShape.circle,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                action.icon,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(height: 4),
              Text(
                action.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SpeedDialAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  SpeedDialAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
