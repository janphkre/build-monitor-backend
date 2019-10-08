Class {
	#name : #BaselineOfBuildMonitor,
	#superclass : #BaselineOf,
	#category : #BaselineOfBuildMonitor
}

{ #category : #baselines }
BaselineOfBuildMonitor >> baseline: spec [
	<baseline>
	spec
		for: #common
		do:
			[ 
			spec baseline: 'ZincHTTPComponents' with: [
						spec
							loads: #('REST');
							repository: 'github://zweidenker/zinc/repository' ].
			spec baseline: 'OpenAPI' with: [
						spec
							loads: #('REST');
							repository: 'github://zweidenker/OpenAPI/source' ];
					project: 'OpenAPI-Core' copyFrom: 'OpenAPI' with: [ 
						 spec loads: 'Core'].
			spec baseline: 'cadmium' with: [
						spec
							loads: #('default');
							repository: 'github://janphkre/cadmium/src' ].
			spec package: 'BuildMonitor-REST' with:[spec requires: #('ZincHTTPComponents' 'OpenAPI-Core' 'cadmium')].
			spec package: 'BuildMonitor-Tests' with:[spec requires: #('core')].

			spec
				group: 'core' with: #('BuildMonitor-REST');
				group: 'tests' with: #('BuildMonitor-Tests');
				group: 'default' with: #('core')
			]
]
