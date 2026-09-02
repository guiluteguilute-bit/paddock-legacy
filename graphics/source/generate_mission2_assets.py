#!/usr/bin/env python3
"""Generate Mission 2's lightweight karting-career visual kit.

The script only owns Mission 2 files and merges their stable IDs into the existing
registries. It deliberately contains no gameplay, persistence, scoring or economy.
"""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
G = ROOT / "graphics"
assets = {}


def svg(body, w=128, h=128, defs=""):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" '
            f'viewBox="0 0 {w} {h}"><defs>{defs}</defs>{body}</svg>')


def save(rel, body, kind):
    path = G / rel
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(body, encoding="utf-8")
    assets[path.stem] = {"path": f"res://graphics/{rel}", "type": kind, "version": 1}


def register(rel, kind, aid=None):
    assets[aid or Path(rel).stem] = {"path": f"res://graphics/{rel}", "type": kind, "version": 1}


# Six additional original, monochrome-friendly team marks (12 total).
teams = [
    ("crimson_orbit", "CO", "#ff6b78"), ("helix_racing", "HR", "#18d3c5"),
    ("lumen_motorsport", "LM", "#ffb547"), ("meridian_kart", "MK", "#4da3ff"),
    ("pulse_competition", "PC", "#8f7cff"), ("vertex_union", "VU", "#d5ec62"),
]
for name, mark, color in teams:
    save(f"logos/logo_team_{name}.svg", svg(
        f'<path d="M64 7l47 22v52l-47 40L17 81V29z" fill="#111927" stroke="{color}" stroke-width="7"/>'
        f'<path d="M28 41h72L64 103z" fill="none" stroke="#f5f7fa" stroke-width="6"/>'
        f'<text x="64" y="75" text-anchor="middle" font-family="sans-serif" font-size="24" font-weight="900" fill="#f5f7fa">{mark}</text>', 128, 128), "team_logo")

# Four additional fictional sponsors (12 total), covering drinks and automotive.
sponsors = [
    ("nova_energy", "NE", "#18d3c5"), ("driftline_auto", "DA", "#ff6b78"),
    ("bluepulse", "BP", "#4da3ff"), ("railbird", "RB", "#ffb547"),
]
for name, mark, color in sponsors:
    save(f"sponsors/logo_sponsor_{name}.svg", svg(
        f'<rect x="7" y="25" width="114" height="78" rx="17" fill="#111927" stroke="#2d3b50" stroke-width="3"/>'
        f'<path d="M20 86l21-44h18L42 86z" fill="{color}"/>'
        f'<text x="82" y="78" text-anchor="middle" font-family="sans-serif" font-size="25" font-weight="900" fill="#f5f7fa">{mark}</text>'), "sponsor_logo")

# Portrait expansion: eight heads, ten hairstyles and tintable backgrounds.
skins = ["#efbea0", "#c98561", "#8f5945", "#5d392f"]
for idx in range(5, 9):
    skin = skins[idx - 5]
    jaw = 36 + (idx % 3) * 3
    save(f"portraits/components/driver_head_{idx:02}.svg", svg(
        f'<path d="M{jaw} 31Q64 12 {128-jaw} 31v45q-7 38-32 42-25-4-32-42z" fill="{skin}"/>'
        '<circle cx="49" cy="63" r="4" fill="#172131"/><circle cx="79" cy="63" r="4" fill="#172131"/>'
        '<path d="M51 91q13 8 26 0" fill="none" stroke="#603d35" stroke-width="3"/>', 128, 128), "portrait_component")
hair_shapes = [
    '<path d="M27 56Q30 10 97 30l7 25-17-12-12 8-14-12-28 21z"/>',
    '<path d="M28 58Q19 18 65 15q43 4 37 43L86 42 67 55 48 40z"/>',
    '<path d="M30 57q2-45 68-27l4 29-18-16-20 8-18-10z"/>',
    '<path d="M28 56q8-36 33-38 37 0 42 38L89 43H41z"/>',
]
for idx, shape in enumerate(hair_shapes, 7):
    save(f"portraits/components/driver_hair_{idx:02}.svg", svg(f'<g fill="#2b2020">{shape}</g>'), "portrait_component")
for idx, (a, b) in enumerate([("#172b3d", "#18d3c5"), ("#2d203d", "#8f7cff"), ("#38251d", "#ffb547"), ("#16352f", "#42d69a")], 1):
    defs = f'<linearGradient id="bg" x2="1" y2="1"><stop stop-color="{a}"/><stop offset="1" stop-color="{b}"/></linearGradient>'
    save(f"portraits/components/driver_background_{idx:02}.svg", svg('<rect width="128" height="128" rx="18" fill="url(#bg)"/><path d="M0 100L128 34v94H0z" fill="#090e17" opacity=".28"/>', 128, 128, defs), "portrait_component")

