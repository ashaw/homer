/* 	homer js
* 	requires jQuery 1.4
* 	by al shaw
**/

$(document).ready(function() {
	
	//ajax spinner
	$("#loading")
	.ajaxStart(function() {	
		$(this).show();
	})
	.ajaxStop(function() {
		$(this).hide()
	});
	
	function clearHomepageMenu() {
		$("#feeds_menu > *").hide()
	}

	$("li.add_feed a").click(function() {
		clearHomepageMenu();
		$("ul.feeds_menu").toggle();
		return false;
	});
	$("li.add_slot a").click(function() {
		clearHomepageMenu();
		$(".slot_form").toggle()
		return false;
	});


// do this statically for now
	
// 	$("ul.feeds_menu li").each(function() {
// 		var classes = $(this).attr('class').split(' ');	
// 		var hpid = classes[0];
// 		var fid = classes[1];
// 		
// 			$(this).click(function() {
// 				$.post("/hpfeed/new", { hpid: hpid, fid: fid } );
// 			return false;
// 			});
// 	});

	// refresh feeds
	
		$("#feed_list ul li a").each(function() {
			$(this).click(function() {
				var ids = $(this).attr('class').split(' ');
				var hpid = ids[0]
				var fid = ids[1]
				$.get("/feeds/"+hpid+"/"+fid, function(newstories) {
					$("#story_list ul#fresh_stories").prepend(newstories);
				});
			return false;
			});
		});
		
}); //dom ready