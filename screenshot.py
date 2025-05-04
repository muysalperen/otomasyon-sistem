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
