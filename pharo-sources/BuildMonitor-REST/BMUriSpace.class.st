Class {
	#name : #BMUriSpace,
	#superclass : #ZnRestUriSpace,
	#instVars : [
		'basePath'
	],
	#category : #'BuildMonitor-REST'
}

{ #category : #'as yet unclassified' }
BMUriSpace class >> versioned: versionString [
	^ (self new) version: versionString; yourself.
]

{ #category : #accessing }
BMUriSpace >> basePath [
	^ basePath
]

{ #category : #accessing }
BMUriSpace >> match: request [
	|requestSegments baseSegments |
	requestSegments := request uri segments.
	baseSegments := self basePath.
	baseSegments withIndexDo: [ :baseSegment :index | 
		(baseSegment = (requestSegments at: index)) ifFalse: [ ^ nil ] ].
	
	requestSegments removeFirst: (baseSegments size).
	request uri segments: requestSegments.
	
	(BMCall allSubclasses reject: #isAbstract)
		do: [ :callClass |
			(callClass forRequest: request) ifNotNil: [ :item |
				^ item ] ].
	^ nil
]

{ #category : #versions }
BMUriSpace >> version: aString [
	basePath :=  { 'api'. aString }
]
