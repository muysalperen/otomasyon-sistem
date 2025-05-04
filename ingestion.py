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
