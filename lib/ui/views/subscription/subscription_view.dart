import 'package:ai_notes_taker/ui/views/subscription/subscription_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../models/response/subscription_form_response.dart';
import '../../../shared/app_colors.dart';

class SubscriptionView extends StatelessWidget {
  const SubscriptionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    
    return ViewModelBuilder<SubscriptionViewmodel>.reactive(
      viewModelBuilder: () => SubscriptionViewmodel(context)..init(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: AppColors.bg_color,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppColors.primary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            // _buildLanguageSelector(model),
            // SizedBox(width: 16),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 0 : 24,
              vertical: 16,
            ),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    _buildHeader(model),
                    const SizedBox(height: 32),
                    if (model.isLoading)
                      _buildLoadingState()
                    else if (model.errorMessage != null)
                      _buildErrorState(model)
                    else if (model.formResponse != null)
                      _buildSubscriptionPlans(model, isWide)
                    else
                      _buildEmptyState(),
                    const SizedBox(height: 24),
                    if (!model.isLoading && model.selectedPlanIndex != null)
                      _buildContinueButton(model, context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(SubscriptionViewmodel model) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.aliceBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: model.selectedLanguage,
          icon: Icon(Icons.language, size: 16, color: AppColors.primary),
          items: ['EN', 'DE'].map((String language) {
            return DropdownMenuItem<String>(
              value: language,
              child: Text(
                language,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              model.setLanguage(newValue);
            }
          },
        ),
      ),
    );
  }

  Widget _buildHeader(SubscriptionViewmodel model) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.workspace_premium,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          model.getTitle() ?? 'Choose Your Plan',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Select the perfect plan for your needs',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.primary,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(60),
      child: Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text(
            'Loading subscription plans...',
            style: TextStyle(
              color: AppColors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(SubscriptionViewmodel model) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.red.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            model.errorMessage!,
            style: TextStyle(
              color: AppColors.red,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              model.clearError();
              model.fetchFormData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(60),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            color: AppColors.grey,
            size: 48,
          ),
          const SizedBox(height: 20),
          Text(
            'No subscription plans available',
            style: TextStyle(
              color: AppColors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionPlans(SubscriptionViewmodel model, bool isWide) {
    final plans = model.getPlans();
    if (plans == null || plans.isEmpty) {
      return _buildEmptyState();
    }

    if (isWide) {
      return _buildDesktopLayout(model, plans);
    } else {
      return _buildMobileLayout(model, plans);
    }
  }

  Widget _buildDesktopLayout(SubscriptionViewmodel model, List<EN> plans) {
    return Row(
      children: plans.asMap().entries.map((entry) {
        final index = entry.key;
        final plan = entry.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: _buildPlanCard(model, plan, index),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMobileLayout(SubscriptionViewmodel model, List<EN> plans) {
    return Column(
      children: plans.asMap().entries.map((entry) {
        final index = entry.key;
        final plan = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildPlanCard(model, plan, index),
        );
      }).toList(),
    );
  }

  Widget _buildPlanCard(SubscriptionViewmodel model, EN plan, int index) {
    final isSelected = model.selectedPlanIndex == index;
    final isPro = plan.title?.toLowerCase() == 'pro';
    final isFree = plan.title?.toLowerCase() == 'free';

    return GestureDetector(
      onTap: () => model.selectPlan(index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? AppColors.primary 
                : AppColors.platinum,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? AppColors.primary.withOpacity(0.15)
                  : Colors.black.withOpacity(0.08),
              blurRadius: isSelected ? 20 : 10,
              offset: Offset(0, isSelected ? 8 : 4),
            ),
          ],
        ),
        child: Column(
          children: [
            if (isPro) _buildPopularBadge(),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildPlanHeader(plan, isFree, isPro),
                  const SizedBox(height: 20),
                  _buildPlanFeatures(plan),
                  const SizedBox(height: 24),
                  _buildPlanPricing(plan, isFree),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularBadge() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Text(
        'MOST POPULAR',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildPlanHeader(EN plan, bool isFree, bool isPro) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isPro
                  ? [AppColors.primary, AppColors.secondary]
                  : isFree
                      ? [AppColors.grey, AppColors.light_grey]
                      : [AppColors.secondary, AppColors.primary],
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            isPro
                ? Icons.star
                : isFree
                    ? Icons.free_breakfast
                    : Icons.favorite,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          plan.title ?? '',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanFeatures(EN plan) {
    return Column(
      children: (plan.bullets ?? []).map((bullet) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 20,
                height: 20,
                margin: EdgeInsets.only(right: 12, top: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.check,
                  size: 14,
                  color: AppColors.primary,
                ),
              ),
              Expanded(
                child: Text(
                  bullet,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlanPricing(EN plan, bool isFree) {
    return Column(
      children: [
        if (isFree)
          Text(
            'Free',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '\$',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                plan.title?.toLowerCase() == 'pro' ? '29' : '19',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                '/month',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        if (!isFree)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Billed monthly',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContinueButton(SubscriptionViewmodel model, BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: model.isLoading
            ? null
            : () => model.selectSubscription(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          shadowColor: AppColors.primary.withOpacity(0.3),
        ),
        child: model.isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Continue with Selected Plan',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
