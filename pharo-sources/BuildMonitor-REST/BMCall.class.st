Class {
	#name : #BMCall,
	#superclass : #ZnRestCall,
	#category : #'BuildMonitor-REST'
}

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

{ #category : #'error handling' }
BMCall >> wrongMethod: aRequest [
	^ delegate errorResponse: aRequest code: 400 message: 'Unsupported method used.'
]
