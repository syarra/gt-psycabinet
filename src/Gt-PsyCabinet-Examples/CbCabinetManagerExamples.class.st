Class {
	#name : 'CbCabinetManagerExamples',
	#superclass : 'Object',
	#category : 'Gt-PsyCabinet-Examples',
	#package : 'Gt-PsyCabinet-Examples'
}

{ #category : 'examples' }
CbCabinetManagerExamples >> exampleAllViewsBuild [
	<gtExample>
	"Verify all CabinetManager views render without errors using GtPhlowViewTester"
	| cabinet |
	cabinet := self exampleCabinetWithPatients.
	self assertObjectPhlowViewsFor: cabinet.
	^ cabinet
]

{ #category : 'examples' }
CbCabinetManagerExamples >> exampleCabinet [
	<gtExample>
	| cabinet patient |
	cabinet := CbCabinetManager new.
	self assert: cabinet patients isEmpty.
	patient := cabinet
		addPatientFirstName: 'Anaïs'
		lastName: 'Chavignaud'
		matricule: '1988062896018'
		code: 1.
	self assert: cabinet patients size equals: 1.
	self assert: (cabinet patientWithCode: 1) equals: patient.
	self assert: cabinet sessionRate equals: 158.95.
	^ cabinet
]

{ #category : 'examples' }
CbCabinetManagerExamples >> exampleCabinetFromImport [
	<gtExample>
	| cabinet csvFile |
	csvFile := '/Users/arrecs/Dropbox/work Claire/CabinetLuxembourg/Clients/patients_export.csv' asFileReference.
	cabinet := CbCabinetManager new.
	cabinet importPatientsFromCsv: csvFile contents.
	self assert: cabinet patients size > 100.
	self assert: cabinet patients first lastName equals: 'Chavignaud'.
	^ cabinet
]

{ #category : 'examples' }
CbCabinetManagerExamples >> exampleCabinetPatientsView [
	<gtExample>
	| cabinet view |
	cabinet := self exampleCabinetWithPatients.
	view := cabinet gtPatientsFor: GtPhlowEmptyView new.
	self assert: view isNotNil.
	^ view
]

{ #category : 'examples' }
CbCabinetManagerExamples >> exampleCabinetWithPatients [
	<gtExample>
	| cabinet p1 p2 |
	cabinet := self exampleCabinet.
	p1 := cabinet patientWithCode: 1.
	p1
		address: '103 avenue de la Faïencerie';
		city: 'Luxembourg';
		postalCode: '1511';
		country: 'L'.
	p1 addSessionOn: (Date year: 2026 month: 1 day: 10) code: 'SP01' amount: 158.95.
	p1 addSessionOn: (Date year: 2026 month: 1 day: 17) code: 'SP01' amount: 158.95.
	p1 addSessionOn: (Date year: 2026 month: 1 day: 24) code: 'SP01' amount: 158.95.
	p1 addSessionOn: (Date year: 2026 month: 2 day: 7) code: 'SP02' amount: 158.95.
	p1 addSessionOn: (Date year: 2026 month: 2 day: 14) code: 'SP02' amount: 158.95.
	
	p2 := cabinet
		addPatientFirstName: 'Marie'
		lastName: 'Tomassi'
		matricule: '1995091934888'
		code: 5.
	p2
		address: '55 rue Wiltheim';
		city: 'Senningen';
		postalCode: '6962';
		country: 'L'.
	p2 addSessionOn: (Date year: 2026 month: 2 day: 3) code: 'SP01' amount: 158.95.
	p2 addSessionOn: (Date year: 2026 month: 2 day: 10) code: 'SP01' amount: 158.95.
	
	self assert: cabinet patients size equals: 2.
	self assert: p1 sessions size equals: 5.
	self assert: p2 sessions size equals: 2.
	^ cabinet
]

{ #category : 'examples' }
CbCabinetManagerExamples >> exampleDeveloperModeToggle [
	<gtExample>
	| patient viewsOff viewsOn |
	CbCabinetManager developerMode: false.
	patient := CbPatientExamples new exampleBasicPatient.
	
	"OFF: should NOT have Raw, Print, Meta"
	viewsOff := GtPhlowViewsCollector new fromObject: patient; collect.
	viewsOff := viewsOff reject: [ :v | v class = GtPhlowEmptyView ].
	self assert: (viewsOff noneSatisfy: [ :v | v title = 'Raw' ]).
	self assert: (viewsOff noneSatisfy: [ :v | v title = 'Print' ]).
	self assert: (viewsOff noneSatisfy: [ :v | v title = 'Meta' ]).
	
	"ON: should have Raw, Print, Meta"
	CbCabinetManager developerMode: true.
	viewsOn := GtPhlowViewsCollector new fromObject: patient; collect.
	viewsOn := viewsOn reject: [ :v | v class = GtPhlowEmptyView ].
	self assert: (viewsOn anySatisfy: [ :v | v title = 'Raw' ]).
	self assert: (viewsOn anySatisfy: [ :v | v title = 'Print' ]).
	self assert: (viewsOn anySatisfy: [ :v | v title = 'Meta' ]).
	
	"Reset"
	CbCabinetManager developerMode: false.
	^ patient
]
