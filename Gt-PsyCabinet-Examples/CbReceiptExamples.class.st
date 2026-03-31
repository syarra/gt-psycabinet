Class {
	#name : 'CbReceiptExamples',
	#superclass : 'Object',
	#category : 'Gt-PsyCabinet-Examples',
	#package : 'Gt-PsyCabinet-Examples'
}

{ #category : 'examples' }
CbReceiptExamples >> exampleAllViewsBuild [
	<gtExample>
	"Verify all Receipt views render without errors using GtPhlowViewTester"
	| receipt |
	receipt := self exampleReceipt.
	self assertObjectPhlowViewsFor: receipt.
	^ receipt
]

{ #category : 'examples' }
CbReceiptExamples >> exampleReceipt [
	<gtExample>
	| patient receipt |
	patient := CbPatientExamples new examplePatientWithSessions.
	receipt := CbReceipt
		forPatient: patient
		sessions: patient sessions
		date: (Date year: 2026 month: 3 day: 24).
	self assert: receipt patient equals: patient.
	self assert: receipt sessions size equals: 4.
	self assert: receipt receiptNumber equals: 'OC20260324'.
	self assert: receipt total equals: 158.95 * 4.
	^ receipt
]
