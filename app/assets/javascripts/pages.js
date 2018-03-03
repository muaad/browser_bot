$(function() {
	$('#breakString').click(function(e) {
		e.preventDefault()
		$.ajax({
		  type: "POST",
		  url: '/break_strings',
		  dataType: 'json',
		  data: {text: $('#stringToBreak').val()},
		  success: function(data, textStatus, jqXhr) {
		  	var h = ''
		  	for (var i = 0; i < data.strings.length; i++) {
		  		h += data.strings[i] + '<hr>'
		  		console.log(h)
		  	}
		  	$(".well").html(h)
		  }
		});
	})
})