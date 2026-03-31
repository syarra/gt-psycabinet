Class {
	#name : 'CbSession',
	#superclass : 'Object',
	#instVars : [
		'date',
		'codeActe',
		'amount',
		'patient',
		'cancelled'
	],
	#category : 'Gt-PsyCabinet',
	#package : 'Gt-PsyCabinet'
}

{ #category : 'accessing' }
CbSession >> amount [
	^ amount
]

{ #category : 'accessing' }
CbSession >> amount: aNumber [
	amount := aNumber
]

{ #category : 'actions' }
CbSession >> cancel [
	cancelled := true
]

{ #category : 'accessing' }
CbSession >> cancelled [
	^ cancelled ifNil: [ false ]
]

{ #category : 'accessing' }
CbSession >> cancelled: aBoolean [
	cancelled := aBoolean
]

{ #category : 'accessing' }
CbSession >> codeActe [
	^ codeActe
]

{ #category : 'accessing' }
CbSession >> codeActe: aString [
	codeActe := aString
]

{ #category : 'ui' }
CbSession >> codeColor [
	"Color for the session code badge"
	self codeActe = 'SP01' ifTrue: [ ^ Color r: 0.2 g: 0.5 b: 0.9 ].
	self codeActe = 'SP02' ifTrue: [ ^ Color r: 0.5 g: 0.3 b: 0.8 ].
	self codeActe = 'SP03' ifTrue: [ ^ Color r: 0.8 g: 0.4 b: 0.2 ].
	^ Color gray
]

{ #category : 'accessing' }
CbSession >> date [
	^ date
]

{ #category : 'accessing' }
CbSession >> date: aDate [
	date := aDate
]

{ #category : 'magritte' }
CbSession >> descriptionAmount [
	<magritteDescription>
	^ MANumberDescription new
		label: 'Montant (€)';
		priority: 3;
		accessor: #amount
]

{ #category : 'magritte' }
CbSession >> descriptionCancelled [
	<magritteDescription>
	^ MABooleanDescription new
		label: 'Annulée';
		priority: 4;
		accessor: #cancelled
]

{ #category : 'magritte' }
CbSession >> descriptionCodeActe [
	<magritteDescription>
	^ MASingleOptionDescription new
		label: 'Code Acte';
		priority: 2;
		accessor: #codeActe;
		options: #('SP01' 'SP02' 'SP03')
]

{ #category : 'magritte' }
CbSession >> descriptionDate [
	<magritteDescription>
	^ MADateDescription new
		label: 'Date';
		priority: 1;
		accessor: #date
]

{ #category : 'gt-views' }
CbSession >> gtEditFormFor: aView [
	<gtView>
	^ aView explicit
		title: 'Modifier';
		priority: 1;
		stencil: [
			| wrapper |
			wrapper := BrVerticalPane new matchParent.
			wrapper addChild: (self asGtMagritteViewModel asElement
				margin: (BlInsets all: 10);
				constraintsDo: [ :c | c vertical fitContent ]).
			wrapper ]
]

{ #category : 'gt-views' }
CbSession >> gtMagritteFor: aView [
	<gtView>
	^ aView empty
]

{ #category : 'gt-views' }
CbSession >> gtMetaFor: aView [
	<gtView>
	CbCabinetManager developerMode ifFalse: [ ^ aView empty ].
	^ super gtMetaFor: aView
]

{ #category : 'gt-views' }
CbSession >> gtPrintFor: aView [
	<gtView>
	CbCabinetManager developerMode ifFalse: [ ^ aView empty ].
	^ super gtPrintFor: aView
]

{ #category : 'gt-views' }
CbSession >> gtRawFor: aView [
	<gtView>
	CbCabinetManager developerMode ifFalse: [ ^ aView empty ].
	^ super gtRawFor: aView
]

{ #category : 'testing' }
CbSession >> isCancelled [
	^ self cancelled
]

{ #category : 'accessing' }
CbSession >> patient [
	^ patient
]

{ #category : 'accessing' }
CbSession >> patient: aPatient [
	patient := aPatient
]

{ #category : 'printing' }
CbSession >> printOn: aStream [
	aStream
		nextPutAll: self date printString;
		nextPutAll: ' - ';
		nextPutAll: self codeActe;
		nextPutAll: ' - ';
		print: self amount;
		nextPutAll: '€'
]
