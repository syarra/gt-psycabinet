Class {
	#name : 'CbCabinetManager',
	#superclass : 'Object',
	#instVars : [
		'patients',
		'sessionRate',
		'practitionerCode',
		'eventLog',
		'eventLogFile'
	],
	#classInstVars : [
		'developerMode'
	],
	#category : 'Gt-PsyCabinet',
	#package : 'Gt-PsyCabinet'
}

{ #category : 'settings' }
CbCabinetManager class >> developerMode [
	^ developerMode ifNil: [ false ]
]

{ #category : 'settings' }
CbCabinetManager class >> developerMode: aBoolean [
	developerMode := aBoolean
]

{ #category : 'instance creation' }
CbCabinetManager class >> fromEventLog: aFilePathString [
	"Create a cabinet manager by replaying events from a file"
	^ self new
		eventLogFile: aFilePathString;
		replayFromFile;
		yourself
]

{ #category : 'instance creation' }
CbCabinetManager class >> production [
	"Create or restore the production cabinet from the event log"
	| cab |
	cab := self new.
	cab eventLogFile: cab defaultEventLogFile.
	cab eventLogFile asFileReference exists
		ifTrue: [ cab replayFromFile ]
		ifFalse: [ 
			"First run: import existing patients from CSV"
			| csvFile |
			csvFile := '/Users/arrecs/Dropbox/work Claire/CabinetLuxembourg/Clients/patients_export.csv' asFileReference.
			csvFile exists ifTrue: [ cab importPatientsFromCsv: csvFile contents ] ].
	cab patients do: [ :p | p cabinet: cab ].
	^ cab
]

{ #category : 'settings' }
CbCabinetManager class >> toggleDeveloperMode [
	developerMode := self developerMode not.
	^ developerMode
]

{ #category : 'actions' }
CbCabinetManager >> addPatient: aPatient [
	aPatient code ifNil: [ aPatient code: self nextPatientCode ].
	aPatient cabinet: self.
	self patients add: aPatient.
	^ aPatient
]

{ #category : 'actions' }
CbCabinetManager >> addPatientFirstName: aFirstName lastName: aLastName matricule: aMatricule code: aCode [
	| patient |
	patient := CbPatient new
		firstName: aFirstName;
		lastName: aLastName;
		matricule: aMatricule;
		code: aCode;
		cabinet: self.
	self patients add: patient.
	^ patient
]

{ #category : 'querying' }
CbCabinetManager >> allSessions [
	"Return all sessions across all patients"
	^ self patients flatCollect: [ :p | p sessions ]
]

{ #category : 'accessing' }
CbCabinetManager >> appFolder [
	^ '/Users/arrecs/Dropbox/work Claire/CabinetLuxembourg/CabinetApp'
]

{ #category : 'accessing' }
CbCabinetManager >> defaultEventLogFile [
	^ self appFolder , '/data/cabinet_events.ston'
]

{ #category : 'accessing' }
CbCabinetManager >> eventLog [
	^ eventLog ifNil: [ eventLog := OrderedCollection new ]
]

{ #category : 'accessing' }
CbCabinetManager >> eventLogFile [
	^ eventLogFile
]

{ #category : 'accessing' }
CbCabinetManager >> eventLogFile: aFileReference [
	eventLogFile := aFileReference
]

{ #category : 'gt-views' }
CbCabinetManager >> gtEventLogFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Historique';
		priority: 5;
		items: [ self eventLog reversed ];
		column: 'Date' text: [ :e | e timestamp asStringYMDHM ] width: 150;
		column: 'Événement' text: [ :e | e printString ] width: 500
]

{ #category : 'gt-views' }
CbCabinetManager >> gtFinancesFor: aView [
	<gtView>
	| year |
	year := Date today year.
	^ aView columnedList
		title: 'Finances ' , year printString;
		priority: 3;
		items: [
			| months totalSessions totalRevenue |
			months := self monthlyRevenueForYear: year.
			totalSessions := months inject: 0 into: [ :sum :row | sum + row second ].
			totalRevenue := months inject: 0 into: [ :sum :row | sum + row third ].
			months , { { 'TOTAL'. totalSessions. totalRevenue } } ];
		column: 'Mois' text: [ :row |
			row first = 'TOTAL'
				ifTrue: [ row first asRopedText bold ]
				ifFalse: [ row first ] ] width: 120;
		column: 'Séances' text: [ :row |
			| text |
			text := row second printString.
			row second = 0
				ifTrue: [ text asRopedText foreground: Color gray ]
				ifFalse: [ row first = 'TOTAL'
					ifTrue: [ text asRopedText bold ]
					ifFalse: [ text ] ] ] width: 70;
		column: 'Revenu' text: [ :row |
			| amt intPart decPart text |
			amt := row third.
			intPart := amt truncated.
			decPart := ((amt - intPart) * 100) rounded.
			text := intPart printString , ',' , (decPart printString padLeftTo: 2 with: $0) , ' €'.
			amt = 0
				ifTrue: [ text asRopedText foreground: Color gray ]
				ifFalse: [ row first = 'TOTAL'
					ifTrue: [ text asRopedText bold ]
					ifFalse: [ text ] ] ] width: 120
]

{ #category : 'gt-views' }
CbCabinetManager >> gtMagritteFor: aView [
	<gtView>
	^ aView empty
]

{ #category : 'gt-views' }
CbCabinetManager >> gtMetaFor: aView [
	<gtView>
	CbCabinetManager developerMode ifFalse: [ ^ aView empty ].
	^ super gtMetaFor: aView
]

{ #category : 'gt-views' }
CbCabinetManager >> gtPatientsFor: aView [
	<gtView>
	| view |
	view := aView columnedList
		title: 'Patients';
		priority: 1;
		items: [ self patients sorted: [ :a :b | a lastName < b lastName ] ];
		column: '' icon: [ :p | p statusIcon ] width: 30;
		column: 'Nom' text: [ :p | 
			(p lastName asRopedText bold) append: ('  ' , p firstName) asRopedText ] width: 200;
		column: 'Ville' text: [ :p | p city ifNil: [ '' ] ] width: 120;
		column: 'Séances' text: [ :p | 
			| count |
			count := p sessions size.
			count = 0 
				ifTrue: [ '—' asRopedText foreground: Color gray ]
				ifFalse: [ count printString asRopedText ] ] width: 65;
		column: 'SP' text: [ :p |
			p sessions isEmpty
				ifTrue: [ '' ]
				ifFalse: [ p quotaSummary ] ] width: 70;
		column: 'Non facturées' text: [ :p |
			| n |
			n := p uncoveredSessions size.
			n = 0
				ifTrue: [ '' ]
				ifFalse: [ n printString asRopedText foreground: (Color r: 0.8 g: 0.4 b: 0) ] ] width: 100.
	view
		actionButtonIcon: BrGlamorousVectorIcons add
		tooltip: 'Ajouter un patient'
		action: [ :aButton :aTab |
			| newPatient |
			newPatient := CbPatient new
				code: self nextPatientCode;
				firstName: '';
				lastName: '';
				country: 'L'.
			self recordAddPatient: newPatient.
			(self patientWithCode: newPatient code) cabinet: self.
			aTab phlow fireViewUpdateWish ].
	view
		actionStencil: [ :aButton |
			GtSpotterDropdownButtonStencil new
				valuable: [ self patients sorted: [ :a :b | a lastName < b lastName ] ];
				tooltip: 'Chercher un patient';
				objectActOn: [ :anActOnEvent :anItem :theButton |
					anActOnEvent beActed.
					theButton phlow spawnObject: anActOnEvent objectToSend ];
				asElement ]
		tooltip: 'Chercher un patient'.
	view
		actionButtonIcon: BrGlamorousVectorIcons settings
		tooltip: (CbCabinetManager developerMode 
			ifTrue: [ 'Mode développeur : ON' ] 
			ifFalse: [ 'Mode développeur : OFF' ])
		action: [ :aButton :aTab |
			CbCabinetManager toggleDeveloperMode.
			aTab phlow fireViewUpdateWish ].
	^ view
]

{ #category : 'gt-views' }
CbCabinetManager >> gtPrintFor: aView [
	<gtView>
	CbCabinetManager developerMode ifFalse: [ ^ aView empty ].
	^ super gtPrintFor: aView
]

{ #category : 'gt-views' }
CbCabinetManager >> gtRawFor: aView [
	<gtView>
	CbCabinetManager developerMode ifFalse: [ ^ aView empty ].
	^ super gtRawFor: aView
]

{ #category : 'importing' }
CbCabinetManager >> importPatientsFromCsv: csvString [
	"Import patients from semicolon-delimited CSV string. First row is header.
	 Records events for each patient."
	| lines |
	lines := csvString lines.
	lines allButFirst doWithIndex: [ :line :index |
		| fields |
		fields := line splitOn: ';'.
		fields size >= 6 ifTrue: [
			self recordEvent: (CbPatientAddedEvent new
				patientCode: index;
				firstName: (fields at: 1) trimBoth;
				lastName: (fields at: 2) trimBoth;
				address: (fields at: 3) trimBoth;
				city: (fields at: 4) trimBoth;
				postalCode: (fields at: 5) trimBoth;
				country: (fields at: 6) trimBoth;
				matricule: (fields size >= 9 ifTrue: [ (fields at: 9) trimBoth ] ifFalse: [ '' ])).
			(self patientWithCode: index) cabinet: self ] ]
]

{ #category : 'querying' }
CbCabinetManager >> monthlyRevenueForYear: aYear [
	"Return an ordered collection of {monthName. sessionCount. revenue} for each month"
	| months frenchMonths |
	frenchMonths := #('Janvier' 'Février' 'Mars' 'Avril' 'Mai' 'Juin' 'Juillet' 'Août' 'Septembre' 'Octobre' 'Novembre' 'Décembre').
	months := (1 to: 12) collect: [ :m |
		| sessions revenue |
		sessions := self sessionsForYear: aYear month: m.
		revenue := sessions inject: 0 into: [ :sum :s | sum + s amount ].
		{ frenchMonths at: m. sessions size. revenue } ].
	^ months
]

{ #category : 'actions' }
CbCabinetManager >> newPatient [
	"Create a new empty patient with next available code"
	^ CbPatient new
		code: self nextPatientCode;
		firstName: '';
		lastName: '';
		country: 'L'
]

{ #category : 'querying' }
CbCabinetManager >> nextPatientCode [
	"Generate next available patient code"
	self patients ifEmpty: [ ^ 1 ].
	^ (self patients collect: [ :p | p code ]) max + 1
]

{ #category : 'querying' }
CbCabinetManager >> patientWithCode: aCode [
	^ self patients detect: [ :p | p code = aCode ] ifNone: [ nil ]
]

{ #category : 'accessing' }
CbCabinetManager >> patients [
	^ patients ifNil: [ patients := OrderedCollection new ]
]

{ #category : 'event-sourcing' }
CbCabinetManager >> persistEvent: anEvent [
	"Append a single event as STON to the log file"
	self eventLogFile ifNil: [ ^ self ].
	self eventLogFile asFileReference ensureCreateFile.
	self eventLogFile asFileReference
		writeStreamDo: [ :stream |
			stream setToEnd.
			STON put: anEvent onStream: stream.
			stream nextPut: Character lf ]
]

{ #category : 'accessing' }
CbCabinetManager >> practitionerCode [
	^ practitionerCode ifNil: [ '530190-85' ]
]

{ #category : 'printing' }
CbCabinetManager >> printOn: aStream [
	aStream
		nextPutAll: 'Cabinet Orieux - ';
		print: self patients size;
		nextPutAll: ' patients'
]

{ #category : 'accessing' }
CbCabinetManager >> receiptsFolder [
	^ self appFolder , '/receipts'
]

{ #category : 'event-sourcing' }
CbCabinetManager >> recordAddPatient: aPatient [
	"Record a PatientAdded event"
	self recordEvent: (CbPatientAddedEvent new
		patientCode: aPatient code;
		firstName: aPatient firstName;
		lastName: aPatient lastName;
		address: aPatient address;
		city: aPatient city;
		postalCode: aPatient postalCode;
		country: aPatient country;
		matricule: aPatient matricule)
]

{ #category : 'event-sourcing' }
CbCabinetManager >> recordCancelSessionForPatient: aPatient date: aDate [
	"Record a SessionCancelled event"
	self recordEvent: (CbSessionCancelledEvent new
		patientCode: aPatient code;
		date: aDate)
]

{ #category : 'event-sourcing' }
CbCabinetManager >> recordEvent: anEvent [
	"Apply event to current state, store in log, and persist to file"
	anEvent applyOn: self.
	self eventLog add: anEvent.
	self persistEvent: anEvent
]

{ #category : 'event-sourcing' }
CbCabinetManager >> recordReceiptForPatient: aPatient sessions: sessionCollection date: aDate [
	"Record a ReceiptGenerated event"
	| receipt |
	receipt := CbReceipt forPatient: aPatient sessions: sessionCollection date: aDate.
	self recordEvent: (CbReceiptGeneratedEvent new
		patientCode: aPatient code;
		receiptDate: aDate;
		receiptNumber: receipt receiptNumber;
		sessionDates: (sessionCollection collect: [ :s | s date ])).
	^ aPatient receipts last
]

{ #category : 'event-sourcing' }
CbCabinetManager >> recordSessionForPatient: aPatient date: aDate code: aCodeActe amount: anAmount [
	"Record a SessionRecorded event"
	self recordEvent: (CbSessionRecordedEvent new
		patientCode: aPatient code;
		date: aDate;
		codeActe: aCodeActe;
		amount: anAmount)
]

{ #category : 'event-sourcing' }
CbCabinetManager >> recordUpdatePatient: aPatient field: fieldName value: newValue [
	"Record a PatientUpdated event"
	self recordEvent: (CbPatientUpdatedEvent new
		patientCode: aPatient code;
		fieldName: fieldName;
		newValue: newValue)
]

{ #category : 'event-sourcing' }
CbCabinetManager >> replayFromFile [
	"Rebuild state by replaying all events from the log file"
	| file |
	file := self eventLogFile asFileReference.
	file exists ifFalse: [ ^ self ].
	patients := nil.
	eventLog := nil.
	file readStreamDo: [ :stream |
		[ stream atEnd ] whileFalse: [
			| event |
			event := STON fromStream: stream.
			event applyOn: self.
			self eventLog add: event ] ]
]

{ #category : 'accessing' }
CbCabinetManager >> sessionRate [
	^ sessionRate ifNil: [ 158.95 ]
]

{ #category : 'accessing' }
CbCabinetManager >> sessionRate: aNumber [
	sessionRate := aNumber
]

{ #category : 'querying' }
CbCabinetManager >> sessionsForYear: aYear month: aMonth [
	^ self allSessions select: [ :s |
		s date year = aYear and: [ s date monthIndex = aMonth and: [ s isCancelled not ] ] ]
]
