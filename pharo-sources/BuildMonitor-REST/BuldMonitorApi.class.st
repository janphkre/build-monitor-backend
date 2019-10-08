Class {
	#name : #BuldMonitorApi,
	#superclass : #OpenAPI,
	#category : #'BuildMonitor-REST'
}

{ #category : #'initialize-release' }
BuldMonitorApi class >> delegate: versionString [
	^ (BuildMonitorServerDelegate new
			uriSpace: (BMUriSpace versioned: versionString))
]

{ #category : #accessing }
BuldMonitorApi class >> rootCallClass [
	^ BMCall
]

{ #category : #accessing }
BuldMonitorApi >> openapi [
	 ^ '3.0.2'
]
