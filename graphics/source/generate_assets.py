#!/usr/bin/env python3
"""Generate Paddock Legacy's lightweight, editable SVG foundation assets."""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
G = ROOT / "graphics"

DIRS = [
    "manifest", "ui/backgrounds", "ui/panels", "ui/buttons", "ui/cards", "ui/hud", "ui/navigation",
    "icons/racing", "icons/weather", "icons/tyres", "icons/finance", "icons/drivers", "icons/teams", "icons/ui",
    "cars/kart", "cars/f4", "cars/placeholders", "circuits/test_track", "circuits/props", "circuits/environments",
    "buildings", "portraits/components", "portraits/generated", "flags", "logos", "sponsors", "effects",
    "shaders", "source", "placeholders", "demo",
]
for d in DIRS:
    (G / d).mkdir(parents=True, exist_ok=True)

assets = {}
def save(rel, body, kind="icon"):
    path = G / rel
    path.write_text(body, encoding="utf-8")
    aid = path.stem
    assets[aid] = {"path": f"res://graphics/{rel}", "type": kind, "version": 1}

def svg(body, w=128, h=128, view=None):
    return f'''<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="{view or f'0 0 {w} {h}'}">
<defs><linearGradient id="g" x2="1" y2="1"><stop stop-color="#18d3c5"/><stop offset="1" stop-color="#3d7cff"/></linearGradient></defs>{body}</svg>'''

# Icons: a consistent rounded 24px-line language, intentionally monochrome/tintable.
weather = {
 "clear": '<circle cx="64" cy="64" r="23"/><g stroke="#f5f7fa" stroke-width="7">' + ''.join(f'<path d="M64 {x}v{x-16}"/>' for x in []) + '<path d="M64 12v15M64 101v15M12 64h15M101 64h15M27 27l11 11M90 90l11 11M101 27L90 38M38 90L27 101"/></g>',
 "cloudy": '<path d="M32 93h65a21 21 0 0 0 0-42 35 35 0 0 0-66-5A24 24 0 0 0 32 93z"/>',
 "light_rain": '<path d="M28 77h72a20 20 0 0 0-4-40 34 34 0 0 0-63 3A19 19 0 0 0 28 77z"/><path d="M45 91l-7 17M68 91l-7 17M91 91l-7 17" stroke="#f5f7fa" stroke-width="6"/>',
 "rain": '<path d="M28 72h72a20 20 0 0 0-4-40 34 34 0 0 0-63 3A19 19 0 0 0 28 72z"/><path d="M42 84l-9 25M67 84l-9 25M92 84l-9 25" stroke="#f5f7fa" stroke-width="8"/>',
 "heavy_rain": '<path d="M25 67h78a21 21 0 0 0-5-42 36 36 0 0 0-68 4A20 20 0 0 0 25 67z"/><path d="M38 78l-11 34M62 78l-11 34M86 78l-11 34M110 78l-11 34" stroke="#f5f7fa" stroke-width="9"/>',
 "drying": '<path d="M28 75h72a20 20 0 0 0-4-40 34 34 0 0 0-63 3A19 19 0 0 0 28 75z"/><path d="M48 88l-7 18M73 88l-7 18" stroke="#f5f7fa" stroke-width="6"/><circle cx="96" cy="94" r="17" fill="none" stroke="#f5f7fa" stroke-width="6"/>',
}
for name, shape in weather.items(): save(f"icons/weather/icon_weather_{name}.svg", svg(f'<g fill="#f5f7fa">{shape}</g>'))

tyres = {"soft":"#e95b64","medium":"#f5c85b","hard":"#e9edf2","intermediate":"#42d69a","wet":"#4da3ff"}
for name, color in tyres.items():
    save(f"icons/tyres/icon_tyre_{name}.svg", svg(f'<circle cx="64" cy="64" r="45" fill="#151c29" stroke="{color}" stroke-width="10"/><circle cx="64" cy="64" r="22" fill="#283246"/><path d="M64 42v44M42 64h44" stroke="{color}" stroke-width="5"/><circle cx="64" cy="64" r="8" fill="{color}"/>'))

