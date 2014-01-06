# The MIT License (MIT)

# Copyright (c) 2013 Goran Sterjov

# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

root = exports ? this

class root.TastyResourceFactory

	constructor: (@$http, @_config)->
		@_config.cache ||= false
		@_resolved = true


	queryURL: (url, parameters, success, error)->
		results = []

		# construct the filter params
		params = []
		for attr, value of parameters
			params.push "#{attr}=#{value}"

		url = "#{url}?#{params.join('&')}" if params.length > 0

		@_resolved = false
		promise = @$http.get url, cache: @_config.cache

		promise.then (response)=>
			if response.data.objects?
				for object in response.data.objects
					results.push @_create_resource(object)

				results.meta = response.data.meta
			else
				angular.copy(response.data, results)

		promise.then ()=> @_resolved = true
		promise.then success, error
		results


	query: (filter, success, error)->
		@queryURL @_config.url, filter, success, error


	get: (id, success, error)->
		url = @_get_detail_url id
		resource = new TastyResourceFactory(@$http, @_config)

		@_resolved = false
		promise = @$http.get url, cache: @_config.cache

		promise.then (response)=>
			for key, value of response.data
				resource[key] = value

		promise.then ()=> @_resolved = true
		promise.then success, error
		return resource


	post: ()->
		@_resolved = false
		promise = @$http.post @_config.url, @_get_data()
		promise.then ()=> @_resolved = true
		promise.success (response, status, headers)=> @_config.detail_url = headers("Location")
		return promise


	put: (id)->
		url = @_get_detail_url id

		@_resolved = false
		promise = @$http.put url, @_get_data()
		promise.then ()=> @_resolved = true
		return promise


	patch: (id)->
		url = @_get_detail_url id

		@_resolved = false
		promise = @$http method: "PATCH", url: url, data: @_get_data()
		promise.then ()=> @_resolved = true
		return promise


	resolved: ()->
		@_resolved


	_get_detail_url: (id)->
		url = @_config.url
		id = @id if not id?

		# if id has a leading slash then assume its a resource URI
		if id and id[0] is "/"
			@_config.detail_url = id
		else
			@_config.detail_url = "#{@_config.url}#{id}/"

		return @_config.detail_url


	_get_data: ()->
		data = {}

		# get the resource data
		for attr, value of @
			# filter out class features
			if typeof value != "function" and attr[0] not in ["$", "_"]
				# use the resource uri if the value is another resource
				if value instanceof TastyResourceFactory
					data[attr] = value.resource_uri
				else
					data[attr] = value

		return data


	_create_resource: (data)->
		resource = new TastyResourceFactory(@$http, @_config)
		for key, value of data
			resource[key] = value

		return resource



module = angular.module("tastyResource", [])

module.factory "TastyResource", ["$http", ($http)->
	(config)->
		new TastyResourceFactory($http, config)
]