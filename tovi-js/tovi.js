/**
 * @author: ideawu
 * @link: http://www.ideawu.com/
 * Tovi - A JavaScript image gallery and html slider, with iPhone swipe effect.
 */
function ToviViewer(){
	var self = this;
	self.dom = null;
	self.tovi = null;
	self.left = 0;
	self.top = 0;
	self.width = 0;
	self.height = 0;
	
	self.cell_padding = 100;
	self.cell_padding_color = '#ff3';
	// an odd interger, should be equal or greater than 3
	// TODO:
	self.offscreen_size = 11;
	
	self.index = 0;
	self.cells = [];
	var last_pos = {x: 0, y: 0};

	self.onchange = function(index, cell){}
	
	self._onchange = function(){
		self.onchange(self.index, self.cells[self.index]);
	}
	
	function intval(v){
		return parseInt(v, 10) || 0;
	}
	
	function Cell(width, height){
		this.type = null;
		this.dom = null;
		this.url = '';
		this.title = '';
		this.content = null;
		this.left = 0;
		this.top = 0;
		this.origin_width = width;
		this.origin_height = height;
		this.width = width;
		this.height = height;
		this.inited = false;

		this.overflow = function(){
			if(this.is_image() || this.type == 'video'){
				return (this.width > self.width || this.height > self.height);
			}else{
				return (this.width > self.width || this.height > self.height);
			}
		}
		this.scaled = function(){
			if(this.is_image() || this.type == 'video'){
				return (this.width > this.origin_width || this.height > this.origin_height);
			}else{
				return false;
			}
		}
		this.is_image = function(){
			return this.type == 'img';
		}
		this.autosize = function(){
			// all img elements in a text cell must provide width and height attributes
			// or here will get the wrong size
			this.content.css({
				margin: 0,
				padding: 0,
				width: 'auto',
				height: 'auto'
			});
			this.origin_width = this.content.width();
			this.origin_height = this.content.height();
			this.width = Math.min(self.width, this.origin_width);
			this.height = Math.min(self.height, this.origin_height);
		}
		this.centerX = function(){
			this.left = intval((self.width - this.width)/2);
		}
		this.centerY = function(){
			this.top = intval((self.height - this.height)/2);
		}
		this.center = function(){
			this.centerX();
			this.centerY();
		}
		this.isCenterX = function(){
			var r = Math.abs(this.left / ((self.width - this.width)/2));
			// %15 of width or 10 pixels
			return Math.abs(1-r) < 0.15 || Math.abs(self.width - this.width) < 10;
		}
		this.isCenterY = function(){
			var r = Math.abs(this.top / ((self.height - this.height)/2));
			return Math.abs(1-r) < 0.15 || Math.abs(self.height - this.height) < 10;
		}
		this.isCenter = function(){
			return this.isCenterX() && this.isCenterY();
		}
		this.autocenter = function(){
			var r = Math.abs(this.left / ((self.width - this.width)/2));
			if(this.isCenterX()){
				this.centerX();
			}
			if(this.isCenterY()){
				this.centerY();
			}
		}
		this.scale = function(rate){
			if(Math.abs(this.width * rate - this.width) < 1){
				//return;
			}
			var a = this.height;
			this.width = this.width * rate;
			this.height = this.origin_height * this.width/this.origin_width;
			if(rate > 1){
				this.width = Math.ceil(this.width);
				this.height = Math.ceil(this.height);
			}else{
				this.width = Math.floor(this.width);
				this.height = Math.floor(this.height);
			}
		}
		this.autodock = function(){
			var thresh = 6;
			if(Math.abs(self.width - this.width) < thresh){
				var nw = self.width;
				var nh = intval(this.origin_height * nw/this.origin_width);
				this.width = nw;
				this.height =  nh;
			}else if(Math.abs(self.height - this.height) < thresh){
				var nh = self.height;
				var nw = intval(this.origin_width * nh/this.origin_height);
				this.width = nw;
				this.height =  nh;
			}
		}
		this.bestsize = function(){
			var w = this.origin_width;
			var h = this.origin_height;
			if(w == 0 || h == 0){
				return;
			}
			if(self.width/self.height > this.origin_width/this.origin_height){
				var nh = Math.min(self.height, h);
				var nw = intval(this.origin_width * nh/this.origin_height);
			}else{
				var nw = Math.min(self.width, w);
				var nh = intval(this.origin_height * nw/this.origin_width);
			}
			this.width = Math.min(self.width, nw);
			this.height =  Math.min(self.height, nh);
		}
		this.fillsize = function(){
			var w = this.width;
			var h = this.height;
			if(w == 0 || h == 0){
				return;
			}
			if(self.width/self.height > this.origin_width/this.origin_height){
				var nh = self.height;
				var nw = intval(this.origin_width * nh/this.origin_height);
			}else{
				var nw = self.width;
				var nh = intval(this.origin_height * nw/this.origin_width);
			}
			this.width = Math.min(self.width, nw);
			this.height =  Math.min(self.height, nh);
		}
		this.actualsize = function(){
			this.width = this.origin_width;
			this.height = this.origin_height;
		}
		this.build_title = function(index){
			if(this.content.attr('title')){
				this.title = this.content.attr('title');
			}else if(this.is_image()){
				if(this.url.lastIndexOf('/') == -1){
					this.title = this.url;
				}else{
					this.title = decodeURIComponent(this.url.substr(this.url.lastIndexOf('/') + 1));
				}
			}
			if(!this.title){
				this.title = '' + (index + 1);
			}
			this.content.removeAttr('title');
		}
		this.init = function(index){
			this.inited = true;
			if(!this.is_image()){
				this.build_title(index);
			}else{
				this.content = $('<img src="' + this.url + '" />');
				this.build_title(index);
				// the exact way to get image width and height
				var ni = new Image();
				ni.index_ = index;
				ni.onload = function(){
					var index = this.index_;
					var cell = self.cells[index];
					cell.origin_width = this.width;
					cell.origin_height = this.height;
					cell.width = this.width;
					cell.height = this.height;
					cell.bestsize();
					if(index == self.index){
						//self.seek(index);
						self.layout();
					}else{
						cell.layout();
					}
				}
				ni.src = this.url;
			}
		}
		this.move = function(dx, dy){
			this.left += dx;
			this.top += dy;
			this.layout();
		}
		this.layout = function(){
			var cell = this;
			cell.content.css({
				position: 'absolute',
				margin: 0,
				padding: 0,
				border: 0
			});
			if(cell.is_image() || cell.type == 'video'){
				var cursor = 'auto';
				if(cell.overflow()){
					cursor = 'move';
				}else{
					cell.center();
				}
				cell.content.css({
					cursor: cursor,
					width: cell.width,
					height: cell.height,
					top: cell.top,
					left: cell.left
				});
			}else{
				cell.autosize();
				cell.top = intval((self.height - cell.height - 2*intval(cell.content.css('borderLeftWidth')))/2);
				cell.left = intval((self.width - cell.width - 2*intval(cell.content.css('borderTopWidth')))/2);
				cell.content.css({
					width: self.width - 2*cell.left - 2*intval(cell.content.css('borderLeftWidth')),
					height: self.height - 2*cell.top - 2*intval(cell.content.css('borderTopWidth')),
					margin: 0,
					paddingTop: cell.top,
					paddingBottom: cell.top,
					paddingLeft: cell.left,
					paddingRight: cell.left
				});
				//cell.content[0].scrollHeight
			}
		}
	} // end sell
	
	self.next = function(step){
		step = step || 1;		
		self.seek(self.index + step);
	}
	
	self.prev = function(step){
		step = step || 1;		
		self.seek(self.index - step);
	}
	
	self.seek = function(index, animation){
		//debug('queue', self.tovi.queue('fx').length);
		if(!self.cells.length){
			return;
		}
		var animate_speed = (animation==undefined||animation)? 400 : 0;
		if(index < 0){
			self.tovi.queue('fx', []).stop().animate({
				left: self.cell_padding > 0? 0 : 50
			}, animate_speed/2, function(){
				self.seek(0);
			});
			return;
		}
		if(index >= self.cells.length){
			var left = self.offset(self.cells.length - 1) + self.cell_padding;
			if(self.cell_padding == 0){
				left += 50;
			}
			self.tovi.queue('fx', []).stop().animate({
				left: -left
			}, animate_speed/2, function(){
				self.seek(self.cells.length - 1);
			});
			return;
		}

		self.index = index;
		self.left = -self.offset(self.index);
		
		self.layout(false);
		self.tovi.queue('fx', []).stop().animate({
			left: self.left
		}, animate_speed, function(){
			self.layout();
		});
	}

	self.layout = function(fix_position){
		self.left = -self.offset(self.index);
		if(fix_position !== false){
			self.tovi.css({
				left: self.left
			});
		}
		self.dom.width(self.width).height(self.height);
		var width = self.offset(self.cells.length);
		var height = self.height;
		self.tovi.css({
			width: width,
			height: height
		});

		self.tovi.html('');
		var si = self.index - intval(self.offscreen_size/2);
		var ei = self.index + intval(self.offscreen_size/2);
		for(var i=0; i<self.cells.length; i++){
			var cell = self.cells[i];
			if(i < si || i > ei){
				// browser should free memory if we clear DOM elements?
				/*
				cell.dom.empty();
				if(cell.is_image()){
					//cell.content = null;
				}
				*/
				continue;
			}
			if(cell.raw === true){
				var ele = cell.e;
				cell = new Cell(self.width, self.height);
				self.cells[i] = cell;
				
				cell.type = $(ele)[0].tagName.toLowerCase();
				if(cell.is_image()){
					// the caller replace src attribute with tovi_src, to achieve lazy load of the image
					cell.url = $(ele).attr('tovi_src') || $(ele).attr('src');
					//cell.content.removeAttr('tovi_src');
					//cell.content.removeAttr('src');
				}else{
					cell.content = $(ele);
				}
			}
			
			cell.dom = $('<div class="tovi_cell"></div>');
			cell.dom.css({
				position: 'absolute',
				overflow: 'hidden',
				width: self.width,
				height: self.height,
				left: self.offset(i)
			});
			cell.dom.html(cell.content);
			self.tovi.append(cell.dom);

			if(!cell.inited){
				cell.init(i);
			}
			cell.layout();
			//cell.content.hide().fadeIn(150)
		}
		if(self.cells){
			self._onchange();
		}
	}
	
	self.scale = function(delta, e){
		var cell = self.cells[self.index];
		// only allow to scale images and video
		if(!cell.is_image() && cell.type != 'video'){
			return;
		}
		// get focus point of the image
		if(e && e.clientX != undefined && cell.overflow()){
			var fx = e.clientX - cell.left - intval(self.dom.offset().left);
			var fy = e.clientY - cell.top - intval(self.dom.offset().top);
		}else{
			var fx = cell.width/2;
			var fy = cell.height/2;
		}
		//debug(e.clientX, e.clientY, fx, fy);
		
		var ow = cell.width;
		var oh = cell.height;
		cell.width = intval(Math.max(20, cell.width * (delta + 1)));
		cell.height = intval((cell.width/cell.origin_width) * cell.origin_height);
		
		if(cell.overflow()){
			var dx = cell.width - ow;
			var dy = cell.height - oh;
			cell.top = intval(cell.top - dy*(fy/oh));
			cell.left = intval(cell.left - dx*(fx/ow));
		}
		cell.autodock();
		cell.layout();
		self._onchange();
	}

	self.resize = function(width, height){
		width = intval(width);
		height = intval(height);
		var dx = width - self.width;
		var dy = height - self.height;
		var old = [];
		for(var i=0; i<self.cells.length; i++){
			var cell = self.cells[i];
			if(cell.raw === true){
				continue;
			}
			old[i] = {
				scaled: cell.scaled? cell.scaled() : false,
				overflow: cell.overflow? cell.overflow() : false
			};
		}
		var old_width = self.width;
		var old_height = self.height;
		self.width = width;
		self.height = height;
		
		for(var i=0; i<self.cells.length; i++){
			var cell = self.cells[i];
			if(cell.raw === true){
				continue;
			}
			if((cell.is_image && cell.is_image()) || cell.type == 'video'){
				if(dx > 0){
					if(cell.left < self.width - (cell.left + cell.width)){
						var m = cell.left;
						cell.left += intval(dx/2);
						if(m <= 0 && cell.left > 0 && cell.width >= self.width){
							cell.left = 0;
						}
					}else{
						//
					}
				}else{
					if(cell.left < self.width - (cell.left + cell.width)){
						//
					}else{
						cell.left += intval(dx/2);
					}
				}
				if(dy > 0){
					if(cell.top < self.height - (cell.top + cell.height)){
						var m = cell.top;
						cell.top += intval(dy/2);
						if(m <= 0 && cell.top > 0 && cell.height >= self.height){
							cell.top = 0;
						}
					}else{
						//
					}
				}else{
					if(cell.top < self.height - (cell.top + cell.height)){
						//
					}else{
						cell.top += intval(dy/2);
					}
				}
								
				// 1. scale
				if(cell.height == old_height && cell.width <= old_width ||
						cell.width == old_width && cell.height <= old_height
				){
					cell.fillsize();
				}else if(old[i].overflow != cell.overflow()){
					cell.fillsize();
				}else if(!old[i].overflow && !cell.overflow()){
					if(old[i].scaled){
						var ow = cell.width;
						var oh = cell.height;
						cell.scale(self.width / old_width);
						if(!cell.scaled()){
							cell.width = ow;
							cell.height = oh;
						}
					}
				}
				
				// 2. do some auto positioning
				cell.autodock();
				cell.autocenter();
				
				// 3. fix
				if(!old[i].scaled && cell.scaled()){
					cell.bestsize();
				}
				if(old[i].overflow != cell.overflow()){
					cell.fillsize();
				}
			}
		}
		self.layout();
	}

	self.move = function(dx){
		dx = intval(dx);
		self.left += dx;
		if(self.left > 0){
			self.left = 0;
		}
		self.left = Math.max(self.left, -self.offset(self.cells.length-1) - self.cell_padding);
		self.left = Math.min(0, self.left);
		self.tovi.css({
			left: self.left
		});
		var index = calc_index();
		if(index >= 0 && index < self.cells.length){
			self.onchange(index, self.cells[index]);
		}
		return index;
	}
	
	function move_cell(e){
		return move(e, 1);
	}
	
	function move_content(e){
		return move(e, 2);
	}
	
	function move(e, type){
		var x = e.pageX;
		if(last_pos.x == 0){
			last_pos.x = x;
		}
		var y = e.pageY;
		if(last_pos.y == 0){
			last_pos.y = y;
		}
		var dx = x - last_pos.x;
		var dy = y - last_pos.y;

		if(type == 1){
			self.move(dx);
		}else{
			var cell = self.cells[self.index];
			cell.move(dx, dy);
		}
		last_pos.x = x;
		last_pos.y = y;
	}
	
	function move_end(){
		var index = calc_index();
		self.layout(false);
		self.seek(index);
	}
	
	self.offset = function(index){
		return index * (self.cell_padding + self.width) + self.cell_padding;
	}
	
	function calc_index(){
		var thresh = self.width * 1/3;
		var cell_width = self.cell_padding + self.width;
		var last_margin = -self.offset(self.index);
		
		var delta = self.left - last_margin;
		var skip = intval(Math.abs(delta) / cell_width);
		if(intval(Math.abs(delta) % cell_width) > thresh){
			skip += 1;
		}
		if(skip > 0 && delta < 0){
			//debug(delta, (self.index + 1) + ' + ' + skip, 'curr=' + self.left, 'last=' + last_margin);
			return self.index + skip;
		}else if(skip > 0 && delta > 0){
			//debug(delta, (self.index + 1) + ' - ' + skip, 'curr=' + self.left, 'last=' + last_margin);
			return self.index - skip;
		}else{
			return self.index;
		}
	}
	
	function init_drag(){
		self.dom.on('dragstart', function(e){e.preventDefault();});
		self.dom.bind('mousedown', function(e){
			var cell = self.cells[self.index];
			if(!cell.overflow() || e.target.tagName.toLowerCase() == 'div'){
				self.dom.bind('mousemove', move_cell);
			}else{
				self.dom.bind('mousemove', move_content);
			}
			
			self.dom.bind('mouseup mouseleave', function(e){
				if(e.type == 'mouseleave'){
					var offset = self.dom.offset();
					if(e.pageX > offset.left && e.pageX < offset.left + self.dom.width()
						&& e.pageY > offset.top && e.pageY < offset.top + self.dom.height()){
						return;
					}
				}
				last_pos = {x: 0, y: 0};
				self.dom.unbind('mousemove', move_cell);
				self.dom.unbind('mousemove', move_content);
				self.dom.unbind('mouseup mouseleave');
				move_end();
			});
		});
	}
	
	function init_swipe(){
		var swipe = new Swipe(self.dom);
		swipe.onswipe = function(e){
			e.preventDefault();
			var dx = e.dx;
			var dy = e.dy;
			if(Math.abs(dy) > Math.abs(dx)){
				self.scale(dy/1000, e);
			}else{
				self.move(parseInt(dx/3, 10));
			}
		}
		swipe.onend = function(e){
			move_end();
		}
	}

	self.add = function(e){
		self.insert(self.cells.length, e);
	}

	self.insert = function(index, e){
	index = Math.min(self.cells.length, Math.max(0, index));
		var cell = {
			raw: true,
			e: e
		};
		self.cells.splice(index, 0, cell);
	}
	
	self.init = function(dom_or_id, width, height){
		self.dom = dom_or_id;
		if(typeof(self.dom) == 'string'){
			self.dom = $('#' + self.dom);
		}else{
			self.dom = $(self.dom);
		}
		var elements = self.dom.children().clone();
		if(width > 0){
			self.dom.width(width);
		}
		if(height > 0){
			self.dom.height(height);
		}
		self.width = self.dom.width();
		self.height = self.dom.height();
		self.cells = [];
		
		var html = '';
		html += '<div class="tovi"></div>';
		html += '<div class="tovi_prev" style="display: none;">&lt;</div>';
		html += '<div class="tovi_next" style="display: none;">&gt;</div>';
		self.dom.html(html);
		self.tovi = self.dom.find('.tovi');

		self.dom.css({
			// must be relative!
			position: 'relative',
			visibility: 'visible',
			overflow: 'hidden',
			textAlign: 'center',
			cursor: 'default',
			padding: 0,
			userSelect: 'none'
		}).show();
		self.dom.on('selectstart', function(e){e.preventDefault();});
		
		self.tovi.css({
			// must be relative positioning, to make children positioning right
			position: 'relative'
		});
		
		init_drag();
		init_swipe();
		init_nav_button();
		
		elements.each(function(i, e){
			self.add(e);
		});

		self.seek(0, 0);
	}
	
	function init_nav_button(){
		var prev = self.dom.find('.tovi_prev');
		var next = self.dom.find('.tovi_next');
		var opacity = 0.12;
		prev.mousedown(function(){
			$(this).fadeTo('fast', opacity/2).fadeTo('fast', opacity);
		}).click(function(){
			self.prev();
		});
		next.mousedown(function(){
			$(this).fadeTo('fast', opacity/2).fadeTo('fast', opacity);
		}).click(function(){
			self.next();
		});
		var w = 36;
		var h = w;
		self.dom.find('.tovi_prev, .tovi_next').css({
			position: 'absolute',
			color: '#999',
			fontWeight: 'bold',
			background: '#000',
			opacity: 0,
			cursor: 'pointer',
			'font-family': 'arial',
			'font-size': w,
			'border-radius': 8,
			'text-align': 'center',
			border: '1px solid #fff',
			padding: 0,
			width: w,
			lineHeight: w + 'px',
			height: w
		}).show();
		self.dom.bind('mousemove mouseleave', function(e){
			var x = e.pageX - self.dom.offset().left;
			var y = e.pageY - self.dom.offset().top;
			var l = 3;
			var t = (self.height - h)/2.1;
			var vt = self.height * 1/4;
			var vb = self.height * 3/4;
			var to_show = false;
			if(x > l && x < w+6 && y > vt && y < vb){
				to_show = true;
			}
			x = self.width - x;
			if(x > l && x < w+6 && y > vt && y < vb){
				to_show = true;
			}
			prev.css({
				top: t,
				left: l
			});
			next.css({
				top: t,
				right: l
			});

			if(!to_show){
				self.dom.find('.tovi_prev, .tovi_next').queue("fx", []).stop().animate({
					opacity: 0.0
				}, 'fast');
			}else{
				self.dom.find('.tovi_prev, .tovi_next').queue("fx", []).stop().animate({
					opacity: opacity,
				}, 'fast');
			}
		});
	}
	
	self.clear = function(){
		self.cells = [];
		self.index = 0;
		self.tovi.empty();
		self.onchange(-1, null);
	}
	
	self.autoplay_delay = 0;
	self.autoplay_timer = null;
	self.autoplay = function(delay){
		self.autoplay_delay = delay || 2000;
		function autoplay_bind(){
			if(self.autoplay_timer){
				clearTimeout(self.autoplay_timer);
			}
			self.autoplay_timer = setInterval(function(){
				if(self.index < 0 || self.index >= self.cells.length-1){
					self.seek(-1, 0);
				}else{
					self.seek(self.index + 1);
				}
			}, self.autoplay_delay);
		}
		autoplay_bind();
		self.dom.bind('mouseenter', function(){
			if(self.autoplay_timer){
				clearTimeout(self.autoplay_timer);
				self.autoplay_timer = null;
			}
		}).bind('mouseleave', function(){
			if(self.autoplay_delay > 0){
				autoplay_bind();
			}
		});
	}
	
	self.stopAutoplay = function(){
		if(self.autoplay_timer){
			clearTimeout(self.autoplay_timer);
			self.autoplay_delay = 0;
			self.autoplay_timer = null;
		}
	}
	
	self.bestsize = function(){
		var cell = self.cells[self.index];
		cell.bestsize();
		cell.center();
		cell.layout();
		self._onchange();
	}
	
	self.fillsize = function(){
		var cell = self.cells[self.index];
		cell.fillsize();
		cell.layout();
		self._onchange();
	}
	
	self.actualsize = function(){
		var cell = self.cells[self.index];
		cell.actualsize();
		cell.center();
		cell.layout();
		self._onchange();
	}
	
	self.flip_h = function(){
		var cell = self.cells[self.index];
		if(cell.is_image()){
			cell.flip_h = cell.flip_h == -1? 1 : -1;
			cell.content.css('transform', 'scaleX(' + cell.flip_h + ')');
			cell.layout();
			self._onchange();
		}
	}
	
	self.flip_v = function(){
		var cell = self.cells[self.index];
		if(cell.is_image()){
			cell.flip_v = cell.flip_v == -1? 1 : -1;
			cell.content.css('transform', 'scaleY(' + cell.flip_v + ')');
			cell.layout();
			self._onchange();
		}
	}
	
	self.rotate = function(degree){
		var cell = self.cells[self.index];
		if(cell.is_image()){
			cell.rotate = cell.rotate || 0;
			cell.rotate = (cell.rotate + degree) % 360;
			cell.content.css('transform', 'rotate(' + cell.rotate + 'deg)');
			cell.layout();
			self._onchange();
		}
	}

	function debug(){
		var arr = [];
		for(var i=0; i<arguments.length; i++){
			arr.push(arguments[i]);
		}
		console.log(arr.join(', '));
	}
}

