#ifndef RUNNER_THEME_CHANNEL_H_
#define RUNNER_THEME_CHANNEL_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>

class ThemeChannel {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

 private:
  static bool IsSystemDarkMode();
  static void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

#endif  // RUNNER_THEME_CHANNEL_H_
