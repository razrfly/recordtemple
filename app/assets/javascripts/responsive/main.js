
//flex slider timings
var slideTime = 4000;
var animSpeed = 600;


// DOCUMENT READY
$(function() {
		
		
		//**********************************
        //NAV MENU
		//wp active menu item fix
		$('ul#nav li.current-menu-item').addClass('active');
		$('ul#nav ul li.current-menu-item').parents('li').addClass('active');
		
		$('ul#nav > li').addClass('first-level');
		$('ul#nav li').each(function() { if($(this).find('ul').length) $(this).addClass('has-sub'); });
        $('ul#nav li.first-level').hover(function() {
 
                var subMenu = $(this).find('div').length ? $(this).find('ul') : $(this).find('ul:first');
 				
                //if has sub menu
                if(subMenu.length) {
					
                    $(this).find('a').eq(0).addClass("selected");
                    subMenu.stop(true,true).slideDown(300,'easeOutQuad');
					
                }
            }, function(e) {  //hover out
					
                    var subMenu = $(this).find('div').length ? $(this).find('div') : $(this).find('ul:first');
                    subMenu.stop(true,true).delay(0).slideUp(150,'easeOutQuad');
                    $(this).find('a').eq(0).removeClass("selected");
					
                });
        //NAV MENU
        //**********************************
		
		
		// MOBIL NAV MENU - SELECT LIST
		//**********************************
		/* Clone our navigation */
		var mainNavigation = $('ul#nav').clone();
		
		/* Replace unordered list with a "select" element to be populated with options, and create a variable to select our new empty option menu */
		$('.header nav').prepend('<select class="menu"></select>');
		var selectMenu = $('select.menu');
		$(selectMenu).append('<option>'+"MENU"+'</option>');
		
		/* Navigate our nav clone for information needed to populate options */
		$(mainNavigation).children('li').each(function() {
		
			 /* Get top-level link and text */
			 var href = $(this).children('a').attr('href');
			 var text = $(this).children('a').text();
			
			 /* Append this option to our "select" */
			 $(selectMenu).append('<option value="'+href+'">'+text+'</option>');
			
			 /* Check for "children" and navigate for more options if they exist */
			 if ($(this).children('ul').length > 0) {
				$(this).children('ul').children('li').each(function() {
			
				   /* Get child-level link and text */
				   var href2 = $(this).children('a').attr('href');
				   var text2 = $(this).children('a').text();
			
				   /* Append this option to our "select" */
				   $(selectMenu).append('<option value="'+href2+'">--- '+text2+'</option>');
				});
			 }
		});
		
		/* When our select menu is changed, change the window location to match the value of the selected option. */
		$(selectMenu).change(function() {
			location = this.options[this.selectedIndex].value;
		});
		//**********************************
		
		
		
		// LIGHTBOX
		//**********************************
		if($("a[rel^='prettyPhoto']").length) {
			$("a[rel^='prettyPhoto']").prettyPhoto({
					theme: 'pp_default',
					social_tools:"",
					default_width: 800,
					default_height: 450
				});
		}
		//**********************************
		
		
		
		//**********************************
        // MEDIA BOX MASK
		$('.media-box').hover(function() {
					$(this).find('.mask').stop(true,true).fadeIn();
			},function() {
					$(this).find('.mask').stop(true,true).fadeOut();
				});
		//**********************************
		
		
		//**********************************
        // ACCORDION AND TOGGLES
		$('.accordion-group .accordion-toggle').click(function() {
				var parent = $(this).parents('.accordion-group');
				parent.siblings().removeClass('active').find('.accordion-body').stop(true,true).hide();
				if(!parent.hasClass('active')) {
					parent.addClass('active').find('.accordion-body').stop(true,true).fadeIn(500);
				} else { 
					parent.removeClass('active').find('.accordion-body').stop(true,true).hide();
				}
			});
		//**********************************
				
		
		
		//*************************************
		// VALIDATION
		if($('.validate-form').length) {
			$('.validate-form').each(function() {
					$(this).validate();
				});
		}
		//*************************************
		
		
		//**********************************
		// FLEX SLIDER
		// cache container
		var $slider = $('.flexslider');
		if($slider.length) {
			$slider.waitForImages(function() {
				
				$slider.addClass('ready').flexslider({
					  animation: "slide",
					  controlsContainer: ".flex-container", 
					  slideshowSpeed: slideTime,
					  animationDuration: animSpeed
				  });
				
			},null,true);
		}
		//**********************************
		
		
		//**********************************
		// PORTFOLIO FILTERING - ISOTOPE
		// cache container
		var $container = $('#portfolio');
		
		if($container.length) {
			$container.waitForImages(function() {
				
				// initialize isotope
				$container.isotope({
				  itemSelector : '.item',
				  layoutMode : 'fitRows'
				});
				
				// filter items when filter link is clicked
				$('#filters a').click(function(){
				  var selector = $(this).attr('data-filter');
				  $container.isotope({ filter: selector });
				  $(this).parent().addClass('current').siblings().removeClass('current');
				  return false;
				});
				
			},null,true);
		}
		//**********************************
		
		
		
	}); //end doc.load	
//*******************************	
