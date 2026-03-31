Class {
	#name : 'CbPatientUpdatedEvent',
	#superclass : 'CbEvent',
	#instVars : [
		'patientCode',
		'fieldName',
		'newValue'
	],
	#category : 'Gt-PsyCabinet',
	#package : 'Gt-PsyCabinet'
}

{ #category : 'applying' }
CbPatientUpdatedEvent >> applyOn: aCabinetManager [
	| patient |
	patient := aCabinetManager patientWithCode: self patientCode.
	patient perform: (self fieldName , ':') asSymbol with: self newValue
]

{ #category : 'accessing' }
CbPatientUpdatedEvent >> fieldName [
	^ fieldName
]

{ #category : 'accessing' }
CbPatientUpdatedEvent >> fieldName: aString [
	fieldName := aString
]

{ #category : 'accessing' }
CbPatientUpdatedEvent >> newValue [
	^ newValue
]

{ #category : 'accessing' }
CbPatientUpdatedEvent >> newValue: anObject [
	newValue := anObject
]

{ #category : 'accessing' }
CbPatientUpdatedEvent >> patientCode [
	^ patientCode
]

{ #category : 'accessing' }
CbPatientUpdatedEvent >> patientCode: anInteger [
	patientCode := anInteger
]

{ #category : 'printing' }
CbPatientUpdatedEvent >> printOn: aStream [
	aStream
		nextPutAll: 'PatientUpdated: #';
		print: self patientCode;
		nextPutAll: ' ';
		nextPutAll: self fieldName;
		nextPutAll: ' -> ';
		print: self newValue
]
