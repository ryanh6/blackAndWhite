extends Control
class_name BasicGameScreen

signal requestPause
signal requestLeave
signal requestRoundSummary(entries: Array, roundNumber: int)
signal requestMatchResults(entries: Array, title: String)

func bind(controller: GameController) -> void:
	pass
	
func roundSummaryClosed() -> void:
	pass
