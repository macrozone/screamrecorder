
Router.map ->
	@route 'home',
		path: "/"
		
recorder = null

Session.set "recording", false
Session.set "waitingForAudioCheck", true
Session.set "hasUserMediaSupport", false
audioContext = null;


initAudio = ->
	Session.set "waitingForAudioCheck", true
	Session.set "hasUserMediaSupport", false
	Session.set "recording", false
	#webkit shim
	window.AudioContext = window.AudioContext || window.webkitAudioContext;
	navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia;
	window.URL = window.URL || window.webkitURL;
	audioContext = new AudioContext;
	
	onError = (error) ->
		Session.set "waitingForAudioCheck", false
		Session.set "hasUserMediaSupport", false
	onAudioAvailable = (stream) ->
		input = audioContext.createMediaStreamSource stream
		recorder = new Recorder input
		Session.set "waitingForAudioCheck", false
		Session.set "hasUserMediaSupport", true
	
	if navigator?.getUserMedia?
		navigator.getUserMedia {audio: true}, onAudioAvailable, onError
	else 
		onError()

Template.home.rendered = ->
	initAudio()

Template.home.waitingForAudioCheck = ->
	Session.get "waitingForAudioCheck"
Template.home.hasUserMediaSupport = ->
	Session.get "hasUserMediaSupport"

saveScreamBlob = (blob, done) ->
	BinaryFileReader.read blob, (error, fileInfo) ->
		Screams.insert
			itime: new Date().getTime()
			audio: fileInfo
		done()
stopRecording = ->
	recorder.stop()
	recorder.exportWAV (blob) ->
		saveScreamBlob blob, ->
			recorder?.clear()

Template.home.screams = ->
	Screams.find {}, sort: itime: -1

Template.aScream.url = ->

	blob = new Blob [@audio.file], type: @audio.type
	URL.createObjectURL blob

Template.home.events
	"change .audioFileInput": (event) ->
		for file in event.target.files
			saveScreamBlob file, ->
				console.log "done"
	"click .btn-record": (event)->
		recording = Session.get "recording"
		Session.set "recording", !recording
		if recording
			stopRecording()
		else
			recorder.record()

Template.home.buttonLable = ->
	if Session.get "recording" then "Stop" else "Record"

Template.home.glyphicon = ->
	if Session.get "recording" then "glyphicon-stop" else "glyphicon-record"
