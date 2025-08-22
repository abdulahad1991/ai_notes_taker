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
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.grey[800],
            size: isCompact ? 22 : 24,
          ),
          onPressed: model.onBackPressed,
        ),
        title: Text(
          model.appBarTitle,
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.w600,
            fontSize: isCompact ? 18 : 20,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: isCompact ? 12 : 16),
            child: TextButton(
              onPressed: model.saveInput,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 16 : 20,
                  vertical: isCompact ? 8 : 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Save',
                style: TextStyle(
                  fontSize: isCompact ? 14 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: model.formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isCompact ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: model.isTitleFocused 
                        ? const Color(0xFF667eea) 
                        : Colors.grey.shade300,
                    width: model.isTitleFocused ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
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
                      contentPadding: EdgeInsets.all(isCompact ? 16 : 20),
                      hintStyle: TextStyle(
                        fontSize: isCompact ? 16 : 18,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: isCompact ? 16 : 18,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                    validator: model.validateTitle,
                  ),
                ),
              ),
              
              SizedBox(height: isCompact ? 16 : 24),

              // Conditional Content Area
              if (model.isReminder) ...[
                // Description for Reminder
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: model.isDescriptionFocused 
                          ? const Color(0xFF667eea) 
                          : Colors.grey.shade300,
                      width: model.isDescriptionFocused ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
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
                        contentPadding: EdgeInsets.all(isCompact ? 16 : 20),
                        hintStyle: TextStyle(
                          fontSize: isCompact ? 14 : 16,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: isCompact ? 14 : 16,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: isCompact ? 16 : 24),

                // Date & Time Picker Section
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Date Picker
                      InkWell(
                        onTap: model.selectDate,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(isCompact ? 16 : 20),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF667eea).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.calendar_today,
                                  color: const Color(0xFF667eea),
                                  size: isCompact ? 18 : 20,
                                ),
                              ),
                              SizedBox(width: isCompact ? 12 : 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Date',
                                      style: TextStyle(
                                        fontSize: isCompact ? 12 : 14,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      model.dateText,
                                      style: TextStyle(
                                        fontSize: isCompact ? 14 : 16,
                                        color: model.selectedDate != null 
                                            ? Colors.grey[800] 
                                            : Colors.grey.shade500,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey.shade400,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      Divider(
                        height: 1,
                        color: Colors.grey.shade200,
                      ),
                      
                      // Time Picker
                      InkWell(
                        onTap: model.selectTime,
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(isCompact ? 16 : 20),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF667eea).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.schedule,
                                  color: const Color(0xFF667eea),
                                  size: isCompact ? 18 : 20,
                                ),
                              ),
                              SizedBox(width: isCompact ? 12 : 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Time',
                                      style: TextStyle(
                                        fontSize: isCompact ? 12 : 14,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      model.timeText,
                                      style: TextStyle(
                                        fontSize: isCompact ? 14 : 16,
                                        color: model.selectedTime != null 
                                            ? Colors.grey[800] 
                                            : Colors.grey.shade500,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey.shade400,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Validation message for reminder
                if (model.showDateTimeWarning) ...[
                  SizedBox(height: isCompact ? 8 : 12),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isCompact ? 12 : 16,
                      vertical: isCompact ? 8 : 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.amber.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.amber.shade700,
                          size: isCompact ? 16 : 18,
                        ),
                        SizedBox(width: isCompact ? 8 : 12),
                        Expanded(
                          child: Text(
                            'Please select both date and time for the reminder',
                            style: TextStyle(
                              fontSize: isCompact ? 12 : 14,
                              color: Colors.amber.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ] else ...[
                // Description/Content for Note
                Container(
                  height: isCompact ? 200 : 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: model.isDescriptionFocused 
                          ? const Color(0xFF667eea) 
                          : Colors.grey.shade300,
                      width: model.isDescriptionFocused ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
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
                        contentPadding: EdgeInsets.all(isCompact ? 16 : 20),
                        hintStyle: TextStyle(
                          fontSize: isCompact ? 14 : 16,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: isCompact ? 14 : 16,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                      validator: model.validateContent,
                    ),
                  ),
                ),
              ],

              SizedBox(height: isCompact ? 24 : 32),

              // Tip Section
              Container(
                padding: EdgeInsets.all(isCompact ? 16 : 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF667eea).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF667eea).withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      model.tipIcon,
                      color: const Color(0xFF667eea),
                      size: isCompact ? 18 : 20,
                    ),
                    SizedBox(width: isCompact ? 12 : 16),
                    Expanded(
                      child: Text(
                        model.tipText,
                        style: TextStyle(
                          fontSize: isCompact ? 12 : 14,
                          color: const Color(0xFF667eea),
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}