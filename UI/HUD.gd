extends Control


func display(text):
	$Description.text = text

func displayRing(progress):
	$ProgressRing.value = progress * 100
