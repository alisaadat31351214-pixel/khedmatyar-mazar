/* ظاهر صفحهٔ قرآن (مشترک بین سایت و پیش‌نمایش پنل مدیر).
   kyQuranCss(q, scope) → متن CSS؛ kyQuranText(raw, mode, esc) → HTML آیه با حالت اعراب (full | color | none). */
(function () {
  var MARKS = /[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06DC\u06DF-\u06E8\u06EA-\u06ED]+/g;
  function lum(h) { h = String(h || '#ffffff').replace('#', ''); if (h.length === 3) h = h.replace(/./g, '$&$&'); var r = parseInt(h.substr(0, 2), 16) / 255, g = parseInt(h.substr(2, 2), 16) / 255, b = parseInt(h.substr(4, 2), 16) / 255; return .2126 * r + .7152 * g + .0722 * b; }
  function enc(c) { return String(c).replace('#', '%23'); }
  window.kyQuranMarks = MARKS;
  window.kyQuranText = function (raw, mode, esc) {
    esc = esc || function (s) { return String(s).replace(/[&<>"']/g, function (c) { return '&#' + c.charCodeAt(0) + ';'; }); };
    if (mode === 'none') return esc(String(raw).replace(MARKS, ''));
    if (mode === 'color') return esc(raw).replace(MARKS, function (m) { return '<i class="qd">' + m + '</i>'; });
    return esc(raw);
  };
  window.kyQuranCss = function (q, S) {
    q = q || {}; var c1 = q.c1 || '#b8860b', c2 = q.c2 || '#0f766e', bg = q.bg || '#fffdf4', dark = lum(bg) < .4,
      tx = q.tx || (dark ? '#f1f5f9' : '#15283a'), dc = q.dc || '#c2410c', fr = q.frame || 'full', full = fr === 'full', simple = fr === 'simple', f = S + ' .q-frame';
    var band = 'url("data:image/svg+xml;utf8,<svg xmlns=\'http://www.w3.org/2000/svg\' width=\'40\' height=\'24\' viewBox=\'0 0 40 24\'><path d=\'M20 2 L27 12 L20 22 L13 12Z\' fill=\'none\' stroke=\'' + enc(c1) + '\' stroke-width=\'1.6\'/><circle cx=\'20\' cy=\'12\' r=\'2.4\' fill=\'' + enc(c2) + '\'/><path d=\'M0 12H10M30 12H40\' stroke=\'' + enc(c2) + '\' stroke-width=\'1.2\'/></svg>")';
    var star = 'url("data:image/svg+xml;utf8,<svg xmlns=\'http://www.w3.org/2000/svg\' viewBox=\'0 0 100 100\'><rect x=\'18\' y=\'18\' width=\'64\' height=\'64\' fill=\'' + enc(bg) + '\' stroke=\'' + enc(c1) + '\' stroke-width=\'3\'/><rect x=\'18\' y=\'18\' width=\'64\' height=\'64\' fill=\'' + enc(bg) + '\' stroke=\'' + enc(c1) + '\' stroke-width=\'3\' transform=\'rotate(45 50 50)\'/><circle cx=\'50\' cy=\'50\' r=\'25\' fill=\'' + enc(bg) + '\' stroke=\'' + enc(c2) + '\' stroke-width=\'3\'/></svg>")';
    var ring = 'url("data:image/svg+xml;utf8,<svg xmlns=\'http://www.w3.org/2000/svg\' viewBox=\'0 0 100 100\'><circle cx=\'50\' cy=\'50\' r=\'46\' fill=\'' + enc(bg) + '\' stroke=\'' + enc(c2) + '\' stroke-width=\'5\'/><circle cx=\'50\' cy=\'50\' r=\'36\' fill=\'none\' stroke=\'' + enc(c1) + '\' stroke-width=\'3\' stroke-dasharray=\'7 4\'/></svg>")';
    var css = f + '{position:relative;margin:14px 0 36px;background:' + bg + '!important;border-radius:20px!important;' +
      (fr === 'none' ? 'border:0!important;box-shadow:none!important;padding:26px 10px 38px;' : simple ? 'border:2px solid ' + c1 + '!important;box-shadow:none!important;padding:34px 20px 44px;' :
        'padding:46px 22px 50px;border:2px solid ' + c1 + '!important;box-shadow:inset 0 0 0 6px ' + bg + ',inset 0 0 0 8px ' + c2 + ',inset 0 0 0 11px ' + bg + ',inset 0 0 0 12px ' + c1 + ',0 14px 32px rgba(0,0,0,.14)!important;') + '}';
    css += f + ':before,' + f + ':after{content:' + (full ? '""' : 'none') + ';position:absolute;left:16px;right:16px;height:24px;background:' + band + ' repeat-x center/auto 100%}' + f + ':before{top:16px}' + f + ':after{bottom:16px}';
    css += S + ' .q-cart{' + (full ? 'position:absolute;top:-16px;left:50%;transform:translateX(-50%);min-width:190px;padding:7px 28px;border-radius:99px;color:#fff;background:' + c2 + ';border:2px solid ' + c1 + ';box-shadow:0 6px 14px rgba(0,0,0,.2);' :
      'position:static;transform:none;display:block;min-width:0;margin:0 0 14px;padding:0;border-radius:0;color:' + c2 + ';background:none;border:0;box-shadow:none;') + 'text-align:center;font:800 19px "Amiri Quran",Vazirmatn,serif}';
    css += S + ' .q-num{' + (full ? 'position:absolute;bottom:-26px;left:50%;transform:translateX(-50%);width:62px;height:62px;display:grid;place-items:center;font:800 19px Vazirmatn,Tahoma;color:' + c2 + ';background:' + star + ' center/contain no-repeat' :
      simple ? 'position:static;transform:none;width:auto;height:auto;display:block;background:none;text-align:center;margin-top:14px;font:800 16px Vazirmatn,Tahoma;color:' + c2 : 'display:none') + '}';
    css += S + ' .qm{display:inline-grid;place-items:center;width:36px;height:36px;margin:0 6px;vertical-align:middle;font:800 14px Vazirmatn,Tahoma;color:' + c2 + ';background:' + ring + ' center/contain no-repeat}';
    css += S + ' .qv{color:' + tx + '!important}' + S + ' .qtr{color:' + tx + '!important;opacity:.78}' + S + ' .qbis{color:' + c2 + '!important}' + S + ' .qd{font-style:normal;color:' + dc + '}' + f + ' .qv.bm{background:' + (dark ? 'rgba(255,255,255,.1)' : 'rgba(242,185,53,.18)') + '}';
    return css;
  };
})();
