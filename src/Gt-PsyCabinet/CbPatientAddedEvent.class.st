Class {
	#name : 'CbPatientAddedEvent',
	#superclass : 'CbEvent',
	#instVars : [
		'firstName',
		'lastName',
		'address',
		'city',
		'postalCode',
		'country',
		'matricule',
		'patientCode'
	],
	#category : 'Gt-PsyCabinet',
	#package : 'Gt-PsyCabinet'
}

{ #category : 'accessing' }
CbPatientAddedEvent >> address [
	^ address
]

{ #category : 'accessing' }
CbPatientAddedEvent >> address: aString [
	address := aString
]

{ #category : 'applying' }
CbPatientAddedEvent >> applyOn: aCabinetManager [
	| patient |
	patient := CbPatient new
		code: self patientCode;
		firstName: self firstName;
		lastName: self lastName;
		address: self address;
		city: self city;
		postalCode: self postalCode;
		country: self country;
		matricule: self matricule;
		cabinet: aCabinetManager.
	aCabinetManager patients add: patient.
	^ patient
]

{ #category : 'accessing' }
CbPatientAddedEvent >> city [
	^ city
]

{ #category : 'accessing' }
CbPatientAddedEvent >> city: aString [
	city := aString
]

{ #category : 'accessing' }
CbPatientAddedEvent >> country [
	^ country
]

{ #category : 'accessing' }
CbPatientAddedEvent >> country: aString [
	country := aString
]

{ #category : 'accessing' }
CbPatientAddedEvent >> firstName [
	^ firstName
]

{ #category : 'accessing' }
CbPatientAddedEvent >> firstName: aString [
	firstName := aString
]

{ #category : 'accessing' }
CbPatientAddedEvent >> lastName [
	^ lastName
]

{ #category : 'accessing' }
CbPatientAddedEvent >> lastName: aString [
	lastName := aString
]

{ #category : 'accessing' }
CbPatientAddedEvent >> matricule [
	^ matricule
]

{ #category : 'accessing' }
CbPatientAddedEvent >> matricule: aString [
	matricule := aString
]

{ #category : 'accessing' }
CbPatientAddedEvent >> patientCode [
	^ patientCode
]

{ #category : 'accessing' }
CbPatientAddedEvent >> patientCode: anInteger [
	patientCode := anInteger
]

{ #category : 'accessing' }
CbPatientAddedEvent >> postalCode [
	^ postalCode
]

{ #category : 'accessing' }
CbPatientAddedEvent >> postalCode: aString [
	postalCode := aString
]

{ #category : 'printing' }
CbPatientAddedEvent >> printOn: aStream [
	aStream
		nextPutAll: 'PatientAdded: ';
		nextPutAll: (self lastName ifNil: [ '' ]);
		nextPutAll: ' ';
		nextPutAll: (self firstName ifNil: [ '' ])
]
