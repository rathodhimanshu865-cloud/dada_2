import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dada_2/l10n/app_localizations.dart';
import '../../../controllers/notification_controller.dart';
import '../../../models/notification_model.dart';
import '../../../utils/app_typography.dart';
import 'package:intl/intl.dart';

class NotificationDrawer extends StatelessWidget {
  const NotificationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF0F4C5C);
    final notificationController = Provider.of<NotificationController>(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final double drawerWidth = screenWidth > 600 ? 400 : screenWidth * 0.85;

    return Drawer(
      width: drawerWidth,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, notificationController, primaryTeal),
            const Divider(height: 1),
            Expanded(
              child: notificationController.notifications.isEmpty
                  ? _buildEmptyState(context, primaryTeal)
                  : _buildNotificationList(context, notificationController, primaryTeal),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, NotificationController controller, Color teal) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          Icon(Icons.notifications_none_outlined, size: 22, color: teal),
          const SizedBox(width: 12),
          Text(
            l10n.notifications,
            style: AppTypography.headingStyle(context, fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          if (controller.unreadCount > 0)
            TextButton(
              onPressed: () => controller.markAllAsRead(),
              child: Text(l10n.markAllAsRead, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, size: 20, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, Color teal) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Text(
            l10n.noNotificationsYet,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(BuildContext context, NotificationController controller, Color teal) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: controller.notifications.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final notification = controller.notifications[index];
        return _NotificationItem(notification: notification, controller: controller);
      },
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final NotificationController controller;

  const _NotificationItem({required this.notification, required this.controller});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (!notification.isRead) {
          controller.markAsRead(notification.id);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : const Color(0xFF0F4C5C).withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIcon(notification.type),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight: notification.isRead ? FontWeight.bold : FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        DateFormat('HH:mm').format(notification.createdAt),
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(String type) {
    IconData icon;
    Color color;

    switch (type) {
      case 'order':
        icon = Icons.shopping_bag_outlined;
        color = Colors.blue;
        break;
      case 'offer':
        icon = Icons.local_offer_outlined;
        color = Colors.orange;
        break;
      case 'new_product':
        icon = Icons.new_releases_outlined;
        color = Colors.green;
        break;
      default:
        icon = Icons.info_outline;
        color = const Color(0xFF0F4C5C);
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
      child: Icon(icon, size: 18, color: color),
    );
  }
}
