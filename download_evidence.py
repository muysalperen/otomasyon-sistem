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
