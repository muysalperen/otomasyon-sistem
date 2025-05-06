import os
import json
import requests
import time
from dotenv import load_dotenv

load_dotenv()
IG_ACCESS_TOKEN = os.getenv('IG_ACCESS_TOKEN')

def download_evidence():
    """
    Instagram Business Graph API üzerinden çekilen gönderilere ait medya URL'lerini indirir.
    Eğer media_url None ise uyarı basıp atlar.
    """
    os.makedirs('evidence', exist_ok=True)
    with open('posts.json') as f:
        data = json.load(f).get('data', [])
    for media in data:
        media_id = media.get('id')
        url = (
            f"https://graph.facebook.com/v14.0/{media_id}"
            f"?fields=media_url&access_token={IG_ACCESS_TOKEN}"
        )
        resp = requests.get(url)
        resp.raise_for_status()
        media_url = resp.json().get('media_url')
        if not media_url:
            print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] Uyarı: media_url bulunamadı (id={media_id}), atlanıyor.", flush=True)
            continue
        try:
            img_resp = requests.get(media_url)
            img_resp.raise_for_status()
            with open(f"evidence/{media_id}.jpg", 'wb') as img:
                img.write(img_resp.content)
            print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] İndirildi: evidence/{media_id}.jpg", flush=True)
        except Exception as e:
            print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] Hata indirirken (id={media_id}): {e}", flush=True)

if __name__ == '__main__':
    download_evidence()
