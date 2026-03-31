Class {
	#name : 'CbSessionRecordedEvent',
	#superclass : 'CbEvent',
	#instVars : [
		'patientCode',
		'date',
		'codeActe',
		'amount'
	],
	#category : 'Gt-PsyCabinet',
	#package : 'Gt-PsyCabinet'
}

{ #category : 'accessing' }
CbSessionRecordedEvent >> amount [
	^ amount
]

{ #category : 'accessing' }
CbSessionRecordedEvent >> amount: aNumber [
	amount := aNumber
]

{ #category : 'applying' }
CbSessionRecordedEvent >> applyOn: aCabinetManager [
	| patient |
	patient := aCabinetManager patientWithCode: self patientCode.
	patient addSessionOn: self date code: self codeActe amount: self amount
]

{ #category : 'accessing' }
CbSessionRecordedEvent >> codeActe [
	^ codeActe
]

{ #category : 'accessing' }
CbSessionRecordedEvent >> codeActe: aString [
	codeActe := aString
]

{ #category : 'accessing' }
CbSessionRecordedEvent >> date [
	^ date
]

{ #category : 'accessing' }
CbSessionRecordedEvent >> date: aDate [
	date := aDate
]

{ #category : 'accessing' }
CbSessionRecordedEvent >> patientCode [
	^ patientCode
]

{ #category : 'accessing' }
CbSessionRecordedEvent >> patientCode: anInteger [
	patientCode := anInteger
]

{ #category : 'printing' }
CbSessionRecordedEvent >> printOn: aStream [
	aStream
		nextPutAll: 'SessionRecorded: #';
		print: self patientCode;
		nextPutAll: ' ';
		nextPutAll: self date printString;
		nextPutAll: ' ';
		nextPutAll: self codeActe
]
