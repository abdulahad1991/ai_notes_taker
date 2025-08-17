import 'dart:io';

class TimezoneRegionService {
  static TimezoneRegionService? _instance;
  static TimezoneRegionService get instance => _instance ??= TimezoneRegionService._();
  TimezoneRegionService._();

  /// Map of timezone identifiers to regions
  static const Map<String, Map<String, String>> _timezoneToRegion = {
    // North America
    'America/New_York': {'country': 'United States', 'region': 'Eastern US', 'code': 'US'},
    'America/Chicago': {'country': 'United States', 'region': 'Central US', 'code': 'US'},
    'America/Denver': {'country': 'United States', 'region': 'Mountain US', 'code': 'US'},
    'America/Los_Angeles': {'country': 'United States', 'region': 'Pacific US', 'code': 'US'},
    'America/Phoenix': {'country': 'United States', 'region': 'Arizona US', 'code': 'US'},
    'America/Anchorage': {'country': 'United States', 'region': 'Alaska US', 'code': 'US'},
    'Pacific/Honolulu': {'country': 'United States', 'region': 'Hawaii US', 'code': 'US'},
    'America/Toronto': {'country': 'Canada', 'region': 'Eastern Canada', 'code': 'CA'},
    'America/Vancouver': {'country': 'Canada', 'region': 'Pacific Canada', 'code': 'CA'},
    'America/Mexico_City': {'country': 'Mexico', 'region': 'Central Mexico', 'code': 'MX'},

    // Europe
    'Europe/London': {'country': 'United Kingdom', 'region': 'UK', 'code': 'GB'},
    'Europe/Dublin': {'country': 'Ireland', 'region': 'Ireland', 'code': 'IE'},
    'Europe/Paris': {'country': 'France', 'region': 'France', 'code': 'FR'},
    'Europe/Berlin': {'country': 'Germany', 'region': 'Germany', 'code': 'DE'},
    'Europe/Rome': {'country': 'Italy', 'region': 'Italy', 'code': 'IT'},
    'Europe/Madrid': {'country': 'Spain', 'region': 'Spain', 'code': 'ES'},
    'Europe/Amsterdam': {'country': 'Netherlands', 'region': 'Netherlands', 'code': 'NL'},
    'Europe/Brussels': {'country': 'Belgium', 'region': 'Belgium', 'code': 'BE'},
    'Europe/Vienna': {'country': 'Austria', 'region': 'Austria', 'code': 'AT'},
    'Europe/Zurich': {'country': 'Switzerland', 'region': 'Switzerland', 'code': 'CH'},
    'Europe/Stockholm': {'country': 'Sweden', 'region': 'Sweden', 'code': 'SE'},
    'Europe/Oslo': {'country': 'Norway', 'region': 'Norway', 'code': 'NO'},
    'Europe/Helsinki': {'country': 'Finland', 'region': 'Finland', 'code': 'FI'},
    'Europe/Copenhagen': {'country': 'Denmark', 'region': 'Denmark', 'code': 'DK'},
    'Europe/Warsaw': {'country': 'Poland', 'region': 'Poland', 'code': 'PL'},
    'Europe/Prague': {'country': 'Czech Republic', 'region': 'Czech Republic', 'code': 'CZ'},
    'Europe/Budapest': {'country': 'Hungary', 'region': 'Hungary', 'code': 'HU'},
    'Europe/Bucharest': {'country': 'Romania', 'region': 'Romania', 'code': 'RO'},
    'Europe/Athens': {'country': 'Greece', 'region': 'Greece', 'code': 'GR'},
    'Europe/Moscow': {'country': 'Russia', 'region': 'Western Russia', 'code': 'RU'},

    // Asia
    'Asia/Tokyo': {'country': 'Japan', 'region': 'Japan', 'code': 'JP'},
    'Asia/Seoul': {'country': 'South Korea', 'region': 'South Korea', 'code': 'KR'},
    'Asia/Shanghai': {'country': 'China', 'region': 'China', 'code': 'CN'},
    'Asia/Hong_Kong': {'country': 'Hong Kong', 'region': 'Hong Kong', 'code': 'HK'},
    'Asia/Singapore': {'country': 'Singapore', 'region': 'Singapore', 'code': 'SG'},
    'Asia/Bangkok': {'country': 'Thailand', 'region': 'Thailand', 'code': 'TH'},
    'Asia/Jakarta': {'country': 'Indonesia', 'region': 'Western Indonesia', 'code': 'ID'},
    'Asia/Manila': {'country': 'Philippines', 'region': 'Philippines', 'code': 'PH'},
    'Asia/Kuala_Lumpur': {'country': 'Malaysia', 'region': 'Malaysia', 'code': 'MY'},
    'Asia/Kolkata': {'country': 'India', 'region': 'India', 'code': 'IN'},
    'Asia/Karachi': {'country': 'Pakistan', 'region': 'Pakistan', 'code': 'PK'},
    'Asia/Dhaka': {'country': 'Bangladesh', 'region': 'Bangladesh', 'code': 'BD'},
    'Asia/Dubai': {'country': 'UAE', 'region': 'UAE', 'code': 'AE'},
    'Asia/Riyadh': {'country': 'Saudi Arabia', 'region': 'Saudi Arabia', 'code': 'SA'},
    'Asia/Tehran': {'country': 'Iran', 'region': 'Iran', 'code': 'IR'},
    'Asia/Istanbul': {'country': 'Turkey', 'region': 'Turkey', 'code': 'TR'},
    'Asia/Jerusalem': {'country': 'Israel', 'region': 'Israel', 'code': 'IL'},

    // Australia/Oceania
    'Australia/Sydney': {'country': 'Australia', 'region': 'Eastern Australia', 'code': 'AU'},
    'Australia/Melbourne': {'country': 'Australia', 'region': 'Eastern Australia', 'code': 'AU'},
    'Australia/Brisbane': {'country': 'Australia', 'region': 'Eastern Australia', 'code': 'AU'},
    'Australia/Perth': {'country': 'Australia', 'region': 'Western Australia', 'code': 'AU'},
    'Australia/Adelaide': {'country': 'Australia', 'region': 'Central Australia', 'code': 'AU'},
    'Pacific/Auckland': {'country': 'New Zealand', 'region': 'New Zealand', 'code': 'NZ'},

    // Africa
    'Africa/Cairo': {'country': 'Egypt', 'region': 'Egypt', 'code': 'EG'},
    'Africa/Johannesburg': {'country': 'South Africa', 'region': 'South Africa', 'code': 'ZA'},
    'Africa/Lagos': {'country': 'Nigeria', 'region': 'Nigeria', 'code': 'NG'},
    'Africa/Nairobi': {'country': 'Kenya', 'region': 'Kenya', 'code': 'KE'},
    'Africa/Casablanca': {'country': 'Morocco', 'region': 'Morocco', 'code': 'MA'},

    // South America
    'America/Sao_Paulo': {'country': 'Brazil', 'region': 'Brazil', 'code': 'BR'},
    'America/Argentina/Buenos_Aires': {'country': 'Argentina', 'region': 'Argentina', 'code': 'AR'},
    'America/Santiago': {'country': 'Chile', 'region': 'Chile', 'code': 'CL'},
    'America/Lima': {'country': 'Peru', 'region': 'Peru', 'code': 'PE'},
    'America/Bogota': {'country': 'Colombia', 'region': 'Colombia', 'code': 'CO'},
  };

