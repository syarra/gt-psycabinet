Class {
	#name : 'CbSessionCancelledEvent',
	#superclass : 'CbEvent',
	#instVars : [
		'patientCode',
		'date'
	],
	#category : 'Gt-PsyCabinet',
	#package : 'Gt-PsyCabinet'
}

{ #category : 'applying' }
CbSessionCancelledEvent >> applyOn: aCabinetManager [
	| patient session |
	patient := aCabinetManager patientWithCode: self patientCode.
	session := patient sessions
		detect: [ :s | s date = self date and: [ s isCancelled not ] ]
		ifNone: [ nil ].
	session ifNotNil: [ session cancel ]
]

{ #category : 'accessing' }
CbSessionCancelledEvent >> date [
	^ date
]

{ #category : 'accessing' }
CbSessionCancelledEvent >> date: aDate [
	date := aDate
]

{ #category : 'accessing' }
CbSessionCancelledEvent >> patientCode [
	^ patientCode
]

{ #category : 'accessing' }
CbSessionCancelledEvent >> patientCode: anInteger [
	patientCode := anInteger
]

{ #category : 'printing' }
CbSessionCancelledEvent >> printOn: aStream [
	aStream
		nextPutAll: 'SessionCancelled: #';
		print: self patientCode;
		nextPutAll: ' ';
		nextPutAll: self date printString
]