racing = ["attack","push","normal","conserve","pit","damage","warning","safety_car","yellow_flag","red_flag","engine","gearbox","brakes","aero","suspension"]
symbols = ["▲","»","●","▽","P","!","!","SC","⚑","⚑","E","G","B","A","S"]
for name, symbol in zip(racing, symbols):
    save(f"icons/racing/icon_{name}.svg", svg(f'<path d="M64 10l47 27v54l-47 27L17 91V37z" fill="#202a3b" stroke="#91a0b7" stroke-width="4"/><text x="64" y="78" text-anchor="middle" font-family="sans-serif" font-size="42" font-weight="800" fill="#f5f7fa">{symbol}</text>'))

general = {"money":"$","reputation":"★","driver":"◉","team":"◆","sponsor":"S","calendar":"▦","trophy":"♜"}
folders = {"money":"finance","reputation":"drivers","driver":"drivers","team":"teams","sponsor":"finance","calendar":"ui","trophy":"racing"}
for name, symbol in general.items():
    save(f"icons/{folders[name]}/icon_{name}.svg", svg(f'<circle cx="64" cy="64" r="48" fill="#202a3b"/><text x="64" y="82" text-anchor="middle" font-family="sans-serif" font-size="52" font-weight="800" fill="#f5f7fa">{symbol}</text>'))

# Fictitious sponsors and team marks.
sponsors = [("voltaris","V","energy"),("nexora","N","technology"),("aegisure","A","insurance"),("motivex","M","equipment"),("orbian","O","banking"),("telvanta","T","telecom"),("velocargo","VC","transport"),("codeshift","CS","software")]
for i,(name,mark,_) in enumerate(sponsors):
    hue=["#18d3c5","#ffb547","#8f7cff","#ff6b78","#4da3ff","#d5ec62","#f28bd1","#7ee09b"][i]
    save(f"sponsors/logo_sponsor_{name}.svg", svg(f'<rect x="10" y="26" width="108" height="76" rx="20" fill="#111827"/><path d="M24 87L45 41h16L40 87z" fill="{hue}"/><text x="78" y="78" text-anchor="middle" font-family="sans-serif" font-size="28" font-weight="900" fill="#f5f7fa">{mark}</text>'))
teams=[("apex_nova","AN"),("vector_peak","VP"),("ember_fox","EF"),("northstar","NS"),("kinetic_arc","KA"),("silver_finch","SF")]
for i,(name,mark) in enumerate(teams):
    save(f"logos/logo_team_{name}.svg", svg(f'<path d="M64 8l49 28-12 57-37 27-37-27-12-57z" fill="#172131" stroke="{["#18d3c5","#ffb547","#ff6b78","#4da3ff","#8f7cff","#d5ec62"][i]}" stroke-width="7"/><text x="64" y="78" text-anchor="middle" font-family="sans-serif" font-size="31" font-weight="900" fill="#f5f7fa">{mark}</text>'))

