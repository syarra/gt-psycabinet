Class {
	#name : 'CbPatientExamples',
	#superclass : 'Object',
	#category : 'Gt-PsyCabinet-Examples',
	#package : 'Gt-PsyCabinet-Examples'
}

{ #category : 'examples' }
CbPatientExamples >> exampleAllViewsBuild [
	<gtExample>
	"Verify all Patient views render without errors using GtPhlowViewTester"
	| patient |
	patient := self examplePatientWithSessions.
	self assertObjectPhlowViewsFor: patient.
	^ patient
]

{ #category : 'examples' }
CbPatientExamples >> exampleBasicPatient [
	<gtExample>
	| patient |
	patient := CbPatient new
		firstName: 'Anaïs';
		lastName: 'Chavignaud';
		address: '103 avenue de la Faïencerie';
		city: 'Luxembourg';
		postalCode: '1511';
		country: 'L';
		matricule: '1988062896018';
		code: 1.
	self assert: patient firstName equals: 'Anaïs'.
	self assert: patient lastName equals: 'Chavignaud'.
	self assert: patient matricule equals: '1988062896018'.
	self assert: patient sessions isEmpty.
	^ patient
]

{ #category : 'examples' }
CbPatientExamples >> examplePatientEditView [
	<gtExample>
	| patient view |
	patient := self exampleBasicPatient.
	view := patient gtEditFormFor: GtPhlowEmptyView new.
	self assert: view isNotNil.
	^ view
]

{ #category : 'examples' }
CbPatientExamples >> examplePatientQuotas [
	<gtExample>
	| patient |
	patient := self examplePatientWithSessions.
	"3 SP01 used out of 3, 1 SP02 used out of 24"
	self assert: patient sp01Remaining equals: 0.
	self assert: patient sp02Remaining equals: 23.
	self assert: patient sp03Remaining equals: 120.
	self assert: patient sp01Exhausted.
	self assert: patient sp02Exhausted not.
	^ patient
]

{ #category : 'examples' }
CbPatientExamples >> examplePatientWithReceipts [
	<gtExample>
	| patient receipt1 uncovered receipt2 |
	patient := self examplePatientWithSessions.
	"Patient has 4 sessions: 3xSP01 + 1xSP02"
	
	"First receipt covers first 3 sessions (SP01s)"
	receipt1 := patient generateReceiptForUncoveredSessions: (Date year: 2026 month: 2 day: 1).
	self assert: receipt1 sessions size equals: 4.
	self assert: patient receipts size equals: 1.
	
	"Add more sessions"
	patient addSessionOn: (Date year: 2026 month: 2 day: 14) code: 'SP02' amount: 158.95.
	patient addSessionOn: (Date year: 2026 month: 2 day: 21) code: 'SP02' amount: 158.95.
	
	"Uncovered should be only the 2 new ones"
	uncovered := patient uncoveredSessions.
	self assert: uncovered size equals: 2.
	
	"Second receipt covers only new sessions"
	receipt2 := patient generateReceiptForUncoveredSessions: (Date year: 2026 month: 2 day: 28).
	self assert: receipt2 sessions size equals: 2.
	self assert: patient receipts size equals: 2.
	
	"No more uncovered"
	self assert: patient uncoveredSessions isEmpty.
	^ patient
]

{ #category : 'examples' }
CbPatientExamples >> examplePatientWithSessions [
	<gtExample>
	| patient |
	patient := self exampleBasicPatient.
	patient addSessionOn: (Date year: 2026 month: 1 day: 10) code: 'SP01' amount: 158.95.
	patient addSessionOn: (Date year: 2026 month: 1 day: 17) code: 'SP01' amount: 158.95.
	patient addSessionOn: (Date year: 2026 month: 1 day: 24) code: 'SP01' amount: 158.95.
	patient addSessionOn: (Date year: 2026 month: 1 day: 31) code: 'SP02' amount: 158.95.
	self assert: patient sessions size equals: 4.
	self assert: patient sp01Count equals: 3.
	self assert: patient sp02Count equals: 1.
	self assert: patient sp03Count equals: 0.
	^ patient
]

{ #category : 'examples' }
CbPatientExamples >> exampleRecordSession [
	<gtExample>
	| cabinet patient |
	cabinet := CbCabinetManager new eventLogFile: '/tmp/cb_test_record.ston'.
	'/tmp/cb_test_record.ston' asFileReference ensureDelete.
	cabinet recordEvent: (CbPatientAddedEvent new
		patientCode: 1; firstName: 'Anaïs'; lastName: 'Chavignaud';
		matricule: '1988'; country: 'L').
	patient := cabinet patientWithCode: 1.
	patient cabinet: cabinet.
	patient recordSessionToday.
	self assert: patient sessions size equals: 1.
	self assert: patient sessions first codeActe equals: 'SP01'.
	self assert: patient sessions first date equals: Date today.
	self assert: cabinet eventLog size equals: 2. "1 add + 1 session"
	^ patient
]
