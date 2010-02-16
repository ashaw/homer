/*  homer js
*   by al shaw
*   requires jQuery 1.4
* 	
**/

$(document).ready(function() {
	
	//ajax spinner
	$("#loading")
	.ajaxStart(function() {	
		$(this).fadeIn();
	})
	.ajaxStop(function() {
		$(this).fadeOut()
	});
	
	function clearHomepageMenu() {
		$("#feeds_menu > *").hide()
	}

	$("li.add_feed a").click(function() {
		clearHomepageMenu();
		$("#feeds_menu").toggle();
		$("#feeds_submen").show();
		return false;
	});
	$("li.add_slot a").click(function() {
		clearHomepageMenu();
		$("#feeds_menu").toggle();
		$(".slot_form").show()
		return false;
	});

	// refresh feeds
	
		$("#feed_list ul li a").each(function() {
			$(this).click(function() {
				$("#fresh_stories_container").show();
				var ids = $(this).attr('class').split(' ');
				var hpid = ids[0]
				var fid = ids[1]
				$.get("/feeds/"+hpid+"/"+fid, function(newstories) {
					$("#story_list ul#fresh_stories").prepend(newstories);
				});
			return false;
			});
		});

		$("ul#assigned_stories li a.showbody").each(function() {
			$(this).click(function() {
				$(this).next(".story_body").toggle();
				return false;
			});
		});
		
	//destroy confirm
	
	$(".destroy").live('click', function(event) {
		if ( confirm("Are you sure you want to delete this?") )
			window.location.replace(this.attr('href'));
		return false;
	});

}); //dom ready