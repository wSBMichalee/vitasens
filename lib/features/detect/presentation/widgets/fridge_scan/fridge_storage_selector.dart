part of '../../screens/fridge_scan_result_screen.dart';

class FridgeStorageSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const FridgeStorageSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GDZIE DODAĆ PRODUKTY?',
          style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.grey.shade600),
        ),
        SizedBox(height: 12.h),
        Row(children: [
          _StorageChip(label: '🧊 Fridge', value: 'fridge', selected: selected == 'fridge', onTap: () => onChanged('fridge')),
          SizedBox(width: 8.w),
          _StorageChip(label: '❄️ Freezer', value: 'freezer', selected: selected == 'freezer', onTap: () => onChanged('freezer')),
          SizedBox(width: 8.w),
          _StorageChip(label: '🗄️ Pantry', value: 'pantry', selected: selected == 'pantry', onTap: () => onChanged('pantry')),
        ]),
      ],
    );
  }
}

class _StorageChip extends StatelessWidget {
  final String label, value;
  final bool selected;
  final VoidCallback onTap;
  
  const _StorageChip({
    required this.label, 
    required this.value, 
    required this.selected, 
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryLight : AppColors.backgroundWhite,
            border: Border.all(color: selected ? AppColors.primary : AppColors.border),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(
            child: Text(
              label, 
              style: TextStyle(
                fontSize: 11.sp, 
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500, 
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
