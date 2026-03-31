Class {
	#name : 'CbEventExamples',
	#superclass : 'Object',
	#category : 'Gt-PsyCabinet-Examples',
	#package : 'Gt-PsyCabinet-Examples'
}

{ #category : 'examples' }
CbEventExamples >> examplePatientAddedEvent [
	<gtExample>
	| event cabinet |
	event := CbPatientAddedEvent new
		patientCode: 1;
		firstName: 'Anaïs';
		lastName: 'Chavignaud';
		matricule: '1988062896018';
		address: '103 avenue de la Faïencerie';
		city: 'Luxembourg';
		postalCode: '1511';
		country: 'L'.
	cabinet := CbCabinetManager new.
	event applyOn: cabinet.
	self assert: cabinet patients size equals: 1.
	self assert: (cabinet patientWithCode: 1) firstName equals: 'Anaïs'.
	^ event
]

{ #category : 'examples' }
CbEventExamples >> exampleReplayScenario [
	<gtExample>
	| events cabinet |
	events := OrderedCollection new.
	events add: (CbPatientAddedEvent new patientCode: 1; firstName: 'Anaïs'; lastName: 'Chavignaud'; matricule: '1988062896018'; country: 'L').
	events add: (CbPatientUpdatedEvent new patientCode: 1; fieldName: 'address'; newValue: '103 avenue de la Faïencerie').
	events add: (CbSessionRecordedEvent new patientCode: 1; date: (Date year: 2026 month: 1 day: 10); codeActe: 'SP01'; amount: 158.95).
	events add: (CbSessionRecordedEvent new patientCode: 1; date: (Date year: 2026 month: 1 day: 17); codeActe: 'SP01'; amount: 158.95).
	events add: (CbSessionCancelledEvent new patientCode: 1; date: (Date year: 2026 month: 1 day: 17)).

	cabinet := CbCabinetManager new.
	events do: [ :e | e applyOn: cabinet ].

	self assert: cabinet patients size equals: 1.
	self assert: (cabinet patientWithCode: 1) address equals: '103 avenue de la Faïencerie'.
	self assert: (cabinet patientWithCode: 1) sessions size equals: 2.
	self assert: (cabinet patientWithCode: 1) sp01Count equals: 1. "one cancelled"
	^ events
]
