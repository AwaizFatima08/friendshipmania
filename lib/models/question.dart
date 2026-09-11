/// One possible answer to a [Question].
///
/// [score] is how much this answer says about the depth of the friendship,
/// from 0 (yikes) to 3 (soulmates). It's what turns funny answers into a
/// number we can turn back into a funny scorecard at the end.
class AnswerOption {
  final String text;
  final int score;

  const AnswerOption({required this.text, required this.score});
}

/// A single question in the bank.
///
/// [tag] groups questions by humor style (e.g. "roast", "loyalty") so a
/// quiz run can mix tags together instead of always asking the same run
/// of questions in the same order.
class Question {
  final String id;
  final String tag;
  final String prompt;
  final List<AnswerOption> options;

  const Question({
    required this.id,
    required this.tag,
    required this.prompt,
    required this.options,
  });

  /// The highest score any option on this question can give, used to
  /// normalize scores into a percentage regardless of run size.
  int get maxScore => options.map((o) => o.score).reduce((a, b) => a > b ? a : b);
}
