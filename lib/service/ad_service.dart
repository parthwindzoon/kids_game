// lib/service/ad_service.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

class AdService extends GetxService {
  RewardedAd? _rewardedAd;
  BannerAd? _bannerAd1; // First banner
  BannerAd? _bannerAd2; // Second banner

  final RxBool isRewardedAdReady = false.obs;
  final RxBool isBannerAd1Ready = false.obs; // First banner state
  final RxBool isBannerAd2Ready = false.obs; // Second banner state

  static const AdRequest _kidSafeAdRequest = AdRequest(
    nonPersonalizedAds: true,
  );

  // Use test ad unit IDs for development
  static String get rewardedAdUnitId {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        print('ANDROID DEBUG<><><>><><>><<>><><><><><><><><><><><>');
        return 'ca-app-pub-3940256099942544/5224354917';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/1712485313';
      } else {
        throw UnsupportedError("Unsupported Platform.");
      }
    } else {
      if (Platform.isAndroid) {
        print('ANDROID release<><><>><><>><<>><><><><><><><><><><><>');
        return 'ca-app-pub-4288009468041362/2153137575';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-4288009468041362/4377536738';
      } else {
        throw UnsupportedError("Unsupported Platform.");
      }
    }
  }

  // Banner ad unit IDs
  static String get bannerAdUnitId1 {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/6300978111';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/2934735716';
      } else {
        throw UnsupportedError("Unsupported Platform.");
      }
    } else {
      if (Platform.isAndroid) {
        return 'ca-app-pub-4288009468041362/2405801904';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-4288009468041362/9901148542';
      } else {
        throw UnsupportedError("Unsupported Platform.");
      }
    }
  }
  static String get bannerAdUnitId2 {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/6300978111';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/2934735716';
      } else {
        throw UnsupportedError("Unsupported Platform.");
      }
    } else {
      if (Platform.isAndroid) {
        return 'ca-app-pub-4288009468041362/7642650864';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-4288009468041362/4960647207';
      } else {
        throw UnsupportedError("Unsupported Platform.");
      }
    }
  }

  // Method to load a rewarded ad
  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: _kidSafeAdRequest,
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          isRewardedAdReady.value = true;
          debugPrint('Rewarded ad loaded.');
        },
        onAdFailedToLoad: (error) {
          isRewardedAdReady.value = false;
          debugPrint('Failed to load a rewarded ad: ${error.message}');
        },
      ),
    );
  }

  // Method to load first banner ad
  void loadBannerAd1() {
    _bannerAd1 = BannerAd(
      adUnitId: bannerAdUnitId1,
      size: AdSize.banner,
      request: _kidSafeAdRequest,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          isBannerAd1Ready.value = true;
          debugPrint('Banner ad 1 loaded.');
        },
        onAdFailedToLoad: (ad, error) {
          isBannerAd1Ready.value = false;
          ad.dispose();
          debugPrint('Failed to load banner ad 1: ${error.message}');
          // Retry after 30 seconds
          Future.delayed(const Duration(seconds: 30), () {
            if (!isBannerAd1Ready.value) {
              loadBannerAd1();
            }
          });
        },
        onAdOpened: (ad) {
          debugPrint('Banner ad 1 opened.');
        },
        onAdClosed: (ad) {
          debugPrint('Banner ad 1 closed.');
        },
      ),
    );

    _bannerAd1!.load();
  }

  // Method to load second banner ad
  void loadBannerAd2() {
    _bannerAd2 = BannerAd(
      adUnitId: bannerAdUnitId2,
      size: AdSize.banner,
      request: _kidSafeAdRequest,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          isBannerAd2Ready.value = true;
          debugPrint('Banner ad 2 loaded.');
        },
        onAdFailedToLoad: (ad, error) {
          isBannerAd2Ready.value = false;
          ad.dispose();
          debugPrint('Failed to load banner ad 2: ${error.message}');
          // Retry after 30 seconds
          Future.delayed(const Duration(seconds: 30), () {
            if (!isBannerAd2Ready.value) {
              loadBannerAd2();
            }
          });
        },
        onAdOpened: (ad) {
          debugPrint('Banner ad 2 opened.');
        },
        onAdClosed: (ad) {
          debugPrint('Banner ad 2 closed.');
        },
      ),
    );

    _bannerAd2!.load();
  }

  // Method to get the first banner ad widget
  Widget? getBannerAd1Widget() {
    if (_bannerAd1 != null && isBannerAd1Ready.value) {
      return Container(
        alignment: Alignment.center,
        width: _bannerAd1!.size.width.toDouble(),
        height: _bannerAd1!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd1!),
      );
    }
    return null;
  }

  // Method to get the second banner ad widget
  Widget? getBannerAd2Widget() {
    if (_bannerAd2 != null && isBannerAd2Ready.value) {
      return Container(
        alignment: Alignment.center,
        width: _bannerAd2!.size.width.toDouble(),
        height: _bannerAd2!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd2!),
      );
    }
    return null;
  }

  // Method to dispose first banner ad
  void disposeBannerAd1() {
    _bannerAd1?.dispose();
    _bannerAd1 = null;
    isBannerAd1Ready.value = false;
  }

  // Method to dispose second banner ad
  void disposeBannerAd2() {
    _bannerAd2?.dispose();
    _bannerAd2 = null;
    isBannerAd2Ready.value = false;
  }

  // Method to dispose all banner ads
  void disposeAllBannerAds() {
    disposeBannerAd1();
    disposeBannerAd2();
  }

  void showRewardedAd({required VoidCallback onReward}) {
    if (!isRewardedAdReady.value || _rewardedAd == null) {
      debugPrint('Tried to show ad but it was not ready.');
      loadRewardedAd();
      return;
    }

    bool rewardEarned = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        isRewardedAdReady.value = false;
        debugPrint('Ad dismissed. Reward earned: $rewardEarned');

        if (rewardEarned) {
          onReward();
        }

        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        isRewardedAdReady.value = false;
        debugPrint('Failed to show the ad: $error');
        loadRewardedAd();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        debugPrint('User earned reward: ${reward.amount} ${reward.type}');
        rewardEarned = true;
      },
    );
    _rewardedAd = null;
  }

  @override
  void onInit() {
    super.onInit();
    // Load all ads on initialization
    loadRewardedAd();
    loadBannerAd1();
    loadBannerAd2();
  }

  @override
  void onClose() {
    _rewardedAd?.dispose();
    disposeAllBannerAds();
    super.onClose();
  }
}