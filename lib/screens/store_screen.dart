import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dyplom/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/public_program.dart';
import '../services/data_manager.dart';
import '../services/public_program_service.dart';
import '../utils/program_category_ui.dart';
import 'public_program_screen.dart';

enum _LoadState { loading, ready, offline, error, signedOut }

class StoreView extends StatefulWidget {
  const StoreView({super.key});

  @override
  State<StoreView> createState() => _StoreViewState();
}

class _StoreViewState extends State<StoreView>
    with AutomaticKeepAliveClientMixin {
  final _service = PublicProgramService();
  final _scroll = ScrollController();

  StoreSort _sort = StoreSort.popular;
  ProgramCategory? _category;

  _LoadState _state = _LoadState.loading;
  final List<PublicProgram> _programs = [];
  DocumentSnapshot<Map<String, dynamic>>? _lastDoc;
  bool _hasMore = false;
  bool _loadingMore = false;
  int _requestId = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _reload();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 300) {
      _loadMore();
    }
  }

  Future<void> _reload() async {
    if (_service.currentUserId == null) {
      setState(() => _state = _LoadState.signedOut);
      return;
    }
    final request = ++_requestId;
    setState(() {
      _state = _LoadState.loading;
      _programs.clear();
      _lastDoc = null;
      _hasMore = false;
    });
    try {
      final page =
          await _service.fetchApproved(sort: _sort, category: _category);
      if (!mounted || request != _requestId) return;
      setState(() {
        _programs.addAll(page.programs);
        _lastDoc = page.lastDoc;
        _hasMore = page.hasMore;
        _state = _LoadState.ready;
      });
    } on StoreOfflineException {
      if (mounted && request == _requestId) {
        setState(() => _state = _LoadState.offline);
      }
    } catch (e) {
      debugPrint('[STORE] load failed: $e');
      if (mounted && request == _requestId) {
        setState(() => _state = _LoadState.error);
      }
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _loadingMore || _state != _LoadState.ready) return;
    final request = _requestId;
    setState(() => _loadingMore = true);
    try {
      final page = await _service.fetchApproved(
        sort: _sort,
        category: _category,
        startAfter: _lastDoc,
      );
      if (!mounted || request != _requestId) return;
      setState(() {
        _programs.addAll(page.programs);
        _lastDoc = page.lastDoc;
        _hasMore = page.hasMore;
      });
    } catch (e) {
      debugPrint('[STORE] load more failed: $e');
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  Future<void> _open(PublicProgram program) async {
    final updated = await Navigator.of(context).push<PublicProgram>(
      MaterialPageRoute(builder: (_) => PublicProgramScreen(program: program)),
    );
    if (updated == null || !mounted) return;
    final i = _programs.indexWhere((p) => p.id == updated.id);
    if (i >= 0) setState(() => _programs[i] = updated);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        _buildFilters(l10n),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _reload,
            child: _buildBody(l10n),
          ),
        ),
      ],
    );
  }

  Widget _buildFilters(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<StoreSort>(
            segments: [
              ButtonSegment(
                value: StoreSort.popular,
                icon: const Icon(Icons.local_fire_department_outlined),
                label: Text(l10n.storeSortPopular),
              ),
              ButtonSegment(
                value: StoreSort.newest,
                icon: const Icon(Icons.schedule),
                label: Text(l10n.storeSortNew),
              ),
            ],
            selected: {_sort},
            showSelectedIcon: false,
            onSelectionChanged: (s) {
              setState(() => _sort = s.first);
              _reload();
            },
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _categoryChip(null, l10n.storeAllCategories, Icons.apps),
                for (final c in ProgramCategory.values)
                  _categoryChip(c, c.label(l10n), c.icon),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryChip(ProgramCategory? c, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        avatar: Icon(icon, size: 16, color: c?.color ?? AppColors.primary),
        label: Text(label),
        selected: _category == c,
        showCheckmark: false,
        onSelected: (_) {
          if (_category == c) return;
          setState(() => _category = c);
          _reload();
        },
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    switch (_state) {
      case _LoadState.loading:
        return const _Scrollable(
          child: Center(child: CircularProgressIndicator()),
        );
      case _LoadState.offline:
        return _Scrollable(
          child: _Message(
            icon: Icons.wifi_off,
            title: l10n.noInternetTitle,
            text: l10n.noInternetStore,
            onRetry: _reload,
            retryLabel: l10n.retry,
          ),
        );
      case _LoadState.error:
        return _Scrollable(
          child: _Message(
            icon: Icons.error_outline,
            text: l10n.storeLoadError,
            onRetry: _reload,
            retryLabel: l10n.retry,
          ),
        );
      case _LoadState.signedOut:
        return _Scrollable(
          child: _Message(icon: Icons.lock_outline, text: l10n.storeSignInRequired),
        );
      case _LoadState.ready:
        if (_programs.isEmpty) {
          return _Scrollable(
            child: _Message(icon: Icons.storefront, text: l10n.storeEmpty),
          );
        }
        final dataManager = Provider.of<DataManager>(context);
        return ListView.builder(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          itemCount: _programs.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, i) {
            if (i >= _programs.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final p = _programs[i];
            return _StoreProgramCard(
              program: p,
              isOwn: p.authorId == _service.currentUserId,
              isImported: dataManager.hasImportedPublicProgram(p.id),
              onTap: () => _open(p),
            );
          },
        );
    }
  }
}

class _StoreProgramCard extends StatelessWidget {
  final PublicProgram program;
  final bool isOwn;
  final bool isImported;
  final VoidCallback onTap;

  const _StoreProgramCard({
    required this.program,
    required this.isOwn,
    required this.isImported,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = program.category.color;
    final secondary = Theme.of(context).textTheme.bodySmall?.color;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(program.category.icon, color: color, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      program.name,
                      style: AppTextStyles.body1
                          .copyWith(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.byAuthor(program.authorNickname),
                      style: AppTextStyles.caption.copyWith(color: secondary),
                    ),
                    if (program.description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        program.description,
                        style: AppTextStyles.caption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        StoreChip(
                          label: program.category.label(l10n),
                          color: color,
                        ),
                        StoreChip(
                          label: l10n.exercisesCount(program.exerciseCount),
                          icon: Icons.list_alt,
                          color: Colors.blueGrey,
                        ),
                        StoreChip(
                          label: l10n.downloadsCount(program.downloadCount),
                          icon: Icons.download,
                          color: Colors.blueGrey,
                        ),
                        if (isOwn)
                          StoreChip(
                            label: l10n.yourProgramBadge,
                            icon: Icons.person,
                            color: AppColors.primary,
                          )
                        else if (isImported)
                          StoreChip(
                            label: l10n.alreadyImportedBadge,
                            icon: Icons.check_circle,
                            color: AppColors.success,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _Scrollable extends StatelessWidget {
  final Widget child;

  const _Scrollable({required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: child,
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String? title;
  final String text;
  final VoidCallback? onRetry;
  final String? retryLabel;

  const _Message({
    required this.icon,
    required this.text,
    this.title,
    this.onRetry,
    this.retryLabel,
  });

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).textTheme.bodySmall?.color;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: secondary),
            const SizedBox(height: 16),
            if (title != null) ...[
              Text(title!, style: AppTextStyles.h4, textAlign: TextAlign.center),
              const SizedBox(height: 8),
            ],
            Text(
              text,
              style: AppTextStyles.body2.copyWith(color: secondary),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryLabel ?? ''),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
