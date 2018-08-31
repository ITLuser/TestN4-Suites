/*Ticket 4074 script to set a pixel proportional flex after initial sizing*/
zk.afterLoad('zk', function() {
	function initMakeProportional(wgt) {
		var listener = function(evt) {
			wgt.unlisten({onAfterSize: listener});
			setTimeout(function() {
				var width = jq(wgt).outerWidth();
				//setting this directly avoids multiple inital resizing overhead
				wgt._hflex = width;
				wgt.setHflex_(width);
			}, 100);
		};
		wgt.listen({onAfterSize: listener});
	}
	
	var xWidget = {};
	zk.override(zk.Widget.prototype, xWidget ,{
		bind_ : function() {
			if(this.makeProportional) {
				initMakeProportional(this);
			}
			return xWidget.bind_.apply(this, arguments);
		}
	});//zk.override
});//zk.afterLoad

/**
 * Snap back the widget (floating window in our case) to the initial size when drag-resized to be bigger.
 * @param wgt
 */
function limitSize(wgt) {
	var $wgt = jq(wgt);
	console.log(wgt);
	$wgt.css({
		'max-width': jq.px($wgt.outerWidth()),
		'max-height': jq.px($wgt.outerHeight())
	});
	window.addEventListener('resize', function () {
		$wgt.css({
			'width': '',
			'height': '',
			'max-width': '',
			'max-height': ''
		});
		zUtl.fireSized(wgt);
		setTimeout(function () {
			$wgt.css({
				'max-width': jq.px($wgt.outerWidth()),
				'max-height': jq.px($wgt.outerHeight())
			});
		}, 0);
	}, true);
}
