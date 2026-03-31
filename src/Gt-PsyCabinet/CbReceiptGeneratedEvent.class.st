Class {
	#name : 'CbReceiptGeneratedEvent',
	#superclass : 'CbEvent',
	#instVars : [
		'patientCode',
		'receiptDate',
		'receiptNumber',
		'sessionDates'
	],
	#category : 'Gt-PsyCabinet',
	#package : 'Gt-PsyCabinet'
}

{ #category : 'applying' }
CbReceiptGeneratedEvent >> applyOn: aCabinetManager [
	| patient matchingSessions receipt |
	patient := aCabinetManager patientWithCode: self patientCode.
	matchingSessions := patient sessions select: [ :s |
		self sessionDates includes: s date ].
	receipt := CbReceipt
		forPatient: patient
		sessions: matchingSessions
		date: self receiptDate.
	patient receipts add: receipt.
	^ receipt
]

{ #category : 'accessing' }
CbReceiptGeneratedEvent >> patientCode [
	^ patientCode
]

{ #category : 'accessing' }
CbReceiptGeneratedEvent >> patientCode: anInteger [
	patientCode := anInteger
]

{ #category : 'printing' }
CbReceiptGeneratedEvent >> printOn: aStream [
	aStream
		nextPutAll: 'ReceiptGenerated: #';
		print: self patientCode;
		nextPutAll: ' ';
		nextPutAll: self receiptNumber;
		nextPutAll: ' (';
		print: self sessionDates size;
		nextPutAll: ' sessions)'
]

{ #category : 'accessing' }
CbReceiptGeneratedEvent >> receiptDate [
	^ receiptDate
]

{ #category : 'accessing' }
CbReceiptGeneratedEvent >> receiptDate: aDate [
	receiptDate := aDate
]

{ #category : 'accessing' }
CbReceiptGeneratedEvent >> receiptNumber [
	^ receiptNumber
]

{ #category : 'accessing' }
CbReceiptGeneratedEvent >> receiptNumber: aString [
	receiptNumber := aString
]

{ #category : 'accessing' }
CbReceiptGeneratedEvent >> sessionDates [
	^ sessionDates
]

{ #category : 'accessing' }
CbReceiptGeneratedEvent >> sessionDates: aCollection [
	sessionDates := aCollection
]
