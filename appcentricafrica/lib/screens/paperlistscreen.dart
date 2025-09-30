// lib/screens/paper_list_screen.dart
import 'package:appcentricafrica/screens/login.dart';
import 'package:appcentricafrica/screens/questiondetails.dart';
import 'package:appcentricafrica/services/apiservices.dart';
import 'package:flutter/material.dart';
import '../models/paper.dart';
import '../models/subject.dart';


class PaperListScreen extends StatefulWidget {
  const PaperListScreen({Key? key}) : super(key: key);

  @override
  State<PaperListScreen> createState() => _PaperListScreenState();
}

class _PaperListScreenState extends State<PaperListScreen> {
  final _apiService = ApiService();
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  
  List<Paper> _papers = [];
  List<Subject> _subjects = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  int _lastPage = 1;
  String? _selectedSubject;
  int? _selectedYear;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
    _loadPapers();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMorePapers();
    }
  }

  Future<void> _loadSubjects() async {
    try {
      final subjects = await _apiService.getSubjects();
      if (mounted) {
        setState(() => _subjects = subjects);
      }
    } catch (e) {
      // Handle error silently or show snackbar
    }
  }

  Future<void> _loadPapers({bool refresh = false}) async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      if (refresh) {
        _papers.clear();
        _currentPage = 1;
      }
    });

    try {
      final result = await _apiService.getPapers(
        subject: _selectedSubject,
        year: _selectedYear,
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
        page: _currentPage,
      );

      if (mounted) {
        setState(() {
          _papers = result['papers'] as List<Paper>;
          _currentPage = result['currentPage'];
          _lastPage = result['lastPage'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Failed to load papers');
      }
    }
  }

  Future<void> _loadMorePapers() async {
    if (_isLoadingMore || _currentPage >= _lastPage) return;

    setState(() => _isLoadingMore = true);

    try {
      final result = await _apiService.getPapers(
        subject: _selectedSubject,
        year: _selectedYear,
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
        page: _currentPage + 1,
      );

      if (mounted) {
        setState(() {
          _papers.addAll(result['papers'] as List<Paper>);
          _currentPage = result['currentPage'];
          _lastPage = result['lastPage'];
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _apiService.logout();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Filter Papers',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedSubject,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Subjects')),
                  ..._subjects.map((s) => DropdownMenuItem(
                    value: s.code,
                    child: Text(s.name),
                  )),
                ],
                onChanged: (value) {
                  setModalState(() => _selectedSubject = value);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedYear,
                decoration: const InputDecoration(
                  labelText: 'Year',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Years')),
                  for (int year = DateTime.now().year; year >= 2015; year--)
                    DropdownMenuItem(value: year, child: Text(year.toString())),
                ],
                onChanged: (value) {
                  setModalState(() => _selectedYear = value);
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedSubject = _selectedSubject;
                    _selectedYear = _selectedYear;
                  });
                  Navigator.pop(ctx);
                  _loadPapers(refresh: true);
                },
                child: const Text('Apply Filters'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Papers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilters,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search papers...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadPapers(refresh: true);
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (_) => _loadPapers(refresh: true),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _papers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No papers found',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => _loadPapers(refresh: true),
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: _papers.length + (_isLoadingMore ? 1 : 0),
                          itemBuilder: (ctx, index) {
                            if (index == _papers.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final paper = _papers[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text(paper.year.toString().substring(2)),
                                ),
                                title: Text(paper.title),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (paper.subject != null)
                                      Text(paper.subject!.name),
                                    if (paper.description != null)
                                      Text(
                                        paper.description!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => QuestionDetailScreen(
                                        paperId: paper.id,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}