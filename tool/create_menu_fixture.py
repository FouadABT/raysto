from pathlib import Path
from reportlab.pdfgen import canvas
from reportlab.lib.colors import HexColor

root = Path(__file__).resolve().parents[1]
folder = root / 'assets' / 'fixtures'
folder.mkdir(exist_ok=True)
c = canvas.Canvas(str(folder / 'olive-menu.pdf'), pagesize=(595, 842))
c.setTitle('Olive Kitchen - authored demo menu import fixture')
c.setFillColor(HexColor('#F6F7F2')); c.rect(0, 0, 595, 842, fill=1, stroke=0)
c.setFillColor(HexColor('#173F35')); c.setFont('Helvetica-Bold', 35)
c.drawString(48, 755, 'OLIVE KITCHEN')
c.setFont('Helvetica', 15); c.drawString(48, 720, 'A little fresh. A lot of flavour.')
c.setStrokeColor(HexColor('#173F35')); c.line(48, 691, 547, 691)
items = [('Garden bowl', 'Seasonal greens, chickpeas, lemon dressing', 'EUR 9.00'), ('Grilled chicken wrap', 'Grilled chicken, crisp salad, flatbread', 'EUR 10.00'), ('House lemonade', 'Lemon, water, a little sugar', 'EUR 3.?0'), ('Soup of the day', 'Ask us about today\'s ingredients', 'EUR 7.00')]
for i, (name, description, price) in enumerate(items):
    y = 640 - i * 105
    c.setFillColor(HexColor('#173F35')); c.setFont('Helvetica-Bold', 19); c.drawString(48, y, name)
    c.setFont('Helvetica', 16); c.drawRightString(547, y, price)
    c.setFont('Helvetica', 12); c.drawString(48, y - 27, description)
c.setFont('Helvetica-Bold', 12); c.drawString(48, 165, 'REVIEW NEEDED')
c.setFont('Helvetica', 11); c.drawString(48, 143, 'Confirm the lemonade price and soup dietary information before publishing.')
c.drawString(48, 90, 'Authored local demo fixture. Not a real restaurant menu.')
c.drawString(48, 72, 'Prices in EUR. Importing this fixture does not invoke an AI service.')
c.save()
