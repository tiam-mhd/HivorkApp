#include "theme_channel.h"

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>

namespace {
constexpr const wchar_t kGetPreferredBrightnessRegKey[] =
    L"Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize";
constexpr const wchar_t kGetPreferredBrightnessRegValue[] = L"AppsUseLightTheme";
}

void ThemeChannel::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      registrar->messenger(), "com.hivork.app/theme",
      &flutter::StandardMethodCodec::GetInstance());

  channel->SetMethodCallHandler(
      [](const flutter::MethodCall<flutter::EncodableValue>& call,
         std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        HandleMethodCall(call, std::move(result));
      });
}

bool ThemeChannel::IsSystemDarkMode() {
  DWORD light_mode;
  DWORD light_mode_size = sizeof(light_mode);
  LSTATUS result = RegGetValue(
      HKEY_CURRENT_USER, 
      kGetPreferredBrightnessRegKey,
      kGetPreferredBrightnessRegValue, 
      RRF_RT_REG_DWORD, 
      nullptr, 
      &light_mode,
      &light_mode_size);

  if (result == ERROR_SUCCESS) {
    // Registry value: 0 = dark mode, 1 = light mode
    return light_mode == 0;
  }
  
  // Default to light mode if registry read fails
  return false;
}

void ThemeChannel::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare("isSystemDarkMode") == 0) {
    bool is_dark = IsSystemDarkMode();
    result->Success(flutter::EncodableValue(is_dark));
  } else {
    result->NotImplemented();
  }
}
