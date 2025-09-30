
import 'package:appcentricafrica/services/apiservices.dart';
import 'package:appcentricafrica/services/databasehelper.dart';
import 'package:flutter/material.dart';
import '../models/paper.dart';
import '../models/question.dart';



class QuestionDetailScreen extends StatefulWidget {
  final int paperId;

  const QuestionDetailScreen({
    Key? key,
    required this.paperId,
  }) : super(key: key);

  @override
  State<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  final _apiService = ApiService();
  final _dbHelper = DatabaseHelper.instance;
  
  Paper? _paper;
  bool _isLoading = true;
  bool _loadedFromCache = false;
  Map<int, int?> _selectedAnswers = {};
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _loadPaperDetails();
  }

  Future<void> _loadPaperDetails() async {
    setState(() => _isLoading = true);

    // Try loading from cache first
    try {
      final cachedPaper = await _dbHelper.getCachedPaper(widget.paperId);
      if (cachedPaper != null && mounted) {
        setState(() {
          _paper = cachedPaper;
          _isLoading = false;
          _loadedFromCache = true;
        });
      }
    } catch (e) {
      // Continue to load from API
    }

    // Load from API
    try {
      final paper = await _apiService.getPaperDetails(widget.paperId);
      
      // Cache the paper
      await _dbHelper.cachePaper(paper);
      await _dbHelper.clearOldCache();

      if (mounted) {
        setState(() {
          _paper = paper;
          _isLoading = false;
          _loadedFromCache = false;
        });
      }
    } catch (e) {
      if (mounted && _paper == null) {
        setState(() => _isLoading = false);
        _showErrorDialog('Failed to load paper details');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _selectAnswer(int questionId, int answerId) {
    if (_showResults) return;
    
    setState(() {
      _selectedAnswers[questionId] = answerId;
    });
  }

  void _submitAnswers() {
    if (_selectedAnswers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer at least one question')),
      );
      return;
    }

    setState(() => _showResults = true);
  }

  void _resetQuiz() {
    setState(() {
      _selectedAnswers.clear();
      _showResults = false;
    });
  }

  int _calculateScore() {
    if (_paper?.questions == null) return 0;
    
    int correct = 0;
    for (var question in _paper!.questions!) {
      final selectedAnswerId = _selectedAnswers[question.id];
      if (selectedAnswerId != null) {
        final correctAnswer = question.answers?.firstWhere(
          (a) => a.isCorrect,
          orElse: () => question.answers!.first,
        );
        if (correctAnswer?.id == selectedAnswerId) {
          correct++;
        }
      }
    }
    return correct;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_paper?.title ?? 'Loading...'),
        actions: [
          if (_loadedFromCache)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Chip(
                label: Text('Cached', style: TextStyle(fontSize: 12)),
                avatar: Icon(Icons.offline_pin, size: 16),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _paper == null
              ? const Center(child: Text('Failed to load paper'))
              : Column(
                  children: [
                    if (_paper!.subject != null || _paper!.description != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        color: Colors.blue.shade50,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_paper!.subject != null)
                              Text(
                                _paper!.subject!.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            if (_paper!.description != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                _paper!.description!,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              'Year: ${_paper!.year}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_showResults)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        color: Colors.green.shade50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Score: ${_calculateScore()}/${_paper!.questions?.length ?? 0}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _resetQuiz,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Try Again'),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: _paper!.questions == null || _paper!.questions!.isEmpty
                          ? const Center(child: Text('No questions available'))
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _paper!.questions!.length,
                              itemBuilder: (ctx, index) {
                                final question = _paper!.questions![index];
                                return _buildQuestionCard(question);
                              },
                            ),
                    ),
                    if (!_showResults && _paper!.questions != null && _paper!.questions!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: ElevatedButton(
                          onPressed: _submitAnswers,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text(
                            'Submit Answers',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }

  Widget _buildQuestionCard(Question question) {
    final selectedAnswerId = _selectedAnswers[question.id];
    final correctAnswer = question.answers?.firstWhere(
      (a) => a.isCorrect,
      orElse: () => question.answers!.first,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Q${question.order}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question.questionText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${question.marks} mark${question.marks > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (question.answers != null && question.answers!.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...question.answers!.map((answer) {
                final isSelected = selectedAnswerId == answer.id;
                final isCorrect = answer.isCorrect;
                final showCorrect = _showResults && isCorrect;
                final showIncorrect = _showResults && isSelected && !isCorrect;

                Color? tileColor;
                if (showCorrect) {
                  tileColor = Colors.green.shade50;
                } else if (showIncorrect) {
                  tileColor = Colors.red.shade50;
                } else if (isSelected) {
                  tileColor = Colors.blue.shade50;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => _selectAnswer(question.id, answer.id),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: tileColor,
                        border: Border.all(
                          color: showCorrect
                              ? Colors.green
                              : showIncorrect
                                  ? Colors.red
                                  : isSelected
                                      ? Colors.blue
                                      : Colors.grey.shade300,
                          width: isSelected || showCorrect || showIncorrect ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: showCorrect
                                ? Colors.green
                                : showIncorrect
                                    ? Colors.red
                                    : isSelected
                                        ? Colors.blue
                                        : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              answer.answerText,
                              style: TextStyle(
                                color: showCorrect || showIncorrect
                                    ? Colors.black87
                                    : null,
                              ),
                            ),
                          ),
                          if (showCorrect)
                            const Icon(Icons.check_circle, color: Colors.green),
                          if (showIncorrect)
                            const Icon(Icons.cancel, color: Colors.red),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }
}