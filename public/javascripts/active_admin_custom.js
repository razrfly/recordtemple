$(document).ready(function() {
	var artist_id = $('.artist_freebase_id').text()
	$(".freebase_album")
		.suggest({
			type: "/music/album",
			mql_filter: [{"/music/album/artist": [{"id": artist_id}] }]
		})
		.bind("fb-select", function(e, data) {
		    $(".freebase_album_id").val(data.id);
		  });
		
	//alert(artist_id);
});