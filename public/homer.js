/* 	homer js
* 	requires jQuery 1.4
* 	by al shaw
**/

$(document).ready(function() {
	
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
});