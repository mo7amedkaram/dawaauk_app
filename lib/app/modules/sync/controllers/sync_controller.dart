// lib/app/modules/sync/controllers/sync_controller.dart
import 'package:get/get.dart';
import '../../../data/local/database_manager.dart';
import 'package:intl/intl.dart';

class SyncController extends GetxController {
  final DatabaseManager _dbManager = Get.find<DatabaseManager>();

  // États observables pour l'UI
  final RxBool isLoading = false.obs;
  final RxBool isFirstLaunch = true.obs;
  final RxBool hasDatabaseDownloaded = false.obs;
  final RxString lastSyncDateText = ''.obs;

  // Informations sur la synchronisation en cours
  RxBool get isSyncing => _dbManager.isSyncing;
  RxDouble get syncProgress => _dbManager.syncProgress;
  RxString get syncStatus => _dbManager.syncStatus;

  @override
  void onInit() {
    super.onInit();
    loadSyncInfo();
  }

  // Charger les informations de synchronisation
  void loadSyncInfo() {
    isFirstLaunch.value = _dbManager.isFirstLaunch;
    hasDatabaseDownloaded.value = _dbManager.hasDatabaseDownloaded;
    updateLastSyncDate();
  }

  // Mettre à jour le texte de la dernière synchronisation
  void updateLastSyncDate() {
    final lastSync = _dbManager.lastSyncDate;
    if (lastSync != null) {
      final formatter = DateFormat('dd/MM/yyyy HH:mm', 'ar');
      lastSyncDateText.value = formatter.format(lastSync);
    } else {
      lastSyncDateText.value = 'لم يتم التزامن من قبل';
    }
  }

  // Télécharger la base de données complète
  Future<bool> downloadFullDatabase() async {
    if (isSyncing.value) return false;

    isLoading.value = true;
    try {
      final result = await _dbManager.downloadFullDatabase();
      if (result) {
        hasDatabaseDownloaded.value = true;
        updateLastSyncDate();
      }
      return result;
    } finally {
      isLoading.value = false;
    }
  }

  // Mettre à jour la base de données
  Future<bool> updateDatabase() async {
    if (isSyncing.value) return false;

    isLoading.value = true;
    try {
      final result = await _dbManager.updateDatabase();
      if (result) {
        updateLastSyncDate();
      }
      return result;
    } finally {
      isLoading.value = false;
    }
  }
}
