#!/usr/bin/env bash
set -e

# 1. Dosyaları oluştur
mkdir -p evidence

# app.py
cat > app.py << 'EOQ'
import os
from flask import Flask

app = Flask(__name__)

@app.route('/')
def health():
    return 'OK'

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port)
EOQ

# ingestion.py
cat > ingestion.py << 'EOQ'
import os, json, requests
from dotenv import load_dotenv

load_dotenv()
PAGE_ACCESS_TOKEN = os.getenv('PAGE_ACCESS_TOKEN')
IG_BUSINESS_ID = os.getenv('IG_BUSINESS_ID')

def ingest_posts():
    url = f"https://graph.facebook.com/v14.0/{IG_BUSINESS_ID}/media"
    params = {'access_token': PAGE_ACCESS_TOKEN, 'fields': 'id,caption,timestamp,username'}
    resp = requests.get(url, params=params); resp.raise_for_status()
    with open('posts.json','w') as f: json.dump(resp.json(), f)

if __name__=='__main__':
    ingest_posts()
EOQ

# download_evidence.py
cat > download_evidence.py << 'EOQ'
import os, json, requests
from dotenv import load_dotenv

load_dotenv()
IG_ACCESS_TOKEN = os.getenv('IG_ACCESS_TOKEN')

def download_evidence():
    os.makedirs('evidence', exist_ok=True)
    with open('posts.json') as f: data = json.load(f)
    for m in data.get('data', []):
        mid = m['id']
        url = f"https://graph.facebook.com/v14.0/{mid}?fields=media_url&access_token={IG_ACCESS_TOKEN}"
        mu = requests.get(url).json().get('media_url')
        img = requests.get(mu).content
        open(f"evidence/{mid}.jpg","wb").write(img)

if __name__=='__main__':
    download_evidence()
EOQ

# classification.py
cat > classification.py << 'EOQ'
import os, openai
from dotenv import load_dotenv

load_dotenv()
openai.api_key = os.getenv('OPENAI_API_KEY')

def classify_text(text):
    res = openai.Moderation.create(input=text)
    return res['results'][0]['categories']

if __name__=='__main__':
    print(classify_text("Test metni"))
EOQ

# login_and_save_state.py
cat > login_and_save_state.py << 'EOQ'
import os, json
from playwright.sync_api import sync_playwright
from dotenv import load_dotenv

load_dotenv()
IG_USER = os.getenv('IG_USER'); IG_PASS = os.getenv('IG_PASS')

def login_and_save_state():
    with sync_playwright() as p:
        b = p.chromium.launch(headless=True)
        ctx = b.new_context()
        pg = ctx.new_page()
        pg.goto("https://www.instagram.com/accounts/login/")
        pg.fill("input[name='username']", IG_USER)
        pg.fill("input[name='password']", IG_PASS)
        pg.click("button[type='submit']")
        pg.wait_for_timeout(5000)
        open("state.json","w").write(json.dumps(ctx.storage_state()))
        b.close()

if __name__=="__main__":
    login_and_save_state()
EOQ

# screenshot.py
cat > screenshot.py << 'EOQ'
import os, json
from dotenv import load_dotenv
from playwright.sync_api import sync_playwright

load_dotenv()
def take_screenshots():
    st = json.load(open("state.json"))
    posts = json.load(open("posts.json"))['data']
    with sync_playwright() as p:
        b = p.chromium.launch(headless=True)
        ctx = b.new_context(storage_state=st)
        pg = ctx.new_page()
        for post in posts:
            pg.goto(f"https://www.instagram.com/p/{post['id']}/")
            pg.screenshot(path=f"evidence/{post['id']}_post.png", full_page=True)
            pg.goto(f"https://www.instagram.com/{post['username']}/")
            pg.screenshot(path=f"evidence/{post['id']}_profile.png", full_page=True)
        b.close()

if __name__=="__main__":
    take_screenshots()
EOQ

# rpa_uyap.py
cat > rpa_uyap.py << 'EOQ'
import os
from docxtpl import DocxTemplate

def generate_pdf(data):
    tpl = DocxTemplate("template.udf")
    tpl.render(data)
    out="output.docx"
    tpl.save(out)
    os.system(f"libreoffice --headless --convert-to pdf {out}")

if __name__=="__main__":
    print("RPA modülü hazır.")
EOQ

# orchestrator.py
cat > orchestrator.py << 'EOQ'
import json, ingestion, download_evidence, classification, screenshot, rpa_uyap

def main():
    ingestion.ingest_posts()
    download_evidence.download_evidence()
    data = json.load(open("posts.json"))['data']
    approved = [p for p in data if not any(classification.classify_text(p.get('caption',"")).get(c) for c in ['hate','violence'])]
    json.dump({'data':approved}, open("approved_data.json","w"))
    screenshot.take_screenshots()
    if approved:
        rpa_uyap.generate_pdf({
            'USERNAME':'Ad Soyad',
            'DATE':'2025-05-05',
            'COMMENT':'Onaylanan içerik',
            'EVIDENCE_URL':'https://example.com/evidence'
        })

if __name__=="__main__":
    main()
EOQ

# template.udf
cat > template.udf << 'EOQ'
DİLEKÇE
Ad: {{USERNAME}}
Tarih: {{DATE}}

Metin:
{{COMMENT}}

Kanıt URL:
{{EVIDENCE_URL}}
EOQ

# requirements.txt
cat > requirements.txt << 'EOQ'
flask
gunicorn
python-dotenv
requests
openai
playwright
docxtpl
EOQ

# Procfile
cat > Procfile << 'EOQ'
web: gunicorn app:app
worker: python orchestrator.py
EOQ

# .gitignore
cat > .gitignore << 'EOQ'
venv/
__pycache__/
*.pyc
.env
state.json
evidence/
EOQ

# .env.example
cat > .env.example << 'EOQ'
IG_ACCESS_TOKEN=your_ig_access_token
PAGE_ACCESS_TOKEN=your_page_access_token
IG_BUSINESS_ID=your_ig_business_id
IG_USER=your_instagram_username
IG_PASS=your_instagram_password
OPENAI_API_KEY=your_openai_api_key
EOQ

# 2. Commit & Push
git add .
git commit -m "Initial commit: full otomasyon sistemi hazır"
git push https://$GITHUB_TOKEN@github.com/muysalperen/otomasyon-sistem.git main