# Recolourable cars: #18d3c5 primary, #3d7cff secondary, #ffb547 accent are documented swatches.
kart='<ellipse cx="256" cy="166" rx="180" ry="32" fill="#090d14" opacity=".35"/><g stroke="#080b10" stroke-width="8"><rect x="80" y="95" width="58" height="74" rx="18" fill="#252c39"/><rect x="374" y="95" width="58" height="74" rx="18" fill="#252c39"/><rect x="102" y="165" width="62" height="54" rx="18" fill="#252c39"/><rect x="348" y="165" width="62" height="54" rx="18" fill="#252c39"/></g><path d="M132 110l74-45h112l68 45-35 78H159z" fill="#18d3c5"/><path d="M176 104h161l-22 85H197z" fill="#3d7cff"/><path d="M217 73h79l24 43H193z" fill="#121824"/><circle cx="256" cy="91" r="24" fill="#ffb547"/><path d="M139 150h234" stroke="#ffb547" stroke-width="12"/><rect x="227" y="132" width="58" height="48" rx="12" fill="#f5f7fa"/><text x="256" y="168" text-anchor="middle" font-family="sans-serif" font-weight="900" font-size="38" fill="#111827">01</text>'
save("cars/kart/car_kart_01.svg",svg(kart,512,256),"vehicle")
f4='<ellipse cx="360" cy="224" rx="275" ry="30" fill="#090d14" opacity=".35"/><g fill="#202735" stroke="#090d14" stroke-width="8"><rect x="82" y="90" width="105" height="62" rx="16"/><rect x="533" y="90" width="105" height="62" rx="16"/><rect x="110" y="190" width="110" height="62" rx="16"/><rect x="500" y="190" width="110" height="62" rx="16"/></g><path d="M174 110l113-46h150l108 47-57 100H230z" fill="#18d3c5"/><path d="M287 65h150l52 146H232z" fill="#3d7cff"/><path d="M331 73h61l55 111H282z" fill="#101725"/><circle cx="360" cy="93" r="27" fill="#ffb547"/><path d="M112 145h496l-14 28H126z" fill="#18d3c5"/><path d="M245 177h230" stroke="#ffb547" stroke-width="14"/><rect x="330" y="153" width="60" height="48" rx="10" fill="#f5f7fa"/><text x="360" y="189" text-anchor="middle" font-family="sans-serif" font-weight="900" font-size="38" fill="#111827">01</text>'
save("cars/f4/car_f4_01.svg",svg(f4,720,288),"vehicle")

# Livery masks/patterns (white masks are modulated by the consuming material).
patterns={"solid":'<rect width="256" height="128" fill="white"/>',"stripe":'<path d="M100 0h56l-30 128H70z" fill="white"/>',"double_stripe":'<path d="M70 0h26L66 128H40zM145 0h26l-30 128h-26z" fill="white"/>',"diagonal":'<path d="M0 95L190 0h66v34L60 128H0z" fill="white"/>',"geometric":'<path d="M0 0h95L40 65h80l-55 63H0zM180 0h76v128h-28l-50-55z" fill="white"/>',"gradient":'<defs><linearGradient id="m"><stop stop-color="white"/><stop offset="1" stop-color="white" stop-opacity="0"/></linearGradient></defs><rect width="256" height="128" fill="url(#m)"/>'}
for name,shape in patterns.items(): save(f"cars/placeholders/livery_pattern_{name}.svg",svg(shape,256,128),"mask")

