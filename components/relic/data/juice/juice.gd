extends RelicData
class_name Juice

func get_score_report(context: RelicContext) -> RelicReportItem:
	var report = RelicReportItem.new()
	report.relic = context.relic
	report.prev_score = context.word_score
	report.new_score = report.prev_score + 10
	report.text = '+10'
	return report
