$("document").ready ->
	console.log("doc ready")

	$('a.remove-post').on 'click', (el) ->
		$this = $ this
		$.post '/post/remove/' + (($ this).data 'm-id'), (res) ->
			console.log($this.parents('article')) 
			$this.parents('article').animate {opacity: 0}, 250, ->
				($ @).remove()
