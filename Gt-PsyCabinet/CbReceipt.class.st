Class {
	#name : 'CbReceipt',
	#superclass : 'Object',
	#instVars : [
		'patient',
		'sessions',
		'receiptDate',
		'receiptNumber',
		'cabinet'
	],
	#category : 'Gt-PsyCabinet',
	#package : 'Gt-PsyCabinet'
}

{ #category : 'instance creation' }
CbReceipt class >> forPatient: aPatient sessions: aCollection date: aDate [
	^ self new
		patient: aPatient;
		sessions: aCollection asOrderedCollection;
		receiptDate: aDate
]

{ #category : 'exporting' }
CbReceipt >> asJsonForExport [
	"Generate JSON data for the Python DOCX generator"
	| sessionsJson |
	sessionsJson := self sessions collect: [ :s |
		Dictionary new
			at: 'date' put: (self formattedDate: s date);
			at: 'codeActe' put: s codeActe;
			at: 'amount' put: (self formattedAmount: s amount);
			yourself ].
	^ Dictionary new
		at: 'receiptNumber' put: self receiptNumber;
		at: 'receiptDate' put: (self formattedDate: self receiptDate);
		at: 'total' put: (self formattedAmount: self total);
		at: 'practitionerCode' put: '530190-85';
		at: 'lieu' put: '009';
		at: 'patient' put: (Dictionary new
			at: 'firstName' put: (self patient firstName ifNil: [ '' ]);
			at: 'lastName' put: (self patient lastName ifNil: [ '' ]);
			at: 'address' put: (self patient address ifNil: [ '' ]);
			at: 'city' put: (self patient city ifNil: [ '' ]);
			at: 'postalCode' put: (self patient postalCode ifNil: [ '' ]);
			at: 'country' put: (self patient country ifNil: [ '' ]);
			at: 'matricule' put: (self patient matricule ifNil: [ '' ]);
			yourself);
		at: 'sessions' put: sessionsJson;
		yourself
]

{ #category : 'accessing' }
CbReceipt >> cabinet [
	^ cabinet ifNil: [ self patient cabinet ]
]

{ #category : 'accessing' }
CbReceipt >> cabinet: aCabinetManager [
	cabinet := aCabinetManager
]

{ #category : 'exporting' }
CbReceipt >> defaultOutputPath [
	"Generate output path in the CabinetApp/receipts folder"
	| folder |
	folder := self cabinet
		ifNotNil: [ :cab | cab receiptsFolder ]
		ifNil: [ '/tmp' ].
	^ folder , '/MH_' , 
		self patient lastName , '_' , 
		self receiptNumber , '.docx'
]

{ #category : 'exporting' }
CbReceipt >> defaultPdfPath [
	| folder |
	folder := self cabinet
		ifNotNil: [ :cab | cab receiptsFolder ]
		ifNil: [ '/tmp' ].
	^ folder , '/MH_' , 
		self patient lastName , '_' , 
		self receiptNumber , '.pdf'
]

{ #category : 'exporting' }
CbReceipt >> defaultTemplatePath [
	^ '/Users/arrecs/Dropbox/work Claire/CabinetLuxembourg/Clients/MemoireHonoraire/Memoire HonoraireTemplate (1).docx'
]

{ #category : 'exporting' }
CbReceipt >> exportDocx [
	"Export with default paths"
	^ self exportDocxTo: self defaultOutputPath template: self defaultTemplatePath
]

{ #category : 'exporting' }
CbReceipt >> exportDocxTo: outputPath template: templatePath [
	"Export receipt as DOCX by calling Python with json data"
	| jsonFile jsonString process |
	jsonFile := (outputPath , '.json') asFileReference.
	jsonString := NeoJSONWriter toString: self asJsonForExport.
	jsonFile writeStreamDo: [ :s | s nextPutAll: jsonString ].
	
	process := GtSubprocessWithInMemoryOutput new
		command: 'python3';
		arguments: {
			'/Users/arrecs/Dropbox/work Claire/CabinetLuxembourg/generate_receipt.py'.
			jsonFile fullName.
			outputPath.
			templatePath };
		runAndWait.
	
	jsonFile ensureDelete.
	^ outputPath asFileReference
]

{ #category : 'exporting' }
CbReceipt >> exportPdf [
	"Export receipt directly as PDF using reportlab"
	| jsonFile jsonString pdfPath process scriptPath |
	pdfPath := self defaultPdfPath.
	jsonFile := (pdfPath , '.json') asFileReference.
	jsonString := NeoJSONWriter toString: self asJsonForExport.
	jsonFile writeStreamDo: [ :s | s nextPutAll: jsonString ].
	
	scriptPath := self cabinet
		ifNotNil: [ :cab | cab appFolder , '/generate_pdf.py' ]
		ifNil: [ '/Users/arrecs/Dropbox/work Claire/CabinetLuxembourg/CabinetApp/generate_pdf.py' ].
	
	process := GtSubprocessWithInMemoryOutput new
		command: 'python3';
		arguments: { scriptPath. jsonFile fullName. pdfPath };
		runAndWait.
	
	jsonFile ensureDelete.
	^ pdfPath asFileReference
]

{ #category : 'formatting' }
CbReceipt >> formattedAmount: aNumber [
	"Format as 158,95"
	| intPart decPart |
	intPart := aNumber truncated.
	decPart := ((aNumber - intPart) * 100) rounded.
	^ intPart printString , ',' , (decPart printString padLeftTo: 2 with: $0)
]

{ #category : 'formatting' }
CbReceipt >> formattedDate: aDate [
	"Format as DD/MM/YYYY"
	^ (aDate dayOfMonth printString padLeftTo: 2 with: $0) , '/' ,
		(aDate monthIndex printString padLeftTo: 2 with: $0) , '/' ,
		aDate year printString
]

{ #category : 'gt-views' }
CbReceipt >> gtHeaderFor: aView [
	<gtView>
	| view |
	view := aView explicit
		title: 'Mémoire d''Honoraires';
		priority: 1;
		stencil: [ self receiptElement ].
	view
		actionButtonIcon: BrGlamorousVectorIcons accept
		tooltip: 'Exporter PDF'
		action: [ :aButton |
			| pdfFile process |
			pdfFile := self exportPdf.
			"Open the PDF in the default viewer"
			process := GtSubprocessWithInMemoryOutput new
				command: 'open';
				arguments: { pdfFile fullName };
				runAndWait ].
	^ view
]

{ #category : 'gt-views' }
CbReceipt >> gtMagritteFor: aView [
	<gtView>
	^ aView empty
]

{ #category : 'gt-views' }
CbReceipt >> gtMetaFor: aView [
	<gtView>
	CbCabinetManager developerMode ifFalse: [ ^ aView empty ].
	^ super gtMetaFor: aView
]

{ #category : 'gt-views' }
CbReceipt >> gtPrintFor: aView [
	<gtView>
	CbCabinetManager developerMode ifFalse: [ ^ aView empty ].
	^ super gtPrintFor: aView
]

{ #category : 'gt-views' }
CbReceipt >> gtRawFor: aView [
	<gtView>
	CbCabinetManager developerMode ifFalse: [ ^ aView empty ].
	^ super gtRawFor: aView
]

{ #category : 'gt-views' }
CbReceipt >> gtSessionLinesFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Lignes';
		priority: 2;
		items: [ self sessions sorted: [ :a :b | a date <= b date ] ];
		column: '#' text: [ :s | (self sessions indexOf: s) printString ] width: 40;
		column: 'Exécutant' text: [ :s | '530190-85' ] width: 100;
		column: 'Lieu' text: [ :s | '009' ] width: 50;
		column: 'Date' text: [ :s | self formattedDate: s date ] width: 100;
		column: 'Code Acte' text: [ :s | s codeActe ] width: 80;
		column: 'Montant' text: [ :s | (self formattedAmount: s amount) , ' €' ] width: 100
]

{ #category : 'accessing' }
CbReceipt >> patient [
	^ patient
]

{ #category : 'accessing' }
CbReceipt >> patient: aPatient [
	patient := aPatient
]

{ #category : 'printing' }
CbReceipt >> printOn: aStream [
	aStream
		nextPutAll: 'Mémoire ';
		nextPutAll: self receiptNumber;
		nextPutAll: ' - ';
		nextPutAll: self patient lastName;
		nextPutAll: ' - ';
		print: self total;
		nextPutAll: '€'
]

{ #category : 'accessing' }
CbReceipt >> receiptDate [
	^ receiptDate
]

{ #category : 'accessing' }
CbReceipt >> receiptDate: aDate [
	receiptDate := aDate
]

{ #category : 'rendering' }
CbReceipt >> receiptElement [
	"Build a Bloc element that visually matches the Mémoire d'Honoraires"
	| container header patientBlock tableBlock footerBlock |
	container := BrVerticalPane new
		fitContent;
		padding: (BlInsets all: 30);
		background: Color white.
	
	"Header"
	header := BrVerticalPane new fitContent.
	header addChild: (self receiptLabel: 'ORIEUX Claire' size: 14 bold: true).
	header addChild: (self receiptLabel: 'Psychologue - Psychothérapeute' size: 11 bold: false).
	header addChild: (self receiptLabel: '51, avenue Pasteur' size: 11 bold: false).
	header addChild: (self receiptLabel: 'L-2311 Luxembourg' size: 11 bold: false).
	header addChild: (self receiptLabel: 'Tél : +352-691-307-036' size: 11 bold: false).
	header addChild: (self receiptLabel: 'Code psychothérapeute : 530190-85' size: 11 bold: false).
	header addChild: (BlElement new size: 0@10).
	container addChild: header.
	
	"Patient info"
	patientBlock := BrVerticalPane new fitContent; padding: (BlInsets top: 10).
	patientBlock addChild: (self receiptLabel: self patient lastName , ' ' , self patient firstName size: 12 bold: true).
	patientBlock addChild: (self receiptLabel: (self patient address ifNil: [ '' ]) size: 11 bold: false).
	patientBlock addChild: (self receiptLabel: (self patient country ifNil: [ '' ]) , '-' , (self patient postalCode ifNil: [ '' ]) , ' ' , (self patient city ifNil: [ '' ]) size: 11 bold: false).
	patientBlock addChild: (self receiptLabel: 'Matricule : ' , (self patient matricule ifNil: [ '' ]) size: 11 bold: false).
	patientBlock addChild: (BlElement new size: 0@10).
	container addChild: patientBlock.
	
	"Receipt title"
	container addChild: (self receiptLabel: 'MÉMOIRE D''HONORAIRES    N° : ' , self receiptNumber , '  du : ' , (self formattedDate: self receiptDate) size: 12 bold: true).
	container addChild: (BlElement new size: 0@10).
	
	"Session table"
	tableBlock := BrVerticalPane new fitContent.
	tableBlock addChild: (self receiptTableRowLabels: #('#' 'Exécutant' 'Lieu' 'Date' 'Code' 'Montant') bold: true).
	self sessions doWithIndex: [ :s :i |
		tableBlock addChild: (self receiptTableRowLabels: {
			i printString padLeftTo: 2 with: $0.
			'530190-85'.
			'009'.
			self formattedDate: s date.
			s codeActe.
			(self formattedAmount: s amount) , ' €'
		} bold: false) ].
	tableBlock addChild: (BlElement new size: 0@5).
	tableBlock addChild: (self receiptTableRowLabels: { '' . '' . '' . '' . 'TOTAL' . (self formattedAmount: self total) , ' €' } bold: true).
	container addChild: tableBlock.
	
	"Footer"
	container addChild: (BlElement new size: 0@15).
	footerBlock := BrVerticalPane new fitContent.
	footerBlock addChild: (self receiptLabel: 'Pour acquit, le : ' , (self formattedDate: self receiptDate) size: 11 bold: false).
	footerBlock addChild: (BlElement new size: 0@5).
	footerBlock addChild: (self receiptLabel: 'IBAN : LU50 0141 6712 8510 0000' size: 11 bold: false).
	container addChild: footerBlock.
	
	^ container
]

{ #category : 'rendering' }
CbReceipt >> receiptLabel: aString size: aSize bold: aBoolean [
	| text |
	text := aString asRopedText fontSize: aSize.
	aBoolean ifTrue: [ text bold ].
	^ BrLabel new
		aptitude: BrGlamorousLabelAptitude;
		text: text
]

{ #category : 'accessing' }
CbReceipt >> receiptNumber [
	"Format: OC + YYYYMMDD"
	| d |
	d := self receiptDate.
	^ 'OC' , d year printString ,
		(d monthIndex printString padLeftTo: 2 with: $0) ,
		(d dayOfMonth printString padLeftTo: 2 with: $0)
]

{ #category : 'rendering' }
CbReceipt >> receiptTableRowLabels: anArray bold: aBoolean [
	"Build a horizontal row element for the receipt table"
	| row widths |
	widths := #(40 90 50 100 60 100).
	row := BrHorizontalPane new fitContent.
	anArray doWithIndex: [ :label :i |
		| lbl |
		lbl := BrLabel new
			aptitude: BrGlamorousLabelAptitude;
			text: (aBoolean
				ifTrue: [ label asRopedText bold fontSize: 11 ]
				ifFalse: [ label asRopedText fontSize: 11 ]);
			hExact: (widths at: i);
			vFitContent.
		row addChild: lbl ].
	^ row
]

{ #category : 'accessing' }
CbReceipt >> sessions [
	^ sessions
]

{ #category : 'accessing' }
CbReceipt >> sessions: aCollection [
	sessions := aCollection
]

{ #category : 'accessing' }
CbReceipt >> total [
	^ self sessions inject: 0 into: [ :sum :s | sum + s amount ]
]
