"""Render the editable conversation architecture as SVG/PNG using bundled fonts.
Documentation only. Requires Pillow; does not run Raysto or call a provider.
"""
from pathlib import Path
from html import escape
import math
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'docs/backend-v2/maps'
OUT.mkdir(parents=True, exist_ok=True)
W, H = 1680, 1260
BG, INK, PAPER, LIME, MUTED = '#f6f3e9', '#23493c', '#fffdf7', '#d9ee96', '#63776b'
im = Image.new('RGB', (W, H), BG)
d = ImageDraw.Draw(im)
svg = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}"><rect width="100%" height="100%" fill="{BG}"/>']

def text(x, y, value, size=22, bold=False, color=INK):
    font = ImageFont.truetype(str(ROOT/'assets/fonts'/f'PlusJakartaSans-{"Bold" if bold else "Regular"}.ttf'), size)
    d.text((x, y), value, fill=color, font=font)
    svg.append(f'<text x="{x}" y="{y+size}" fill="{color}" font-family="Plus Jakarta Sans,Arial,sans-serif" font-size="{size}" font-weight="{700 if bold else 400}">{escape(value)}</text>')

def box(x, y, w, h, title, lines, highlight=False):
    fill = LIME if highlight else PAPER
    d.rounded_rectangle((x,y,x+w,y+h),radius=18,fill=fill,outline=INK,width=2)
    svg.append(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="18" fill="{fill}" stroke="{INK}" stroke-width="2"/>')
    text(x+24,y+18,title,27,True)
    for n,line in enumerate(lines): text(x+24,y+64+n*31,line,21)

def arrow(points):
    d.line(points,fill=MUTED,width=3)
    svg.append(f'<polyline points="{" ".join(f"{x},{y}" for x,y in points)}" stroke="{MUTED}" stroke-width="3" fill="none"/>')
    x,y=points[-1];px,py=points[-2];a=math.atan2(y-py,x-px)
    triangle=[(x,y),(x-13*math.cos(a-.4),y-13*math.sin(a-.4)),(x-13*math.cos(a+.4),y-13*math.sin(a+.4))]
    d.polygon(triangle,fill=MUTED)
    svg.append(f'<polygon points="{" ".join(f"{x},{y}" for x,y in triangle)}" fill="{MUTED}"/>')

text(60,35,'raysto  /  AI at the table. People in control.',43,True)
text(60,100,'Road to 10/10 · Connected architecture · Integration candidate, 26 October 2026',22,color=MUTED)
box(60,165,480,155,'Diners · Flutter',['Join an admitted visit room','Review order and personal share','Approve in real PayPal Sandbox'])
box(600,165,480,155,'Waiter · Flutter',['Same visit and conversation','Service acknowledgement','Orders, kitchen and bill state'])
box(1140,165,480,155,'Manager · ops.rays.to',['Table map + AG Grid','AG Studio widgets and assistant','Shared filters + room timeline'])
for x in [300,840,1380]: arrow([(x,320),(x,370)])
box(60,370,1560,145,'One authorized backend · Serverpod + PostgreSQL',[
    'Firebase proof + current SQL membership → bounded RPC / REST → domain commands',
    'Idempotency · exact minor-unit money · version checks · transaction + durable events'],True)
arrow([(300,515),(300,575)]);arrow([(840,515),(840,575)]);arrow([(1380,515),(1380,575)])
box(60,575,480,195,'Conversation + operations',['Visit/order rooms and audiences','Messages, replies and read cursors','Authorized SSE + snapshot recovery','Private help remains separate'])
box(600,575,480,195,'Gemini orchestration',['Authorized tools and reviewed drafts','4 rounds · 8 calls · 30 seconds','$35 development + $15 review','No autonomous payment or publishing'])
box(1140,575,480,195,'Financial ledger',['Frozen quotes and exact shares','One pending checkout per visit','Guarded capture/refund REST calls','Reconcile uncertain outcomes'])
arrow([(300,770),(300,830)]);arrow([(840,770),(840,830)]);arrow([(1380,770),(1380,830)])
box(60,830,480,175,'Delivery + files',['Durable jobs → inbox / FCM','Private Firebase Storage imports','Explicit approval before publication'])
box(600,830,480,175,'PayPal MCP · read only',['get_order / get_refund allowlist','Provider IDs from authorized records','REST fallback names its actual source'])
box(1140,830,480,175,'PayPal Sandbox',['Real approval handoff is observed','Verified capture + webhook → ledger','Then room / staff / dashboard refresh'])
box(60,1060,1560,140,'Evidence is the release gate',[
    'Observed: shared room, access revocation, real Gemini basket/share, unapproved Sandbox checkout, console.',
    'Pending: successful MCP access, two buyer captures/refund, device notifications, pilot and final reviewer release.'],True)
text(60,1220,'PostgreSQL owns business truth. A chat reply or browser redirect cannot mark a bill paid.',18,color=MUTED)
svg.append('</svg>')
(OUT/'conversation-architecture.svg').write_text('\n'.join(svg),encoding='utf-8')
im.save(OUT/'conversation-architecture.png')
(OUT/'conversation-architecture.mmd').write_text('''flowchart TB
  Diners[Flutter diners] --> API[Serverpod authorization and commands]
  Staff[Flutter waiter] --> API
  Ops[Next.js AG Grid + AG Studio] --> API
  API <--> SQL[(PostgreSQL: rooms, orders, bills, events)]
  API --> AI[Gemini: bounded authorized tool loop]
  AI --> Tools[Menu, quotes, proposals, bill and manager reads]
  Tools --> SQL
  Tools --> MCP[PayPal MCP: read only; live acceptance pending]
  API --> Pay[Guarded REST payment service]
  Pay <--> PP[PayPal Sandbox]
  MCP --> PP
  PP --> Reconcile[Verified webhooks + reconciliation]
  Reconcile --> SQL
  SQL --> Events[Authorized SSE + inbox + FCM]
  Events --> Diners
  Events --> Staff
  Events --> Ops
  API --> Files[Private Firebase Storage + reviewed imports]
''',encoding='utf-8')
print('Exported conversation-architecture.mmd, .svg and .png')
