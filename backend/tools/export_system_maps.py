"""Deterministic engineering diagrams: editable Mermaid plus SVG and PNG.
This renders documentation only; it does not build the app or execute tests.
"""
from pathlib import Path
from html import escape
from PIL import Image,ImageDraw,ImageFont
import math

OUT=Path(__file__).resolve().parents[2]/'docs/backend-v2/maps';OUT.mkdir(parents=True,exist_ok=True)
BG='#0d1725';CARD='#162638';TEXT='#eef5fc';MUTED='#acbfd2';CYAN='#61d4cf';ORANGE='#ffb46b';LINE='#55728b'
FONT=Path('C:/Windows/Fonts/segoeui.ttf');BOLD=Path('C:/Windows/Fonts/segoeuib.ttf')
class Canvas:
    def __init__(self,w,h,title,subtitle):
        self.w=w;self.h=h;self.im=Image.new('RGB',(w,h),BG);self.d=ImageDraw.Draw(self.im)
        self.svg=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}"><rect width="100%" height="100%" fill="{BG}"/>']
        self.text(58,38,title,42,TEXT,True);self.text(60,96,subtitle,22,MUTED)
    def text(self,x,y,text,size=22,color=TEXT,bold=False):
        font=ImageFont.truetype(str(BOLD if bold else FONT),size);self.d.text((x,y),text,font=font,fill=color)
        self.svg.append(f'<text x="{x}" y="{y+size}" fill="{color}" font-family="Segoe UI,Arial,sans-serif" font-size="{size}" font-weight="{700 if bold else 400}">{escape(text)}</text>')
    def box(self,x,y,w,h,title,lines=(),color=CYAN):
        self.d.rounded_rectangle((x,y,x+w,y+h),radius=16,fill=CARD,outline=color,width=2)
        self.svg.append(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="16" fill="{CARD}" stroke="{color}" stroke-width="2"/>')
        self.text(x+22,y+15,title,25,color,True)
        for i,line in enumerate(lines):self.text(x+22,y+58+i*32,line,21,TEXT)
    def arrow(self,points,color=LINE):
        self.d.line(points,fill=color,width=3);path=' '.join(f'{x},{y}' for x,y in points);self.svg.append(f'<polyline points="{path}" fill="none" stroke="{color}" stroke-width="3"/>')
        x,y=points[-1];p,q=points[-2];a=math.atan2(y-q,x-p);tri=[(x,y),(x-12*math.cos(a-.4),y-12*math.sin(a-.4)),(x-12*math.cos(a+.4),y-12*math.sin(a+.4))]
        self.d.polygon(tri,fill=color);self.svg.append(f'<polygon points="{" ".join(f"{p},{q}" for p,q in tri)}" fill="{color}"/>')
    def save(self,name):
        self.text(60,self.h-46,'RAYSTO  /  Backend v2 source map  /  Runtime verification and rollout deferred',18,MUTED)
        (OUT/f'{name}.svg').write_text('\n'.join(self.svg+['</svg>']),encoding='utf-8');self.im.save(OUT/f'{name}.png')

c=Canvas(1800,1320,'RAYSTO — complete backend map','Restaurant commerce, operations and platform services · PostgreSQL owns business truth')
c.box(60,155,1680,115,'ONE SHARED BACKEND',['Flutter now · Future web client → Cloudflare / HTTPS → Serverpod RPC + REST /api/v2'],ORANGE)
areas=[('01  People & access',['Firebase identity + guest sessions','Profiles, addresses and favorites','Teams, invitations and ownership','Recent authentication + MFA','Privacy requests and audit history']),
 ('02  Restaurant storefront',['Onboarding, services and hours','Menus, variants and modifiers','Drafts and atomic publication','Discovery and verified reviews','Private uploads + approved images']),
 ('03  Dining room',['Floor plans, zones and tables','QR resolution + seating approval','Visits and expiring invitations','Service requests and shared bills','Reservations, waitlist and reset']),
 ('04  Orders & fulfillment',['Saved carts + server-priced quotes','Frozen order snapshots','Kitchen progress and cancellation','Pickup slots and collection','Restaurant couriers + delivery issues']),
 ('05  Money & revenue',['Merchant onboarding + capabilities','Whole, selected-unit and amount pay','Allocations, captures, cash, refunds','Disputes and reconciliation','Subscriptions, commission, reports']),
 ('06  Platform services',['Durable jobs, leases and retries','Inbox, push and transactional email','Gemini extraction and proposals','Human approval before publishing','Support, exports and administration'])]
for i,(title,lines) in enumerate(areas):
    x=60+(i%3)*575;y=325+(i//3)*370;c.box(x,y,530,290,title,lines);c.arrow([(x+265,y-45),(x+265,y)])
c.box(60,1080,1680,140,'CROSS-CUTTING RULES',['Tenant + object + role checks • Integer money • Idempotency keys • Version conflicts • Immutable purchase snapshots','Outbox events commit with business changes • Provider calls outside SQL locks • Bounded input and worker concurrency'],ORANGE)
c.save('capability-map')
(OUT/'capability-map.mmd').write_text('flowchart LR\n  R[Raysto backend]\n'+''.join(f'  R --> A{i}["{title}"]\n'+''.join(f'  A{i} --> A{i}_{n}["{line}"]\n' for n,line in enumerate(lines)) for i,(title,lines) in enumerate(areas)),encoding='utf-8')

c=Canvas(1800,1250,'RAYSTO — architecture & ownership','A modular monolith with bounded workers; external services provide identity, files, delivery channels and evidence')
c.box(60,170,430,130,'Clients',['Flutter mobile','Future connected web'],ORANGE)
c.box(650,170,480,130,'HTTPS edge',['Cloudflare → Nginx','Raysto only: api.rays.to'],ORANGE)
c.box(1270,170,470,130,'API + authorization',['Serverpod RPC and REST v2','Identity · Roles · Input limits'],ORANGE)
c.arrow([(490,235),(650,235)]);c.arrow([(1130,235),(1270,235)])
c.box(650,400,1090,150,'Business services',['Catalogue · Dining · Orders · Fulfillment · Payments · Revenue','Shared rules for RPC, REST, jobs and reviewed AI actions'])
c.arrow([(1505,300),(1505,400)])
c.box(60,400,430,150,'Identity boundary',['Firebase Authentication','Registered proof + App Check'])
c.arrow([(1270,270),(1190,270),(1190,350),(275,350),(275,400)])
c.box(650,650,500,170,'PostgreSQL — authority',['Permissions and restaurant data','Orders, bills, payments and history','Jobs, notifications and audit'],ORANGE)
c.box(1240,650,500,170,'Durable worker',['Claim → external call → acknowledge','Leases, bounded retry, dead letters','Reconcile unknown provider outcomes'])
c.arrow([(900,550),(900,650)]);c.arrow([(1505,550),(1505,650)]);c.arrow([(1150,735),(1240,735)])
c.box(60,650,430,170,'Firebase supporting data',['Storage: private files','Firestore: display preferences','RTDB: advisory presence'])
c.arrow([(650,500),(550,500),(550,735),(490,735)])
c.box(60,935,430,170,'Communication',['FCM push + in-app inbox','Amazon SES transactional email'])
c.box(650,935,500,170,'PayPal',['Restaurant merchant + platform fee','Separate Raysto subscription seller','Existing Sandbox facility preserved'])
c.box(1240,935,500,170,'Google Cloud Gemini',['EU endpoint · bounded inputs','Extraction, translations, proposals','Human correction and approval'])
c.arrow([(1490,820),(1490,935)]);c.arrow([(1360,820),(1360,875),(900,875),(900,935)]);c.arrow([(1320,820),(1320,895),(275,895),(275,935)])
c.save('system-architecture')
(OUT/'system-architecture.mmd').write_text('''flowchart TB
  Clients[Flutter mobile + future web] --> Edge[Cloudflare + HTTPS + Raysto Nginx]
  Edge --> API[Serverpod RPC + REST v2]
  API --> Guard[Identity + tenant + role + validation]
  Guard --> Modules[Business modules]
  Guard <--> Auth[Firebase Authentication]
  Modules <--> DB[(PostgreSQL authoritative records)]
  Modules --> Outbox[Transactional outbox]
  Outbox --> Workers[Leased bounded workers]
  Workers <--> DB
  Workers --> PayPal[PayPal restaurant marketplace]
  Workers --> Billing[Separate PayPal subscription seller]
  Workers --> Gemini[Gemini EU - reviewed proposals]
  Workers --> Channels[Inbox + FCM + SES]
  Modules --> Files[Firebase Storage private files]
  Clients -.-> Prefs[Firestore private preferences]
  Clients -.-> Presence[RTDB advisory presence]
''',encoding='utf-8')

c=Canvas(1800,1200,'RAYSTO — data relationships','Tenant identifiers accompany business relations; purchased amounts and provider references remain historical evidence')
nodes=[('Actor',60,160,['Registered or guest']),('Membership',640,160,['Restaurant role + active state']),('Restaurant',1220,160,['Settings, currency, subscription']),('Menu / drafts',1220,360,['Items, modifiers, publication']),('Table',60,360,['Stable ID and public QR']),('Visit',640,360,['Active party and participants']),('Order',640,570,['Immutable lines + fulfillment']),('Reservation',60,570,['Timed hold + table allocation']),('Checkout attempt',1220,570,['Frozen amount + provider state']),('Bill charge',60,800,['Obligation, credit, paid, reserved']),('Payment allocation',640,800,['Exact units or minor-unit share']),('Capture / refund',1220,800,['External evidence + ledger']),('Jobs / audit / inbox',60,1010,['Durable effects and history']),('Kitchen / delivery',640,1010,['Preparation and handoffs']),('Commission / billing',1220,1010,['Versioned revenue accounting'])]
for title,x,y,lines in nodes:c.box(x,y,490,110,title,lines)
for points in [[(550,215),(640,215)],[(1130,215),(1220,215)],[(1465,270),(1465,360)],[(550,415),(640,415)],[(885,470),(885,570)],[(305,470),(305,570)],[(305,570),(305,520),(710,520),(710,470)],[(1130,625),(1220,625)],[(885,680),(885,735),(305,735),(305,800)],[(550,855),(640,855)],[(1130,855),(1220,855)],[(1465,680),(1465,735),(1100,735),(1100,800)],[(1465,735),(1465,800)],[(1465,910),(1465,1010)],[(885,680),(1180,680),(1180,980),(885,980),(885,1010)]]:c.arrow(points)
c.save('data-relationships')
(OUT/'data-relationships.mmd').write_text('''erDiagram
  ACTOR ||--o{ MEMBERSHIP : has
  RESTAURANT ||--o{ MEMBERSHIP : authorizes
  RESTAURANT ||--o{ MENU_ITEM : publishes
  RESTAURANT ||--o{ TABLE : contains
  RESTAURANT ||--o{ SUBSCRIPTION : subscribes
  TABLE ||--o{ VISIT : hosts
  TABLE ||--o{ RESERVATION : reserves
  VISIT ||--o{ PARTICIPANT : admits
  ACTOR ||--o{ PARTICIPANT : joins
  VISIT o|--o{ ORDER : groups
  ORDER ||--|{ ORDER_LINE : freezes
  ORDER ||--o{ BILL_CHARGE : creates
  ORDER ||--o{ KITCHEN_TICKET : prepares
  ORDER ||--o| DELIVERY_TASK : fulfills
  CHECKOUT_ATTEMPT ||--|{ PAYMENT_ALLOCATION : reserves
  BILL_CHARGE ||--o{ PAYMENT_ALLOCATION : receives
  CHECKOUT_ATTEMPT ||--o| CAPTURE : records
  CAPTURE ||--o{ REFUND : refunds
  CAPTURE ||--o{ COMMISSION_ENTRY : produces
''',encoding='utf-8')

c=Canvas(1800,1280,'RAYSTO — payment workflow','Approval redirects are a handoff. Only verified provider evidence changes collected money.')
xs=[205,655,1105,1555]
for x,title in zip(xs,['Customer / waiter','Raysto API','PostgreSQL','PayPal']):c.box(x-145,155,290,80,title,[],ORANGE)
for x in xs:c.arrow([(x,260),(x,1090)],'#314b63')
steps=[(0,1,'1  Confirm bill selection',320),(1,2,'2  Lock balance; reserve exact allocation',410),(1,3,'3  Create order with stable request ID',500),(3,0,'4  Return approval URL; customer approves',590),(0,1,'5  Request completion',680),(1,3,'6  Read provider state; capture if approved',770),(3,1,'7  Verified capture result or signed webhook',860),(1,2,'8  Settle allocations; save receipt + outbox',950),(1,0,'9  Return remaining balance and receipt',1040)]
for a,b,text,y in steps:c.arrow([(xs[a],y),(xs[b],y)],CYAN);c.text(min(xs[a],xs[b])+12,y-37,text,21,TEXT)
c.box(60,1120,1680,90,'IF THE RESPONSE IS LOST',['Keep the allocation reserved → reconcile the same provider order → never create a replacement charge from a timeout.'],ORANGE)
c.save('payment-workflow')
(OUT/'payment-workflow.mmd').write_text('''sequenceDiagram
  participant C as Customer / waiter
  participant A as Raysto API
  participant D as PostgreSQL
  participant P as PayPal
  C->>A: Confirm selection and stable request key
  A->>D: Lock and reserve frozen bill allocation
  A->>P: Create with stable provider request ID
  P-->>C: Approval URL
  C->>P: Approve
  C->>A: Complete checkout
  A->>P: Read and capture if eligible
  P-->>A: Authoritative result
  A->>D: Capture, allocations, commission and outbox
  P->>A: Signed webhook
  A->>D: Durable deduplicated inbox
  Note over A,P: Lost responses remain uncertain and are reconciled
  A-->>C: Receipt and remaining balance
''',encoding='utf-8')
print('Exported four editable Mermaid maps, four SVGs and four PNGs.')
