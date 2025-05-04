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
