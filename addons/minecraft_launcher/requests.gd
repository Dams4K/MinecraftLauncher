class_name Requests
extends Node
## [br]
## Original code by winston-yallow (ty)
## [br]
## https://gist.github.com/winston-yallow/be5240784b9928d82a0a40b0d3b805b4
## [br]
## [br]
## A small script to dynamically create web requests and await their result.
## [br]
## The API is in parts inspired by the python module [code]httpx[/code].
## [br]
## Usage:
##     [codeblock]
##     var requests: Requests = $Requests
##     var response := requests.do_get("https://catfact.ninja/fact")
##     if response.result == Requests.RESULT.SUCCESS:
##         print(response.json())
##     [/codeblock]


enum Result {
	SUCCESS,  ## The response exists (HTTP status code is not checked). The [member code] represents the HTTP status code.
	REQUEST_ERROR,  ## The request could not be started. The [member code] is a [enum @GlobalScope.Error]
	RESULT_ERROR  ## The request failed. The [member code] is a [enum HTTPRequest.Result]
}


## Response object returned by [Requests].
class Response extends RefCounted:
	
	## A [enum Requests.Result] value indicating the success or error type of the response
	var result: Result = Result.SUCCESS
	
	## The meaning of the code varies depending on the [member result]. It will
	## either be a HTTP status code or an error code.
	var code: int = OK
	
	## The response headers (only available when the request was successful)
	var headers: PackedStringArray
	
	## The response body (only available when the request was successful)
	var body: PackedByteArray
	
	
	## Static method to create a response object from a request error code
	static func request_error(error_code: int) -> Response:
		var r := Response.new()
		r.result = Result.REQUEST_ERROR
		r.code = error_code
		return r
	
	
	## Static method to create a response object from a response error code
	static func result_error(error_code: int) -> Response:
		var r := Response.new()
		r.result = Result.RESULT_ERROR
		r.code = error_code
		return r
	
	
	## Static method to create a response object from a successful http request
	static func success(
			response_code: int,
			response_headers: PackedStringArray,
			response_body: PackedByteArray
	) -> Response:
		var r := Response.new()
		r.result = Result.SUCCESS
		r.code = response_code
		r.headers = response_headers
		r.body = response_body
		return r
	
	
	## Converts the body to a string. Assumes UTF8.
	func text() -> String:
		return body.get_string_from_utf8()
	
	
	## Converts the body to a GDScript object. Assumes a valid UTF8 JSON body.
	func json() -> Variant:
		var j = JSON.new()
		j.parse(text())
		return j.data


## Performs an asynchronous web request using threads.
## The arguments have the same meaning as in [method HTTPRequest.request].
## [br]
## [br]
## [b]Attention:[/b] this uses a different order of arguments!
## [br]
## This is done to put more commonly used arguments first.
func do(
		url: String,
		data := "",
		headers := PackedStringArray(),
		method := HTTPClient.METHOD_GET,
		download_file := ""
) -> Response:
	var http_request := HTTPRequest.new()
	add_child(http_request)
	http_request.use_threads = true
	http_request.accept_gzip = true
	http_request.download_file = download_file
	
	var err := http_request.request(url, headers, method, data)
	if err != OK:
		return Response.request_error(err)
	# Since we use threads, we can be sure that the completed signal
	# is called deferred. This means that we can safely await the signal
	# without worrying if it may already completed.
	var results = await http_request.request_completed
	http_request.queue_free()
	if results[0] != HTTPRequest.RESULT_SUCCESS:
		return Response.result_error(results[0]) 
	return Response.success(results[1], results[2], results[3])


## The same as [method do] but performs a hardcoded [code]GET[/code] request.
## This method exists purely for convenience.
func do_get(url: String, data := "", headers := PackedStringArray()) -> Response:
	return await do(url, data, headers, HTTPClient.METHOD_GET)


## The same as [method do] but performs a hardcoded [code]POST[/code] request.
## This method exists purely for convenience.
func do_post(url: String, data := "", headers := PackedStringArray()) -> Response:
	return await do(url, data, headers, HTTPClient.METHOD_POST)


## The same as [method do] but performs a hardcoded [code]PUT[/code] request.
## This method exists purely for convenience.
func do_put(url: String, data := "", headers := PackedStringArray()) -> Response:
	return await do(url, data, headers, HTTPClient.METHOD_PUT)


## The same as [method do] but performs a hardcoded [code]PATCH[/code] request.
## This method exists purely for convenience.
func do_patch(url: String, data := "", headers := PackedStringArray()) -> Response:
	return await do(url, data, headers, HTTPClient.METHOD_PATCH)


## The same as [method do] but performs a hardcoded [code]DELETE[/code] request.
## This method exists purely for convenience.
func do_delete(url: String, data := "", headers := PackedStringArray()) -> Response:
	return await do(url, data, headers, HTTPClient.METHOD_DELETE)

func do_file(url: String, download_file: String, data := "", headers := PackedStringArray()) -> Response:
	return await do(url, data, headers, HTTPClient.METHOD_GET, download_file)
