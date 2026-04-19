import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';
import '../../config/strings.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/websocket_service.dart';
import 'chat_detail_screen.dart';
import 'new_chat_screen.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  int _selectedFilter = 0;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animController;
  String? _userName;

  final List<String> _filters = const ['All', 'Unread', 'Groups', 'Archived'];

  List<ChatItem> _chats = const [
    ChatItem(
      name: 'Project Alpha Team',
      lastMessage: 'Meeting confirmed for 3 PM today',
      timestamp: '2m',
      unreadCount: 3,
      isGroup: true,
      avatar: 'PA',
      avatarColor: AppTheme.primaryColor,
      isOnline: true,
      isPinned: true,
      messageStatus: MessageStatus.delivered,
    ),
    ChatItem(
      name: 'John Doe',
      lastMessage: 'Typing...',
      timestamp: '15m',
      unreadCount: 0,
      isGroup: false,
      avatar: 'JD',
      avatarColor: Color(0xFFFF6B6B),
      isOnline: true,
      isTyping: true,
    ),
    ChatItem(
      name: 'Design Team',
      lastMessage: '📎 New mockups ready for review',
      timestamp: '1h',
      unreadCount: 5,
      isGroup: true,
      avatar: 'DT',
      avatarColor: Color(0xFF00BFFF),
      isPinned: true,
      messageStatus: MessageStatus.read,
    ),
    ChatItem(
      name: 'Sarah Smith',
      lastMessage: 'Thanks for the update! 🙌',
      timestamp: '3h',
      unreadCount: 0,
      isGroup: false,
      avatar: 'SS',
      avatarColor: Color(0xFFFF9F43),
      isMuted: true,
      messageStatus: MessageStatus.read,
    ),
    ChatItem(
      name: 'Development Squad',
      lastMessage: 'PR #234 ready for review',
      timestamp: '5h',
      unreadCount: 2,
      isGroup: true,
      avatar: 'DS',
      avatarColor: Color(0xFF00C853),
      isOnline: true,
    ),
    ChatItem(
      name: 'Mike Wilson',
      lastMessage: 'Let me check the docs',
      timestamp: '1d',
      unreadCount: 0,
      isGroup: false,
      avatar: 'MW',
      avatarColor: Color(0xFF9C27B0),
      messageStatus: MessageStatus.sent,
    ),
    ChatItem(
      name: 'Product Team',
      lastMessage: 'Sprint planning tomorrow',
      timestamp: '1d',
      unreadCount: 1,
      isGroup: true,
      avatar: 'PT',
      avatarColor: Color(0xFF3F51B5),
    ),
  ];

  List<ChatItem> get _filtered {
    var list = _chats;

    if (_selectedFilter == 0) {
      list = list.where((c) => !c.isArchived).toList();
    } else if (_selectedFilter == 1) {
      list = list.where((c) => c.unreadCount > 0 && !c.isArchived).toList();
    } else if (_selectedFilter == 2) {
      list = list.where((c) => c.isGroup && !c.isArchived).toList();
    } else if (_selectedFilter == 3) {
      list = list.where((c) => c.isArchived).toList();
    }

    if (_searchController.text.isEmpty) return list;
    final q = _searchController.text.toLowerCase();
    return list
        .where(
          (c) =>
              c.name.toLowerCase().contains(q) ||
              c.lastMessage.toLowerCase().contains(q),
        )
        .toList();
  }

  List<ChatItem> get _pinnedChats =>
      _filtered.where((c) => c.isPinned).toList();
  List<ChatItem> get _regularChats =>
      _filtered.where((c) => !c.isPinned).toList();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    _searchController.addListener(() => setState(() {}));
    _loadUser();
    _connectWebSocket();
  }

  Future<void> _loadUser() async {
    final name = await StorageService.instance.getUserName();
    if (mounted) setState(() => _userName = name);
  }

  Future<void> _connectWebSocket() async {
    await WebSocketService.instance.connect();
    WebSocketService.instance.messages.listen((messages) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Column(
          children: [
            _buildGradientHeader(),
            _buildFilterChips(),
            Expanded(child: _buildChatList()),
          ],
        ),
        floatingActionButton: _buildFAB(),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  // ── Gradient Header ──────────────────────────────────────────────────────
  Widget _buildGradientHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            children: [
              Row(
                children: [
                  _buildProfileAvatar(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(),
                          style: TextStyle(
                            color: Colors.white.withAlpha(200),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _userName ?? 'Smart App',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _headerIconButton(
                    Icons.notifications_outlined,
                    badge: '3',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSearchBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    final initials = _initials();
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withAlpha(100), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(40),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            initials,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerIconButton(
    IconData icon, {
    String? badge,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(40),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          if (badge != null)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4757),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final hasText = _searchController.text.isNotEmpty;
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(40),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(60), width: 1),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.search_rounded, color: Colors.white, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: 'Search names, messages, groups...',
                hintStyle: TextStyle(
                  color: Colors.white.withAlpha(180),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: hasText
                ? GestureDetector(
                    key: const ValueKey('clear'),
                    onTap: () {
                      _searchController.clear();
                      setState(() {});
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: AppTheme.errorColor,
                        size: 18,
                      ),
                    ),
                  )
                : GestureDetector(
                    key: const ValueKey('actions'),
                    onTap: () {},
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(50),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.mic_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ── Filter Chips ─────────────────────────────────────────────────────────
  Widget _buildFilterChips() {
    final activeChats = _chats.where((c) => !c.isArchived).toList();
    final unreadCount = activeChats.where((c) => c.unreadCount > 0).length;
    final groupCount = activeChats.where((c) => c.isGroup).length;
    final archivedCount = _chats.where((c) => c.isArchived).length;
    final counts = [activeChats.length, unreadCount, groupCount, archivedCount];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final selected = _selectedFilter == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: selected ? AppTheme.primaryGradient : null,
                  color: selected ? null : AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? Colors.transparent : AppTheme.borderColor,
                    width: 1,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryColor.withAlpha(50),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _filters[index],
                      style: TextStyle(
                        color: selected ? Colors.white : AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (counts[index] > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? Colors.white.withAlpha(60)
                              : AppTheme.primaryColor.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${counts[index]}',
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : AppTheme.primaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Chat List ────────────────────────────────────────────────────────────
  Widget _buildChatList() {
    final pinned = _pinnedChats;
    final regular = _regularChats;

    if (pinned.isEmpty && regular.isEmpty) return _buildEmptyState();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 4, bottom: 100),
      children: [
        if (pinned.isNotEmpty) ...[
          _buildSectionHeader(Icons.push_pin_rounded, 'Pinned'),
          ...pinned.asMap().entries.map(
            (e) =>
                _animatedTile(e.value, e.key, pinned.length + regular.length),
          ),
          const SizedBox(height: 8),
        ],
        if (regular.isNotEmpty) ...[
          _buildSectionHeader(Icons.chat_bubble_rounded, 'All Chats'),
          ...regular.asMap().entries.map(
            (e) => _animatedTile(
              e.value,
              e.key + pinned.length,
              pinned.length + regular.length,
            ),
          ),
        ],
      ],
    );
  }

  Widget _animatedTile(ChatItem chat, int index, int total) {
    final anim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Interval(
          (index / total).clamp(0.0, 0.7),
          ((index + 1) / total).clamp(0.0, 1.0),
          curve: Curves.easeOutCubic,
        ),
      ),
    );
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.05, 0),
          end: Offset.zero,
        ).animate(anim),
        child: _buildChatTile(chat),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppTheme.textMuted),
          const SizedBox(width: 6),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.textMuted,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withAlpha(18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.forum_outlined,
              size: 44,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No conversations found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try a different search or filter',
            style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  // ── Chat Tile ────────────────────────────────────────────────────────────
  Widget _buildChatTile(ChatItem chat) {
    return Dismissible(
      key: Key(chat.name + chat.timestamp),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.errorColor.withAlpha(200), AppTheme.errorColor],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Delete Chat'),
            content: Text('Delete conversation with ${chat.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.errorColor,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openChat(chat),
          onLongPress: () => _showChatOptions(chat),
          splashColor: AppTheme.primaryColor.withAlpha(15),
          highlightColor: AppTheme.primaryColor.withAlpha(8),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                _buildAvatarWithStatus(chat),
                const SizedBox(width: 12),
                Expanded(child: _buildChatContent(chat)),
                const SizedBox(width: 8),
                _buildChatTrailing(chat),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarWithStatus(ChatItem chat) {
    return Stack(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: chat.avatarColor,
            borderRadius: BorderRadius.circular(chat.isGroup ? 14 : 27),
            boxShadow: [
              BoxShadow(
                color: chat.avatarColor.withAlpha(50),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              chat.avatar,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
        ),
        if (chat.isOnline && !chat.isGroup)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: AppTheme.onlineColor,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.backgroundColor, width: 2.5),
              ),
            ),
          ),
        if (chat.isGroup)
          Positioned(
            bottom: -2,
            right: -2,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.backgroundColor, width: 2),
              ),
              child: const Icon(
                Icons.groups_rounded,
                size: 10,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildChatContent(ChatItem chat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                chat.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: chat.unreadCount > 0
                      ? FontWeight.w800
                      : FontWeight.w600,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            if (chat.isMuted) ...[
              const SizedBox(width: 6),
              Icon(
                Icons.volume_off_rounded,
                size: 13,
                color: AppTheme.textMuted,
              ),
            ],
            if (chat.isPinned) ...[
              const SizedBox(width: 4),
              Icon(Icons.push_pin_rounded, size: 12, color: AppTheme.textMuted),
            ],
          ],
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            if (chat.messageStatus != null && chat.unreadCount == 0) ...[
              _buildMessageStatus(chat.messageStatus!),
              const SizedBox(width: 4),
            ],
            if (chat.isTyping)
              Expanded(child: _buildTypingRow())
            else
              Expanded(
                child: Text(
                  chat.lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: chat.unreadCount > 0
                        ? AppTheme.textSecondary
                        : AppTheme.textMuted,
                    fontWeight: chat.unreadCount > 0
                        ? FontWeight.w500
                        : FontWeight.w400,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildMessageStatus(MessageStatus status) {
    switch (status) {
      case MessageStatus.sent:
        return Icon(Icons.check_rounded, size: 14, color: AppTheme.textMuted);
      case MessageStatus.delivered:
        return Icon(
          Icons.done_all_rounded,
          size: 14,
          color: AppTheme.textMuted,
        );
      case MessageStatus.read:
        return Icon(
          Icons.done_all_rounded,
          size: 14,
          color: AppTheme.primaryColor,
        );
    }
  }

  Widget _buildTypingRow() {
    return Row(
      children: [
        _buildTypingIndicator(),
        const SizedBox(width: 6),
        Text(
          'typing',
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.primaryColor,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return SizedBox(
      width: 20,
      height: 10,
      child: Row(
        children: List.generate(
          3,
          (i) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 1),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withAlpha(150 + i * 30),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatTrailing(ChatItem chat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          chat.timestamp,
          style: TextStyle(
            fontSize: 11,
            color: chat.unreadCount > 0
                ? AppTheme.primaryColor
                : AppTheme.textMuted,
            fontWeight: chat.unreadCount > 0
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        if (chat.unreadCount > 0)
          Container(
            constraints: const BoxConstraints(minWidth: 22),
            height: 22,
            padding: const EdgeInsets.symmetric(horizontal: 7),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(11),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withAlpha(80),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                chat.unreadCount > 99 ? '99+' : '${chat.unreadCount}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1,
                ),
              ),
            ),
          )
        else
          const SizedBox(height: 22),
      ],
    );
  }

  // ── FAB ──────────────────────────────────────────────────────────────────
  Widget _buildFAB() {
    return Container(
      width: 58,
      height: 58,
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withAlpha(100),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => _showNewChatOptions(),
          child: const Icon(Icons.chat_rounded, color: Colors.white, size: 26),
        ),
      ),
    );
  }

  // ── Bottom Nav ───────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      (Icons.chat_bubble_rounded, Icons.chat_bubble_outline_rounded, 'Chats'),
      (Icons.groups_rounded, Icons.groups_outlined, 'Teams'),
      (Icons.calendar_month_rounded, Icons.calendar_month_outlined, 'Calendar'),
      (Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          top: BorderSide(color: AppTheme.borderColor, width: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(4, (i) {
              final selected = _selectedIndex == i;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() => _selectedIndex = i);
                    _handleNav(i);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.primaryColor.withAlpha(20)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          selected ? items[i].$1 : items[i].$2,
                          color: selected
                              ? AppTheme.primaryColor
                              : AppTheme.textMuted,
                          size: 22,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          items[i].$3,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: selected
                                ? AppTheme.primaryColor
                                : AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning 👋';
    if (hour < 17) return 'Good afternoon 👋';
    return 'Good evening 👋';
  }

  String _initials() {
    final name = _userName ?? 'ME';
    if (name.isEmpty) return 'ME';
    final parts = name.trim().split(' ');
    if (parts.length >= 2 && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (name.length >= 2) return name.substring(0, 2).toUpperCase();
    return name[0].toUpperCase();
  }

  void _openChat(ChatItem chat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatDetailScreen(
          conversationId: chat.conversationId ?? '',
          chatName: chat.name,
          avatar: chat.avatar,
          avatarColor: chat.avatarColor,
        ),
      ),
    );
  }

  void _showChatOptions(ChatItem chat) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Chat preview header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: chat.avatarColor,
                      borderRadius: BorderRadius.circular(
                        chat.isGroup ? 12 : 22,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        chat.avatar,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chat.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          chat.isGroup ? 'Group chat' : 'Direct message',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppTheme.borderColor),
            const SizedBox(height: 8),
            _sheetTile(
              chat.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
              chat.isPinned ? 'Unpin chat' : 'Pin chat',
              ctx,
              onTap: () => _togglePin(chat),
            ),
            _sheetTile(
              chat.isMuted
                  ? Icons.notifications_active_outlined
                  : Icons.notifications_off_outlined,
              chat.isMuted ? 'Unmute notifications' : 'Mute notifications',
              ctx,
              onTap: () => _toggleMute(chat),
            ),
            _sheetTile(
              Icons.done_all_rounded,
              chat.unreadCount > 0 ? 'Mark as read' : 'Already read',
              ctx,
              disabled: chat.unreadCount == 0,
              onTap: chat.unreadCount > 0 ? () => _markAsRead(chat) : null,
            ),
            _sheetTile(
              chat.isArchived
                  ? Icons.unarchive_outlined
                  : Icons.archive_outlined,
              chat.isArchived ? 'Unarchive chat' : 'Archive chat',
              ctx,
              onTap: () => _toggleArchive(chat),
            ),
            const Divider(
              height: 16,
              indent: 20,
              endIndent: 20,
              color: AppTheme.borderColor,
            ),
            _sheetTile(
              Icons.delete_outline_rounded,
              'Delete chat',
              ctx,
              destructive: true,
              onTap: () => _confirmDelete(chat),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _sheetTile(
    IconData icon,
    String label,
    BuildContext ctx, {
    bool destructive = false,
    bool disabled = false,
    VoidCallback? onTap,
  }) {
    final tintColor = destructive
        ? AppTheme.errorColor
        : disabled
        ? AppTheme.textMuted
        : AppTheme.primaryColor;
    final textColor = destructive
        ? AppTheme.errorColor
        : disabled
        ? AppTheme.textMuted
        : AppTheme.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled
            ? null
            : () {
                Navigator.pop(ctx);
                onTap?.call();
              },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: tintColor.withAlpha(disabled ? 12 : 20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: tintColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              if (!destructive && !disabled)
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.textMuted,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Chat Actions ─────────────────────────────────────────────────────────
  void _togglePin(ChatItem chat) {
    setState(() {
      _chats = _chats
          .map(
            (c) => c.name == chat.name ? c.copyWith(isPinned: !c.isPinned) : c,
          )
          .toList();
    });
    _showSnack(
      chat.isPinned ? 'Chat unpinned' : 'Chat pinned',
      icon: Icons.push_pin_rounded,
    );
  }

  void _toggleMute(ChatItem chat) {
    setState(() {
      _chats = _chats
          .map((c) => c.name == chat.name ? c.copyWith(isMuted: !c.isMuted) : c)
          .toList();
    });
    _showSnack(
      chat.isMuted ? 'Notifications enabled' : 'Notifications muted',
      icon: chat.isMuted
          ? Icons.notifications_active_rounded
          : Icons.notifications_off_rounded,
    );
  }

  void _markAsRead(ChatItem chat) {
    setState(() {
      _chats = _chats
          .map((c) => c.name == chat.name ? c.copyWith(unreadCount: 0) : c)
          .toList();
    });
    _showSnack('Marked as read', icon: Icons.done_all_rounded);
  }

  void _toggleArchive(ChatItem chat) {
    final wasArchived = chat.isArchived;
    setState(() {
      _chats = _chats
          .map(
            (c) =>
                c.name == chat.name ? c.copyWith(isArchived: !c.isArchived) : c,
          )
          .toList();
    });
    _showSnack(
      wasArchived ? 'Chat unarchived' : 'Chat archived',
      icon: wasArchived ? Icons.unarchive_rounded : Icons.archive_rounded,
      action: SnackBarAction(
        label: 'UNDO',
        textColor: AppTheme.primaryColor,
        onPressed: () =>
            _toggleArchive(chat.copyWith(isArchived: !wasArchived)),
      ),
    );
  }

  void _confirmDelete(ChatItem chat) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Chat'),
        content: Text(
          'Delete conversation with ${chat.name}? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteChat(chat);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteChat(ChatItem chat) {
    setState(() {
      _chats = _chats.where((c) => c.name != chat.name).toList();
    });
    _showSnack('Chat deleted', icon: Icons.delete_rounded);
  }

  void _showSnack(String msg, {IconData? icon, SnackBarAction? action}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 10),
            ],
            Expanded(child: Text(msg)),
          ],
        ),
        action: action,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showNewChatOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Start a new conversation',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _newChatAction(Icons.person_add_rounded, 'New Chat', ctx),
                _newChatAction(Icons.group_add_rounded, 'New Group', ctx),
                _newChatAction(Icons.campaign_rounded, 'Broadcast', ctx),
                _newChatAction(Icons.qr_code_scanner_rounded, 'Scan', ctx),
              ],
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _newChatAction(IconData icon, String label, BuildContext ctx) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(ctx);
        if (label == 'New Chat') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewChatScreen()),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('$label coming soon')));
        }
      },
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withAlpha(60),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _handleNav(int index) {
    final msgs = [
      null,
      AppStrings.teamsComingSoon,
      AppStrings.calendarComingSoon,
      AppStrings.profileComingSoon,
    ];
    if (msgs[index] != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(msgs[index]!)));
    }
  }
}

enum MessageStatus { sent, delivered, read }

class ChatItem {
  final String name, lastMessage, timestamp, avatar;
  final String? conversationId;
  final int unreadCount;
  final bool isGroup, isOnline, isTyping, isPinned, isMuted, isArchived;
  final Color avatarColor;
  final MessageStatus? messageStatus;

  const ChatItem({
    required this.name,
    required this.lastMessage,
    required this.timestamp,
    required this.unreadCount,
    required this.isGroup,
    required this.avatar,
    required this.avatarColor,
    this.conversationId,
    this.isOnline = false,
    this.isTyping = false,
    this.isPinned = false,
    this.isMuted = false,
    this.isArchived = false,
    this.messageStatus,
  });

  ChatItem copyWith({
    String? name,
    String? lastMessage,
    String? timestamp,
    String? avatar,
    String? conversationId,
    int? unreadCount,
    bool? isGroup,
    bool? isOnline,
    bool? isTyping,
    bool? isPinned,
    bool? isMuted,
    bool? isArchived,
    Color? avatarColor,
    MessageStatus? messageStatus,
  }) {
    return ChatItem(
      name: name ?? this.name,
      lastMessage: lastMessage ?? this.lastMessage,
      timestamp: timestamp ?? this.timestamp,
      avatar: avatar ?? this.avatar,
      conversationId: conversationId ?? this.conversationId,
      unreadCount: unreadCount ?? this.unreadCount,
      isGroup: isGroup ?? this.isGroup,
      isOnline: isOnline ?? this.isOnline,
      isTyping: isTyping ?? this.isTyping,
      isPinned: isPinned ?? this.isPinned,
      isMuted: isMuted ?? this.isMuted,
      isArchived: isArchived ?? this.isArchived,
      avatarColor: avatarColor ?? this.avatarColor,
      messageStatus: messageStatus ?? this.messageStatus,
    );
  }
}
