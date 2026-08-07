import 'package:flutter/material.dart';

import 'compose_page.dart';
import 'day_panel.dart';
import 'note.dart';
import 'note_actions.dart';
import 'note_api.dart';

/// 월간 캘린더(메인). 좌우로 스와이프하거나 제목 옆 화살표로 달을 넘긴다.
/// 각 달은 넘어갈 때 그 달치 데이터만 따로 불러온다(전체를 한 번에 안 불러도 됨).
/// 블록을 누르면 그 날 기록이 옆(좁으면 아래) 패널에 뜬다. 시작 시 오늘 선택.
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  // 달 ↔ PageView 인덱스 매핑 (연*12 + 월-1)
  static int _indexOf(DateTime m) => m.year * 12 + (m.month - 1);
  static DateTime _monthOf(int i) => DateTime(i ~/ 12, i % 12 + 1);

  late final PageController _pageController;
  late DateTime _month; // 현재 보이는 달
  late DateTime _selected; // 패널에 표시할 날짜 (기본: 오늘)
  int _reloadToken = 0; // 값이 바뀌면 각 달 뷰가 개수를 다시 가져온다

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _selected = DateTime(now.year, now.month, now.day);
    _pageController = PageController(initialPage: _indexOf(_month));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _compose() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const ComposePage()),
    );
    if (saved == true) {
      final now = DateTime.now();
      setState(() {
        _selected = DateTime(now.year, now.month, now.day);
        _reloadToken++;
      });
      _goToPage(_indexOf(DateTime(now.year, now.month))); // 오늘 달로 이동
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => _goToPage(_indexOf(_month) - 1),
            ),
            Text('${_month.year}년 ${_month.month}월'),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => _goToPage(_indexOf(_month) + 1),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: '기록 작성',
            icon: const Icon(Icons.edit_note),
            onPressed: _compose,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final pager = PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _month = _monthOf(i)),
            itemBuilder: (context, i) => _MonthView(
              month: _monthOf(i),
              selected: _selected,
              reloadToken: _reloadToken,
              onTapDay: (d) => setState(() => _selected = d),
            ),
          );
          final panel = DayPanel(
            date: _selected,
            onChanged: () => setState(() => _reloadToken++),
          );

          // 넓은 화면: 좌 캘린더(메인) : 우 노트 = 3 : 2
          if (constraints.maxWidth >= 600) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 3, child: pager),
                  const VerticalDivider(width: 1),
                  Expanded(flex: 2, child: panel),
                ],
              ),
            );
          }
          // 모바일(세로): 캘린더(접히는 헤더) + 노트 목록을 하나의 스크롤로.
          // 스크롤 올리면 캘린더가 접혀 올라가고, 내리면 다시 펼쳐진다.
          const sidePad = 16.0;
          final cell = (constraints.maxWidth - sidePad * 2 - 24 - 6 * 6) / 7;
          final calendarHeight = 6 * cell + 96;
          final ymd = _selected.toIso8601String().split('T').first;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                floating: true, // 스크롤 내리면 즉시 다시 펼쳐짐
                toolbarHeight: 0,
                expandedHeight: calendarHeight,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: sidePad),
                    child: pager,
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true, // 스크롤해도 날짜 헤더는 상단 고정
                delegate: _PinnedDateHeader(
                  ymd: ymd,
                  background: Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
              _DaySliverList(
                date: _selected,
                reloadToken: _reloadToken,
                onChanged: () => setState(() => _reloadToken++),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 스크롤해도 상단에 고정되는 날짜 헤더 + 진한 둥근 구분선.
class _PinnedDateHeader extends SliverPersistentHeaderDelegate {
  final String ymd;
  final Color background;

  _PinnedDateHeader({required this.ymd, required this.background});

  static const double _height = 56;

  @override
  double get minExtent => _height;
  @override
  double get maxExtent => _height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: background, // 아래 노트가 헤더 뒤로 비치지 않도록 불투명 배경
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 진하고 둥근 구분선
          Container(
            height: 4,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade500,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(ymd, style: Theme.of(context).textTheme.titleMedium),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_PinnedDateHeader old) => old.ymd != ymd || old.background != background;
}

/// 모바일용: 선택 날짜의 기록을 sliver 리스트로. 항목 탭 시 공용 상세 모달.
class _DaySliverList extends StatefulWidget {
  final DateTime date;
  final int reloadToken;
  final VoidCallback onChanged;

  const _DaySliverList({
    required this.date,
    required this.reloadToken,
    required this.onChanged,
  });

  @override
  State<_DaySliverList> createState() => _DaySliverListState();
}

class _DaySliverListState extends State<_DaySliverList> {
  final _api = NoteApi();
  List<Note>? _notes;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(_DaySliverList old) {
    super.didUpdateWidget(old);
    if (old.date != widget.date || old.reloadToken != widget.reloadToken) _load();
  }

  Future<void> _load() async {
    setState(() {
      _notes = null;
      _error = null;
    });
    try {
      final r = await _api.fetchByDate(widget.date);
      if (mounted) setState(() => _notes = r);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return SliverToBoxAdapter(
        child: Padding(padding: const EdgeInsets.all(24), child: Center(child: Text('불러오기 실패: $_error'))),
      );
    }
    if (_notes == null) {
      return const SliverToBoxAdapter(
        child: Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
      );
    }
    if (_notes!.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(padding: EdgeInsets.all(24), child: Center(child: Text('기록이 없습니다'))),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, i) {
          final n = _notes![i];
          return ListTile(
            title: Text(n.displayTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
            onTap: () => showNoteDetailDialog(context, n, widget.onChanged),
          );
        },
        childCount: _notes!.length,
      ),
    );
  }
}

/// 한 달치 잔디 그리드. 넘어올 때 그 달 개수만 따로 fetch.
class _MonthView extends StatefulWidget {
  final DateTime month;
  final DateTime selected;
  final int reloadToken;
  final void Function(DateTime) onTapDay;

  const _MonthView({
    required this.month,
    required this.selected,
    required this.reloadToken,
    required this.onTapDay,
  });

  @override
  State<_MonthView> createState() => _MonthViewState();
}

class _MonthViewState extends State<_MonthView> {
  final _api = NoteApi();
  late Future<Map<DateTime, int>> _counts;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(_MonthView old) {
    super.didUpdateWidget(old);
    // 추가/수정/삭제(reloadToken) 시에만 다시 가져온다. selected 변경은 재조회 불필요.
    if (old.reloadToken != widget.reloadToken) _load();
  }

  void _load() {
    final first = widget.month;
    final last = DateTime(widget.month.year, widget.month.month + 1, 0);
    _counts = _api.fetchCounts(first, last);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<DateTime, int>>(
      future: _counts,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('불러오기 실패: ${snap.error}'));
        }
        return _MonthGrid(
          month: widget.month,
          counts: snap.data ?? {},
          selected: widget.selected,
          onTapDay: widget.onTapDay,
        );
      },
    );
  }
}

