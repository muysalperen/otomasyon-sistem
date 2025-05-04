import os, openai
from dotenv import load_dotenv

load_dotenv()
openai.api_key = os.getenv('OPENAI_API_KEY')

def classify_text(text):
    res = openai.Moderation.create(input=text)
    return res['results'][0]['categories']

if __name__=='__main__':
    print(classify_text("Test metni"))
