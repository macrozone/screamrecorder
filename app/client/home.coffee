
Router.map ->
	@route 'home',
		path: "/"
		
recorder = null

Session.set "recording", false
audioContext = null;

initAudio = ->
	Session.set "recording", false
	#webkit shim
	window.AudioContext = window.AudioContext || window.webkitAudioContext;
	navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia;
	window.URL = window.URL || window.webkitURL;
	audioContext = new AudioContext;
	
	onError = (error) ->
		console.error error
	onAudioAvailable = (stream) ->
		input = audioContext.createMediaStreamSource stream
		recorder = new Recorder input
		Session.set "audioAvailable", true
		
	navigator.getUserMedia {audio: true}, onAudioAvailable, onError


Template.home.rendered = ->
	initAudio()

Template.home.audioAvailable = ->
	Session.get "audioAvailable"

stopRecording = ->
	recorder.stop()
	recorder.exportWAV (blob) ->
		BinaryFileReader.read blob, (error, fileInfo) ->
			Screams.insert
				itime: new Date().getTime()
				audio: fileInfo
			recorder.clear()

Template.home.screams = ->
	Screams.find {}, sort: itime: -1

Template.aScream.url = ->

	blob = new Blob [@audio.file], type: @audio.type
	URL.createObjectURL blob

Template.home.events
	"click .btn-record": (event)->
		recording = Session.get "recording"
		Session.set "recording", !recording
		if recording
			stopRecording()
		else
			recorder.record()

Template.home.buttonLable = ->
	if Session.get "recording"
		"Stop"
	else
		"Record"
