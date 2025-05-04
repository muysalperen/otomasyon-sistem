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
