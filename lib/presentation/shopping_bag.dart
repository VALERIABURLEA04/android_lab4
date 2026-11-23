import 'package:material_ui/material_ui.dart';

import 'common.dart';
import 'shop_session.dart';

Future<void> showShoppingBag(
  BuildContext context,
  ShopSession session, {
  CartLine? addedLine,
}) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  builder: (_) => SafeArea(
    child: ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        final items = session.cart;
        return ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          children: [
            const Text(
              'Shopping bag',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            if (addedLine != null && items.contains(addedLine)) ...[
              const SizedBox(height: 8),
              Text(
                '${addedLine.product.name} added to your bag.',
                style: const TextStyle(color: accent),
              ),
            ],
            if (items.isEmpty)
              const ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Your bag is empty.'),
              ),
            for (final line in items)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(line.product.name),
                subtitle: Text(
                  '${line.color} · ${line.size} · ${priceLabel(line.product.price, line.product.currency)}',
                ),
                trailing: IconButton(
                  tooltip: 'Remove',
                  icon: const Icon(Icons.close),
                  onPressed: () => session.remove(line),
                ),
              ),
          ],
        );
      },
    ),
  ),
);
