Class {
	#name : 'BaselineOfGtPsyCabinet',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfGtPsyCabinet',
	#package : 'BaselineOfGtPsyCabinet'
}

{ #category : 'baseline' }
BaselineOfGtPsyCabinet >> baseline: spec [
	<baseline>
	
	^ spec for: #common do: [
		spec
			package: 'Gt-PsyCabinet';
			package: 'Gt-PsyCabinet-Examples' with: [ spec requires: #('Gt-PsyCabinet') ]
	]
]
