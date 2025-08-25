import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'viewmodel/text_input_viewmodel.dart';

class TextInputView extends StatelessWidget {
  final bool isReminder;

  const TextInputView({super.key, required this.isReminder});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<TextInputViewmodel>.reactive(
      viewModelBuilder: () => TextInputViewmodel(context, isReminder)..init(),
      builder: (context, model, child) => _buildView(context, model),
    );
  }

  Widget _buildView(BuildContext context, TextInputViewmodel model) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(context, model, isCompact),
      body: Form(
        key: model.formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 20 : 32,
            vertical: isCompact ? 16 : 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleField(model, isCompact),
              SizedBox(height: isCompact ? 20 : 28),

              if (model.isReminder) ...[
                _buildDescriptionField(model, isCompact),
                SizedBox(height: isCompact ? 20 : 28),
                _buildDateTimeSection(model, isCompact),
              ] else ...[
                _buildContentField(model, isCompact),
              ],

              SizedBox(height: isCompact ? 28 : 36),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: model.canSave
                      ? const LinearGradient(
                          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: [Colors.grey.shade300, Colors.grey.shade400],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: model.canSave
                      ? [
                          BoxShadow(
                            color: const Color(0xFF667eea).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: TextButton(
                  onPressed: model.canSave ? model.saveInput : null,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isCompact ? 20 : 24,
                      vertical: isCompact ? 12 : 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_rounded,
                        size: isCompact ? 16 : 18,
                        color: model.canSave ? Colors.white : Colors.grey.shade600,
                      ),
                      SizedBox(width: isCompact ? 6 : 8),
                      Text(
                        'Save',
                        style: TextStyle(
                          fontSize: isCompact ? 14 : 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                          color: model.canSave ? Colors.white : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // _buildTipSection(model, isCompact),
              // SizedBox(height: isCompact ? 20 : 28), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, TextInputViewmodel model, bool isCompact) {
    return AppBar(
      backgroundColor: const Color(0xFFF8F9FA),
      elevation: 0,
      centerTitle: false,
      leading: Container(
        margin: EdgeInsets.only(left: isCompact ? 8 : 12),
        child: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.grey[700],
              size: isCompact ? 18 : 20,
            ),
          ),
          onPressed: model.onBackPressed,
        ),
      ),
      title: Padding(
        padding: EdgeInsets.only(left: isCompact ? 8 : 16),
        child: Text(
          model.appBarTitle,
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.w700,
            fontSize: isCompact ? 20 : 24,
            letterSpacing: -0.5,
          ),
        ),
      ),
      actions: [
      ],
    );
  }

  Widget _buildTitleField(TextInputViewmodel model, bool isCompact) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: model.isTitleFocused
              ? const Color(0xFF667eea)
              : Colors.grey.shade200,
          width: model.isTitleFocused ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: model.isTitleFocused
                ? const Color(0xFF667eea).withOpacity(0.1)
                : Colors.black.withOpacity(0.06),
            blurRadius: model.isTitleFocused ? 16 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Focus(
        onFocusChange: model.setTitleFocus,
        child: TextFormField(
          controller: model.titleController,
          decoration: InputDecoration(
            hintText: model.titleHint,
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(isCompact ? 18 : 22),
            hintStyle: TextStyle(
              fontSize: isCompact ? 16 : 18,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.2,
            ),
          ),
          style: TextStyle(
            fontSize: isCompact ? 16 : 18,
            color: Colors.grey[800],
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
          validator: model.validateTitle,
        ),
      ),
    );
  }

  Widget _buildDescriptionField(TextInputViewmodel model, bool isCompact) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: model.isDescriptionFocused
              ? const Color(0xFF667eea)
              : Colors.grey.shade200,
          width: model.isDescriptionFocused ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: model.isDescriptionFocused
                ? const Color(0xFF667eea).withOpacity(0.1)
                : Colors.black.withOpacity(0.06),
            blurRadius: model.isDescriptionFocused ? 16 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Focus(
        onFocusChange: model.setDescriptionFocus,
        child: TextFormField(
          controller: model.descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: model.contentHint,
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(isCompact ? 18 : 22),
            hintStyle: TextStyle(
              fontSize: isCompact ? 14 : 16,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.2,
            ),
          ),
          style: TextStyle(
            fontSize: isCompact ? 14 : 16,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
            height: 1.5,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildContentField(TextInputViewmodel model, bool isCompact) {
    return Container(
      height: isCompact ? 240 : 320,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: model.isDescriptionFocused
              ? const Color(0xFF667eea)
              : Colors.grey.shade200,
          width: model.isDescriptionFocused ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: model.isDescriptionFocused
                ? const Color(0xFF667eea).withOpacity(0.1)
                : Colors.black.withOpacity(0.06),
            blurRadius: model.isDescriptionFocused ? 16 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Focus(
        onFocusChange: model.setDescriptionFocus,
        child: TextFormField(
          controller: model.descriptionController,
          maxLines: null,
          expands: true,
          textAlignVertical: TextAlignVertical.top,
          decoration: InputDecoration(
            hintText: model.contentHint,
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(isCompact ? 18 : 22),
            hintStyle: TextStyle(
              fontSize: isCompact ? 14 : 16,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.2,
            ),
          ),
          style: TextStyle(
            fontSize: isCompact ? 14 : 16,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
            height: 1.6,
            letterSpacing: 0.2,
          ),
          validator: model.validateContent,
        ),
      ),
    );
  }

  Widget _buildDateTimeSection(TextInputViewmodel model, bool isCompact) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDateTimeTile(
            icon: Icons.calendar_today_rounded,
            label: 'Date',
            value: model.dateText,
            isSelected: model.selectedDate != null,
            onTap: model.selectDate,
            isFirst: true,
            isCompact: isCompact,
          ),

          Container(
            height: 1,
            margin: EdgeInsets.symmetric(horizontal: isCompact ? 16 : 20),
            color: Colors.grey.shade100,
          ),

          _buildDateTimeTile(
            icon: Icons.schedule_rounded,
            label: 'Time',
            value: model.timeText,
            isSelected: model.selectedTime != null,
            onTap: model.selectTime,
            isFirst: false,
            isCompact: isCompact,
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeTile({
    required IconData icon,
    required String label,
    required String value,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isFirst,
    required bool isCompact,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(16) : Radius.zero,
        bottom: !isFirst ? const Radius.circular(16) : Radius.zero,
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 18 : 22,
          vertical: isCompact ? 16 : 20,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isCompact ? 10 : 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF667eea).withOpacity(0.1),
                    const Color(0xFF764ba2).withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF667eea),
                size: isCompact ? 20 : 22,
              ),
            ),
            SizedBox(width: isCompact ? 14 : 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: isCompact ? 12 : 14,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: isCompact ? 4 : 6),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: isCompact ? 15 : 17,
                      color: isSelected
                          ? Colors.grey[800]
                          : Colors.grey.shade400,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.grey.shade400,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationWarning(bool isCompact) {
    return Padding(
      padding: EdgeInsets.only(top: isCompact ? 12 : 16),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 16 : 20,
          vertical: isCompact ? 12 : 16,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.amber.shade50,
              Colors.orange.shade50,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.amber.shade200,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.info_rounded,
                color: Colors.amber.shade700,
                size: isCompact ? 16 : 18,
              ),
            ),
            SizedBox(width: isCompact ? 12 : 16),
            Expanded(
              child: Text(
                'Please select both date and time for the reminder',
                style: TextStyle(
                  fontSize: isCompact ? 13 : 15,
                  color: Colors.amber.shade800,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipSection(TextInputViewmodel model, bool isCompact) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 18 : 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF667eea).withOpacity(0.08),
            const Color(0xFF764ba2).withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF667eea).withOpacity(0.15),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(isCompact ? 8 : 10),
            decoration: BoxDecoration(
              color: const Color(0xFF667eea).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              model.tipIcon,
              color: const Color(0xFF667eea),
              size: isCompact ? 18 : 20,
            ),
          ),
          SizedBox(width: isCompact ? 14 : 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pro Tip',
                  style: TextStyle(
                    fontSize: isCompact ? 12 : 14,
                    color: const Color(0xFF667eea),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: isCompact ? 4 : 6),
                Text(
                  model.tipText,
                  style: TextStyle(
                    fontSize: isCompact ? 13 : 15,
                    color: const Color(0xFF667eea).withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}