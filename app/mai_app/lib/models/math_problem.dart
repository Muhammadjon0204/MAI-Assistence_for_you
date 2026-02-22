class MathProblem {
  final String problem;

  MathProblem({required this.problem});

  Map<String, dynamic> toJson() => {
        'problem': problem,
      };
}

class MathSolution {
  final String problem;
  final String solution;
  final String solver;
  final DateTime timestamp;
  final bool success;

  MathSolution({
    required this.problem,
    required this.solution,
    required this.solver,
    required this.timestamp,
    required this.success, required List<String> steps,
  });

  factory MathSolution.fromJson(Map<String, dynamic> json) {
    return MathSolution(
      problem: json['problem'] ?? '',
      solution: json['solution'] ?? '',
      solver: json['solver'] ?? 'Unknown',
      timestamp: DateTime.parse(json['timestamp']),
      success: json['success'] ?? false, steps: [],
    );
  }
}
