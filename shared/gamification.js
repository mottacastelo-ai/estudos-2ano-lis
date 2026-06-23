/**
 * SabendoGamification — Portal da Lis (2º Ano)
 *
 * Ao concluir todas as atividades de um módulo, a Lis recebe
 * uma carta temática aleatória (frutas, coração, estrela).
 * Sem sistema de raridade — toda carta é igualmente especial!
 *
 * Uso:
 *   await SabendoGamification.run(supa, uid, themeSlug, discipline, config);
 *
 * config: {
 *   characterName,    // ex: 'Florita'
 *   characterEmoji,   // ex: '🌿'  (fallback se characterImg ausente)
 *   characterImg,     // ex: 'chars/florita.png'  (relativo a _landing/)
 *   themeLabel,       // ex: 'Onde Vivem as Plantas · Ciências'
 *   totalActivities,  // ex: 5
 *   primaryColor,     // ex: '#22C55E'
 *   lightColor,       // ex: '#6EE7A0'
 *   bgColor,          // ex: '#F0FDF4'
 *   glowRgb,          // ex: '34,197,94'
 *   assetBase,        // opcional — prefixo de assets (default: '../../')
 *   backUrl           // opcional — redireciona após o reveal
 * }
 */
(function () {
  "use strict";

  /* ------------------------------------------------------------------ */
  /* Cartas temáticas disponíveis                                        */
  /* ------------------------------------------------------------------ */
  var THEMATIC_CARDS = [
    "abacaxi", "banana", "coracao", "estrela",
    "kiwi", "maca", "melancia", "morango", "pessego", "uva"
  ];

  var CARD_EMOJIS = {
    abacaxi: "🍍", banana: "🍌", coracao: "❤️", estrela: "⭐",
    kiwi: "🥝", maca: "🍎", melancia: "🍉", morango: "🍓",
    pessego: "🍑", uva: "🍇"
  };

  var CARD_NAMES = {
    abacaxi: "Abacaxi", banana: "Banana", coracao: "Coração", estrela: "Estrela",
    kiwi: "Kiwi", maca: "Maçã", melancia: "Melancia", morango: "Morango",
    pessego: "Pêssego", uva: "Uva"
  };

  function randomCard() {
    return THEMATIC_CARDS[Math.floor(Math.random() * THEMATIC_CARDS.length)];
  }

  /* ------------------------------------------------------------------ */
  /* Font — Space Mono (carregada dinamicamente)                         */
  /* ------------------------------------------------------------------ */
  function loadSpaceMono() {
    if (document.querySelector('link[href*="Space+Mono"]')) return;
    var link = document.createElement("link");
    link.rel = "stylesheet";
    link.href = "https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&display=swap";
    document.head.appendChild(link);
  }

  /* ------------------------------------------------------------------ */
  /* SFX — efeitos sonoros via Web Audio API                             */
  /* ------------------------------------------------------------------ */
  var SFX = (function () {
    var _ctx = null;

    function ctx() {
      if (!_ctx) {
        try { _ctx = new (window.AudioContext || window.webkitAudioContext)(); } catch (e) { return null; }
      }
      if (_ctx && _ctx.state === "suspended") { try { _ctx.resume(); } catch (e) {} }
      return _ctx;
    }

    function osc(freq, type, startAt, dur, vol, freqEnd) {
      var c = ctx(); if (!c) return;
      var o = c.createOscillator();
      var g = c.createGain();
      o.connect(g); g.connect(c.destination);
      o.type = type || "sine";
      o.frequency.setValueAtTime(freq, startAt);
      if (freqEnd != null) o.frequency.linearRampToValueAtTime(freqEnd, startAt + dur);
      g.gain.setValueAtTime(0.001, startAt);
      g.gain.linearRampToValueAtTime(vol || 0.25, startAt + 0.012);
      g.gain.exponentialRampToValueAtTime(0.001, startAt + dur);
      o.start(startAt); o.stop(startAt + dur + 0.06);
    }

    function noise(startAt, dur, vol, centerFreq, q) {
      var c = ctx(); if (!c) return;
      var rate = c.sampleRate;
      var bufSz = Math.ceil(rate * (dur + 0.06));
      var buf = c.createBuffer(1, bufSz, rate);
      var d = buf.getChannelData(0);
      for (var i = 0; i < bufSz; i++) d[i] = Math.random() * 2 - 1;
      var src = c.createBufferSource(); src.buffer = buf;
      var flt = c.createBiquadFilter();
      flt.type = "bandpass"; flt.frequency.value = centerFreq || 1000; flt.Q.value = q || 1;
      var g = c.createGain();
      src.connect(flt); flt.connect(g); g.connect(c.destination);
      g.gain.setValueAtTime(vol || 0.12, startAt);
      g.gain.exponentialRampToValueAtTime(0.001, startAt + dur);
      src.start(startAt); src.stop(startAt + dur + 0.06);
    }

    return {
      scanReveal: function (durMs) {
        var c = ctx(); if (!c) return;
        var t = c.currentTime + 0.05;
        var dur = Math.max(0.6, (durMs || 1200) / 1000);
        noise(t, dur * 0.75, 0.10, 800, 0.8);
        osc(160, "sine", t, dur * 0.85, 0.16, 480);
        osc(320, "sine", t + dur * 0.25, dur * 0.55, 0.07, 900);
      },
      stageProgress: function () {
        var c = ctx(); if (!c) return;
        var t = c.currentTime + 0.05;
        osc(523, "sine", t,      0.18, 0.20);
        osc(659, "sine", t+0.13, 0.18, 0.16);
      },
      characterComplete: function () {
        var c = ctx(); if (!c) return;
        var t = c.currentTime + 0.05;
        osc(523,  "sine", t,      0.22, 0.22);
        osc(659,  "sine", t+0.10, 0.20, 0.20);
        osc(784,  "sine", t+0.20, 0.20, 0.20);
        osc(1047, "sine", t+0.30, 0.30, 0.24);
        noise(t+0.28, 0.32, 0.08, 3500, 0.6);
      },
      cardRevealBuild: function () {
        var c = ctx(); if (!c) return;
        var t = c.currentTime + 0.05;
        osc(55,  "sawtooth", t, 0.75, 0.07);
        osc(80,  "sine",     t, 0.75, 0.10);
        noise(t, 0.55, 0.06, 120, 0.5);
      },
      cardEntry: function () {
        var c = ctx(); if (!c) return;
        var t = c.currentTime + 0.05;
        osc(523,  "sine", t,      0.22, 0.22);
        osc(659,  "sine", t+0.10, 0.20, 0.20);
        osc(784,  "sine", t+0.20, 0.22, 0.20);
        osc(1047, "sine", t+0.30, 0.32, 0.26);
        noise(t+0.28, 0.28, 0.09, 2500, 0.5);
      },
      cardFlash: function () {
        var c = ctx(); if (!c) return;
        var t = c.currentTime + 0.05;
        osc(2200, "sawtooth", t, 0.08, 0.12, 380);
        noise(t, 0.10, 0.08, 4000, 0.5);
      },
      shockwave: function () {
        var c = ctx(); if (!c) return;
        var t = c.currentTime + 0.05;
        osc(50, "sine", t, 0.35, 0.35);
        noise(t, 0.30, 0.18, 100, 0.4);
      },
      sparkle: function () {
        var c = ctx(); if (!c) return;
        var t = c.currentTime + 0.05;
        for (var i = 0; i < 7; i++) {
          var delay = i * 0.038;
          osc(1100 + Math.random() * 1800, "sine", t + delay, 0.16, 0.04 + Math.random() * 0.04);
        }
      },
      celebration: function () {
        var c = ctx(); if (!c) return;
        var t = c.currentTime + 0.05;
        osc(523,  "sine", t,     0.28, 0.22);
        osc(659,  "sine", t+.10, 0.25, 0.22);
        osc(784,  "sine", t+.20, 0.25, 0.22);
        osc(1047, "sine", t+.30, 0.28, 0.26);
        osc(1319, "sine", t+.42, 0.40, 0.28);
        noise(t+.38, 0.40, 0.12, 3000, 0.5);
      }
    };
  })();

  /* ------------------------------------------------------------------ */
  /* CSS — modal de personagem                                           */
  /* ------------------------------------------------------------------ */
  function injectStyles(primaryColor, lightColor, bgColor, glowRgb) {
    if (document.getElementById("sgami-styles")) return;
    var css = [
      "@keyframes sgami-fadein    { from{opacity:0} to{opacity:1} }",
      "@keyframes sgami-slideup   { from{transform:translateY(40px);opacity:0} to{transform:none;opacity:1} }",
      "@keyframes sgami-fillbar   { from{width:0} to{width:var(--sgami-bar-w)} }",
      "@keyframes sgami-chip-in   { from{transform:scale(0) translateY(6px);opacity:0} to{transform:none;opacity:1} }",
      "@keyframes sgami-flash     { 0%{opacity:0} 18%{opacity:1} 100%{opacity:0} }",
      "@keyframes sgami-ring-pulse {",
      "  0%,100% { box-shadow:0 0 0 3px SGAMI_PRIMARY, 0 0 24px rgba(SGAMI_GLOW,.4); }",
      "  50%     { box-shadow:0 0 0 5px SGAMI_LIGHT,   0 0 52px rgba(SGAMI_GLOW,.8); }",
      "}",
      "@keyframes sgami-celebrate { 0%{transform:scale(0)rotate(-20deg);opacity:0} 50%{transform:scale(1.3)rotate(5deg)} 100%{transform:scale(1)rotate(0);opacity:1} }",
      "@keyframes sgami-scan-sweep { 0%{top:-50px;opacity:.9} 100%{top:100%;opacity:0} }",
      "@keyframes sgami-wrap-pop   { 0%{transform:scale(1)} 30%{transform:scale(1.06)} 100%{transform:scale(1)} }",

      "#sgami-overlay { position:fixed;inset:0;z-index:99999; background:rgba(0,0,0,.65);backdrop-filter:blur(4px); display:flex;align-items:center;justify-content:center; animation:sgami-fadein .3s ease; font-family:'Baloo 2',sans-serif; }",
      "#sgami-card { background:#fff;border-radius:20px;padding:20px 18px 16px; max-width:320px;width:90%;text-align:center; box-shadow:0 20px 60px rgba(0,0,0,.4); animation:sgami-slideup .4s cubic-bezier(.22,1,.36,1); }",
      "#sgami-title    { font-size:17px;font-weight:800;color:#1e1b4b;margin:0 0 2px; }",
      "#sgami-subtitle { font-size:12px;color:#6b7280;margin:0 0 14px; }",
      ".sgami-canvas-wrap { position:relative;width:200px;height:240px; margin:0 auto 14px;border-radius:12px;overflow:hidden; }",
      "#sgami-char-canvas { display:block;width:200px;height:240px;border-radius:12px; image-rendering:pixelated;image-rendering:crisp-edges; background:#120D28; }",
      ".sgami-canvas-wrap.done #sgami-char-canvas { animation:sgami-ring-pulse 1.5s ease infinite; }",
      ".sgami-unlock-flash { position:absolute;inset:0;border-radius:12px; background:rgba(SGAMI_GLOW,.48);pointer-events:none;opacity:0; animation:sgami-flash .65s ease forwards; }",
      ".sgami-scan-line { position:absolute;left:0;right:0;height:52px;pointer-events:none;z-index:2; background:linear-gradient(to bottom,transparent,rgba(SGAMI_GLOW,.55),transparent); animation:sgami-scan-sweep linear forwards; }",
      ".sgami-canvas-wrap.sgami-wrap-pop { animation:sgami-wrap-pop .55s cubic-bezier(.22,1,.36,1) both; }",
      ".sgami-chips { display:flex;gap:6px;justify-content:center;flex-wrap:wrap;min-height:28px;margin-bottom:10px; }",
      ".sgami-chip { background:SGAMI_BG;border:1.5px solid SGAMI_PRIMARY; border-radius:8px;padding:3px 10px; font-size:11px;font-weight:800;color:SGAMI_PRIMARY; animation:sgami-chip-in .35s cubic-bezier(.22,1,.36,1) both; }",
      ".sgami-bar-wrap { background:#e5e7eb;border-radius:99px;height:8px;margin-bottom:4px;overflow:hidden; }",
      ".sgami-bar-fill { height:100%;border-radius:99px; background:linear-gradient(90deg,SGAMI_PRIMARY,SGAMI_LIGHT); width:var(--sgami-bar-w); transition:width .6s cubic-bezier(.22,1,.36,1); }",
      ".sgami-bar-fill.animated { animation:sgami-fillbar .6s .2s cubic-bezier(.22,1,.36,1) both; }",
      ".sgami-bar-label { font-size:11px;color:#9ca3af;margin-bottom:12px; }",
      ".sgami-carta { display:none;border-radius:14px;padding:10px 14px;margin-bottom:12px; background:SGAMI_BG;border:1.5px solid SGAMI_PRIMARY; animation:sgami-celebrate .5s cubic-bezier(.22,1,.36,1) both; }",
      ".sgami-carta.show { display:block; }",
      ".sgami-carta-name  { font-size:13px;font-weight:800;color:#5B21B6;margin-bottom:2px; }",
      ".sgami-carta-badge { display:inline-block;background:linear-gradient(135deg,SGAMI_PRIMARY,SGAMI_LIGHT); color:#fff;padding:2px 12px;border-radius:99px;font-size:11px;font-weight:800;margin-top:6px; }",
      "#sgami-continue { background:linear-gradient(135deg,SGAMI_PRIMARY,SGAMI_LIGHT); color:#fff;border:none;border-radius:50px; padding:10px;font-size:13px;font-weight:800; cursor:pointer;width:100%;font-family:'Baloo 2',sans-serif; transition:opacity .2s; }",
      "#sgami-continue:hover { opacity:.88; }",
    ]
      .join("\n")
      .replace(/SGAMI_PRIMARY/g, primaryColor)
      .replace(/SGAMI_LIGHT/g, lightColor)
      .replace(/SGAMI_BG/g, bgColor)
      .replace(/SGAMI_GLOW/g, glowRgb);

    var st = document.createElement("style");
    st.id = "sgami-styles";
    st.textContent = css;
    document.head.appendChild(st);
  }

  /* ------------------------------------------------------------------ */
  /* CSS — reveal cinematográfico                                        */
  /* ------------------------------------------------------------------ */
  function injectRevealStyles() {
    if (document.getElementById("sgami-reveal-styles")) return;
    var css = `
      @keyframes sgami-rev-bgfade    { to { opacity:1; } }
      @keyframes sgami-rev-flash-pop { 0%{opacity:0} 15%{opacity:1} 100%{opacity:0} }
      @keyframes sgami-rev-letter-fall { to { opacity:1; transform:translateY(0) rotate(0deg); } }
      @keyframes sgami-rev-card-spring {
        0%   { opacity:0; transform:scale(0.05) rotate(-10deg); }
        55%  { opacity:1; transform:scale(1.1) rotate(1.5deg); }
        75%  { transform:scale(0.96) rotate(-0.5deg); }
        100% { opacity:1; transform:scale(1) rotate(0deg); }
      }
      @keyframes sgami-rev-card-float {
        0%,100% { transform:translateY(0) rotate(0deg); }
        50%     { transform:translateY(-10px) rotate(.4deg); }
      }
      @keyframes sgami-rev-ring-pulse {
        0%   { filter:brightness(1); }
        40%  { filter:brightness(2.5) blur(2px); }
        100% { filter:brightness(1); }
      }
      @keyframes sgami-rev-blink { 0%,100%{opacity:.2} 50%{opacity:.55} }

      #sgami-rev-overlay {
        display:none; position:fixed; inset:0; z-index:999999;
        align-items:center; justify-content:center; flex-direction:column;
        cursor:pointer; overflow:hidden; font-family:"Baloo 2",sans-serif;
      }
      #sgami-rev-overlay.active { display:flex; }
      #sgami-rev-bg {
        position:absolute; inset:0;
        background:radial-gradient(ellipse at center,#120d28 0%,#05040f 70%);
        opacity:0; animation:sgami-rev-bgfade .5s ease forwards;
      }
      #sgami-rev-glow { position:absolute; inset:0; pointer-events:none; opacity:0; transition:opacity .4s; }
      #sgami-rev-canvas { position:absolute; inset:0; pointer-events:none; z-index:2; }
      #sgami-rev-flash { position:absolute; inset:0; pointer-events:none; z-index:3; opacity:0; }
      #sgami-rev-flash.pop { animation:sgami-rev-flash-pop .7s ease-out forwards; }

      #sgami-rev-title {
        position:relative; z-index:5;
        font-family:"Space Mono",monospace;
        font-size:11px; font-weight:700; letter-spacing:.22em; text-transform:uppercase;
        color:rgba(255,255,255,.3); height:24px;
        display:flex; align-items:center; gap:1px; margin-bottom:20px;
      }
      .sgami-rev-letter {
        display:inline-block; opacity:0;
        transform:translateY(-40px) rotate(-8deg);
        animation:sgami-rev-letter-fall .35s cubic-bezier(.22,1,.36,1) forwards;
      }
      .sgami-rev-space { width:8px; }

      #sgami-rev-stage { position:relative; z-index:5; display:flex; align-items:center; justify-content:center; }

      .sgami-rev-card {
        position:relative; width:280px; height:400px;
        border-radius:20px; overflow:visible; margin-top:64px;
      }
      .sgami-rev-frame { position:absolute; inset:0; border-radius:20px; overflow:hidden; }
      .sgami-rev-frame-bg { position:absolute; inset:0; background-size:cover; background-position:center top; background-color:#1A1035; }
      .sgami-rev-frame-overlay {
        position:absolute; inset:0;
        background:linear-gradient(to bottom,transparent 0%,transparent 45%,rgba(5,4,15,.7) 65%,rgba(5,4,15,.95) 100%);
      }
      .sgami-rev-char {
        position:absolute; bottom:150px; left:50%; transform:translateX(-50%);
        width:163px; height:163px; z-index:10; pointer-events:none;
        display:flex; align-items:center; justify-content:center;
      }
      .sgami-rev-char img { width:100%; height:100%; object-fit:contain; }
      .sgami-rev-char-emoji { font-size:72px; line-height:1; }
      .sgami-rev-info {
        position:absolute; bottom:0; left:0; right:0; height:148px; z-index:11;
        display:flex; flex-direction:column; align-items:center;
        padding:48px 18px 16px; gap:2px;
      }
      .sgami-rev-name  { font-size:22px; font-weight:900; line-height:1; text-align:center; color:#E5E0FF; }
      .sgami-rev-theme { font-size:10px; font-weight:700; text-transform:uppercase; letter-spacing:.1em; opacity:.65; text-align:center; color:#A78BFA; }
      .sgami-rev-extra { font-family:"Space Mono",monospace; font-size:10px; font-weight:700; margin-top:3px; color:rgba(255,255,255,.5); }
      .sgami-rev-logo  { margin-top:auto; font-family:"Space Mono",monospace; font-size:11px; font-weight:700; color:rgba(255,255,255,.55); }
      .sgami-rev-logo span { color:#2DD4BF; }
      .sgami-rev-card-label {
        position:absolute; top:14px; left:50%; transform:translateX(-50%);
        white-space:nowrap; font-size:28px; z-index:12;
        filter:drop-shadow(0 2px 8px rgba(0,0,0,.7));
      }
      .sgami-rev-ring {
        position:absolute; inset:-2px; border-radius:22px; z-index:-1;
        background:linear-gradient(135deg,var(--sgami-primary),var(--sgami-light));
        box-shadow:0 0 32px rgba(var(--sgami-glow-rgb),.65);
      }
      .sgami-rev-card .sgami-rev-char img {
        filter:drop-shadow(0 0 24px rgba(var(--sgami-glow-rgb),.5)) drop-shadow(0 8px 24px rgba(0,0,0,.8));
      }
      .sgami-rev-card .sgami-rev-name { text-shadow:0 0 20px rgba(var(--sgami-glow-rgb),.7); }

      .sgami-rev-card.rev-enter    { animation:sgami-rev-card-spring .85s cubic-bezier(.34,1.56,.64,1) forwards; }
      .sgami-rev-card.rev-floating { animation:sgami-rev-card-float 3.2s ease-in-out infinite; }
      .sgami-rev-card.rev-ring-pulse .sgami-rev-ring { animation:sgami-rev-ring-pulse .5s ease-out !important; }

      #sgami-rev-card-name {
        position:relative; z-index:5;
        font-size:22px; font-weight:900; margin-top:16px;
        color:#fff; text-shadow:0 2px 12px rgba(0,0,0,.6);
        opacity:0; transform:translateY(16px);
        transition:opacity .5s ease,transform .5s ease;
      }
      #sgami-rev-card-name.visible { opacity:1; transform:translateY(0); }
      #sgami-rev-hint {
        position:absolute; bottom:32px; font-family:"Space Mono",monospace;
        font-size:9px; font-weight:700; letter-spacing:.2em; text-transform:uppercase;
        color:rgba(255,255,255,.25); z-index:6;
        opacity:0; transform:translateY(8px); transition:opacity .4s,transform .4s;
        animation:sgami-rev-blink 2s ease-in-out infinite;
      }
      #sgami-rev-hint.visible { opacity:1; transform:translateY(0); }
    `;
    var st = document.createElement("style");
    st.id = "sgami-reveal-styles";
    st.textContent = css;
    document.head.appendChild(st);
  }

  /* ------------------------------------------------------------------ */
  /* Estágios de revelação pixelada                                      */
  /* ------------------------------------------------------------------ */
  var STAGES_8 = [
    { pixelSize: 42, gray: 100, bright: 38 },
    { pixelSize: 38, gray: 100, bright: 42 },
    { pixelSize: 34, gray: 100, bright: 46 },
    { pixelSize: 30, gray: 95,  bright: 50 },
    { pixelSize: 26, gray: 88,  bright: 55 },
    { pixelSize: 20, gray: 78,  bright: 61 },
    { pixelSize: 13, gray: 55,  bright: 72 },
    { pixelSize:  4, gray: 15,  bright: 90 },
    { pixelSize:  1, gray:  0,  bright: 100 },
  ];

  function getStages(n) {
    if (n === 8) return STAGES_8;
    var stages = [];
    for (var i = 0; i <= n; i++) {
      var t = i / n;
      var c = Math.pow(t, 3.2);
      stages.push({
        pixelSize: Math.max(1, Math.round(42 - 41 * c)),
        gray:      Math.round(100 * (1 - c)),
        bright:    Math.round(38 + 62 * c)
      });
    }
    return stages;
  }

  function stageLabel(idx, total) {
    var pct = idx / total;
    if (pct <= 0.25) return "Algo está se formando...";
    if (pct <= 0.5)  return "Uma figura misteriosa!";
    if (pct <= 0.75) return "Quem será?";
    return "Quase lá!";
  }

  /* ------------------------------------------------------------------ */
  /* Partículas — confete colorido (sem tier)                            */
  /* ------------------------------------------------------------------ */
  var _rp = [], _rr = [], _rs = [], _rid = null, _rc = null, _rx = null;

  var CONFETTI_COLORS = [
    "#FF6B6B","#FFD93D","#6BCB77","#4D96FF","#FF922B",
    "#CC5DE8","#F06595","#51CF66","#339AF0","#FCC419"
  ];

  function _pNew(x, y, cfg) {
    var angle = Math.random() * Math.PI * 2;
    var spd   = cfg.speed * (.4 + Math.random() * .9);
    return {
      x:x, y:y, vx:Math.cos(angle)*spd, vy:Math.sin(angle)*spd - cfg.speed*.3,
      alpha:1, decay:cfg.decay+Math.random()*.008,
      color:cfg.colors[Math.floor(Math.random()*cfg.colors.length)],
      size:cfg.sizeMin+Math.random()*(cfg.sizeMax-cfg.sizeMin),
      gravity:cfg.gravity, rot:Math.random()*Math.PI*2,
      rotSpd:(Math.random()-.5)*.18
    };
  }
  function _pDraw(p, c) {
    if (p.alpha<=0) return;
    c.save(); c.globalAlpha=Math.max(0,p.alpha); c.fillStyle=p.color;
    c.translate(p.x,p.y); c.rotate(p.rot);
    c.fillRect(-p.size/2,-p.size/2,p.size,p.size*1.6);
    c.restore();
  }
  function _swNew(x,y,color){return{x:x,y:y,r:10,alpha:.7,color:color};}
  function _swDraw(s,c){if(s.alpha<=0)return;c.save();c.globalAlpha=Math.max(0,s.alpha);c.strokeStyle=s.color;c.lineWidth=3;c.beginPath();c.arc(s.x,s.y,s.r,0,Math.PI*2);c.stroke();c.restore();}
  function _rayNew(cx,cy,angle,color){return{cx:cx,cy:cy,angle:angle,color:color,len:0,maxLen:Math.hypot(window.innerWidth,window.innerHeight)*.5,alpha:0,growing:true};}
  function _rayDraw(r,c){if(r.alpha<=0)return;c.save();c.globalAlpha=Math.max(0,r.alpha);var grd=c.createLinearGradient(r.cx,r.cy,r.cx+Math.cos(r.angle)*r.len,r.cy+Math.sin(r.angle)*r.len);grd.addColorStop(0,r.color);grd.addColorStop(1,"transparent");c.strokeStyle=grd;c.lineWidth=3+Math.random()*2;c.beginPath();c.moveTo(r.cx,r.cy);c.lineTo(r.cx+Math.cos(r.angle)*r.len,r.cy+Math.sin(r.angle)*r.len);c.stroke();c.restore();}

  function _fxLoop() {
    _rx.clearRect(0,0,_rc.width,_rc.height);
    _rr=_rr.filter(function(r){return r.alpha>0;});
    _rs=_rs.filter(function(s){return s.alpha>0;});
    _rp=_rp.filter(function(p){return p.alpha>0;});
    _rr.forEach(function(r){if(r.growing){r.len+=r.maxLen*.04;r.alpha=Math.min(.6,r.alpha+.06);if(r.len>=r.maxLen)r.growing=false;}else{r.alpha-=.025;}_rayDraw(r,_rx);});
    _rs.forEach(function(s){s.r+=14;s.alpha-=.055;_swDraw(s,_rx);});
    _rp.forEach(function(p){p.x+=p.vx;p.y+=p.vy;p.vy+=p.gravity;p.vx*=.985;p.rot+=p.rotSpd;p.alpha-=p.decay;_pDraw(p,_rx);});
    if(_rr.length||_rs.length||_rp.length){_rid=requestAnimationFrame(_fxLoop);}else{_rid=null;}
  }
  function _fxStart(){if(_rid)cancelAnimationFrame(_rid);_rid=requestAnimationFrame(_fxLoop);}

  /* ------------------------------------------------------------------ */
  /* Canvas — revelação pixelada do personagem                           */
  /* ------------------------------------------------------------------ */
  function renderPixelated(ctx, img, canvas, pixelSize, grayPct, brightPct) {
    if (!img || !img.complete || !img.naturalWidth) return;
    var W = canvas.width, H = canvas.height;
    ctx.clearRect(0, 0, W, H);
    if (pixelSize <= 1) {
      ctx.filter = "grayscale(" + grayPct + "%) brightness(" + brightPct + "%)";
      ctx.drawImage(img, 0, 0, W, H);
      ctx.filter = "none";
      return;
    }
    var sw = Math.ceil(W / pixelSize), sh = Math.ceil(H / pixelSize);
    var off = document.createElement("canvas");
    off.width = sw; off.height = sh;
    var octx = off.getContext("2d");
    octx.filter = "grayscale(" + grayPct + "%) brightness(" + brightPct + "%)";
    octx.drawImage(img, 0, 0, sw, sh);
    ctx.imageSmoothingEnabled = false;
    ctx.drawImage(off, 0, 0, W, H);
    ctx.imageSmoothingEnabled = true;
  }

  /* ------------------------------------------------------------------ */
  /* Supabase                                                             */
  /* ------------------------------------------------------------------ */
  async function saveCard(supa, uid, themeSlug, discipline, cardSlug) {
    await supa.from("cards").upsert(
      { user_id: uid, theme_slug: themeSlug, discipline: discipline, card_slug: cardSlug },
      { onConflict: "user_id,theme_slug" }
    );
  }

  async function fetchProgress(supa, uid, themeSlug) {
    // Conta activity_types distintos concluídos neste tema
    var res = await supa.from("activity_log")
      .select("activity_type")
      .eq("user_id", uid)
      .eq("theme_slug", themeSlug);
    var uniqueTypes = new Set((res.data || []).map(function(r) { return r.activity_type; }));
    return { completedCount: uniqueTypes.size };
  }

  /* ------------------------------------------------------------------ */
  /* Modal de personagem pixelado (progressivo por atividade)            */
  /* ------------------------------------------------------------------ */
  function showCharModal(opts) {
    return new Promise(function(resolve) {
      var cfg        = opts.config;
      var stage      = opts.stages[opts.stageIndex];
      var total      = opts.totalActivities;
      var idx        = opts.stageIndex;
      var isComplete = opts.isComplete;
      var barPct     = Math.round((idx / total) * 100) + "%";

      var title, subtitle;
      if (isComplete) {
        title    = "🎉 " + cfg.characterName + " revelado!";
        subtitle = "Módulo completo! Você arrasou! 🌟";
      } else {
        title    = idx <= 2 ? "✨ Algo está se formando..." : "✨ Ficou mais nítido!";
        subtitle = "Personagem misterioso · " + idx + " de " + total + " atividades";
      }

      var cardEmoji = opts.cardSlug ? (CARD_EMOJIS[opts.cardSlug] || "🃏") : "";
      var cardName  = opts.cardSlug ? (CARD_NAMES[opts.cardSlug]  || "Carta") : "";
      var cartaHtml = isComplete && opts.cardSlug ? [
        '<div class="sgami-carta" id="sgami-carta-el">',
        '  <div class="sgami-carta-name">' + cardEmoji + ' Carta ' + cardName + ' desbloqueada!</div>',
        '  <span class="sgami-carta-badge">Nova carta na coleção! 🃏</span>',
        '</div>'
      ].join("") : "";

      var chipsHtml = "";
      if (idx > 0 && !isComplete) {
        chipsHtml += '<span class="sgami-chip">' + stageLabel(idx, total) + '</span>';
      }

      var html = [
        '<div id="sgami-card">',
        '  <div id="sgami-title">' + title + '</div>',
        '  <div id="sgami-subtitle">' + subtitle + '</div>',
        '  <div class="sgami-canvas-wrap" id="sgami-canvas-wrap">',
        '    <canvas id="sgami-char-canvas" width="200" height="240"></canvas>',
        '  </div>',
        '  <div class="sgami-chips">' + chipsHtml + '</div>',
        cartaHtml,
        '  <div class="sgami-bar-wrap"><div class="sgami-bar-fill" style="--sgami-bar-w:' + barPct + '"></div></div>',
        '  <div class="sgami-bar-label">' + idx + ' / ' + total + ' atividades</div>',
        '  <button id="sgami-continue">' + (isComplete ? "Ver minha carta! ✨" : "Continuar →") + '</button>',
        '</div>'
      ].join("");

      var overlay = document.createElement("div");
      overlay.id = "sgami-overlay";
      overlay.innerHTML = html;
      document.body.appendChild(overlay);

      var canvas = overlay.querySelector("#sgami-char-canvas");
      var ctx    = canvas.getContext("2d");
      var wrap   = overlay.querySelector("#sgami-canvas-wrap");

      if (idx > 0) {
        var ANIM_DUR = 800 + idx * 200;
        var animFrom = { pixelSize: 80, gray: 100, bright: 15 };
        var animTo   = { pixelSize: stage.pixelSize, gray: stage.gray, bright: stage.bright };

        function ease(t) { return 1 - Math.pow(1 - t, 3); }
        function lerp(a, b, t) { return a + (b - a) * t; }

        renderPixelated(ctx, opts.img, canvas, animFrom.pixelSize, animFrom.gray, animFrom.bright);

        setTimeout(function() {
          SFX.scanReveal(ANIM_DUR);

          var flash = document.createElement("div");
          flash.className = "sgami-unlock-flash";
          wrap.appendChild(flash);
          setTimeout(function() { if (flash.parentNode) flash.remove(); }, 700);

          var scan = document.createElement("div");
          scan.className = "sgami-scan-line";
          scan.style.animationDuration = ANIM_DUR + "ms";
          wrap.appendChild(scan);
          setTimeout(function() { if (scan.parentNode) scan.remove(); }, ANIM_DUR + 100);

          wrap.classList.remove("sgami-wrap-pop");
          void wrap.offsetWidth;
          wrap.classList.add("sgami-wrap-pop");
          setTimeout(function() { wrap.classList.remove("sgami-wrap-pop"); }, 600);

          var animStart = performance.now();
          function drawFrame() {
            var raw = Math.min(1, (performance.now() - animStart) / ANIM_DUR);
            var t   = ease(raw);
            renderPixelated(ctx, opts.img, canvas,
              Math.max(1, Math.round(lerp(animFrom.pixelSize, animTo.pixelSize, t))),
              Math.round(lerp(animFrom.gray,   animTo.gray,   t)),
              Math.round(lerp(animFrom.bright, animTo.bright, t))
            );
            if (raw < 1) { requestAnimationFrame(drawFrame); }
            else {
              if (isComplete) { wrap.classList.add("done"); SFX.characterComplete(); }
              else            { SFX.stageProgress(); }
            }
          }
          drawFrame();
        }, 500);

        if (isComplete) {
          setTimeout(function() {
            var el = overlay.querySelector("#sgami-carta-el");
            if (el) el.classList.add("show");
          }, 500 + ANIM_DUR + 300);
        }
      } else {
        renderPixelated(ctx, opts.img, canvas, stage.pixelSize, stage.gray, stage.bright);
      }

      overlay.querySelector("#sgami-continue").addEventListener("click", function() {
        overlay.style.animation = "sgami-fadein .25s ease reverse forwards";
        setTimeout(function() { overlay.remove(); resolve(); }, 250);
      });
    });
  }

  /* ------------------------------------------------------------------ */
  /* Reveal cinematográfico da carta temática                            */
  /* ------------------------------------------------------------------ */
  function showReveal(cardSlug, config, opts) {
    return new Promise(function(resolve) {
      injectRevealStyles();
      opts = opts || {};

      var base         = config.assetBase || "../../";
      var cardBgUrl    = base + "_landing/cartas/carta-fundo-" + cardSlug + ".png";
      var cardEmoji    = CARD_EMOJIS[cardSlug] || "🃏";
      var cardLabel    = CARD_NAMES[cardSlug]  || "Carta";
      var primaryColor = config.primaryColor   || "#A78BFA";
      var lightColor   = config.lightColor     || "#C4B5FD";
      var glowRgb      = config.glowRgb        || "167,139,250";

      var old = document.getElementById("sgami-rev-overlay");
      if (old) old.remove();

      var overlay = document.createElement("div");
      overlay.id = "sgami-rev-overlay";

      var charInner = config.characterImg
        ? '<img src="' + base + "_landing/" + config.characterImg + '" alt="' + config.characterName + '">'
        : '<span class="sgami-rev-char-emoji">' + (config.characterEmoji || "⭐") + "</span>";

      var cssVars = "--sgami-primary:" + primaryColor + ";--sgami-light:" + lightColor + ";--sgami-glow-rgb:" + glowRgb;

      overlay.innerHTML = [
        '<div id="sgami-rev-bg"></div>',
        '<div id="sgami-rev-glow"></div>',
        '<canvas id="sgami-rev-canvas"></canvas>',
        '<div id="sgami-rev-flash"></div>',
        '<div id="sgami-rev-title"></div>',
        '<div id="sgami-rev-stage">',
        '  <div class="sgami-rev-card" id="sgami-rev-card" style="' + cssVars + '">',
        '    <div class="sgami-rev-ring"></div>',
        '    <div class="sgami-rev-frame">',
        '      <div class="sgami-rev-frame-bg" style="background-image:url(\'' + cardBgUrl + '\')"></div>',
        '      <div class="sgami-rev-frame-overlay"></div>',
        '    </div>',
        '    <div class="sgami-rev-card-label">' + cardEmoji + '</div>',
        '    <div class="sgami-rev-char">' + charInner + '</div>',
        '    <div class="sgami-rev-info">',
        '      <div class="sgami-rev-name">' + config.characterName + '</div>',
        '      <div class="sgami-rev-theme">' + (config.themeLabel || "") + '</div>',
        '      <div class="sgami-rev-extra">Carta ' + cardLabel + ' ' + cardEmoji + '</div>',
        '      <div class="sgami-rev-logo">sabendo<span>.</span></div>',
        '    </div>',
        '  </div>',
        '</div>',
        '<div id="sgami-rev-card-name"></div>',
        '<div id="sgami-rev-hint">toque para continuar</div>',
      ].join("");
      document.body.appendChild(overlay);

      _rc = overlay.querySelector("#sgami-rev-canvas");
      _rx = _rc.getContext("2d");
      _rc.width = window.innerWidth; _rc.height = window.innerHeight;
      _rp = []; _rr = []; _rs = [];
      if (_rid) { cancelAnimationFrame(_rid); _rid = null; }

      var card       = overlay.querySelector("#sgami-rev-card");
      var titleEl    = overlay.querySelector("#sgami-rev-title");
      var cardNameEl = overlay.querySelector("#sgami-rev-card-name");
      var cont       = overlay.querySelector("#sgami-rev-hint");
      var glow       = overlay.querySelector("#sgami-rev-glow");
      var flash      = overlay.querySelector("#sgami-rev-flash");

      card.style.cssText = "opacity:0;transform:scale(0.05) rotate(-10deg);animation:none;" + cssVars;

      // Título animado letra a letra
      var TEXT = "NOVA CARTA OBTIDA!";
      titleEl.innerHTML = "";
      TEXT.split("").forEach(function(ch, i) {
        if (ch === " ") { var sp=document.createElement("span"); sp.className="sgami-rev-space"; titleEl.appendChild(sp); }
        else { var s=document.createElement("span"); s.className="sgami-rev-letter"; s.textContent=ch; s.style.animationDelay=(i*38)+"ms"; titleEl.appendChild(s); }
      });

      cardNameEl.textContent = cardEmoji + " " + cardLabel;
      glow.style.background = "radial-gradient(ellipse at center,rgba(" + glowRgb + ",.22) 0%,transparent 65%)";

      overlay.style.display = "flex"; overlay.offsetHeight; overlay.classList.add("active");

      var canClose = false;
      overlay.addEventListener("click", function handler() {
        if (!canClose) return;
        overlay.removeEventListener("click", handler);
        overlay.style.transition = "opacity .35s"; overlay.style.opacity = "0";
        setTimeout(function() { overlay.remove(); _rp=[];_rr=[];_rs=[]; if(_rid){cancelAnimationFrame(_rid);_rid=null;} resolve(); }, 350);
      });

      var pCfg = { count:90, speed:8, gravity:.035, colors:CONFETTI_COLORS, sizeMin:6, sizeMax:14, decay:.010 };

      function at(fn, delay) { setTimeout(fn, delay); }
      at(function(){ glow.style.transition="opacity 1s"; glow.style.opacity="1"; SFX.cardRevealBuild(); }, 300);
      at(function(){
        card.style.cssText = cssVars;
        void card.offsetWidth;
        card.classList.add("rev-enter");
        SFX.cardEntry();
      }, 820);
      at(function(){
        flash.style.background = "rgba(255,255,255,.7)";
        flash.className=""; flash.offsetHeight; flash.classList.add("pop");
        SFX.cardFlash();
      }, 900);
      at(function(){
        var r = card.getBoundingClientRect();
        var cx = r.left + r.width/2, cy = r.top + r.height/2;
        _rs.push(_swNew(cx, cy, primaryColor));
        for(var i=0;i<12;i++) _rr.push(_rayNew(cx, cy, (i/12)*Math.PI*2, primaryColor));
        _fxStart();
        SFX.shockwave();
      }, 980);
      at(function(){
        var r = card.getBoundingClientRect();
        var cx = r.left + r.width/2, cy = r.top + r.height/3;
        for(var i=0;i<pCfg.count;i++) _rp.push(_pNew(cx, cy, pCfg));
        _fxStart(); SFX.sparkle();
      }, 1100);
      at(function(){
        var r = card.getBoundingClientRect();
        var cx = r.left + r.width/2, cy = r.top + r.height/2;
        for(var i=0;i<Math.floor(pCfg.count*.6);i++) _rp.push(_pNew(cx, cy, pCfg));
        SFX.sparkle();
      }, 1400);
      at(function(){ card.classList.add("rev-ring-pulse"); setTimeout(function(){card.classList.remove("rev-ring-pulse");},600); }, 1350);
      at(function(){ card.classList.remove("rev-enter"); void card.offsetWidth; card.classList.add("rev-floating"); }, 1700);
      at(function(){ cardNameEl.classList.add("visible"); SFX.celebration(); }, 1850);
      at(function(){ cont.classList.add("visible"); canClose=true; }, 2800);
    });
  }

  /* ------------------------------------------------------------------ */
  /* run() — ponto de entrada principal                                  */
  /* ------------------------------------------------------------------ */
  async function run(supa, uid, themeSlug, discipline, config) {
    loadSpaceMono();

    var totalActivities = config.totalActivities || 5;
    var stages          = getStages(totalActivities);
    var base            = config.assetBase || "../../";

    injectStyles(config.primaryColor, config.lightColor, config.bgColor, config.glowRgb || "167,139,250");

    var progress   = await fetchProgress(supa, uid, themeSlug);
    // stageIndex ANTES de registrar esta atividade (já contabilizada pelo caller)
    var stageIndex = Math.min(progress.completedCount, totalActivities);
    var isComplete = stageIndex >= totalActivities;

    var cardSlug = null;

    if (isComplete) {
      var cardRes = await supa.from("cards").select("card_slug")
        .eq("user_id", uid).eq("theme_slug", themeSlug).maybeSingle();

      if (!cardRes.data) {
        cardSlug = randomCard();
        await saveCard(supa, uid, themeSlug, discipline, cardSlug);
      } else {
        cardSlug = cardRes.data.card_slug;
      }
    }

    // Carrega portrait do personagem
    var img = null;
    if (config.characterImg) {
      img = new Image();
      img.src = base + "_landing/" + config.characterImg;
      await new Promise(function(res) {
        if (img.complete && img.naturalWidth) { res(); return; }
        img.onload = res; img.onerror = res;
      });
    }

    await showCharModal({
      stageIndex:      stageIndex,
      totalActivities: totalActivities,
      stages:          stages,
      img:             img,
      isComplete:      isComplete,
      cardSlug:        cardSlug,
      config:          config
    });

    // Reveal cinematográfico apenas na primeira conclusão total do módulo
    if (isComplete && cardSlug) {
      var cardRes2 = await supa.from("cards").select("created_at,updated_at")
        .eq("user_id", uid).eq("theme_slug", themeSlug).maybeSingle();
      var justCreated = cardRes2.data &&
        Math.abs(new Date(cardRes2.data.created_at) - new Date(cardRes2.data.updated_at)) < 5000;
      if (justCreated) {
        await showReveal(cardSlug, config);
      }
    }

    if (config.backUrl) window.location.href = config.backUrl;
  }

  /* ------------------------------------------------------------------ */
  /* Export                                                               */
  /* ------------------------------------------------------------------ */
  window.SabendoGamification = { run: run, showReveal: showReveal };

  window._sgamiTest = {
    sfx: SFX,
    showReveal: showReveal,
    showCharModal: showCharModal,
    getStages: getStages,
    renderPixelated: renderPixelated,
    randomCard: randomCard,
    THEMATIC_CARDS: THEMATIC_CARDS,
    CARD_EMOJIS: CARD_EMOJIS,
    CARD_NAMES: CARD_NAMES
  };
})();