# Kart V2 family: three sentinel-colour liveries, detailed shared visual language.
def kart_body(variant):
    front = {1: 112, 2: 92, 3: 128}[variant]
    rear = {1: 404, 2: 420, 3: 384}[variant]
    return (f'<ellipse cx="256" cy="210" rx="205" ry="25" fill="#05080d" opacity=".55"/>'
        f'<g fill="#171d28" stroke="#05080d" stroke-width="7"><rect x="{front-38}" y="85" width="62" height="72" rx="16"/><rect x="{rear-24}" y="85" width="62" height="72" rx="16"/><rect x="{front-25}" y="172" width="66" height="57" rx="16"/><rect x="{rear-38}" y="172" width="66" height="57" rx="16"/></g>'
        '<path d="M125 122l82-56h102l81 56-35 82H158z" fill="#18d3c5" stroke="#081019" stroke-width="5"/>'
        f'<path d="M{154-variant*5} 120h{210+variant*9}l-22 69H174z" fill="#3d7cff"/>'
        '<path d="M202 78h108l31 52H173z" fill="#121824"/><circle cx="256" cy="92" r="25" fill="#ffb547" stroke="#f5f7fa" stroke-width="4"/>'
        '<path d="M130 153h252" stroke="#ffb547" stroke-width="11"/><path d="M183 204h146" stroke="#738196" stroke-width="8"/>'
        '<rect x="229" y="139" width="54" height="46" rx="10" fill="#f5f7fa"/><circle cx="356" cy="128" r="24" fill="#273244"/><path d="M352 105v46M366 108v40" stroke="#8995a5" stroke-width="5"/>')
for i in range(1, 4):
    save(f"cars/kart/car_kart_{i:02}.svg", svg(kart_body(i), 512, 256), "vehicle")
assets["car_kart_01"]["version"] = 2  # Stable ID, visually upgraded in Mission 2.

components = {
    "chassis": '<path d="M15 95h98M28 36l22 59m50-59L78 95" fill="none" stroke="#91a0b7" stroke-width="10"/><rect x="28" y="88" width="72" height="24" rx="9" fill="#18d3c5"/>',
    "bodywork": '<path d="M12 82l22-52h61l22 52-24 29H36z" fill="#18d3c5"/><path d="M35 52h58L82 88H46z" fill="#3d7cff"/><path d="M18 84h92" stroke="#ffb547" stroke-width="8"/>',
    "wheels": '<g fill="#161c26" stroke="#080b10" stroke-width="6"><circle cx="36" cy="64" r="27"/><circle cx="92" cy="64" r="27"/></g><circle cx="36" cy="64" r="10" fill="#718096"/><circle cx="92" cy="64" r="10" fill="#718096"/>',
    "engine": '<rect x="20" y="26" width="88" height="76" rx="12" fill="#354154"/><path d="M31 40h66M31 55h66M31 70h66" stroke="#91a0b7" stroke-width="6"/><circle cx="91" cy="91" r="14" fill="#ffb547"/>',
    "driver": '<path d="M25 128q8-43 39-45 31 2 39 45" fill="#18d3c5"/><circle cx="64" cy="54" r="30" fill="#ffb547"/><path d="M38 49h52v24H38z" fill="#16202e"/>',
    "helmet": '<circle cx="64" cy="61" r="44" fill="#18d3c5" stroke="#f5f7fa" stroke-width="5"/><path d="M25 58h78v24H33z" fill="#101725"/><path d="M30 92h70" stroke="#ffb547" stroke-width="9"/>',
    "number_plate": '<rect x="23" y="27" width="82" height="74" rx="14" fill="#f5f7fa" stroke="#18d3c5" stroke-width="6"/>',
}
for name, body in components.items(): save(f"cars/kart/components/kart_{name}.svg", svg(body), "vehicle_component")

for i in range(1, 9):
    patterns = ["M24 48h80", "M25 35l78 54", "M30 25l68 75M98 25L30 100", "M20 63h88", "M32 22l64 82", "M20 44h88M20 78h88", "M28 28l72 72", "M20 80Q64 22 108 80"]
    save(f"cars/kart/helmets/helmet_pattern_{i:02}.svg", svg(
        '<circle cx="64" cy="61" r="45" fill="#18d3c5" stroke="#f5f7fa" stroke-width="5"/>'
        f'<path d="{patterns[i-1]}" fill="none" stroke="#3d7cff" stroke-width="11"/>'
        '<path d="M24 56h80v25H31z" fill="#101725"/><path d="M31 94h67" stroke="#ffb547" stroke-width="8"/>'), "helmet_pattern")

