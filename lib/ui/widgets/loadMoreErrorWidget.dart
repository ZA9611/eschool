// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:eschool/ui/styles/colors.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/uiUtils.dart';
import 'package:flutter/material.dart';

class LoadMoreErrorWidget extends StatelessWidget {
  final Function() onTapRetry;
  final String? titleTextKey;
  const LoadMoreErrorWidget({
    super.key,
    required this.onTapRetry,
    this.titleTextKey,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapRetry,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.refresh,
            color: primaryColor,
            size: 16,
          ),
          const SizedBox(
            width: 5,
          ),
          Flexible(
            child: Text(
              UiUtils.getTranslatedLabel(
                context,
                titleTextKey ?? errorLoadingMoreTapToRetryKey,
              ),
              style: const TextStyle(
                color: primaryColor,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
