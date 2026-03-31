Class {
	#name : 'CbPatient',
	#superclass : 'Object',
	#instVars : [
		'firstName',
		'lastName',
		'address',
		'city',
		'postalCode',
		'country',
		'matricule',
		'code',
		'sessions',
		'cabinet',
		'receipts'
	],
	#category : 'Gt-PsyCabinet',
	#package : 'Gt-PsyCabinet'
}

{ #category : 'actions' }
CbPatient >> addSessionOn: aDate code: aCodeActe amount: anAmount [
	| session |
	session := CbSession new
		date: aDate;
		codeActe: aCodeActe;
		amount: anAmount;
		patient: self.
	self sessions add: session.
	^ session
]

{ #category : 'accessing' }
CbPatient >> address [
	^ address
]

{ #category : 'accessing' }
CbPatient >> address: aString [
	address := aString
]

{ #category : 'accessing' }
CbPatient >> cabinet [
	^ cabinet
]

{ #category : 'accessing' }
CbPatient >> cabinet: aCabinetManager [
	cabinet := aCabinetManager
]

{ #category : 'accessing' }
CbPatient >> city [
	^ city
]

{ #category : 'accessing' }
CbPatient >> city: aString [
	city := aString
]

{ #category : 'accessing' }
CbPatient >> code [
	^ code
]

{ #category : 'accessing' }
CbPatient >> code: anInteger [
	code := anInteger
]

{ #category : 'accessing' }
CbPatient >> country [
	^ country
]

{ #category : 'accessing' }
CbPatient >> country: aString [
	country := aString
]

{ #category : 'querying' }
CbPatient >> coveredSessions [
	"Sessions already included in a receipt"
	^ self receipts flatCollect: [ :r | r sessions ]
]

{ #category : 'magritte' }
CbPatient >> descriptionAddress [
	<magritteDescription>
	^ MAStringDescription new
		label: 'Adresse';
		priority: 3;
		accessor: #address
]

{ #category : 'magritte' }
CbPatient >> descriptionCity [
	<magritteDescription>
	^ MAStringDescription new
		label: 'Ville';
		priority: 5;
		accessor: #city
]

{ #category : 'magritte' }
CbPatient >> descriptionCode [
	<magritteDescription>
	^ MANumberDescription new
		label: 'Code patient';
		priority: 8;
		accessor: #code
]

{ #category : 'magritte' }
CbPatient >> descriptionCountry [
	<magritteDescription>
	^ MAStringDescription new
		label: 'Pays';
		priority: 6;
		accessor: #country
]

{ #category : 'magritte' }
CbPatient >> descriptionFirstName [
	<magritteDescription>
	^ MAStringDescription new
		label: 'Prénom';
		priority: 1;
		accessor: #firstName
]

{ #category : 'magritte' }
CbPatient >> descriptionLastName [
	<magritteDescription>
	^ MAStringDescription new
		label: 'Nom';
		priority: 2;
		accessor: #lastName
]

{ #category : 'magritte' }
CbPatient >> descriptionMatricule [
	<magritteDescription>
	^ MAStringDescription new
		label: 'Matricule';
		priority: 7;
		accessor: #matricule
]

{ #category : 'magritte' }
CbPatient >> descriptionPostalCode [
	<magritteDescription>
	^ MAStringDescription new
		label: 'Code postal';
		priority: 4;
		accessor: #postalCode
]

{ #category : 'accessing' }
CbPatient >> firstName [
	^ firstName
]

{ #category : 'accessing' }
CbPatient >> firstName: aString [
	firstName := aString
]

{ #category : 'accessing' }
CbPatient >> fullName [
	^ self firstName , ' ' , self lastName
]

{ #category : 'actions' }
CbPatient >> generateReceiptForAllSessionsOn: aDate [
	^ self generateReceiptForSessions: self sessions date: aDate
]

{ #category : 'actions' }
CbPatient >> generateReceiptForSessions: sessionCollection date: aDate [
	^ CbReceipt
		forPatient: self
		sessions: sessionCollection
		date: aDate
]

{ #category : 'actions' }
CbPatient >> generateReceiptForUncoveredSessions: aDate [
	"Generate a receipt for sessions not yet covered by any receipt"
	| uncovered |
	uncovered := self uncoveredSessions.
	uncovered ifEmpty: [ ^ nil ].
	self cabinet
		ifNotNil: [ :cab |
			^ cab recordReceiptForPatient: self sessions: uncovered date: aDate ]
		ifNil: [
			| receipt |
			receipt := CbReceipt forPatient: self sessions: uncovered date: aDate.
			self receipts add: receipt.
			^ receipt ]
]

{ #category : 'gt-views' }
CbPatient >> gtEditFormFor: aView [
	<gtView>
	^ aView explicit
		title: 'Modifier';
		priority: 3;
		stencil: [
			| wrapper |
			wrapper := BrVerticalPane new matchParent.
			wrapper addChild: (self asGtMagritteViewModel asElement
				margin: (BlInsets all: 10);
				constraintsDo: [ :c | c vertical fitContent ]).
			wrapper ]
]

{ #category : 'gt-views' }
CbPatient >> gtInfoFor: aView [
	<gtView>
	^ aView explicit
		title: 'Info';
		priority: 2;
		stencil: [
			| container header details quotas |
			container := BrVerticalPane new
				matchParent;
				padding: (BlInsets all: 20).
			
			"Name header"
			header := BrVerticalPane new fitContent.
			header addChild: (BrLabel new
				aptitude: BrGlamorousLabelAptitude;
				text: (self fullName asRopedText bold fontSize: 18)).
			header addChild: (BrLabel new
				aptitude: BrGlamorousLabelAptitude;
				text: (('Code patient : ' , self code printString) asRopedText foreground: Color gray)).
			container addChild: header.
			container addChild: (BlElement new size: 0@15).
			
			"Details"
			details := BrVerticalPane new fitContent.
			{ 
				'Adresse' -> ((self address ifNil: [ '' ]) , ', ' , (self country ifNil: [ '' ]) , '-' , (self postalCode ifNil: [ '' ]) , ' ' , (self city ifNil: [ '' ])).
				'Matricule' -> (self matricule ifNil: [ '' ]).
			} do: [ :assoc |
				| row |
				row := BrHorizontalPane new fitContent.
				row addChild: (BrLabel new
					aptitude: BrGlamorousLabelAptitude;
					text: (assoc key asRopedText foreground: Color gray);
					hExact: 100; vFitContent).
				row addChild: (BrLabel new
					aptitude: BrGlamorousLabelAptitude;
					text: assoc value asRopedText;
					vFitContent).
				details addChild: row ].
			container addChild: details.
			container addChild: (BlElement new size: 0@20).
			
			"Quotas with bars"
			quotas := BrVerticalPane new fitContent.
			quotas addChild: (BrLabel new
				aptitude: BrGlamorousLabelAptitude;
				text: ('Quotas CNS' asRopedText bold fontSize: 13)).
			quotas addChild: (BlElement new size: 0@8).
			quotas addChild: (self quotaBarFor: self sp01Count max: 3 label: 'SP01 (initiation)').
			quotas addChild: (BlElement new size: 0@5).
			quotas addChild: (self quotaBarFor: self sp02Count max: 24 label: 'SP02 (soutien)').
			quotas addChild: (BlElement new size: 0@5).
			quotas addChild: (self quotaBarFor: self sp03Count max: 120 label: 'SP03 (prolongé)').
			quotas addChild: (BlElement new size: 0@10).
			quotas addChild: (BrLabel new
				aptitude: BrGlamorousLabelAptitude;
				text: ('Prochain code : ' , self nextCodeActe) asRopedText).
			container addChild: quotas.
			container addChild: (BlElement new size: 0@15).
			
			"Summary"
			container addChild: (BrLabel new
				aptitude: BrGlamorousLabelAptitude;
				text: (('Total séances : ' , self sessions size printString ,
					'  |  Non facturées : ' , self uncoveredSessions size printString ,
					'  |  Mémoires : ' , self receipts size printString) asRopedText foreground: Color gray)).
			
			container ]
]

{ #category : 'gt-views' }
CbPatient >> gtMagritteFor: aView [
	<gtView>
	^ aView empty
]

{ #category : 'gt-views' }
CbPatient >> gtMetaFor: aView [
	<gtView>
	CbCabinetManager developerMode ifFalse: [ ^ aView empty ].
	^ super gtMetaFor: aView
]

{ #category : 'gt-views' }
CbPatient >> gtPrintFor: aView [
	<gtView>
	CbCabinetManager developerMode ifFalse: [ ^ aView empty ].
	^ super gtPrintFor: aView
]

{ #category : 'gt-views' }
CbPatient >> gtRawFor: aView [
	<gtView>
	CbCabinetManager developerMode ifFalse: [ ^ aView empty ].
	^ super gtRawFor: aView
]

{ #category : 'gt-views' }
CbPatient >> gtReceiptsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Mémoires';
		priority: 4;
		items: [ self receipts reversed ];
		column: '' icon: [ :r | BrGlamorousVectorIcons file ] width: 30;
		column: 'N°' text: [ :r | r receiptNumber asRopedText bold ] width: 130;
		column: 'Date' text: [ :r | r formattedDate: r receiptDate ] width: 100;
		column: 'Séances' text: [ :r | r sessions size printString ] width: 65;
		column: 'Total' text: [ :r | 
			((r formattedAmount: r total) , ' €') asRopedText bold ] width: 100
]

{ #category : 'gt-views' }
CbPatient >> gtSessionsFor: aView [
	<gtView>
	| view |
	view := aView columnedList
		title: 'Séances';
		priority: 1;
		items: [ self sessions sorted: [ :a :b | a date > b date ] ];
		column: 'Date' text: [ :s | 
			s date printString asRopedText
				foreground: (s isCancelled ifTrue: [ Color gray ] ifFalse: [ Color black ]) ] width: 130;
		column: 'Code' stencil: [ :s |
			BrLabel new
				aptitude: BrGlamorousLabelAptitude;
				text: (s codeActe asRopedText
					foreground: (s isCancelled ifTrue: [ Color gray ] ifFalse: [ s codeColor darker ]));
				background: (s isCancelled
					ifTrue: [ Color gray alpha: 0.15 ]
					ifFalse: [ s codeColor alpha: 0.12 ]);
				geometry: (BlRoundedRectangleGeometry cornerRadius: 8);
				padding: (BlInsets top: 2 bottom: 2 left: 8 right: 8);
				fitContent ] width: 70;
		column: 'Montant' text: [ :s | 
			(s amount printString , ' €') asRopedText
				foreground: (s isCancelled ifTrue: [ Color gray ] ifFalse: [ Color black ]) ] width: 90;
		column: 'Facturée' icon: [ :s |
			(self coveredSessions includes: s)
				ifTrue: [ BrGlamorousVectorIcons greencircle ]
				ifFalse: [ BrGlamorousVectorIcons transparent ] ] width: 60;
		column: '' text: [ :s | 
			s isCancelled ifTrue: [ 'Annulée' asRopedText foreground: Color red ] ifFalse: [ '' ] ] width: 60.
	view
		actionButtonIcon: BrGlamorousVectorIcons add
		tooltip: 'Séance aujourd''hui (' , self nextCodeActe , ')'
		action: [ :aButton :aTab |
			self cabinet ifNotNil: [
				self recordSessionToday.
				aTab phlow fireViewUpdateWish ] ].
	view
		actionDropdownButtonIcon: BrGlamorousVectorIcons edit
		tooltip: 'Séance à une date spécifique'
		content: [ :aDropdown |
			| dateEditor codeEditor container |
			container := BrVerticalPane new fitContent padding: (BlInsets all: 10).
			dateEditor := BrEditor new
				aptitude: BrGlamorousEditorAptitude;
				text: Date today yyyymmdd;
				hExact: 150; vFitContent.
			codeEditor := BrEditor new
				aptitude: BrGlamorousEditorAptitude;
				text: self nextCodeActe;
				hExact: 100; vFitContent.
			container addChild: (BrLabel new aptitude: BrGlamorousLabelAptitude; text: 'Date (AAAA-MM-JJ):').
			container addChild: dateEditor.
			container addChild: (BrLabel new aptitude: BrGlamorousLabelAptitude; text: 'Code acte:').
			container addChild: codeEditor.
			container addChild: (BrButton new
				aptitude: BrGlamorousButtonWithLabelAptitude;
				label: 'Enregistrer';
				action: [ :btn |
					| dateStr date code |
					dateStr := dateEditor editor text asString trimBoth.
					code := codeEditor editor text asString trimBoth.
					date := Date fromString: dateStr.
					self cabinet
						recordSessionForPatient: self
						date: date
						code: code
						amount: self cabinet sessionRate.
					aDropdown phlow fireViewUpdateWish ]).
			container ].
	view
		actionButtonIcon: BrGlamorousVectorIcons note
		tooltip: 'Générer Mémoire d''Honoraires (séances non facturées)'
		action: [ :aButton :aTab |
			| receipt |
			receipt := self generateReceiptForUncoveredSessions: Date today.
			receipt
				ifNotNil: [
					aTab phlow fireViewUpdateWish.
					aButton phlow spawnObject: receipt ]
				ifNil: [ aButton phlow spawnObject: 'Aucune séance non facturée' ] ].
	^ view
]

{ #category : 'accessing' }
CbPatient >> lastName [
	^ lastName
]

{ #category : 'accessing' }
CbPatient >> lastName: aString [
	lastName := aString
]

{ #category : 'accessing' }
CbPatient >> matricule [
	^ matricule
]

{ #category : 'accessing' }
CbPatient >> matricule: aString [
	matricule := aString
]

{ #category : 'querying' }
CbPatient >> nextCodeActe [
	"Suggest next session code based on quotas"
	self sp01Exhausted ifFalse: [ ^ 'SP01' ].
	self sp02Exhausted ifFalse: [ ^ 'SP02' ].
	self sp03Exhausted ifFalse: [ ^ 'SP03' ].
	^ 'SP03'
]

{ #category : 'accessing' }
CbPatient >> postalCode [
	^ postalCode
]

{ #category : 'accessing' }
CbPatient >> postalCode: aString [
	postalCode := aString
]

{ #category : 'printing' }
CbPatient >> printOn: aStream [
	aStream
		nextPutAll: self lastName;
		nextPutAll: ' ';
		nextPutAll: self firstName
]

{ #category : 'ui' }
CbPatient >> quotaBarFor: used max: max label: label [
	"Build a horizontal bar showing quota usage"
	| ratio barWidth container bar filledBar text |
	ratio := max = 0 ifTrue: [ 0 ] ifFalse: [ (used / max) asFloat min: 1.0 ].
	barWidth := 200.
	
	container := BrHorizontalPane new
		fitContent;
		alignCenterLeft.
	
	text := BrLabel new
		aptitude: BrGlamorousLabelAptitude;
		text: (label , '  ' , used printString , ' / ' , max printString) asRopedText;
		hExact: 150;
		vFitContent.
	
	bar := BlElement new
		size: barWidth @ 14;
		background: (Color gray alpha: 0.15);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 3).
	
	filledBar := BlElement new
		size: (barWidth * ratio) @ 14;
		background: (ratio >= 1.0
			ifTrue: [ Color r: 0.85 g: 0.2 b: 0.2 ]
			ifFalse: [ ratio > 0.7
				ifTrue: [ Color r: 0.9 g: 0.6 b: 0.1 ]
				ifFalse: [ Color r: 0.2 g: 0.7 b: 0.3 ] ]);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 3).
	bar addChild: filledBar.
	
	container addChild: text.
	container addChild: bar.
	^ container
]

{ #category : 'ui' }
CbPatient >> quotaSummary [
	"Short text summary of quota usage"
	^ self sp01Count printString , '/' , self sp02Count printString , '/' , self sp03Count printString
]

{ #category : 'accessing' }
CbPatient >> receipts [
	^ receipts ifNil: [ receipts := OrderedCollection new ]
]

{ #category : 'actions' }
CbPatient >> recordSessionOn: aDate [
	"Record a session on the given date with the next appropriate SP code"
	| code |
	code := self nextCodeActe.
	self cabinet
		recordSessionForPatient: self
		date: aDate
		code: code
		amount: self cabinet sessionRate.
	^ self sessions last
]

{ #category : 'actions' }
CbPatient >> recordSessionToday [
	"Record a session for today with the next appropriate SP code"
	^ self recordSessionOn: Date today
]

{ #category : 'accessing' }
CbPatient >> sessions [
	^ sessions ifNil: [ sessions := OrderedCollection new ]
]

{ #category : 'querying' }
CbPatient >> sessionsWithCode: aCodeActe [
	^ self sessions select: [ :s | s codeActe = aCodeActe and: [ s isCancelled not ] ]
]

{ #category : 'querying' }
CbPatient >> sp01Count [
	^ (self sessionsWithCode: 'SP01') size
]

{ #category : 'testing' }
CbPatient >> sp01Exhausted [
	^ self sp01Remaining = 0
]

{ #category : 'querying' }
CbPatient >> sp01Remaining [
	^ (3 - self sp01Count) max: 0
]

{ #category : 'querying' }
CbPatient >> sp02Count [
	^ (self sessionsWithCode: 'SP02') size
]

{ #category : 'testing' }
CbPatient >> sp02Exhausted [
	^ self sp02Remaining = 0
]

{ #category : 'querying' }
CbPatient >> sp02Remaining [
	^ (24 - self sp02Count) max: 0
]

{ #category : 'querying' }
CbPatient >> sp03Count [
	^ (self sessionsWithCode: 'SP03') size
]

{ #category : 'testing' }
CbPatient >> sp03Exhausted [
	^ self sp03Remaining = 0
]

{ #category : 'querying' }
CbPatient >> sp03Remaining [
	^ (120 - self sp03Count) max: 0
]

{ #category : 'ui' }
CbPatient >> statusIcon [
	"Green if has uncovered sessions, grey if all covered, red if SP01 exhausted"
	self uncoveredSessions ifNotEmpty: [ ^ BrGlamorousVectorIcons yellowcircle ].
	self sessions ifEmpty: [ ^ BrGlamorousVectorIcons graycircle ].
	^ BrGlamorousVectorIcons greencircle
]

{ #category : 'querying' }
CbPatient >> uncoveredSessions [
	"Sessions not yet included in any receipt"
	| covered |
	covered := self coveredSessions.
	^ self sessions select: [ :s | 
		s isCancelled not and: [ (covered includes: s) not ] ]
]

{ #category : 'magritte' }
CbPatient >> write: aValue using: aDescription [
	"Intercept Magritte writes to record events"
	| fieldName |
	super write: aValue using: aDescription.
	self cabinet ifNotNil: [ :cab |
		fieldName := aDescription accessor selector asString.
		cab recordUpdatePatient: self field: fieldName value: aValue ]
]