# Regional environment modular assets.
env = {
 "asphalt": '<rect width="256" height="128" fill="#303844"/><path d="M0 27h256M0 101h256" stroke="#3d4653" stroke-width="2"/><g fill="#56606c"><circle cx="31" cy="38" r="2"/><circle cx="118" cy="92" r="2"/><circle cx="215" cy="54" r="2"/></g>',
 "kerb": '<rect width="256" height="128" fill="#e9edf2"/><path d="M0 0h32v128H0zm64 0h32v128H64zm64 0h32v128h-32zm64 0h32v128h-32z" fill="#e95b64"/>',
 "grass": '<rect width="256" height="128" fill="#2f5940"/><path d="M0 98l45-32 40 17 48-43 47 30 76-34v92H0z" fill="#396749"/>',
 "gravel": '<rect width="256" height="128" fill="#8e7b60"/><path d="M18 30l8 5m55 31l10-4m63-31l7 8m56 48l11-5" stroke="#b6a17e" stroke-width="5"/>',
 "tyres": '<g fill="#121821" stroke="#526071" stroke-width="4"><circle cx="30" cy="70" r="24"/><circle cx="76" cy="70" r="24"/><circle cx="122" cy="70" r="24"/><circle cx="168" cy="70" r="24"/><circle cx="214" cy="70" r="24"/></g>',
 "barrier": '<path d="M2 40h252v55H2z" fill="#c6cdd6" stroke="#536072" stroke-width="6"/><path d="M28 42l40 51m36-51l40 51m36-51l40 51" stroke="#8e9aaa" stroke-width="5"/>',
 "fence": '<path d="M12 18v100m232-100v100M12 25h232v75H12z" fill="none" stroke="#8290a2" stroke-width="5"/><path d="M12 25l75 75 75-75 75 75M87 25L12 100m225-75l-75 75" stroke="#657386" stroke-width="2"/>',
 "sign": '<rect x="9" y="28" width="110" height="65" rx="8" fill="#111927" stroke="#18d3c5" stroke-width="5"/><path d="M31 93v27m66-27v27" stroke="#718096" stroke-width="8"/><path d="M28 61h72" stroke="#f5f7fa" stroke-width="8"/>',
 "start_line": '<rect width="128" height="128" fill="#f5f7fa"/><path d="M0 0h32v32H0zm64 0h32v32H64zM32 32h32v32H32zm64 0h32v32H96zM0 64h32v32H0zm64 0h32v32H64zM32 96h32v32H32zm64 0h32v32H96z" fill="#172131"/>',
 "grid_marking": '<rect width="128" height="128" fill="#303844"/><path d="M18 110V25h45M110 18H72v85" fill="none" stroke="#f5f7fa" stroke-width="6"/>',
 "pitlane": '<rect width="256" height="128" fill="#343d49"/><path d="M0 25h256M0 103h256" stroke="#f5f7fa" stroke-width="4"/><path d="M20 64h216" stroke="#ffb547" stroke-width="4" stroke-dasharray="18 14"/>',
 "paddock": '<rect x="4" y="47" width="120" height="73" fill="#263244"/><path d="M0 47h128L108 25H20z" fill="#18d3c5"/><rect x="16" y="70" width="32" height="50" fill="#111927"/><rect x="76" y="70" width="34" height="23" fill="#4d6178"/>',
 "timing_building": '<rect x="10" y="30" width="108" height="90" fill="#263244"/><path d="M2 30h124L109 15H19z" fill="#f5f7fa"/><rect x="24" y="48" width="80" height="32" fill="#4d6178"/><circle cx="64" cy="99" r="11" fill="#18d3c5"/>',
 "grandstand": '<path d="M7 112h114L100 26H32z" fill="#536174"/><path d="M24 91h87M21 69h84M27 47h73" stroke="#d9dee5" stroke-width="8"/><path d="M15 120L38 25m74 95L94 25" stroke="#263244" stroke-width="6"/>',
 "tree": '<circle cx="64" cy="44" r="37" fill="#3d704b"/><circle cx="41" cy="63" r="28" fill="#315c42"/><circle cx="84" cy="67" r="29" fill="#356946"/><path d="M58 80h14v44H58z" fill="#70563f"/>',
 "light": '<path d="M58 27h12v97H58z" fill="#667386"/><path d="M35 15h58v31H35z" fill="#f8e8ad"/><path d="M44 46l-14 43m54-43l14 43" stroke="#f8e8ad" stroke-width="3" opacity=".3"/>',
 "marshal": '<circle cx="64" cy="26" r="16" fill="#d99b72"/><path d="M39 45h50l12 57H27z" fill="#ffb547"/><path d="M42 52l44 43M86 52L42 95" stroke="#f5f7fa" stroke-width="6"/><path d="M45 102l-8 24m46-24l8 24" stroke="#1a2230" stroke-width="10"/>',
}
for name, body in env.items():
    w = 256 if name in {"asphalt", "kerb", "grass", "gravel", "tyres", "barrier", "fence", "pitlane"} else 128
    save(f"circuits/environments/regional_kart_environment_01/prop_regional_{name}.svg", svg(body, w, 128), "environment_prop")

# Three fictitious layouts reuse the regional environment palette.
paths = [
 "M212 425C75 360 100 126 288 112c110-8 106 95 193 89 100-7 97-111 205-97 190 25 248 257 89 347-91 52-161-52-264-25-115 30-180 55-299-1z",
 "M160 402C62 315 127 116 303 103h410c171 3 241 199 151 318-70 91-208 64-311 24-127-49-285 66-393-43z",
 "M180 423C61 326 127 111 302 103c128-5 102 110 202 112 93 2 95-119 211-103 169 24 232 220 108 323-101 83-206-21-308 8-129 36-235 60-335-20z",
]
for i, path in enumerate(paths, 1):
    body = ('<rect width="1024" height="576" fill="#2f5940"/><path d="M0 490L1024 290v286H0z" fill="#274f39"/>'
        f'<path d="{path}" fill="none" stroke="#97a0aa" stroke-width="120"/>'
        f'<path d="{path}" fill="none" stroke="#303844" stroke-width="94"/>'
        f'<path d="{path}" fill="none" stroke="#65707d" stroke-width="3" stroke-dasharray="18 19"/>'
        '<path d="M275 58v105" stroke="#f5f7fa" stroke-width="9" stroke-dasharray="10 8"/>'
        '<g fill="#172131"><rect x="37" y="42" width="162" height="57"/><rect x="820" y="469" width="165" height="65"/></g>'
        '<g fill="#3d704b"><circle cx="64" cy="230" r="25"/><circle cx="950" cy="180" r="31"/><circle cx="730" cy="528" r="23"/></g>')
    save(f"circuits/regional/track_kart_regional_{i:02}.svg", svg(body, 1024, 576), "track")