class _MonthGrid extends StatelessWidget {
  final DateTime month;
  final Map<DateTime, int> counts;
  final DateTime selected;
  final void Function(DateTime) onTapDay;

  const _MonthGrid({
    required this.month,
    required this.counts,
    required this.selected,
    required this.onTapDay,
  });

  static const _weekdayLabels = ['일', '월', '화', '수', '목', '금', '토'];
  static const _gap = 6.0;
  static const _cols = 7;
  static const _rows = 6; // 6주 고정 (달 바뀔 때 흔들림 방지)
  static const _headerH = 22.0;
  static const _spacer = 6.0;

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingBlanks = month.weekday % 7;
    final cells = <int?>[...List.filled(leadingBlanks, null), for (var d = 1; d <= daysInMonth; d++) d];

    return Padding(
      padding: const EdgeInsets.all(12),
      child: LayoutBuilder(
        builder: (context, c) {
          // 칸 크기: 가로·세로 어느 쪽도 넘지 않도록 min 으로 결정
          double cell = (c.maxWidth - (_cols - 1) * _gap) / _cols;
          if (c.maxHeight.isFinite) {
            final byHeight = (c.maxHeight - _headerH - _spacer - (_rows - 1) * _gap) / _rows;
            if (byHeight < cell) cell = byHeight;
          }
          if (cell < 0) cell = 0;
          final gridWidth = _cols * cell + (_cols - 1) * _gap;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: gridWidth,
                height: _headerH,
                child: Row(
                  children: [
                    for (final label in _weekdayLabels)
                      Expanded(
                        child: Center(
                          child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: _spacer),
              SizedBox(
                width: gridWidth,
                child: Wrap(
                  spacing: _gap,
                  runSpacing: _gap,
                  children: [
                    for (final day in cells)
                      SizedBox(
                        width: cell,
                        height: cell,
                        child: day == null
                            ? null
                            : _DayCell(
                                day: day,
                                count: counts[DateTime(month.year, month.month, day)] ?? 0,
                                selected: _isSameDay(selected, DateTime(month.year, month.month, day)),
                                onTap: () => onTapDay(DateTime(month.year, month.month, day)),
                              ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DayCell extends StatelessWidget {
  final int day;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  Color _shade() {
    if (count <= 0) return const Color(0xFFEBEDF0);
    if (count <= 2) return Colors.green.shade200;
    if (count <= 4) return Colors.green.shade400;
    if (count <= 6) return Colors.green.shade600;
    return Colors.green.shade800;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(top: 3, right: 5),
        decoration: BoxDecoration(
          color: _shade(),
          borderRadius: BorderRadius.circular(6),
          border: selected
              ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
              : null,
        ),
        // 우상단 날짜 숫자: 색칸은 흰색, 빈 칸(연회색)은 회색 글자로 대비 확보
        child: Align(
          alignment: Alignment.topRight,
          child: Text(
            '$day',
            style: TextStyle(
              color: count > 0 ? Colors.white : Colors.grey.shade500,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
