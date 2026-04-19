import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';
import '../../config/strings.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/websocket_service.dart';
import 'chat_detail_screen.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animController;
  String? _userName;

  final List<ChatItem> _chats = const [
    ChatItem(
      name: 'Project Alpha Team',
      lastMessage: 'Meeting confirmed for 3 PM today',
      timestamp: '2m',
      unreadCount: 3,
      isGroup: true,
      avatar: 'PA',
      avatarColor: AppTheme.primaryColor,
      isOnline: true,
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
      lastMessage: 'New mockups ready for review',
      timestamp: '1h',
      unreadCount: 5,
      isGroup: true,
      avatar: 'DT',
      avatarColor: Color(0xFF00BFFF),
      isOnline: false,
    ),
    ChatItem(
      name: 'Sarah Smith',
      lastMessage: 'Thanks for the update!',
      timestamp: '3h',
      unreadCount: 0,
      isGroup: false,
      avatar: 'SS',
      avatarColor: Color(0xFFFF9F43),
      isOnline: false,
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
      isOnline: false,
    ),
    ChatItem(
      name: 'Product Team',
      lastMessage: 'Sprint planning tomorrow',
      timestamp: '1d',
      unreadCount: 1,
      isGroup: true,
      avatar: 'PT',
      avatarColor: Color(0xFF3F51B5),
      isOnline: false,
    ),
  ];

  List<ChatItem> get _filtered {
    if (_searchController.text.isEmpty) return _chats;
    final q = _searchController.text.toLowerCase();
    return _chats
        .where(
          (c) =>
              c.name.toLowerCase().contains(q) ||
              c.lastMessage.toLowerCase().contains(q),
        )
        .toList();
  }

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
        appBar: _buildAppBar(),
        body: Column(children: [Expanded(child: _buildChatList())]),
        floatingActionButton: _buildFAB(),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.surfaceColor,
      elevation: 0,
      scrolledUnderElevation: 1,
      title: Text(
        _userName ?? 'Chats',
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: AppTheme.fontSizeXL,
          fontWeight: FontWeight.w800,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded, color: AppTheme.textSecondary),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(
            Icons.notifications_outlined,
            color: AppTheme.textSecondary,
          ),
          onPressed: () {},
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.spacingM,
            0,
            AppTheme.spacingM,
            AppTheme.spacingS,
          ),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Row(
              children: [
                const SizedBox(width: AppTheme.spacingM),
                const Icon(
                  Icons.search_rounded,
                  color: AppTheme.textMuted,
                  size: 20,
                ),
                const SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: AppTheme.fontSizeM,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Search conversations...',
                      hintStyle: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      fillColor: Colors.transparent,
                      filled: true,
                    ),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() {});
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(right: AppTheme.spacingM),
                      child: Icon(
                        Icons.close_rounded,
                        color: AppTheme.textMuted,
                        size: 18,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatList() {
    final list = _filtered;
    if (list.isEmpty) return _buildEmptyState();

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: AppTheme.spacingS, bottom: 80),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final anim = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _animController,
            curve: Interval(
              (index / list.length).clamp(0.0, 0.7),
              ((index + 1) / list.length).clamp(0.0, 1.0),
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
            child: _buildChatTile(list[index]),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withAlpha(18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 36,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          const Text(
            'No conversations yet',
            style: TextStyle(
              fontSize: AppTheme.fontSizeL,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTile(ChatItem chat) {
    return Dismissible(
      key: Key(chat.name + chat.timestamp),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppTheme.spacingL),
        color: AppTheme.errorColor,
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
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
          splashColor: AppTheme.primaryColor.withAlpha(10),
          highlightColor: AppTheme.primaryColor.withAlpha(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingM,
              vertical: 12,
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: chat.avatarColor,
                    borderRadius: BorderRadius.circular(chat.isGroup ? 12 : 26),
                  ),
                  child: Center(
                    child: Text(
                      chat.avatar,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              chat.name,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: AppTheme.fontSizeM,
                                fontWeight: chat.unreadCount > 0
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          if (chat.isTyping) _buildTypingIndicator(),
                        ],
                      ),
                      const SizedBox(height: 2),
                      chat.isTyping
                          ? Text(
                              'typing...',
                              style: TextStyle(
                                fontSize: AppTheme.fontSizeS,
                                color: AppTheme.primaryColor,
                                fontStyle: FontStyle.italic,
                              ),
                            )
                          : Text(
                              chat.lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: AppTheme.fontSizeS,
                                color: chat.unreadCount > 0
                                    ? AppTheme.textSecondary
                                    : AppTheme.textMuted,
                              ),
                            ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      chat.timestamp,
                      style: TextStyle(
                        fontSize: 10,
                        color: chat.unreadCount > 0
                            ? AppTheme.primaryColor
                            : AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (chat.unreadCount > 0)
                      Container(
                        constraints: const BoxConstraints(minWidth: 20),
                        height: 20,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            chat.unreadCount > 99
                                ? '99+'
                                : '${chat.unreadCount}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return SizedBox(
      width: 24,
      height: 12,
      child: Row(
        children: List.generate(
          3,
          (i) => AnimatedContainer(
            duration: Duration(milliseconds: 300 + i * 150),
            margin: const EdgeInsets.symmetric(horizontal: 1),
            width: 3,
            height: 3,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return Container(
      width: 52,
      height: 52,
      margin: const EdgeInsets.only(bottom: 8, right: 4),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withAlpha(80),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => _showNewChatOptions(),
          child: const Icon(Icons.edit_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      (Icons.chat_bubble_rounded, 'Chats'),
      (Icons.groups_rounded, 'Teams'),
      (Icons.calendar_month_rounded, 'Calendar'),
      (Icons.person_rounded, 'Profile'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          top: BorderSide(color: AppTheme.borderColor, width: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(4, (i) {
              final selected = _selectedIndex == i;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedIndex = i);
                  _handleNav(i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppTheme.primaryColor.withAlpha(18)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        items[i].$1,
                        color: selected
                            ? AppTheme.primaryColor
                            : AppTheme.textMuted,
                        size: 22,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        items[i].$2,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: selected
                              ? AppTheme.primaryColor
                              : AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  void _openChat(ChatItem chat) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Opening ${chat.name}'),
      duration: const Duration(milliseconds: 600),
    ),
  );

  void _showChatOptions(ChatItem chat) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              ListTile(
                leading: const Icon(
                  Icons.search,
                  color: AppTheme.textSecondary,
                ),
                title: const Text('Search'),
                onTap: () => Navigator.pop(ctx),
              ),
              ListTile(
                leading: const Icon(
                  Icons.notifications_off_outlined,
                  color: AppTheme.textSecondary,
                ),
                title: const Text('Mute'),
                onTap: () => Navigator.pop(ctx),
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: AppTheme.errorColor),
                title: Text(
                  'Delete',
                  style: TextStyle(color: AppTheme.errorColor),
                ),
                onTap: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNewChatOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNewChatOption(Icons.person_add, 'New Chat', ctx),
                  _buildNewChatOption(Icons.group_add, 'New Group', ctx),
                  _buildNewChatOption(Icons.campaign, 'Broadcast', ctx),
                ],
              ),
              const SizedBox(height: AppTheme.spacingM),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewChatOption(IconData icon, String label, BuildContext ctx) =>
      GestureDetector(
        onTap: () {
          Navigator.pop(ctx);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('$label coming soon')));
        },
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );

  void _handleNav(int index) {
    final msgs = [
      null,
      AppStrings.teamsComingSoon,
      AppStrings.calendarComingSoon,
      AppStrings.profileComingSoon,
    ];
    if (msgs[index] != null)
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(msgs[index]!)));
  }
}

class ChatItem {
  final String name, lastMessage, timestamp, avatar;
  final int unreadCount;
  final bool isGroup, isOnline, isTyping;
  final Color avatarColor;

  const ChatItem({
    required this.name,
    required this.lastMessage,
    required this.timestamp,
    required this.unreadCount,
    required this.isGroup,
    required this.avatar,
    required this.avatarColor,
    this.isOnline = false,
    this.isTyping = false,
  });
}