# Championship identity uses only symbolic artwork; all translated words remain Labels.
save("championship/regional_kart_series/logo_regional_kart_series.svg", svg(
    '<path d="M64 7l48 24-8 62-40 29-40-29-8-62z" fill="#111927" stroke="#18d3c5" stroke-width="6"/>'
    '<path d="M35 81l23-48h13L52 74h18l22-41h12L78 87H43z" fill="#f5f7fa"/>'), "championship_logo")
save("championship/regional_kart_series/trophy_regional_kart_series.svg", svg(
    '<path d="M39 18h50v26q0 36-25 45-25-9-25-45z" fill="#ffb547"/><path d="M39 30H17q0 30 28 35M89 30h22q0 30-28 35" fill="none" stroke="#ffb547" stroke-width="8"/><path d="M64 88v18M38 115h52" stroke="#f5f7fa" stroke-width="9"/>'), "trophy")
save("championship/regional_kart_series/header_regional_kart_series.svg", svg(
    '<rect width="1024" height="256" fill="#0d1522"/><path d="M0 256L430 0h270L260 256z" fill="#18d3c5" opacity=".13"/><path d="M580 256L1024 34v222z" fill="#3d7cff" opacity=".16"/><path d="M0 220h1024" stroke="#18d3c5" stroke-width="4"/>', 1024, 256), "championship_header")
save("championship/regional_kart_series/badge_regional_level.svg", svg(
    '<path d="M64 8l45 25v56l-45 31-45-31V33z" fill="#172131" stroke="#ffb547" stroke-width="6"/><path d="M37 79l27-43 27 43z" fill="none" stroke="#f5f7fa" stroke-width="7"/><circle cx="64" cy="78" r="8" fill="#18d3c5"/>'), "championship_badge")


def scene(name, ext, body, load_steps=None):
    lines = [f'[gd_scene load_steps={load_steps or len(ext)+1} format=3]', '']
    for idx, (typ, path) in enumerate(ext, 1): lines.append(f'[ext_resource type="{typ}" path="res://{path}" id="{idx}"]')
    lines += ['', body.strip(), '']
    rel = f"demo/{name}.tscn"
    (G / rel).write_text('\n'.join(lines), encoding="utf-8")
    register(rel, "demo_scene")


ROOT_NODE = '''[node name="%s" type="Control"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
theme = ExtResource("1")
[node name="Background" type="ColorRect" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
color = Color(0.035, 0.055, 0.09, 1)'''

def panel(parent, name, l,t,r,b): return f'''[node name="{name}" type="PanelContainer" parent="{parent}"]
layout_mode = 0
offset_left = {l}.0
offset_top = {t}.0
offset_right = {r}.0
offset_bottom = {b}.0'''
def label(parent,name,text,l,t,r,b,size=18,color=None):
    c=f'\ntheme_override_colors/font_color = Color({color})' if color else ''
    return f'''[node name="{name}" type="Label" parent="{parent}"]
layout_mode = 0
offset_left = {l}.0
offset_top = {t}.0
offset_right = {r}.0
offset_bottom = {b}.0
theme_override_font_sizes/font_size = {size}{c}
text = "{text}"'''

# Team creation.
b = [ROOT_NODE % "TeamCreationDemo", label('.', 'Title', 'CRÉER MON ÉCURIE',80,52,900,120,42),
panel('.', 'Form',80,150,840,930), label('Form','NameLabel','NOM DE L’ÉCURIE',30,25,500,60,16,'0.094, 0.827, 0.773, 1'),
label('Form','NameValue','AURORA KART RACING',30,70,700,125,28), label('Form','Country','PAYS     FRANCE',30,155,700,210,22),
label('Form','Colors','COULEURS',30,245,300,285,18),
'[node name="PrimaryColor" type="ColorRect" parent="Form"]\nlayout_mode = 0\noffset_left = 30.0\noffset_top = 300.0\noffset_right = 170.0\noffset_bottom = 380.0\ncolor = Color(0.094, 0.827, 0.773, 1)',
'[node name="SecondaryColor" type="ColorRect" parent="Form"]\nlayout_mode = 0\noffset_left = 190.0\noffset_top = 300.0\noffset_right = 330.0\noffset_bottom = 380.0\ncolor = Color(0.239, 0.486, 1, 1)',
'[node name="AccentColor" type="ColorRect" parent="Form"]\nlayout_mode = 0\noffset_left = 350.0\noffset_top = 300.0\noffset_right = 490.0\noffset_bottom = 380.0\ncolor = Color(1, 0.71, 0.28, 1)',
label('Form','LogoTitle','SÉLECTION LOGO',30,425,400,465,18),
'[node name="Logo" type="TextureRect" parent="Form"]\nlayout_mode = 0\noffset_left = 30.0\noffset_top = 480.0\noffset_right = 200.0\noffset_bottom = 650.0\ntexture = ExtResource("2")\nexpand_mode = 1\nstretch_mode = 5',
'[node name="Confirm" type="Button" parent="Form"]\nlayout_mode = 0\noffset_left = 30.0\noffset_top = 680.0\noffset_right = 700.0\noffset_bottom = 750.0\ntext = "CONFIRMER L’ÉCURIE"',
panel('.', 'Preview',880,150,1840,930), label('Preview','Eyebrow','APERÇU KART',34,26,400,65,16,'0.094, 0.827, 0.773, 1'),
'[node name="Kart" type="TextureRect" parent="Preview"]\nlayout_mode = 0\noffset_left = 50.0\noffset_top = 170.0\noffset_right = 910.0\noffset_bottom = 600.0\ntexture = ExtResource("3")\nexpand_mode = 1\nstretch_mode = 5', label('Preview','Number','27',430,335,550,420,54), label('Preview','Hint','Couleurs et numéro modifiables • Aperçu sans données métier',65,650,900,700,18)]
scene('team_creation_demo', [('Theme','graphics/ui/paddock_theme.tres'),('Texture2D','graphics/logos/logo_team_helix_racing.svg'),('Texture2D','graphics/cars/kart/car_kart_01.svg')], '\n'.join(b))

