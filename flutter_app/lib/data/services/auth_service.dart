import 'package:bcrypt/bcrypt.dart';

import '../models/models.dart';
import '../repositories/local_crud_repository.dart';

const kSeedUsername = 'admin1';
const kSeedPasswordPlain = 'lino';

enum SignInResult {
  success,
  userNotFound,
  invalidPassword,
  termsNotAccepted,
}

class AuthService {
  AuthService({LocalCrudRepository? repository})
      : _repository = repository ?? LocalCrudRepository();

  static final AuthService instance = AuthService();

  final LocalCrudRepository _repository;

  int? _activeSessionId;

  Future<void> bootstrap() async {
    final existing = await _repository.getUserByUsername(kSeedUsername);
    if (existing != null) {
      return;
    }

    final now = DateTime.now().toUtc();
    final userId = await _repository.createUser(
      AppUser(
        username: kSeedUsername,
        displayName: 'Administrador',
        email: null,
        status: 'activo',
        createdAt: now,
        updatedAt: now,
      ),
    );

    final hashedPassword = BCrypt.hashpw(kSeedPasswordPlain, BCrypt.gensalt());

    await _repository.upsertCredential(
      Credential(
        userId: userId,
        passwordHash: hashedPassword,
        hashAlgo: 'bcrypt',
        passwordUpdatedAt: now,
      ),
    );

    await _repository.createTerm(
      TermVersion(
        version: '1.0.0',
        contentChecksum: 'seed-terminos-v1',
        publishedAt: now,
        active: true,
      ),
    );
  }

  Future<SignInResult> signIn({
    required String username,
    required String password,
    required bool termsAccepted,
  }) async {
    if (!termsAccepted) {
      return SignInResult.termsNotAccepted;
    }

    final user = await _repository.getUserByUsername(username);
    if (user == null) {
      return SignInResult.userNotFound;
    }

    final credential = await _repository.getCredential(user.userId!);
    if (credential == null || !BCrypt.checkpw(password, credential.passwordHash)) {
      return SignInResult.invalidPassword;
    }

    final activeTerm = await _repository.getActiveTerm();
    if (activeTerm != null) {
      final acceptance =
          await _repository.getAcceptance(user.userId!, activeTerm.termId!);
      if (acceptance == null) {
        await _repository.createAcceptance(
          UserTermAcceptance(
            userId: user.userId!,
            termId: activeTerm.termId!,
            accepted: true,
            acceptedAt: DateTime.now().toUtc(),
            userAgent: 'flutter-app',
          ),
        );
      }
    }

    final now = DateTime.now().toUtc();
    final updatedUser = AppUser(
      userId: user.userId,
      username: user.username,
      displayName: user.displayName,
      email: user.email,
      status: user.status,
      createdAt: user.createdAt,
      updatedAt: now,
      lastLoginAt: now,
    );
    await _repository.updateUser(updatedUser);

    final token = _buildToken(user.username, now);
    final sessionId = await _repository.createSession(
      AppSession(
        userId: user.userId!,
        publicToken: token,
        startedAt: now,
        status: 'abierta',
        device: 'mobile',
        appVersion: '0.1.0',
      ),
    );

    _activeSessionId = sessionId;
    return SignInResult.success;
  }

  Future<void> signOutCurrent() async {
    final sessionId = _activeSessionId;
    if (sessionId == null) {
      return;
    }

    final currentSession = await _repository.getSessionById(sessionId);
    if (currentSession == null || currentSession.status != 'abierta') {
      _activeSessionId = null;
      return;
    }

    await _repository.updateSession(
      AppSession(
        sessionId: currentSession.sessionId,
        userId: currentSession.userId,
        publicToken: currentSession.publicToken,
        startedAt: currentSession.startedAt,
        closedAt: DateTime.now().toUtc(),
        status: 'cerrada',
        closeReason: 'logout',
        device: currentSession.device,
        appVersion: currentSession.appVersion,
      ),
    );

    _activeSessionId = null;
  }

  String _buildToken(String username, DateTime nowUtc) {
    return [username, nowUtc.microsecondsSinceEpoch].join('_');
  }
}
