Class {
	#name : #BMCall,
	#superclass : #ZnRestCall,
	#traits : 'CdRejectingAuthTrait',
	#classTraits : 'CdRejectingAuthTrait classTrait',
	#category : #'BuildMonitor-REST'
}

{ #category : #accessing }
BMCall class >> description: aSymbol [
^ self perform: (#description, aSymbol)
]

{ #category : #'as yet unclassified' }
BMCall class >> forRequest: request [
	| callPath requestPath parameters |
	requestPath := request uri segments.
	callPath := self function.
	(requestPath size = callPath size) ifFalse: [ 
		^ nil ].
	parameters := Dictionary new.
	requestPath with: callPath do: [ :requestPathSegment : callPathSegment |
		(callPathSegment first = ${)
			ifFalse: [ 
				(callPathSegment  = requestPathSegment )
					ifFalse: [ ^ nil ] ]
			ifTrue: [ parameters at: (callPathSegment copyFrom: 2 to: callPathSegment size - 1) put: requestPathSegment ] ].
	^ self new: parameters.
]

{ #category : #accessing }
BMCall class >> function [
	^ self subclassResponsibility 
]

{ #category : #accessing }
BMCall class >> implementedMethods [
	^ self usedHttpVerbs select: [ :method | self includesSelector: method asSymbol ]
]

{ #category : #accessing }
BMCall class >> isAbstract [ 
 ^ self = BMCall
]

{ #category : #accessing }
BMCall class >> new: aDict [
	| result |
	result := self new.
	aDict associations do: [ :pair |
		result instVarNamed: (pair key) put: (pair value)].
	^ result.
]

{ #category : #accessing }
BMCall class >> objectsForPragmas: aCollection [
	^ aCollection
		collect: [:each | each method valueWithReceiver: self arguments: #() ]
]

{ #category : #'as yet unclassified' }
BMCall class >> openApiPathParameter: aString [
^ OAParameter new
		name: aString;
		in: #path;
		beString;
		required: true.
]

{ #category : #'as yet unclassified' }
BMCall class >> parametersForMethod: aSymbol [
	^ self objectsForPragmas: ( self pragmas: #openApiParameter: includingMethod: aSymbol )
]

{ #category : #'as yet unclassified' }
BMCall class >> path [
	^ String
		streamContents: [ :s | 
			s nextPut: $/.
			RemoteConfigApi basePath asStringOn: s delimiter: '/'.
			s nextPut: $/.
			self function asStringOn: s delimiter: '/' ]
]

{ #category : #'as yet unclassified' }
BMCall class >> pathItem [
	| item |
	item := OAPathItem new.
	self implementedMethods do: [ :method | | capitalizedMethod |
		capitalizedMethod := method capitalized.
		(item operationAt: method)
			summary: (self summary: capitalizedMethod);
			description: (self description: capitalizedMethod);
			parameters: (self parametersForMethod: method);
			requestBody: (self requestBodyForMethod: method) ].
	^ item

]

{ #category : #'as yet unclassified' }
BMCall class >> pragmas: pragmaName includingMethod: aSymbol [
	^ (self openApiPragmasNamed: pragmaName) 
		select: [ :each | 
			each arguments first includesAny: { aSymbol . #common } ]
]

{ #category : #'as yet unclassified' }
BMCall class >> requestBodyForMethod: aSymbol [

	| body pragmas |
	pragmas := (self pragmas: #openApiRequestBody:contentType: includingMethod: aSymbol)
		ifEmpty: [ ^ nil ].
	
	body := OARequestBody new.
	body required: true.
	pragmas do: [ :pragma | | mediaObject |
		mediaObject := pragma method valueWithReceiver: self arguments: #().
		pragma arguments second do: [ :contentType | 
			body
				contentAt: contentType 
				put: mediaObject ] ].
	^ body
]

{ #category : #'as yet unclassified' }
BMCall class >> summary: aSymbol [
^ self perform: (#summary, aSymbol)
]

{ #category : #'as yet unclassified' }
BMCall class >> usedHttpVerbs [
	^ #( #get #post )
]

{ #category : #execution }
BMCall >> execute [
	"execution of the api call"
	^ [ self authorize: request.
		(self respondsTo: self method)	
		ifTrue: [ 
			self perform: self method.
			response ] 
		ifFalse: [ self wrongMethod: request ]
		] on: Exception 
		do: [ :err | self handleError: err ]
]

{ #category : #private }
BMCall >> handleError: anError [
	anError inspect.
	^ delegate errorResponse: nil code: (anError znErrorCode) message: (anError znErrorMessage).
]

{ #category : #accessing }
BMCall >> jsonRequest [
	^ (self request contentType matches: ZnMimeType applicationJson)
		ifTrue: [
			NeoJSONReader fromString: self request contents ]
		ifFalse: [
			JSONError signal: 'JSON content expected.' ]
]

{ #category : #private }
BMCall >> wrongMethod: aRequest [
	^ delegate errorResponse: aRequest code: 400 message: 'Unsupported method used.'
]