# Driver profile.
b=[ROOT_NODE % 'DriverProfileDemo', label('.','Title','PROFIL PILOTE',70,45,700,110,38), panel('.','Identity',70,140,650,960),
'[node name="Portrait" type="TextureRect" parent="Identity"]\nlayout_mode = 0\noffset_left = 45.0\noffset_top = 45.0\noffset_right = 535.0\noffset_bottom = 490.0\ntexture = ExtResource("2")\nexpand_mode = 1\nstretch_mode = 5',
'[node name="Flag" type="TextureRect" parent="Identity"]\nlayout_mode = 0\noffset_left = 45.0\noffset_top = 520.0\noffset_right = 105.0\noffset_bottom = 560.0\ntexture = ExtResource("3")\nexpand_mode = 1',
label('Identity','Name','NOAH MARTIN',125,510,520,565,31), label('Identity','Meta','14 ANS   •   NIVEAU 58\nPOTENTIEL ESTIMÉ   78–91',45,590,530,665,22), label('Identity','Traits','TRAITS\nCalme  •  Travailleur  •  Fin sous la pluie',45,705,530,780,19), label('Identity','Moral','MORAL   86%   ▲',45,820,500,870,21,'0.259, 0.839, 0.604, 1'),
panel('.','Stats',690,140,1255,960), label('Stats','Title','ATTRIBUTS',30,25,400,70,20,'0.094, 0.827, 0.773, 1'),
label('Stats','Rows','Vitesse                         61\nQualification                  57\nDépart                          64\nDépassement                    59\nDéfense                         55\nPluie                           68\nGestion pneus                   62\nRégularité                      60\nMental                          66',30,90,525,590,22),
label('Stats','Bars','██████░░░░\n██████░░░░\n██████░░░░\n██████░░░░\n██████░░░░\n███████░░░\n██████░░░░\n██████░░░░\n███████░░░',300,90,520,590,22,'0.094, 0.827, 0.773, 1'),
panel('.','Career',1295,140,1850,960), label('Career','History','HISTORIQUE\n\n2026  Regional Kart Series\nP3 • 1 victoire • 4 podiums\n\nFORME RÉCENTE\nP4   P2   P7   P1   P3',30,25,500,300,20), label('Career','Contract','CONTRAT\n\nAurora Kart Racing\nDurée : 1 saison\nStatut : Pilote titulaire\n\nTous les textes sont dynamiques.',30,355,500,620,20)]
scene('driver_profile_demo',[('Theme','graphics/ui/paddock_theme.tres'),('Texture2D','graphics/portraits/generated/portrait_driver_01.svg'),('Texture2D','graphics/flags/flag_france.svg')],'\n'.join(b))

# Championship with event calendar and 20-row standings.
names=['L. Bernard','N. Martin','E. Rossi','M. Weber','T. Dubois','A. Costa','J. Wilson','S. Moreau','K. Ito','P. Garcia','O. Klein','R. Silva','H. Clark','F. Leroy','D. Evans','B. Ricci','C. Mayer','I. Petit','G. Ward','V. Sato']
rows='POSITION    PILOTE                 ÉCURIE                 POINTS    VICTOIRES\n'+'\n'.join(f'{i:02}  {"▲" if i%3==0 else "▼" if i%4==0 else "•"}       {n:<20} {("AURORA" if i==2 else "VECTOR"):20} {max(0,102-i*4):>3}       {3 if i==1 else 1 if i<5 else 0}' for i,n in enumerate(names,1))
b=[ROOT_NODE%'ChampionshipDemo',
'[node name="Header" type="TextureRect" parent="."]\nlayout_mode = 0\noffset_right = 1920.0\noffset_bottom = 260.0\ntexture = ExtResource("2")\nexpand_mode = 1\nstretch_mode = 6',
'[node name="Logo" type="TextureRect" parent="."]\nlayout_mode = 0\noffset_left = 70.0\noffset_top = 45.0\noffset_right = 230.0\noffset_bottom = 205.0\ntexture = ExtResource("3")\nexpand_mode = 1',label('.','Title','REGIONAL KART SERIES',260,70,1050,135,40),label('.','Meta','SAISON 2026  •  NIVEAU RÉGIONAL  •  6 MANCHES',260,145,1100,190,18),
panel('.','Calendar',55,285,620,1030),label('Calendar','Title','CALENDRIER',25,20,400,60,20,'0.094, 0.827, 0.773, 1'),
label('Calendar','Events','✓  01  VALMONT          14 AVR   SEC\n✓  02  SAINT-ROCH        28 AVR   PLUIE\n●  03  MONTBRUN          12 MAI   22°C\n○  04  BELLE-RIVE        26 MAI   19°C\n▣  05  GRAND-LAC         09 JUIN  --\n▣  06  VALMONT FINALE    23 JUIN  --\n\nSTATUTS\n✓ Terminé   ● Sélectionné\n○ À venir   ▣ Verrouillé\n\nMANCHE 3\nLongueur : 1,16 km\nPrévision : Sec',25,85,530,620,20),
panel('.','Standings',650,285,1865,1030),label('Standings','Title','CLASSEMENT CHAMPIONNAT',25,20,800,60,20,'0.094, 0.827, 0.773, 1'),label('Standings','Rows',rows,25,72,1170,710,17)]
scene('championship_demo',[('Theme','graphics/ui/paddock_theme.tres'),('Texture2D','graphics/championship/regional_kart_series/header_regional_kart_series.svg'),('Texture2D','graphics/championship/regional_kart_series/logo_regional_kart_series.svg')],'\n'.join(b))

