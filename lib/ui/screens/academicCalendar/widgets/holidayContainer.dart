import 'package:eschool/data/models/holiday.dart';
import 'package:eschool/utils/uiUtils.dart';
import 'package:flutter/material.dart';

class HolidayContainer extends StatelessWidget {
  final Holiday holiday;
  const HolidayContainer({super.key, required this.holiday});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
      width: MediaQuery.of(context).size.width * (0.85),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                holiday.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.0,
                ),
              ),
              SizedBox(
                height: holiday.description.isEmpty ? 0 : 5,
              ),
              holiday.description.isEmpty
                  ? const SizedBox()
                  : Text(
                      holiday.description,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 11.5,
                      ),
                    ),
              const SizedBox(
                height: 5,
              ),
              Text.rich(
                TextSpan(
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(end: 2),
                        child: Icon(
                          Icons.calendar_month_outlined,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 12,
                        ),
                      ),
                    ),
                    TextSpan(
                      text: UiUtils.formatDate(holiday.date),
                    ),
                  ],
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 12.0,
                  ),
                ),
                textAlign: TextAlign.start,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );
        },
      ),
    );
  }
}
