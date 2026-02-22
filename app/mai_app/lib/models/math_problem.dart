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
  final DateTime timestamp;
  final String steps;

  MathSolution({
    required this.problem,
    required this.solution,
    required this.timestamp,
    required this.steps,
  });

  factory MathSolution.fromJson(Map<String, dynamic> json) {
    return MathSolution(
      problem: json['problem'] ?? '',
      solution: json['solution'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      steps: json['steps'] ?? [],
    );
  }
}