# Garage.
b=[ROOT_NODE%'KartGarageDemo',label('.','Title','GARAGE KART',70,42,700,105,38),panel('.','Info',60,135,430,940),label('Info','Data','KART 01\nÉQUILIBRÉ\n\nNUMÉRO       27\nCHÂSSIS       K-01\nMOTEUR        R-125\nPNEUS         SLICK\n\nLIVRÉE\nPrimaire\nSecondaire\nAccent',25,25,330,620,21),panel('.','Preview',465,135,1315,940),
'[node name="Kart" type="TextureRect" parent="Preview"]\nlayout_mode = 0\noffset_left = 25.0\noffset_top = 130.0\noffset_right = 825.0\noffset_bottom = 570.0\ntexture = ExtResource("2")\nexpand_mode = 1\nstretch_mode = 5',label('Preview','Number','27',395,375,500,445,48),label('Preview','Variant','VARIANTES   01  •  02  •  03',220,650,650,700,20),panel('.','Technical',1350,135,1860,940),label('Technical','Title','ZONES TECHNIQUES',25,25,460,65,18,'0.094, 0.827, 0.773, 1'),label('Technical','Systems','MOTEUR         92%  █████████░\n\nCHÂSSIS        88%  █████████░\n\nPNEUS          73%  ███████░░░\n\nFREINS         96%  ██████████\n\nFIABILITÉ      89%  █████████░',25,95,470,510,19),
'[node name="Repair" type="Button" parent="Technical"]\nlayout_mode = 0\noffset_left = 25.0\noffset_top = 600.0\noffset_right = 475.0\noffset_bottom = 660.0\ntext = "RÉPARER"','[node name="Setup" type="Button" parent="Technical"]\nlayout_mode = 0\noffset_left = 25.0\noffset_top = 675.0\noffset_right = 475.0\noffset_bottom = 735.0\ntext = "RÉGLER"','[node name="Upgrade" type="Button" parent="Technical"]\nlayout_mode = 0\noffset_left = 25.0\noffset_top = 750.0\noffset_right = 475.0\noffset_bottom = 810.0\ntext = "AMÉLIORER"']
scene('kart_garage_demo',[('Theme','graphics/ui/paddock_theme.tres'),('Texture2D','graphics/cars/kart/car_kart_01.svg')],'\n'.join(b))

# Race preparation.
b=[ROOT_NODE%'RacePreparationDemo',label('.','Title','PROCHAINE COURSE',70,48,800,110,40),label('.','Subtitle','MANCHE 03 / 06  •  MONTBRUN',70,115,800,155,20,'0.094, 0.827, 0.773, 1'),panel('.','TrackCard',70,195,1010,800),
'[node name="Track" type="TextureRect" parent="TrackCard"]\nlayout_mode = 0\noffset_left = 25.0\noffset_top = 25.0\noffset_right = 915.0\noffset_bottom = 500.0\ntexture = ExtResource("2")\nexpand_mode = 1\nstretch_mode = 5',label('TrackCard','Details','CIRCUIT TECHNIQUE  •  1,16 KM  •  18 TOURS',30,525,900,575,21),panel('.','SetupCard',1045,195,1850,800),label('SetupCard','Data','PILOTE       Noah Martin     Niveau 58\n\nKART         Kart 01         Fiabilité 89%\n\nPNEUS        Slick tendre\n\nMÉTÉO        Sec  •  22°C  •  Risque pluie 15%\n\nOBJECTIF SPONSOR\nTerminer dans le Top 5\nBonus visuel : 5 000 €',30,30,750,510,21),
'[node name="Start" type="Button" parent="."]\nlayout_mode = 0\noffset_left = 1045.0\noffset_top = 840.0\noffset_right = 1850.0\noffset_bottom = 925.0\ntext = "COMMENCER LE WEEK-END"',label('.','SafeArea','ZONE SÛRE MOBILE  •  Toutes les données sont des Labels remplaçables',70,990,1100,1030,16)]
scene('race_preparation_demo',[('Theme','graphics/ui/paddock_theme.tres'),('Texture2D','graphics/circuits/regional/track_kart_regional_01.svg')],'\n'.join(b))

