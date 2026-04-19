import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';
import '../../config/strings.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _listAnim;

  final List<ChatItem> _chats = const [
    ChatItem(name: 'Project Alpha Team', lastMessage: 'Meeting confirmed for 3 PM today',
        timestamp: '2 min', unreadCount: 3, isGroup: true,
        avatar: 'PA', avatarColor: AppTheme.primaryColor, isOnline: true),
    ChatItem(name: 'John Doe', lastMessage: 'Sounds good! See you then.',
        timestamp: '15 min', unreadCount: 0, isGroup: false,
        avatar: 'JD', avatarColor: Color(0xFFFF6B6B), isOnline: true),
    ChatItem(name: 'Design Team', lastMessage: 'New mockups are ready for review',
        timestamp: '1 hr', unreadCount: 5, isGroup: true,
        avatar: 'DT', avatarColor: Color(0xFF00BFFF), isOnline: false),
    ChatItem(name: 'Sarah Smith', lastMessage: 'Thanks for the update!',
        timestamp: '3 hr', unreadCount: 0, isGroup: false,
        avatar: 'SS', avatarColor: Color(0xFFFF9F43), isOnline: false),
    ChatItem(name: 'Development Squad', lastMessage: 'PR #234 is ready for review',
        timestamp: '5 hr', unreadCount: 2, isGroup: true,
        avatar: 'DS', avatarColor: Color(0xFF00C853), isOnline: true),
  ];

  List<ChatItem> get _filtered {
    if (_searchController.text.isEmpty) return _chats;
    final q = _searchController.text.toLowerCase();
    return _chats.where((c) =>
        c.name.toLowerCase().contains(q) ||
        c.lastMessage.toLowerCase().contains(q)).toList();
  }

  @override
  void initState() {
    super.initState();
    _listAnim = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this)
      ..forward();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _listAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Column(
          children: [
            _buildToolbar(),
            _buildSearchBar(),
            _buildOnlineStrip(),
            Expanded(child: _buildList()),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(),
        floatingActionButton: _buildFAB(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
            bottom: BorderSide(color: AppTheme.borderColor, width: 0.8)),
        boxShadow: [
          BoxShadow(
              color: Color(0x08000000),
              blurRadius: 8,
              offset: Offset(0, 2))
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingM, vertical: AppTheme.spacingS),
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle),
                    child: const Center(
                      child: Text('Me',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: AppTheme.fontSizeS,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                  Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                          color: AppTheme.onlineColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppTheme.surfaceColor, width: 1.5)),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(AppStrings.chatsTitle,
                        style: TextStyle(
                            fontSize: AppTheme.fontSizeXL,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.3)),
                    Text('5 conversations',
                        style: TextStyle(
                            fontSize: AppTheme.fontSizeS,
                            color: AppTheme.textMuted)),
                  ],
                ),
              ),
              _toolbarBtn(Icons.notifications_outlined, () {}),
              const SizedBox(width: AppTheme.spacingXS),
              _toolbarBtn(Icons.more_vert_rounded, () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toolbarBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Icon(icon, color: AppTheme.textSecondary, size: 20),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppTheme.spacingM, AppTheme.spacingM, AppTheme.spacingM, 0),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(AppTheme.radiusRound),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Row(
          children: [
            const SizedBox(width: AppTheme.spacingM),
            const Icon(Icons.search_rounded,
                color: AppTheme.textMuted, size: 20),
            const SizedBox(width: AppTheme.spacingS),
            Expanded(
              child: TextField(
                controller: _searchController,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: AppTheme.fontSizeM),
                decoration: const InputDecoration(
                  hintText: AppStrings.search,
                  hintStyle:
                      TextStyle(color: AppTheme.textMuted, fontSize: 14),
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
                  child: Icon(Icons.close_rounded,
                      color: AppTheme.textMuted, size: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnlineStrip() {
    final online = _chats.where((c) => c.isOnline && !c.isGroup).toList();
    if (online.isEmpty) return const SizedBox(height: AppTheme.spacingM);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(
              AppTheme.spacingM, AppTheme.spacingM, 0, AppTheme.spacingS),
          child: Text('Active Now',
              style: TextStyle(
                  fontSize: AppTheme.fontSizeS,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted,
                  letterSpacing: 0.5)),
        ),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingM),
            itemCount: online.length,
            itemBuilder: (_, i) {
              final c = online[i];
              return Padding(
                padding:
                    const EdgeInsets.only(right: AppTheme.spacingM),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: c.avatarColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: c.avatarColor.withAlpha(70),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3)),
                            ],
                          ),
                          child: Center(
                            child: Text(c.avatar,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: AppTheme.fontSizeS,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            width: 11,
                            height: 11,
                            decoration: BoxDecoration(
                                color: AppTheme.onlineColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppTheme.surfaceColor,
                                    width: 1.5)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingXS),
                    Text(c.name.split(' ').first,
                        style: const TextStyle(
                            fontSize: AppTheme.fontSizeXS,
                            color: AppTheme.textSecondary),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              );
            },
          ),
        ),
        const Divider(height: 0, color: AppTheme.dividerColor),
      ],
    );
  }

  Widget _buildList() {
    final list = _filtered;
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: AppTheme.spacingS),
      itemCount: list.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 0, indent: 78, color: AppTheme.dividerColor),
      itemBuilder: (context, index) {
        final anim = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _listAnim,
            curve: Interval(
              (index / list.length) * 0.6,
              ((index + 1) / list.length).clamp(0.0, 1.0),
              curve: Curves.easeOut,
            ),
          ),
        );
        return FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
                    begin: const Offset(0.04, 0), end: Offset.zero)
                .animate(anim),
            child: _buildTile(list[index]),
          ),
        );
      },
    );
  }

  Widget _buildTile(ChatItem chat) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openChat(chat),
        splashColor: AppTheme.primaryColor.withAlpha(10),
        highlightColor: AppTheme.primaryColor.withAlpha(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingM, vertical: 10),
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: chat.avatarColor,
                      borderRadius:
                          BorderRadius.circular(chat.isGroup ? 14 : 28),
                      boxShadow: [
                        BoxShadow(
                            color: chat.avatarColor.withAlpha(60),
                            blurRadius: 8,
                            offset: const Offset(0, 3)),
                      ],
                    ),
                    child: Center(
                      child: Text(chat.avatar,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16)),
                    ),
                  ),
                  if (chat.isOnline)
                    Positioned(
                      bottom: 1,
                      right: 1,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                            color: AppTheme.onlineColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppTheme.backgroundColor,
                                width: 2)),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(chat.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: AppTheme.fontSizeL,
                                        fontWeight: chat.unreadCount > 0
                                            ? FontWeight.w700
                                            : FontWeight.w600,
                                        color: AppTheme.textPrimary)),
                              ),
                              if (chat.isGroup) ...[
                                const SizedBox(width: AppTheme.spacingXS),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color:
                                        chat.avatarColor.withAlpha(20),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                        color:
                                            chat.avatarColor.withAlpha(60),
                                        width: 0.5),
                                  ),
                                  child: Text('GROUP',
                                      style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: chat.avatarColor,
                                          letterSpacing: 0.5)),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingXS),
                        Text(chat.timestamp,
                            style: TextStyle(
                                fontSize: AppTheme.fontSizeXS,
                                color: chat.unreadCount > 0
                                    ? AppTheme.primaryColor
                                    : AppTheme.textMuted,
                                fontWeight: chat.unreadCount > 0
                                    ? FontWeight.w600
                                    : FontWeight.normal)),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingXS),
                    Row(
                      children: [
                        Expanded(
                          child: Text(chat.lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: AppTheme.fontSizeM,
                                  color: chat.unreadCount > 0
                                      ? AppTheme.textSecondary
                                      : AppTheme.textMuted,
                                  fontWeight: chat.unreadCount > 0
                                      ? FontWeight.w500
                                      : FontWeight.normal)),
                        ),
                        if (chat.unreadCount > 0) ...[
                          const SizedBox(width: AppTheme.spacingS),
                          Container(
                            constraints:
                                const BoxConstraints(minWidth: 22),
                            height: 22,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6),
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(11),
                              boxShadow: const [
                                BoxShadow(
                                    color: Color(0x406C63FF),
                                    blurRadius: 6,
                                    offset: Offset(0, 2)),
                              ],
                            ),
                            child: Center(
                              child: Text('${chat.unreadCount}',
                                  style: const TextStyle(
                                      fontSize: AppTheme.fontSizeXS,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    const items = [
      _NavItem(Icons.chat_bubble_rounded, 'Chats'),
      _NavItem(Icons.groups_rounded, 'Teams'),
      _NavItem(Icons.calendar_month_rounded, 'Calendar'),
      _NavItem(Icons.person_rounded, 'Profile'),
    ];
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
            top: BorderSide(color: AppTheme.borderColor, width: 0.8)),
        boxShadow: [
          BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 16,
              offset: Offset(0, -4))
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final selected = _selectedIndex == i;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedIndex = i);
                  _handleNav(i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingM,
                      vertical: AppTheme.spacingS),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppTheme.primaryColor.withAlpha(18)
                        : Colors.transparent,
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(items[i].icon,
                          color: selected
                              ? AppTheme.primaryColor
                              : AppTheme.textMuted,
                          size: 24),
                      const SizedBox(height: 4),
                      Text(items[i].label,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                              color: selected
                                  ? AppTheme.primaryColor
                                  : AppTheme.textMuted)),
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

  Widget _buildFAB() {
    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color: Color(0x506C63FF),
              blurRadius: 18,
              offset: Offset(0, 7))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {},
          child: const Icon(Icons.edit_rounded,
              color: Colors.white, size: 24),
        ),
      ),
    );
  }

  void _openChat(ChatItem chat) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${AppStrings.openingChat}${chat.name}'),
      duration: const Duration(milliseconds: 800),
    ));
  }

  void _handleNav(int index) {
    final msgs = [
      null,
      AppStrings.teamsComingSoon,
      AppStrings.calendarComingSoon,
      AppStrings.profileComingSoon,
    ];
    if (msgs[index] != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msgs[index]!)));
    }
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

class ChatItem {
  final String name, lastMessage, timestamp, avatar;
  final int unreadCount;
  final bool isGroup, isOnline;
  final Color avatarColor;

  const ChatItem({
    required this.name, required this.lastMessage,
    required this.timestamp, required this.unreadCount,
    required this.isGroup, required this.avatar,
    required this.avatarColor, this.isOnline = false,
  });
}