# Track and modular props.
track='<rect width="1024" height="576" fill="#244835"/><path d="M185 430C60 330 105 105 305 96h340c226 0 310 245 139 357-100 66-234 17-314-22-99-48-195 88-285-1z" fill="none" stroke="#8c96a1" stroke-width="116"/><path d="M185 430C60 330 105 105 305 96h340c226 0 310 245 139 357-100 66-234 17-314-22-99-48-195 88-285-1z" fill="none" stroke="#313944" stroke-width="92"/><path d="M185 430C60 330 105 105 305 96h340c226 0 310 245 139 357-100 66-234 17-314-22-99-48-195 88-285-1z" fill="none" stroke="#7d8792" stroke-width="3" stroke-dasharray="18 20"/><path d="M282 54v84" stroke="#f5f7fa" stroke-width="9" stroke-dasharray="9"/><path d="M620 175h260v46H620z" fill="#596574"/><path d="M620 198h260" stroke="#f5f7fa" stroke-width="4" stroke-dasharray="12"/><g fill="#172131"><rect x="45" y="42" width="150" height="48"/><rect x="820" y="450" width="145" height="62"/></g><g fill="#53785d"><circle cx="50" cy="220" r="26"/><circle cx="920" cy="180" r="31"/><circle cx="740" cy="520" r="24"/></g>'
save("circuits/test_track/test_track_01.svg",svg(track,1024,576),"track")
props={"track_straight":'<rect y="34" width="256" height="60" fill="#303844"/><path d="M0 64h256" stroke="#7d8792" stroke-dasharray="16"/>',"kerb":'<path d="M0 40h256v48H0z" fill="#e9edf2"/><path d="M0 40h32v48H0zm64 0h32v48H64zm64 0h32v48h-32zm64 0h32v48h-32z" fill="#e95b64"/>',"grass":'<rect width="256" height="128" fill="#315c42"/><path d="M0 95L60 50l55 40 52-65 89 65v38H0z" fill="#3d6c4c"/>',"gravel":'<rect width="256" height="128" fill="#9b8767"/><g fill="#b9a27c"><circle cx="30" cy="40" r="5"/><circle cx="96" cy="82" r="7"/><circle cx="175" cy="45" r="6"/><circle cx="220" cy="96" r="5"/></g>',"barrier":'<path d="M5 40h246v45H5z" fill="#cbd2da" stroke="#4b5666" stroke-width="6"/><path d="M20 85v30m216-30v30" stroke="#4b5666" stroke-width="9"/>',"cone":'<path d="M64 20l30 80H34z" fill="#ff8a45"/><path d="M20 100h88v16H20z" fill="#f5f7fa"/>',"start_line":'<rect width="128" height="128" fill="#f5f7fa"/><path d="M0 0h32v32H0zm64 0h32v32H64zM32 32h32v32H32zm64 0h32v32H96zM0 64h32v32H0zm64 0h32v32H64zM32 96h32v32H32zm64 0h32v32H96z" fill="#172131"/>',"sign":'<rect x="10" y="25" width="108" height="65" rx="8" fill="#172131" stroke="#18d3c5" stroke-width="5"/><path d="M32 90v30m64-30v30" stroke="#7d8792" stroke-width="8"/>',"tree":'<circle cx="64" cy="52" r="42" fill="#3d704b"/><circle cx="42" cy="63" r="30" fill="#315c42"/><path d="M58 78h14v45H58z" fill="#755b43"/>',"grandstand":'<path d="M12 100h105L94 30H35z" fill="#566274"/><path d="M28 82h78M24 65h75M32 47h62" stroke="#d7dde5" stroke-width="8"/>',"paddock_building":'<rect x="8" y="34" width="112" height="78" fill="#273244"/><path d="M0 34h128L108 14H20z" fill="#18d3c5"/><rect x="26" y="63" width="28" height="49" fill="#101725"/><rect x="70" y="58" width="33" height="22" fill="#4da3ff"/>',"light":'<path d="M58 30h12v92H58z" fill="#657185"/><path d="M40 18h48v28H40z" fill="#f5e7ad"/>',"tv_camera":'<rect x="21" y="31" width="75" height="52" rx="8" fill="#283246"/><path d="M96 43l25-10v48L96 70zM58 83v17m-26 22l26-22 27 22" fill="#657185" stroke="#657185" stroke-width="8"/>'}
for name,shape in props.items(): save(f"circuits/props/prop_{name}.svg",svg(shape,256 if name in ["track_straight","kerb","grass","gravel"] else 128,128),"prop")

