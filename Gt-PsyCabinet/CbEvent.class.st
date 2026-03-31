Class {
	#name : 'CbEvent',
	#superclass : 'Object',
	#instVars : [
		'timestamp'
	],
	#category : 'Gt-PsyCabinet',
	#package : 'Gt-PsyCabinet'
}

{ #category : 'applying' }
CbEvent >> applyOn: aCabinetManager [
	self subclassResponsibility
]

{ #category : 'initialization' }
CbEvent >> initialize [
	timestamp := DateAndTime now
]

{ #category : 'accessing' }
CbEvent >> timestamp [
	^ timestamp
]

{ #category : 'accessing' }
CbEvent >> timestamp: aDateAndTime [
	timestamp := aDateAndTime
]
