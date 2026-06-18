extends RelicData
class_name Juice

func get_score_report(context: RelicContext) -> RelicReportItem:
	var report = RelicReportItem.new()
	report.relic = context.relic
	print_debug('word score is ' + str(context.word_score))
	report.prev_score = context.word_score
	report.new_score = report.prev_score + 50
	report.text = '+50'
	return report
