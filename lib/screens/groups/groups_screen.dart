import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/group_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../models/group.dart';
import '../../l10n/app_localizations.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({Key? key}) : super(key: key);

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId != null) {
      await context.read<GroupProvider>().fetchMyGroups(userId);
      await context.read<GroupProvider>().fetchAllGroups();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.t('groups')),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryBlue,
          labelColor: AppTheme.primaryBlue,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(text: t.t('my_groups')),
            Tab(text: 'Découvrir'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyGroupsTab(),
          _buildDiscoverTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showCreateGroupModal();
        },
        icon: const Icon(Icons.add),
        label: Text(t.t('create_group')),
      ),
    );
  }

  Widget _buildMyGroupsTab() {
    return Consumer<GroupProvider>(
      builder: (context, groupProvider, _) {
        final t = AppLocalizations.of(context);
        if (groupProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (groupProvider.myGroups.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.group_outlined,
                  size: 80,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  t.t('no_groups'),
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rejoignez ou créez votre premier groupe',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: groupProvider.myGroups.length,
          itemBuilder: (context, index) {
            return _buildGroupCard(groupProvider.myGroups[index], isMember: true);
          },
        );
      },
    );
  }

  Widget _buildDiscoverTab() {
    return Consumer<GroupProvider>(
      builder: (context, groupProvider, _) {
        final t = AppLocalizations.of(context);
        if (groupProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final nonMemberGroups = groupProvider.allGroups.where((group) {
          return !groupProvider.myGroups.any((myGroup) => myGroup.id == group.id);
        }).toList();

        if (nonMemberGroups.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 80,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  t.t('no_groups'),
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: nonMemberGroups.length,
          itemBuilder: (context, index) {
            return _buildGroupCard(nonMemberGroups[index], isMember: false);
          },
        );
      },
    );
  }

  Widget _buildGroupCard(Group group, {required bool isMember}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.groupChat,
            arguments: group,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: group.imageUrl != null
                        ? null
                        : Center(
                            child: Text(
                              group.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                group.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (group.type == GroupType.private_group)
                              const Icon(
                                Icons.lock,
                                size: 16,
                                color: AppTheme.greyText,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.people,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${group.memberCount} ${t.t('members')}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                group.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (!isMember) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final t = AppLocalizations.of(context);
                      final userId = context.read<AuthProvider>().currentUser?.id;
                      if (userId != null) {
                        await context.read<GroupProvider>().joinGroup(group.id, userId);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(t.t('group_joined')),
                              backgroundColor: AppTheme.successGreen,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: Text(t.t('join_group')),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateGroupModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const CreateGroupModal(),
    );
  }
}

class CreateGroupModal extends StatefulWidget {
  const CreateGroupModal({Key? key}) : super(key: key);

  @override
  State<CreateGroupModal> createState() => _CreateGroupModalState();
}

class _CreateGroupModalState extends State<CreateGroupModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  GroupType _groupType = GroupType.public_group;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateGroup() async {
    final t = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;

    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) return;

    try {
      await context.read<GroupProvider>().createGroup(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            creatorId: userId,
            type: _groupType,
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.t('group_created')),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${t.t('error')}: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    t.t('create_group'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: t.t('group_name'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return t.t('group_name_required');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: t.t('group_description'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return t.t('group_description_required');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Group Type
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<GroupType>(
                      value: GroupType.public_group,
                      groupValue: _groupType,
                      onChanged: (value) {
                        setState(() => _groupType = value!);
                      },
                      title: Text(t.t('public_group')),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<GroupType>(
                      value: GroupType.private_group,
                      groupValue: _groupType,
                      onChanged: (value) {
                        setState(() => _groupType = value!);
                      },
                      title: Text(t.t('private_group')),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Consumer<GroupProvider>(
                builder: (context, groupProvider, _) {
                  return ElevatedButton(
                    onPressed: groupProvider.isLoading ? null : _handleCreateGroup,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: groupProvider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(t.t('create_group')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
