(function (global, define) {
	"use strict";

	define(function() {
	
		var doc = global.document;
		var html = doc.documentElement;
		var body, fakeBody, div, span;
		var overflow;
		var style = "&#173;<style>@font-face{font-family:test-woff2;src:url(data:font/woff2;base64,d09GMgABAAAAAAIkAAoAAAAABVwAAAHcAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAABlYAgloKLEoBNgIkAxgLDgAEIAWDcgc1G7IEyB6SJAFID5YA3nAHC6h4+H7s27nP1kTyOoQkGuJWtNGIJKYznRI3VEL7IaHq985ZUuKryZKcAtJsi5eULwUybm9KzajBBhywZ5ZwoJNuwDX5C/xBjvz5DbsoNsvG1NGQiqp0NMLZ7JlnW+5MaM3HwcHheUQeiVokekHkn/FRdefvJaTp2PczN+I1Sc3k9VuX51Tb0Tqqf1deVXGdJsDOhz0/EffMOPOzHNH06pYkDDjs+P8fb/z/8n9Iq8ITzWywkP6PBMMN9L/O7vY2FNoTAkp5PpD6g1nV9WmyQnM5uPpAMHR2fe06jbfvzPriekVTQxC6lpKr43oDtRZfCATl5OVAUKykqwm9o8R/kg37cxa6eZikS7cjK4aIwoyh6jOFplhFrz2b833G3Jii9AjDUiAZ9AxZtxdEYV6imvRF0+0Nej3wu6nPZrTLh81AVcV3kmMVdQj6Qbe9qetzbuDZ7vXOlRrqooFSxCv6SfrDICA6rnHZXQPVcUHJYGcoqa3jVH7ATrjWBNYYkEqF3RFpVIl0q2JvMOJd7/TyjXHw2NyAuJpNaEbz8RTEVtCbSH7JrwQQOqwGl7sTUOtdBZIY2DKqKlvOmPvUxJaURAZZcviTT0SKHCXqzwc=) format(\"woff2\");font-weight:400}@font-face{font-family:test-woff;src:url(data:font/woff;base64,d09GRgABAAAAAAOEAAoAAAAABVwAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAABPUy8yAAAA9AAAAEEAAABWXgxFo2NtYXAAAAE4AAAASQAAAVrCBCIvZ2x5ZgAAAYQAAAApAAAALBOjUapoZWFkAAABsAAAAC0AAAA2BMSve2hoZWEAAAHgAAAAHgAAACQG0gUHaG10eAAAAgAAAAATAAAAGBfUAABsb2NhAAACFAAAAA4AAAAOACwAJG1heHAAAAIkAAAAHwAAACABEQAQbmFtZQAAAkQAAAEeAAAB8l01citwb3N0AAADZAAAAB8AAAA1AyQCCHicY2Bk/sk4gYGVgYP5O0sCAwPDAwjNzMDgxziHgYGJgRXIxAYC0lxTGByAGoCa/x1gmMDKwAjkMTCC5AAZ5wtJAAAAeJxjYGBgZoBgGQZGBhAIAfIYwXwWBgsgzcXAwcAEhAwMvAx6Dxj+/wergrP/f/l/RYEZqhcKGNkYUAEjAwHAREjBkAMAewYLEAAAAHicY2BkAAJGB1YGBmYGBkFFQUVGh38HWBn+HQAJM8AAUM6SGQBoaQSxAAAAeJxjYGRgYABiE72TQvH8Nl8ZuNkcgCIMl4yN5yPTjA6sIIqDgQlEAQDiBwcuAAAAeJxjYGRgYGX4d4BhApsDAxAwOjAwMqACNgBPYgLjAAB4nGP8wsDA5gDBzAoIDAAiXAHrAAAAAAAAAAAOABYAFgAWAAB4nGNgZGBgYGNgYQDRDAxMQMwFhAwM/8F8BgAJZwEiAHicXY6/bsIwEMa/QEhbkFqkSu1qdWCplAAjDwBzGdgDOAGUxJFjkFg7duxTdOxT9Ln6xT064JPvfvfdHxvAED8I0J4At963p4MbZn/cRYgH4ZD2KNzDAM/CEfUX4T5eMRIesPuNG4LwjsoQW+EO7uGEu3zpXTgkfwj38IRP4Yj6l3AfK3wLDzAKosxUTheFWer8WKTW6ca1d6VtszeVmsTjNl3oStvU6a1an1VzyqfOZSqzplRzmVe1NQe9cfHOuXqWJJe98caUyGBQ8c8aBc1gScpxJKewXm/oL3HFaEl7P6UwQYzxf3XBWPmO1Gtbdqxxpm9w4tap35Qxz9hjUJLmV+8r1L52oLKhHmPnp2rMkNCu/xuzi5t+Abr4U+YAAHicY2BigAABBuyAjYGBkYmRmZGFkZWRDSoGAATyADIA) format(\"woff\");font-weight:400}@font-face{font-family:test-ttf;src:url(data:font/ttf;base64,AAEAAAAKAIAAAwAgT1MvMl4MRaMAAAEoAAAAVmNtYXDCBCIvAAABmAAAAVpnbHlmE6NRqgAAAwQAAAAsaGVhZATEr3sAAADQAAAANmhoZWEG0gUHAAAArAAAACRobXR4F9QAAAAAAYAAAAAYbG9jYQAsACQAAAL0AAAADm1heHABEQAQAAABCAAAACBuYW1lXTVyKwAAAzAAAAHycG9zdAMkAggAAAUkAAAANQABAAAFAP7AAJAGQAAAAAABQAABAAAAAAAAAAAAAAAAAAAABgABAAAAAQAANC7Orl8PPPUACwZAAAAAANIzM58AAAAA0jMznwAAAAABQAUAAAAACAACAAAAAAAAAAEAAAAGAAQAAQAAAAAAAgAAAAoACgAAAP8AAAAAAAAAAQP5AZAABQAAA/cEYAAAAOAD9wRgAAADAABOAZwAAAIABQMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAUGZFZABAAADgAAUA/sAAkAUAAUAAAAABAAAAAAAAAfQAAAZAAAAGQAAAAyAAAAMgAAADIAAAAAAAAwAAAAMAAAAcAAEAAAAAAFQAAwABAAAAHAAEADgAAAAKAAgAAgACAAAADQAu4AD//wAAAAAADQAu4AD//wAA//T/1CADAAEAAAAAAAAAAAAAAAABBgAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA4AFgAWABYAAAABAAAAAAFABQAAAwAAESERIQFA/sAFAP7AAAAAAQAAAAAAAAAAAAMAADkDAAAAEADGAAEAAAAAAAEACAAAAAEAAAAAAAIABwAIAAEAAAAAAAMABAAPAAEAAAAAAAQABAATAAEAAAAAAAUACwAXAAEAAAAAAAYABAAiAAEAAAAAAAoAKwAmAAEAAAAAAAsAEwBRAAMAAQQJAAEAEABkAAMAAQQJAAIADgB0AAMAAQQJAAMACACCAAMAAQQJAAQACACKAAMAAQQJAAUAFgCSAAMAAQQJAAYACACoAAMAAQQJAAoAVgCwAAMAAQQJAAsAJgEGZm9udGVsbG9SZWd1bGFydGVzdHRlc3RWZXJzaW9uIDEuMHRlc3RHZW5lcmF0ZWQgYnkgc3ZnMnR0ZiBmcm9tIEZvbnRlbGxvIHByb2plY3QuaHR0cDovL2ZvbnRlbGxvLmNvbQBmAG8AbgB0AGUAbABsAG8AUgBlAGcAdQBsAGEAcgB0AGUAcwB0AHQAZQBzAHQAVgBlAHIAcwBpAG8AbgAgADEALgAwAHQAZQBzAHQARwBlAG4AZQByAGEAdABlAGQAIABiAHkAIABzAHYAZwAyAHQAdABmACAAZgByAG8AbQAgAEYAbwBuAHQAZQBsAGwAbwAgAHAAcgBvAGoAZQBjAHQALgBoAHQAdABwADoALwAvAGYAbwBuAHQAZQBsAGwAbwAuAGMAbwBtAAAAAgAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAGAAABAgEDAQQBBQEGAAAAAAAAAAAAAA==) format(\"truetype\");font-weight:400}@font-face{font-family:test-svg;src:url(data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBzdGFuZGFsb25lPSJubyI/Pgo8IURPQ1RZUEUgc3ZnIFBVQkxJQyAiLS8vVzNDLy9EVEQgU1ZHIDEuMS8vRU4iICJodHRwOi8vd3d3LnczLm9yZy9HcmFwaGljcy9TVkcvMS4xL0RURC9zdmcxMS5kdGQiID4KPHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgo8ZGVmcz4KPGZvbnQgaWQ9InRlc3QiIGhvcml6LWFkdi14PSIxNjAwIiA+Cjxmb250LWZhY2UgdW5pdHMtcGVyLWVtPSIxNjAwIiBhc2NlbnQ9IjEyODAiIGRlc2NlbnQ9Ii0zMjAiIC8+CjxtaXNzaW5nLWdseXBoIGhvcml6LWFkdi14PSI1MDAiIC8+CjxnbHlwaCBob3Jpei1hZHYteD0iODAwIiAvPgo8Z2x5cGggaG9yaXotYWR2LXg9IjgwMCIgLz4KPGdseXBoIHVuaWNvZGU9IiYjeGQ7IiAvPgo8Z2x5cGggdW5pY29kZT0iLiIgZD0iTTAgMTI4MGgzMjB2LTMyMGgtMzIwdjMyMHoiIC8+CjxnbHlwaCB1bmljb2RlPSImI3hlMDAwOyIgaG9yaXotYWR2LXg9IjgwMCIgZD0iTTAgMHYwdjB2MHYweiIgLz4KPC9mb250Pgo8L2RlZnM+PC9zdmc+IA==) format(\"svg\");font-weight:400}.test-woff2,.test-woff,.test-ttf,.test-svg{font-size:10px;font-weight:400}.test-woff2{font-family:test-woff2}.test-woff{font-family:test-woff}.test-ttf{font-family:test-ttf}.test-svg{font-family:test-svg}</style>";
		var formats = ["woff2", "woff", "ttf", "svg"];
		var isComplete = false;
		var isRunning = false;
		var callbacks = [];
		var support = {};

		return function (callback, returnOption) {
			
			callbacks.push({callback: callback, option: returnOption || null});

			if (isComplete) {
				handleCallbacks();
			}
			else {
				
				if (isRunning) {
					return;
				}
				
				detect();
			}

		};
		
		function formatResult (option) {
			var result;
			if (!option) {
				result = support;
			}
			else if (typeof option == "string") {
				result = support[option];
			}
			else {
				result = [];
				var i = 0;
				var l = option.length;
				while (i < l) {
					(function (format) {
						if (support[format]) {
							result.push(format);
						}
					}(option[i++]));
				}
				result = 0 in result && result[0] || null;
			}
			return result;
		}
		
		function handleCallbacks () {
			var data;
			while (callbacks.length) {
				data = callbacks.shift();
				data.callback(formatResult(data.option));
			}
		}
		
		function detect () {
			isRunning = true;
			body = doc.body,
			fakeBody = body || doc.createElement("body"),
			div = doc.createElement("div"),
			span = doc.createElement("span"),

			span.innerHTML = ".";

			(body ? div : fakeBody).innerHTML += style;
			fakeBody.appendChild(div);
			if (!body) {
				fakeBody.style.background = "";
				fakeBody.style.overflow = "hidden";
				overflow = html.style.overflow;
				html.style.overflow = "hidden";
				html.appendChild(fakeBody);
			}

			var i = 0;
			var l = formats.length;
			var countdown = l;
			var clones = [];
			var detected;
			var start = new Date();
			var timeout = 2000;

			while (i < l) {
				(function (format, clone) {
					clone.className = "test-" + format;
					clones.push(clone);
					div.appendChild(clone);
				}(formats[i++], span.cloneNode(true)));
			}

			(function check() {
				var i = 0;
				while (i < l) {
					if (clones[i].offsetWidth == 10) {
						detected = true;
						support[formats[i]] = true;
					}
					i++;
				}
				if (detected) {
					isComplete = true;
					cleanup();
				}
				else if (new Date() - start > timeout) {
					cleanup();
				}
				else {
					setTimeout(check, 100);
				}
			}());
		}
		
		function cleanup() {
			if (!body) {
				fakeBody.parentNode.removeChild(fakeBody);
				html.style.overflow = overflow;
			} else {
				div.parentNode.removeChild(div);
			}
			handleCallbacks();
			isRunning = false;
		}
		
	});

}(window, typeof define == "function" && define.amd ? define : function(factory) { window.fontSupport = factory() } ));