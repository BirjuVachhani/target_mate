import 'package:flutter/material.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';

import '../resources/colors.dart';
import '../utils/extensions.dart';
import '../utils/font_variations.dart';
import 'dropdown_button3.dart';

/// Flutter's default dropdown.
class CustomMaterialDropdown<T> extends StatelessWidget {
  final List<T> items;
  final ValueChanged<T> onSelected;
  final String? label;
  final Widget Function(BuildContext context, T item)? itemBuilder;
  final T? value;
  final bool isExpanded;
  final String? hint;
  final double? itemHeight;
  final Widget Function(BuildContext context, T item)? selectedItemBuilder;

  const CustomMaterialDropdown({
    super.key,
    required this.items,
    required this.onSelected,
    this.value,
    this.label,
    this.itemBuilder,
    this.isExpanded = true,
    this.hint,
    this.itemHeight,
    this.selectedItemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null) Text(label!),
        if (label != null) const SizedBox(height: 10),
        SizedBox(
          height: itemHeight,
          child: DropdownButtonFormField<T?>(
            value: items.contains(value) ? value : null,
            isExpanded: isExpanded,
            hint: hint != null ? Text(hint!) : null,
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(fontVariations: FontVariations.w400, height: 1),
            // underline: const SizedBox.shrink(),
            // dropdownColor: Colors.red,
            decoration: InputDecoration(
              border: InputBorder.none,
              filled: true,
              fillColor: Colors.grey.withOpacity(0.15),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            menuMaxHeight: 700,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
            ),
            selectedItemBuilder: selectedItemBuilder != null
                ? (context) => [
                      for (final item in items)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: selectedItemBuilder!(context, item),
                        ),
                    ]
                : null,
            items: items
                .map((item) => DropdownMenuItem<T>(
                      value: item,
                      alignment: Alignment.centerLeft,
                      child: itemBuilder?.call(context, item) ??
                          Text(item.toString()),
                    ))
                .toList(),
            onChanged: (mode) {
              if (mode == null) return;
              onSelected(mode);
            },
          ),
        ),
      ],
    );
  }
}

class CustomDropdown<T> extends StatelessWidget {
  final List<T> items;
  final ValueChanged<T> onSelected;
  final String? label;
  final Widget Function(BuildContext context, T item)? itemBuilder;
  final T? value;
  final bool isExpanded;
  final double itemHeight;
  final double dropdownMaxHeight;
  final String? hint;
  final Widget Function(BuildContext context, T item)? selectedItemBuilder;

  const CustomDropdown({
    super.key,
    required this.items,
    required this.onSelected,
    this.value,
    this.label,
    this.itemBuilder,
    this.isExpanded = true,
    this.itemHeight = 36,
    this.dropdownMaxHeight = 500,
    this.selectedItemBuilder,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null) Text(label!),
        if (label != null) const SizedBox(height: 10),
        DefaultTextStyle(
          style: DefaultTextStyle.of(context).style.copyWith(
                fontSize: 14,
              ),
          child: CustomDropdownButton<T>(
            value: value == null || items.contains(value) ? value : null,
            hint: Text(hint ?? 'Select', style: const TextStyle(fontSize: 14)),
            isExpanded: isExpanded,
            barrierDismissible: true,
            offset: const Offset(0, -4),
            itemHeight: itemHeight,
            buttonHeight: 44,
            dropdownOverButton: false,
            buttonElevation: 0,
            dropdownMaxHeight: dropdownMaxHeight,
            scrollbarThickness: 4,
            dropdownElevation: 2,
            selectedItemHighlightColor: Theme.of(context).primaryColor,
            dropdownPadding: EdgeInsets.zero,
            // searchInnerWidget: searchable
            //     ? SearchBar(controller: searchController)
            //     : null,
            // onMenuStateChange: (isOpen) {
            //   if (!isOpen) searchController.clear();
            // },
            // searchMatchFn: searchable
            //     ? searchMatchFn ?? defaultSearchFn
            //     : null,
            // searchController: searchable ? searchController : null,
            buttonPadding: const EdgeInsets.only(right: 12),
            underline: const SizedBox.shrink(),
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontVariations: FontVariations.w400,
                  height: 1,
                ),
            buttonDecoration: BoxDecoration(
              color: context.theme.colorScheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(4),
            ),
            dropdownDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: context.theme.colorScheme.primary.darken(80),
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
            ),
            itemBuilder: (context, item) => CustomDropdownMenuItem<T>(
              value: item,
              alignment: Alignment.centerLeft,
              child: itemBuilder?.call(context, item) ?? Text(item.toString()),
            ),
            items: items,
            selectedItemBuilder: selectedItemBuilder != null
                ? (context, item) => CustomDropdownMenuItem<T>(
                      value: item,
                      alignment: Alignment.centerLeft,
                      child: selectedItemBuilder!(context, item),
                    )
                : null,
            onChanged: (value) {
              if (value == null) return;
              if (value == this.value) return;
              onSelected(value);
            },
          ),
        ),
      ],
    );
  }

  bool defaultSearchFn(DropdownMenuItem item, String searchValue) {
    return item.value
        .toString()
        .toLowerCase()
        .contains(searchValue.toLowerCase());
  }
}

class SearchBar extends StatelessWidget {
  final TextEditingController controller;

  const SearchBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        // color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.5),
            width: 0.5,
          ),
        ),
      ),
      child: TextField(
        controller: controller,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontVariations: FontVariations.w400,
              height: 1.2,
            ),
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Search',
          filled: true,
          prefixIcon: const Icon(Icons.search_rounded),
          fillColor: AppColors.borderColor.withOpacity(0.25),
          hintStyle: const TextStyle(fontSize: 13, height: 1.2),
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Colors.grey.withOpacity(0.3), width: 0.5),
            borderRadius: BorderRadius.circular(4),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Colors.grey.withOpacity(0.3), width: 0.5),
            borderRadius: BorderRadius.circular(4),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300, width: 0.5),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