  /// Get timezone information
  Map<String, dynamic> getTimezoneInfo() {
    final now = DateTime.now();
    final timezone = now.timeZoneName;
    final offset = now.timeZoneOffset;
    
    // Try to get the IANA timezone identifier (works on most platforms)
    String? timezoneId;
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        // On mobile, we can get more detailed timezone info
        timezoneId = _getSystemTimezone();
      }
    } catch (e) {
      print('Error getting system timezone: $e');
    }

    return {
      'timezone': timezone,
      'timezoneId': timezoneId,
      'offset': offset.inHours,
      'offsetMinutes': offset.inMinutes,
      'offsetString': _formatOffset(offset),
    };
  }

  /// Get region information based on timezone
  Map<String, dynamic> getRegionFromTimezone() {
    final timezoneInfo = getTimezoneInfo();
    final timezone = timezoneInfo['timezone'] as String;
    final timezoneId = timezoneInfo['timezoneId'] as String?;
    final offset = timezoneInfo['offset'] as int;
    
    // Debug logging
    print('=== TIMEZONE DEBUG ===');
    print('Raw timezone: $timezone');
    print('Timezone ID: $timezoneId');
    print('Offset hours: $offset');
    print('Offset string: ${timezoneInfo['offsetString']}');
    print('====================');
    
    Map<String, String>? regionInfo;
    
    // First try to match by timezone ID if available
    if (timezoneId != null && _timezoneToRegion.containsKey(timezoneId)) {
      regionInfo = _timezoneToRegion[timezoneId];
      print('Found exact match for timezone ID: $timezoneId');
    } else {
      // Fallback: try to determine region by timezone name and offset
      regionInfo = _getRegionByTimezoneAndOffset(timezone, offset);
      if (regionInfo != null) {
        print('Found fallback match: ${regionInfo['country']}');
      } else {
        print('No match found for timezone: $timezone, offset: $offset');
      }
    }

    final result = {
      'country': regionInfo?['country'] ?? 'Unknown',
      'region': regionInfo?['region'] ?? 'Unknown',
      'countryCode': regionInfo?['code'] ?? 'XX',
      'timezone': timezone,
      'timezoneId': timezoneId,
      'offset': offset,
      'offsetString': timezoneInfo['offsetString'],
      'confidence': regionInfo != null ? 'high' : 'low',
    };
    
    print('Final result: $result');
    return result;
  }

  /// Get system timezone (platform specific)
  String? _getSystemTimezone() {
    try {
      // This is a simplified approach. In a real app, you might want to use
      // platform channels to get the actual IANA timezone identifier
      final now = DateTime.now();
      return now.timeZoneName;
    } catch (e) {
      return null;
    }
  }

  /// Format timezone offset as string
  String _formatOffset(Duration offset) {
    final hours = offset.inHours;
    final minutes = (offset.inMinutes % 60).abs();
    final sign = hours >= 0 ? '+' : '-';
    return '${sign}${hours.abs().toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  /// Fallback method to determine region by timezone name and offset
  Map<String, String>? _getRegionByTimezoneAndOffset(String timezone, int offset) {
    // Convert timezone to uppercase for easier matching
    final tz = timezone.toUpperCase();
    
    print('Attempting fallback match for: $tz (offset: $offset)');
    
    // Try to match by offset first (most reliable)
    switch (offset) {
      case -12:
        return {'country': 'United States', 'region': 'Baker Island', 'code': 'US'};
      case -11:
        return {'country': 'United States', 'region': 'American Samoa', 'code': 'US'};
      case -10:
        return {'country': 'United States', 'region': 'Hawaii', 'code': 'US'};
      case -9:
        return {'country': 'United States', 'region': 'Alaska', 'code': 'US'};
      case -8: // PST/PDT
        return {'country': 'United States', 'region': 'Pacific US', 'code': 'US'};
      case -7: // MST/MDT
        return {'country': 'United States', 'region': 'Mountain US', 'code': 'US'};
      case -6: // CST/CDT
        if (tz.contains('MEX')) {
          return {'country': 'Mexico', 'region': 'Central Mexico', 'code': 'MX'};
        }
        return {'country': 'United States', 'region': 'Central US', 'code': 'US'};
      case -5: // EST/EDT
        if (tz.contains('COL') || tz.contains('BOG')) {
          return {'country': 'Colombia', 'region': 'Colombia', 'code': 'CO'};
        }
        if (tz.contains('PER') || tz.contains('LIM')) {
          return {'country': 'Peru', 'region': 'Peru', 'code': 'PE'};
        }
        return {'country': 'United States', 'region': 'Eastern US', 'code': 'US'};
      case -4:
        if (tz.contains('VEN') || tz.contains('CAR')) {
          return {'country': 'Venezuela', 'region': 'Venezuela', 'code': 'VE'};
        }
        return {'country': 'Canada', 'region': 'Atlantic Canada', 'code': 'CA'};
      case -3:
        if (tz.contains('ARG') || tz.contains('BUE')) {
          return {'country': 'Argentina', 'region': 'Argentina', 'code': 'AR'};
        }
        if (tz.contains('BRA') || tz.contains('SAO')) {
          return {'country': 'Brazil', 'region': 'Brazil', 'code': 'BR'};
        }
        return {'country': 'Brazil', 'region': 'Brazil', 'code': 'BR'};
      case -2:
        return {'country': 'Brazil', 'region': 'Fernando de Noronha', 'code': 'BR'};
      case -1:
        return {'country': 'Portugal', 'region': 'Azores', 'code': 'PT'};
      case 0: // GMT/UTC
        if (tz.contains('GB') || tz.contains('UK') || tz.contains('LON')) {
          return {'country': 'United Kingdom', 'region': 'UK', 'code': 'GB'};
        }
        if (tz.contains('POR') || tz.contains('LIS')) {
          return {'country': 'Portugal', 'region': 'Portugal', 'code': 'PT'};
        }
        return {'country': 'United Kingdom', 'region': 'UK', 'code': 'GB'};
      case 1: // CET/CEST
        if (tz.contains('GER') || tz.contains('BER')) {
          return {'country': 'Germany', 'region': 'Germany', 'code': 'DE'};
        }
        if (tz.contains('FRA') || tz.contains('PAR')) {
          return {'country': 'France', 'region': 'France', 'code': 'FR'};
        }
        if (tz.contains('ITA') || tz.contains('ROM')) {
          return {'country': 'Italy', 'region': 'Italy', 'code': 'IT'};
        }
        if (tz.contains('SPA') || tz.contains('MAD')) {
          return {'country': 'Spain', 'region': 'Spain', 'code': 'ES'};
        }
        return {'country': 'Germany', 'region': 'Central Europe', 'code': 'DE'};
      case 2: // EET
        if (tz.contains('EGY') || tz.contains('CAI')) {
          return {'country': 'Egypt', 'region': 'Egypt', 'code': 'EG'};
        }
        if (tz.contains('GRE') || tz.contains('ATH')) {
          return {'country': 'Greece', 'region': 'Greece', 'code': 'GR'};
        }
        if (tz.contains('ZAF') || tz.contains('JOH')) {
          return {'country': 'South Africa', 'region': 'South Africa', 'code': 'ZA'};
        }
        return {'country': 'Egypt', 'region': 'Eastern Europe', 'code': 'EG'};
      case 3:
        if (tz.contains('SAU') || tz.contains('RIY')) {
          return {'country': 'Saudi Arabia', 'region': 'Saudi Arabia', 'code': 'SA'};
        }
        if (tz.contains('RUS') || tz.contains('MOS')) {
          return {'country': 'Russia', 'region': 'Western Russia', 'code': 'RU'};
        }
        return {'country': 'Saudi Arabia', 'region': 'Middle East', 'code': 'SA'};
      case 4:
        if (tz.contains('UAE') || tz.contains('DUB')) {
          return {'country': 'UAE', 'region': 'UAE', 'code': 'AE'};
        }
        return {'country': 'UAE', 'region': 'Gulf Region', 'code': 'AE'};
      case 5: // IST (India) / PKT (Pakistan)
        if (tz.contains('PAK') || tz.contains('KAR')) {
          return {'country': 'Pakistan', 'region': 'Pakistan', 'code': 'PK'};
        }
        return {'country': 'India', 'region': 'India', 'code': 'IN'};
      case 6:
        if (tz.contains('BAN') || tz.contains('DHA')) {
          return {'country': 'Bangladesh', 'region': 'Bangladesh', 'code': 'BD'};
        }
        return {'country': 'Bangladesh', 'region': 'South Asia', 'code': 'BD'};
      case 7:
        if (tz.contains('THA') || tz.contains('BAN')) {
          return {'country': 'Thailand', 'region': 'Thailand', 'code': 'TH'};
        }
        if (tz.contains('VIE') || tz.contains('HOC')) {
          return {'country': 'Vietnam', 'region': 'Vietnam', 'code': 'VN'};
        }
        return {'country': 'Thailand', 'region': 'Southeast Asia', 'code': 'TH'};
      case 8: // CST (China) / SGT (Singapore)
        if (tz.contains('CHN') || tz.contains('SHA') || tz.contains('BEI')) {
          return {'country': 'China', 'region': 'China', 'code': 'CN'};
        }
        if (tz.contains('SGP') || tz.contains('SIN')) {
          return {'country': 'Singapore', 'region': 'Singapore', 'code': 'SG'};
        }
        if (tz.contains('MYS') || tz.contains('KUL')) {
          return {'country': 'Malaysia', 'region': 'Malaysia', 'code': 'MY'};
        }
        if (tz.contains('PHI') || tz.contains('MAN')) {
          return {'country': 'Philippines', 'region': 'Philippines', 'code': 'PH'};
        }
        if (tz.contains('AUS') || tz.contains('PER')) {
          return {'country': 'Australia', 'region': 'Western Australia', 'code': 'AU'};
        }
        return {'country': 'China', 'region': 'East Asia', 'code': 'CN'};
      case 9: // JST (Japan) / KST (Korea)
        if (tz.contains('JPN') || tz.contains('TOK')) {
          return {'country': 'Japan', 'region': 'Japan', 'code': 'JP'};
        }
        if (tz.contains('KOR') || tz.contains('SEO')) {
          return {'country': 'South Korea', 'region': 'South Korea', 'code': 'KR'};
        }
        return {'country': 'Japan', 'region': 'East Asia', 'code': 'JP'};
      case 10:
        if (tz.contains('AUS') || tz.contains('SYD') || tz.contains('MEL')) {
          return {'country': 'Australia', 'region': 'Eastern Australia', 'code': 'AU'};
        }
        return {'country': 'Australia', 'region': 'Eastern Australia', 'code': 'AU'};
      case 11:
        return {'country': 'Australia', 'region': 'Eastern Australia DST', 'code': 'AU'};
      case 12:
        if (tz.contains('NZL') || tz.contains('AUC')) {
          return {'country': 'New Zealand', 'region': 'New Zealand', 'code': 'NZ'};
        }
        return {'country': 'New Zealand', 'region': 'Pacific', 'code': 'NZ'};
      case 13:
        return {'country': 'New Zealand', 'region': 'New Zealand DST', 'code': 'NZ'};
    }
    
    // If no match found, return null
    print('No fallback match found for offset: $offset');
    return null;
  }

  /// Get detailed region information including additional metadata
  Map<String, dynamic> getDetailedRegionInfo() {
    final regionData = getRegionFromTimezone();
    final now = DateTime.now();
    
    return {
      ...regionData,
      'timestamp': now.toIso8601String(),
      'localTime': now.toString(),
      'utcTime': now.toUtc().toIso8601String(),
      'weekday': now.weekday,
      'isWeekend': now.weekday >= 6,
    };
  }
}