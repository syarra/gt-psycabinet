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
			package: 'Gt-PsyCabinet-Examples' with: [ spec requires: #('Gt-PsyCabinet') ].
		spec postLoadDoIt: #postLoad ]
]

{ #category : 'loading' }
BaselineOfGtPsyCabinet >> postLoad [
	| repo lepiterDir db |
	repo := IceRepository registry 
		detect: [ :r | r name = 'gt-psycabinet' ]
		ifNone: [ ^ self ].
	lepiterDir := repo location / 'lepiter'.
	lepiterDir exists ifFalse: [ ^ self ].
	(LeDatabasesRegistry defaultLogicalDatabase databases
		anySatisfy: [ :d | d localStoreRootDirectory = lepiterDir ])
		ifTrue: [ ^ self ].
	db := LeLocalStoreLoad current loadAndMonitorFrom: lepiterDir.
	LeDatabasesRegistry defaultLogicalDatabase addDB: db
]
