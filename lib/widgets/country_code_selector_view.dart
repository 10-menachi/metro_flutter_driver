import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CountryCodeSelectorView extends StatelessWidget {
  final ValueChanged<CountryCode>? onChanged;
  final TextEditingController countryCodeController;
  final bool isEnable;
  final bool isCountryNameShow;
  const CountryCodeSelectorView(
      {super.key,
      required this.onChanged,
      required this.countryCodeController,
      required this.isEnable,
      required this.isCountryNameShow});

  @override
  Widget build(BuildContext context) {
    return CountryCodePicker(
      onChanged: onChanged,
      enabled: isEnable,
      dialogTextStyle:
          GoogleFonts.inter(color: Colors.grey, fontWeight: FontWeight.w500),
      dialogBackgroundColor: Colors.white,
      initialSelection: countryCodeController.text,
      comparator: (a, b) => b.name!.compareTo(a.name.toString()),
      flagDecoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(2)),
      ),
      showFlag: true,
      showCountryOnly: true,
      backgroundColor: Colors.white,
      builder: (p0) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              clipBehavior: Clip.hardEdge,
              margin: const EdgeInsets.only(right: 8.0),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(2)),
              ),
              child: Image.asset(
                p0!.flagUri ?? '',
                package: 'country_code_picker',
                width: 26,
                height: 26,
              ),
            ),
            Text(
              isCountryNameShow ? p0.name ?? '' : p0.dialCode ?? '',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded)
          ],
        );
      },
      textStyle:
          GoogleFonts.inter(color: Colors.grey, fontWeight: FontWeight.w500),
      searchDecoration: const InputDecoration(iconColor: Colors.grey),
      searchStyle:
          GoogleFonts.inter(color: Colors.grey, fontWeight: FontWeight.w500),
    );
  }
}