# Qualifying broadcast.
qrows='01  E. ROSSI       48.201\n02  N. MARTIN      +0.084\n03  L. BERNARD     +0.173\n04  M. WEBER       +0.251\n05  T. DUBOIS      +0.399\n06  A. COSTA       +0.447\n07  J. WILSON      +0.583\n08  S. MOREAU      +0.702'
b=[ROOT_NODE%'QualifyingDemo','[node name="Track" type="TextureRect" parent="."]\nlayout_mode = 1\nanchors_preset = 15\nanchor_right = 1.0\nanchor_bottom = 1.0\ntexture = ExtResource("2")\nexpand_mode = 1\nstretch_mode = 6\nmodulate = Color(0.72, 0.78, 0.84, 1)',panel('.','TopHud',40,28,1880,130),label('TopHud','Session','QUALIFICATIONS  •  06:42',25,20,600,70,28),label('TopHud','Weather','SEC  •  22°C  •  PISTE 31°C',1200,23,1750,70,20),panel('.','Standings',40,165,550,805),label('Standings','Title','CLASSEMENT',24,18,400,55,18,'0.094, 0.827, 0.773, 1'),label('Standings','Rows',qrows,24,76,465,500,20),panel('.','Timing',1030,720,1880,1035),label('Timing','Driver','P02   NOAH MARTIN   •   SLICK TENDRE',25,18,780,62,22),label('Timing','Lap','TOUR ACTUEL     48.285',25,78,500,125,31),label('Timing','Sectors','S1  15.482   S2  17.103   S3  15.700\nMEILLEUR TOUR  48.285   ÉCART +0.084',25,145,760,235,21)]
scene('qualifying_demo',[('Theme','graphics/ui/paddock_theme.tres'),('Texture2D','graphics/circuits/regional/track_kart_regional_01.svg')],'\n'.join(b))

# Results and podium.
result_rows='04  T. DUBOIS          +5.882    12 pts\n05  A. COSTA           +7.104    10 pts\n06  J. WILSON          +9.551     8 pts\n07  S. MOREAU         +11.002     6 pts\n08  K. ITO            +12.430     4 pts\n09  P. GARCIA         +14.227     2 pts\n10  O. KLEIN          +15.880     1 pt'
b=[ROOT_NODE%'RaceResultsDemo',label('.','Title','RÉSULTATS',70,43,700,105,42),label('.','Meta','MONTBRUN  •  MANCHE 03 / 06',70,112,700,150,18,'0.094, 0.827, 0.773, 1'),panel('.','Podium',70,190,1120,650),label('Podium','P2','P2\nNOAH MARTIN',85,190,350,300,25),label('Podium','P1','P1\nE. ROSSI',410,110,650,225,29),label('Podium','P3','P3\nL. BERNARD',725,235,990,340,23),
'[node name="Second" type="ColorRect" parent="Podium"]\nlayout_mode = 0\noffset_left = 55.0\noffset_top = 300.0\noffset_right = 365.0\noffset_bottom = 430.0\ncolor = Color(0.42, 0.48, 0.57, 1)','[node name="First" type="ColorRect" parent="Podium"]\nlayout_mode = 0\noffset_left = 380.0\noffset_top = 240.0\noffset_right = 690.0\noffset_bottom = 430.0\ncolor = Color(1, 0.71, 0.28, 1)','[node name="Third" type="ColorRect" parent="Podium"]\nlayout_mode = 0\noffset_left = 705.0\noffset_top = 330.0\noffset_right = 1015.0\noffset_bottom = 430.0\ncolor = Color(0.64, 0.39, 0.25, 1)',panel('.','Player',1160,190,1850,650),label('Player','Title','VOTRE COURSE',25,22,600,62,18,'0.094, 0.827, 0.773, 1'),label('Player','Data','DÉPART              P5\nARRIVÉE              P2   ▲3\nPOINTS               +18\nARGENT           +6 500 €\nEXPÉRIENCE           +420\nRÉPUTATION             +3',25,92,640,400,22),panel('.','Full',70,690,1850,1025),label('Full','Title','CLASSEMENT COMPLET',25,16,500,52,18),label('Full','Rows',result_rows,25,68,900,310,19)]
scene('race_results_demo',[('Theme','graphics/ui/paddock_theme.tres')],'\n'.join(b))

# Season finale.
b=[ROOT_NODE%'SeasonEndDemo',label('.','Eyebrow','REGIONAL KART SERIES  •  2026',630,110,1300,150,19,'0.094, 0.827, 0.773, 1'),label('.','Title','SAISON TERMINÉE',535,165,1450,250,54),panel('.','Summary',360,300,1560,760),label('Summary','Stats','CHAMPIONNAT\nP3\n\nVICTOIRES\n1',90,65,420,380,22),label('Summary','Stats2','PODIUMS\n4\n\nPOINTS\n86',455,65,750,380,22),label('Summary','Stats3','REVENUS\n24 500 €\n\nPROGRESSION PILOTE\n+6',790,65,1120,380,22),
'[node name="Review" type="Button" parent="."]\nlayout_mode = 0\noffset_left = 360.0\noffset_top = 815.0\noffset_right = 735.0\noffset_bottom = 885.0\ntext = "VOIR LA SAISON"','[node name="Continue" type="Button" parent="."]\nlayout_mode = 0\noffset_left = 770.0\noffset_top = 815.0\noffset_right = 1145.0\noffset_bottom = 885.0\ntext = "CONTINUER"','[node name="Contracts" type="Button" parent="."]\nlayout_mode = 0\noffset_left = 1180.0\noffset_top = 815.0\noffset_right = 1560.0\noffset_bottom = 885.0\ntext = "MARCHÉ DES CONTRATS"']
scene('season_end_demo',[('Theme','graphics/ui/paddock_theme.tres')],'\n'.join(b))