# Portrait system and examples.
skins=["#f2c6a5","#d99b72","#a9674b","#704536"]
for i,skin in enumerate(skins,1): save(f"portraits/components/driver_head_{i:02}.svg",svg(f'<path d="M32 34q32-28 64 0v42q-8 38-32 40-24-2-32-40z" fill="{skin}"/><circle cx="49" cy="62" r="4" fill="#172131"/><circle cx="79" cy="62" r="4" fill="#172131"/><path d="M52 91q12 8 24 0" fill="none" stroke="#603d35" stroke-width="3"/>'),"portrait_component")
for i in range(1,7): save(f"portraits/components/driver_hair_{i:02}.svg",svg(f'<path d="M28 51Q{30+i*5} {8+i*2} {100-i*2} {42+i}L91 52Q64 {30+i} 33 58z" fill="{["#231c19","#6f4930","#d2a86f","#3b2c29","#8c4d35","#16171b"][i-1]}"/>'),"portrait_component")
for i,c in enumerate(["#18d3c5","#3d7cff","#ff6b78"],1): save(f"portraits/components/driver_suit_{i:02}.svg",svg(f'<path d="M12 128q6-40 42-47h20q36 7 42 47z" fill="{c}"/><path d="M64 84v44" stroke="#f5f7fa" stroke-width="5"/>'),"portrait_component")
for i in range(1,5):
    save(f"portraits/generated/portrait_driver_{i:02}.svg",svg(f'<rect width="128" height="128" rx="18" fill="#202a3b"/><path d="M12 128q6-40 42-47h20q36 7 42 47z" fill="{["#18d3c5","#3d7cff","#ff6b78","#8f7cff"][i-1]}"/><path d="M32 34q32-28 64 0v42q-8 38-32 40-24-2-32-40z" fill="{skins[i-1]}"/><path d="M28 52q13-42 72-12L91 53Q62 30 33 58z" fill="{["#231c19","#6f4930","#16171b","#3b2c29"][i-1]}"/><circle cx="49" cy="62" r="4" fill="#172131"/><circle cx="79" cy="62" r="4" fill="#172131"/><path d="M53 91q11 7 22 0" fill="none" stroke="#603d35" stroke-width="3"/>'),"portrait")

# Flags and clean placeholders.
flags={"france":["#244aa5","#f5f7fa","#e04852"],"italy":["#23945d","#f5f7fa","#df4452"],"spain":["#d9444e","#f4c542","#d9444e"],"germany":["#17191d","#df4452","#f4c542"],"united_states":["#35509b","#f5f7fa","#d9444e"],"japan":["#f5f7fa","#df4452","#f5f7fa"],"australia":["#243f83","#f5f7fa","#e0525c"],"united_kingdom":["#283f82","#f5f7fa","#d84650"]}
for name,cs in flags.items(): save(f"flags/flag_{name}.svg",svg(f'<rect width="128" height="42" y="1" fill="{cs[0]}"/><rect width="128" height="42" y="43" fill="{cs[1]}"/><rect width="128" height="42" y="85" fill="{cs[2]}"/>',128,128),"flag")
for name,symbol in [("car","▰"),("driver","◉"),("team","◆"),("track","⌁"),("logo","◇"),("icon","+")]: save(f"placeholders/placeholder_{name}.svg",svg(f'<rect x="5" y="5" width="118" height="118" rx="18" fill="#202a3b" stroke="#69778d" stroke-width="5" stroke-dasharray="9"/><text x="64" y="82" text-anchor="middle" font-family="sans-serif" font-size="52" fill="#91a0b7">{symbol}</text>'),"placeholder")

(ROOT/"shared").mkdir(exist_ok=True)
registered_files = {
    "paddock_theme": ("graphics/ui/paddock_theme.tres", "theme"),
    "livery_recolor": ("graphics/shaders/livery_recolor.gdshader", "shader"),
    "selection_highlight": ("graphics/shaders/selection_highlight.gdshader", "shader"),
    "effect_rain": ("graphics/effects/effect_rain.tscn", "effect"),
    "effect_dust": ("graphics/effects/effect_dust.tscn", "effect"),
    "effect_sparks": ("graphics/effects/effect_sparks.tscn", "effect"),
    "effect_smoke": ("graphics/effects/effect_smoke.tscn", "effect"),
    "ui_demo": ("graphics/demo/ui_demo.tscn", "demo_scene"),
    "dashboard_demo": ("graphics/demo/dashboard_demo.tscn", "demo_scene"),
    "race_visual_demo": ("graphics/demo/race_visual_demo.tscn", "demo_scene"),
}
for aid, (path, kind) in registered_files.items():
    if (ROOT / path).exists():
        assets[aid] = {"path": f"res://{path}", "type": kind, "version": 1}
(ROOT/"shared/graphics_manifest.json").write_text(json.dumps(dict(sorted(assets.items())),indent=2)+"\n")
(ROOT/"shared/asset_ids.json").write_text(json.dumps({k:k for k in sorted(assets)},indent=2)+"\n")
print(f"Generated {len(assets)} registered assets")
