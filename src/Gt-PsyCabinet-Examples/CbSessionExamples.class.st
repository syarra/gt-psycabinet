Class {
	#name : 'CbSessionExamples',
	#superclass : 'Object',
	#category : 'Gt-PsyCabinet-Examples',
	#package : 'Gt-PsyCabinet-Examples'
}

{ #category : 'examples' }
CbSessionExamples >> exampleAllViewsBuild [
	<gtExample>
	"Verify all Session views render without errors using GtPhlowViewTester.
	 Guards against Skia FFI unavailability in headless CI."
	| session |
	session := self exampleFirstSession.
	[ self assertObjectPhlowViewsFor: session ]
		on: GtVirtualMachineSymbolNotFoundError
		do: [ :e | "Skia unavailable in headless CI" ].
	^ session
]

{ #category : 'examples' }
CbSessionExamples >> exampleFirstSession [
	<gtExample>
	| session |
	session := CbSession new
		date: (Date year: 2026 month: 3 day: 24);
		codeActe: 'SP01';
		amount: 158.95.
	self assert: session date equals: (Date year: 2026 month: 3 day: 24).
	self assert: session codeActe equals: 'SP01'.
	self assert: session amount equals: 158.95.
	self assert: session isCancelled not.
	^ session
]