# Reusable visual-only components.
components_scenes = {
"championship_card": '''[gd_scene load_steps=3 format=3]\n[ext_resource type="Theme" path="res://graphics/ui/paddock_theme.tres" id="1"]\n[ext_resource type="Texture2D" path="res://graphics/championship/regional_kart_series/logo_regional_kart_series.svg" id="2"]\n[node name="ChampionshipCard" type="PanelContainer"]\ncustom_minimum_size = Vector2(680, 260)\ntheme = ExtResource("1")\n[node name="Logo" type="TextureRect" parent="."]\nlayout_mode = 0\noffset_left = 24.0\noffset_top = 24.0\noffset_right = 220.0\noffset_bottom = 220.0\ntexture = ExtResource("2")\nexpand_mode = 1\nstretch_mode = 5\n[node name="Details" type="Label" parent="."]\nlayout_mode = 0\noffset_left = 250.0\noffset_top = 35.0\noffset_right = 650.0\noffset_bottom = 225.0\ntext = "REGIONAL KART SERIES\\nNIVEAU RÉGIONAL\\n6 MANCHES  •  20 PILOTES\\nPROCHAINE : MONTBRUN"''',
"event_card": '''[gd_scene load_steps=2 format=3]\n[ext_resource type="Theme" path="res://graphics/ui/paddock_theme.tres" id="1"]\n[node name="EventCard" type="PanelContainer"]\ncustom_minimum_size = Vector2(480, 150)\ntheme = ExtResource("1")\n[node name="Content" type="Label" parent="."]\nlayout_mode = 2\ntext = "03  MONTBRUN\\n12 MAI  •  SEC 22°C  •  1,16 KM\\n● SÉLECTIONNÉ"''',
"sponsor_card": '''[gd_scene load_steps=3 format=3]\n[ext_resource type="Theme" path="res://graphics/ui/paddock_theme.tres" id="1"]\n[ext_resource type="Texture2D" path="res://graphics/sponsors/logo_sponsor_nova_energy.svg" id="2"]\n[node name="SponsorCard" type="PanelContainer"]\ncustom_minimum_size = Vector2(620, 240)\ntheme = ExtResource("1")\n[node name="Logo" type="TextureRect" parent="."]\ncustom_minimum_size = Vector2(160, 160)\nlayout_mode = 2\ntexture = ExtResource("2")\nexpand_mode = 3\nstretch_mode = 5\n[node name="Details" type="Label" parent="."]\nlayout_mode = 2\ntext = "NOVA ENERGY\\nCONTRAT  25 000 €  •  DURÉE 1 SAISON\\nOBJECTIF  TOP 5\\nBONUS  +5 000 €"\nhorizontal_alignment = 2''',
"start_lights": '''[gd_scene load_steps=2 format=3]\n[ext_resource type="Theme" path="res://graphics/ui/paddock_theme.tres" id="1"]\n[node name="StartLights" type="PanelContainer"]\ncustom_minimum_size = Vector2(560, 150)\ntheme = ExtResource("1")\n[node name="StateLabel" type="Label" parent="."]\nlayout_mode = 2\ntheme_override_font_sizes/font_size = 48\ntext = "●  ●  ●  ●  ●"\nhorizontal_alignment = 1\n# Claude may animate font color/red to dark; this scene owns no start logic.''',
"notifications_demo": '''[gd_scene load_steps=2 format=3]\n[ext_resource type="Theme" path="res://graphics/ui/paddock_theme.tres" id="1"]\n[node name="NotificationsDemo" type="VBoxContainer"]\ncustom_minimum_size = Vector2(680, 480)\ntheme = ExtResource("1")\ntheme_override_constants/separation = 12\n[node name="Information" type="PanelContainer" parent="."]\nlayout_mode = 2\n[node name="Text" type="Label" parent="Information"]\nlayout_mode = 2\ntext = "ⓘ  INFORMATION  •  Nouvelle session disponible"\n[node name="Success" type="PanelContainer" parent="."]\nlayout_mode = 2\n[node name="Text" type="Label" parent="Success"]\nlayout_mode = 2\ntext = "✓  SUCCÈS  •  Objectif atteint"\n[node name="Warning" type="PanelContainer" parent="."]\nlayout_mode = 2\n[node name="Text" type="Label" parent="Warning"]\nlayout_mode = 2\ntext = "⚠  AVERTISSEMENT  •  Pneus usés"\n[node name="Error" type="PanelContainer" parent="."]\nlayout_mode = 2\n[node name="Text" type="Label" parent="Error"]\nlayout_mode = 2\ntext = "×  ERREUR  •  Action indisponible"\n[node name="Offer" type="PanelContainer" parent="."]\nlayout_mode = 2\n[node name="Text" type="Label" parent="Offer"]\nlayout_mode = 2\ntext = "★  NOUVELLE OFFRE  •  Contrat reçu"''',
}
for name, content in components_scenes.items():
    rel=f"ui/components/{name}.tscn"; (G/rel).parent.mkdir(parents=True,exist_ok=True); (G/rel).write_text(content+'\n',encoding='utf-8'); register(rel,'ui_component')

# Merge—never remove or rename an existing stable ID.
manifest_path = ROOT / "shared/graphics_manifest.json"
ids_path = ROOT / "shared/asset_ids.json"
manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
manifest.update(assets)
if "race_visual_demo" in manifest:
    manifest["race_visual_demo"]["version"] = 2
manifest_path.write_text(json.dumps(dict(sorted(manifest.items())), indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
ids = json.loads(ids_path.read_text(encoding="utf-8"))
ids.update({key: key for key in assets})
ids_path.write_text(json.dumps(dict(sorted(ids.items())), indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
print(f"Generated/registered {len(assets)} Mission 2 assets; manifest now has {len(manifest)} IDs")
