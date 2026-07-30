// Web-only implementation (selected via conditional import). dart:html is the
// simplest, dependency-free way to read the user agent, media queries, and
// session storage on web; the analyzer warnings below are intentional here.
// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;

bool get isMobileWeb {
  final ua = html.window.navigator.userAgent.toLowerCase();
  return ua.contains('iphone') ||
      ua.contains('ipad') ||
      ua.contains('ipod') ||
      ua.contains('android') ||
      ua.contains('mobile');
}

bool get isStandalonePwa {
  final standalone = html.window.matchMedia('(display-mode: standalone)').matches;
  return standalone;
}

const _googleRedirectKey = 'dc_google_redirect_pending';

void markGoogleRedirectPending() {
  html.window.sessionStorage[_googleRedirectKey] = '1';
}

bool consumeGoogleRedirectPending() {
  final pending = html.window.sessionStorage[_googleRedirectKey] == '1';
  if (pending) {
    html.window.sessionStorage.remove(_googleRedirectKey);
  }
  return pending;
}
