import 'package:flutter/material.dart';

class CropCard extends StatelessWidget {
  const CropCard({
    super.key,
    required this.name,
    this.image,
    this.status,
    this.onTap,
  });

  final String name;
  final String? image;
  final String? status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            if (image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  image!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_outlined),
                  ),
                ),
              ),
            if (image == null) ...[
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.image_outlined),
              ),
            ],
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  if (status != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      status!,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
