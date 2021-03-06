define(
    "frontend-js-metal-web@1.0.0/metal/src/string/string",
    ['exports', 'module'],
    function (exports, module) {
        'use strict';

        var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ('value' in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

        function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError('Cannot call a class as a function'); } }

        var string = (function () {
            function string() {
                _classCallCheck(this, string);
            }

            _createClass(string, null, [{
                key: 'collapseBreakingSpaces',

                /**
        * Removes the breaking spaces from the left and right of the string and
        * collapses the sequences of breaking spaces in the middle into single spaces.
        * The original and the result strings render the same way in HTML.
        * @param {string} str A string in which to collapse spaces.
        * @return {string} Copy of the string with normalized breaking spaces.
        */
                value: function collapseBreakingSpaces(str) {
                    return str.replace(/[\t\r\n ]+/g, ' ').replace(/^[\t\r\n ]+|[\t\r\n ]+$/g, '');
                }

                /**
        * Calculates the hashcode for a string. The hashcode value is computed by
        * the sum algorithm: s[0]*31^(n-1) + s[1]*31^(n-2) + ... + s[n-1]. A nice
        * property of using 31 prime is that the multiplication can be replaced by
        * a shift and a subtraction for better performance: 31*i == (i<<5)-i.
        * Modern VMs do this sort of optimization automatically.
        * @param {String} val Target string.
        * @return {Number} Returns the string hashcode.
        */
            }, {
                key: 'hashCode',
                value: function hashCode(val) {
                    var hash = 0;
                    for (var i = 0, len = val.length; i < len; i++) {
                        hash = 31 * hash + val.charCodeAt(i);
                        hash %= 0x100000000;
                    }
                    return hash;
                }

                /**
        * Replaces interval into the string with specified value, e.g.
        * `replaceInterval("abcde", 1, 4, "")` returns "ae".
        * @param {string} str The input string.
        * @param {Number} start Start interval position to be replaced.
        * @param {Number} end End interval position to be replaced.
        * @param {string} value The value that replaces the specified interval.
        * @return {string}
        */
            }, {
                key: 'replaceInterval',
                value: function replaceInterval(str, start, end, value) {
                    return str.substring(0, start) + value + str.substring(end);
                }
            }]);

            return string;
        })();

        module.exports = string;
    }
);